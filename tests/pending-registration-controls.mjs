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
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-pending-registration-'));
let cases=0,driverSplits=0;
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/pending-registration-fixture.bend'],['core','runtime/core.bend'],['pending','runtime/pending-state.bend']]){
  const output=path.join(dir,name+'.mjs');
  const compiled=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(compiled.status,0,compiled.stdout+'\n'+compiled.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const F=modules.fixture,C=modules.core,P=modules.pending,b=new BendRuntime();
 const blank=list(F.initial(b.encode(undefined),false,encodeList([]),encodeList([])).extensions)[0];
 const observed=world=>({values:list(world.nodes).map(n=>n.value),tree:world.tree,events:world.events});
 for(const value of [undefined,null,false,0,-0,NaN,'cached',{ref:1}])for(const recomputing of [false,true])for(const extCount of [0,2])for(const setCount of [0,2])for(const callerWork of [[],[{$:'AsyncFlush'},{$:'Discard'}]]){
  const extensions=encodeList(Array.from({length:extCount},()=>blank)),sets=encodeList(Array.from({length:setCount},(_,i)=>encodeList([3+i])));
  const args=[b.encode(value),recomputing,extensions,sets];
  const rest=encodeList(callerWork),stack=encodeList([b.encode('outer'),b.encode({ref:1})]);
  const initial=F.initial(...args),linked=F.linked(...args),registered=F.registered(...args),certificate=F.complete(...args,rest,stack);
  assert.equal(P.hasSource(linked,2,1),false);assert.equal(P.hasSource(registered,2,1),true);
  assert.equal(list(registered.extensions).length,list(linked.extensions).length+1);assert.equal(list(registered.pendingSets).length,list(linked.pendingSets).length+1);
  const x=list(registered.nodes)[2].x,set=list(registered.extensions)[x].pendingSources;
  assert.equal(x,extCount+1);assert.equal(set,setCount+1);assert.deepEqual(list(list(registered.pendingSets)[set]),[1]);
  assert.deepEqual(list(registered.pendingSets).slice(0,set),list(linked.pendingSets));
  assert.deepEqual(observed(registered),observed(initial));
  const again=P.addPendingSource(registered,2,1);assert.equal(again.right,false);assert.deepEqual(again.left,registered);
  const removal=P.removePendingSource(registered,2,1);assert.equal(removal.right,true);assert.equal(P.hasSource(removal.left,2,1),false);
  assert.equal(list(removal.left.extensions)[x].pendingSources,0);assert.deepEqual(list(list(removal.left.pendingSets)[set]),[0]);
  const removalAgain=P.removePendingSource(removal.left,2,1);assert.equal(removalAgain.right,false);assert.deepEqual(removalAgain.left,removal.left);
  assert.equal(certificate.$,'ReturnedAt');assert.equal(certificate.steps,10);assert.equal(certificate.steps+certificate.slack,10);
  const machine={$:'Machine',world:registered,tasks:encodeList([{$:'AsyncWriteAfterTrim',id:1},{$:'AsyncWriteSchedule'},...callerWork]),values:stack};
  let returned=machine;for(let step=0;step<certificate.steps;step++)returned=C.step(returned);
  assert.deepEqual(returned,{$:'Machine',world:certificate.world,tasks:rest,values:stack});
  assert.deepEqual(observed(returned.world),observed(initial));assert.equal(returned.world.fault.$,'Healthy');
  assert.equal(P.hasSource(returned.world,2,1),false);assert.equal(list(returned.world.extensions)[x].pendingSources,0);assert.deepEqual(list(list(returned.world.pendingSets)[set]),[0]);
  const afterCore=P.removePendingSource(returned.world,2,1);assert.equal(afterCore.right,false);assert.deepEqual(afterCore.left,returned.world);
  for(const remaining of [0,1,7]){assert.deepEqual(C.run(certificate.steps+remaining,machine),C.run(remaining,returned));driverSplits++;}
  cases++;
 }
 console.log(JSON.stringify({typedFreshRegistrationCases:cases,actualTenStepReturns:cases,actualDriverSplits:driverSplits,duplicateNoOpChecks:cases*3,jsSuppliesEqualityEvidence:false,scope:'private compact graph states with real fresh extension/Set add, variable auxiliary arena sizes and recomputing flags; actual helper retirement and actual Core settlement tested separately; callbacks/public reachability/full flight protocol not claimed'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
