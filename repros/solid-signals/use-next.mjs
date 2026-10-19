// Build the unchanged public index at an exact upstream commit, then install
// that bundle as @solidjs/signals. No Bend code or private exports are involved.
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { build } from 'esbuild';
const commit = 'd2ad8b288886a5c7171e6746ccc019ad1d08d8ab';
const root = fileURLToPath(new URL('.', import.meta.url));
const source = process.argv[2] ? path.resolve(process.argv[2]) : path.join(root, '.solid-source');
const git = args => execFileSync('git', args, { cwd: source, encoding: 'utf8' }).trim();
if (!process.argv[2]) {
  await mkdir(source, { recursive: true });
  git(['init', '--quiet']);
  git(['fetch', '--depth=1', 'https://github.com/solidjs/solid.git', commit]);
  git(['checkout', '--detach', '--quiet', 'FETCH_HEAD']);
}
assert.equal(git(['rev-parse', 'HEAD']), commit, 'Unexpected Solid commit');
assert.equal(git(['status', '--porcelain', '--', 'packages/signals/src']), '', 'Solid source must be unchanged');
const output = path.join(root, '.solid-next');
await mkdir(output, { recursive: true });
await build({
  entryPoints: [path.join(source, 'packages/signals/src/index.ts')],
  outfile: path.join(output, 'index.mjs'),
  bundle: true, platform: 'node', format: 'esm', treeShaking: true,
  define: { __DEV__: 'false', __OBSERVE__: 'false', __TEST__: 'false' }
});
await writeFile(path.join(output, 'package.json'), JSON.stringify({
  name: '@solidjs/signals', version: '2.0.0-rc.15', type: 'module',
  exports: { '.': './index.mjs', './package.json': './package.json' },
  reproSourceCommit: commit
}, null, 2) + '\n');
execFileSync('npm', ['install', '--no-save', '--package-lock=false', '--ignore-scripts', '--no-audit', '--no-fund', './.solid-next'], {
  cwd: root, stdio: 'inherit'
});
console.log(`Installed unchanged Solid next public index at ${commit}`);
console.log('npm ci restores the published npm package.');
