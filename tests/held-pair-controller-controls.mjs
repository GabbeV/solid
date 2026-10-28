// Finite controls for the two-controller internal resume prefix. These stop
// before queued output/slice/Round work and do not claim a host event history.
import assert from 'node:assert/strict';
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-held-pair-'));
try {
 const inputs=path.join(dir,'inputs'),sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 fs.mkdirSync(inputs);for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(inputs,name),{recursive:true});
 fs.cpSync(path.join(root,'proof'),path.join(inputs,'proof'),{recursive:true});
 const modules={};
 for(const [name,file]of Object.entries({G:'proof/ordinary-graph-data.bend',E:'proof/ordinary-body-evaluation.bend',C:'runtime/core.bend',A:'runtime/action-state.bend',X:'runtime/transaction.bend'})){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(inputs,file),'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const {G,E,C,A,X}=modules,b=new BendRuntime(),sequences=[[],[0],[1],[1,0,false,'']],answers=[undefined,false,0,'',{ref:17}].map(x=>b.encode(x));
 const content=w=>({values:list(w.nodes).map(n=>n.value),tree:w.tree,events:w.events});
 let pairs=0,bodies=0,sourceCacheRetained=0,sourceCacheResolved=0;
 for(const reverse of [false,true])for(const firstActor of [0,1])for(const rejected of [false,true])for(const leftValues of sequences)for(const rightValues of sequences)for(const answer of answers){
  const source=G.source(b.encode(0)),initial=G.linked(b.encode(0)),values=[leftValues,rightValues],encoded=values.map(v=>encodeList(v.map(x=>b.encode(x)))),results=[answer,b.encode('other result')],methods=encoded.map((v,i)=>{const expression=E.expression(v,source,results[i]);return {$:'ActionMethods',next:expression,catches:true,thrown:expression,tail:{$:'ActionEnd'}};});
  const first=A.create(initial,methods[0]);assert.equal(first.right,0);
  let w=X.holdNode(A.open(first.left,first.right),source,1);
  const second=A.create(w,methods[1]);assert.equal(second.right,1);w=A.open(second.left,second.right);
  assert.deepEqual(list(w.actions).map(a=>a.transaction),[1,2]);
  w=X.merge(w,reverse?2:1,reverse?1:2);const rootGroup=reverse?1:2,redirected=reverse?2:1;
  assert.equal(list(w.txArena)[rootGroup].open,2);assert.equal(list(w.txArena)[redirected].open,1);
  assert.equal(list(w.extensions)[list(w.nodes)[source].x].transaction,1);
  let latest=0,pending={$:'Empty'},everWritten=false;
  for(const [index,actor]of [firstActor,1-firstActor].entries()){
   const rest=encodeList([{$:'AsyncWriteSchedule'}]),stack=encodeList([results[actor],b.encode('caller')]),before=w;
   let machine=C.actionResume(w,rest,stack,actor,b.encode('input'),rejected);
   for(let step=0;step<2+5*values[actor].length;step++)machine=C.step(machine);
   w=machine.world;
   assert.equal(w.fault.$,'Healthy');assert.equal(w.actionDepth,0);
   assert.deepEqual(machine.values,stack);assert.deepEqual(list(machine.tasks).map(t=>t.$),['DeliverObservers','ActionSliceEnd','AsyncWriteSchedule']);
   assert.deepEqual(content(w),content(initial));
   assert.deepEqual(list(w.actions).map(a=>a.transaction),[1,2]);
   assert.equal(list(w.txArena)[rootGroup].open,1-index);
   assert.equal(list(w.txArena)[redirected].open,1,'redirected record is not the live obligation count');
   assert.deepEqual(list(w.asyncObjects)[list(before.actions)[actor].result].state,{$:'Fulfilled',value:results[actor]});
   assert.equal(list(w.actions)[actor].methods.$,'ActionEnd');
   for(const value of values[actor]){if(latest!==value)pending={$:'Present',value:b.encode(value)};latest=value;}
   assert.deepEqual(list(w.nodes)[source].pending,pending);
   everWritten ||= values[actor].length>0;
   const cache=list(w.extensions)[list(w.nodes)[source].x].transaction;
   assert.equal(cache,everWritten?rootGroup:1);
   if(everWritten)sourceCacheResolved++;else sourceCacheRetained++;
   bodies++;
  }
  assert.deepEqual(list(w.actions).map(a=>a.methods.$),['ActionEnd','ActionEnd']);pairs++;
 }
 assert.equal(pairs,640);assert.equal(bodies,1280);
 console.log(JSON.stringify({constructedPairs:pairs,actualResumeBodies:bodies,joinDirections:2,completionOrders:2,fulfilledAndCaughtRejected:true,sourceCacheRetained,sourceCacheResolved,scope:'finite consecutive internal resume prefixes on actual create/open/hold/create/open/join state, with body evaluation, both captured identities, exact positive and zero live debt, saved caller stack and retained committed content; output/slice/Round tails and public host admission remain separate'}));
} finally {fs.rmSync(dir,{recursive:true,force:true});}
