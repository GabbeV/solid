// Constructor identity correction and actual first delivery/retirement controls.
// The queued public flush and general generator protocol remain separate.
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
 for(const [name,input]of [['fixture','proof/action-wait-fixture.bend'],['first','proof/action-first-constructed.bend'],['action','runtime/action-state.bend'],['flight','runtime/flight.bend'],['core','runtime/core.bend']]){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const F=modules.fixture,First=modules.first,A=modules.action,Flight=modules.flight,C=modules.core,b=new BendRuntime(),zero=encodeList([]);
 const pending=Promise.withResolvers().promise,payloads=[undefined,null,false,0,-0,NaN,'cached',{ref:1},new Error('raw'),{nested:'cached'},pending];let cases=0,duplicateChecks=0,badAliasControls=0;
 const outer=w=>({...w,asyncObjects:zero,asyncObservers:zero,actionWaits:zero,hostJobs:zero});
 const content=w=>({values:list(w.nodes).map(n=>n.value),tree:w.tree,events:w.events});
 for(const [index,payload]of payloads.entries())for(const size of [0,2,11])for(const rejected of [false,true]){
  const value=index===payloads.length-1?{$:'AsyncValue',identity:2}:payload instanceof Error?b.encode({ref:31}):payload?.nested?b.encode({ref:32}):b.encode(payload),values=encodeList(Array.from({length:size},(_,i)=>i%2?value:b.encode(i))),rest=encodeList([{$:'AsyncWriteSchedule'}]),stack=encodeList([b.encode('caller'),value]),initial=F.initial(values),actor=F.action(values),registered=F.registered(values,zero),observer=F.fresh(values,zero),result=list(initial.actions)[actor].result,group=list(initial.actions)[actor].transaction;
  assert.equal(actor,F.created(values).right);assert.ok(actor<list(initial.actions).length);assert.equal(actor,0);assert.equal(group,1);
  const arrived=First.first(values,rest,stack,rejected,value);assert.deepEqual(arrived,rejected?C.asyncRejectOrdinary(registered,rest,stack,observer,value):C.asyncFulfillOrdinary(registered,rest,stack,observer,value));assert.deepEqual(A.find(arrived.world.actionWaits,observer),{$:'Some',value:{$:'ActionWait',observer,action:actor,kind:0,settled:true}});assert.equal(list(arrived.world.txArena)[group].open,1);assert.equal(list(arrived.world.txArena).length,2);assert.deepEqual(content(arrived.world),content(initial));assert.deepEqual(list(arrived.tasks).map(t=>t.$),['ActionStepReturn','ActionSliceEnd','AsyncWriteSchedule']);
  const retired=C.step(arrived);assert.equal(list(retired.world.txArena)[group].open,0);assert.deepEqual(list(retired.world.asyncObjects)[result].state,rejected?{$:'Rejected',error:value}:{$:'Fulfilled',value:b.encode(undefined)});assert.equal(retired.world.fault.$,'Healthy');assert.deepEqual(content(retired.world),content(initial));assert.deepEqual(list(retired.tasks).map(t=>t.$),['DeliverObservers','ActionSliceEnd','AsyncWriteSchedule']);assert.deepEqual(retired.values,stack);assert.deepEqual(retired.world.question,list(initial.actions)[actor].question);
  for(const rounds of [0,1,8]){let w=retired.world;for(let i=0;i<rounds;i++){w=Flight.newObserver(w,0,2).left;w=Flight.syncFulfilled(w,observer,b.encode(i));w=Flight.syncRejected(w,observer,b.encode('ignored'));w={...w,actionWaits:A.settleWait(w.actionWaits,99)};}
   assert.deepEqual(outer(w),outer(retired.world));const expected={$:'Machine',world:w,tasks:retired.tasks,values:retired.values};for(const actual of [C.asyncFulfillOrdinary(w,retired.tasks,retired.values,observer,value),C.asyncRejectOrdinary(w,retired.tasks,retired.values,observer,value)]){assert.deepEqual(actual,expected);assert.equal(list(actual.world.txArena)[group].open,0);duplicateChecks++;}
  }
  if(!rejected){const bad=A.wait(initial,actor+1,F.result(values),0),badFirst=C.asyncFulfillOrdinary(bad.left,rest,stack,bad.right,value),badRetired=C.step(badFirst);assert.equal(list(badRetired.world.txArena)[group].open,1);assert.equal(list(badRetired.world.asyncObjects)[result].state.$,'Unresolved');badAliasControls++;}
  cases++;
 }
 const bundled=await build({stdin:{contents:`export {action} from './index.ts';export {setContextInternal} from './core/core.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}}),native=path.join(dir,'native.mjs');fs.writeFileSync(native,bundled.outputFiles[0].text);const S=await import(pathToFileURL(native));let nativeCases=0;
 for(const payload of payloads)for(const rejected of [false,true]){S.setContextInternal(null);let saved,resumed=0,ended=0;const source={then(resolve,reject){saved={resolve,reject};}},run=S.action(function*(){try{yield source;resumed++;}finally{ended++;}}),outcome=run().then(value=>({status:'fulfilled',value}),reason=>({status:'rejected',reason}));assert.ok(saved);if(rejected)saved.reject(payload);else saved.resolve(payload);const result=await outcome;assert.equal(result.status,rejected?'rejected':'fulfilled');assert.ok(Object.is(rejected?result.reason:result.value,rejected?payload:undefined));assert.equal(resumed,rejected?0:1);assert.equal(ended,1);saved.resolve(payload);saved.reject(payload);assert.equal(resumed,rejected?0:1);assert.equal(ended,1);nativeCases++;}
 console.log(JSON.stringify({actualFirstAndRetirementCases:cases,duplicateCurrentMachineChecks:duplicateChecks,badUnallocatedAliasControls:badAliasControls,nativeTerminalGeneratorCases:nativeCases,scope:'actual first callback and terminal ActionStepReturn before observer drain/public flush; action identity derived from create, raw rejection including thenable data, legacy alias trap explicit'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
