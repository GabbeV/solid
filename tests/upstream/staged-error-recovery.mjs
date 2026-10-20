// Reduced source-only baseline and paired controls. No Bend adapter, private
// source export, function rewrite, lane/action scope or candidate fix is used.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
const baseline=process.argv.includes('--baseline');
const reference=process.env.SOLID_REFERENCE??new URL('../../build/solid.mjs',import.meta.url).href;
const rows=[];
for(const delivery of ['immediate','native'])for(const variant of ['no-error','no-recovery','same-recovery','changed-recovery']){
 const S=await import(reference+'?staged-error-recovery='+rows.length),escaped=[],reports=[],seen=[];
 const original=console.error;console.error=(...args)=>reports.push(args);
 let complete;
 const q=delivery==='immediate'?{then(yes){complete=value=>{try{yes(value);}catch(e){escaped.push(e);}};}}:(()=>{
  let finish;const promise=new Promise(resolve=>{finish=resolve;});complete=finish;
  // Host observation of the source callback's rejected continuation; the
  // callback itself and the native Promise reaction order are unchanged.
  return {then(yes,no){return promise.then(yes,no).catch(e=>{escaped.push(e);});}};
 })();
 const unwrap=e=>e instanceof Error&&Object.hasOwn(e,'source')&&Object.hasOwn(e,'cause')?e.cause:e;
 let dispose;
 try{
  // Mutations happen outside the root's construction context.
  const app=S.createRoot(d=>{
   dispose=d;const [mode,setMode]=S.createSignal(false),[stage,setStage]=S.createSignal(0);
   const b=S.createMemo(()=>mode()?q:1);
   const a=S.createMemo(()=>{const s=stage();if(s===1)throw 99;return s===2?7:1;});
   const c=S.createMemo(()=>b()+a());
   S.createRenderEffect(c,value=>void seen.push(value));
   return {setMode,setStage,a,c};
  });
  S.flush();app.setMode(true);if(variant!=='no-error')app.setStage(1);S.flush();
  if(variant==='same-recovery')app.setStage(0);
  if(variant==='changed-recovery')app.setStage(2);
  S.flush();const before=app.a();complete(2);await setImmediate();S.flush();
  let result;try{result={returned:app.c()};}catch(e){result={thrown:unwrap(e)};}
  const failed=baseline?variant!=='no-error':variant==='no-recovery',cause=variant==='no-recovery'?99:variant==='changed-recovery'?7:1;
  assert.deepEqual(result,failed?{thrown:cause}:{returned:variant==='changed-recovery'?9:3});
  assert.deepEqual(seen,failed?[2]:[2,variant==='changed-recovery'?9:3]);
  if(failed){assert.deepEqual(escaped.map(unwrap),baseline?[cause]:[]);assert.equal(reports[0][0],'[REACTIVITY_HALTED]');assert.equal(reports[0][1],cause);}
  else{assert.deepEqual(escaped,[]);assert.deepEqual(reports,[]);}
  rows.push({delivery,variant,before,...result,rendered:seen,escaped:escaped.map(unwrap),haltReports:reports.length});
 }finally{dispose?.();S.resetErrorHalt();S.flush();console.error=original;}
}
if(process.argv.includes('--json'))console.log(JSON.stringify(rows,null,2));
else console.log(`${rows.length} source-only staged-error recovery controls pass (${baseline?'historical value-as-error':'upstream recovery fix'}) for immediate and native delivery.`);
