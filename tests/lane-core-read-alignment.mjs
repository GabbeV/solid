// Internal source helpers, separate from admitted public histories. Fixtures
// prime real nodes/transactions; only private exports/resetters are injected.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-lane-read-'));
const list=xs=>{const a=[];while('head'in xs){a.push(xs.head);xs=xs.tail;}return a;};
const question=x=>x===0?{$:'QuestionZero'}:x%2?{$:'QuestionOdd',half:question((x-1)/2)}:{$:'QuestionEven',half:question((x-2)/2)};
const qNumber=q=>q.$==='QuestionZero'?0:q.$==='QuestionOdd'?qNumber(q.half)*2+1:qNumber(q.half)*2+2;
try{
 const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(dir,name),{recursive:true});
 fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});const probe=path.join(dir,'tests/probes/lane-core-read.bend');fs.copyFileSync(path.join(root,'tests/probes/lane-core-read.bend'),probe);
 const emitted=path.join(dir,'lane-read.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',probe,'-o',emitted],{cwd:root,encoding:'utf8'});assert.equal(compile.status,0,compile.stderr);
 const {default:B}=await import(pathToFileURL(emitted)),source=path.join(root,'upstream/solid/packages/signals/src');
 const native=await build({stdin:{contents:`export * from './index.ts';export * as K from './core/constants.ts';export {computed,ext,setContextInternal,probeTracking,resyncUnflushedCompanions,read} from './core/core.ts';export {link} from './core/graph.ts';export {newTransaction,list,globalQueue,GlobalQueue,dirtyQueue,stagedReaders,probeResetQueue,probePass,probeFlush,probeScheduled,probePending,setPassLane} from './core/scheduler.ts';export {laneRead,probeNewLane,probeLink,probeResetLanes,probeLive,probeStale,probeAnswered} from './core/lanes.ts';export {truthRead,truthConfirmed,probeTruth} from './core/truth.ts';export {probeHeld,probeLatest} from './core/verdict.ts';`,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'lane-private-observation',setup(b){
  b.onLoad({filter:/[/\\]core[/\\]core\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport function probeTracking(v:boolean){tracking=v;}'}));
  b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+`\nexport {passLane as probePass,flushTransaction as probeFlush,scheduled as probeScheduled,pendingNodes as probePending};export function probeResetQueue(p:Transaction|null,f:Transaction|null){latestOpened=null;guessing=false;rethrowCleanupError(true);clock=5;notifyEpoch=0;scheduled=false;syncDepth=1;passLane=p;flushTransaction=f;stagedReaders.length=0;pendingNodes.length=heldTrims.length=transactions.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;}`}));
  b.onLoad({filter:/[/\\]core[/\\]lanes\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {newLane as probeNewLane,linkLanes as probeLink,lanes as probeLive,stale as probeStale,answered as probeAnswered};export function probeResetLanes(){revealing.length=0;guessed=false;kept.length=0;reverting=false;entered.length=lanes.length=pendingGuesses.length=0;judged=0;}'}));
  b.onLoad({filter:/[/\\]core[/\\]truth\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {truth as probeTruth};'}));
  b.onLoad({filter:/[/\\]core[/\\]verdict\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {heldNotFinal as probeHeld};export function probeLatest(v:boolean){latestActive=v;}'}));
 }}]});
 const file=path.join(dir,'solid.mjs');fs.writeFileSync(file,native.outputFiles[0].text);const S=await import(pathToFileURL(file)),K=S.K;
 const value=i=>i===1?undefined:i===2?null:i===3?false:i===4?0:i===5?7:9;
 const decode=v=>v.$==='NotPendingToken'?'TOKEN':v.$==='Undefined'?undefined:v.$==='Null'?null:v.$==='Boolean'?v.b:v.$==='Number'?v.n:v;
 function actual(c){const m=B.fixture({$: 'Spec',...c,query:question(c.query),sourceQ:question(c.sourceQ),firstQ:question(c.firstQ),secondQ:question(c.secondQ)}),w=m.world,xs=list(w.extensions),tx=list(w.txArena);assert.equal(list(m.tasks).length,0);assert.equal(decode(list(m.values).at(-1)),71,'caller operand survives');return{value:w.fault.$==='Healthy'?decode(list(m.values)[0]):undefined,error:w.fault.$==='Healthy'?undefined:w.fault.$==='CallbackThrown'?(w.fault.cause.$==='NotReadyFailure'?{notReady:true,source:w.fault.cause.source}:{raw:decode(w.fault.cause)}):w.fault,pass:w.passLane,flush:w.flushTransaction,serial:w.errorSerial,staged:list(w.laneState.stagedReaders),live:list(w.laneState.live),tx:tx.slice(1).map(t=>({into:t.into,links:t.links?list(list(w.laneState.groups)[t.links]):[],nodes:list(t.nodes),reruns:list(t.reruns)})),nodes:list(w.nodes).slice(1).map(n=>({flags:n.flags,config:n.config,status:n.status,time:n.time,tx:xs[n.x]?.transaction??0})),pending:list(w.pendingNodes),scheduled:w.scheduled,heap:list(w.buckets),min:w.minimum,max:w.maximum};}
 function reference(c,op=c.op){
  S.probeResetQueue(null,null);S.probeResetLanes();S.setContextInternal(null);S.probeTracking(true);S.resyncUnflushedCompanions();
  const r=S.createOwner();S.setContextInternal(r);const ns=[null,r,...[7,23,11,13].map(v=>S.computed(()=>v,{lazy:true}))];S.setContextInternal(null);
  const id=n=>n?ns.indexOf(n):0;for(let i=2;i<ns.length;i++){ns[i]._value=[7,23,11,13][i-2];ns[i]._pendingValue=K.NOT_PENDING;ns[i]._flags=0;}
  const ts=[null,S.newTransaction(),null,null,null];ts[2]=S.probeNewLane(ts[1]);ts[3]=S.probeNewLane(ts[1]);ts[4]=S.newTransaction();const tid=t=>t?ts.indexOf(t):0;
  const n=ns[2],reader=c.readerKind?ns[3]:null;S.list(n,ts[2]);
  Object.assign(n,{_config:c.config,_statusFlags:c.status,_equals:c.equals?((a,b)=>a===b):false,_pendingValue:c.pending?value(c.pending):K.NOT_PENDING});
  Object.assign(S.ext(n),{_q:c.sourceQ,_lane:c.slot?value(c.slot):K.NOT_PENDING,_reask:c.reask,_shownError:c.shownError?99:undefined});
  Object.assign(ns[3],{_config:c.readerConfig,_flags:c.flags});if(c.readerKind>=2)ns[3]._type=c.readerKind===2?K.EFFECT_RENDER:c.readerKind===3?K.EFFECT_USER:K.EFFECT_TRACKED;
  if(c.readerTx)S.list(ns[3],ts[c.readerTx]);Object.assign(ts[2],{_shown:c.shown,_held:c.held});if(c.linked)S.probeLink(ts[2],ts[3]);if(c.redirect)ts[4]._into=ts[1];
  for(const [at,q,now]of[[4,c.firstQ,c.firstNow],[5,c.secondQ,c.secondNow]]){S.ext(ns[at])._q=q;ns[at]._time=now?5:4;}
  if(c.graph>=1)S.link(ns[4],n);if(c.graph>=2)S.link(ns[5],n);if(c.graph>=3)S.link(n,ns[3]);
  S.GlobalQueue._truth=S.truthRead;S.probeLatest(c.latest);S.probeResetQueue(ts[c.pass],ts[c.flush]);S.setContextInternal(reader);S.probeTracking(c.tracking);
  let result,error;try{result=op===0?S.read(n):op===1?S.truthRead(n):op===2?S.probeHeld(n):op===3?S.probeTruth(n):op===4?S.probeStale(n,c.query):op===5?S.probeAnswered(n):S.truthConfirmed(ts[2]);}catch(e){error=e instanceof S.NotReadyError?{notReady:true,source:id(e.source)}:{raw:e};}
  if(op===4||op===5)return result;
  return{value:result===K.NOT_PENDING?'TOKEN':result,error,pass:tid(S.probePass),flush:tid(S.probeFlush),serial:error?.notReady?1:0,staged:S.stagedReaders.map(id),live:S.probeLive.map(tid),tx:ts.slice(1).map(t=>({into:tid(t._into),links:t._links?.map(tid)??[],nodes:t._nodes.map(id),reruns:t._reruns.map(id)})),nodes:ns.slice(1).map(n=>({flags:n._flags??0,config:n._config,status:n._statusFlags??0,time:n._time??0,tx:tid(n._x?._transaction)})),pending:S.probePending.map(id),scheduled:S.probeScheduled,heap:Array.from({length:Math.max(1,S.dirtyQueue._heap.length)},(_,i)=>id(S.dirtyQueue._heap[i])),min:S.dirtyQueue._min,max:S.dirtyQueue._max};
 }
 const base={op:0,readerKind:1,tracking:true,pass:0,flush:0,readerTx:0,flags:0,readerConfig:0,config:K.CONFIG_OVERRIDE,status:0,shown:false,held:false,slot:5,pending:0,equals:true,reask:false,shownError:false,graph:0,linked:false,redirect:false,latest:false,query:0,sourceQ:0,firstQ:0,secondQ:0,firstNow:true,secondNow:true};
 let count=0;function check(delta){const c={...base,...delta};assert.deepEqual(actual(c),reference(c),JSON.stringify(c));count++;}
 for(const readerKind of[0,1,2,3,4])for(const tracking of[false,true])for(const config of[K.CONFIG_OVERRIDE,K.CONFIG_OVERRIDE|K.CONFIG_GUESS])for(const status of[0,K.STATUS_ERROR,K.STATUS_PENDING,K.STATUS_PENDING|K.STATUS_UNINITIALIZED])for(const shown of[false,true])for(const held of[false,true])for(const pass of[0,2,3])check({readerKind,tracking,config,status,shown,held,pass});
 for(const status of[K.STATUS_PENDING,K.STATUS_PENDING|K.STATUS_UNINITIALIZED])for(const shown of[false,true])for(const held of[false,true])check({readerKind:2,status,slot:0,shown,held});
 for(const slot of[0,1,2,3,4,5,6])for(const pending of[0,1,4,5,6])for(const pass of[0,2,3])for(const readerConfig of[0,K.CONFIG_CHILDREN_FORBIDDEN,K.CONFIG_AUTHORITATIVE])for(const config of[K.CONFIG_OVERRIDE,K.CONFIG_OVERRIDE|K.CONFIG_GUESS])check({slot,pending,pass,readerConfig,config,readerKind:2,shown:true});
 for(const flush of[1,4])for(const readerTx of[1,2])for(const redirect of[false,true])for(const pending of[0,1,5,6])for(const held of[false,true])for(const status of[0,K.STATUS_PENDING,K.STATUS_UNINITIALIZED|K.STATUS_PENDING])check({readerKind:2,readerConfig:K.CONFIG_HELD,flush,readerTx,redirect,pending,held,status});
 for(const linked of[false,true])for(const flags of[0,K.REACTIVE_SCREEN_READ,K.REACTIVE_JOINED|K.REACTIVE_STAGED_READ])for(const tracking of[false,true])check({readerKind:2,pass:3,linked,flags,tracking,held:true});
 for(const op of[1,2,3])for(const pending of[0,1,2,3,4,5,6])for(const config of[0,K.CONFIG_OVERRIDE,K.CONFIG_GUESS|K.CONFIG_OVERRIDE])for(const equals of[false,true])for(const status of[0,K.STATUS_PENDING,K.STATUS_UNINITIALIZED|K.STATUS_PENDING])for(const reask of[false,true])check({op,pending,config,equals,status,reask});
 for(const pending of[0,5,6])for(const latest of[false,true])for(const shownError of[false,true])check({op:2,pending,latest,shownError});
 for(const readerConfig of[0,K.CONFIG_AUTHORITATIVE,K.CONFIG_VERDICT])for(const flags of[0,K.REACTIVE_IN_HEAP,K.REACTIVE_DIRTY,K.REACTIVE_CHECK])for(const readerKind of[1,2,3,4])check({op:6,readerConfig,flags,readerKind,graph:3});
 // Core integration paths outside overrides: foreign flights and held/staged
 // ordinary nodes read from a lane or verdict reader. Held sources have a tx.
 for(const readerKind of[0,1,2,3,4])for(const config of[0,K.CONFIG_HELD,K.CONFIG_HELD|K.CONFIG_INPUTS_PUBLISHED])for(const status of[0,K.STATUS_PENDING,K.STATUS_PENDING|K.STATUS_UNINITIALIZED])for(const pass of[0,2,3])for(const flush of[0,1,2])for(const readerConfig of[0,K.CONFIG_VERDICT,K.CONFIG_CHILDREN_FORBIDDEN])for(const pending of[0,5])check({readerKind,config,status,pass,flush,readerConfig,pending});
 const numbers=[0,1,2,3,4,7,8,15,16,31,32,1023,1024,2147483646,2147483647,2147483648,4294967295,4294967296,Number.MAX_SAFE_INTEGER-1,Number.MAX_SAFE_INTEGER];
 let provenance=0;for(const a of numbers)for(const b of numbers){const got=B.compare(question(a),question(b)).$;assert.equal(got,a<b?'Less':a>b?'More':'Same');const c={...base,query:a,sourceQ:b};assert.equal(B.stale({$: 'Spec',...c,query:question(a),sourceQ:question(b),firstQ:question(0),secondQ:question(0)}),reference(c,4));provenance++;}
 for(const firstQ of numbers)for(const secondQ of[0,3,2147483647,Number.MAX_SAFE_INTEGER])for(const firstNow of[false,true])for(const secondNow of[false,true]){const c={...base,graph:2,firstQ,secondQ,firstNow,secondNow};const result=B.answered({$: 'Spec',...c,query:question(0),sourceQ:question(0),firstQ:question(firstQ),secondQ:question(secondQ)});assert.equal(result.left.fault.$,'Healthy');assert.equal(qNumber(result.right),reference(c,5));provenance++;}
 console.log(`${count} native lane/truth/held-finality helper programs preserve raw values, stale render routing, screen/authoritative reads, error/loading precedence and lane/transaction mutation; ${provenance} exact question-order/provenance controls pass.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
