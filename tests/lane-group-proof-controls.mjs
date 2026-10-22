import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-group-proof-controls-'));
try{
 const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(dir,name),{recursive:true});
 fs.mkdirSync(path.join(dir,'proof'));fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});fs.copyFileSync(path.join(root,'proof/lane-group-laws.bend'),path.join(dir,'proof/lane-group-laws.bend'));fs.copyFileSync(path.join(root,'tests/probes/lane-groups.bend'),path.join(dir,'tests/probes/lane-groups.bend'));
 const emitted=path.join(dir,'groups.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'tests/probes/lane-groups.bend'),'-o',emitted],{cwd:root,encoding:'utf8'});assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
 const source=path.join(root,'upstream/solid/packages/signals/src');const bundle=await build({stdin:{contents:`export * from './index.ts';export {newTransaction} from './core/scheduler.ts';export {probeLink,probeUnlink} from './core/lanes.ts';`,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'actual-group-helper-exports',setup(b){b.onLoad({filter:/[/\\]core[/\\]lanes\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {linkLanes as probeLink,unlink as probeUnlink};'}));}}]});
 const file=path.join(dir,'solid.mjs');fs.writeFileSync(file,bundle.outputFiles[0].text);const S=await import(pathToFileURL(file));
 const list=xs=>{const a=[];while('head'in xs){a.push(xs.head);xs=xs.tail;}return a;},adt=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$: 'Nil'});
 function nativeArena(){const parent=S.newTransaction(false),nodes=[null,...Array.from({length:15},()=>S.newTransaction(true,parent)),parent];return nodes;}
 function check(pair,nodes,groups){
  assert.deepEqual(pair.left,pair.right,'actual operation must match the exact quantified World specification');
  const w=pair.left;assert.equal(w.fault.$,'Healthy');assert.deepEqual(list(w.txArena).slice(1).map(t=>t.links),nodes.slice(1).map(t=>t._links===null?0:groups.indexOf(t._links)));
  assert.deepEqual(list(w.laneState.groups).map(list),groups.map(g=>g.map(n=>nodes.indexOf(n))));
 }
 const prefixes=Array.from([0,1,2,3,8,17,64,128],length=>Array.from({length},(_,i)=>(i*5)%14)),suffixes=[[],[2],[1],[3,1,3],[1,1,1],[2,3,4],[15,2,1,14]];
 let count=0;
 for(const prefix of prefixes)for(const present of [false,true])for(const suffix of present?suffixes:[[]]){
  const pair=B.fixture(adt(prefix),adt(suffix),present),nodes=nativeArena(),items=[...prefix.map(n=>n+2),...(present?[1,...suffix]:[])],groups=[[],items.map(i=>nodes[i]),[nodes[3],nodes[2]],[nodes[4]]];
  nodes[1]._links=groups[1];for(let i=2;i<=15;i++)nodes[i]._links=items.includes(i)?groups[1]:null;
  const original=groups[1];S.probeUnlink(nodes[1]);assert.equal(groups[1],original);for(let i=2;i<=15;i++)if(items.includes(i))assert.equal(nodes[i]._links,original,'peer must retain its shared array identity');check(pair,nodes,groups);count++;
 }
 for(const group of [0,1,2]){const pair=B.linked(group),nodes=nativeArena(),groups=[[],[nodes[1],nodes[2]],[nodes[2],nodes[1]],[nodes[1],nodes[2]]];nodes[1]._links=nodes[2]._links=groups[group+1];const original=nodes[1]._links;S.probeLink(nodes[1],nodes[2]);assert.equal(nodes[1]._links,original);assert.equal(nodes[2]._links,original);check(pair,nodes,groups);count++;}
 for(const oldGroups of [[],[[2,3]],[[]],[[3,4],[2],[14,15],[]]]){const pair=B.self(adt(oldGroups.map(adt))),nodes=nativeArena(),groups=[[],...oldGroups.map(g=>g.map(i=>nodes[i]))];S.probeLink(nodes[1],nodes[1]);assert.ok(!groups.includes(nodes[1]._links),'self-link allocates a fresh group');groups.push(nodes[1]._links);assert.deepEqual(nodes[1]._links,[nodes[1]],'self is inserted once');check(pair,nodes,groups);count++;}
 console.log(`${count} canonical/native group controls match complete Bend Worlds, exact source unlink/link aliasing, repeated/absent entries, cached groups and fresh self allocation; quantified proofs are checked separately.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
