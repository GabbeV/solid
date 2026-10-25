// All status words survive actual source registration, including fresh
// extension allocation, duplicate insertion and a separately present source.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-source-status-'));
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/pending-notification-fixture.bend'],['status','proof/node-status-frame.bend'],['pending','runtime/pending-state.bend']]){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const bundled=await build({stdin:{contents:`export {computed,ext,setContextInternal} from './core/core.ts';export {addPendingSource} from './core/async.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}}),native=path.join(dir,'native.mjs');fs.writeFileSync(native,bundled.outputFiles[0].text);const S=await import(pathToFileURL(native));
 const F=modules.fixture,Frame=modules.status,P=modules.pending,b=new BendRuntime(),zero=encodeList([]);let cases=0;
 for(const flags of [0,1,2,4,5,8,10,15,0xffffffff])for(const size of [0,2,7])for(const phase of ['fresh','allocated','duplicate','other']){
  const payload=cases%2?'cached':NaN,values=encodeList(Array.from({length:size},(_,i)=>b.encode(i))),args=[values,b.encode(payload),zero,zero];let w=F.before(...args);const node=F.leaf(...args),source=F.root(values),nodes=list(w.nodes).map((n,i)=>({...n,status:i===node?flags:(i*13)}));w={...w,nodes:encodeList(nodes)};
  S.setContextInternal(null);const nativeNode=S.computed(()=>payload,{lazy:true}),nativeSource=S.computed(()=>0,{lazy:true});nativeNode._statusFlags=flags;
  if(phase==='allocated'){w=P.removePendingSource(P.addPendingSource(w,node,source).left,node,source).left;S.ext(nativeNode);}
  if(phase==='duplicate'){w=P.addPendingSource(w,node,source).left;S.addPendingSource(nativeNode,nativeSource);}
  if(phase==='other'){w=P.addPendingSource(w,node,node).left;S.addPendingSource(nativeNode,nativeNode);}
  const before=Frame.observe(w),pair=P.addPendingSource(w,node,source),inserted=S.addPendingSource(nativeNode,nativeSource);
  assert.deepEqual(Frame.observe(pair.left),before);assert.equal(list(pair.left.nodes)[node].status,flags);assert.equal(nativeNode._statusFlags,flags);assert.equal(pair.right,inserted);assert.equal(pair.right,phase!=='duplicate');
  cases++;
 }
 console.log(`${cases} source-registration status-frame controls preserve all represented node status words across fresh/allocated/duplicate/other-source branches, matching native selected status and insertion results. The generalized frame is kernel checked separately.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
