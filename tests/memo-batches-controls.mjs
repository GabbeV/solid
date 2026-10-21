// Native correspondence for arbitrary batches; quantified list induction and
// exact state/coalescing properties are checked by the independent kernel.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-memo-batches-controls-'));
const list=items=>items.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const array=xs=>{const out=[];while('head'in xs){out.push(xs.head);xs=xs.tail;}return out;};
try{
 const modules={};
 for(const [name,file]of [['D','memo-batches-driver'],['H','memo-batches'],['I','memo-history-public'],['V','memo-driver']]){
  const output=path.join(dir,file+'.mjs');
  const built=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','proof/'+file+'.bend','-o',output],{cwd:root,encoding:'utf8'});
  assert.equal(built.status,0,built.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const {D,H,I,V}=modules,values=[0,1,17,255,65535,2**32+3,2**48-2];
 let programs=0,prefixes=0,writes=0;
 for(const initial of values)for(const length of [0,1,2,5,13]){
  const first=values[(programs+2)%values.length],constructorExtra=programs%2?0:242,firstExtra=programs%5;
  const firstRest=Array.from({length:[0,1,2,8,31][programs%5]},(_,i)=>i%3?values[(i+programs)%values.length]:initial);
  const batches=Array.from({length},(_,i)=>({$:'Batch',first:values[(i+programs+1)%values.length],rest:list(Array.from({length:[0,1,3,7][i%4]},(_,j)=>j%2?first:values[(i+j+programs)%values.length])),extra:i%7}));
  const S=await import('../build/solid.mjs?memo-batches='+programs);
  let read,set,derived,calls=0;
  const dispose=S.createRoot(dispose=>{
   [read,set]=S.createSignal(initial,{equals:false});derived=S.createMemo(()=>{calls++;return read()+1;},{equals:false});return dispose;
  });
  const apply=(proposals,old,oldCalls)=>{
   for(const proposal of proposals){
    set(proposal);writes++;
    assert.deepEqual([read(),derived()],[old,old+1],'intermediate writes preserve committed reads');
    assert.equal(calls,oldCalls,'compute waits for the flush');
   }
   S.flush();assert.equal(calls,oldCalls+1,'the entire batch computes once');
  };
  try{
   apply([first,...firstRest],initial,1);
   const seedValue=firstRest.at(-1)??first;
   let current=seedValue;
   for(let k=0;k<=batches.length;k++){
    const tail=list(batches.slice(0,k)),world=D.program(initial,first,list(firstRest),constructorExtra,firstExtra,tail);
    assert.deepEqual(world,H.result(tail,0,seedValue,I.initialEvents(initial,seedValue),list([{$:'FlushJob'}])),'exact World including only one scheduling job and one computation per batch');
    assert.deepEqual(V.view(world),V.expected(current));
    assert.deepEqual([read(),derived()],[current,current+1]);
    assert.equal(array(world.events).filter(e=>e.$==='Invoked').length,k+2);
    assert.equal(array(world.hostJobs).length,k+1);
    prefixes++;
    if(k<batches.length){
     const batch=batches[k],proposals=[batch.first,...array(batch.rest)];
     apply(proposals,current,calls);current=proposals.at(-1);
    }
   }
  }finally{dispose();S.flush();}
  programs++;
 }
 console.log(`${programs} finite batched scalar-memo programs / ${prefixes} completed prefixes and ${writes} writes match pinned native committed reads, one computation per batch, exact canonical Worlds and scheduling-job counts. Induction is checked separately by the kernel.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
