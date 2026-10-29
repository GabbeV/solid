import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-lifecycle-probe-'));
try {
  const emitted=path.join(dir,'lifecycle.mjs');
  const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/lifecycle.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';export * as K from './core/constants.ts';
    export {signal,computed,read,setSignal,recompute,ext,setContextInternal,probeParkChildren,resyncUnflushedCompanions,unflushedStaged,context,tracking} from './core/core.ts';
    export {cleanup,createOwner} from './core/owner.ts';
    export {commitPendingNode,queuePendingNode,clock,dirtyQueue,globalQueue,probeReset,probePending,probeTrims,probeScheduled} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'lifecycle-private-state',setup(b){
      b.onLoad({filter:/[/\\]core[/\\]core\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {parkChildren as probeParkChildren};'}));
      b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
        export {pendingNodes as probePending, heldTrims as probeTrims, scheduled as probeScheduled};
        export function probeReset(){guessing=false;rethrowCleanupError(true);clock=0;notifyEpoch=0;scheduled=false;syncDepth=1;pendingNodes.length=heldTrims.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;}
      `}));
    }
  }]});
  const refFile=path.join(dir,'solid.mjs');fs.writeFileSync(refFile,bundle.outputFiles[0].text);const S=await import(pathToFileURL(refFile)),K=S.K;
  const list=xs=>{const a=[];while('head' in xs){a.push(xs.head);xs=xs.tail;}return a;};
  const value=v=>Object.hasOwn(v,'n')?v.n:Object.hasOwn(v,'b')?v.b:undefined;
  const disposal=d=>Object.hasOwn(d,'callback')?[d.callback]:Object.hasOwn(d,'callbacks')?list(d.callbacks):[];
  function actual(w){const xs=list(w.extensions);return {
    nodes:list(w.nodes).slice(1).map(n=>({flags:n.flags,config:n.config,status:n.status,value:value(n.value),pending:Object.hasOwn(n.pending,'value'),pendingValue:value(n.pending.value??{}),
      first:n.firstChild,next:n.nextSibling,prev:n.prevSibling,gen:n.depGen,time:n.time,loading:n.loading,disposal:disposal(n.disposal),cleanup:n.cleanup,
      x:n.x?{flight:(xs[n.x].inFlight.result??0),teardown:xs[n.x].flightTeardown,child:xs[n.x].pendingFirstChild,disposal:disposal(xs[n.x].pendingDisposal),reask:xs[n.x].reask}:null})),
    events:list(w.events).map(e=>'callback' in e?['cleanup',e.callback,e.code]:'reader' in e?['read',e.reader,e.source,value(e.value)]:['compute',e.id]),
    context:w.context,tracking:w.tracking,clock:w.clock,running:w.running,scheduled:w.scheduled,unflushed:w.unflushedStaged,pending:list(w.pendingNodes),trims:list(w.trims),
    min:w.minimum,max:w.maximum,error:w.fault.cause?.n};}
  function reference(mode){
    S.probeReset();S.resyncUnflushedCompanions();S.setContextInternal(null);const events=[],callbacks=[null];
    const r=S.createOwner(),x=S.signal(1);S.setContextInternal(r);
    const a=S.computed(()=>{events.push(['compute',3]);const v=S.read(x);events.push(['read',3,2,v]);return mode===2?v===0:v;});
    S.setContextInternal(a);const child=S.createOwner(),memo=S.computed(()=>17,{lazy:true});S.setContextInternal(null);
    const nodes=[null,r,x,a,child,memo],id=n=>n?nodes.indexOf(n):0;
    for(let cb=1;cb<=5;cb++)callbacks.push(function callback(){
      assert.equal(this,undefined);events.push(['cleanup',cb,100+cb]);
      if(cb===3&&mode===11)S.setSignal(x,7);
      if((cb===3&&[4,5,9].includes(mode))||(cb===5&&mode===6))throw 99;
    });
    for(const [n,cb] of [[child,1],[memo,2],[a,3]])S.runWithOwner(n,()=>S.cleanup(callbacks[cb]));memo._cleanup=callbacks[4];events.length=0;
    if(mode===3||mode===4)a._config|=K.CONFIG_STAGED;
    if(mode===6||mode===7){S.ext(a)._inFlight=1;S.ext(a)._flightTeardown=callbacks[5];}
    let error;
    try {
      if(mode>=8&&mode<=10){S.probeParkChildren(a);a._config|=K.CONFIG_STAGED;a._pendingValue=mode===10?K.NOT_PENDING:23;if(mode===10)a._statusFlags=K.STATUS_PENDING;S.queuePendingNode(a);S.commitPendingNode(a);}
      else {S.setSignal(x,2);if(mode===1){S.recompute(a);S.commitPendingNode(a);}else S.flush();}
    }catch(e){error=e;}
    const ds=d=>!d?[]:(Array.isArray(d)?d:[d]).map(cb=>callbacks.indexOf(cb));
    return {nodes:nodes.slice(1).map(n=>({flags:n._flags??0,config:n._config,status:n._statusFlags??0,value:n._value,pending:n._pendingValue!==undefined&&n._pendingValue!==K.NOT_PENDING,
      pendingValue:n._pendingValue===K.NOT_PENDING?undefined:n._pendingValue,first:id(n._firstChild),next:id(n._nextSibling),prev:id(n._prevSibling),gen:n._depGen??0,time:n._time??0,loading:n._loading??false,disposal:ds(n._disposal),cleanup:callbacks.indexOf(n._cleanup)>0?callbacks.indexOf(n._cleanup):0,
      x:n._x?{flight:n._x._inFlight??0,teardown:callbacks.indexOf(n._x._flightTeardown)>0?callbacks.indexOf(n._x._flightTeardown):0,child:id(n._x._pendingFirstChild),disposal:ds(n._x._pendingDisposal),reask:n._x._reask}:null})),
      events,context:id(S.context),tracking:S.tracking,clock:S.clock,running:S.globalQueue._running,scheduled:S.probeScheduled,unflushed:S.unflushedStaged,pending:S.probePending.map(id),trims:S.probeTrims.map(id),min:S.dirtyQueue._min,max:S.dirtyQueue._max,error};
  }
  for(let mode=0;mode<12;mode++)assert.deepEqual(actual(B.fixture(mode)),reference(mode),'lifecycle case '+mode);
  console.log('12 lifecycle comparisons match pinned TS recompute/park/commit and cancellation order and cleanup-staged live intake, including unchanged frames, restaging, in-flight commit, cleanup throws and flush finally state.');
}finally{fs.rmSync(dir,{recursive:true,force:true});}
