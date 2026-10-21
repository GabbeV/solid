// Finite source/canonical correspondence for the independently quantified
// arbitrary-length scalar-memo theorem. These controls do not prove induction.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-memo-history-controls-'));
const list=items=>items.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
try{
 const modules={};
 for(const [name,file]of [['D','memo-history-driver'],['H','memo-history-public'],['M','memo-history-states'],['V','memo-driver']]){
  const output=path.join(dir,file+'.mjs');
  const built=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','proof/'+file+'.bend','-o',output],{cwd:root,encoding:'utf8'});
  assert.equal(built.status,0,built.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const {D,H,M,V}=modules,values=[0,1,17,255,65535,2**32+3,2**48-2];
 let programs=0,prefixes=0,passes=0;
 for(const initial of values)for(const length of [0,1,2,3,8,32,127]){
  const first=values[(programs+2)%values.length],constructorExtra=programs%3?0:242,firstExtra=programs%5;
  const tail=Array.from({length},(_,i)=>({$:'Update',value:i%4===0?first:values[(i+programs)%values.length],extra:i%7}));
  const S=await import('../build/solid.mjs?memo-history='+programs);
  let read,set,derived;
  const dispose=S.createRoot(dispose=>{
   [read,set]=S.createSignal(initial,{equals:false});derived=S.createMemo(()=>read()+1,{equals:false});return dispose;
  });
  try{
   set(first);assert.deepEqual([read(),derived()],[initial,initial+1]);S.flush();
   for(let k=0;k<=tail.length;k++){
    const updates=list(tail.slice(0,k)),expected=k?tail[k-1].value:first;
    const world=D.program(initial,first,constructorExtra,firstExtra,updates);
    assert.deepEqual(world,H.result(updates,0,first,H.initialEvents(initial,first),list([{$:'FlushJob'}])),'complete canonical World with actual clocks, generations, trace and queued jobs');
    assert.deepEqual(V.view(world),V.expected(expected));
    assert.deepEqual([read(),derived()],[expected,expected+1]);
    assert.deepEqual([V.view(world).source.n,V.view(world).memo.n],[read(),derived()]);
    prefixes++;
    if(k<tail.length){set(tail[k].value);assert.deepEqual([read(),derived()],[expected,expected+1]);S.flush();}
   }
  }finally{dispose();S.flush();}
  programs++;
 }
 // The reusable lemma admits arbitrary existing trace/job prefixes and counters.
 // These are synthetic canonical-state probes, separate from public programs.
 for(const tick of [0,1,2,17,255,65535])for(const previous of [0,17])for(const input of [0,17,65535]){
  const events=list([{$:'Invoked',id:99},{$:'ReadValue',reader:71,source:44,value:{$:'Number',n:previous}}]);
  const jobs=list([{$:'FlushJob'},{$:'FlushJob'},{$:'FlushJob'}]);
  assert.deepEqual(D.update(tick,previous,input,events,jobs,tick%7),M.origin(tick+1,input,H.nextEvents(events,input),H.nextJobs(jobs)));
  passes++;
 }
 console.log(`${programs} finite public scalar-memo programs / ${prefixes} prefixes match complete canonical Worlds and pinned native values; ${passes} separate steady-pass prefix/counter controls pass. Induction is checked separately by the kernel.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
