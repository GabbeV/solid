import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-question-probe-'));
try{
 const emitted=path.join(dir,'question.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/question.bend','-o',emitted],{cwd:root,encoding:'utf8'});
 assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
 const encode=n=>n===0n?B.zero():n%2n?B.odd(encode((n-1n)/2n)):B.even(encode((n-2n)/2n));
 const decode=q=>q.$==='QuestionZero'?0n:q.$==='QuestionOdd'?2n*decode(q.half)+1n:2n*decode(q.half)+2n;
 const special=[(1n<<31n)-2n,(1n<<31n)-1n,1n<<31n,(1n<<32n)-1n,(1n<<48n)-1n,1n<<80n,1n<<128n];
 for(const n of [...Array.from({length:4096},(_,i)=>BigInt(i)),...special]){
  const q=encode(n),next=B.increment(q);assert.equal(decode(q),n);assert.equal(decode(next),n+1n);assert.equal(B.equal(q,q),true);assert.equal(B.equal(q,next),false);
 }
 assert.equal(decode(B.mainline()),0x7fffffffn);
 assert.equal(B.equal(B.increment(encode(0x7ffffffen)),B.mainline()),true,'the numeric identity at the mainline value must not be a distinct action tag');
 const source=path.join(root,'upstream/solid/packages/signals/src'),bundle=await build({stdin:{contents:`export * from './index.ts';export {computed,setContextInternal} from './core/core.ts';export {handleAsync} from './core/async.ts';export {nextQuestion,setQuestion,question,MAINLINE_QUESTION,probeQuestions} from './core/scheduler.ts';`,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'question-counter-start',setup(b){b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport function probeQuestions(value){questions=value;}'}));}}]});
 const file=path.join(dir,'solid.mjs');fs.writeFileSync(file,bundle.outputFiles[0].text);const S=await import(pathToFileURL(file));let w=B.initial(),counter=0;
 for(let i=0;i<4096;i++){
  const pair=B.next(w);w=pair.left;assert.equal(Number(decode(pair.right)),S.nextQuestion());assert.equal(decode(w.question),0n,'nextQuestion must not install the ambient question');counter++;
 }
 let boundaries=0;
 for(const n of special.filter(n=>n<(1n<<49n))){
  S.probeQuestions(Number(n));w=B.primeCounter(w,encode(n));const pair=B.next(w);w=pair.left;
  assert.equal(Number(decode(pair.right)),S.nextQuestion());assert.equal(decode(w.question),0n);boundaries++;
 }
 let registration=0;
 for(const n of [...Array.from({length:64},(_,i)=>BigInt(i)),...special.filter(n=>n<(1n<<49n))]){
  S.setQuestion(Number(n));w=B.set(w,encode(n));assert.equal(Number(decode(w.question)),S.question);
  let actual;S.createRoot(dispose=>{const node=S.computed(()=>0,{lazy:true});S.setContextInternal(node);S.handleAsync(node,{then:yes=>yes(11)});actual=node._x._q;S.setContextInternal(null);dispose();});
  assert.equal(Number(decode(B.register(encode(n)))),actual);registration++;
 }
 console.log(`${counter} source question-counter steps, ${boundaries} large counter boundaries and ${registration} flight provenance cases match TS; exact binary increment/equality also pass 4103 integer vectors, including the mainline identity and large mathematical IDs.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
