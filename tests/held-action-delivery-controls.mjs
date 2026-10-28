// Ordinary observer lookup through held setter bodies, then a repeated current
// lookup. These finite controls supplement quantified proofs; the outer
// from/deferred interception and host event loop are separate boundaries.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-held-delivery-'));
try {
 const inputs=path.join(dir,'inputs'),sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 fs.mkdirSync(inputs);
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(inputs,name),{recursive:true});
 const modules={};
 for(const [name,file]of Object.entries({N:'runtime/construct-state.bend',G:'runtime/graph-state.bend',C:'runtime/core.bend',A:'runtime/action-state.bend',X:'runtime/transaction.bend',F:'runtime/flight.bend'})){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(inputs,file),'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const {N,G,C,A,X,F}=modules,b=new BendRuntime();
 const graph=()=>{const signal=N.signal(b.world,b.encode(0),N.defaults()),source=list(b.world.nodes).length,reader=list(signal.nodes).length;return G.link(N.createEffectNode(signal,{$:'Read',id:source},{$:'Render'},0,N.defaults(),0,0,0),source,reader);};
 const payloads=[undefined,false,0,-0,NaN,'saved',{ref:17}].map(v=>b.encode(v));
 let bodies=0,duplicates=0;
 for(const prefixMode of [0,1,2])for(const depth of [0,1,3,8])for(const current of [false,true])for(const rejected of [false,true])for(const writes of [[],[b.encode(1)],[b.encode(1),b.encode(0),b.encode(2),b.encode(2)]])for(const answer of payloads){
  const id=list(b.world.nodes).length,expr=writes.reduceRight((tail,value)=>({$:'Then',first:{$:'WriteExpr',signal:id,value:{$:'Literal',value},updater:true},second:tail}),{$:'Literal',value:{$:'StepResult',done:true,value:answer}}),methods={$:'ActionMethods',next:expr,catches:true,thrown:expr,tail:{$:'ActionEnd'}},created=A.create(graph(),methods),actor=created.right;
  let w=A.open(created.left,actor),group=list(w.actions)[actor].transaction;const capture=group;
  for(let hop=0;hop<depth;hop++){const pair=X.newTransaction(w,false,0);w=X.merge(pair.left,group,pair.right);group=pair.right;}
  w=X.holdNode(w,id,group);if(current)w=X.joinFuture(w,group);
  const future=F.newThenable(w,false,{$:'Unresolved'});w=future.left;
  if(prefixMode){const prior=A.wait(w,actor,future.right,prefixMode===1?1:0);w=prior.left;if(prefixMode===2){w=F.newObserver(w,0,future.right).left;w={...w,actionWaits:A.settleWait(w.actionWaits,prior.right)};}}
  const registered=A.wait(w,actor,future.right,0),observer=registered.right;w=registered.left;
  const stack=encodeList([answer,b.encode('caller')]),rest=encodeList([{$:'AsyncWriteSchedule'}]),incoming=b.encode('input');
  // Execute the actual dispatcher and core; the syntax-derived prefix ends
  // before DeliverObservers/ActionSliceEnd, matching the theorem boundary.
  const finish=()=>{let machine=C.asyncActionDelivery(w,rest,stack,observer,rejected,incoming,A.find(w.actionWaits,observer));for(let step=0;step<2+5*writes.length;step++)machine=C.step(machine);return machine;};
  const finished=finish();
  assert.equal(finished.world.fault.$,'Healthy');assert.equal(finished.world.actionDepth,0);
  assert.equal(list(finished.world.actions)[actor].transaction,capture);
  assert.equal(list(finished.world.txArena)[group].open,0);
  assert.deepEqual(A.find(finished.world.actionWaits,observer),{$:'Some',value:{$:'ActionWait',observer,action:actor,kind:0,settled:true}});
  assert.deepEqual(finished.values,stack);assert.deepEqual(list(finished.tasks).map(t=>t.$),['DeliverObservers','ActionSliceEnd','AsyncWriteSchedule']);
  assert.equal(list(finished.world.nodes)[id].pending.$,writes.length?'Present':'Empty');
  if(writes.length)assert.deepEqual(list(finished.world.nodes)[id].pending.value,writes.at(-1));
  bodies++;
  for(const events of [[],[{$:'WaitMark',observer}],[{$:'WaitRegister',action:actor,result:future.right,kind:0},{$:'ObserverAllocate',node:0,result:future.right},{$:'WaitMark',observer}],[{$:'WaitRegister',action:actor,result:future.right,kind:1},{$:'WaitMark',observer:observer+1}]])for(const lateRejected of [false,true]){
   let later=finish();
   for(const event of events){let next=later.world;if(event.$==='WaitRegister')next=A.wait(next,event.action,event.result,event.kind).left;else if(event.$==='ObserverAllocate')next=F.newObserver(next,event.node,event.result).left;else next={...next,actionWaits:A.settleWait(next.actionWaits,event.observer)};later={...later,world:next};}
   const found=A.find(later.world.actionWaits,observer);
   const repeated=C.asyncActionDelivery(later.world,later.tasks,later.values,observer,lateRejected,b.encode('late'),found);
   assert.deepEqual(repeated,later,'a repeated current lookup must preserve the entire machine');duplicates++;
  }
 }
 assert.equal(bodies,1008);assert.equal(duplicates,8064);
 console.log(JSON.stringify({ordinaryObserverBodies:bodies,helperPrefixModes:3,duplicateCurrentLookups:duplicates,capturedRedirectLengths:[0,1,3,8],scope:'actual ordinary observer lookup and settled marking, fresh/current held bodies, original capture, positive debt retirement, saved tasks/stack and duplicate Machine equality after permitted wait histories; outer interception and public flush are separate'}));
} finally {fs.rmSync(dir,{recursive:true,force:true});}
