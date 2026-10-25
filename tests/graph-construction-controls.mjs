// Executable checks of the typed graph/return constructor. Its input predicates
// are proved in the compact Bend fixture; JavaScript supplies no equality terms.
// These are private represented states, separate from native/public histories.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-graph-construction-'));
let cases=0,driverSplits=0;
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/graph-construction-fixture.bend'],['core','runtime/core.bend']]){
  const output=path.join(dir,name+'.mjs');
  const compiled=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(compiled.status,0,compiled.stdout+'\n'+compiled.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const F=modules.fixture,C=modules.core,b=new BendRuntime();
 const observed=world=>({values:list(world.nodes).map(n=>n.value),tree:world.tree,events:world.events});
 for(const value of [undefined,null,false,0,-0,NaN,'cached',{ref:1}])for(const recomputing of [false,true])for(const carrier of [false,true])for(const callerWork of [[],[{$:'AsyncFlush'},{$:'Discard'}]]){
  const encoded=b.encode(value),rest=encodeList(callerWork),stack=encodeList([b.encode('outer'),b.encode({ref:1})]);
  const before=F.initial(encoded,recomputing,carrier),linked=F.linked(encoded,recomputing,carrier),certificate=F.complete(encoded,recomputing,carrier,rest,stack);
  assert.equal(certificate.$,'ReturnedAt');assert.equal(certificate.steps,carrier?10:9);assert.equal(certificate.steps+certificate.slack,10);
  const nodes=list(linked.nodes),edge=nodes[1].subs;
  assert.equal(edge,1);assert.equal(list(linked.links)[edge].sub,2);assert.equal(list(linked.links)[edge].nextSub,0);
  assert.equal(nodes[2].subs,0);assert.equal(nodes[2].config,0);assert.equal(linked.fault.$,'Healthy');
  assert.deepEqual(observed(linked),observed(before),'actual graph creation retains committed content');
  const machine={$:'Machine',world:linked,tasks:encodeList([{$:'AsyncWriteAfterTrim',id:1},{$:'AsyncWriteSchedule'},...callerWork]),values:stack};
  let returned=machine;for(let step=0;step<certificate.steps;step++)returned=C.step(returned);
  assert.deepEqual(returned,{$:'Machine',world:certificate.world,tasks:rest,values:stack},'constructed certificate carries actual World/caller after actual steps');
  assert.deepEqual(observed(returned.world),observed(before));assert.equal(returned.world.fault.$,'Healthy');
  for(const remaining of [0,1,7]){
   assert.deepEqual(C.run(certificate.steps+remaining,machine),C.run(remaining,returned),'constructed count composes with the actual driver');driverSplits++;
  }
  cases++;
 }
 console.log(JSON.stringify({typedConstructorCases:cases,actualDriverSplits:driverSplits,arbitraryPayloadProofCheckedSeparately:true,jsSuppliesEqualityEvidence:false,scope:'private compact graph states, both recomputing flags, carrier present/absent, empty/nonempty callers; no public reachability or compiler correctness claim'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
