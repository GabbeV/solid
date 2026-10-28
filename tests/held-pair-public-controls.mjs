// Public paired generators on real Solid and the port. Finite correspondence
// controls are separate from the quantified internal-prefix proofs.
import assert from 'node:assert/strict';
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import {build} from 'esbuild';import {pathToFileURL,fileURLToPath} from 'node:url';
import {BendRuntime,list} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-held-pair-public-'));
try {
 const bundle=await build({stdin:{contents:"export * from './index.ts';export {setContextInternal} from './core/core.ts';export {flushTransaction} from './core/scheduler.ts';",resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}});
 const native=path.join(dir,'native.mjs');fs.writeFileSync(native,bundle.outputFiles[0].text);const S=await import(pathToFileURL(native)),tick=()=>new Promise(resolve=>setImmediate(resolve));
 const sequences=[[],[0],[false],[1,0,'']];let cases=0;
 const write=value=>({invokeWith:{callee:{lit:{setter:'x'}},value:{lit:value},updater:true}});
 for(const first of [0,1])for(const rejected of [false,true])for(const left of sequences)for(const right of sequences){
  S.setContextInternal(null);const inputs=[Promise.withResolvers(),Promise.withResolvers()],values=[left,right],seen=[],groups=[];let get,set,dispose;
  S.createRoot(d=>{dispose=d;[get,set]=S.createSignal(0);const memo=S.createMemo(get);S.createRenderEffect(memo,value=>{seen.push(value);});});S.flush();
  const port=new BendRuntime({async:true});port.signal('x',0);port.memo('memo',{read:'x'});port.effect('view',{read:'memo'});port.flush();port.future('a');port.future('b');
  const nativeResults=[],portResults=[];
  for(const actor of [0,1]){
   nativeResults[actor]=S.action(function*(){set(actor+1);groups[actor]=S.flushTransaction;try{yield inputs[actor].promise;}catch{}for(const value of values[actor])set(()=>value);return 'result '+actor;})();nativeResults[actor].catch(()=>{});
   const name=actor?'b':'a',initial={seq:[write(actor+1),{iteratorResult:{done:false,value:{future:name}}}]},body={seq:[...values[actor].map(write),{iteratorResult:{done:true,value:{lit:'result '+actor}}}]};
   portResults[actor]=port.runAction('pair '+actor,{steps:[{next:initial},{next:body,throw:body}]});portResults[actor].catch(()=>{});
  }
  S.flush();port.flush();let portGroup=list(port.world.actions)[1].transaction;const arena=list(port.world.txArena);for(let hops=0;arena[portGroup].into;hops++){assert.ok(hops<arena.length);portGroup=arena[portGroup].into;}assert.deepEqual(seen,[0]);assert.equal(groups[1]._open,2);assert.equal(arena[portGroup].open,2);
  let latest=2;
  for(const [index,actor]of [first,1-first].entries()){
   const name=actor?'b':'a';if(rejected){inputs[actor].reject('input failed');port.reject(name,'input failed');}else{inputs[actor].resolve('input');port.resolve(name,'input');}
   for(const value of values[actor])latest=value;
   await tick();assert.equal(groups[1]._open,1-index);assert.equal(list(port.world.txArena)[portGroup].open,1-index);
   if(index===0)assert.deepEqual(seen,[0],'first completion must remain blocked by the other action');
   assert.deepEqual(port.trace().filter(e=>e[0]==='apply'&&e[1]==='view').map(e=>e[2]),seen);
  }
  assert.ok(Object.is(get(),latest));assert.ok(Object.is(port.read('x'),latest));assert.ok(Object.is(seen.at(-1),latest));assert.ok(seen.slice(1).every(value=>Object.is(value,latest)),'only the final group value may be rendered');
  assert.deepEqual(await Promise.all(portResults),await Promise.all(nativeResults));dispose();port.dispose();S.flush();port.flush();cases++;
 }
 assert.equal(cases,64);console.log(JSON.stringify({publicNativePortPairs:cases,completionOrders:2,fulfilledAndCaughtRejected:true,liveDebtSequence:[2,1,0],firstCompletionRetainsRenderedZero:true,finalRevealMatchesNative:true,scope:'finite actual public generator/memo/render histories; no equivalence theorem or arbitrary host-history claim'}));
}finally{fs.rmSync(dir,{recursive:true,force:true});}
