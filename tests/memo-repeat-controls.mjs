// Finite correspondence controls for the separate quantified two-update theorem.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-memo-repeat-controls-'));
try{
 const modules={};
 for(const [name,file] of [['D','memo-repeat-driver'],['M','memo-repeat-states'],['V','memo-driver']]){
  const output=path.join(dir,file+'.mjs');
  const built=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','proof/'+file+'.bend','-o',output],{cwd:root,encoding:'utf8'});
  assert.equal(built.status,0,built.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const {D,M,V}=modules,values=[0,1,2,17,255,65535,2**32+3,2**48-2];
 for(const first of values)for(const second of values){
  const before=D.before(first,second);assert.deepEqual(before,M.state_0(first,second),'actual first update and second setter');
  const world=D.program(first,second,(first+second)%3,(first*3+second)%5);
  assert.deepEqual(world,M.finalWorld(first,second),'complete final World across two actual updates');
  assert.deepEqual(V.view(world),V.expected(second));
  const S=await import('../build/solid.mjs?memo-repeat-control='+first+'-'+second);
  let read,set,derived;
  const dispose=S.createRoot(dispose=>{
   [read,set]=S.createSignal(0,{equals:false});derived=S.createMemo(()=>read()+1,{equals:false});return dispose;
  });
  try{
   set(first);assert.deepEqual([read(),derived()],[0,1]);S.flush();assert.deepEqual([read(),derived()],[first,first+1]);
   set(second);assert.deepEqual([read(),derived()],[first,first+1]);S.flush();assert.deepEqual([read(),derived()],[second,second+1]);
   assert.deepEqual([V.view(world).source.n,V.view(world).memo.n],[read(),derived()]);
  }finally{dispose();S.flush();}
 }
 console.log('64 finite two-update scalar-memo controls match actual public constructors/setters/flushes, canonical final Worlds and native Solid values.');
}finally{fs.rmSync(dir,{recursive:true,force:true});}
