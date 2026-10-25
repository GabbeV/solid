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
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-carrier-cycles-'));
let cases=0,driverSplits=0;
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/pending-carrier-cycle-fixture.bend'],['pending','runtime/pending-state.bend']]){
  const output=path.join(dir,name+'.mjs');
  const compiled=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(compiled.status,0,compiled.stdout+'\n'+compiled.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const F=modules.fixture,P=modules.pending,b=new BendRuntime();
 const zero=encodeList([]),literal={$:'Literal',value:b.encode(undefined)};
 const blank=list(F.initial(zero,literal,literal,zero,zero).extensions)[0];
 const observed=world=>({values:list(world.nodes).map(n=>n.value),tree:world.tree,events:world.events});
 const sequences=[];
 for(let length=0;length<=6;length++)for(let mask=0;mask<2**length;mask++)sequences.push(Array.from({length},(_,i)=>Boolean(mask&(2**i))));
 sequences.push(Array.from({length:32},(_,i)=>Boolean(i%2)),Array.from({length:64},(_,i)=>Boolean(i%2)),[...Array(32).fill(true),...Array(32).fill(false)],Array(64).fill(false));
 let duplicateNoOps=0;
 for(const [index,sequence]of sequences.entries()){
  const payload=[undefined,null,false,0,-0,NaN,'cached',{ref:1}][index%8],size=[0,3,11][index%3],rootId=1+size,leafId=rootId+1;
  const extCount=index%2?2:0,setCount=index%3?2:0;
  const prefix=encodeList(Array.from({length:size},(_,i)=>b.encode(i%2?payload:i))),extensions=encodeList(Array.from({length:extCount},()=>blank)),sets=encodeList(Array.from({length:setCount},(_,i)=>encodeList([3+i])));
  const sourceExpr={$:'Literal',value:b.encode(payload)},effectExpr={$:'Read',id:rootId},commands=encodeList(sequence.map(add=>({$:add?'AddLeaf':'RemoveLeaf'}))),args=[prefix,sourceExpr,effectExpr,extensions,sets];
  const initial=F.initial(...args),result=F.run(...args,commands),after=F.after(...args,commands);
  let expected=initial,active=false,allocations=0,everAdded=false;
  for(const add of sequence){
   const before=expected,pair=add?P.addPendingSource(expected,leafId,rootId):P.removePendingSource(expected,leafId,rootId);expected=pair.left;
   if(add===active){assert.equal(pair.right,false);assert.deepEqual(expected,before);duplicateNoOps++;}else assert.equal(pair.right,true);
   if(add&&!active){allocations++;everAdded=true;}active=add;
  }
  assert.deepEqual(result.world,expected);assert.deepEqual(after,expected,'proof-carrying execution matches the independent actual-helper replay');
  assert.equal(result.snapshot.$,active?'CarrierSingle':everAdded?'CarrierEmpty':'CarrierFresh');
  assert.equal(P.hasSource(result.world,leafId,rootId),active,'general membership theorem exercised on the emitted backend');
  assert.deepEqual(observed(result.world),observed(initial));assert.equal(result.world.fault.$,'Healthy');
  assert.equal(list(after.pendingSets).length,1+setCount+allocations);assert.equal(list(after.extensions).length,1+extCount+(everAdded?1:0));
  const captured=list(after.pendingSets).slice(1+setCount).map(list);captured.forEach((slots,i)=>assert.deepEqual(slots,active&&i===captured.length-1?[rootId]:[0]));
  cases++;
 }
 console.log(JSON.stringify({typedCarrierCycleHistories:cases,allBinaryOrdersThroughLength:6,longestHistory:64,duplicateWholeWorldNoOps:duplicateNoOps,jsSuppliesEqualityEvidence:false,scope:'general single-source membership/representation invariant from actual default node construction, arbitrary finite add/remove commands, direct actual-helper world agreement; no status/readiness/full flight-controller/final-reveal claim'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
