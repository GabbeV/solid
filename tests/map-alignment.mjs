// Actual pinned private function bodies with synthetic arrays/root identities.
// This is operation/partial-state evidence, separate from public histories.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-map-probe-'));
const list=xs=>{const values=[];while('head'in xs){values.push(xs.head);xs=xs.tail;}return values;};
try{
 const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(dir,name),{recursive:true});
 const probeFile=path.join(dir,'tests/probes/map.bend');fs.mkdirSync(path.dirname(probeFile),{recursive:true});fs.copyFileSync(path.join(root,'tests/probes/map.bend'),probeFile);
 const emitted=path.join(dir,'probe.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',probeFile,'-o',emitted],{cwd:root,encoding:'utf8'});
 assert.equal(compile.status,0,compile.stderr.slice(0,5000));const {default:B}=await import(pathToFileURL(emitted));
 const source=path.join(root,'upstream/solid/packages/signals/src');
 const bundle=await build({stdin:{contents:"export {trySmallMove,stageRemoval,commitWindow} from './map.ts';",resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'map-private-functions',setup(b){b.onLoad({filter:/[/\\]map\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {trySmallMove,stageRemoval,commitWindow};\n'}));}}]});
 const native=path.join(dir,'solid.mjs');fs.writeFileSync(native,bundle.outputFiles[0].text);const S=await import(pathToFileURL(native));
 const references=new Map();const normalize=xs=>xs.map(value=>{if(value&&typeof value==='object'){if(!references.has(value.ref))references.set(value.ref,value);return references.get(value.ref);}return value;});
 const encoded=value=>value===undefined?B.undefined():Number.isNaN(value)?B.nan():typeof value==='object'?B.reference(value.ref):B.number(value);
 const encode=xs=>xs.reduceRight((tail,value)=>B.cons(encoded(value),tail),B.nil());
 const decode=value=>'n'in value?value.n:value.$==='NotANumber'?NaN:value.$==='Reference'?{ref:value.id}:undefined;
 const array=(w,id)=>{const slots=list(list(w.arrays)[id].slots),result=new Array(slots.length);slots.forEach((slot,i)=>{if('value'in slot)result[i]=decode(slot.value);});return result;};
 const state=w=>list(w.maps)[0],nodeLabels=w=>list(state(w).nodes);
 function data(old){const cleaned=[],nodes=old.map((_,i)=>({id:i+1,dispose(){cleaned.push(i+1);}}));return {data:{_len:old.length,_items:old.slice(),_mappings:old.map((_,i)=>i+1),_nodes:nodes,_key:undefined,_rows:undefined,_indexes:undefined},cleaned};}
 const trim=(old,next)=>{let start=0,end=Math.min(old.length,next.length);while(start<end&&old[start]===next[start])start++;end=old.length;let newEnd=next.length;while(end>start&&newEnd>start&&old[end-1]===next[newEnd-1]){end--;newEnd--;}return {start,end,newEnd};};
 const cases=[],wide=Array.from({length:80},(_,i)=>i+1);
 for(const size of [4,67,80]){
  const old=wide.slice(0,size);
  for(const distance of [1,2,5,31,33])cases.push([old,[...old.slice(distance),...old.slice(0,distance)],0]);
  cases.push([old,old.slice().reverse(),0],[old,old.filter((_,i)=>i%4!==0),0],[old,old.map(v=>v+100),0],[old,old.slice(),0]);
 }
 cases.push([wide.map(v=>v===41?1:v),[...wide.slice(1),1].map(v=>v===41?1:v),0]);
 cases.push([wide,wide.map((v,i)=>i===0?wide[70]:i===70?wide[0]:v),0]);
 cases.push([wide,wide.map((v,i)=>i===0?999:i===70?wide[0]:v),0]);
 cases.push([wide.map(v=>v===41?NaN:v),[...wide.slice(1),1].map(v=>v===41?NaN:v),0]);
 cases.push([wide,[...wide.slice(32),...wide.slice(0,32)],0],[wide,wide.filter((_,i)=>i>=31&&i!==75),0],[wide,wide.filter((_,i)=>i>=32&&i!==75),0]);
 let small=0,branches=0;
 for(const [oldInput,nextInput,start]of cases){
  const old=normalize(oldInput),next=normalize(nextInput);
  const a=data(old),beforeMappings=a.data._mappings,beforeItems=a.data._items,applied=S.trySmallMove(a.data,next,next.length,start),pair=B.direct(encode(old),encode(next),start),w=pair.left,plan=pair.right;
  assert.equal(w.fault.$,'Healthy');assert.equal(plan.applied,applied,'small-move branch');
  assert.deepEqual(array(w,state(w).mappings),a.data._mappings,'small mapped values');assert.deepEqual(nodeLabels(w),a.data._nodes.map(n=>n.id),'small row identities');assert.equal(state(w).len,a.data._len);assert.deepEqual(array(w,state(w).items),a.data._items);
  assert.equal(state(w).mappings!==1,applied);assert.equal(state(w).items!==0,applied);assert.equal(a.data._mappings!==beforeMappings,applied);assert.equal(a.data._items!==beforeItems,applied);
  const consumed=list(plan.consumed),srcPos=list(plan.srcPos),oldNodes=list(plan.oldNodes);assert.deepEqual(srcPos.flatMap((p,i)=>consumed[i]?[]:[oldNodes[p]]),a.cleaned,'unmatched disposal order');small++;
  if(old.length>=67&&next.length&&next.length<=old.length){
   const {start,end,newEnd}=trim(old,next),m=start+Math.floor((newEnd-start-1)/2),hi=Math.min(end-1,m+32);let k=Math.max(start,m-32);while(k<=hi&&old[k]!==next[m])k++;
   const eligible=end-start>65,probe=eligible&&k<=hi;
   if(eligible)assert.equal(B.probe(encode(old),encode(next),start,end,newEnd),probe,'pre-scan probe');
   const n=data(old),expected=start===next.length&&old.length===next.length?false:probe&&S.trySmallMove(n.data,next,next.length,start);
   const machine=B.branch(encode(old),encode(next),start,end,newEnd),task=list(machine.tasks)[0];
   assert.equal(task?.$==='MapSmallCleanup',expected,'core return point must actually select fast path');branches++;
  }
 }
 let removals=0,windows=0;
 for(const oldInput of [[1,2,3,4],[1,2,1,3],[NaN,1,NaN,2],[{ref:1},{ref:2},{ref:1}]]){
  const old=normalize(oldInput);
  for(const next of [old.slice(1),old.slice(0,2),old.filter((_,i)=>i%2),[old.at(-1),old[0]],[8,9],[]]){
   const {start,end,newEnd}=trim(old,next),n=data(old),temp=new Array(next.length),nodes=new Array(Math.max(0,newEnd-start));
   const removed=S.stageRemoval(n.data,next,start,end-1,newEnd-1,temp,nodes,undefined,undefined),machine=B.removal(encode(old),encode(next),start,end,newEnd),task=list(machine.tasks)[0],frame=task.frame;
   assert.equal(machine.world.fault.$,'Healthy');assert.equal(task.$==='MapCommitPrefix',removed!==null,'pure-removal verdict '+JSON.stringify({old,next,start,end,newEnd}));assert.deepEqual(array(machine.world,frame.mappings),temp,'removal scratch mappings');assert.deepEqual(list(frame.nodes),Array.from(nodes,n=>n?.id??0),'removal owner scratch/reset');assert.deepEqual(list(frame.removed),removed?.map(n=>n.id)??[]);removals++;
  }
 }
 for(const [oldLen,newLen,start,end,newEnd]of [[8,10,2,5,7],[8,6,1,5,3],[8,8,2,6,6],[4,8,0,4,8],[8,4,0,8,4],[8,5,5,8,5],[5,8,5,5,8]]){
  const old=Array.from({length:oldLen},(_,i)=>i+1),next=Array.from({length:newLen},(_,i)=>i+10),n=data(old),nodes=Array.from({length:newEnd-start},(_,i)=>({id:oldLen+i+1}));
  S.commitWindow(n.data,next,newLen,start,end-1,newEnd-1,nodes,undefined,undefined);
  const machine=B.window(encode(old),encode(next),start,end,newEnd);
  assert.equal(machine.world.fault.$,'Healthy');assert.deepEqual(nodeLabels(machine.world),n.data._nodes.map(n=>n.id),'commitWindow live suffix shift');assert.equal(state(machine.world).len,oldLen,'probe stops before caller publication');windows++;
 }
 for(const p of [0,1,31,79,33554431,33554432,67108863])assert.equal(B.fits(25,p),p<33554432,'signed packing admission');
 console.log(`${small} actual trySmallMove states, ${branches} core fast-path return points, ${removals} actual stageRemoval states and ${windows} actual commitWindow states agree; packing-overflow admission remains explicit.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
