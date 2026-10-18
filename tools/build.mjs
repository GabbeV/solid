import { build } from 'esbuild';
import { spawnSync } from 'node:child_process';
import { mkdir, rm, writeFile, readFile } from 'node:fs/promises';
import { hash, files } from './pins.mjs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
const root = fileURLToPath(new URL('../', import.meta.url));
export const bendRoot = path.join(root, 'upstream/bend');
export const solidRoot = path.join(root, 'upstream/solid');
await mkdir(path.join(root, 'build'), {recursive:true});
await rm(path.join(root, 'build/runtime.mjs'), {force:true});
const command = spawnSync(path.join(root,'node_modules/.bin/bun'), [path.join(bendRoot,'bend2/main.ts'), path.join(root,'runtime/api.bend'), '-o', path.join(root,'build/runtime.mjs')], {cwd:root, encoding:'utf8'});
if (command.status !== 0) { process.stderr.write(command.stderr.slice(-6000)); process.exit(command.status ?? 1); }
// Production entry is the actual package index: store hook initialization is
// retained if reachable; no hand-written reference runtime replaces Solid.
await build({entryPoints:[path.join(solidRoot,'packages/signals/src/index.ts')], outfile:path.join(root,'build/solid.mjs'), bundle:true, platform:'node', format:'esm', define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}, treeShaking:true});
const inputs=Object.fromEntries(await Promise.all([...files(path.join(root,'runtime')),...files(path.join(root,'representation')),...files(path.join(root,'observation')),...files(path.join(root,'upstream/bend/bend2'))].map(async p=>[path.relative(root,p),hash(await readFile(p))])));
await writeFile(path.join(root,'build/build-inputs.json'),JSON.stringify(inputs,null,2)+'\n');
process.stdout.write('Built Bend runtime and pinned Solid production reference.\n');
