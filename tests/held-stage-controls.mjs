// Finite held-entry/snapshot controls support the quantified helper contracts.
// Independently authored public generators additionally exercise real held writes.
import assert from 'node:assert/strict';
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {setImmediate} from 'node:timers/promises';
import {build} from 'esbuild';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-held-stage-'));
try{
 const input=path.join(dir,'inputs'),active=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;fs.mkdirSync(input);
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(active,name),path.join(input,name),{recursive:true});
 fs.cpSync(path.join(root,'proof'),path.join(input,'proof'),{recursive:true});
 const modules={};
 for(const [name,file]of [['graph','proof/ordinary-write-constructed.bend'],['tx','runtime/transaction.bend'],['write','runtime/write.bend'],['read','runtime/read-state.bend'],['stash','proof/held-stash-frame.bend'],['frame','proof/held-write-outer.bend'],['base','representation/base.bend']]){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(input,file),'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const G=modules.graph,X=modules.tx,W=modules.write,V=modules.read,S=modules.stash,F=modules.frame,B=modules.base,b=new BendRuntime();
 const values=[undefined,null,false,true,0,-0,NaN,3,'','held',{ref:9}].map(v=>b.encode(v));values.push({$:'ProgramReference',callback:17},{$:'AccessorReference',signal:1});
 let helperCases=0,savedSnapshots=0,cachedSnapshots=0;
 for(const original of values)for(const proposed of values)for(const wasStaged of [false,true])for(const running of [false,true])for(const cached of [false,true]){
  let w=G.linked(original),pair=X.newTransaction(w,false,0);w=pair.left;const group=pair.right;
  w={...w,flushTransaction:group,clock:5,scheduled:false,running};
  w=B.store_transaction(w,group,{...B.transaction(w,group),open:2});
  if(wasStaged)w=W.stageResolved(w,1,original);
  w=X.holdNode(w,1,group);const slot=B.node(w,1).x;
  const record={...B.extension(w,1),inFlight:{$:'FlightActive',result:31},pendingSources:8,error:b.encode('saved error'),q:{$:'QuestionOdd',half:{$:'QuestionZero'}},snapshotValue:{$:'SnapshotValue',value:original},shownError:b.encode(undefined),flushed:{$:'Present',value:b.encode('earlier window')},flushedAt:cached?{$:'Stamped',value:5}:{$:'Unstamped'}};
  w=B.store_extension(w,1,record);
  const snapshot=structuredClone(w),joined=X.joinNode(w,1);
  assert.deepEqual(joined,running?w:B.schedule(w));assert.deepEqual(joined.txArena,w.txArena);assert.deepEqual(joined.actions,w.actions);
  const saved=V.stashFlushed(w,1);
  assert.equal(saved.fault.$,'Healthy');assert.deepEqual(S.observe(saved,slot),S.observe(w,slot));
  assert.deepEqual(S.clean(B.extension(saved,1)),S.clean(record));
  if(cached){assert.deepEqual(saved,w);cachedSnapshots++;}else{assert.deepEqual(B.extension(saved,1).flushed,B.node(w,1).pending);assert.equal(B.stampMatches(B.extension(saved,1).flushedAt,w.clock),true);savedSnapshots++;}
  const staged=W.stageResolved(w,1,proposed);
  assert.equal(staged.fault.$,'Healthy');assert.deepEqual(F.observe(staged,slot),F.observe(w,slot));
  assert.deepEqual(list(staged.nodes).map(n=>n.x),list(w.nodes).map(n=>n.x));
  assert.deepEqual(B.node(staged,1).pending,{$:'Present',value:proposed});
  assert.deepEqual(staged.txArena,w.txArena);assert.deepEqual(staged.actions,w.actions);assert.deepEqual(staged.actionWaits,w.actionWaits);
  assert.deepEqual(w,snapshot);helperCases++;
 }
 const bundle=await build({stdin:{contents:"export * from './index.ts';export {flushTransaction,resolveTx} from './core/scheduler.ts';",resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}}),native=path.join(dir,'native.mjs');fs.writeFileSync(native,bundle.outputFiles[0].text);
 let publicCases=0,heldResumeWrites=0;
 for(const order of [[0,1],[1,0]])for(const length of [0,1,4,16])for(const rejected of [false,true])for(const flight of [false,true]){
  const N=await import(pathToFileURL(native).href+'#case='+publicCases),port=new BendRuntime({async:true}),gates=[Promise.withResolvers(),Promise.withResolvers()],renderGate=Promise.withResolvers(),seen=[];
  let get,set,dispose;N.createRoot(d=>{dispose=d;[get,set]=N.createSignal(0);const memo=N.createMemo(()=>flight&&get()!==0?renderGate.promise:get());N.createRenderEffect(memo,v=>{seen.push(v);});});N.flush();
  port.signal('x',0);port.future('draw');port.memo('memo',flight?{select:[{same:[{read:'x'},{lit:0}]},{lit:0},{future:'draw'}]}:{read:'x'});port.effect('view',{read:'memo'});port.flush();port.future('a');port.future('b');
  const write=value=>({invokeWith:{callee:{lit:{setter:'x'}},value:{lit:value},updater:true}}),result=(value,done)=>({iteratorResult:{value,done}});
  const seqs=[0,1].map(id=>Array.from({length},(_,i)=>100*(id+1)+i));
  const act=N.action(function* (id){set(id+1);try{yield gates[id].promise;}catch{}for(const v of seqs[id])set(()=>v);return id+10;});
  const ps=[act(0),act(1)],qs=[0,1].map(id=>port.runAction(id?'two':'one',{steps:[{next:{seq:[write(id+1),result({future:id?'b':'a'},false)]}},{next:{seq:[...seqs[id].map(write),result({lit:id+10},true)]},throw:{seq:[...seqs[id].map(write),result({lit:id+10},true)]}}]}));
  const group=N.flushTransaction;N.flush();port.flush();assert.equal(group._open,2);assert.deepEqual(seen,[0]);assert.deepEqual(port.read('x'),0);
  for(const [index,id]of order.entries()){
   if(rejected&&index===0){gates[id].reject('caught');port.reject(id?'b':'a','caught');}else{gates[id].resolve('ready');port.resolve(id?'b':'a','ready');}
   await setImmediate();assert.equal(group._open,1-index);assert.equal(await qs[id],await ps[id]);heldResumeWrites+=seqs[id].length;
   assert.deepEqual(port.read('x'),get());assert.deepEqual(port.trace().filter(e=>e[0]==='apply'&&e[1]==='view').map(e=>e[2]),seen);
   if(index===0||flight){assert.deepEqual(seen,[0]);}
  }
  if(flight){renderGate.resolve('rendered');port.resolve('draw','rendered');await setImmediate();assert.deepEqual(seen,[0,'rendered']);assert.deepEqual(port.trace().filter(e=>e[0]==='apply'&&e[1]==='view').map(e=>e[2]),seen);}
  assert.equal(port.world.fault.$,'Healthy');dispose();port.dispose();N.flush();port.flush();publicCases++;
 }
 console.log(JSON.stringify({heldHelperCases:helperCases,savedSnapshots,cachedSnapshots,publicJoinedActionCases:publicCases,heldResumeWrites,scope:'finite held helper frames and independent native/port joined generators; formal public construction, once-only flight ledger and publication are separate'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
