import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-watch-probe-'));
try{
  const emitted=path.join(dir,'watch.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/watch.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';export * as K from './core/constants.ts';export {watch} from './signals.ts';
    export {setContextInternal} from './core/core.ts';export {createOwner} from './core/owner.ts';export {NotReadyError,StatusError} from './core/error.ts';
    export {newTransaction,probeReset,probeJoin} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'watch-state',setup(b){
      b.onLoad({filter:/[/\\]signals\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {watch};'}));
      b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
        export function probeJoin(f,p){flushTransaction=f;passTx=p;}
        export function probeReset(){guessing=false;clock=5;notifyEpoch=0;scheduled=false;syncDepth=1;pendingNodes.length=heldTrims.length=deferredZombies.length=transactions.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;halted=haltNotified=false;passTx=flushTransaction=passLane=judge=null;}
      `}));
    }
  }]});
  const refFile=path.join(dir,'solid.mjs');fs.writeFileSync(refFile,bundle.outputFiles[0].text);const S=await import(pathToFileURL(refFile)),K=S.K;
  const list=xs=>{const a=[];while('head'in xs){a.push(xs.head);xs=xs.tail;}return a;};
  const value=v=>v?.$==='Number'?v.n:v?.$==='Boolean'?v.b:v?.$==='NotReadyFailure'?{pending:2}:undefined;
  function actual(m){const w=m.world;return {flags:list(w.nodes)[2].flags,reruns:list(w.txArena).slice(1).map(t=>list(t.reruns)),jobs:list(w.hostJobs).map(j=>[j.rejected?'error':'value',value(j.value)]),threw:w.fault.$!=='Healthy',exception:value(w.fault.cause),returned:list(m.values).length>0};}
  function reference(own,flush,pass,redirect,flags,cause){
    S.probeReset();S.setContextInternal(null);const root=S.createOwner(),txs=[null,S.newTransaction(false),S.newTransaction(false),S.newTransaction(false)];
    if(redirect===1||redirect===3)txs[1]._into=txs[2];if(redirect===2||redirect===3)txs[2]._into=txs[3];
    const jobs=[],queue=[],original=globalThis.queueMicrotask;globalThis.queueMicrotask=fn=>queue.push(fn);let n,active=false,threw=false,exception;
    try{
      S.setContextInternal(root);S.watch(()=>{n=S.getOwner();if(!active)return;const values=[23,99,new S.StatusError(n,99),new S.NotReadyError(n),undefined,false];if(cause)throw values[cause];return values[0];},v=>jobs.push(['value',v]),e=>jobs.push(['error',e]),0,undefined,txs[own]);
      queue.length=0;active=true;n._flags=flags;S.probeJoin(txs[flush],txs[pass]);S.setContextInternal(n);
      try{n._fn();}catch(e){threw=true;exception=e;}
      for(const fn of queue)fn();
    }finally{globalThis.queueMicrotask=original;S.setContextInternal(null);}
    return {flags:n._flags,reruns:txs.slice(1).map(t=>t._reruns.map(()=>2)),jobs,threw,exception:exception instanceof S.NotReadyError?{pending:2}:exception,returned:!threw};
  }
  let count=0;
  for(let own=0;own<4;own++)for(let flush=0;flush<4;flush++)for(let pass=0;pass<4;pass++)for(let redirect=0;redirect<4;redirect++)for(const flags of [0,K.REACTIVE_JOINED,K.REACTIVE_FRAME_READ,K.REACTIVE_JOINED|K.REACTIVE_FRAME_READ])for(let cause=0;cause<6;cause++){
    const args=[own,flush,pass,redirect,flags,cause];assert.deepEqual(actual(B.fixture(...args)),reference(...args),JSON.stringify(args));count++;
  }
  console.log(`${count} watch-body comparisons match actual TS closure calls: own/foreign transaction delivery gates, redirects, rerun deduplication, status unwrapping and NotReady rethrows.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
