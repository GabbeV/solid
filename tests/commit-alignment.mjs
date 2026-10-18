// Compare the actual pinned helper, not a second implementation. The generated
// internal states probe individual branches; they do not establish full async,
// held-frame, error, or transaction execution coverage.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-commit-probe-'));
try {
  const emitted=path.join(dir,'commit.mjs');
  const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/commit.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);
  const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';
    export * as K from './core/constants.ts';
    export {link} from './core/graph.ts';
    export {ext} from './core/core.ts';
    export {commitPendingNode,queuePendingNode,globalQueue,probeCommitPendingNodes,probePendingNodes,probeReset,probeScheduled} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'private-scheduler-probe',setup(b) {b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
      export {commitPendingNodes as probeCommitPendingNodes, pendingNodes as probePendingNodes, scheduled as probeScheduled};
      export function probeReset() { pendingNodes.length=0; globalQueue._queues=[[],[]]; globalQueue._running=true; scheduled=false; }
    `}));}
  }]});
  const S=await import('data:text/javascript;base64,'+Buffer.from(bundle.outputFiles[0].text).toString('base64'));
  const K=S.K;
  function list(xs) {const a=[];while('head' in xs){a.push(xs.head);xs=xs.tail;}return a;}
  const numeric=v=>Object.hasOwn(v,'n')?v.n:undefined;
  const tags=B.withExtension(0,0,0,0,0,false,false,false,2);
  const nullTag=list(tags.extensions)[1].error.$;
  function payload(v) {return v.$===nullTag?null:Object.hasOwn(v,'b')?v.b:numeric(v);}
  function bendExtension(w,n) {
    if(!n.x)return null;
    const x=list(w.extensions)[n.x];
    return {error:payload(x.error),reask:x.reask,flushed:Object.hasOwn(x.flushed,'value'),flushedValue:numeric(x.flushed.value??{}),
      flushedAt:x.flushedAt.value??-1,shownError:payload(x.shownError)};
  }
  function sourceExtension(x) {
    return x?{error:x._error,reask:x._reask,flushed:x._flushed!==K.NOT_PENDING,flushedValue:x._flushed===K.NOT_PENDING?undefined:x._flushed,
      flushedAt:x._flushedAt,shownError:x._shownError}:null;
  }
  function bendState(w) {
    const ns=list(w.nodes),n=ns[2],dep=ns[3];
    return {config:n.config,flags:n.flags,status:n.status,loading:n.loading,value:numeric(n.value),
      staging:Object.hasOwn(n.pending,'value'),pending:numeric(n.pending.value??{}),modified:n.modified,
      deps:n.deps!==0,subs:dep.subs!==0,render:list(w.renderQueue).length,user:list(w.userQueue).length,
      scheduled:w.scheduled,intake:list(w.pendingNodes).length,extension:bendExtension(w,n)};
  }
  function reference(k,config,flags,status,stage,loading,modified,sweep,mode=0) {
    S.probeReset();
    // A source-shaped node with no cold extension and a plain source signal.
    const n={_fn:k?()=>{}:undefined,_type:k>1?k-1:0,_config:config,_flags:flags,_statusFlags:status,_loading:loading,
      _value:11,_pendingValue:stage===0?K.NOT_PENDING:stage===1?23:undefined,_x:null,_modified:modified,
      _deps:null,_depsTail:null,_depGen:0};
    const dep={_config:0,_x:null,_subs:null,_subsTail:null};
    if(k){S.link(dep,n);n._depsTail=null;}
    if(mode) {
      const x=S.ext(n);
      if(mode===2)x._error=null;
      if(mode===3)x._error=false;
      if(mode===4)x._error=23;
      if(mode===5){x._reask=true;x._flushed=19;x._flushedAt=0;x._shownError=29;}
    }
    S.queuePendingNode(n);
    if(sweep)S.probeCommitPendingNodes();else S.commitPendingNode(n);
    return {config:n._config,flags:n._flags,status:n._statusFlags,loading:n._loading,value:n._value,
      staging:n._pendingValue!==K.NOT_PENDING,pending:n._pendingValue===K.NOT_PENDING?undefined:n._pendingValue,modified:n._modified,
      deps:n._deps!==null,subs:dep._subs!==null,render:S.globalQueue._queues[0].length,user:S.globalQueue._queues[1].length,
      scheduled:S.probeScheduled,intake:S.probePendingNodes.length,extension:sourceExtension(n._x)};
  }
  const configs=[0,K.CONFIG_STAGED,K.CONFIG_HELD,K.CONFIG_HELD_FRAME,K.CONFIG_INPUTS_PUBLISHED,
    K.CONFIG_OVERRIDE,K.CONFIG_STAGED|K.CONFIG_HELD|K.CONFIG_HELD_FRAME|K.CONFIG_INPUTS_PUBLISHED,
    K.CONFIG_SYNC|K.CONFIG_TRANSPARENT|K.CONFIG_STAGED|K.CONFIG_HELD_FRAME];
  let checked=0;
  for(const k of [0,1,2,3])for(const config of configs)for(const status of [0,K.STATUS_UNINITIALIZED,K.STATUS_PENDING|K.STATUS_UNINITIALIZED,K.STATUS_ERROR|K.STATUS_UNINITIALIZED])
    for(const stage of [0,1,2])for(const sweep of [false,true]) {
      const args=[k,config,K.REACTIVE_MANUAL_WRITE|K.REACTIVE_STAGED_READ,status,stage,true,false,sweep];
      assert.deepEqual(bendState(B.fixture(...args)),reference(...args),JSON.stringify({k,config,status,stage,sweep}));
      checked++;
      for(const mode of [1,2,3,4,5]) {
        assert.deepEqual(bendState(B.withExtension(...args,mode)),reference(...args,mode),JSON.stringify({k,config,status,stage,sweep,mode}));checked++;
      }
    }
  // A staged error is explicitly outside this port's supported outcomes.
  const refused=B.fixture(1,K.CONFIG_STAGED_ERROR,0,0,1,false,false,false);
  assert.equal(refused.fault.reason,2,'staged error must not masquerade as a successful value commit');
  assert.equal(B.withExtension(1,0,0,0,1,false,false,false,6).fault.reason,5,'parked teardown must refuse until translated');
  console.log(`${checked} commit-state comparisons match pinned TS, including undefined staging, signal/computed separation, flight bits, staged effect queues, stale-tail error gates, cold metadata and held/override intake guards. Staged-error execution remains unsupported.`);
} finally {fs.rmSync(dir,{recursive:true,force:true});}
