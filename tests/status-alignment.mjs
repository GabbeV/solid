import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-status-probe-'));
try{
  let probe='tests/probes/status.bend';
  if(process.env.BEND_EMIT_FILE){
    const changed=path.dirname(process.env.BEND_EMIT_FILE);
    for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(changed,name),path.join(dir,name),{recursive:true});
    fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});
    probe=path.join(dir,'tests/probes/status.bend');fs.copyFileSync(path.join(root,'tests/probes/status.bend'),probe);
  }
  const emitted=path.join(dir,'status.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',probe,'-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';export * as K from './core/constants.ts';
    export {computed,createEffectNode,setContextInternal,ext} from './core/core.ts';
    export {createOwner} from './core/owner.ts';export {link} from './core/graph.ts';export {clearStatus,notifyStatus} from './core/async.ts';export {StatusError} from './core/error.ts';
    export {clock,dirtyQueue,globalQueue,probeReset,probePending,probeScheduled,probeHalted,probeHaltNotified} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'status-state',setup(b){b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
      export {pendingNodes as probePending,scheduled as probeScheduled,halted as probeHalted,haltNotified as probeHaltNotified};
      export function probeReset(){guessing=false;clock=5;notifyEpoch=0;scheduled=false;syncDepth=1;pendingNodes.length=heldTrims.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;halted=haltNotified=false;}
    `}));}
  }]});
  const refFile=path.join(dir,'solid.mjs');fs.writeFileSync(refFile,bundle.outputFiles[0].text);const S=await import(pathToFileURL(refFile)),K=S.K;
  const list=xs=>{const a=[];while('head' in xs){a.push(xs.head);xs=xs.tail;}return a;},consoleError=console.error;
  function actual(w){const errors=new Map(),extensions=list(w.extensions),decode=v=>{
    if('identity'in v){if(!errors.has(v.identity))errors.set(v.identity,errors.size+1);return {identity:errors.get(v.identity),source:v.source,cause:decode(v.cause)};}
    if('n'in v)return v.n;if('b'in v)return v.b;return v.$==='Null'?null:undefined;
  };return {nodes:list(w.nodes).slice(1).map(n=>({flags:n.flags,config:n.config,status:n.status,time:n.time,modified:n.modified,
    error:decode(extensions[n.x]?.error??{}),blocked:'value'in(extensions[n.x]?.blocked??{})?decode(extensions[n.x].blocked.value):undefined,sources:!!extensions[n.x]?.pendingSources,
    x:!!n.x,next:n.nextHeap,prev:n.prevHeap})),
    pending:list(w.pendingNodes),user:list(w.userQueue).map(e=>e.node),render:list(w.renderQueue),buckets:list(w.buckets),min:w.minimum,max:w.maximum,marked:w.marked,scheduled:w.scheduled,
    halted:w.halted,haltNotified:w.haltNotified,exception:'cause'in w.fault?decode(w.fault.cause):undefined,reports:list(w.reports).map(r=>[r.kind,'value'in r.cause?decode(r.cause.value):undefined])};}
  function reference(op,kind,status,config,code,sources){
    S.probeReset();S.setContextInternal(null);const r=S.createOwner();S.setContextInternal(r);
    const n=kind===0?S.computed(()=>7,{lazy:true}):S.createEffectNode(()=>7,()=>{},undefined,kind===1?K.EFFECT_USER:kind===3?K.EFFECT_TRACKED:K.EFFECT_RENDER,{lazy:true});
    const a=S.computed(()=>11,{lazy:true}),b=S.computed(()=>13,{lazy:true});S.setContextInternal(null);
    const nodes=[null,r,n,a,b],id=n=>n?nodes.indexOf(n):0,errors=new Map(),reports=[];
    const value=[undefined,null,false,42][code];S.link(n,a);S.link(a,b);S.link(n,b);n._statusFlags=status;a._config=config;
    Object.assign(S.ext(n),{_error:value,_blocked:true,_pendingSources:sources?new Set([n]):undefined});let exception;
    const decode=e=>{if(e instanceof S.StatusError){if(!errors.has(e))errors.set(e,errors.size+1);return {identity:errors.get(e),source:id(e.source),cause:decode(e.cause)};}return e;};
    console.error=(...args)=>reports.push([0,args[1]]);
    try{op>=2?S.notifyStatus(n,op===4?K.STATUS_PENDING:K.STATUS_ERROR,value):S.clearStatus(n,op===1);}catch(e){exception=e;}finally{console.error=consoleError;}
    return {nodes:nodes.slice(1).map(n=>({flags:n._flags??0,config:n._config,status:n._statusFlags??0,time:n._time??0,modified:n._modified??false,error:decode(n._x?._error),blocked:n._x?._blocked,sources:!!n._x?._pendingSources,
      x:!!n._x,next:id(n._nextHeap),prev:id(n._prevHeap)})),pending:S.probePending.map(id),user:S.globalQueue._queues[1].map(()=>2),render:S.globalQueue._queues[0].map(()=>2),
      buckets:Array.from({length:Math.max(1,S.dirtyQueue._heap.length)},(_,i)=>id(S.dirtyQueue._heap[i])),min:S.dirtyQueue._min,max:S.dirtyQueue._max,marked:S.dirtyQueue._marked,scheduled:S.probeScheduled,
      halted:S.probeHalted,haltNotified:S.probeHaltNotified,exception:decode(exception),reports:reports.map(([kind,cause])=>[kind,decode(cause)])};
  }
  let count=0;
  for(const op of [0,1,2,4])for(const kind of [0,1,2,3])for(let status=0;status<16;status++)for(const config of [0,K.CONFIG_REDERIVE,K.CONFIG_VERDICT])for(let code=0;code<4;code++)for(const sources of [false,true]){
    assert.deepEqual(actual(B.run(op,kind,status,config,code,sources)),reference(op,kind,status,config,code,sources),JSON.stringify({op,kind,status,config,code,sources}));count++;
  }
  console.log(`${count} status-state comparisons, including all STATUS_NO_VALUE bit combinations, match TS clearStatus/error notification, wrapper sharing, diamond propagation, rederive/verdict branches, effect queues, node-owned forwarding and halt partial states. Tracked effects retain their distinct pending/error notifier branches.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
