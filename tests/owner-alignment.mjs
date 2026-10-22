import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-owner-probe-'));
try {
  const emitted=path.join(dir,'owner.mjs');
  const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/owner.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);
  const {default:B}=await import(pathToFileURL(emitted));
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';
    export * as K from './core/constants.ts';
    export {computed,signal,ext,setContextInternal,markRefresh} from './core/core.ts';
    export {dispose,disposeChildren,cleanup,createOwner} from './core/owner.ts';
    export {link,clearDeps} from './core/graph.ts';
    export {globalQueue,probeScheduled,probeReset} from './core/scheduler.ts';
  `,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'owner-scheduler-state',setup(b){b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
      export {scheduled as probeScheduled};
      export function probeReset(){rethrowCleanupError(true);scheduled=false;globalQueue._running=true;dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;}
    `}));}
  }]});
  const referenceFile=path.join(dir,'solid.mjs');fs.writeFileSync(referenceFile,bundle.outputFiles[0].text);
  const S=await import(pathToFileURL(referenceFile)),K=S.K;
  function list(xs){const a=[];while('head' in xs){a.push(xs.head);xs=xs.tail;}return a;}
  const disposal=d=>Object.hasOwn(d,'callback')?[d.callback]:Object.hasOwn(d,'callbacks')?list(d.callbacks):[];
  function actual(w){
    const xs=list(w.extensions);
    return {nodes:list(w.nodes).slice(1).map(n=>({flags:n.flags,config:n.config,status:n.status,
      first:n.firstChild,next:n.nextSibling,prev:n.prevSibling,deps:n.deps!==0,subs:n.subs!==0,disposal:disposal(n.disposal),cleanup:n.cleanup,
      childCount:n.childCount,x:n.x?{flight:xs[n.x].inFlight,child:xs[n.x].pendingFirstChild,disposal:disposal(xs[n.x].pendingDisposal)}:null})),
      events:list(w.events).filter(e=>'callback' in e).map(e=>[e.callback,e.code]),scheduled:w.scheduled,error:w.fault.cause?.n};
  }
  function reference(mode){
    S.probeReset();S.setContextInternal(null);
    const r=S.createOwner(),s=S.signal(7);S.setContextInternal(r);
    const a=S.computed(()=>11,{lazy:true}),b=S.computed(()=>13,{lazy:true});a._config=0;
    S.setContextInternal(a);const nested=S.createOwner();S.setContextInternal(nested);const c=S.computed(()=>17,{lazy:true});S.setContextInternal(null);
    const nodes=[null,r,s,a,b,nested,c],events=[],callbacks=[null];
    const id=n=>n?nodes.indexOf(n):0;
    function dispose(n){if(n._root)n.dispose();else S.dispose(n);}
    for(let cb=1;cb<=8;cb++)callbacks.push(function callback(){
      assert.equal(this,undefined,'runCleanup invokes every guarded callback as a plain call');events.push([cb,cb===8?208:100+cb]);
      if(cb===5&&mode===15)dispose(a);
      if(cb!==8)return;
      if(mode===3||mode===7)throw 99;
      if(mode===4)dispose(r);
      if(mode===5||mode===6)S.runWithOwner(a,()=>S.cleanup(callbacks[1]));
    });
    S.link(s,a);S.link(s,b);S.link(a,c);
    for(const [n,cb] of [[r,1],[r,2],[a,3],[b,5],[nested,6],[c,7]])S.runWithOwner(n,()=>S.cleanup(callbacks[cb]));
    a._cleanup=callbacks[4];r._childCount=11;a._childCount=7;nested._childCount=9;
    if(mode>=3&&mode<=6)S.runWithOwner(a,()=>S.cleanup(callbacks[8]));
    if(mode===7)a._cleanup=callbacks[8];
    if(mode===8)b._flags=K.REACTIVE_DISPOSED;
    if(mode===9){S.clearDeps(b);S.markRefresh(b);}
    if(mode===10||mode===11){
      const x=S.ext(a);x._pendingFirstChild=a._firstChild;x._pendingDisposal=a._disposal;a._firstChild=null;a._disposal=null;
      nested._flags|=K.REACTIVE_ZOMBIE;c._flags|=K.REACTIVE_ZOMBIE;
    }
    if(mode===12){S.ext(a)._inFlight=1;S.ext(a)._transaction={};a._statusFlags=K.STATUS_PENDING;}
    if(mode===13)a._flags|=K.REACTIVE_FRAME_READ;
    if(mode===14)a._flags|=K.REACTIVE_ZOMBIE;
    let error;
    try {
      if(mode===15)S.disposeChildren(r,false);
      else if(mode===11)S.disposeChildren(a,false,true);
      else if(mode===2||(mode>=4&&mode<=6))S.disposeChildren(a,false);
      else dispose(mode===1||mode>=12?a:r);
      if(mode===6)dispose(a);
      if(mode===0)dispose(r);
      if(mode===9){S.globalQueue._running=false;S.flush();}
    }catch(e){error=e;}
    const ds=d=>!d?[]:(Array.isArray(d)?d:[d]).map(fn=>callbacks.indexOf(fn));
    return {nodes:nodes.slice(1).map(n=>({flags:n._flags??0,config:n._config,status:n._statusFlags??0,
      first:id(n._firstChild),next:id(n._nextSibling),prev:id(n._prevSibling),deps:!!n._deps,subs:!!n._subs,disposal:ds(n._disposal),cleanup:callbacks.indexOf(n._cleanup)>0?callbacks.indexOf(n._cleanup):0,
      childCount:n._childCount??0,x:n._x?{flight:n._x._inFlight??0,child:id(n._x._pendingFirstChild),disposal:ds(n._x._pendingDisposal)}:null})),events,scheduled:S.probeScheduled,error};
  }
  for(let mode=0;mode<16;mode++)assert.deepEqual(actual(B.fixture(mode)),reference(mode),'owner scenario '+mode);
  console.log('16 owner teardown comparisons match pinned TS live child/sibling state and cleanup order, including parked frames, LIFO callbacks, reentrancy, registration during drain, throws, live next-sibling changes, dead children and queued dependency-free nodes.');
}finally{fs.rmSync(dir,{recursive:true,force:true});}
