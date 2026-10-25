// Actual source list/ext helpers on allocated fixtures. Pending-status metadata
// is installed explicitly: these are private construction controls, not a
// proof/control of the complete callback/status-propagation entry programme.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-list-controls-'));
const modules={};
try{
 const active=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const name of ['transaction','extension']){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(active,'runtime',name+'.bend'),'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(r.status,0,r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
}finally{fs.rmSync(dir,{recursive:true,force:true});}
const T=modules.transaction,E=modules.extension;
const source=path.join(root,'upstream/solid/packages/signals/src');
const bundle=await build({stdin:{contents:"export * from './index.ts';export {newTransaction,list,blocked} from './core/scheduler.ts';export {ext} from './core/core.ts';",resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}});
const moduleUrl='data:text/javascript;base64,'+Buffer.from(bundle.outputFiles[0].text).toString('base64');
let fixtures=0,relistings=0;
for(const priorGroups of [0,2,5])for(const suffixGroups of [0,3])for(const prefixLength of [0,1,4])for(const family of ['zero','undefined','reference']){
 const S=await import(moduleUrl+'#list-fixture='+fixtures),b=new BendRuntime();
 const nativeValue=family==='zero'?0:family==='undefined'?undefined:Object.freeze({value:'baseline'}),value=family==='reference'?{ref:1}:nativeValue;
 const nativeNodes=[];let dispose;
 try{
  S.createRoot(d=>{
   dispose=d;const owner=S.getOwner();
   for(let i=0;i<=prefixLength;i++){S.createRenderEffect(()=>nativeValue,()=>{});nativeNodes.push(owner._firstChild);}
  });
  for(let i=0;i<=prefixLength;i++)b.effect('node'+i,{lit:value});
  S.flush();b.flush();
  const txs=[null];for(let i=0;i<1+priorGroups+suffixGroups;i++){txs.push(S.newTransaction(false));b.world=T.newTransaction(b.world,false,0).left;}
  const tx=1+priorGroups,target=nativeNodes[prefixLength],id=b.ids['node'+prefixLength];
  // Earlier ordinary render nodes supply a real source-ineligible prefix.
  for(let i=0;i<prefixLength;i++){S.list(nativeNodes[i],txs[tx]);b.world=T.list(b.world,b.ids['node'+i],tx);}
  S.ext(target);b.world=E.ext(b.world,id);
  target._statusFlags=1;
  const nodes=list(b.world.nodes);nodes[id]={...nodes[id],status:1};b.world={...b.world,nodes:encodeList(nodes)};
  const before=structuredClone(b.world),slot=nodes[id].x;
  assert.ok(slot>0);assert.equal(list(before.extensions)[slot].transaction,0);
  S.list(target,txs[tx]);b.world=T.list(b.world,id,tx);
  assert.equal(target._x._transaction,txs[tx]);assert.equal(list(b.world.extensions)[slot].transaction,tx);
  assert.deepEqual(txs[tx]._nodes,[...nativeNodes.slice(0,prefixLength),target]);
  assert.deepEqual(list(list(b.world.txArena)[tx].nodes),Array.from({length:prefixLength+1},(_,i)=>b.ids['node'+i]));
  const mask=new Set(['txArena','extensions']);for(const key of Object.keys(before))if(!mask.has(key))assert.deepEqual(b.world[key],before[key],key+' source list frame');
  for(let i=0;i<list(before.txArena).length;i++)if(i!==tx)assert.deepEqual(list(b.world.txArena)[i],list(before.txArena)[i]);
  for(let i=0;i<list(before.extensions).length;i++)if(i!==slot)assert.deepEqual(list(b.world.extensions)[i],list(before.extensions)[i]);
  assert.deepEqual(list(b.world.nodes)[id],nodes[id]);
  const blocked=T.blocked(b.world,tx);assert.equal(blocked.right,true);assert.deepEqual(blocked.left,b.world);assert.equal(S.blocked(txs[tx]),true);
  for(let i=0;i<3;i++){
   const prior=b.world;S.list(target,txs[tx]);b.world=T.list(b.world,id,tx);assert.deepEqual(b.world,prior);
   assert.equal(txs[tx]._nodes.length,prefixLength+1);relistings++;
  }
  fixtures++;
 }finally{dispose?.();b.dispose();}
}
console.log(JSON.stringify({privateListConstructionFixtures:fixtures,exactRelistings:relistings,publicHistories:false,scope:'actual allocated extension/group/node slots, fresh membership/list construction, zero-debt pending render blocker and exact same-group no-op; pending status installed explicitly'}));
