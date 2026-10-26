// Actual method execution/retirement. Private helper prefixes are not claimed
// as complete public generator histories; native generators cover real IO too.
import assert from 'node:assert/strict';
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import {spawnSync} from 'node:child_process';import {pathToFileURL,fileURLToPath} from 'node:url';
import {build} from 'esbuild';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-action-body-'));
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/action-method-wait-fixture.bend'],['first','proof/action-method-first-history.bend'],['body','proof/action-body-constructed.bend'],['guard','proof/action-body-guard.bend'],['core','runtime/core.bend']]){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const F=modules.fixture,H=modules.first,Body=modules.body,G=modules.guard,C=modules.core,b=new BendRuntime(),nil=encodeList([]),orders=[[]];
 for(let length=1;length<=2;length++)for(let code=0;code<7**length;code++){let n=code;orders.push(Array.from({length},()=>{const op=n%7;n=Math.floor(n/7);return op;}));}
 orders.push(Array.from({length:64},(_,i)=>i%7),...Array.from({length:7},(_,op)=>Array(32).fill(op)));
 const event=(op,i)=>op===0?{$:'WaitRegister',action:0,result:2,kind:i%3}:op===1?{$:'ObserverAllocate',node:0,result:2}:op===2?{$:'WaitMark',observer:i%5}:{$:'ObserverCapture',operation:op===3?{$:'CaptureFulfilled',observer:i%7,value:b.encode(i)}:op===4?{$:'CaptureRejected',observer:i%7,error:b.encode('capture '+i)}:op===5?{$:'CaptureStream',stream:0}:{$:'CaptureIgnored',result:2}};
 const payloads=[undefined,null,false,true,0,-0,NaN,1,'','body result',{ref:1}].map(v=>b.encode(v));payloads.push({$:'AsyncValue',identity:2},{$:'ProgramReference',callback:0},{$:'AccessorReference',signal:1},{$:'StepResult',done:false,value:b.encode('nested result')});
 const outer=w=>({...w,hostJobs:nil,asyncObjects:nil}),content=w=>({values:list(w.nodes).map(n=>n.value),tree:w.tree,events:w.events});let cases=0,duplicates=0,adoptions=0;
 for(const [i,sequence]of orders.entries())for(const value of payloads)for(const rejected of [false,true]){
  const expr={$:'Literal',value:{$:'StepResult',done:true,value}},tail={$:'ActionMethods',next:{$:'Raise',cause:b.encode('must not run tail')},catches:false,thrown:{$:'Literal',value:b.encode(undefined)},tail:{$:'ActionEnd'}},method={$:'Body',next:expr,catches:true,thrown:expr,tail},values=encodeList(Array.from({length:[0,3,11][i%3]},(_,n)=>b.encode(n))),prefix=encodeList(sequence.map((op,n)=>event(op,i+n))),suffix=encodeList([...sequence].reverse().map((op,n)=>event((op+i)%7,i+n+1))),rest=encodeList([{$:'AsyncWriteSchedule'}]),stack=encodeList([b.encode('caller'),value]),incoming=b.encode('yielded'),initial=F.initial(values,method),actor=F.action(values,method),observer=F.fresh(values,method,prefix),capture=list(initial.actions)[actor],arrived=H.first(values,method,prefix,rest,stack,rejected,incoming);
  assert.equal(list(arrived.world.txArena)[capture.transaction].open,1);assert.equal(arrived.world.actionDepth,1);
  const evaluated=C.step(arrived);assert.deepEqual(list(evaluated.tasks).map(t=>t.$),['ActionStepReturn','ActionSliceEnd','AsyncWriteSchedule']);assert.deepEqual(list(evaluated.values),[{$:'StepResult',done:true,value},...list(stack)]);
  const done=C.step(evaluated);assert.deepEqual(done,Body.returned(values,value,tail,prefix,rest,stack,incoming,rejected));assert.equal(done.world.fault.$,'Healthy');assert.equal(done.world.actionDepth,0);assert.equal(list(done.world.txArena)[capture.transaction].open,0);assert.deepEqual(done.values,stack);assert.deepEqual(list(done.world.actions)[actor].methods,tail);assert.deepEqual(content(done.world),content(initial));assert.deepEqual(done.world.question,capture.question);assert.deepEqual(outer(done.world),outer(C.actionDone({...arrived.world,actionDepth:0},encodeList([{$:'ActionSliceEnd',previous:initial.question},...list(rest)]),stack,actor,false,value).world));
  const output=list(done.world.asyncObjects)[capture.result].state;
  if(value.$==='AsyncValue'){assert.equal(output.$,'Unresolved');assert.equal(list(done.world.hostJobs).at(-1).$,'ActionAdopt');adoptions++;}else{assert.deepEqual(output,{$:'Fulfilled',value});assert.equal(list(done.world.hostJobs).at(-1).$,'ActionOutcome');}
  const after=G.after(values,value,tail,prefix,rest,stack,incoming,rejected,suffix);assert.equal(list(after.world.txArena)[capture.transaction].open,0);assert.deepEqual(after.tasks,done.tasks);assert.deepEqual(after.values,done.values);assert.deepEqual(content(after.world),content(initial));
  for(const lateRejected of [false,true]){assert.deepEqual(C.asyncActionDelivery(after.world,after.tasks,after.values,observer,lateRejected,b.encode('stale'),{$:'Some',value:list(after.world.actionWaits).find(e=>e.observer===observer)}),after);duplicates++;}cases++;
 }
 const bundled=await build({stdin:{contents:"export {action} from './index.ts';export {setContextInternal} from './core/core.ts';export {flushTransaction,actionDepth} from './core/scheduler.ts';",resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}}),file=path.join(dir,'native.mjs');fs.writeFileSync(file,bundled.outputFiles[0].text);const S=await import(pathToFileURL(file));let nativeCases=0;
 for(const rejected of [false,true])for(const adopts of [false,true])for(const payload of [undefined,false,0,'saved']){
  S.setContextInternal(null);let callbacks,resumed=0;const source={then(resolve,reject){callbacks={resolve,reject};}},later=Promise.withResolvers(),answer=adopts?later.promise:payload,native=S.action(function*(){try{yield source;}catch{}resumed++;return answer;})();native.catch(()=>{});const group=S.flushTransaction;
  const port=new BendRuntime({async:true});port.future('request',{immediate:true});if(adopts)port.future('answer');const result=value=>({iteratorResult:{done:true,value}}),plan={steps:[{next:{iteratorResult:{value:{future:'request'}}}},{next:result(adopts?{future:'answer'}:{lit:payload}),throw:result(adopts?{future:'answer'}:{lit:payload})}]},promise=port.runAction('save',plan),actor=list(port.world.actions)[0],outcome=p=>p.then(value=>({value}),error=>({error}));
  assert.equal(group._open,1);assert.equal(list(port.world.txArena)[actor.transaction].open,1);let nativeSettled=false,portSettled=false;native.then(()=>nativeSettled=true);promise.then(()=>portSettled=true);
  callbacks[rejected?'reject':'resolve']('input');if(rejected)port.reject('request','input');else port.resolve('request','input');assert.equal(resumed,1);assert.equal(group._open,0);assert.equal(list(port.world.txArena)[actor.transaction].open,0);assert.equal(S.actionDepth,0);assert.equal(port.world.actionDepth,0);
  callbacks.resolve('stale');callbacks.reject('stale');assert.equal(resumed,1);assert.equal(group._open,0);
  if(adopts){await new Promise(resolve=>setImmediate(resolve));assert.equal(nativeSettled,false);assert.equal(portSettled,false);later.resolve(payload);port.resolve('answer',payload);}
  assert.deepEqual(await outcome(promise),await outcome(native));assert.equal(nativeSettled,true);assert.equal(portSettled,true);nativeCases++;
 }
 console.log(JSON.stringify({helperPrefixOrders:orders.length,actualBodyReturns:cases,exactStaleMachineChecks:duplicates,pendingOutputAdoptions:adoptions,nativeGeneratorAndPortCases:nativeCases,scope:'literal terminal generator results after private helper prefixes; actual public source settlement and returned-Promise controls; queued publication is separate'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
