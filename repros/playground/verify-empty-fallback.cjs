// Builds the real JSX component with unchanged upstream compiler/runtime source.
const fs=require('node:fs'),assert=require('node:assert/strict'),http=require('node:http'),path=require('node:path');
const {execFileSync}=require('node:child_process');
const root=__dirname,source=path.resolve(process.argv[2]??'/workspace/solid-repin-0222d684');
const req=require('node:module').createRequire(root+'/package.json');
const {build}=req('esbuild'),{transformSync}=req('@babel/core'),{chromium}=req('playwright');
const out=root+'/.build/empty-fallback';fs.mkdirSync(out,{recursive:true});
const git=args=>execFileSync('git',args,{cwd:source,encoding:'utf8'}).trim();
(async()=>{
 assert.equal(git(['rev-parse','HEAD']),'0222d684365f08a29dfc1d613e664659f06948c8');
 assert.equal(git(['status','--porcelain','--','packages/signals/src','packages/solid/src','packages/web/src','packages/babel-plugin/src']),'');
 await build({entryPoints:[source+'/packages/babel-plugin/src/index.ts'],outfile:out+'/compiler.cjs',bundle:true,platform:'node',format:'cjs',external:['@tsrx/core'],nodePaths:[root+'/node_modules']});
 const compiler=require(out+'/compiler.cjs').default,original=fs.readFileSync(root+'/empty-fallback.tsx','utf8'),cases=[];
 for(const [profile,dev,observe]of [['production',false,false],['development',true,true],['observe',false,true]])for(const helper of ['For','Repeat'])for(const truthy of [false,true]){
  const name='case-'+profile+'-'+helper.toLowerCase()+'-'+(truthy?'control':'zero');
  let text=truthy?original.replace('return 0;','return 1;'):original;
  if(helper==='Repeat')text=text.replace('{ For,','{ Repeat,').replace('<For each={rows()} fallback={<Empty />}>{row => row}</For>','<Repeat count={rows().length} fallback={<Empty />}>{index => index}</Repeat>');
  const {code}=transformSync(text,{filename:'main.tsx',babelrc:false,configFile:false,presets:[req('@babel/preset-typescript')],plugins:[[compiler,{generate:'dom',moduleName:'@solidjs/web'}]]});
  await build({stdin:{contents:code,resolveDir:source,sourcefile:'main.tsx'},outfile:out+'/'+name+'.js',bundle:true,platform:'browser',format:'esm',define:{__DEV__:String(dev),__OBSERVE__:String(observe),__TEST__:'false'},alias:{'solid-js/web':source+'/packages/web/src/index.ts','solid-js':source+'/packages/solid/src/index.ts','solid-js/internal':source+'/packages/solid/src/internal.ts','@solidjs/signals':source+'/packages/signals/src/index.ts','@solidjs/web':source+'/packages/web/src/index.ts'},plugins:[{name:'upstream-build-flags',setup(b){b.onLoad({filter:/\.ts$/},async args=>({contents:(await fs.promises.readFile(args.path,'utf8')).replaceAll('"_SOLID_DEV_"',String(dev)).replaceAll('"_SOLID_OBSERVE_"',String(observe)),loader:'ts'}));}}]});
  fs.writeFileSync(out+'/'+name+'.html',`<!doctype html><link rel="icon" href="data:,"><div id="root"></div><script type="module" src="/${name}.js"></script>`);cases.push({name,profile,helper,truthy});
 }
 const server=http.createServer((req,res)=>{if(!/^\/case-[a-z-]+\.(js|html)$/.test(req.url)){res.writeHead(404).end();return;}res.setHeader('Content-Type',req.url.endsWith('.js')?'text/javascript':'text/html');res.end(fs.readFileSync(out+req.url));});
 await new Promise(ok=>server.listen(0,'127.0.0.1',ok));let browser;const rows=[];
 try{
  browser=await chromium.launch({executablePath:'/usr/bin/chromium',headless:true,args:['--no-sandbox']});
  for(const test of cases){
   const page=await browser.newPage(),events=[],errors=[];page.on('console',m=>{if(['Empty mounted','Empty cleaned'].includes(m.text()))events.push(m.text());});page.on('pageerror',e=>errors.push(e.message));
   await page.goto(`http://127.0.0.1:${server.address().port}/${test.name}.html`);await page.getByRole('button',{name:'Reload empty rows'}).waitFor();
   assert.deepEqual(events,['Empty mounted']);await page.getByRole('button',{name:'Reload empty rows'}).click();await page.waitForTimeout(20);
   const afterFirst=[...events];assert.deepEqual(afterFirst,test.truthy?['Empty mounted']:['Empty mounted','Empty cleaned','Empty mounted']);
   await page.getByRole('button',{name:'Reload empty rows'}).click();await page.waitForTimeout(20);assert.equal(events.filter(x=>x==='Empty mounted').length,test.truthy?1:3);assert.deepEqual(errors,[]);
   rows.push({...test,afterFirst,afterSecond:[...events],text:await page.locator('body').innerText(),errors});await page.close();
  }
  const record={sourceCommit:git(['rev-parse','HEAD']),browser:await browser.version(),cases:rows};fs.writeFileSync(root+'/empty-fallback-verification.json',JSON.stringify(record,null,2)+'\n');console.log(JSON.stringify(record));
 }finally{await browser?.close();await new Promise(ok=>server.close(ok));}
})().catch(e=>{console.error(e);process.exitCode=1;});
