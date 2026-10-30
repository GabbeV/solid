// Actual whole-round comparison with a positively blocked group and captured
// callbacks. Seeds are private; initial-state semantic contracts are separate.
// Native caller restoration is an explicit setQuestion after globalQueue.flush.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-mixed-parking-'));
const list=x=>{const a=[];while('head'in x){a.push(x.head);x=x.tail;}return a;};
const decode=v=>v.$==='Undefined'?undefined:v.$==='Boolean'?v.b:v.n;
try{
 const from=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const d of ['runtime','representation','observation'])fs.cpSync(path.join(from,d),path.join(dir,d),{recursive:true});
 fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});fs.copyFileSync(path.join(root,'tests/probes/mixed-parking.bend'),path.join(dir,'tests/probes/mixed-parking.bend'));
 fs.copyFileSync(path.join(root,'tests/probes/queued-round.bend'),path.join(dir,'tests/probes/queued-round.bend'));
 const out=path.join(dir,'parking.mjs'),compiled=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'tests/probes/queued-round.bend'),'-o',out],{cwd:root,encoding:'utf8'});
 assert.equal(compiled.status,0,compiled.stderr);const {default:B}=await import(pathToFileURL(out));
 const native=await build({stdin:{contents:`export * from './index.ts';export * as K from './core/constants.ts';export {signal,computed,createEffectNode,ext,setContextInternal} from './core/core.ts';export {newTransaction,holdNode,globalQueue,probeReset,probeInput,probePending,probeLive,probeRound,setQuestion,probeControl} from './core/scheduler.ts';export {probeResetLanes} from './core/lanes.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'private-observation',setup(b){
 b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+`\nexport {pendingNodes as probePending,transactions as probeLive};export function probeRound(){globalQueue._running=false;dirtyQueue._min=1;dirtyQueue._max=0;}export function probeControl(){return {clock,scheduled,question,passTx,flushTransaction,min:dirtyQueue._min,max:dirtyQueue._max};}export function probeReset(){latestOpened=null;guessing=false;clock=notifyEpoch=0;scheduled=false;syncDepth=1;transactions.length=pendingNodes.length=heldTrims.length=stagedReaders.length=deferredZombies.length=0;passLane=passTx=flushTransaction=judge=null;globalQueue._queues=[[],[]];globalQueue._running=false;dirtyQueue._heap=[];dirtyQueue._min=dirtyQueue._max=0;dirtyQueue._marked=false;}export function probeInput(t,nodes){flushTransaction=t;globalQueue._running=true;pendingNodes.push(...nodes);}`}));
 b.onLoad({filter:/[/\\]core[/\\]lanes\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+`\nexport function probeResetLanes(){revealing.length=0;guessed=reverting=false;lanes.length=kept.length=pendingGuesses.length=entered.length=judged=0;}`}));
 }}]});const sf=path.join(dir,'solid.mjs');fs.writeFileSync(sf,native.outputFiles[0].text);const S=await import(pathToFileURL(sf)),K=S.K;
 const slots=[null,{$:'Present',value:{$:'Undefined'}},{$:'Present',value:{$:'Boolean',b:false}},{$:'Present',value:{$:'Number',n:0}},{$:'Present',value:{$:'Number',n:17}}];
 let cases=0;
 for(const render of [false,true])for(const allocated of [false,true])for(const pending of slots)for(const status of [0,K.STATUS_UNINITIALIZED,K.STATUS_PENDING,K.STATUS_PENDING|K.STATUS_UNINITIALIZED])for(const staged of [false,true])for(const debt of [0,2])for(const queued of [false,true]){
  S.probeReset();S.probeResetLanes();S.setContextInternal(null);S.setQuestion(0);
  const source=S.signal(7),reader=render?S.createEffectNode(()=>9,()=>{},undefined,K.EFFECT_RENDER,{}):S.computed(()=>9,{lazy:true,equals:false}),t=S.newTransaction(false);
  S.holdNode(source,t);t._open=1+debt;if(allocated)S.ext(reader);
  Object.assign(reader,{_value:undefined,_config:(render?K.CONFIG_FRAME:0)|(staged?K.CONFIG_STAGED:0),_flags:0,_statusFlags:status,_pendingValue:pending?decode(pending.value):K.NOT_PENDING});
  const called=[],renderCall=()=>called.push('render'),oldUser=()=>called.push('old user'),newUser=()=>called.push('new user');
  const callbackId=f=>f===renderCall?2:f===oldUser?0:1;
  if(queued){t._queues[0].push(renderCall);t._queues[1].push(oldUser);S.globalQueue._queues=[[renderCall,renderCall],[newUser,oldUser]];}
  const previous=reader._x;S.probeInput(t,[source,reader]);S.probeRound();S.setQuestion(3);S.globalQueue.flush();S.setQuestion(2);assert.deepEqual(called,[]);
  const m=B.fixture(render,allocated,pending??{$:'Empty'},status,staged,debt,queued),w=m.world,xs=list(w.extensions),ns=list(w.nodes),tx=list(w.txArena)[1];
  assert.equal(w.fault.$,'Healthy');assert.ok(!list(w.events).some(e=>['Invoked','Applied','CleanupObserved'].includes(e.$)),'parked callbacks must not run');assert.deepEqual(list(m.tasks),[]);assert.deepEqual(list(m.values).map(decode),[71]);
  const bslot=p=>p.$==='Empty'?['none']:['value',decode(p.value)],nslot=v=>v===K.NOT_PENDING?['none']:['value',v],id=n=>n===source?1:n===reader?2:0;
  assert.deepEqual({pending:list(w.pendingNodes),live:list(w.transactions),count:tx.open,members:list(tx.nodes),nodes:ns.slice(1).map(n=>({value:decode(n.value),pending:bslot(n.pending),flags:n.flags,config:n.config,status:n.status,x:!!n.x,owner:xs[n.x]?.transaction??0})),renders:list(w.renderQueue),users:list(w.userQueue)},
   {pending:S.probePending.map(id),live:S.probeLive.map(()=>1),count:t._open,members:t._nodes.map(id),nodes:[source,reader].map(n=>({value:n._value,pending:nslot(n._pendingValue),flags:n._flags??0,config:n._config,status:n._statusFlags??0,x:n._x!==null,owner:n._x?._transaction===t?1:0})),renders:S.globalQueue._queues[0],users:S.globalQueue._queues[1]},JSON.stringify({render,allocated,pending,status,staged,debt}));
  assert.deepEqual({clock:w.clock,scheduled:w.scheduled,passTx:w.passTx,flushTransaction:w.flushTransaction,min:w.minimum,max:w.maximum,running:w.running},(({question,...control})=>({...control,running:S.globalQueue._running,passTx:control.passTx?1:0,flushTransaction:control.flushTransaction?1:0}))(S.probeControl()));
  assert.deepEqual(list(tx.renderQueue),t._queues[0].map(callbackId));assert.deepEqual(list(tx.userQueue).map(e=>e.callback),t._queues[1].map(callbackId));
  assert.deepEqual(w.question,{$:'QuestionEven',half:{$:'QuestionZero'}});assert.equal(S.probeControl().question,2);
  if(allocated)assert.equal(reader._x,previous,'existing extension identity retained');cases++;
 }
 console.log(`${cases} paired native/Bend whole-round controls preserve fresh/existing extension ownership, empty/falsy pending slots, render-versus-memo loading gates, staging, exact retained action debt, callback-prefix order, clock/finally state and caller restoration. Callbacks remain unexecuted. Private seeded states, not public reachability.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
