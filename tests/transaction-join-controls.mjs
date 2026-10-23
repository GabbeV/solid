// Private source-helper controls, separate from public histories and proofs.
// No TypeScript function body is replaced; fixture access exposes membership.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-join-controls-'));
try{
 const source=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const folder of ['runtime','representation','observation'])fs.cpSync(path.join(source,folder),path.join(dir,folder),{recursive:true});
 const modules={};
 for(const name of ['transaction','action-state','api']){
  const output=path.join(dir,name+'.mjs');const result=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'runtime',name+'.bend'),'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(result.status,0,result.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const T=modules.transaction,A=modules['action-state'],API=modules.api;
 const list=xs=>{const out=[];while('head'in xs){out.push(xs.head);xs=xs.tail;}return out;};
 const bundle=await build({stdin:{contents:"export * from './index.ts';export {newTransaction,merge,resolveTx,blocked,judge} from './core/scheduler.ts';export {transactions as live} from './core/scheduler.ts';",resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'membership-observation',setup(b){b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {transactions,judge};'}));}}]});
 const nativeFile=path.join(dir,'native.mjs');fs.writeFileSync(nativeFile,bundle.outputFiles[0].text);const S=await import(pathToFileURL(nativeFile));

 const asList=xs=>xs.reduceRight((tail,head)=>({$:'Cons',head,tail}),{$:'Nil'});
 const shape=(t,id)=>({into:id(t._into),parent:id(t._parent),lane:t._lane,verdict:id(t._verdict),open:t._open,acted:t._acted,links:0,shown:t._shown,held:t._held,nodes:t._nodes.map(n=>n.id),renderQueue:t._queues[0].map(f=>f.id),userQueue:t._queues[1].map(f=>({$:'NodeRun',node:f.id})),reruns:t._reruns.map(n=>n.id),marks:t._marks===null?{$:'NoIds'}:{$:'SomeIds',items:asList(t._marks.map(n=>n.id))}});
 const bendShape=t=>{const {$:tag,...fields}=t;return {...fields,nodes:list(t.nodes),renderQueue:list(t.renderQueue),userQueue:list(t.userQueue),reruns:list(t.reruns),marks:t.marks.$==='NoIds'?null:list(t.marks.items)};};
 const vectors=(seed,size)=>Array.from({length:size},(_,i)=>({id:seed+i}));
 let fixtures=0,rejoins=0,queries=0,openingControls=0,positiveBlockerControls=0;
 for(const prefix of [0,1,4])for(const gap of [0,1,3])for(const suffix of [0,2])for(const reverse of [false,true])for(const markState of [0,1,2,3])for(const emptyPresentMarks of [false,true]){
  S.live.length=0;let world=API.createWorld();const tx=[null];
  const left=1+prefix,right=left+1+gap,total=right+suffix;
  for(let i=1;i<=total;i++){const p=T.newTransaction(world,false,0);world=p.left;assert.equal(p.right,i);tx.push(S.newTransaction(false));}
  const id=t=>t===null?0:tx.indexOf(t);
  const arena=list(world.txArena);
  for(let i=1;i<=total;i++){
   const t=tx[i];
   // Asymmetric metadata and vector lengths expose transfer direction/loss.
   Object.assign(t,{_open:i%3,_acted:i%2===0,_parent:tx[i===1?total:1],_verdict:tx[total],_shown:i%2!==0,_held:i%3===0,
    _nodes:vectors(i*100,1+i%3),_queues:[vectors(i*1000,1+i%2),vectors(i*2000,i%3)],_reruns:vectors(i*3000,2),
    _marks:((i===left?(markState&1):(i===right?(markState&2):true)))?(emptyPresentMarks?[]:vectors(i*4000,1)):null});
   const s=shape(t,id);arena[i]={...arena[i],...s,nodes:asList(s.nodes),renderQueue:asList(s.renderQueue),userQueue:asList(s.userQueue),reruns:asList(s.reruns)};
  }
  world={...world,txArena:asList(arena),context:77,tracking:true,question:{$:'QuestionEven',half:{$:'QuestionZero'}},judge:9,clock:11};
  const original=world,source=reverse?right:left,target=reverse?left:right;
  const sourceBefore=structuredClone(arena[source]),targetBefore=structuredClone(arena[target]);
  const compare=()=>{
   assert.deepEqual(list(world.txArena).slice(1).map(bendShape),tx.slice(1).map(t=>{const s=shape(t,id);return {...s,marks:s.marks.$==='NoIds'?null:list(s.marks.items)};}));
   assert.deepEqual(list(world.transactions),S.live.map(id));
   for(const key of Object.keys(original))if(!['txArena','transactions'].includes(key))assert.deepEqual(world[key],original[key],'join preserves '+key);
   for(let i=0;i<arena.length;i++)if(i!==source&&i!==target)assert.deepEqual(list(world.txArena)[i],arena[i],'unrelated slot '+i);
   assert.equal(world.fault.$,'Healthy');
  };
  world=T.merge(world,source,target);S.merge(tx[source],tx[target]);compare();
  assert.deepEqual(list(world.txArena)[source],{...sourceBefore,into:target},'retired record retains its captured count/vectors');
  assert.equal(list(world.txArena)[target].open,targetBefore.open+sourceBefore.open);
  assert.equal(list(world.txArena)[target].parent,targetBefore.parent);
  const savedJudge=S.judge,blocked=T.blocked(world,target);
  assert.equal(blocked.right,true);assert.equal(S.blocked(tx[target]),true);
  assert.deepEqual(blocked.left,world,'positive action count preserves complete World/judge');
  assert.equal(S.judge,savedJudge,'native positive count restores the previous judge');positiveBlockerControls++;

  for(const [a,b]of [[source,target],[target,source],[source,source],[target,target]]){
   const before=world;world=T.merge(world,a,b);S.merge(tx[a],tx[b]);assert.deepEqual(world,before,'rejoin transfers nothing twice');compare();rejoins++;
  }
  for(const query of [left,right]){const p=T.resolveTx(world,query);assert.deepEqual(p.left,world);assert.equal(p.right,target);queries++;}
  fixtures++;
 }
 // Actual action opening: each existing action cell receives a fresh nonzero
 // group and one obligation, while entry methods/result and all other cells
 // survive. These are Bend helper/frame controls, not native public histories.
 for(const groups of [0,1,4,7])for(const actions of [1,2,5])for(const selected of Array.from({length:actions},(_,i)=>i+1)){
  let world=API.createWorld();
  for(let i=0;i<groups;i++)world=T.newTransaction(world,false,0).left;
  const ids=[];for(let i=0;i<actions;i++){const p=A.create(world,{$:'ActionEnd'});world=p.left;ids.push(p.right);}
  const id=ids[selected-1],old=structuredClone(world),t=list(world.txArena).length,entries=list(world.actions),before=entries[id];
  const after=A.open(world,id),updated=list(after.actions)[id],created=list(after.txArena)[t];
  assert.equal(t>0,true);assert.equal(updated.transaction,t);assert.equal(created.open,1);assert.equal(created.acted,true);assert.equal(created.into,0);assert.equal(created.lane,false);
  assert.deepEqual(updated.methods,before.methods);assert.equal(updated.result,before.result);assert.deepEqual(updated.question,after.questions);
  assert.notDeepEqual(after.questions,old.questions);assert.deepEqual(after.question,old.question,'ambient question is not the fresh counter');
  assert.deepEqual(list(after.txArena).slice(0,-1),list(old.txArena));assert.deepEqual(list(after.transactions),[...list(old.transactions),t]);
  const mask=new Set(['txArena','transactions','questions','actions']);for(const k of Object.keys(old))if(!mask.has(k))assert.deepEqual(after[k],old[k],k);
  for(let i=0;i<entries.length;i++)if(i!==id)assert.deepEqual(list(after.actions)[i],entries[i]);
  const blocked=T.blocked(after,t);assert.equal(blocked.right,true);assert.deepEqual(blocked.left,after);positiveBlockerControls++;

  openingControls++;
 }
 console.log(JSON.stringify({privateJoinFixtures:fixtures,exactRejoins:rejoins,resolverQueries:queries,bendOpeningFrameControls:openingControls,positiveBlockerControls,publicHistories:false}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
