// Direct comparisons with the actual native tracked _run closure, not a copy.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-tracked-probe-'));
const list=xs=>{const out=[];while('head'in xs){out.push(xs.head);xs=xs.tail;}return out;};
try{
 const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(dir,name),{recursive:true});
 const fixture=path.join(dir,'tracked.bend');
 fs.writeFileSync(fixture,fs.readFileSync(path.join(root,'tests/probes/tracked.bend'),'utf8').replaceAll('../../runtime/','./runtime/').replaceAll('../../representation/','./representation/'));
 const emitted=path.join(dir,'tracked.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',fixture,'-o',emitted],{cwd:root,encoding:'utf8'});
 assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
 const bundled=await build({stdin:{contents:`export * from './index.ts';export {stale,staleValues} from './core/core.ts';export {REACTIVE_DISPOSED} from './core/constants.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}});
 const text=bundled.outputFiles[0].text;let count=0;
 for(const copies of [0,1,2,3])for(const modified of [false,true])for(const dead of [false,true])for(const stale of [false,true]){
  // Fresh native state per direct call sequence; no flush consumes its heap.
  const S=await import('data:text/javascript;base64,'+Buffer.from(text+'\n// fixture '+count).toString('base64'));
  let node,source,marker,rootNode,calls=0,seen=[];
  S.createRoot(()=>{
   rootNode=S.getOwner();const [x]=S.createSignal(7),[y,setY]=S.createSignal(0);
   source=Object.getOwnPropertySymbols(x).map(key=>x[key]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v);
   marker=Object.getOwnPropertySymbols(y).map(key=>y[key]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v);
   S.createTrackedEffect(()=>{calls++;seen.push(S.stale);setY(x());});node=rootNode._firstChild;
  });
  node._modified=modified;if(dead)node._flags|=S.REACTIVE_DISPOSED;
  S.staleValues(()=>{for(let i=0;i<copies;i++)node._run();},stale);
  const w=B.fixture(copies,modified,dead,stale),nodes=list(w.nodes),n=nodes[4],notPending=source._pendingValue;
  const val=x=>x.$==='Number'?x.n:undefined;
  const target=(n,v,pending)=>({flags:n.flags,config:n.config,status:n.status,time:n.time,gen:n.depGen,modified:n.modified,value:v,pending});
  assert.deepEqual(target(n,val(n.value),'value'in n.pending),target({flags:node._flags,config:node._config,status:node._statusFlags,time:node._time,depGen:node._depGen,modified:node._modified},node._value,node._pendingValue!==notPending));
  assert.equal(list(w.events).filter(e=>'id'in e&&!('value'in e)).length,calls,'duplicate queued runner is gated by modified');
  assert.deepEqual(seen,Array(calls).fill(true),'native callback runs under staleValues');
  assert.equal(w.stale,stale,'core returns to its incoming stale scope');
  assert.equal(S.stale,false,'outer native staleValues restores the caller');
  assert.equal(val(nodes[3].value),marker._value);assert.equal('value'in nodes[3].pending,marker._pendingValue!==notPending);
  if('value'in nodes[3].pending)assert.equal(val(nodes[3].pending.value),marker._pendingValue);
  count++;
 }
 console.log(`${count} actual tracked-run closure comparisons preserve duplicate-run gates, disposal, cleanup assignment, values and stale-scope restoration.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
