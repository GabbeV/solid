import { build } from 'esbuild';
import { execFileSync } from 'node:child_process';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { brotliCompressSync } from 'node:zlib';
import { createHash } from 'node:crypto';
const here = dirname(fileURLToPath(import.meta.url));
const out = resolve(process.argv[2] || resolve(here, 'results/forwarded-observation-stage49'));
mkdirSync(out, { recursive: true });
const adapter = readFileSync(resolve(here, 'reference/scalar-runtime.mjs'), 'utf8');
writeFileSync(resolve(out, 'before-adapter.mjs'), adapter.replace("'./unified-scheduler.mjs'", "'./before.mjs'"));
const sizes = [];
for (const name of ['before','after']) {
  const entry = name === 'before' ? resolve(out, 'before-adapter.mjs') : resolve(here, 'reference/scalar-runtime.mjs');
  const result = await build({ entryPoints:[entry], bundle:true, format:'esm', platform:'node', minify:true, write:false });
  const bytes = result.outputFiles[0].contents;
  writeFileSync(resolve(out, `${name}-bundle.mjs`), bytes);
  sizes.push({ name, minified:bytes.length, brotli:brotliCompressSync(bytes).length, sha256:createHash('sha256').update(bytes).digest('hex') });
}
const scenarios = process.env.FORWARD_CASES?.split(',') || ['signal-read','memo-read','write-flush','equal-write','memo-write','batch-10-writes','chain','diamond','fanout-memos','fanout-effects','branch-switch','signal-create','memo-create-dispose','unrelated-inactive','unrelated-active','nested-active','unobserved-shared'];
const median = xs => xs.toSorted((a,b)=>a-b)[Math.floor(xs.length/2)];
const runs = [], summary = [];
for (const scenario of scenarios) {
  const custom = ['unrelated-inactive','unrelated-active','nested-active','unobserved-shared'].includes(scenario);
  const worker = resolve(here, custom ? 'forwarded-observation-bench.mjs' : 'sync-bench.mjs');
  for (let sample = 0; sample < Number(process.env.FORWARD_SAMPLES || 3); sample++) {
    for (const name of sample % 2 ? ['after','before'] : ['before','after']) {
      const entry = custom ? (name === 'before' ? resolve(out,'before.mjs') : resolve(here,'reference/unified-scheduler.mjs')) : resolve(out,`${name}-bundle.mjs`);
      const result = JSON.parse(execFileSync(process.execPath, ['--expose-gc',worker,entry,scenario], { encoding:'utf8' }));
      runs.push({name,sample,...result});
    }
  }
  const before = median(runs.filter(r=>r.scenario===scenario && r.name==='before').map(r=>r.ns));
  const after = median(runs.filter(r=>r.scenario===scenario && r.name==='after').map(r=>r.ns));
  const result = { scenario, before, after, ratio:after/before }; summary.push(result); console.log(JSON.stringify(result));
  writeFileSync(resolve(out,'cost.json'),JSON.stringify({node:process.version,sizes,runs,summary},null,2));
}
