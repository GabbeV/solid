// Reduced source-only counterexample. No Bend adapter or private TS rewrite.
// Preserves the pinned result, including the surprising object leak.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
const immediate=value=>({then(yes){return yes?.(value);}});
const rows=[];
for(const outer of ['direct','immediate','native'])for(const step of ['bare','immediate','native'])for(const nonempty of [false,true]){
  const S=await import('../../build/solid.mjs?empty-flatten-repro='+rows.length);
  let cursor=0,dispose;
  const iterable={ [Symbol.asyncIterator](){return {next(){
    const result=nonempty&&cursor++===0?{done:false,value:7}:{done:true,value:99};
    return step==='bare'?result:step==='immediate'?immediate(result):Promise.resolve(result);
  }};}};
  let read;
  S.createRoot(d=>{dispose=d;read=S.createMemo(()=>outer==='direct'?iterable:outer==='immediate'?immediate(iterable):Promise.resolve(iterable));S.createRenderEffect(read,()=>{});});
  await setImmediate();S.flush();
  const value=read(),actual=value===iterable?'iterable object':value;
  const expected=nonempty?7:outer==='immediate'&&step!=='native'?'iterable object':undefined;
  assert.equal(actual,expected,`${outer} / ${step} / nonempty=${nonempty}`);
  rows.push({outer,step,nonempty,actual:actual===undefined?'undefined':actual});dispose();S.flush();
}
if(process.argv.includes('--json'))console.log(JSON.stringify(rows,null,2));
else console.log(`${rows.length} source-only empty-flatten controls preserve the pinned immediate-thenable object leak; direct/native/one-yield controls settle as expected.`);
