// Finite canonical/native checks supplement the all-natural kernel theorem.
import assert from 'node:assert/strict';import fs from 'node:fs';import os from 'node:os';import path from 'node:path';import {spawnSync} from 'node:child_process';import {fileURLToPath,pathToFileURL} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-deferred-proof-'));
try{
 const from=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const p of['runtime','representation','observation'])fs.cpSync(path.join(from,p),path.join(dir,p),{recursive:true});fs.cpSync(path.join(root,'proof'),path.join(dir,'proof'),{recursive:true});
 const compile=async name=>{const out=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'proof',name+'.bend'),'-o',out],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stderr);return import(pathToFileURL(out));};
 const {default:D}=await compile('deferred-driver'),{default:P}=await compile('deferred-program');let count=0;
 for(const initial of[0,1,7,11,2**32,2**40,2**48,2**50])for(const next of[0,1,17,2**40]){
  let m=D.before(initial,next);assert.deepEqual(m,P.state_0(initial,next));for(let i=0;i<103;i++){m=D.step(m);assert.deepEqual(m,P['state_'+(i+1)](initial,next),`canonical prefix ${i+1}`);}for(const fuel of[103,104,128])assert.deepEqual(D.run(fuel,initial,next),m);
  const S=await import(pathToFileURL(path.join(root,'build/solid.mjs'))+'?deferred-control='+count);let set,get,dispose;
  S.createRoot(d=>{dispose=d;const [input,update]=S.createSignal(initial,{equals:false});set=update;get=S.createDeferred(input,{equals:false});});set(next);S.flush();assert.equal(get(),next);dispose();S.flush();
  assert.deepEqual(m.values,{$:'Con',head:{$:'Number',n:next},tail:{$:'Nil'}});assert.equal(m.world.fault.$,'Healthy');count++;
 }console.log(`${count} deferred complete-program/native controls compare 103 canonical transitions and exact final Machines at three sufficient budgets; the all-natural theorem is independently kernel checked.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
