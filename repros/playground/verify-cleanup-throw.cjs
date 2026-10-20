// Runs the JSX repro against unchanged Solid runtime and compiler source.
// The no-throw control changes application code only; no private exports.
const fs = require('node:fs');
const assert = require('node:assert/strict');
const http = require('node:http');
const { execFileSync } = require('node:child_process');
const path = require('node:path');
const root = __dirname;
const requireRepro = require('node:module').createRequire(root + '/package.json');
const { build } = requireRepro('esbuild');
const { transformSync } = requireRepro('@babel/core');
const { chromium } = requireRepro('playwright');
if (!process.argv[2]) throw new Error('Usage: node verify-cleanup-throw.cjs /path/to/solid-at-a2743fa2');
const source = path.resolve(process.argv[2]);
const out = path.join(root, '.build', 'cleanup-throw');
fs.mkdirSync(out, {recursive:true});
const original = fs.readFileSync(root + '/cleanup-throw.tsx', 'utf8');
(async () => {
  const git = args => execFileSync('git', args, {cwd:source,encoding:'utf8'}).trim();
  assert.equal(git(['rev-parse','HEAD']), 'a2743fa2d26d78f38c42600b91aceddb43a1c3ef');
  assert.equal(git(['status','--porcelain','--','packages/signals/src','packages/solid/src','packages/web/src','packages/babel-plugin/src']), '');
  await build({entryPoints:[source+'/packages/babel-plugin/src/index.ts'],outfile:out+'/issue-compiler.cjs',bundle:true,platform:'node',format:'cjs',external:['@tsrx/core'],nodePaths:[root+'/node_modules']});
  const compiler = require(out+'/issue-compiler.cjs').default;
  const cases=[];
  for(const dev of [false,true])for(const throws of [false,true]){
    const name='issue-'+(dev?'dev':'prod')+'-'+(throws?'throw':'control');
    const text=throws?original:original.replace('throw new Error("cleanup failed");','return;');
    const {code}=transformSync(text,{filename:'main.tsx',babelrc:false,configFile:false,presets:[requireRepro('@babel/preset-typescript')],plugins:[[compiler,{generate:'dom',moduleName:'@solidjs/web'}]]});
    await build({stdin:{contents:code,resolveDir:source,sourcefile:'main.tsx'},outfile:out+'/'+name+'.js',bundle:true,platform:'browser',format:'esm',define:{__DEV__:String(dev),__OBSERVE__:String(dev),__TEST__:'false'},alias:{'solid-js/web':source+'/packages/web/src/index.ts','solid-js':source+'/packages/solid/src/index.ts','solid-js/internal':source+'/packages/solid/src/internal.ts','@solidjs/signals':source+'/packages/signals/src/index.ts','@solidjs/web':source+'/packages/web/src/index.ts'},plugins:[{name:'upstream-build-flags',setup(b){b.onLoad({filter:/\.ts$/},async args=>({contents:(await fs.promises.readFile(args.path,'utf8')).replaceAll('"_SOLID_DEV_"',String(dev)).replaceAll('"_SOLID_OBSERVE_"',String(dev)),loader:'ts'}));}}]});
    fs.writeFileSync(out+'/'+name+'.html',`<!doctype html><link rel="icon" href="data:,"><div id="root"></div><script type="module" src="/${name}.js"></script>`);
    cases.push({name,dev,throws});
  }
  const server=http.createServer((req,res)=>{
    if(!/^\/issue-[a-z-]+\.(js|html)$/.test(req.url)){res.writeHead(404).end();return;}
    res.setHeader('Content-Type',req.url.endsWith('.js')?'text/javascript':'text/html');res.end(fs.readFileSync(out+req.url));
  });
  await new Promise(ok=>server.listen(0,'127.0.0.1',ok));
  let browser;const rows=[];
  try{
    browser=await chromium.launch({executablePath:'/usr/bin/chromium',headless:true,args:['--no-sandbox']});
    for(const test of cases){
      const page=await browser.newPage(),errors=[],reports=[];
      page.on('pageerror',e=>errors.push(e.message));
      page.on('console',m=>{if(m.type()==='error')reports.push(m.text());});
      await page.goto(`http://127.0.0.1:${server.address().port}/${test.name}.html`);
      await page.getByRole('button',{name:'Run',exact:true}).click();
      const expected='Cleanup count: '+(test.throws?0:1);
      await page.locator('p').filter({hasText:expected}).waitFor({timeout:10000});
      assert.deepEqual(errors,[]);assert.deepEqual(reports,[]);
      rows.push({...test,text:await page.locator('p').innerText(),errors,reports});
      await page.close();
    }
    const record={sourceCommit:git(['rev-parse','HEAD']),browser:await browser.version(),cases:rows};
    fs.writeFileSync(root+'/cleanup-throw-verification.json',JSON.stringify(record,null,2)+'\n');
    console.log(JSON.stringify(record));
  }finally{await browser?.close();await new Promise(ok=>server.close(ok));}
})().catch(e=>{console.error(e);process.exitCode=1;});
