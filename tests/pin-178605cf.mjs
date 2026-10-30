// Rebase controls run unchanged upstream helper bodies, with observation/reset
// exports appended only in the isolated test bundle. Not a reachability proof.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-178605cf-'));
const list=x=>{const a=[];while('head'in x){a.push(x.head);x=x.tail;}return a;};
const decode=v=>v.$==='Undefined'?undefined:v.$==='Number'?v.n:v.$==='Boolean'?v.b:v.$==='NotPendingToken'?'NOT_PENDING':v;
const question=q=>q.$==='QuestionZero'?0:q.$==='QuestionOdd'?2*question(q.half)+1:2*question(q.half)+2;
const bslot=s=>s.$==='Empty'?['none']:['value',decode(s.value)];
try {
 const from=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const d of ['runtime','representation','observation'])fs.cpSync(path.join(from,d),path.join(dir,d),{recursive:true});
 fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});
 for(const n of ['pin-178605cf','lane-stage'])fs.copyFileSync(path.join(root,'tests/probes/'+n+'.bend'),path.join(dir,'tests/probes/'+n+'.bend'));
 const file=path.join(dir,'probe.mjs');
 const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'tests/probes/pin-178605cf.bend'),'-o',file],{cwd:root,encoding:'utf8'});
 assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(file));
 const result=await build({stdin:{contents:`export * from './index.ts';export * as K from './core/constants.ts';export {signal,computed,ext,setContextInternal,resyncUnflushedCompanions,probeTracking} from './core/core.ts';export {createOwner} from './core/owner.ts';export {notifyStatus} from './core/async.ts';export {NotReadyError} from './core/error.ts';export {probeReader} from './core/verdict.ts';export {link} from './core/graph.ts';export {newTransaction,list,merge,armGuessing,releaseMarksHook,releaseAmbientMarksHook,probeReset,probeFlush,probeUnarm,probePass,stagedReaders,globalQueue,passTx,flushTransaction,transactions} from './core/scheduler.ts';export {probeNewLane,probeResetLanes,probeStage,probeCorrections,probeEnd,probeLive,probeKept,probeReverted,probeReverting,take} from './core/lanes.ts';export {register as probeRegister,ambient as probeAmbient} from './affects.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'test-observation',setup(b){
 b.onLoad({filter:/[/\\]core[/\\]core\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport function probeTracking(v){tracking=v;}'}));
 b.onLoad({filter:/[/\\]core[/\\]verdict\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {markVerdictReader as probeReader};'}));
 b.onLoad({filter:/[/\\]affects\.ts$/},a=>a.path.includes('/store/')?undefined:({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {register,ambient};'}));
 b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+`\nexport {transactions};export function probeReset(){latestOpened=null;guessing=false;clock=notifyEpoch=0;scheduled=false;syncDepth=1;passLane=passTx=flushTransaction=judge=null;pendingNodes.length=heldTrims.length=transactions.length=stagedReaders.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=dirtyQueue._max=0;dirtyQueue._marked=false;}export function probeFlush(t){flushTransaction=t;}export function probeUnarm(){guessing=false;}export function probePass(t){passLane=t;}`}));
 b.onLoad({filter:/[/\\]core[/\\]lanes\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+`\nexport {newLane as probeNewLane,laneStage as probeStage,laneCorrections as probeCorrections,endLanes as probeEnd,lanes as probeLive,kept as probeKept,reverted as probeReverted,reverting as probeReverting};export function probeResetLanes(){revealing.length=0;guessed=true;reverting=false;kept.length=lanes.length=entered.length=pendingGuesses.length=judged=0;}`}));
 } }]});
 const source=path.join(dir,'solid.mjs');fs.writeFileSync(source,result.outputFiles[0].text);const S=await import(pathToFileURL(source)),K=S.K;
 const sval=mode=>mode===0?K.NOT_PENDING:mode===1?undefined:mode===2?0:mode===3?false:7;
 const slot=v=>v===K.NOT_PENDING?['none']:['value',v];
 function actual(mode,value,error,detach,move,confirmed){
  const m=B.borrow(mode,value,error,detach,move,confirmed),w=m.world,xs=list(w.extensions),tx=list(w.txArena),ns=list(w.nodes);
  assert.equal(w.fault.$,'Healthy',JSON.stringify({mode,value,error,detach,move,confirmed}));assert.deepEqual(list(m.tasks),[]);
  assert.deepEqual(list(m.values).map(decode),mode===2?[true,71]:[71]);
  return{live:list(w.laneState.live),kept:list(w.laneState.kept).map(e=>[e.node,bslot(e.value),e.transaction,question(e.question),e.holder]),reverted:tx.slice(1).map((_,i)=>list(w.laneState.reverted).includes(i+1)),reverting:w.laneState.reverting,pending:list(w.pendingNodes),staged:list(w.laneState.stagedReaders),tx:tx.slice(1).map(t=>({nodes:list(t.nodes),reruns:list(t.reruns),into:t.into,open:t.open,shown:t.shown,held:t.held})),nodes:ns.slice(1).map(n=>({value:decode(n.value),pending:bslot(n.pending),config:n.config,flags:n.flags,tx:xs[n.x]?.transaction??0,lane:bslot(xs[n.x]?.lane??{$:'Empty'}),q:question(xs[n.x]?.q??{$:'QuestionZero'})}))};
 }
 function initial(value){
  S.probeReset();S.probeResetLanes();S.armGuessing();S.setContextInternal(null);S.resyncUnflushedCompanions();S.probeAmbient.length=0;
  const ns=[null,S.signal(1),...[2,3,4].map(v=>S.computed(()=>v,{lazy:true}))];ns[3]._type=K.EFFECT_RENDER;
  for(const i of [2,3,4]){ns[i]._value=i;ns[i]._flags=0;S.link(ns[1],ns[i]);}for(const i of [3,4])S.link(ns[2],ns[i]);
  const ts=[null,S.newTransaction(false),S.newTransaction(false)];ts.push(S.probeNewLane(ts[1]),S.probeNewLane(ts[1]),S.probeNewLane(ts[2]));
  S.list(ns[2],ts[3]);Object.assign(ns[2],{_config:K.CONFIG_OVERRIDE|K.CONFIG_GUESS});Object.assign(S.ext(ns[2]),{_lane:sval(value),_q:7});
  S.list(ns[1],ts[5]);ns[1]._config=K.CONFIG_OVERRIDE|K.CONFIG_GUESS;S.ext(ns[1])._lane=9;S.globalQueue._running=true;S.probeTracking(true);
  return {ns,ts};
 }
 function reference(mode,value,error,detach,move,confirmed){
  const {ns,ts}=initial(value);
  if(mode===4)S.merge(ts[1],ts[2]);if(mode===5)S.merge(ts[2],ts[1]);
  if(mode===1)S.take(ns[2],ts[5],detach);else S.probeStage(ns[2],ts[5],false,error===0?false:error===1?true:ns[4]);
  if(move)S.list(ns[2],ts[4]);ts[2]._acted=true;if(confirmed)ns[1]._pendingValue=9;
  if(mode===2||mode===3)assert.equal(S.probeCorrections(),true);if(mode===3)S.probeEnd(ts[2]);
  const nid=n=>n?ns.indexOf(n):0,tid=t=>t?ts.indexOf(t):0,kept=[];for(let i=0;i<S.probeKept.length;i+=5)kept.push([nid(S.probeKept[i]),slot(S.probeKept[i+1]),tid(S.probeKept[i+2]),S.probeKept[i+3],tid(S.probeKept[i+4])]);
  return{live:S.probeLive.map(tid),kept,reverted:ts.slice(1).map(t=>S.probeReverted.has(t)),reverting:S.probeReverting,pending:[],staged:S.stagedReaders.map(nid),tx:ts.slice(1).map(t=>({nodes:t._nodes.map(nid),reruns:t._reruns.map(nid),into:tid(t._into),open:t._open,shown:t._shown,held:t._held})),nodes:ns.slice(1).map(n=>({value:n._value===K.NOT_PENDING?'NOT_PENDING':n._value,pending:slot(n._pendingValue),config:n._config,flags:n._flags??0,tx:tid(n._x?._transaction),lane:slot(n._x==null?K.NOT_PENDING:n._x._lane),q:n._x?._q??0}))};
 }
 let cases=0;for(const mode of [0,1,2,3,4,5])for(const value of [0,1,2,3,4])for(const error of [0,1,2])for(const detach of [false,true])for(const move of [false,true])for(const confirmed of [false,true]){
  const args=[mode,value,error,detach,move,confirmed];assert.deepEqual(actual(...args),reference(...args),JSON.stringify(args));cases++;
 }
 let marks=0;for(const pending of [false,true])for(const copies of [1,2,4])for(const settle of [false,true]){
  S.probeReset();S.probeAmbient.length=0;S.setContextInternal(null);const n=S.computed(()=>1,{lazy:true}),t=S.newTransaction(false);S.probeFlush(t);for(let i=0;i<copies;i++)S.probeRegister(n);n._statusFlags=pending?K.STATUS_PENDING:0;S.releaseMarksHook(t._marks);if(settle){n._statusFlags=0;S.releaseAmbientMarksHook(null);}
  const w=B.markRelease(pending,copies,settle),node=list(w.nodes)[1],x=list(w.extensions)[node.x];assert.equal(w.fault.$,'Healthy');assert.deepEqual({ambient:list(w.ambientMarks),marks:x.marks,active:w.activeMarks,scope:list(list(w.txArena)[1].marks.items)},{ambient:S.probeAmbient.map(()=>1),marks:n._x._marks,active:n._x._marks,scope:t._marks});marks++;
 }
 let pendingCases=0;for(const armed of [false,true])for(const reask of [false,true])for(const pass of [0,3,5]){
  const {ns,ts}=initial(4);S.probeTracking(true);S.probeFlush(null);S.globalQueue._running=true;
  if(!armed) { S.probeUnarm(); }
  S.probePass(pass?ts[pass]:null);ns[2]._flags=reask?K.REACTIVE_REASK:0;
  S.notifyStatus(ns[2],K.STATUS_PENDING,new S.NotReadyError(ns[2]));
  for(const t of S.transactions)if(!ts.includes(t))ts.push(t);
  const tid=t=>t?ts.indexOf(t):0,w=B.pendingGuess(armed,reask,pass),xs=list(w.extensions);
  assert.equal(w.fault.$,'Healthy');
  assert.deepEqual({flush:w.flushTransaction,pass:w.passTx,nodes:list(w.nodes).slice(1).map(n=>({status:n.status,flags:n.flags,tx:xs[n.x]?.transaction??0})),tx:list(w.txArena).slice(1).map(t=>({into:t.into,open:t.open}))},{flush:tid(S.flushTransaction),pass:tid(S.passTx),nodes:ns.slice(1).map(n=>({status:n._statusFlags??0,flags:n._flags??0,tx:tid(n._x?._transaction)})),tx:ts.slice(1).map(t=>({into:tid(t._into),open:t._open}))},JSON.stringify({armed,reask,pass}));pendingCases++;
 }
 let bornCases=0;const flags=[0,K.REACTIVE_RECOMPUTING_DEPS,K.REACTIVE_RECOMPUTING_DEPS|K.REACTIVE_JOINED,K.REACTIVE_RECOMPUTING_DEPS|K.REACTIVE_STAGED_READ,K.REACTIVE_RECOMPUTING_DEPS|K.REACTIVE_STAGED_READ|K.REACTIVE_JOINED,K.REACTIVE_STAGED_READ];
 for(const parent of flags)for(const grand of flags)for(const throughRoot of [false,true])for(const tracking of [false,true]){
  const {ns}=initial(4);ns[2]._config=0;ns[2]._parent=ns[4];ns[4]._flags=parent;ns[4]._parent=ns[3];ns[3]._flags=grand;
  if(throughRoot){S.setContextInternal(ns[4]);ns[2]._parent=S.createOwner();}S.setContextInternal(ns[2]);S.probeTracking(tracking);S.probeReader(1);
  const w=B.born(parent,grand,throughRoot,tracking),n=list(w.nodes)[2];assert.equal(w.fault.$,'Healthy');assert.deepEqual([n.flags,n.config],[ns[2]._flags,ns[2]._config],JSON.stringify({parent,grand,throughRoot,tracking}));bornCases++;
 }
 console.log(`${cases} native borrowed-guess controls match staging, take/detach, ordered snapshots, error forms, correction/confirmation, raw holder identity, moved-owner refusal, restoration and subscriber reruns; ${marks} transaction mark/flight release controls, ${pendingCases} pending-guess join controls and ${bornCases} verdict-ancestor controls pass.`);
} finally {fs.rmSync(dir,{recursive:true,force:true});}
