// Build the actual one-button component with the unchanged pinned sources.
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { mkdtemp, readFile, writeFile, rm } from 'node:fs/promises';
import path from 'node:path';
import http from 'node:http';
import { transformSync } from '@babel/core';
import presetTypeScript from '@babel/preset-typescript';
import { build } from 'esbuild';
import { chromium } from 'playwright';

const root = fileURLToPath(new URL('.', import.meta.url));
assert.ok(process.argv[2], 'Pass a clean Solid checkout at the recorded pin.');
const source = path.resolve(process.argv[2]);
const commit = '2105ffb8ca2fced55f5fac0763177fc93f97c2c2';
const git = args => execFileSync('git', args, { cwd: source, encoding: 'utf8' }).trim();
assert.equal(git(['rev-parse', 'HEAD']), commit);
assert.equal(git(['status', '--porcelain', '--', 'packages/signals/src', 'packages/solid/src', 'packages/web/src', 'packages/babel-plugin/src']), '');
const output = await mkdtemp(path.join(root, '.store-screen-build-'));
const require = createRequire(import.meta.url);
let browser, server;
try {
  await build({ entryPoints: [path.join(source, 'packages/babel-plugin/src/index.ts')], outfile: path.join(output, 'compiler.cjs'), bundle: true, platform: 'node', format: 'cjs', external: ['@tsrx/core'], nodePaths: [path.join(root, 'node_modules'), path.join(path.dirname(require.resolve('@solidjs/babel-plugin')), 'node_modules')] });
  const compiler = require(path.join(output, 'compiler.cjs')).default;
  const original = await readFile(path.join(root, 'store-staged-screen.tsx'), 'utf8');
  assert.equal(original.split('untrack(() => state.count)').length, 2);
  const cases = [];
  for (const [tier, dev, observe] of [['production', false, false], ['development', true, true], ['observe', false, true]]) for (const control of [false, true]) {
    const name = tier + (control ? '-tracked' : '-untracked');
    const code = control ? original.replace('untrack(() => state.count)', 'state.count') : original;
    const transformed = transformSync(code, { filename: name + '.tsx', babelrc: false, configFile: false, presets: [presetTypeScript], plugins: [[compiler, { generate: 'dom', moduleName: '@solidjs/web' }]] });
    await build({ stdin: { contents: transformed.code, resolveDir: source, sourcefile: name + '.tsx' }, outfile: path.join(output, name + '.js'), bundle: true, platform: 'browser', format: 'esm', define: { __DEV__: String(dev), __OBSERVE__: String(observe), __TEST__: 'false' }, alias: { 'solid-js': path.join(source, 'packages/solid/src/index.ts'), 'solid-js/web': path.join(source, 'packages/web/src/index.ts'), 'solid-js/internal': path.join(source, 'packages/solid/src/internal.ts'), '@solidjs/signals': path.join(source, 'packages/signals/src/index.ts'), '@solidjs/web': path.join(source, 'packages/web/src/index.ts') }, plugins: [{ name: 'source-build-flags', setup(builder) { builder.onLoad({ filter: /\.ts$/ }, async args => ({ contents: (await readFile(args.path, 'utf8')).replaceAll('"_SOLID_DEV_"', String(dev)).replaceAll('"_SOLID_OBSERVE_"', String(observe)), loader: 'ts' })); } }] });
    await writeFile(path.join(output, name + '.html'), `<!doctype html><link rel="icon" href="data:,"><div id="root"></div><script type="module" src="./${name}.js"></script>`);
    cases.push({ name, tier, control });
  }
  server = http.createServer(async (req, res) => {
    const pathname = new URL(req.url, 'http://localhost').pathname;
    if (!/^\/[a-z-]+\.(html|js)$/.test(pathname)) { res.writeHead(404).end(); return; }
    try { res.setHeader('Content-Type', pathname.endsWith('.js') ? 'text/javascript' : 'text/html'); res.end(await readFile(path.join(output, pathname))); } catch { res.writeHead(404).end(); }
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  browser = await chromium.launch({ headless: true, executablePath: process.env.CHROMIUM_PATH ?? '/usr/bin/chromium', args: ['--no-sandbox'] });
  const rows = [];
  for (const test of cases) {
    const page = await browser.newPage(), errors = [], reports = [];
    page.on('pageerror', error => errors.push(error.message));
    page.on('console', message => { if (message.type() === 'error') reports.push(message.text()); });
    await page.goto(`http://127.0.0.1:${server.address().port}/${test.name}.html`);
    assert.equal(await page.locator('p').innerText(), '0 / 0');
    await page.getByRole('button', { name: 'Run', exact: true }).click();
    await page.waitForTimeout(200);
    const text = await page.locator('p').innerText();
    if (test.control) { assert.deepEqual(errors, []); assert.deepEqual(reports, []); assert.equal(text, '1 / 1'); }
    else { assert.match([...errors, ...reports].join('\n'), /reading '_x'/); assert.equal(text, '0 / 0'); }
    rows.push({ ...test, text, errors, reports });
    await page.close();
  }
  const record = { sourceCommit: commit, sourceTreeClean: true, browser: browser.version(), reproducer: 'store-staged-screen.tsx', control: 'Only untrack(() => state.count) becomes state.count.', rows };
  await writeFile(path.join(root, 'store-staged-screen-browser.json'), JSON.stringify(record, null, 2) + '\n');
  console.log(JSON.stringify(record));
} finally {
  await browser?.close();
  if (server) await new Promise(resolve => server.close(resolve));
  await rm(output, { recursive: true, force: true });
}
