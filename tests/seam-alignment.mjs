import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-seam-probe-'));
try{
  const emitted=path.join(dir,'seam.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/seam.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';export * as K from './core/constants.ts';
    export {signal,computed,read,setSignal,createEffectNode,setContextInternal,ext,probeParkChildren} from './core/core.ts';
    export {createOwner} from './core/owner.ts';export {link} from './core/graph.ts';export {NotReadyError,StatusError} from './core/error.ts';
    export {newTransaction,holdNode,globalQueue,dirtyQueue,clock,probeReset,probeSeed,probePending,probeTrims,probeTransactions,probeFlush,probePass,probeZombies} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'seam-state',setup(b){
      b.onLoad({filter:/[/\\]core[/\\]core\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {parkChildren as probeParkChildren};'}));
      b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
        export {pendingNodes as probePending,heldTrims as probeTrims,transactions as probeTransactions,flushTransaction as probeFlush,passTx as probePass,deferredZombies as probeZombies};
        export function probeSeed(t,pending,trims,zombies=[]){deferredZombies.push(...zombies);flushTransaction=t;pendingNodes.push(...pending);heldTrims.push(...trims);globalQueue._running=true;}
        export function probeReset(){guessing=false;clock=0;notifyEpoch=0;scheduled=false;syncDepth=1;pendingNodes.length=heldTrims.length=deferredZombies.length=transactions.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;halted=haltNotified=false;passTx=flushTransaction=passLane=judge=null;}
      `}));
    }
  }]});
  const refFile=path.join(dir,'solid.mjs');fs.writeFileSync(refFile,bundle.outputFiles[0].text);const S=await import(pathToFileURL(refFile)),K=S.K;
  const list=xs=>{const a=[];while('head'in xs){a.push(xs.head);xs=xs.tail;}return a;},disposal=d=>'callback'in d?[d.callback]:'callbacks'in d?list(d.callbacks):[];
  function actual(w){const xs=list(w.extensions);const decode=v=>v.$==='Null'?null:'n'in v?v.n:'source'in v?{source:v.source,cause:'cause'in v?decode(v.cause):undefined}:undefined;
    return {nodes:list(w.nodes).slice(1).map(n=>({config:n.config,flags:n.flags,status:n.status,loading:n.loading,modified:n.modified,value:decode(n.value),pending:'value'in n.pending,pendingValue:decode(n.pending.value??{}),time:n.time,
      deps:n.deps,tail:n.depsTail,subs:n.subs,subsTail:n.subsTail,nextHeap:n.nextHeap,prevHeap:n.prevHeap,first:n.firstChild,next:n.nextSibling,prev:n.prevSibling,disposal:disposal(n.disposal),x:n.x?{tx:xs[n.x].transaction,child:xs[n.x].pendingFirstChild,disposal:disposal(xs[n.x].pendingDisposal),error:decode(xs[n.x].error),shown:decode(xs[n.x].shownError),flight:(xs[n.x].inFlight.result??0)}:null})),
      tx:list(w.txArena).slice(1).map(t=>({nodes:list(t.nodes),render:list(t.renderQueue),user:list(t.userQueue).map(e=>e.node),reruns:list(t.reruns),into:t.into,open:t.open})),live:list(w.transactions),flush:w.flushTransaction,pass:w.passTx,pending:list(w.pendingNodes),trims:list(w.trims),zombies:list(w.deferredZombies),render:list(w.renderQueue),user:list(w.userQueue).map(e=>e.node),events:list(w.events).map(e=>'callback'in e?['cleanup',e.callback,e.code]:'reader'in e?['read',e.reader,e.source,decode(e.value)]:['compute',e.id]),error:'cause'in w.fault?decode(w.fault.cause):undefined,
      buckets:list(w.buckets),min:w.minimum,max:w.maximum,marked:w.marked,clock:w.clock,running:w.running};}
  function reference(joined,waiting,zombie,write,throwing,status,stage,revert,open,held,deferred=false){
    S.probeReset();S.setContextInternal(null);const r=S.createOwner(),x=S.signal(11);S.setContextInternal(r);const n=S.computed(()=>{events.push(['compute',3]);const v=S.read(x);events.push(['read',3,2,v]);return v;},{lazy:true});S.setContextInternal(n);const render=S.createEffectNode(()=>{events.push(['compute',4]);const v=S.read(n);events.push(['read',4,3,v]);return v;},()=>{},undefined,K.EFFECT_RENDER);S.setContextInternal(r);const user=S.createEffectNode(()=>S.read(x),()=>{},undefined,K.EFFECT_USER);S.setContextInternal(null);
    const ns=[null,r,x,n,render,user],id=n=>n?ns.indexOf(n):0,events=[],links=[null],error=new S.NotReadyError(n);
    Object.assign(n,{_value:11,_flags:0,_statusFlags:status,_config:K.CONFIG_STAGED,_pendingValue:stage===0?K.NOT_PENDING:stage===1?33:undefined});x._pendingValue=revert?11:23;
    Object.assign(render,{_flags:0,_statusFlags:waiting?K.STATUS_PENDING:0,_value:11,_modified:true});Object.assign(user,{_flags:0,_statusFlags:0,_value:11,_modified:true});S.link(x,n);links.push(n._depsTail);S.link(n,render);links.push(render._depsTail);
    S.ext(n);S.ext(render);if(status&K.STATUS_PENDING)n._x._error=error;if(waiting)render._x._error=error;
    const cb=()=>{events.push(['cleanup',1,101]);if(write)S.setSignal(x,77);if(throwing)throw 42;};S.runWithOwner(n,()=>S.onCleanup(cb));if(zombie)S.probeParkChildren(n);
    const t=S.newTransaction(false);if(held){S.holdNode(n,t);S.holdNode(x,t);}const cb4=()=>{},cb5=()=>{},cbid=fn=>fn===cb4||fn===render._boundRunEffect?4:5;t._queues=[[cb4],[cb5]];t._open=open?1:0;S.globalQueue._queues=[[cb5],[cb4]];S.probeSeed(joined?t:null,[x,n,render],[n],deferred?[render]:[]);let exception;
    try{S.globalQueue.settle();}catch(e){exception=e;}
    const decode=e=>e instanceof S.NotReadyError?{source:id(e.source),cause:undefined}:e instanceof S.StatusError?{source:id(e.source),cause:decode(e.cause)}:e,edge=e=>e?links.indexOf(e):0,ds=d=>!d?[]:[1];
    return {nodes:ns.slice(1).map(n=>({config:n._config,flags:n._flags??0,status:n._statusFlags??0,loading:n._loading??false,modified:n._modified??false,value:decode(n._value),pending:n._pendingValue!==undefined&&n._pendingValue!==K.NOT_PENDING||n._pendingValue===undefined&&('_fn'in n||n===x)&&n._pendingValue!==K.NOT_PENDING,pendingValue:n._pendingValue===K.NOT_PENDING?undefined:decode(n._pendingValue),time:n._time??0,
      deps:edge(n._deps),tail:edge(n._depsTail),subs:edge(n._subs),subsTail:edge(n._subsTail),nextHeap:id(n._nextHeap),prevHeap:id(n._prevHeap),first:id(n._firstChild),next:id(n._nextSibling),prev:id(n._prevSibling),disposal:ds(n._disposal),x:n._x?{tx:n._x._transaction===t?1:0,child:id(n._x._pendingFirstChild),disposal:ds(n._x._pendingDisposal),error:decode(n._x._error),shown:decode(n._x._shownError),flight:n._x._inFlight?1:0}:null})),
      tx:[{nodes:t._nodes.map(id),render:t._queues[0].map(cbid),user:t._queues[1].map(cbid),reruns:t._reruns.map(id),into:t._into?1:0,open:t._open}],live:S.probeTransactions.map(()=>1),flush:S.probeFlush===t?1:0,pass:S.probePass===t?1:0,pending:S.probePending.map(id),trims:S.probeTrims.map(id),zombies:S.probeZombies.map(id),render:S.globalQueue._queues[0].map(cbid),user:S.globalQueue._queues[1].map(cbid),events,error:decode(exception),
      buckets:Array.from({length:Math.max(1,S.dirtyQueue._heap.length)},(_,i)=>id(S.dirtyQueue._heap[i])),min:S.dirtyQueue._min,max:S.dirtyQueue._max,marked:S.dirtyQueue._marked,clock:S.clock,running:S.globalQueue._running};
  }
  let count=0;
  for(const joined of [false,true])for(const waiting of [false,true])for(const zombie of [false,true])for(const write of [false,true])for(const throwing of [false,true])for(const status of [0,K.STATUS_PENDING,K.STATUS_PENDING|K.STATUS_UNINITIALIZED])for(const stage of [0,1,2])for(const revert of [false,true])for(const open of [false,true])for(const held of [false,true]){
    const args=[joined,waiting,zombie,write,throwing,status,stage,revert,open,held];assert.deepEqual(actual(B.fixture(...args)),reference(...args),JSON.stringify(args));count++;
  }
  let deferredCount=0;
  for(const joined of [false,true])for(const waiting of [false,true])for(const status of [0,K.STATUS_PENDING,K.STATUS_PENDING|K.STATUS_UNINITIALIZED])for(const open of [false,true])for(const held of [false,true]){
    assert.deepEqual(actual(B.fixtureDeferred(joined,waiting,status,open,held)),reference(joined,waiting,true,false,false,status,1,false,open,held,true),'deferred '+JSON.stringify({joined,waiting,status,open,held}));deferredCount++;
  }
  console.log(`${count} seam and ${deferredCount} deferred-zombie comparisons match TS park/commit/land, blocker judgments, queue ordering, zombie disposal, net-zero writes, live landing rewrites and exceptional partial state.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
