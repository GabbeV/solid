// Direct comparisons with the actual native tracked _run closure, not a copy.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-settled-probe-'));
const list=xs=>{const out=[];while('head'in xs){out.push(xs.head);xs=xs.tail;}return out;};
try{
 const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(dir,name),{recursive:true});
 const fixture=path.join(dir,'settled.bend');
 fs.writeFileSync(fixture,fs.readFileSync(path.join(root,'tests/probes/settled.bend'),'utf8').replaceAll('../../runtime/','./runtime/').replaceAll('../../representation/','./representation/'));
 const emitted=path.join(dir,'settled.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',fixture,'-o',emitted],{cwd:root,encoding:'utf8'});
 assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
 const bundled=await build({stdin:{contents:`export * from './index.ts';export {globalQueue,newTransaction,probeLane,dirtyQueue} from './core/scheduler.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'probe-live-lane',setup(build){build.onLoad({filter:/core\/scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport function probeLane(tx){passLane=tx;}'}));}}]});
 const text=bundled.outputFiles[0].text;let count=0;
 for(const [minimum,maximum]of [[0,0],[1,0],[2,1],[2,2],[1,3],[3,1]])for(const copies of [0,1,2,3])for(const lane of [false,true]){
  const S=await import('data:text/javascript;base64,'+Buffer.from(text+'\n// fixture '+count).toString('base64'));
  const [value,setValue]=S.createSignal(0);const node=Object.getOwnPropertySymbols(value).map(key=>value[key]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v);
  const notPending=node._pendingValue;let calls=0;
  S.onSettled(()=>{calls++;value();return setValue(7);});
  const fire=S.globalQueue._queues[1][0];S.globalQueue._queues=[[],[]];
  const tx=S.newTransaction(true);S.dirtyQueue._min=minimum;S.dirtyQueue._max=maximum;
  // Queue.enqueue accepts its default live passLane. Set it only in this
  // standalone direct fixture; no public lane execution is claimed.
  S.probeLane(lane?tx:null);
  for(let i=0;i<copies;i++)fire();
  const w=B.fixture(copies,minimum,maximum,lane),nodes=list(w.nodes),n=nodes[2],queues=list(w.userQueue),held=list(list(w.txArena)[1].userQueue);
  assert.equal(nodes.length,3,'unowned callback allocates no reactive node');
  assert.equal(list(w.settledCallbacks).length,2,'requeue retains the same closure');
  assert.deepEqual(queues.map(e=>[e.$,e.callback]),S.globalQueue._queues[1].map(fn=>['SettledFire',fn===fire?1:0]));
  assert.deepEqual(held.map(e=>[e.$,e.callback]),tx._queues[1].map(fn=>['SettledFire',fn===fire?1:0]));
  assert.equal(list(w.events).filter(e=>'reader'in e).length,calls,'dirty heap defers without invoking user code');
  assert.equal('value'in n.pending,node._pendingValue!==notPending);
  if('value'in n.pending)assert.equal(n.pending.value.n,node._pendingValue);
  assert.equal(w.minimum,minimum);assert.equal(w.maximum,maximum);
  assert.equal(w.fault.$,'Healthy');count++;
 }
 console.log(`${count} native onSettled.fire comparisons preserve heap gating, repeated closure identity, node-free allocation and lane queue routing.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
