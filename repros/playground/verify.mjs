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
const empty = await readFile(path.join(root, 'empty-stream.tsx'), 'utf8');
const recovery = await readFile(path.join(root, 'held-recovery.tsx'), 'utf8');
function replace(text, before, after) {
  assert.equal(text.split(before).length, 2, `Control must change exactly one application site: ${before}`);
  return text.replace(before, after);
}
const cases = [
  { name: 'empty-stream', code: empty, text: 'Value: [object Object]', error: null },
  { name: 'empty-direct-control', code: replace(empty, '() => immediately(empty)', '() => empty'), text: 'Value: undefined', error: null },
  {
    name: 'empty-native-control',
    // A genuinely async first load needs the normal Loading scope in dev.
    code: replace(replace(replace(empty, '{ createMemo }', '{ createMemo, Loading }'),
      '() => immediately(empty)', '() => Promise.resolve(empty)'),
      '<p>Value: {String(value())}</p>', '<Loading fallback="Loading..."><p>Value: {String(value())}</p></Loading>'),
    text: 'Value: undefined', error: null
  },
  { name: 'held-recovery', code: recovery, text: 'Sum: 2', error: '1' },
  { name: 'held-changed-recovery', code: replace(recovery, 'return 1;', 'return step() === 2 ? 7 : 1;'), text: 'Sum: 2', error: '7' },
  { name: 'held-no-error-control', code: replace(recovery, 'if (step() === 1) throw new Error("boom");', ''), text: 'Sum: 3', error: null }
];
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
let browser;
const rows = [];
try {
  browser = await chromium.launch({
    headless: true, args: ['--no-sandbox'],
    ...(process.env.CHROMIUM_PATH ? { executablePath: process.env.CHROMIUM_PATH } : {})
  });
  for (const dev of [false, true]) for (const test of cases) {
    const page = await browser.newPage();
    const errors = [], reports = [], states = [];
    let step = 'initial';
    page.on('pageerror', error => errors.push({ step, message: error.message }));
    page.on('console', message => { if (message.type() === 'error') reports.push({ step, message: message.text() }); });
    await page.goto(`http://127.0.0.1:${server.address().port}/${test.name}-${dev ? 'dev' : 'prod'}.html`);
    await page.locator('p').waitFor();
    states.push({ step, text: await page.locator('p').innerText() });
    if (test.name.startsWith('held-')) {
      assert.equal(states[0].text, 'Sum: 2');
      for (const label of ['1. Start update', '2. Recover', '3. Finish request']) {
        step = label;
        await page.getByRole('button', { name: label, exact: true }).click();
        // A separate browser task for each manual click; no flush(), effects,
        // runtime instrumentation, or timing logic is added to the component.
        await page.evaluate(() => new Promise(resolve => setTimeout(resolve, 0)));
        states.push({ step, text: await page.locator('p').innerText() });
        if (label !== '3. Finish request') {
          assert.equal(states.at(-1).text, 'Sum: 2');
          assert.deepEqual(errors, []);
          assert.deepEqual(reports, []);
        }
      }
    }
    assert.equal(states.at(-1).text, test.text, `${test.name} dev=${dev}`);
    if (test.error === null) {
      assert.deepEqual(errors, []);
      assert.deepEqual(reports, []);
    } else {
      assert.ok(errors.length > 0);
      assert.ok(errors.every(e => e.step === '3. Finish request' && e.message === test.error));
      assert.ok(reports.some(e => e.message.includes('[REACTIVITY_HALTED]')));
    }
    rows.push({ name: test.name, profile: dev ? 'development' : 'production', states, errors, reports });
    console.log(`${test.name} / ${dev ? 'development' : 'production'}: ${test.text}${test.error ? `; throws ${test.error} on final click` : ''}`);
    await page.close();
  }
  await writeFile(path.join(root, 'verification.json'), JSON.stringify({
    date: new Date().toISOString(), sourceCommit: commit, browser: await browser.version(), node: process.version,
    claim: 'Specific baseline failures and paired controls for compiled JSX in connected Chromium DOM; no proof of intended behavior or hosted playground execution.',
    cases: rows
  }, null, 2) + '\n');
} finally {
  await browser?.close();
  await new Promise(resolve => server.close(resolve));
}
