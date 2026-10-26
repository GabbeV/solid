import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-held-probe-'));
try{
  const emitted=path.join(dir,'held.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/held.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';export * as K from './core/constants.ts';
    export {signal,computed,read,setSignal,setMemo,recompute,createEffectNode,setContextInternal,ext,probeConfigure,probePromoted,unflushedStaged,context,tracking} from './core/core.ts';
    export {createOwner} from './core/owner.ts';export {stageError} from './core/async.ts';export {NotReadyError,StatusError} from './core/error.ts';
    export {newTransaction,holdNode,commitPendingNode,globalQueue,dirtyQueue,clock,probeReset,probeFlushSet,probePending,probeTrims,probeTransactions,probeFlush,probePass,probeScheduled} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'held-state',setup(b){
      b.onLoad({filter:/[/\\]core[/\\]core\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {promotedWrites as probePromoted};export function probeConfigure(c,t,u){context=c;tracking=t;unflushedStaged=u;promotedWrites.length=0;}'}));
      b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
        export {pendingNodes as probePending,heldTrims as probeTrims,transactions as probeTransactions,flushTransaction as probeFlush,passTx as probePass,scheduled as probeScheduled};
        export function probeFlushSet(running,t){globalQueue._running=running;flushTransaction=t;}
        export function probeReset(){clock=5;notifyEpoch=0;scheduled=false;syncDepth=1;pendingNodes.length=heldTrims.length=deferredZombies.length=transactions.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=1;dirtyQueue._max=0;dirtyQueue._marked=false;halted=haltNotified=false;passTx=flushTransaction=passLane=judge=null;}
      `}));
    }
  }]});
  const refFile=path.join(dir,'solid.mjs');fs.writeFileSync(refFile,bundle.outputFiles[0].text);const S=await import(pathToFileURL(refFile)),K=S.K;
  const list=xs=>{const a=[];while('head'in xs){a.push(xs.head);xs=xs.tail;}return a;};
  function actual({world:w,result}){const xs=list(w.extensions),sets=list(w.pendingSets),errors=new Map(),decode=v=>{
    if('identity'in v){if(!errors.has(v.identity))errors.set(v.identity,errors.size+1);return {kind:'cause'in v?'error':'pending',identity:errors.get(v.identity),source:v.source,...('cause'in v?{cause:decode(v.cause)}:{})};}
    return v.$==='NotPendingToken'?{sentinel:'NOT_PENDING'}:v.$==='Null'?null:'n'in v?v.n:'b'in v?v.b:undefined;
  };return {returned:'value'in result,value:'value'in result?decode(result.value):undefined,
    nodes:list(w.nodes).slice(1).map(n=>({config:n.config,flags:n.flags,status:n.status,value:decode(n.value),pending:'value'in n.pending,pendingValue:decode(n.pending.value??{}),time:n.time,loading:n.loading,modified:n.modified,deps:n.deps,tail:n.depsTail,subs:n.subs,subsTail:n.subsTail,height:n.height,nextHeap:n.nextHeap,prevHeap:n.prevHeap,
      x:n.x?{tx:xs[n.x].transaction,error:decode(xs[n.x].error),shown:decode(xs[n.x].shownError),blocked:'value'in xs[n.x].blocked?decode(xs[n.x].blocked.value):undefined,sources:xs[n.x].pendingSources?list(sets[xs[n.x].pendingSources]).filter(id=>id!==0):undefined,flushed:'value'in xs[n.x].flushed,flushedValue:decode(xs[n.x].flushed.value??{}),flushedAt:xs[n.x].flushedAt.value??-1}:null})),
    heap:{minimum:w.minimum,maximum:w.maximum,marked:w.marked,buckets:list(w.buckets).map((id,index)=>[index,id]).filter(([,id])=>id!==0)},live:list(w.transactions),tx:list(w.txArena).slice(1).map(t=>({nodes:list(t.nodes),reruns:list(t.reruns),render:list(t.renderQueue),user:list(t.userQueue).map(e=>e.node)})),flush:w.flushTransaction,pass:w.passTx,pending:list(w.pendingNodes),trims:list(w.trims),unflushed:w.unflushedStaged,promoted:list(w.promotedWrites),scheduled:w.scheduled,context:w.context,tracking:w.tracking,
    events:list(w.events).map(e=>'reader'in e?['read',e.reader,e.source,decode(e.value)]:['compute',e.id]),threw:w.fault.$!=='Healthy',exception:'cause'in w.fault?decode(w.fault.cause):'reason'in w.fault?{unsupported:w.fault.reason}:undefined};}
  function reference(op,status,config,staging,reader,readerConfig,readerStatus,tracking,running,joined,unflushed,v,flags=0,held=true){
    S.probeReset();S.probeConfigure(null,false,false);const events=[],r=S.createOwner(),x=S.signal(11);S.setContextInternal(r);
    const n=S.computed(()=>{events.push(['compute',3]);throw 99;},{lazy:true}),c=reader<=1?S.computed(()=>0,{lazy:true}):S.createEffectNode(()=>0,()=>{},undefined,reader===2?K.EFFECT_RENDER:K.EFFECT_USER);S.setContextInternal(null);
    const ns=[null,r,x,n,c],id=n=>n?ns.indexOf(n):0,t=S.newTransaction(false),txid=tx=>tx===t?1:0;S.holdNode(n,t);S.holdNode(x,t);
    x._config=n._config=K.CONFIG_HELD|config;x._pendingValue=n._pendingValue=staging===0?K.NOT_PENDING:staging===1?23:undefined;
    Object.assign(n,{_value:11,_flags:flags,_statusFlags:status});if(!held)n._config&=~K.CONFIG_HELD;Object.assign(c,{_flags:0,_config:readerConfig,_statusFlags:readerStatus});if(readerConfig&K.CONFIG_HELD)S.holdNode(c,t);
    const notReady=new S.NotReadyError(n),failure=new S.StatusError(n,99);if(status&K.STATUS_ERROR)n._x._error=failure;else if(status&K.STATUS_PENDING)n._x._error=notReady;if(status&K.STATUS_PENDING)n._x._pendingSources=new Set([n]);
    S.probeFlushSet(running,joined?t:null);S.probeConfigure(reader?c:null,tracking,unflushed);const val=[undefined,11,23,77][v];let result,returned=false,exception,threw=false;
    try{
      if(op===0||op===1){result=S.read(op===0?x:n);returned=true;events.push(['read',reader?4:0,op===0?2:3,result]);}
      if(op===2||op===3){result=S.setSignal(op===2?x:n,val);returned=true;}
      if(op===4)S.recompute(n);
      if(op===5){result=S.stageError(n,99,tracking);returned=true;}
      if(op===6)S.commitPendingNode(n);
      if(op>=7){result=S.setMemo(n,op===7?val:op===8?(previous=>previous):(()=>val));returned=true;}
    }catch(e){exception=e;threw=true;}
    const errors=new Map(),decode=e=>{if(e===K.NOT_PENDING)return {sentinel:'NOT_PENDING'};if(e instanceof S.StatusError||e instanceof S.NotReadyError){if(!errors.has(e))errors.set(e,errors.size+1);return {kind:e instanceof S.StatusError?'error':'pending',identity:errors.get(e),source:id(e.source),...(e instanceof S.StatusError?{cause:decode(e.cause)}:{})};}return e;};
    // Number links in their allocation order, as the stable Bend arena does.
    const links=[null];for(const node of ns.slice(1)){for(let edge=node._deps;edge;edge=edge._nextDep)if(!links.includes(edge))links.push(edge);}const edge=e=>e?links.indexOf(e):0;
    return {returned,value:decode(result),nodes:ns.slice(1).map(n=>({config:n._config,flags:n._flags??0,status:n._statusFlags??0,value:decode(n._value),pending:(n===x||!!n._fn)&&n._pendingValue!==K.NOT_PENDING,pendingValue:n._pendingValue===K.NOT_PENDING?undefined:decode(n._pendingValue),time:n._time??0,loading:n._loading??false,modified:n._modified??false,deps:edge(n._deps),tail:edge(n._depsTail),subs:edge(n._subs),subsTail:edge(n._subsTail),height:n._height??0,nextHeap:id(n._nextHeap),prevHeap:id(n._prevHeap),
      x:n._x?{tx:txid(n._x._transaction),error:decode(n._x._error),shown:decode(n._x._shownError),blocked:n._x._blocked,sources:n._x._pendingSources?[...n._x._pendingSources].map(id):undefined,flushed:n._x._flushed!==K.NOT_PENDING,flushedValue:n._x._flushed===K.NOT_PENDING?undefined:decode(n._x._flushed),flushedAt:n._x._flushedAt}:null})),
      heap:{minimum:S.dirtyQueue._min,maximum:S.dirtyQueue._max,marked:S.dirtyQueue._marked,buckets:Array.from({length:S.dirtyQueue._heap.length},(_,i)=>[i,id(S.dirtyQueue._heap[i])]).filter(([,id])=>id!==0)},live:S.probeTransactions.map(txid),tx:[{nodes:t._nodes.map(id),reruns:t._reruns.map(id),render:t._queues[0].map(()=>4),user:t._queues[1].map(()=>4)}],flush:txid(S.probeFlush),pass:txid(S.probePass),pending:S.probePending.map(id),trims:S.probeTrims.map(id),unflushed:S.unflushedStaged,promoted:S.probePromoted.map(id),scheduled:S.probeScheduled,context:id(S.context),tracking:S.tracking,events,threw,exception:decode(exception)};
  }
  let seed=0x613af9,count=0;const rng=n=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return(seed>>>0)%n;};
  for(let index=0;index<4096;index++){
    const args=[index%7,[0,1,2,4,5][rng(5)],[0,K.CONFIG_INPUTS_PUBLISHED,K.CONFIG_STAGED_ERROR,K.CONFIG_STAGED,K.CONFIG_HELD_FRAME,K.CONFIG_LAGS][rng(6)],rng(3),rng(4),[0,K.CONFIG_CHILDREN_FORBIDDEN,K.CONFIG_HELD|K.CONFIG_HELD_FRAME][rng(3)],rng(2)?K.STATUS_UNINITIALIZED:0,!!rng(2),!!rng(2),!!rng(2),!!rng(2),rng(4)];
    assert.deepEqual(actual(B.fixture(...args)),reference(...args),JSON.stringify(args));count++;
  }
  let memoCount=0;
  for(let index=0;index<4096;index++){
    const args=[7+index%3,[0,1,2,4,5][rng(5)],[0,K.CONFIG_INPUTS_PUBLISHED,K.CONFIG_STAGED_ERROR,K.CONFIG_STAGED,K.CONFIG_HELD_FRAME,K.CONFIG_LAGS][rng(6)],rng(3),rng(4),[0,K.CONFIG_CHILDREN_FORBIDDEN,K.CONFIG_HELD|K.CONFIG_HELD_FRAME][rng(3)],rng(2)?K.STATUS_UNINITIALIZED:0,!!rng(2),!!rng(2),!!rng(2),!!rng(2),rng(4),[0,K.REACTIVE_MANUAL_WRITE,K.REACTIVE_CHECK,K.REACTIVE_MANUAL_WRITE|K.REACTIVE_CHECK][rng(4)],!!rng(2)];
    assert.deepEqual(actual(B.fixtureMemo(...args)),reference(...args),JSON.stringify(args));memoCount++;
  }
  // #4302 separates frame posture from node kind. Exercise frame-marked
  // memos and explicitly unmarked render nodes independently in actual source.
  let frameCount=0;
  for(const op of [0,1,4])for(const config of [0,K.CONFIG_FRAME])for(const reader of [1,2])for(const readerConfig of [0,K.CONFIG_FRAME])for(const staging of [0,1,2])for(const running of [false,true])for(const joined of [false,true]){
    const args=[op,0,config,staging,reader,readerConfig,0,true,running,joined,false,3];
    assert.deepEqual(actual(B.fixture(...args)),reference(...args),JSON.stringify({framePosture:args}));frameCount++;
  }
  console.log(`${frameCount} frame-posture comparisons independently vary CONFIG_FRAME and memo/render kind across reads and held re-entry.`);
  console.log(`${memoCount} setMemo comparisons match actual TS raw/updater calls, committed-versus-staged previous values, manual writes, held rederivation flags, heaps and schedules.`);
  console.log(`${count} held-operation comparisons match TS signal/memo reads and writes, frame/born-held posture, unflushed stashes, pending/error throws, recompute catches and staged error publication.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
