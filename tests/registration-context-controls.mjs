// Executable checks of actual default memo/render allocation and graph construction. Its input predicates
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
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-registration-context-'));
let cases=0,driverSplits=0;
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/memo-render-registration-fixture.bend'],['core','runtime/core.bend'],['pending','runtime/pending-state.bend']]){
  const output=path.join(dir,name+'.mjs');
  const compiled=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(compiled.status,0,compiled.stdout+'\n'+compiled.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const F=modules.fixture,C=modules.core,P=modules.pending,b=new BendRuntime();
 const blank=list(F.input(encodeList([]),encodeList([]),encodeList([])).extensions)[0];
 const observed=world=>({values:list(world.nodes).map(n=>n.value),tree:world.tree,events:world.events});
 for(const prefixLength of [0,3,11])for(const value of [undefined,false,-0,NaN,'cached',{ref:1}])for(const extCount of [0,2])for(const setCount of [0,2])for(const callerWork of [[],[{$:'AsyncFlush'},{$:'Discard'}]]){
  const prefix=encodeList(Array.from({length:prefixLength},(_,i)=>b.encode(i%2?value:i)));
  const extensions=encodeList(Array.from({length:extCount},()=>blank)),sets=encodeList(Array.from({length:setCount},(_,i)=>encodeList([3+i])));
  const rootId=1+prefixLength,leafId=rootId+1,sourceExpr={$:'Literal',value:b.encode(value)},effectExpr={$:'Read',id:rootId};
  const rest=encodeList(callerWork),stack=encodeList([b.encode('outer'),b.encode({ref:1})]),args=[prefix,sourceExpr,effectExpr,extensions,sets];
  const linked=F.linked(...args),registered=F.registered(...args),ready=F.ready(...args),certificate=F.complete(...args,rest,stack);
  assert.equal(ready.$,'RegisteredReady');assert.equal(P.hasSource(linked,leafId,rootId),false);assert.equal(P.hasSource(registered,leafId,rootId),true);
  const nodes=list(registered.nodes),x=nodes[leafId].x,set=list(registered.extensions)[x].pendingSources;
  assert.equal(nodes[rootId].kind.$,'Memo');assert.equal(nodes[leafId].kind.$,'Render');assert.equal(x,extCount+1);assert.equal(set,setCount+1);
  assert.deepEqual(list(list(registered.pendingSets)[set]),[rootId]);assert.deepEqual(observed(registered),observed(linked));
  const duplicate=P.addPendingSource(registered,leafId,rootId);assert.equal(duplicate.right,false);assert.deepEqual(duplicate.left,registered);
  assert.equal(certificate.$,'ReturnedAt');assert.equal(certificate.steps,10);assert.equal(certificate.steps+certificate.slack,10);
  const machine={$:'Machine',world:registered,tasks:encodeList([{$:'AsyncWriteAfterTrim',id:rootId},{$:'AsyncWriteSchedule'},...callerWork]),values:stack};
  let returned=machine;for(let step=0;step<certificate.steps;step++)returned=C.step(returned);
  assert.deepEqual(returned,{$:'Machine',world:certificate.world,tasks:rest,values:stack});assert.deepEqual(observed(returned.world),observed(linked));assert.equal(returned.world.fault.$,'Healthy');
  assert.equal(P.hasSource(returned.world,leafId,rootId),false);assert.equal(list(returned.world.extensions)[x].pendingSources,0);assert.deepEqual(list(list(returned.world.pendingSets)[set]),[0]);
  for(const remaining of [0,1,7]){assert.deepEqual(C.run(certificate.steps+remaining,machine),C.run(remaining,returned));driverSplits++;}
  cases++;
 }
 console.log(JSON.stringify({typedConstructedRegistrationCases:cases,actualTenStepReturns:cases,actualDriverSplits:driverSplits,jsSuppliesEqualityEvidence:false,scope:'actual variable-ID default memo/render construction supplies fresh registration context/member/graph and bounded actual return; initial equality facts checked in Bend, no callback evaluation or full flight controller/reveal claim'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
