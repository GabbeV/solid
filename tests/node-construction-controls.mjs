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
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-node-construction-'));
let cases=0,driverSplits=0;
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/memo-render-fixture.bend'],['core','runtime/core.bend']]){
  const output=path.join(dir,name+'.mjs');
  const compiled=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(compiled.status,0,compiled.stdout+'\n'+compiled.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const F=modules.fixture,C=modules.core,b=new BendRuntime();
 const observed=world=>({values:list(world.nodes).map(n=>n.value),tree:world.tree,events:world.events});
 for(const prefixLength of [0,1,4,9])for(const value of [undefined,false,-0,NaN,'cached',{ref:1}])for(const callerWork of [[],[{$:'AsyncFlush'},{$:'Discard'}]]){
  const prefix=encodeList(Array.from({length:prefixLength},(_,i)=>b.encode(i%2?value:i)));
  const rootId=1+prefixLength,leafId=rootId+1;
  const sourceExpr={$:'Literal',value:b.encode(value)},effectExpr={$:'Read',id:rootId};
  const rest=encodeList(callerWork),stack=encodeList([b.encode('outer'),b.encode({ref:1})]);
  const args=[prefix,sourceExpr,effectExpr,7,0,0];
  const initial=F.input(prefix),allocated=F.allocated(...args),linked=F.linked(...args),certificate=F.complete(...args,rest,stack);
  assert.equal(certificate.$,'ReturnedAt');assert.equal(certificate.steps,9);assert.equal(certificate.steps+certificate.slack,10);
  const nodes=list(linked.nodes),edge=nodes[rootId].subs;
  assert.equal(nodes.length,rootId+2);assert.equal(nodes[rootId].kind.$,'Memo');assert.equal(nodes[leafId].kind.$,'Render');
  assert.equal(nodes[rootId].prevHeap,rootId);assert.equal(nodes[leafId].prevHeap,leafId);
  assert.equal(nodes[rootId].config,32);assert.equal(nodes[leafId].config,0);assert.equal(nodes[leafId].subs,0);
  assert.equal(edge,1);assert.equal(list(linked.links)[edge].sub,leafId);assert.equal(list(linked.links)[edge].nextSub,0);assert.equal(linked.fault.$,'Healthy');
  assert.deepEqual(list(allocated.nodes).slice(0,rootId),list(initial.nodes),'old nodes retained through actual allocation');
  assert.deepEqual(observed(linked),observed(allocated),'actual graph creation retains committed content');
  const machine={$:'Machine',world:linked,tasks:encodeList([{$:'AsyncWriteAfterTrim',id:rootId},{$:'AsyncWriteSchedule'},...callerWork]),values:stack};
  let returned=machine;for(let step=0;step<certificate.steps;step++)returned=C.step(returned);
  assert.deepEqual(returned,{$:'Machine',world:certificate.world,tasks:rest,values:stack});
  assert.deepEqual(observed(returned.world),observed(allocated));assert.equal(returned.world.fault.$,'Healthy');
  for(const remaining of [0,1,7]){assert.deepEqual(C.run(certificate.steps+remaining,machine),C.run(remaining,returned));driverSplits++;}
  cases++;
 }
 console.log(JSON.stringify({typedRawConstructorCases:cases,actualDriverSplits:driverSplits,jsSuppliesEqualityEvidence:false,scope:'actual memo/render allocation/setup/link from reserved arenas with variable existing nodes; callbacks and pending flight registration are not executed, so these cases take the absent-carrier nine-step alternative'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
