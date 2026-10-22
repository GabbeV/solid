// Canonical path/native controls supplement the independent quantified proof.
import assert from 'node:assert/strict';import fs from 'node:fs';import os from 'node:os';import path from 'node:path';import {spawnSync} from 'node:child_process';import {fileURLToPath,pathToFileURL} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-optimistic-proof-'));
try{
 const from=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const p of['runtime','representation','observation'])fs.cpSync(path.join(from,p),path.join(dir,p),{recursive:true});fs.cpSync(path.join(root,'proof'),path.join(dir,'proof'),{recursive:true});
 const compile=name=>{const out=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'proof',name+'.bend'),'-o',out],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stderr);return import(pathToFileURL(out));};
 const {default:D}=await compile('optimistic-driver'),{default:P}=await compile('optimistic-program');
 let count=0;
 for(const initial of[0,1,11,2**40])for(const next of[0,17])for(const last of[0,23]){
  let m=D.before(initial,next,last);assert.deepEqual(m,P.state_0(initial,next,last));
  for(let i=0;i<56;i++){m=D.step(m);assert.deepEqual(m,P['state_'+(i+1)](initial,next,last),`canonical prefix ${i+1}`);}
  for(const fuel of[56,57,128])assert.deepEqual(D.run(fuel,initial,next,last),m,'complete machine, all caller stack and World fields');
  const S=await import(pathToFileURL(path.join(root,'build/solid.mjs'))+'?optimistic-control='+count);
  let get,set,dispose;S.createRoot(d=>{dispose=d;[get,set]=S.createOptimistic(initial,{equals:false});});
  assert.equal(set(next),next);assert.equal(set(last),last);S.flush();assert.equal(get(),initial);
  const n=Object.getOwnPropertySymbols(get).map(k=>get[k]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v);
  assert.equal(n._value,initial);assert.equal(n._config,0);assert.equal(n._time,0);assert.equal(m.world.fault.$,'Healthy');assert.equal(m.values.head.n,initial);assert.equal(m.world.laneState.pendingGuesses.$,'Nil');assert.equal(m.world.laneState.live.$,'Nil');assert.equal(m.world.scheduled,false);dispose();count++;
 }
 console.log(`${count} optimistic complete-program/native controls compare 56 canonical transitions and exact final Machines at three sufficient budgets; the all-natural theorem is independently kernel checked.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
