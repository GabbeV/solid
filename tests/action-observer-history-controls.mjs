// Actual action/Promise construction supplies wait-range evidence in Bend.
// Finite helper histories exercise the generalized registration/mark guard.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-action-wait-construction-'));
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/action-wait-fixture.bend'],['action','runtime/action-state.bend'],['flight','runtime/flight.bend'],['core','runtime/core.bend'],['iterator','runtime/iterator-state.bend'],['construct','runtime/construct-state.bend']]){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const F=modules.fixture,A=modules.action,Flight=modules.flight,C=modules.core,b=new BendRuntime(),zero=encodeList([]),sequences=[];
 for(let length=0;length<=3;length++)for(let code=0;code<7**length;code++){let n=code;sequences.push(Array.from({length},()=>{const d=n%7;n=Math.floor(n/7);return d;}));}
 sequences.push(Array.from({length:64},(_,i)=>i%7),...Array.from({length:7},(_,op)=>Array(32).fill(op)));
 const Iterator=modules.iterator;
 const event=(op,i)=>op===0?{$:'WaitRegister',action:0,result:2,kind:i%3}:op===1?{$:'ObserverAllocate',node:0,result:2}:op===2?{$:'WaitMark',observer:i%5}:{$:'ObserverCapture',operation:op===3?{$:'CaptureFulfilled',observer:i%7,value:b.encode(i)}:op===4?{$:'CaptureRejected',observer:i%7,error:b.encode('capture '+i)}:op===5?{$:'CaptureStream',stream:0}:{$:'CaptureIgnored',result:2}};
 const grows=e=>e.$==='WaitRegister'||e.$==='ObserverAllocate'||(e.$==='ObserverCapture'&&['CaptureStream','CaptureIgnored'].includes(e.operation.$));
 function replay(w,events){for(const e of events){
  if(e.$==='WaitRegister')w=A.wait(w,e.action,e.result,e.kind).left;
  else if(e.$==='ObserverAllocate')w=Flight.newObserver(w,e.node,e.result).left;
  else if(e.$==='WaitMark')w={...w,actionWaits:A.settleWait(w.actionWaits,e.observer)};
  else {const op=e.operation;if(op.$==='CaptureFulfilled')w=Flight.syncFulfilled(w,op.observer,op.value);else if(op.$==='CaptureRejected')w=Flight.syncRejected(w,op.observer,op.error);else if(op.$==='CaptureStream')w=Iterator.newStepObserver(w,op.stream).left;else w=Iterator.ignoreThen(w,op.result);}
 }return w;}
 const outer=w=>({...w,asyncObjects:zero,asyncObservers:zero,actionWaits:zero,hostJobs:zero});
 const observation=w=>({values:list(w.nodes).map(n=>n.value),tree:w.tree,events:w.events});let cases=0,duplicateChecks=0,caughtThrows=0;
 for(const [index,sequence]of sequences.entries()){
  const payload=[undefined,null,false,0,-0,NaN,'cached',{ref:1}][index%8],values=encodeList(Array.from({length:[0,3,11][index%3]},(_,i)=>b.encode(i%2?payload:i))),prefix=sequence.map((op,i)=>event(op,index+i)),suffix=[...sequence].reverse().map((op,i)=>event((op+index)%7,index+i+1)),prefixList=encodeList(prefix),suffixList=encodeList(suffix);
  const initial=F.initial(values),before=F.before(values,prefixList),fresh=F.fresh(values,prefixList);assert.equal(F.action(values),F.created(values).right);assert.ok(F.action(values)<list(initial.actions).length);assert.ok(F.action(values)<list(before.actions).length);assert.equal(list(initial.actions)[F.action(values)].methods.$,'ActionEnd');assert.equal(list(initial.txArena)[list(initial.actions)[F.action(values)].transaction].open,1);assert.deepEqual(before,replay(initial,prefix));assert.deepEqual(outer(before),outer(initial));assert.deepEqual(list(before.actions)[F.action(values)],list(initial.actions)[F.action(values)]);assert.equal(fresh,list(before.asyncObservers).length);assert.equal(A.find(before.actionWaits,fresh).$,'None');
  const registered=F.registered(values,prefixList),pair=A.wait(before,F.action(values),F.result(values),0);assert.deepEqual(registered,pair.left);assert.equal(pair.right,fresh);assert.deepEqual(A.find(registered.actionWaits,fresh),{$:'Some',value:{$:'ActionWait',observer:fresh,action:F.action(values),kind:0,settled:false}});
  const marked={...registered,actionWaits:A.settleWait(registered.actionWaits,fresh)},after=F.final(values,prefixList,suffixList);assert.deepEqual(after,replay(marked,suffix));assert.deepEqual(observation(after),observation(initial));assert.deepEqual(outer(after),outer(initial));
  assert.equal(list(after.asyncObservers).length,1+prefix.filter(grows).length+1+suffix.filter(grows).length);
  for(const entry of list(after.actionWaits))assert.ok(entry.observer<list(after.asyncObservers).length);
  assert.deepEqual(A.find(after.actionWaits,fresh),{$:'Some',value:{$:'ActionWait',observer:fresh,action:F.action(values),kind:0,settled:true}});
  const rest=index%2?encodeList([{$:'AsyncWriteSchedule'}]):zero,stack=encodeList([b.encode(payload),b.encode('caller'),b.encode(index)]),expected={$:'Machine',world:after,tasks:rest,values:stack};
  // Inspect the actual Machine field ABI; full World/tasks/value stack remain.
  const yes=C.asyncFulfillOrdinary(after,rest,stack,fresh,b.encode(payload)),no=C.asyncRejectOrdinary(after,rest,stack,fresh,b.encode('late rejection'));
  for(const actual of [yes,no]){assert.deepEqual(actual.world,after);assert.deepEqual(actual.tasks,rest);assert.deepEqual(actual,expected);duplicateChecks++;}
  const cause=b.encode('then threw'),thrown={...after,fault:{$:'CallbackThrown',cause}},caught=C.actionYieldThrow(thrown,rest,stack,fresh,thrown.fault);assert.deepEqual(caught,expected);caughtThrows++;
  cases++;
 }
 let actualClientCases=0;
 for(const immediate of [false,true])for(const stateTag of ['Unresolved','Fulfilled','Rejected'])for(const payload of [undefined,'cached']){
  let w=F.initial(encodeList([b.encode(payload)]));const node=list(w.nodes).length;w=modules.construct.computed(w,{$:'Literal',value:b.encode(payload)},modules.construct.defaults(),0);
  const wait=A.wait(w,0,2,0);w={...wait.left,actionWaits:A.settleWait(wait.left.actionWaits,wait.right)};
  const source=list(w.asyncObjects).length;w=Iterator.newIterable(w,zero,false,{$:'Empty'},0);const stream=Iterator.newStream(w,node,2,source,false,b.encode(payload));w=stream.left;assert.ok(stream.right>0);assert.equal(w.fault.$,'Healthy');
  const state=stateTag==='Unresolved'?{$:stateTag}:stateTag==='Fulfilled'?{$:stateTag,value:b.encode(payload)}:{$:stateTag,error:b.encode('ignored')},returned=Flight.newThenable(w,immediate,state);w=returned.left;
  const before=w,observer=list(w.asyncObservers).length,step=Iterator.newStepObserver(w,stream.right);w=step.left;assert.equal(step.right,observer);assert.deepEqual(list(w.asyncObservers)[observer],{$:'AsyncObserver',node,result:2,isSync:true,resolved:false,rejected:false,syncValue:b.encode(undefined),syncError:b.encode(undefined),stream:stream.right,mirrorTarget:0});
  const ignored=list(w.asyncObservers).length,jobs=list(w.hostJobs).length;w=Iterator.ignoreThen(w,returned.right);assert.equal(list(w.asyncObservers).length,ignored+1);assert.equal(list(w.hostJobs).length,jobs+(stateTag==='Rejected'&&!immediate?1:0));assert.equal(list(list(w.asyncObjects)[returned.right].observers).at(-1),ignored);assert.deepEqual(w.actionWaits,before.actionWaits);assert.deepEqual(observation(w),observation(before));
  const rest=encodeList([{$:'AsyncWriteSchedule'}]),stack=encodeList([b.encode(payload)]),expected={$:'Machine',world:w,tasks:rest,values:stack};assert.deepEqual(C.asyncFulfillOrdinary(w,rest,stack,wait.right,b.encode(payload)),expected);assert.deepEqual(C.asyncRejectOrdinary(w,rest,stack,wait.right,b.encode('late')),expected);actualClientCases++;
 }
 console.log(JSON.stringify({typedHistories:cases,actualClientCases,enumeratedPrefixEventOrdersThroughLength:3,helperKinds:7,longestHistory:64,duplicateFulfillRejectChecks:duplicateChecks,postCallbackThrowChecks:caughtThrows,scope:'actual old helper transitions plus synchronous captures, stream-step allocation and ignored-return subscription; reserved stream-zero fallback controls do not assert public stream reachability or full protocol correctness'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
