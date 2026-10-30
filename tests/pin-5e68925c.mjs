// rc.20 changed leaf predicates and actual parked-flight adoption, compared
// against unmodified source bodies. These seeded states are not reachability.
import assert from 'node:assert/strict';
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import {spawnSync} from 'node:child_process';import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-5e68925c-'));
try{
 const active=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const d of ['runtime','representation','observation'])fs.cpSync(path.join(active,d),path.join(dir,d),{recursive:true});
 fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});fs.copyFileSync(path.join(root,'tests/probes/pin-5e68925c.bend'),path.join(dir,'tests/probes/pin-5e68925c.bend'));
 const output=path.join(dir,'probe.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'tests/probes/pin-5e68925c.bend'),'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stderr);const B=(await import(pathToFileURL(output))).default;
 const source=path.join(root,'upstream/solid/packages/signals/src'),bundle=await build({stdin:{contents:`export * from './index.ts';export * as K from './core/constants.ts';export {computed,ext,creatorReads,setContextInternal} from './core/core.ts';export {probeHoldWork} from './core/verdict.ts';export {probeAdoptParked,probeResetLanes,probeSeams,probeRevealing,probeReveal} from './core/lanes.ts';export {handleAsync} from './core/async.ts';export {reruns as probeReruns,probeResetQueue} from './core/scheduler.ts';`,loader:'ts',resolveDir:source},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'observations-only',setup(b){
 b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport function probeResetQueue(){scheduled=false;syncDepth=1;dirtyQueue._heap=[];dirtyQueue._min=dirtyQueue._max=0;dirtyQueue._marked=false;}'}));
 b.onLoad({filter:/[/\\]core[/\\]verdict\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {holdWork as probeHoldWork};'}));
 b.onLoad({filter:/[/\\]core[/\\]lanes\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {adoptParked as probeAdoptParked,laneSeams as probeSeams,revealing as probeRevealing};export function probeReveal(t){revealing.push(t);}export function probeResetLanes(){revealing.length=lanes.length=kept.length=entered.length=pendingGuesses.length=0;judged=0;guessed=false;}'}));
 }}]});const native=path.join(dir,'solid.mjs');fs.writeFileSync(native,bundle.outputFiles[0].text);const S=await import(pathToFileURL(native)),K=S.K;
 function fixture(){const b=new BendRuntime();b.memo('n',{lit:7},{lazy:true});b.memo('s',{lit:11},{lazy:true});b.memo('p',{lit:13},{lazy:true});b.world=B.storeExt(b.world,2,B.ext(b.world,2));return b;}
 const bn=(b,id,patch)=>{b.world=B.storeNode(b.world,id,{...B.node(b.world,id),...patch});};
 const bx=(b,id,patch)=>{b.world=B.storeExt(b.world,id,{...B.ext(b.world,id),...patch});};
 let holds=0,creators=0,adoptions=0,reruns=0;
 for(const own of [false,true])for(const pending of [false,true])for(const lane of [false,true])for(const reask of [false,true]){
  const b=fixture(),n=S.computed(()=>7,{lazy:true}),s=S.computed(()=>11,{lazy:true});
  Object.assign(n,{_config:own?K.CONFIG_ASYNC:0,_statusFlags:pending?K.STATUS_PENDING:0});S.ext(n)._transaction=lane?{_lane:true}:null;s._flags=reask?K.REACTIVE_REASK:0;
  bn(b,2,{config:n._config,status:n._statusFlags});bn(b,3,{flags:s._flags});
  // Transaction identity is represented by the actual arena row, not node ID.
  const t=B.transaction(b.world,lane);b.world=t.left;bx(b,2,{transaction:lane?t.right:0});assert.equal(B.hold(b.world,2,3),!!S.probeHoldWork(n,s));holds++;
 }
 for(const active of [false,true])for(const outerActive of [false,true])for(const bits of [0,K.REACTIVE_JOINED,K.REACTIVE_STAGED_READ,K.REACTIVE_JOINED|K.REACTIVE_STAGED_READ])for(const outer of [0,K.REACTIVE_JOINED,K.REACTIVE_STAGED_READ]){
  const b=fixture(),n=S.computed(()=>7,{lazy:true}),p=S.computed(()=>13,{lazy:true}),g=S.computed(()=>11,{lazy:true});n._parent=p;p._parent=g;g._parent=null;p._flags=bits|(active?K.REACTIVE_RECOMPUTING_DEPS:0);g._flags=outer|(outerActive?K.REACTIVE_RECOMPUTING_DEPS:0);
  bn(b,2,{parent:4});bn(b,4,{parent:3,flags:p._flags});bn(b,3,{parent:0,flags:g._flags});
  const x=B.creator(b.world,2,0);assert.equal(x.left.fault.$,'Healthy');assert.equal(x.right,S.creatorReads(n,0));assert.deepEqual(x.left,b.world);creators++;
 }
 for(const lane of [false,true])for(const kind of ['Memo','Render','User','Tracked'])for(const error of ['none','own','inherited-live','inherited-errored','missing-source'])for(const disposed of [false,true])for(const marked of [false,true]){
  S.probeResetQueue();S.setContextInternal(null);const b=fixture(),n=S.computed(()=>7,{lazy:true}),s=S.computed(()=>11,{lazy:true}),t=B.transaction(b.world,lane);b.world=t.left;
  const flags=(disposed?K.REACTIVE_DISPOSED:0)|(marked?K.REACTIVE_FRAME_READ:0),config=kind==='Memo'?0:K.CONFIG_FRAME,status=error==='none'?0:K.STATUS_ERROR;
  Object.assign(n,{_flags:flags,_config:config,_statusFlags:status,_modified:true});if(kind!=='Memo')n._type={Render:1,User:2,Tracked:3}[kind];
  S.ext(n)._error=error==='none'?null:{source:error==='own'?n:error==='missing-source'?undefined:s};s._statusFlags=error==='inherited-errored'?K.STATUS_ERROR:0;
  bn(b,2,{flags,config,status,kind:{$:kind},modified:true});bn(b,3,{status:s._statusFlags});bx(b,2,{error:error==='none'?b.encode(null):{$:'StatusFailure',identity:1,source:error==='own'?2:error==='missing-source'?0:3,cause:b.encode('cause'),message:0}});
  b.world=B.storeTransaction(b.world,t.right,{...B.transactionRow(b.world,t.right),reruns:encodeList([2])});
  const native={_lane:lane,_reruns:[n]},expected=S.probeReruns(native),m=B.reruns(b.world,t.right);assert.equal(m.world.fault.$,'Healthy');assert.deepEqual(list(m.tasks),[]);assert.equal(list(m.values)[0].n,Number(expected)||0);assert.deepEqual(list(B.transactionRow(m.world,t.right).reruns),native._reruns);
  const actual=B.node(m.world,2);assert.equal(actual.flags,n._flags);assert.equal(actual.modified,n._modified);reruns++;
 }
 for(const count of [0,1,3]){
  S.probeResetLanes();const b=fixture(),t=B.transaction(b.world,false);b.world=t.left;
  const ids=Array(count).fill(t.right),encoded=encodeList(ids);b.world={...b.world,laneState:{...b.world.laneState,revealing:encoded}};
  for(let i=0;i<count;i++)S.probeReveal({});S.probeSeams(null);const m=B.finish(b.world);assert.equal(m.world.fault.$,'Healthy');assert.deepEqual(list(m.world.laneState.revealing),S.probeRevealing);
 }
 for(const throws of [false,true]){
  S.probeResetQueue();S.probeResetLanes();S.setContextInternal(null);const b=fixture(),n=S.computed(()=>7,{lazy:true}),source=b.future('source'),p=Promise.withResolvers();let calls=0;
  p.promise.catch(()=>{});try{S.handleAsync(n,p.promise);}catch(e){assert.equal(e.constructor.name,'NotReadyError');}
  b.world=B.register(b.world,2,source);assert.equal(b.world.fault.$,'CallbackThrown');b.world={...b.world,fault:{$:'Healthy'}};
  const callback=b.program('teardown',[['emit',71],...(throws?[['throw',99]]:[])]);bx(b,2,{parkedFlight:{$:'FlightActive',result:source},flightTeardown:callback});bn(b,2,{flags:0});
  S.ext(n)._parked=p.promise;S.ext(n)._flightTeardown=()=>{calls++;if(throws)throw 99;};n._flags=0;
  let failure;try{assert.equal(S.probeAdoptParked(n),true);}catch(e){failure=e;}
  const m=B.adopt(b.world,2);assert.equal(calls,1);assert.equal(list(m.world.events).filter(e=>'callback'in e&&e.code===71).length,1);assert.equal(B.ext(m.world,2).flightTeardown,0);assert.equal(S.ext(n)._flightTeardown,null);assert.equal(B.ext(m.world,2).parkedFlight.$,'FlightUndefined');assert.equal(S.ext(n)._parked,undefined);
  if(throws){assert.equal(failure,99);assert.equal(m.world.fault.$,'CallbackThrown');assert.equal(b.decode(m.world.fault.cause),99);assert.equal(list(m.world.asyncObjects).length,list(b.world.asyncObjects).length);assert.equal(B.ext(m.world,2).inFlight.result,source);assert.equal(S.ext(n)._inFlight,p.promise);}
  else{assert.equal(failure,undefined);assert.equal(m.world.fault.$,'Healthy');assert.notEqual(B.ext(m.world,2).inFlight.result,source);}
  p.resolve(29);for(let i=0;i<8;i++)await Promise.resolve();
 }
 for(const rejected of [false,true])for(const dirty of [0,K.REACTIVE_DIRTY,K.REACTIVE_CHECK,K.REACTIVE_IN_HEAP])for(const settled of [false,true]){
  S.probeResetLanes();S.setContextInternal(null);const b=fixture(),n=S.computed(()=>7,{lazy:true}),source=b.future('source'),p=Promise.withResolvers();
  // Keep a source listener as the superseded frame registration, as upstream
  // does. The adopted listener must have its own promise identity.
  const caught=p.promise.catch(()=>{});try{S.handleAsync(n,p.promise);}catch(e){assert.equal(e.constructor.name,'NotReadyError');}S.ext(n)._parked=p.promise;n._flags=dirty;
  b.world=B.register(b.world,2,source);assert.equal(b.world.fault.$,'CallbackThrown');b.world={...b.world,fault:{$:'Healthy'}};bx(b,2,{parkedFlight:{$:'FlightActive',result:source}});bn(b,2,{flags:dirty});
  if(settled){if(rejected)p.reject('failure');else p.resolve(29);if(rejected)b.reject('source','failure');else b.resolve('source',29);}
  // Admission is tested through source's actual exported helper and Bend's
  // actual rerun predicate; the adoption entry itself follows admission.
  const before=b.world,accepted=S.probeAdoptParked(n);
  if(dirty){assert.equal(accepted,false);assert.equal(B.admissible(before,2),false);assert.deepEqual(S.ext(n)._parked,p.promise);p.resolve(29);await caught;adoptions++;continue;}
  assert.equal(B.admissible(before,2),true);const m=B.adopt(before,2);assert.equal(accepted,true);assert.equal(m.world.fault.$,'Healthy');assert.deepEqual(list(m.tasks),[]);b.world=m.world;
  const flight=B.ext(b.world,2).inFlight;assert.equal(flight.$,'FlightActive');assert.notEqual(flight.result,source);assert.notEqual(S.ext(n)._inFlight,p.promise);assert.equal(B.ext(b.world,2).parkedFlight.$,'FlightUndefined');assert.equal(S.ext(n)._parked,undefined);assert.equal(b.decode(B.ext(b.world,2).blocked.value),true);assert.equal(S.ext(n)._blocked,true);
  if(!settled){if(rejected)p.reject('failure');else p.resolve(29);if(rejected)b.reject('source','failure');else b.resolve('source',29);}
  // Both ordinary delivery hops are visible before the adopted registration.
  const jobs=list(b.world.hostJobs).filter(j=>j.$==='DeliveryJob');assert.equal(jobs.length,2);await caught;
  for(let i=0;i<8;i++)await Promise.resolve();
  // Engine host transport drains the mirror then its ordinary registration.
  b.hostAsync=true;b.drainJobs();await new Promise(resolve=>setImmediate(resolve));b.drainJobs();await new Promise(resolve=>setImmediate(resolve));assert.equal(B.ext(b.world,2).inFlight.$,'FlightEmpty');assert.equal(S.ext(n)._inFlight,null);
  if(!rejected){assert.equal(b.decode(B.node(b.world,2).value),n._value);assert.equal(n._value,29);}
  else{assert.equal(b.decode(B.ext(b.world,2).error).cause,S.ext(n)._error.cause);}
  adoptions++;
 }
 console.log(JSON.stringify({holdWorkCases:holds,creatorAncestorCases:creators,rerunErrorCases:reruns,parkedAdoptionCases:adoptions,teardownCases:2,emptySeamResetCases:3,scope:'unchanged native predicates and actual Promise adoption; seeded helper states, not public reachability or arbitrary thenables'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
