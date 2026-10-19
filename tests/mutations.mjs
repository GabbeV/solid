import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));
const mutations=[
  ['StatusError prefixes a native Error message','runtime/error.bend','B.choose(~String, native, _ => message, _ => errorString(name, message))','errorString(name, message)','tests/host-errors.mjs'],
  ['explicit/native error identities alias','representation/base.bend','Bool.and(Nat.is_eq(x, y), Bool.xor(Bool.xor(explicitA, explicitB), True{}))','Nat.is_eq(x, y)','tests/host-errors.mjs'],
  ['until timer is never cancelled','runtime/signals.bend','R.Awaiter.timer(a)','False{}','tests/until-options.mjs'],
  ['until ignores a pre-aborted signal','runtime/signals.bend','Bool.and(Nat.is_ne(signal, 0n), R.AbortInput.aborted(input))','False{}','tests/until-options.mjs'],
  ['until resolves a falsy value','runtime/signals.bend','Bool.and(R.Awaiter.until(B.awaiter(w, id)), Bool.and(Bool.not(rejected), Bool.not(B.truth(value))))','False{}','tests/until.mjs'],
  ['unregistered staged-error recovery workaround','runtime/core.bend','+w = B.choose(~R.World, Bool.or(U32.is_ne(R.Node.status(B.node(w, id)), 0), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),','+w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), K.CONFIG_STAGED_ERROR())))\n      +w = B.choose(~R.World, Bool.or(U32.is_ne(R.Node.status(B.node(w, id)), 0), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),','tests/held-recovery.mjs'],
  ['refresh waiter runs eagerly','runtime/signals.bend','_ => R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.WatchStart{id}]))','_ => makeWatch(256n, w, id)','tests/waiters.mjs'],
  ['watch promise resolves in the pass','runtime/watch-state.bend','[R.WatchDelivery{id, failed, value}]','[R.PromiseOutcome{id, failed, value}]','tests/waiters.mjs'],
  ['post-gap synchronous yield is lost','runtime/core.bend','Bool.and(R.AsyncObserver.isSync(o), R.StreamState.initialRead(s))','R.AsyncObserver.isSync(o)','tests/iterators.mjs'],
  ['iterator return omitted','runtime/iterator-state.bend','R.StreamPlan.hasReturn(plan)','False{}','tests/iterators.mjs'],
  ['stale flight writes','runtime/flight.bend','Bool.or(Nat.is_ne(R.NodeExtension.inFlight(B.extension(w, id)), result), B.has','Bool.or(False{}, B.has','tests/async.mjs'],
  ['unresolved promise commits','runtime/flight.bend','Bool.not(R.AsyncObserver.resolved(o))','False{}','tests/async.mjs'],
  ['lost subscriber wake','runtime/write.bend','B.schedule(insertSubs(w, id))','B.schedule(w)'],
  ['leaked staging','runtime/core.bend','          value = B.choose(~R.Value, committed, _ => R.Node.value(n), _ => B.current(n))','          value = B.current(n)'],
  ['untrack subscribes','runtime/core.bend','Machine{R.World.with_tracking(w, False{}), Evaluate{body, prev}','Machine{R.World.with_tracking(w, True{}), Evaluate{body, prev}'],
  ['wrong render result','runtime/core.bend','T.setText(w, R.Node.target(B.node(w, id)), R.Node.value(B.node(w, id)))','T.setText(w, R.Node.target(B.node(w, id)), R.Undefined{})'],
];
let caught=0;
for(const [name,file,before,after,test='tests/differential.mjs'] of mutations) {
  const dir=await fs.mkdtemp(path.join(os.tmpdir(),'bend-signals-mutation-'));
  try {
    for(const d of ['runtime','representation','observation'])await fs.cp(path.join(root,d),path.join(dir,d),{recursive:true});
    const p=path.join(dir,file),text=await fs.readFile(p,'utf8');
    if(!text.includes(before))throw new Error('Stale mutation '+name);
    await fs.writeFile(p,text.replace(before,after));
    const emit=path.join(dir,'runtime.mjs');
    const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),[path.join(root,'upstream/bend/bend2/main.ts'),path.join(dir,'runtime/api.bend'),'-o',emit],{encoding:'utf8'});
    if(compile.status!==0)throw new Error('Mutation did not compile: '+name+'\n'+compile.stderr.slice(-3000));
    const run=spawnSync(process.execPath,[test],{cwd:root,env:{...process.env,BEND_EMIT_FILE:emit},encoding:'utf8',maxBuffer:1024*1024});
    if(run.status===0)throw new Error('Test oracle accepted mutation: '+name);
    if(!run.stderr.includes('AssertionError'))throw new Error('Mutation failed for an unrelated reason: '+name+'\n'+run.stderr.slice(-3000));
    caught++;console.log('Rejected mutation: '+name);
  } finally {await fs.rm(dir,{recursive:true,force:true});}
}
console.log(`${caught} source-changing variants rejected by differential assertions.`);
