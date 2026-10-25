// Private status classification controls. Generalized equality evidence lives in
// Bend; these samples compare actual local stores to native leaf notification.
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
 const F=modules.fixture,A=modules.status,P=modules.pending,b=new BendRuntime(),zero=encodeList([]);
 const observe=w=>({values:list(w.nodes).map(n=>n.value),tree:w.tree,events:w.events});
 let cases=0;
 const words=[...Array.from({length:16},(_,i)=>i),0x80000000,0x8000000e,0x7fffffff,0xffffffff];
 for(const flags of words)for(const size of [0,2,7])for(const phase of ['fresh','allocated','duplicate','other']){
  const payload=[undefined,null,false,0,-0,NaN,'cached',{ref:2}][cases%8],values=encodeList(Array.from({length:size},(_,i)=>b.encode(i))),args=[values,b.encode(payload),zero,zero];let before=F.before(...args);const node=F.leaf(...args),source=F.root(values),serial=cases+1,error={$:'NotReadyFailure',identity:serial,source};
  before={...before,nodes:encodeList(list(before.nodes).map((n,i)=>({...n,status:i===node?flags:n.status})))};
  S.setContextInternal(null);const nativeSource=S.computed(()=>payload,{lazy:true}),nativeNode=S.computed(()=>payload,{lazy:true}),nativeError=new S.NotReadyError(nativeSource);nativeNode._statusFlags=flags;
  // A real native error status owns an extension; manually setting only its
  // flags creates an invalid private state. Preserve that native invariant.
  if(flags&2){before=P.removePendingSource(P.addPendingSource(before,node,source).left,node,source).left;S.ext(nativeNode)._error='previous error';const ns=list(before.nodes),xs=list(before.extensions);xs[ns[node].x]={...xs[ns[node].x],error:b.encode('previous error')};before={...before,extensions:encodeList(xs)};}
  if(phase==='allocated'){before=P.removePendingSource(P.addPendingSource(before,node,source).left,node,source).left;S.ext(nativeNode);}
  if(phase==='duplicate'){before=P.addPendingSource(before,node,source).left;S.ext(nativeNode)._pendingSources=new Set([nativeSource]);}
  if(phase==='other'){before=P.addPendingSource(before,node,node).left;S.ext(nativeNode)._pendingSources=new Set([nativeNode]);}
  const actual=A.storeStatus(before,node,1,error);S.notifyStatus(nativeNode,S.K.STATUS_PENDING,nativeError);
  const n=list(actual.nodes)[node];assert.equal(n.status,1|((flags&8)?4:(flags&4)));assert.equal(n.status&1,1);assert.equal(n.status&2,0);assert.equal(nativeNode._statusFlags,n.status);assert.deepEqual(observe(actual),observe(before));
  assert.deepEqual(list(actual.extensions)[n.x].error,error);assert.equal(nativeNode._x._error,nativeError);assert.equal(P.hasSource(actual,node,source),true);
  cases++;
 }
 console.log(`${cases} paired native/local pending-status controls cover every low status-bit combination, high bits, fresh/allocated/duplicate/other-source arenas and cached payloads. Only node validity is required by the generalized status-selection proof; these manually prepared private states do not establish public reachability or accessor readiness.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
