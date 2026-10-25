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
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-source-histories-'));
let cases=0,driverSplits=0;
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/pending-source-history-fixture.bend'],['core','runtime/core.bend'],['pending','runtime/pending-state.bend']]){
  const output=path.join(dir,name+'.mjs');
  const compiled=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(compiled.status,0,compiled.stdout+'\n'+compiled.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const F=modules.fixture,C=modules.core,P=modules.pending,b=new BendRuntime();
 const observed=world=>({values:list(world.nodes).map(n=>n.value),tree:world.tree,events:world.events});
 const sequences=[];
 for(let length=0;length<=6;length++)for(let mask=0;mask<2**length;mask++)sequences.push(Array.from({length},(_,i)=>Boolean(mask&(2**i))));
 sequences.push(Array.from({length:32},(_,i)=>Boolean(i%2)),Array.from({length:64},(_,i)=>Boolean(i%2)),[...Array(32).fill(true),...Array(32).fill(false)],Array(64).fill(false));
 for(const [index,sequence]of sequences.entries()){
  const payload=[undefined,null,false,0,-0,NaN,'cached',{ref:1}][index%8],size=[0,1,5,11][index%4],rootId=1+size,leafId=rootId+1;
  const prefix=encodeList(Array.from({length:size},(_,i)=>b.encode(i%2?payload:i)));
  const sourceExpr={$:'Literal',value:b.encode(payload)},effectExpr={$:'Read',id:rootId},commands=encodeList(sequence.map(add=>({$:add?'AddLeaf':'RemoveLeaf'})));
  const callerWork=index%2?[{$:'AsyncFlush'},{$:'Discard'}]:[],rest=encodeList(callerWork),stack=encodeList([b.encode('outer'),b.encode({ref:1})]);
  const initial=F.initial(prefix,sourceExpr,effectExpr),after=F.after(prefix,sourceExpr,effectExpr,commands),certificate=F.complete(prefix,sourceExpr,effectExpr,commands,rest,stack);
  let expected=initial,active=false,allocations=0,registered=false;
  for(const add of sequence){
   expected=(add?P.addPendingSource(expected,leafId,rootId):P.removePendingSource(expected,leafId,rootId)).left;
   if(add&&!active){allocations++;registered=true;}active=add;
  }
  assert.deepEqual(after,expected,'constructed permitted history executes the actual source operations');
  assert.equal(P.hasSource(after,leafId,rootId),active,'last command determines membership, including duplicate/missing commands');
  assert.equal(list(after.pendingSets).length,1+allocations);assert.equal(list(after.extensions).length,registered?2:1);
  const captured=list(after.pendingSets).slice(1).map(list);
  captured.forEach((slots,i)=>assert.deepEqual(slots,active&&i===captured.length-1?[rootId]:[0],'retired Set identities keep tombstones through re-registration'));
  assert.deepEqual(observed(after),observed(initial));
  assert.equal(certificate.$,'ReturnedAt');assert.equal(certificate.steps,active?10:9);assert.equal(certificate.steps+certificate.slack,10);
  const machine={$:'Machine',world:after,tasks:encodeList([{$:'AsyncWriteAfterTrim',id:rootId},{$:'AsyncWriteSchedule'},...callerWork]),values:stack};
  let returned=machine;for(let step=0;step<certificate.steps;step++)returned=C.step(returned);
  assert.deepEqual(returned,{$:'Machine',world:certificate.world,tasks:rest,values:stack});assert.deepEqual(observed(returned.world),observed(initial));assert.equal(returned.world.fault.$,'Healthy');
  assert.equal(P.hasSource(returned.world,leafId,rootId),false);
  for(const remaining of [0,1,7]){assert.deepEqual(C.run(certificate.steps+remaining,machine),C.run(remaining,returned));driverSplits++;}
  cases++;
 }
 console.log(JSON.stringify({typedConstructedHistories:cases,allBinaryOrdersThroughLength:6,longestHistory:64,actualDriverSplits:driverSplits,jsSuppliesEqualityEvidence:false,scope:'actual variable-ID memo/render construction, source Set add/remove history and bounded actual Core return; finite membership/tombstone checks supplement general frame/validity/return proofs; callback/flight-controller reachability and final reveal not claimed'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
