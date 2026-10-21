// Finite public/canonical/native controls for the scalar-memo family.
// The quantified constructor/setter/drain proofs are checked separately.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {setImmediate} from 'node:timers/promises';
import {SolidRuntime} from '../host/solid.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-memo-controls-'));
try{
 let sourceRoot=root;
 if(process.env.BEND_EMIT_FILE){
  sourceRoot=dir;
  for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(path.dirname(process.env.BEND_EMIT_FILE),name),path.join(dir,name),{recursive:true});
  fs.cpSync(path.join(root,'proof'),path.join(dir,'proof'),{recursive:true});
 }
 const modules={};
 for(const [name,file]of [['D','memo-driver'],['M','memo-states'],['I','memo-initial-driver'],['G','memo-initial-data'],['J','memo-general-driver'],['K','memo-general-setter-data']]){
  const output=path.join(dir,file+'.mjs'),built=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(sourceRoot,'proof',file+'.bend'),'-o',output],{cwd:root,encoding:'utf8'});
  assert.equal(built.status,0,built.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const {D,M,I,G,J,K}=modules,values=[0,1,2,17,255,65535,2**32+3,2**48-2];
 for(const next of values){
  const S=await import('../build/solid.mjs?memo-proof-control='+next),s=new SolidRuntime({module:S});
  try{
   const before=D.before(next);assert.deepEqual(before,M.state_0(next),'Bend constructor/setter boundary at '+next);
   const after=D.view(D.flush(40,before.world));assert.deepEqual(after,D.expected(next),'specified arena drain at '+next);
   s.signal('value',0,{equals:false});s.memo('derived',{add:[{read:'value'},{lit:1}]},{equals:false});
   s.set('value',next);assert.equal(s.read('value'),0);assert.equal(s.read('derived'),1);
   s.flush();assert.equal(s.read('value'),next);assert.equal(s.read('derived'),next+1);
   assert.deepEqual([after.source.n,after.memo.n],[next,next+1]);
  }finally{s.attempt('dispose');s.attempt('flush');await setImmediate();}
 }
 for(const initial of values){
  const S=await import('../build/solid.mjs?memo-initial-control='+initial),s=new SolidRuntime({module:S});
  try{
   const world=I.construct(initial,14);assert.deepEqual(world,G.finished(initial),'general constructor arena at '+initial);
   s.signal('value',initial,{equals:false});s.memo('derived',{add:[{read:'value'},{lit:1}]},{equals:false});
   assert.deepEqual(D.view(world),D.expected(initial));assert.equal(s.read('value'),initial);assert.equal(s.read('derived'),initial+1);
  }finally{s.attempt('dispose');s.attempt('flush');await setImmediate();}
 }
 for(const initial of values)for(const next of values){
  const S=await import('../build/solid.mjs?memo-general-control='+initial+'-'+next),s=new SolidRuntime({module:S});
  try{
   const world=J.constructSet(initial,next,(initial+next)%2?14:256);
   assert.deepEqual(world,K.scheduled(initial,next),'public general constructor/setter arena '+initial+'/'+next);
   const after=D.view(D.flush(40,world));assert.deepEqual(after,D.expected(next),'general complete drain '+initial+'/'+next);
   s.signal('value',initial,{equals:false});s.memo('derived',{add:[{read:'value'},{lit:1}]},{equals:false});
   s.set('value',next);assert.equal(s.read('value'),initial);assert.equal(s.read('derived'),initial+1);
   s.flush();assert.equal(s.read('value'),next);assert.equal(s.read('derived'),next+1);
  }finally{s.attempt('dispose');s.attempt('flush');await setImmediate();}
 }
 console.log('8 fixed-initial constructor/setter, 8 general-initial constructor and 64 general constructor/setter/drain controls match canonical arenas and pinned Solid values; the quantified properties are independently kernel-checked.');
}finally{fs.rmSync(dir,{recursive:true,force:true});}
