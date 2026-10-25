// Typed constructor-to-notification controls. Equality evidence lives in Bend;
// JS provides represented data and independently calls the actual local helper.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-notification-carrier-'));
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/pending-notification-fixture.bend'],['status','runtime/status.bend'],['pending','runtime/pending-state.bend']]){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const bundled=await build({stdin:{contents:`export {computed,ext,setContextInternal} from './core/core.ts';export {notifyStatus} from './core/async.ts';export {NotReadyError} from './core/error.ts';export * as K from './core/constants.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}});
 const native=path.join(dir,'native.mjs');fs.writeFileSync(native,bundled.outputFiles[0].text);const S=await import(pathToFileURL(native));
 const F=modules.fixture,A=modules.status,P=modules.pending,b=new BendRuntime(),zero=encodeList([]),blank=list(F.before(zero,b.encode(undefined),zero,zero).extensions)[0];
 const observe=w=>({values:list(w.nodes).map(n=>n.value),tree:w.tree,events:w.events});
 let cases=0;
 const incoming=[['IncomingReady',0],['IncomingUninitialized',4],['IncomingNeverValued',8],['IncomingPending',1],['IncomingPendingUninitialized',5]];
 for(const [tag,flags]of incoming)for(const size of [0,2,9])for(const extCount of [0,2])for(const setCount of [0,3])for(const serial of [0,19]){
  const payload=[undefined,null,false,0,-0,NaN,'cached',{ref:2}][cases%8],values=encodeList(Array.from({length:size},(_,i)=>b.encode(i%2?payload:i))),extensions=encodeList(Array.from({length:extCount},()=>blank)),sets=encodeList(Array.from({length:setCount},(_,i)=>encodeList([31+i]))),args=[values,b.encode(payload),extensions,sets,{$:tag}],before=F.initial(...args),node=F.leaf(...args.slice(0,4)),source=F.root(values),error={$:'NotReadyFailure',identity:serial,source};
  const actual=F.after(...args,serial);assert.deepEqual(actual,A.storeStatus(before,node,1,error));assert.deepEqual(observe(actual),observe(before));
  const certificate=F.ready(...args,serial);assert.equal(certificate.$,'Single');assert.equal(P.hasSource(actual,node,source),true);
  const n=list(actual.nodes)[node],x=list(actual.extensions)[n.x];assert.deepEqual(x.error,error);assert.equal(n.status,1|((flags&8)?4:(flags&4)));
  assert.equal(list(actual.extensions).length,2+extCount);assert.equal(list(actual.pendingSets).length,2+setCount);assert.deepEqual(list(list(actual.pendingSets).at(-1)),[source]);
  S.setContextInternal(null);const nativeSource=S.computed(()=>payload,{lazy:true}),nativeNode=S.computed(()=>payload,{lazy:true}),nativeError=new S.NotReadyError(nativeSource);nativeNode._statusFlags=flags;S.notifyStatus(nativeNode,S.K.STATUS_PENDING,nativeError);
  assert.equal(nativeNode._statusFlags,n.status);assert.equal(nativeNode._x._error,nativeError);assert.deepEqual([...nativeNode._x._pendingSources],[nativeSource]);
  cases++;
 }
 console.log(`${cases} typed actual memo/render construction and local pending-notification cases preserve committed content, exact error identity and singleton source membership; paired native leaf-memo notifications match the status/error/source result. No propagation/flush or callback-evaluation theorem is claimed.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
