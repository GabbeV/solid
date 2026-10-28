// Output task prefixes and the inTransaction slice end use the shared runtime.
// These are component controls, separate from the constructed body proofs and
// from executing the scheduler Round or later host callbacks.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-output-continuation-'));
try {
 const inputs=path.join(dir,'inputs'),source=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;fs.mkdirSync(inputs);
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(source,name),path.join(inputs,name),{recursive:true});
 const modules={};
 for(const [name,file]of Object.entries({C:'core',A:'action-state',F:'flight'})){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(inputs,'runtime',file+'.bend'),'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const {C,A,F}=modules,b=new BendRuntime(),nil=encodeList([]),plain=[undefined,false,0,NaN,'saved',{ref:41}].map(v=>b.encode(v));
 const hideJobs=w=>({...w,hostJobs:nil});let outputs=0,drains=0,pendingAdoptions=0,slices=0;
 for(const length of [0,1,3,12])for(const reverse of [false,true])for(const prior of ['unresolved','fulfilled','rejected'])for(const rejected of [false,true])for(const mode of [...plain.map(value=>({value})),{adopts:true}]){
  const created=A.create(b.world,{$:'ActionEnd'}),actor=created.right;let w=A.open(created.left,actor);const result=list(w.actions)[actor].result,ids=[];
  for(let i=0;i<length;i++){const observer=F.newObserver(w,0,result);w=observer.left;ids.push(observer.right);}
  if(reverse)ids.reverse();for(const id of ids)w=F.addObserver(w,result,id);
  if(prior!=='unresolved'){
   let first=C.actionOutput(w,nil,nil,actor,prior==='rejected',b.encode('old'));
   for(let i=0;i<length+1;i++)first=C.step(first);
   assert.equal(list(first.tasks).length,0);w=first.world;
  }
  let value=mode.value;if(mode.adopts){const future=F.newThenable(w,false,{$:'Unresolved'});w=future.left;value={$:'AsyncValue',identity:future.right};}
  const q=list(w.actions)[actor].question,rest=encodeList([{$:'ActionSliceEnd',question:q},{$:'AsyncWriteSchedule'}]),stack=encodeList([b.encode('caller'),value]),finished=C.actionOutput(w,rest,stack,actor,rejected,value),adopts=prior==='unresolved'&&mode.adopts&&!rejected;
  const tasks=list(finished.tasks);
  if(prior==='unresolved'&&!adopts){assert.equal(tasks[0].$,'DeliverObservers');assert.equal(tasks[0].immediate,false);assert.deepEqual(list(tasks[0].observers),ids);assert.equal(tasks[0].rejected,rejected);assert.deepEqual(tasks[0].value,value);}
  else assert.deepEqual(finished.tasks,rest);
  if(adopts){pendingAdoptions++;assert.equal(list(finished.world.asyncObjects)[result].state.$,'Unresolved');assert.equal(list(finished.world.hostJobs).at(-1).$,'ActionAdopt');assert.deepEqual(list(finished.world.hostJobs).at(-1).value,value);}
  let drained=finished;const count=prior==='unresolved'&&!adopts?length+1:0;
  for(let step=0;step<count;step++)drained=C.step(drained);
  assert.deepEqual(drained.tasks,rest);assert.deepEqual(drained.values,stack);assert.deepEqual(hideJobs(drained.world),hideJobs(finished.world));
  const jobs=list(finished.world.hostJobs),expected=count?ids.map(observer=>({$:'DeliveryJob',observer,rejected,value})):[];assert.deepEqual(list(drained.world.hostJobs),[...jobs,...expected]);outputs++;drains+=count;
 }
 for(const depth of [0,1,4])for(const running of [false,true])for(const halted of [false,true])for(const scheduled of [false,true]){
  const created=A.create(b.world,{$:'ActionEnd'}),q=list(A.open(created.left,created.right).actions)[created.right].question,w={...created.left,actionDepth:depth,running,halted,scheduled},rest=encodeList([{$:'AsyncWriteSchedule'}]),stack=encodeList([b.encode('saved')]),start={$:'Machine',world:w,tasks:encodeList([{$:'ActionSliceEnd',question:q},...list(rest)]),values:stack},next=C.step(start);
  assert.deepEqual(next.world,w);assert.deepEqual(next.values,stack);
  if(depth===0&&!running&&!halted&&scheduled)assert.deepEqual(list(next.tasks).map(t=>t.$),['Round','ActionRestoreQuestion','AsyncWriteSchedule']);
  else {assert.deepEqual(list(next.tasks).map(t=>t.$),['ActionRestoreQuestion','AsyncWriteSchedule']);const done=C.step(next);assert.deepEqual(done.tasks,rest);assert.deepEqual(done.values,stack);assert.deepEqual(done.world,{...w,question:q});}
  slices++;
 }
 assert.equal(outputs,336);assert.equal(pendingAdoptions,8);assert.equal(slices,24);
 console.log(JSON.stringify({outputCases:outputs,actualObserverPrefixSteps:drains,pendingOutputAdoptions:pendingAdoptions,sliceGuardCases:slices,observerLengths:[0,1,3,12],scope:'actual output states/fulfillment/rejection/adoption, callback registration order, host request outbox, exact caller work/values and nested/outer slice guards; Round execution and host callback delivery remain separate'}));
} finally {fs.rmSync(dir,{recursive:true,force:true});}
