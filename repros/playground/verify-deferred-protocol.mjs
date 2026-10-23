// Actual one-button JSX against unchanged source-built b9b6f333 runtime and
// JSX compiler. Only the passing application's next() gains the async keyword.
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {mkdtemp,readFile,writeFile,rm} from 'node:fs/promises';
import path from 'node:path';
import http from 'node:http';
import {transformSync} from '@babel/core';
import presetTypeScript from '@babel/preset-typescript';
import {build} from 'esbuild';
import {chromium} from 'playwright';

const root=fileURLToPath(new URL('.',import.meta.url));
if(!process.argv[2])throw new Error('Pass a clean Solid b9b6f333 checkout path.');
const source=path.resolve(process.argv[2]),commit='b9b6f3339a971b9ea06740151b029987a84ee13e';
const git=args=>execFileSync('git',args,{cwd:source,encoding:'utf8'}).trim();
assert.equal(git(['rev-parse','HEAD']),commit);
assert.equal(git(['status','--porcelain','--','packages/signals/src','packages/solid/src','packages/web/src','packages/babel-plugin/src']),'');
const output=await mkdtemp(path.join(root,'.protocol-build-')),require=createRequire(import.meta.url);
let browser,server;
try{
  await build({entryPoints:[path.join(source,'packages/babel-plugin/src/index.ts')],outfile:path.join(output,'compiler.cjs'),bundle:true,platform:'node',format:'cjs',external:['@tsrx/core'],nodePaths:[path.join(root,'node_modules'),path.join(path.dirname(require.resolve('@solidjs/babel-plugin')),'node_modules')]});
  const compiler=require(path.join(output,'compiler.cjs')).default;
  const code=await readFile(path.join(root,'deferred-protocol-error.tsx'),'utf8');
  assert.equal(code.split('next() {').length,2);
  for(const [tier,dev,observe]of[['prod',false,false],['dev',true,true],['observe',false,true]])for(const control of[false,true]){
    const name=tier+(control?'-async':'-sync');
    const transformed=transformSync(control?code.replace('next() {','async next() {'):code,{filename:name+'.tsx',babelrc:false,configFile:false,presets:[presetTypeScript],plugins:[[compiler,{generate:'dom',moduleName:'@solidjs/web'}]]});
    await build({stdin:{contents:transformed.code,resolveDir:source,sourcefile:name+'.tsx'},outfile:path.join(output,name+'.js'),bundle:true,platform:'browser',format:'esm',define:{__DEV__:String(dev),__OBSERVE__:String(observe),__TEST__:'false'},alias:{'solid-js':path.join(source,'packages/solid/src/index.ts'),'solid-js/web':path.join(source,'packages/web/src/index.ts'),'solid-js/internal':path.join(source,'packages/solid/src/internal.ts'),'@solidjs/signals':path.join(source,'packages/signals/src/index.ts'),'@solidjs/web':path.join(source,'packages/web/src/index.ts')},plugins:[{name:'source-build-flags',setup(builder){builder.onLoad({filter:/\.ts$/},async args=>({contents:(await readFile(args.path,'utf8')).replaceAll('"_SOLID_DEV_"',String(dev)).replaceAll('"_SOLID_OBSERVE_"',String(observe)),loader:'ts'}));}}]});
    await writeFile(path.join(output,name+'.html'),`<!doctype html><link rel="icon" href="data:,"><div id="root"></div><script type="module" src="./${name}.js"></script>`);
  }
  server=http.createServer(async(req,res)=>{
    const pathname=new URL(req.url,'http://localhost').pathname;
    if(!/^\/[a-z-]+\.(html|js)$/.test(pathname)){res.writeHead(404).end();return;}
    try{const file=path.join(output,pathname);res.setHeader('Content-Type',file.endsWith('.js')?'text/javascript':'text/html');res.end(await readFile(file));}catch{res.writeHead(404).end();}
  });
  await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
  browser=await chromium.launch({headless:true,args:['--no-sandbox'],...(process.env.CHROMIUM_PATH?{executablePath:process.env.CHROMIUM_PATH}:{})});
  const rows=[];
  for(const tier of['prod','dev','observe'])for(const control of[false,true]){
    const page=await browser.newPage(),errors=[],reports=[];
    page.on('pageerror',error=>errors.push(error.message));
    page.on('console',message=>{if(message.type()==='error')reports.push(message.text());});
    await page.addInitScript(()=>{
      window.__protocolLogs=[];const log=console.log;
      console.log=(...args)=>{window.__protocolLogs.push(args.map(value=>value instanceof Error?value.message:value));return log.apply(console,args);};
    });
    await page.goto(`http://127.0.0.1:${server.address().port}/${tier}-${control?'async':'sync'}.html`);
    await page.getByRole('button',{name:'Run',exact:true}).click();
    await page.waitForFunction(()=>window.__protocolLogs.some(row=>row[0]==='Pending:'));
    if(control)await page.waitForFunction(()=>window.__protocolLogs.some(row=>row[0]==='Error:'));
    await page.waitForTimeout(50);
    const logs=await page.evaluate(()=>window.__protocolLogs);
    assert.deepEqual(logs,control?[['Pending:',false],['Error:','stream failed']]:[['Pending:',true]],tier+' console sequence');
    assert.deepEqual(errors,[]);assert.deepEqual(reports,[]);
    rows.push({tier,control,logs,errors,reports});await page.close();
  }
  const record={sourceCommit:commit,sourceTreeClean:true,browser:browser.version(),reproducer:'deferred-protocol-error.tsx',control:'Only next() becomes async; no flush, extra button or source patch.',rows};
  await writeFile(path.join(root,'deferred-protocol-error-browser.json'),JSON.stringify(record,null,2)+'\n');
  console.log(JSON.stringify(record));
}finally{
  await browser?.close();if(server)await new Promise(resolve=>server.close(resolve));await rm(output,{recursive:true,force:true});
}
