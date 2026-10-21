// Finite public/canonical/native graph controls. The independent theorem starts
// at its explicit staged arena; these controls do not prove the setter bridge.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-chain-controls-'));
try{
 let sourceRoot=root;
 if(process.env.BEND_EMIT_FILE){
  sourceRoot=dir;
  for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(path.dirname(process.env.BEND_EMIT_FILE),name),path.join(dir,name),{recursive:true});
  fs.cpSync(path.join(root,'proof'),path.join(dir,'proof'),{recursive:true});
 }
 const modules={};
 for(const [name,file]of [['D','chain-driver'],['M','chain-states']]){
  const output=path.join(dir,file+'.mjs'),built=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(sourceRoot,'proof',file+'.bend'),'-o',output],{cwd:root,encoding:'utf8'});
  assert.equal(built.status,0,built.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const {D,M}=modules;
 for(const next of [0,1,2,17,255,65535,2**32+3,2**46-2]){
  const S=await import('../build/solid.mjs?chain-control='+next),b=new BendRuntime(),s=new SolidRuntime({module:S});
  try{
   for(const r of [b,s]){
    r.signal('source',0,false);
    r.memo('first',{add:[{read:'source'},{lit:1}]},{equals:false});
    r.memo('second',{mul:[{read:'first'},{lit:2}]},{equals:false});
    r.effect('view',{add:[{read:'second'},{read:'source'}]},{target:2});
   }
   assert.deepEqual(b.screen(),s.screen());assert.deepEqual(b.trace(),s.trace());
   assert.equal(b.screen(),2,'constructor applies the initial render');
   assert.deepEqual(D.base(),M.origin(),'actual constructor reaches the canonical origin');
   for(const r of [b,s])assert.doesNotThrow(()=>r.set('source',next),'valid graph write');
   assert.deepEqual(b.world,M.state_0(next).world,'public setter reaches the specified staged arena');
   assert.deepEqual(D.before(next),M.state_0(next),'driver constructor/setter reaches canonical staging');
   assert.deepEqual(b.screen(),s.screen());assert.equal(b.screen(),2,'write stays staged before flush');
   const canonical=D.flush(95,D.before(next).world);
   for(const r of [b,s])assert.doesNotThrow(()=>r.flush(),'valid graph drain');
   assert.deepEqual(canonical,M.finalWorld(next),'95-step canonical drain');
   assert.deepEqual(b.world,canonical,'ordinary public flush reaches the same whole World');
   assert.deepEqual(b.screen(),s.screen());assert.deepEqual(b.trace(),s.trace());
   assert.equal(b.screen(),(next+1)*2+next);
   assert.deepEqual(b.trace().filter(e=>e[0]==='apply').map(e=>e[2]),[2,(next+1)*2+next],'one application per update, including equal-value input');
  }finally{for(const r of [b,s]){r.attempt('dispose');r.attempt('flush');}await setImmediate();}
 }
 console.log('8 finite two-memo/render controls match actual constructors/setters, complete canonical Worlds, native traces and exactly one final render application per update; the public setter bridge remains a separate open proof.');
}finally{fs.rmSync(dir,{recursive:true,force:true});}
