// Actual action/Promise construction supplies wait-range evidence in Bend.
// Finite helper histories exercise the generalized registration/mark guard.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-action-wait-construction-'));
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/action-wait-fixture.bend'],['action','runtime/action-state.bend'],['flight','runtime/flight.bend'],['core','runtime/core.bend']]){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const F=modules.fixture,A=modules.action,Flight=modules.flight,C=modules.core,b=new BendRuntime(),zero=encodeList([]),sequences=[];
 for(let length=0;length<=5;length++)for(let code=0;code<3**length;code++){let n=code;sequences.push(Array.from({length},()=>{const d=n%3;n=Math.floor(n/3);return d;}));}
 sequences.push(Array.from({length:64},(_,i)=>i%3),Array(32).fill(0),Array(32).fill(1),Array(64).fill(2));
 const event=(op,i)=>op===0?{$:'WaitRegister',action:0,result:2,kind:i%3}:op===1?{$:'ObserverAllocate',node:0,result:2}:{$:'WaitMark',observer:i%5};
 function replay(w,events){for(const e of events){if(e.$==='WaitRegister')w=A.wait(w,e.action,e.result,e.kind).left;else if(e.$==='ObserverAllocate')w=Flight.newObserver(w,e.node,e.result).left;else w={...w,actionWaits:A.settleWait(w.actionWaits,e.observer)};}return w;}
 const outer=w=>({...w,asyncObjects:zero,asyncObservers:zero,actionWaits:zero,hostJobs:zero});
 const observation=w=>({values:list(w.nodes).map(n=>n.value),tree:w.tree,events:w.events});let cases=0,duplicateChecks=0,caughtThrows=0;
 for(const [index,sequence]of sequences.entries()){
  const payload=[undefined,null,false,0,-0,NaN,'cached',{ref:1}][index%8],values=encodeList(Array.from({length:[0,3,11][index%3]},(_,i)=>b.encode(i%2?payload:i))),prefix=sequence.map((op,i)=>event(op,index+i)),suffix=[...sequence].reverse().map((op,i)=>event((op+index)%3,index+i+1)),prefixList=encodeList(prefix),suffixList=encodeList(suffix);
  const initial=F.initial(values),before=F.before(values,prefixList),fresh=F.fresh(values,prefixList);assert.equal(F.action(values),F.created(values).right);assert.ok(F.action(values)<list(initial.actions).length);assert.ok(F.action(values)<list(before.actions).length);assert.equal(list(initial.actions)[F.action(values)].methods.$,'ActionEnd');assert.equal(list(initial.txArena)[list(initial.actions)[F.action(values)].transaction].open,1);assert.deepEqual(before,replay(initial,prefix));assert.deepEqual(outer(before),outer(initial));assert.deepEqual(list(before.actions)[F.action(values)],list(initial.actions)[F.action(values)]);assert.equal(fresh,list(before.asyncObservers).length);assert.equal(A.find(before.actionWaits,fresh).$,'None');
  const registered=F.registered(values,prefixList),pair=A.wait(before,F.action(values),F.result(values),0);assert.deepEqual(registered,pair.left);assert.equal(pair.right,fresh);assert.deepEqual(A.find(registered.actionWaits,fresh),{$:'Some',value:{$:'ActionWait',observer:fresh,action:F.action(values),kind:0,settled:false}});
  const marked={...registered,actionWaits:A.settleWait(registered.actionWaits,fresh)},after=F.final(values,prefixList,suffixList);assert.deepEqual(after,replay(marked,suffix));assert.deepEqual(observation(after),observation(initial));assert.deepEqual(outer(after),outer(initial));
  assert.equal(list(after.asyncObservers).length,1+prefix.filter(e=>e.$!=='WaitMark').length+1+suffix.filter(e=>e.$!=='WaitMark').length);
  for(const entry of list(after.actionWaits))assert.ok(entry.observer<list(after.asyncObservers).length);
  assert.deepEqual(A.find(after.actionWaits,fresh),{$:'Some',value:{$:'ActionWait',observer:fresh,action:F.action(values),kind:0,settled:true}});
  const rest=index%2?encodeList([{$:'AsyncWriteSchedule'}]):zero,stack=encodeList([b.encode(payload),b.encode('caller'),b.encode(index)]),expected={$:'Machine',world:after,tasks:rest,values:stack};
  // Inspect the actual Machine field ABI; full World/tasks/value stack remain.
  const yes=C.asyncFulfillOrdinary(after,rest,stack,fresh,b.encode(payload)),no=C.asyncRejectOrdinary(after,rest,stack,fresh,b.encode('late rejection'));
  for(const actual of [yes,no]){assert.deepEqual(actual.world,after);assert.deepEqual(actual.tasks,rest);assert.deepEqual(actual,expected);duplicateChecks++;}
  const cause=b.encode('then threw'),thrown={...after,fault:{$:'CallbackThrown',cause}},caught=C.actionYieldThrow(thrown,rest,stack,fresh,thrown.fault);assert.deepEqual(caught,expected);caughtThrows++;
  cases++;
 }
 const bundled=await build({stdin:{contents:`export {action} from './index.ts';export {setContextInternal} from './core/core.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}}),native=path.join(dir,'native.mjs');fs.writeFileSync(native,bundled.outputFiles[0].text);const S=await import(pathToFileURL(native));let nativeSequences=0,staleCalls=0;
 for(const rounds of [1,2,4]){
  S.setContextInternal(null);const callbacks=[[],[]],trace=[[],[]],source=callbacks.map(entries=>({then(resolve,reject){entries.push({resolve,reject});}}));
  const run=actor=>S.action(function*(){for(let i=0;i<rounds;i++){try{trace[actor].push(['value',yield source[actor]]);}catch(error){trace[actor].push(['error',error]);}}return actor;})();
  const outcomes=[run(0),run(1)];
  for(let step=0;step<rounds;step++)for(const actor of [0,1]){
   const current=callbacks[actor][step];assert.ok(current);if(actor&&step%2)current.reject(step);else current.resolve(step);
   assert.equal(trace[actor].length,step+1);
   for(const old of callbacks[actor].slice(0,step+1)){old.resolve('duplicate');old.reject('duplicate');staleCalls+=2;}
   assert.equal(trace[actor].length,step+1,'old callbacks cannot consume the new yield');
  }
  assert.deepEqual(await Promise.all(outcomes),[0,1]);assert.deepEqual(callbacks.map(xs=>xs.length),[rounds,rounds]);nativeSequences++;
 }
 for(const rounds of [1,2,4]){
  const callbacks=[],trace=[],source={then(resolve,reject){callbacks.push({resolve,reject});resolve('value');throw new Error('after callback');}};
  const outcome=S.action(function*(){for(let i=0;i<rounds;i++)trace.push(yield source);return 'done';})();
  assert.equal(await outcome,'done');assert.deepEqual(trace,Array(rounds).fill('value'));
  for(const old of callbacks){old.resolve('duplicate');old.reject('duplicate');staleCalls+=2;}
  assert.equal(trace.length,rounds);nativeSequences++;
 }
 console.log(JSON.stringify({typedHistories:cases,enumeratedPrefixEventOrdersThroughLength:5,longestHistory:64,duplicateFulfillRejectChecks:duplicateChecks,postCallbackThrowChecks:caughtThrows,nativeRepeatedYieldSequences:nativeSequences,nativeStaleCallbackInvocations:staleCalls,scope:'actual registration/observer allocation/mark histories and exact current-World duplicate yield guards; not complete generator/debt or rendered publication'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
