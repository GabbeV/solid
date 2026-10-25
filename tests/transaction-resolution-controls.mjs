// Private source-helper controls, separate from public histories and proofs.
// No TypeScript function body is replaced; fixture access exposes membership.
import assert from 'node:assert/strict';
import {list,encodeList} from '../host/bend.mjs';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-redirect-controls-'));
try{
 const source=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const folder of ['runtime','representation','observation'])fs.cpSync(path.join(source,folder),path.join(dir,folder),{recursive:true});
 const modules={};
 for(const name of ['transaction','action-state','api']){
  const output=path.join(dir,name+'.mjs');const result=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'runtime',name+'.bend'),'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(result.status,0,result.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const T=modules.transaction,A=modules['action-state'],API=modules.api;
 const bundle=await build({stdin:{contents:"export * from './index.ts';export {newTransaction,merge,resolveTx} from './core/scheduler.ts';export {transactions as live} from './core/scheduler.ts';",resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'membership-observation',setup(b){b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {transactions};'}));}}]});
 const nativeFile=path.join(dir,'native.mjs');fs.writeFileSync(nativeFile,bundle.outputFiles[0].text);const S=await import(pathToFileURL(nativeFile));
 let fixtures=0,queries=0,rejoins=0,completions=0;
 for(let size=1;size<=7;size++)for(const reverse of [false,true])for(const stale of [false,true]){
  S.live.length=0;let world=API.createWorld();const tx=[null];
  for(let i=1;i<=size+1;i++){
   const pair=T.newTransaction(world,false,0);world=pair.left;assert.equal(pair.right,i);
   tx.push(S.newTransaction(false));
  }
  const id=t=>t===null?0:tx.indexOf(t);
  const compare=()=>{
   assert.deepEqual(list(world.txArena).slice(1).map(t=>({into:t.into,open:t.open})),tx.slice(1).map(t=>({into:id(t._into),open:t._open})));
   assert.deepEqual(list(world.transactions),S.live.map(id));assert.equal(world.fault.$,'Healthy');
   for(let i=1;i<tx.length;i++){
    const before=world,pair=T.resolveTx(world,i);assert.deepEqual(pair.left,before,'resolution preserves complete World');assert.equal(pair.right,id(S.resolveTx(tx[i])));queries++;
   }
  };
  const order=Array.from({length:size},(_,i)=>i+1);if(reverse)order.reverse();let previous=order[0];compare();
  for(const target of order.slice(1)){
   const sourceId=stale?order[0]:previous;
   world=T.merge(world,sourceId,target);S.merge(tx[sourceId],tx[target]);previous=target;compare();
   // Repeated joins through original and current aliases, including reverse.
   for(const [a,b]of [[sourceId,target],[target,sourceId],[order[0],target]]){
    const before=world;world=T.merge(world,a,b);S.merge(tx[a],tx[b]);assert.deepEqual(world,before,'same-component rejoin is exact identity');compare();rejoins++;
   }
  }
  assert.equal(T.resolveTx(world,size+1).right,size+1,'independent transaction retained');
  // Exercise the real done prefix through an original transaction identity.
  // This fixture supplies one positive outstanding obligation to its live root;
  // public native action/once-only delivery controls are tested separately.
  const representative=T.resolveTx(world,order[0]).right;
  const created=A.create(world,{$:'ActionEnd'});world=created.left;
  const action=list(world.actions)[created.right];world=A.store(world,created.right,{...action,transaction:order[0]});
  for(const remaining of [0,1,5]){
   const arena=list(world.txArena),rootTx=arena[representative];arena[representative]={...rootTx,open:remaining+1};
   const asList=encodeList;
   const before={...world,txArena:asList(arena)};const after=A.done(before,created.right),updated=list(after.txArena);
   assert.equal(updated[representative].open,remaining);
   for(let i=0;i<arena.length;i++)if(i!==representative)assert.deepEqual(updated[i],arena[i],'other transaction untouched');
   const allowed=new Set(['txArena','scheduled','hostJobs']);for(const key of Object.keys(before))if(!allowed.has(key))assert.deepEqual(after[key],before[key],key+' preserved');
   assert.equal(after.scheduled,true);completions++;
  }
  fixtures++;
 }
 // Bad cyclic fixture is outside the certified-path domain and must fault.
 let cyclic=API.createWorld();for(let i=0;i<2;i++)cyclic=T.newTransaction(cyclic,false,0).left;
 const entries=list(cyclic.txArena);entries[1]={...entries[1],into:2};entries[2]={...entries[2],into:1};
 const asList=encodeList;
 const bad=T.resolveTx({...cyclic,txArena:asList(entries)},1);assert.equal(bad.left.fault.$,'Exhausted');
 console.log(JSON.stringify({fixtures,queries,rejoins,positiveCompletionPrefixes:completions,cyclicExhaustionControls:1,kind:'private helpers; not public histories or a proof'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
