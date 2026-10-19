// Test the actual JSX components in connected Chromium DOM, using the unchanged
// Solid runtime AND JSX compiler at the recorded source commit. Test controls
// change the application only. No Bend runtime/adapter or private exports.
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import http from 'node:http';
import path from 'node:path';
import { transformSync } from '@babel/core';
import presetTypeScript from '@babel/preset-typescript';
import { build } from 'esbuild';
import { chromium } from 'playwright';

const root = fileURLToPath(new URL('.', import.meta.url));
const output = path.join(root, '.build');
const source = process.argv[2] ? path.resolve(process.argv[2]) : path.join(root, '.solid-source');
const commit = 'd2ad8b288886a5c7171e6746ccc019ad1d08d8ab';
const git = args => execFileSync('git', args, { cwd: source, encoding: 'utf8' }).trim();
await mkdir(output, { recursive: true });
if (!process.argv[2]) {
  await mkdir(source, { recursive: true });
  git(['init', '--quiet']);
  git(['fetch', '--depth=1', 'https://github.com/solidjs/solid.git', commit]);
  git(['checkout', '--detach', '--quiet', 'FETCH_HEAD']);
}
assert.equal(git(['rev-parse', 'HEAD']), commit);
assert.equal(git(['status', '--porcelain', '--', 'packages/signals/src', 'packages/solid/src', 'packages/web/src', 'packages/babel-plugin/src']), '');
const require = createRequire(import.meta.url);
await build({
  entryPoints: [path.join(source, 'packages/babel-plugin/src/index.ts')],
  outfile: path.join(output, 'compiler.cjs'), bundle: true, platform: 'node', format: 'cjs',
  external: ['@tsrx/core'],
  nodePaths: [path.join(root, 'node_modules'), path.join(path.dirname(require.resolve('@solidjs/babel-plugin')), 'node_modules')]
});
const compiler = require(path.join(output, 'compiler.cjs')).default;
const baseline=await readFile(path.join(root,'held-function.tsx'),'utf8');
const cases=[
 {name:'function-held',code:baseline,result:'string',calls:1,initial:'0 / function / 0'},
 {name:'function-unheld',code:baseline.replace('version() === 0 ? 0 : request','version()'),result:'function',calls:0,initial:'0 / function / 0'},
 {name:'function-plain',code:baseline.replace('createSignal<() => string>(() => {\n    version();\n    return () => "derived";\n  })','createSignal<() => string>()'),result:'function',calls:0,initial:'0 / undefined / 0'}
];
for(const control of cases.slice(1))assert.notEqual(control.code,baseline);
for (const dev of [false, true]) for (const test of cases) {
  const { code } = transformSync(test.code, {
    filename: test.name + '.tsx', babelrc: false, configFile: false,
    presets: [presetTypeScript], plugins: [[compiler, { generate: 'dom', moduleName: '@solidjs/web' }]]
  });
  const name = `${test.name}-${dev ? 'dev' : 'prod'}`;
  await build({
    stdin: { contents: code, resolveDir: source, sourcefile: test.name + '.tsx' },
    outfile: path.join(output, name + '.js'), bundle: true, platform: 'browser', format: 'esm',
    define: { __DEV__: String(dev), __OBSERVE__: String(dev), __TEST__: 'false' },
    alias: {
      'solid-js': path.join(source, 'packages/solid/src/index.ts'),
      'solid-js/internal': path.join(source, 'packages/solid/src/internal.ts'),
      '@solidjs/signals': path.join(source, 'packages/signals/src/index.ts'),
      '@solidjs/web': path.join(source, 'packages/web/src/index.ts')
    },
    // These are the literal substitutions in upstream's Rollup configs.
    plugins: [{ name: 'upstream-build-flags', setup(build) {
      build.onLoad({ filter: /\.ts$/ }, async args => ({
        contents: (await readFile(args.path, 'utf8')).replaceAll('"_SOLID_DEV_"', String(dev)).replaceAll('"_SOLID_OBSERVE_"', String(dev)),
        loader: 'ts'
      }));
    } }]
  });
  await writeFile(path.join(output, name + '.html'), `<!doctype html><link rel="icon" href="data:,"><div id="root"></div><script type="module" src="./${name}.js"></script>`);
}
const server = http.createServer(async (req, res) => {
  const pathname = new URL(req.url, 'http://localhost').pathname;
  if (!/^\/[a-z-]+\.(html|js)$/.test(pathname)) { res.writeHead(404).end(); return; }
  try {
    const file = path.join(output, pathname);
    res.setHeader('Content-Type', file.endsWith('.js') ? 'text/javascript' : 'text/html');
    res.end(await readFile(file));
  } catch { res.writeHead(404).end(); }
});
await new Promise(ok => server.listen(0, '127.0.0.1', ok));
let browser;const rows=[];
try{
 browser=await chromium.launch({headless:true,args:['--no-sandbox'],...(process.env.CHROMIUM_PATH?{executablePath:process.env.CHROMIUM_PATH}:{})});
 for(const dev of [false,true])for(const test of cases){
  const page=await browser.newPage(),errors=[],reports=[],logs=[],states=[];
  page.on('pageerror',error=>errors.push(error.message));
  page.on('console',message=>{if(message.type()==='error')reports.push(message.text());if(message.text()==='Replacement invoked')logs.push(message.text());});
  await page.goto(`http://127.0.0.1:${server.address().port}/${test.name}-${dev?'dev':'prod'}.html`);
  await page.locator('p').waitFor();assert.equal(await page.locator('p').innerText(),test.initial);
  for(const label of ['1. Start update','2. Store callback','3. Finish request']){
   await page.getByRole('button',{name:label,exact:true}).click();
   await page.evaluate(()=>new Promise(resolve=>setTimeout(resolve,0)));
   states.push({step:label,text:await page.locator('p').innerText()});
   if(label==='2. Store callback'){
    assert.equal(await page.getByRole('button',{name:'Returned: '+test.result,exact:true}).count(),1);
    assert.equal(logs.length,test.calls);
   }
  }
  assert.equal(states.at(-1).text,'1 / function / 1');assert.deepEqual(errors,[]);assert.deepEqual(reports,[]);
  rows.push({name:test.name,profile:dev?'development':'production',states,returned:test.result,unexpectedInvocations:logs.length,errors,reports});
  console.log(`${test.name} / ${dev?'development':'production'}: setter returns ${test.result}, replacement calls ${logs.length}`);
  await page.close();
 }
 await writeFile(path.join(root,'held-function-verification.json'),JSON.stringify({date:new Date().toISOString(),sourceCommit:commit,browser:await browser.version(),node:process.version,cases:rows},null,2)+'\n');
}finally{await browser?.close();await new Promise(resolve=>server.close(resolve));}
