import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {hash,files} from './pins.mjs';
import {readDeviations} from './deviations.mjs';
const root=fileURLToPath(new URL('../',import.meta.url));
const lean=process.env.LEAN_ROOT ?? path.join(root,'.tools/lean');
const env={...process.env,PATH:path.join(lean,'bin')+path.delimiter+process.env.PATH};
function command(bin,args) {
  const start=performance.now();
  const r=spawnSync(bin,args,{cwd:root,env,encoding:'utf8',maxBuffer:16*1024*1024});
  if(r.status!==0)throw new Error(`${bin} ${args.join(' ')} failed (${r.status??r.signal}):\n${r.stderr.slice(-5000)}\n${r.stdout.slice(-5000)}`);
  return {seconds:(performance.now()-start)/1000,stdout:r.stdout,stderr:r.stderr};
}
const deviations=readDeviations();
command('python3',['tools/records.py','--check']);
command(process.execPath,['tools/constants.mjs','--check']);
command(process.execPath,['tools/inventory.mjs','--check']);
// Refuse to check a stale emitted runtime and reference bundle.
const currentInputs=Object.fromEntries([...files(path.join(root,'runtime')),...files(path.join(root,'representation')),...files(path.join(root,'observation')),...files(path.join(root,'upstream/bend/bend2'))].map(p=>[path.relative(root,p),hash(fs.readFileSync(p))]));
const built=JSON.parse(fs.readFileSync(path.join(root,'build/build-inputs.json')));
if(JSON.stringify(currentInputs)!==JSON.stringify(built))throw new Error('Build inputs changed; run npm run build before checking.');
const dirs=['runtime','representation','observation','proof','host','tests','tools'];
const checked=[...dirs.flatMap(d=>files(path.join(root,d))),...['LAWS.bend','PROOF.bend','package.json','package-lock.json','upstream/pins.json','upstream/correspondence.json','upstream/inventory.json','tracking/deviations.json','tracking/deviations.md','tracking/source-fidelity.md','tracking/representation.md','README.md','tracking/frontier.md','tracking/async.md','tracking/watchers.md','tracking/question-ids.md','tracking/until.md','tracking/errors.md','tracking/callbacks.md','tracking/ownership.md','tracking/arguments.md','tracking/contexts.md','tracking/cleanup-values.md','tracking/nested.md','tracking/locals.md','tracking/setters.md','tracking/computed-accessors.md','tracking/writable-signals.md','tracking/setter-cleanup.md','tracking/verification.md','tracking/reviews/function-values.md','tracking/reviews/function-values-impact.json','tracking/upstream-issues.json','tracking/upstream/empty-flatten.md','tracking/upstream/staged-error-recovery.md','tracking/upstream/held-function-value.md','tracking/upstream/held-function-value.patch','tracking/upstream/held-function-value-function-only.patch','tracking/upstream/held-function-benchmark.json','tracking/upstream/held-function-size.json','tracking/upstream/held-function-issue-draft.md','tracking/upstream/held-function-allocation-free.md','tracking/upstream/held-function-value-allocation-free.patch','tracking/upstream/held-function-allocation-free-size.json','tracking/upstream/held-function-allocation-free-benchmark.json','tracking/upstream/held-function-wrapper-pr.md','tracking/upstream/held-function-wrapper-size.json','AGENTS.md'].map(p=>path.join(root,p))];
// Seal the standalone repro sources/lock/log, excluding installed dependencies
// and generated source/build directories inside this independent npm project.
for(const name of ['solid-signals','playground']){
  const reproRoot=path.join(root,'repros',name);
  checked.push(...fs.readdirSync(reproRoot,{withFileTypes:true}).filter(e=>e.isFile()).map(e=>path.join(reproRoot,e.name)).sort());
}
const inputs=Object.fromEntries(checked.map(p=>[path.relative(root,p),hash(fs.readFileSync(p))]));
console.log('Checking composed proofs with the independent BendTT kernel...');
const proof=command(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','PROOF.bend','--verdict']);
if(!proof.stdout.includes('ALL PROOFS CHECK'))throw new Error('Kernel returned no success verdict.');
for(const [p,want] of Object.entries(inputs))if(hash(fs.readFileSync(path.join(root,p)))!==want)throw new Error('A proof dependency changed during verification: '+p);
const outputs=Object.fromEntries(['build/runtime.mjs','build/solid.mjs'].map(p=>[p,hash(fs.readFileSync(path.join(root,p)))]));
// Only a completed run replaces the sealed verification record.
const record={schemaVersion:1,activeDeviationIds:deviations.active.map(e=>e.id),claim:'Concrete synchronous chain_once(6), chain_twice(6,9) cleanup_reentry, error_propagates and error_recovers_same_value through the active runtime, plus concrete pending diamond retirement/other-path helper regressions, transaction_parks/transaction_lands with explicit open-count inputs, five concrete ordinary-flight loading/landing/supersession/diamond regressions, two default-until queued-callback regressions, one callback read/return/application-write regression, one captured-root disposal regression, one bound-init-disposer regression, two context-record snapshot/isolation regressions, one bound-cleanup identity/drain regression, one nested-memo replacement/retirement regression, two nested-effect first-application/disposal regressions, one captured-local accumulator/lifetime regression, one escaped-accessor lifetime/tracking regression, one escaped-setter lifetime regression, one reentrant-setter entry-value regression, one computed-accessor freezing regression, one writable-memo manual-previous regression, one negative held-function-result counterexample, one setter-cleanup identity/clear regression, two general callback-binding and four general lexical-binding helper laws, a negative staged-error recovery source counterexample, three general exact question-ID representation laws, generic path composition, and payload laws. See LAWS.bend and tracking/frontier.md.',inputs,outputs,proof:{stdout:proof.stdout.trim(),seconds:proof.seconds,kernelSourceSha256:hash(fs.readFileSync(path.join(root,'upstream/bend/bend2/bendtt.lean')))},host:{node:process.version,bun:command(path.join(root,'node_modules/.bin/bun'),['--version']).stdout.trim(),lean:command(path.join(lean,'bin/lean'),['--version']).stdout.trim(),platform:process.platform,arch:process.arch}};
const temp=path.join(root,'build/verification.pending.json');
fs.writeFileSync(temp,JSON.stringify(record,null,2)+'\n');fs.renameSync(temp,path.join(root,'build/verification.json'));
console.log(proof.stdout.trim());console.log(`Kernel completed in ${proof.seconds.toFixed(1)}s; hashes sealed in build/verification.json.`);
