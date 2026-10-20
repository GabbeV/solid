// Reduced source-only counterexample. No Bend adapter or private TS rewrite.
// Current default checks the merged fix; --baseline checks the historical pin.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
const baseline=process.argv.includes('--baseline');
const reference=process.env.SOLID_REFERENCE??new URL('../../build/solid.mjs',import.meta.url).href;
const immediate=value=>({then(yes){return yes?.(value);}});
const rows=[];
for(const outer of ['direct','immediate','native'])for(const step of ['bare','immediate','native'])for(const nonempty of [false,true]){
  const S=await import(reference+'?empty-flatten-repro='+rows.length);
  let cursor=0,dispose;
  const iterable={ [Symbol.asyncIterator](){return {next(){
    const result=nonempty&&cursor++===0?{done:false,value:7}:{done:true,value:99};
    return step==='bare'?result:step==='immediate'?immediate(result):Promise.resolve(result);
  }};}};
  let read;
  S.createRoot(d=>{dispose=d;read=S.createMemo(()=>outer==='direct'?iterable:outer==='immediate'?immediate(iterable):Promise.resolve(iterable));S.createRenderEffect(read,()=>{});});
  await setImmediate();S.flush();
  const value=read(),actual=value===iterable?'iterable object':value;
  const expected=nonempty?7:baseline&&outer==='immediate'&&step!=='native'?'iterable object':undefined;
  assert.equal(actual,expected,`${outer} / ${step} / nonempty=${nonempty}`);
  rows.push({outer,step,nonempty,actual:actual===undefined?'undefined':actual});dispose();S.flush();
}
if(process.argv.includes('--json'))console.log(JSON.stringify(rows,null,2));
else console.log(`${rows.length} source-only empty-flatten controls pass (${baseline?'historical object leak':'upstream empty-stream fix'}); direct/native/one-yield controls settle as expected.`);
