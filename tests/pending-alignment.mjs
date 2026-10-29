import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-pending-probe-'));
try{
  const emitted=path.join(dir,'pending.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/pending.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';export * as K from './core/constants.ts';
    export {computed,createEffectNode,setContextInternal,ext} from './core/core.ts';
    export {createOwner} from './core/owner.ts';export {link} from './core/graph.ts';export {clearStatus,notifyStatus,addPendingSource,setPendingError,parkLoadingWindow,settlePendingSource,releaseSettledDependents,probeRemove,probeLand,probeClear} from './core/async.ts';export {StatusError,NotReadyError} from './core/error.ts';
    export {clock,dirtyQueue,globalQueue,probeReset,probePending,probeScheduled,probeHalted,probeHaltNotified} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'pending-state',setup(b){
      b.onLoad({filter:/[/\\]core[/\\]async\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {removePendingSource as probeRemove,landStatus as probeLand,clearPendingSources as probeClear};'}));
      b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
      export {pendingNodes as probePending,scheduled as probeScheduled,halted as probeHalted,haltNotified as probeHaltNotified};
      export function probeReset(){guessing=false;clock=5;notifyEpoch=0;scheduled=false;syncDepth=1;pendingNodes.length=heldTrims.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;halted=haltNotified=false;}
    `}));}
  }]});
  const refFile=path.join(dir,'solid.mjs');fs.writeFileSync(refFile,bundle.outputFiles[0].text);const S=await import(pathToFileURL(refFile)),K=S.K;
  const list=xs=>{const a=[];while('head'in xs){a.push(xs.head);xs=xs.tail;}return a;};
  const disposal=d=>'callback'in d?[d.callback]:'callbacks'in d?list(d.callbacks):[];
  function actual(w){const errors=new Map(),extensions=list(w.extensions),decode=v=>{
    if('identity'in v){if(!errors.has(v.identity))errors.set(v.identity,errors.size+1);return {kind:'cause'in v?'error':'pending',identity:errors.get(v.identity),source:v.source,...('cause'in v?{cause:decode(v.cause)}:{})};}
    if('n'in v)return v.n;if('b'in v)return v.b;return v.$==='Null'?null:undefined;
  };return {nodes:list(w.nodes).slice(1).map(n=>({flags:n.flags,config:n.config,status:n.status,time:n.time,
      error:decode(extensions[n.x]?.error??{}),shown:decode(extensions[n.x]?.shownError??{}),blocked:'value'in(extensions[n.x]?.blocked??{})?decode(extensions[n.x].blocked.value):undefined,
      sources:extensions[n.x]?.pendingSources?list(list(w.pendingSets)[extensions[n.x].pendingSources]).filter(id=>id!==0):undefined,
      x:!!n.x,next:n.nextHeap,prev:n.prevHeap,first:n.firstChild,nextSibling:n.nextSibling,prevSibling:n.prevSibling,deps:n.deps,tail:n.depsTail,subs:n.subs,subsTail:n.subsTail,disposal:disposal(n.disposal)})),
    links:list(w.links).slice(1).map(l=>({...l,$:undefined})),events:list(w.events).map(e=>[e.callback,e.code]),
    pending:list(w.pendingNodes),buckets:list(w.buckets),min:w.minimum,max:w.maximum,marked:w.marked,scheduled:w.scheduled,exception:'cause'in w.fault?decode(w.fault.cause):undefined};}
  function reference(op,status,flags,extra,additional,block,config){
    S.probeReset();S.setContextInternal(null);const r=S.createOwner();S.setContextInternal(r);
    const ns=[null,r,...[7,11,13,17,19].map(v=>S.computed(()=>v,{lazy:true}))];S.setContextInternal(null);
    const [n,a,b,c,other]=ns.slice(2),id=n=>n?ns.indexOf(n):0,links=[null],events=[];
    for(const [dep,sub] of [[n,a],[n,b],[a,c],[b,c],...(extra?[[other,b]]:[])]){S.link(dep,sub);links.push(sub._depsTail);}
    for(const node of [n,a,b]){node._flags=0;node._config=node===a?config:0;}c._flags=flags;
    const source=op===1?n:other,unready=new S.NotReadyError(source),failure=new S.StatusError(n,99);
    for(const node of [n,a,b,c])Object.assign(S.ext(node),{_error:status&K.STATUS_ERROR?failure:unready,_blocked:true,
      _pendingSources:node===n||op!==0||extra?new Set([source,...(additional?[b]:[])]):undefined});
    for(const node of [n,a,b,c])node._statusFlags=status;
    const cb1=()=>{events.push([1,101]);if(block)throw 42;},cb2=()=>events.push([2,102]);S.ext(a)._unobserved=cb2;S.runWithOwner(c,()=>S.onCleanup(cb1));let exception;
    try{
      if(op===0)S.notifyStatus(n,K.STATUS_PENDING,unready);
      if(op===1)S.settlePendingSource(n,n);
      if(op===2)S.settlePendingSource(n,other);
      if(op===3)S.releaseSettledDependents(n);
      if(op===4)S.parkLoadingWindow(n,unready);
      if(op===5){S.addPendingSource(c,c);S.probeLand(c,additional);}
      if(op===7)S.notifyStatus(n,K.STATUS_ERROR,unready);
      if(op===8)S.notifyStatus(n,K.STATUS_PENDING,new S.NotReadyError(null));
      if(op===9){a._depGen=1;S.notifyStatus(n,K.STATUS_PENDING,unready);}
      if(op===6){S.addPendingSource(c,other);S.addPendingSource(c,other);S.probeRemove(c,other);S.setPendingError(c,additional?b:undefined);}
    }catch(e){exception=e;}
    const errors=new Map(),decode=e=>{if(e instanceof S.StatusError||e instanceof S.NotReadyError){if(!errors.has(e))errors.set(e,errors.size+1);return {kind:e instanceof S.StatusError?'error':'pending',identity:errors.get(e),source:id(e.source),...(e instanceof S.StatusError?{cause:decode(e.cause)}:{})};}return e;},edge=e=>e?links.indexOf(e):0;
    return {nodes:ns.slice(1).map(n=>({flags:n._flags??0,config:n._config,status:n._statusFlags??0,time:n._time??0,error:decode(n._x?._error),shown:decode(n._x?._shownError),blocked:n._x?._blocked,
      sources:n._x?._pendingSources?[...n._x._pendingSources].map(id):undefined,x:!!n._x,next:id(n._nextHeap),prev:id(n._prevHeap),first:id(n._firstChild),nextSibling:id(n._nextSibling),prevSibling:id(n._prevSibling),
      deps:edge(n._deps),tail:edge(n._depsTail),subs:edge(n._subs),subsTail:edge(n._subsTail),disposal:n._disposal?[1]:[]})),
      links:links.slice(1).map(l=>({$:undefined,dep:id(l._dep),sub:id(l._sub),nextDep:edge(l._nextDep),prevSub:edge(l._prevSub),nextSub:edge(l._nextSub),gen:l._gen})),events,
      pending:S.probePending.map(id),buckets:Array.from({length:Math.max(1,S.dirtyQueue._heap.length)},(_,i)=>id(S.dirtyQueue._heap[i])),min:S.dirtyQueue._min,max:S.dirtyQueue._max,marked:S.dirtyQueue._marked,scheduled:S.probeScheduled,exception:decode(exception)};
  }
  let count=0;
  for(let op=0;op<10;op++)for(const status of [0,1,3,5])for(const flags of [0,K.REACTIVE_ZOMBIE,K.REACTIVE_DISPOSED])for(const extra of [false,true])for(const additional of [false,true])for(const block of [false,true])for(const config of [0,K.CONFIG_VERDICT,K.CONFIG_REDERIVE]){
    if([0,7,8,9].includes(op)&&block)continue;
    assert.deepEqual(actual(B.fixture(op,status,flags,extra,additional,block,config)),reference(op,status,flags,extra,additional,block,config),JSON.stringify({op,status,flags,extra,additional,block,config}));count++;
  }
  for(let mode=0;mode<9;mode++){
    S.probeReset();S.setContextInternal(null);const r=S.createOwner();S.setContextInternal(r);const nodes=[null,r,...[0,1,2,3,4].map(()=>S.computed(()=>7,{lazy:true}))];S.setContextInternal(null);const n=nodes[2],id=n=>nodes.indexOf(n),seen=[];
    S.addPendingSource(n,nodes[3]);const saved=n._x._pendingSources;
    if(mode===0){S.addPendingSource(n,nodes[3]);S.addPendingSource(n,nodes[4]);}
    if(mode===1)S.probeRemove(n,nodes[3]);
    if(mode===2){S.probeClear(n);S.addPendingSource(n,nodes[4]);}
    if(mode===3){S.probeRemove(n,nodes[3]);S.addPendingSource(n,nodes[4]);}
    if(mode===4){S.addPendingSource(n,nodes[4]);S.probeRemove(n,nodes[3]);}
    if(mode===5)S.probeRemove(n,{});
    if(mode>=6){
      if(mode===6)S.addPendingSource(n,nodes[4]);
      for(const source of saved){seen.push(id(source));
        if(mode===6&&source===nodes[3]){S.probeRemove(n,nodes[3]);S.addPendingSource(n,nodes[5]);}
        if(mode===6&&source===nodes[4]){S.probeRemove(n,nodes[5]);S.addPendingSource(n,nodes[6]);}
        if(mode===7&&source===nodes[3]){S.probeRemove(n,nodes[3]);S.addPendingSource(n,nodes[4]);}
        if(mode===8&&source===nodes[3]){S.probeClear(n);S.addPendingSource(n,nodes[4]);}
      }
    }
    const result=B.aliasFixture(mode);
    assert.deepEqual({oldItems:list(result.oldItems),current:'items'in result.current?list(result.current.items):undefined,same:result.same,seen:list(result.seen)},
      {oldItems:[...saved].map(id),current:n._x._pendingSources?[...n._x._pendingSources].map(id):undefined,same:n._x._pendingSources===saved,seen},'captured Set case '+mode);
  }
  console.log(`${count} pending-state comparisons match TS source sets, pending propagation, loading parks, self-only landing, settle/retry diamonds, deferred release and cleanup throws. Nine captured-Set alias/iterator cases also match. Public promise/transaction execution is checked separately.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
