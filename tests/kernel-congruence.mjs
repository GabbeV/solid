// Check the real independently built kernel, including counterexamples whose
// .bendtt text is corrupted only after the frontend has accepted its source.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {prepareKernel,assertKernelUnchanged} from '../tools/kernel-profile.mjs';
import {proofProcess} from '../tools/proof-process.mjs';

const root=fileURLToPath(new URL('../',import.meta.url));
const kernel=prepareKernel({profile:'same-head-congruence-v1'});
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-kernel-congruence-'));
const common=`import Base
def alias(x: Nat) -> Nat:
  x
def choose(condition: Bool,yes: Nat,no: Nat) -> Nat:
  match condition:
    case True{}: yes
    case False{}: no
def branch(depth: Nat,+x: Nat) -> Nat:
  match depth:
    case 0n: x
    case 1n+p:
      +previous = branch(p,x)
      choose(Nat.is_eq(previous,0n),previous,previous)
`;
const env={...process.env,LEAN_STACK_SIZE_KB:'4194304'};
async function verdict(file){
 const start=performance.now();
 const r=await proofProcess(kernel.bin,[file],{cwd:root,env,timeout:90000});
 assert.equal(r.error,undefined,r.error?.message);assert.equal(r.signal,null);
 assert.ok(!/out of (?:fuel|memory)|infrastructure|INTERNAL PANIC/.test(r.stdout+r.stderr),'Resource failures are not semantic verdicts');
 return {...r,seconds:(performance.now()-start)/1000};
}
function emit(name,source){
 const input=path.join(dir,name+'.bend'),output=path.join(dir,name+'.bendtt');fs.writeFileSync(input,source);
 const r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
 assert.equal(r.status,0,r.stdout+'\n'+r.stderr);assert.ok(fs.existsSync(output));return output;
}
try{
 const timings=[];
 const large=emit('shared-call',common+'\ndef same(+x: Nat) -> {branch(18n,x) == branch(18n,alias(x)) : Nat}:\n  {==}\n');
 const checked=await verdict(large);assert.equal(checked.status,0,checked.stdout+checked.stderr);assert.equal(checked.stdout.trim(),'ALL PROOFS CHECK');timings.push({case:'shared-call-depth18',seconds:checked.seconds});
 for(const depth of [0,1,3]){
  const good=emit('argument-'+depth,common+`\ndef same(+x: Nat) -> {branch(${depth}n,x) == branch(${depth}n,alias(x)) : Nat}:\n  {==}\n`);
  const accepted=await verdict(good);assert.equal(accepted.status,0,accepted.stdout+accepted.stderr);
  const text=fs.readFileSync(good,'utf8'),anchor=/^alias :[^\n]* =\n  λx0 => x0$/m;
  assert.ok(anchor.test(text),'Expected exactly the exported identity alias');
  const bad=path.join(dir,'false-argument-'+depth+'.bendtt');fs.writeFileSync(bad,text.replace(anchor,match=>match.replace('λx0 => x0','λx0 => (.Succ, (x0, ()))')));
  const rejected=await verdict(bad);assert.equal(rejected.status,1,'The kernel accepted a false same-head equation');assert.match(rejected.stdout,/SOME PROOFS FAIL\nIn same:/);timings.push({case:'false-argument-depth'+depth,seconds:rejected.seconds});
 }
 const fallback=emit('fallback',`import Base
def left(x: Nat) -> Nat:
  x
def right(x: Nat) -> Nat:
  x
def constant(x: Nat) -> Nat:
  0n
def differentHeads(+x: Nat) -> {left(x) == right(x) : Nat}:
  {==}
def differentArguments(+x: Nat) -> {constant(x) == constant(1n+x) : Nat}:
  {==}
`);
 const result=await verdict(fallback);assert.equal(result.status,0,result.stdout+result.stderr);timings.push({case:'fallback-heads-and-arguments',seconds:result.seconds});
 assertKernelUnchanged(kernel);
 console.log(JSON.stringify({profile:kernel.profile,allLeanTheoremsChecked:kernel.evidence.allLeanTheoremsChecked,positiveCases:6,rawKernelCounterexamples:3,fuel:kernel.evidence.fuel,timings}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
