import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-graph-probe-'));
try {
  const emitted=path.join(dir,'graph.mjs');
  const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/graph.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';export * as K from './core/constants.ts';
    export {signal,computed,setSignal,setContextInternal} from './core/core.ts';
    export {cleanup,createOwner} from './core/owner.ts';export * from './core/graph.ts';
    export {probeReset,probePending,probeScheduled} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'graph-private-state',setup(b){
      b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
        export {pendingNodes as probePending,scheduled as probeScheduled};
        export function probeReset(){guessing=false;clock=0;notifyEpoch=0;scheduled=false;syncDepth=1;pendingNodes.length=heldTrims.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;}
      `}));
    }
  }]});
  const refFile=path.join(dir,'solid.mjs');fs.writeFileSync(refFile,bundle.outputFiles[0].text);const S=await import(pathToFileURL(refFile)),K=S.K;
  const list=xs=>{const a=[];while('head' in xs){a.push(xs.head);xs=xs.tail;}return a;};
  const ds=d=>Object.hasOwn(d,'callback')?[d.callback]:Object.hasOwn(d,'callbacks')?list(d.callbacks):[];
  function actual(w){return {
    nodes:list(w.nodes).slice(1).map(n=>({flags:n.flags,config:n.config,status:n.status,value:n.value.n,pending:n.pending.value?.n,
      first:n.firstChild,next:n.nextSibling,prev:n.prevSibling,deps:n.deps,tail:n.depsTail,subs:n.subs,subsTail:n.subsTail,disposal:ds(n.disposal)})),
    links:list(w.links).slice(1).map(l=>({dep:l.dep,sub:l.sub,nextDep:l.nextDep,prevSub:l.prevSub,nextSub:l.nextSub,gen:l.gen})),
    events:list(w.events).map(e=>[e.callback,e.code]),dormant:list(w.dormantNodes),pending:list(w.pendingNodes),scheduled:w.scheduled,error:w.fault.cause?.n};}
  function reference(op,auto,flags,pending,hook){
    S.probeReset();S.dormantNodes.clear();S.setContextInternal(null);const events=[];
    const cb1=()=>events.push([1,101]),cb2=()=>{events.push([2,102]);if(hook===1)throw 99;if(hook===2)S.setSignal(x,9);},cb3=()=>events.push([3,103]);
    const r=S.createOwner(),x=S.signal(7,{unobserved:cb1});
    S.setContextInternal(r);const c=S.computed(()=>11,{lazy:true,unobserved:cb2});
    S.setContextInternal(c);const child=S.createOwner();S.setContextInternal(r);const sub=S.computed(()=>13,{lazy:true});S.setContextInternal(null);
    const nodes=[null,r,x,c,child,sub],links=[null],id=n=>n?nodes.indexOf(n):0;
    c._flags=flags;c._config=auto?K.CONFIG_AUTO_DISPOSE:0;c._statusFlags=pending?K.STATUS_PENDING:0;
    S.link(x,c);links.push(c._deps);if(op===3)S.dormantNodes.add(c);else{S.link(c,sub);links.push(sub._deps);}
    S.runWithOwner(c,()=>S.cleanup(cb3));let error;
    try{if(op===0)S.clearDeps(sub);if(op===1){sub._depsTail=null;S.trimStaleDeps(sub);}if(op===2)S.unlinkSubs(sub._deps);if(op===3)S.sweepDormant();}catch(e){error=e;}
    const edge=e=>e?links.indexOf(e):0;
    return {nodes:nodes.slice(1).map(n=>({flags:n._flags??0,config:n._config,status:n._statusFlags??0,value:n._value,pending:n._pendingValue===K.NOT_PENDING?undefined:n._pendingValue,
      first:id(n._firstChild),next:id(n._nextSibling),prev:id(n._prevSibling),deps:edge(n._deps),tail:edge(n._depsTail),subs:edge(n._subs),subsTail:edge(n._subsTail),disposal:n._disposal?[3]:[]})),
      links:links.slice(1).map(l=>({dep:id(l._dep),sub:id(l._sub),nextDep:edge(l._nextDep),prevSub:edge(l._prevSub),nextSub:edge(l._nextSub),gen:l._gen})),
      events,dormant:[...S.dormantNodes].map(id),pending:S.probePending.map(id),scheduled:S.probeScheduled,error};
  }
  let count=0;
  for(const op of [0,1,2,3])for(const auto of [false,true])for(const flags of [0,K.REACTIVE_ZOMBIE,K.REACTIVE_DISPOSED])for(const pending of [false,true])for(const hook of [0,1,2]){
    assert.deepEqual(actual(B.fixture(op,auto,flags,pending,hook)),reference(op,auto,flags,pending,hook),JSON.stringify({op,auto,flags,pending,hook}));count++;
  }
  console.log(`${count} graph-state comparisons match TS detachment, last-subscriber hooks, dormancy guards, callback writes and partial state after throws.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
