// Paired feature bundles for the restricted stable-context adapter and pinned next.
import { build } from 'esbuild';
import { mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { brotliCompressSync, constants } from 'node:zlib';
const out = resolve(process.argv[2] || 'experiments/unified-updates/results/stable-context-stage60/features');
mkdirSync(out, { recursive: true });
const records = [];
for (const [name, entry] of [
  ['baseline', '/workspace/layered-baseline/packages/signals/dist/prod/index.js'],
  ['candidate', resolve('experiments/unified-updates/reference/stable-runtime.mjs')]
]) for (const scenario of ['ordinary', 'optimistic', 'pending']) {
  const exports = ['createSignal', 'createMemo', 'createRoot', 'createRenderEffect', 'action', 'flush'];
  if (scenario !== 'ordinary') exports.push('createOptimistic as optimistic');
  if (scenario === 'pending') exports.push('isPending');
  const result = await build({ stdin: { contents: `export { ${exports.join(',')} } from ${JSON.stringify(entry)};`, resolveDir: process.cwd() },
    bundle: true, minify: true, format: 'esm', platform: 'node', write: false, metafile: true, logLevel: 'error',
    mangleProps: /^_/, reserveProps: /^_(name|parent)$/ });
  const bytes = result.outputFiles[0].contents;
  writeFileSync(resolve(out, `${name}-${scenario}.mjs`), bytes);
  writeFileSync(resolve(out, `${name}-${scenario}.meta.json`), JSON.stringify(result.metafile, null, 2));
  records.push({ name, scenario, entry, minified: bytes.length,
    brotli: brotliCompressSync(bytes, { params: { [constants.BROTLI_PARAM_QUALITY]: 11 } }).length });
}
writeFileSync(resolve(out, 'size.json'), JSON.stringify(records, null, 2));
console.log(JSON.stringify(records, null, 2));
