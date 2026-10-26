// Actual leaf notifier completion controls, including consistent incoming error
// states. Constructor controls stop before callback evaluation.
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
 for(const [name,input]of [['fixture','proof/memo-render-fixture.bend'],['construct','runtime/construct-state.bend'],['status','runtime/status.bend'],['pending','runtime/pending-state.bend'],['extension','runtime/extension.bend'],['base','representation/base.bend']]){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const bundled=await build({stdin:{contents:`export {computed,ext,setContextInternal} from './core/core.ts';export {notifyStatus} from './core/async.ts';export {NotReadyError} from './core/error.ts';export * as K from './core/constants.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}});
 const native=path.join(dir,'native.mjs');fs.writeFileSync(native,bundled.outputFiles[0].text);const S=await import(pathToFileURL(native));
 const F=modules.fixture,C=modules.construct,A=modules.status,P=modules.pending,E=modules.extension,B=modules.base,b=new BendRuntime();
 const observe=w=>({values:list(w.nodes).map(n=>n.value),tree:w.tree,events:w.events});let cases=0;
 for(const flags of [...Array(16).keys(),0x8000000d,0x8000000f])for(const size of [0,2,7])for(const phase of ['fresh','allocated','duplicate']){
  const payload=[undefined,null,false,0,-0,NaN,'cached',{ref:2}][cases%8],values=encodeList(Array.from({length:size},(_,i)=>b.encode(i)));let w=F.input(values),source=list(w.nodes).length;w=C.computed(w,{$:'Literal',value:b.encode(payload)},C.defaults(),0);const node=list(w.nodes).length;w=C.computed(w,{$:'Literal',value:b.encode(payload)},C.defaults(),0);
  w={...w,nodes:encodeList(list(w.nodes).map((n,i)=>({...n,status:i===node?flags:n.status})))};
  const wasError=Boolean(flags&2),oldError=b.encode('old error '+cases);
  if(wasError){w=E.ext(w,node);const ext=B.extension(w,node);w=B.store_extension(w,node,{...ext,error:oldError});}
  if(phase==='allocated')w=P.removePendingSource(P.addPendingSource(w,node,source).left,node,source).left;
  if(phase==='duplicate')w=P.addPendingSource(w,node,source).left;
  const error={$:'NotReadyFailure',identity:cases+1,source},stored=A.storeStatus(w,node,1,error),actual=A.notifyStatusWith(w,node,1,error);
  assert.deepEqual(actual,stored);assert.deepEqual(observe(actual),observe(w));assert.equal(actual.fault.$,'Healthy');assert.equal(P.hasSource(actual,node,source),true);if(wasError)assert.deepEqual(B.extension(actual,node).shownError,oldError);
  const initial={$:'Machine',world:w,tasks:encodeList([{$:'Notify',id:node,status:1,error}]),visited:encodeList([71,72]),scheduled:true};
  const first=A.dispatch(initial.world,initial.tasks,initial.visited,initial.scheduled);assert.deepEqual(first.world,stored);assert.deepEqual(list(first.tasks),[{$:'Propagate',edge:0,status:1,error}]);assert.deepEqual(first.visited,initial.visited);assert.equal(first.scheduled,true);
  const second=A.dispatch(first.world,first.tasks,first.visited,first.scheduled);assert.deepEqual(second.world,stored);assert.deepEqual(list(second.tasks),[]);assert.deepEqual(second.visited,initial.visited);assert.equal(second.scheduled,true);
  assert.deepEqual(A.run(2,initial),stored);assert.equal(A.run(1,initial).fault.$,'Exhausted');
  S.setContextInternal(null);const nativeSource=S.computed(()=>payload,{lazy:true}),nativeNode=S.computed(()=>payload,{lazy:true}),nativeError=new S.NotReadyError(nativeSource);nativeNode._statusFlags=flags;const nativeOldError=new Error('old error '+cases);if(wasError)S.ext(nativeNode)._error=nativeOldError;S.notifyStatus(nativeNode,S.K.STATUS_PENDING,nativeError);
  assert.equal(nativeNode._statusFlags,list(actual.nodes)[node].status);assert.equal(nativeNode._x._error,nativeError);if(wasError)assert.equal(nativeNode._x._shownError,nativeOldError);assert.deepEqual([...nativeNode._x._pendingSources],[nativeSource]);cases++;
 }
 console.log(`${cases} actual raw memo-construction/notifier controls match local stores and native leaf notification, including retained shown-error identity; two real dispatcher steps preserve visited/scheduled locals, and one-step exhaustion remains explicit. Public callback reachability and general propagation are separate.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
