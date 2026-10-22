// Finite canonical/native checks supplement the all-natural kernel theorem.
import assert from 'node:assert/strict';import fs from 'node:fs';import os from 'node:os';import path from 'node:path';import {spawnSync} from 'node:child_process';import {fileURLToPath,pathToFileURL} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-affects-proof-'));
try{
 const from=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const p of['runtime','representation','observation'])fs.cpSync(path.join(from,p),path.join(dir,p),{recursive:true});fs.cpSync(path.join(root,'proof'),path.join(dir,'proof'),{recursive:true});
 const compile=async name=>{const out=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'proof',name+'.bend'),'-o',out],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stderr);return import(pathToFileURL(out));};
 const {default:D}=await compile('affects-driver'),{default:P}=await compile('affects-program');let count=0;
 for(const initial of[0,1,2,3,7,11,17,42,127,255,1024,2**20,2**32,2**39,2**40,2**48]){
  let m=D.before(initial);assert.deepEqual(m,P.state_0(initial));for(let i=0;i<51;i++){m=D.step(m);assert.deepEqual(m,P['state_'+(i+1)](initial),`canonical prefix ${i+1}`);}for(const fuel of[51,52,128])assert.deepEqual(D.run(fuel,initial),m);
  const S=await import(pathToFileURL(path.join(root,'build/solid.mjs'))+'?affects-control='+count);const [get]=S.createSignal(initial);S.affects(get);const before=S.isPending(get);S.flush();assert.deepEqual([before,S.isPending(get),get()],[true,false,initial]);
  assert.deepEqual(m.world.arrays,P.outputs(initial));assert.equal(m.world.activeMarks,0);assert.equal('head'in m.world.ambientMarks,false);assert.equal(m.world.fault.$,'Healthy');count++;
 }console.log(`${count} affects complete-program/native controls compare 51 canonical transitions and exact final Machines at three sufficient budgets; the all-natural theorem is independently kernel checked.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
