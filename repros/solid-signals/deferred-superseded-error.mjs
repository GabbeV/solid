// Native Solid only. The optional entry selects an isolated candidate build.
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const fixed=process.argv.includes('--expect-fixed'),entry=process.argv.slice(2).find(x=>!x.startsWith('--'));
const S=await import(entry?pathToFileURL(path.resolve(entry)):new URL('../../build/solid.mjs',import.meta.url));
async function settle(){for(let i=0;i<8;i++)await Promise.resolve();S.flush();for(let i=0;i<8;i++)await Promise.resolve();}
const cases=[];
for(const waiter of['until','refresh'])for(const seeded of[false,true])for(const priorFlight of[false,true]){
 const error=new Error('current request failed'),outcomes=[];let finish;
 const [mode,setMode]=S.createSignal(0);
 const {value,dispose}=S.createRoot(dispose=>({dispose,value:S.createDeferred(()=>{const current=mode();if(current===2)throw error;return current===1?new Promise(resolve=>finish=resolve):7;},seeded?{loadingValue:0}:undefined)}));
 try{
  S.flush();if(priorFlight){setMode(1);S.flush();}setMode(2);S.flush();
  const promise=waiter==='until'?S.until(value):S.refresh(value);promise.then(value=>outcomes.push({value}),reason=>outcomes.push({error:reason===error}));await settle();
  const before=outcomes.map(x=>({...x}));assert.deepEqual(before,priorFlight&&!fixed?[]:[{error:true}]);
  if(priorFlight){finish(21);await settle();assert.deepEqual(outcomes,[{error:true}]);}
  cases.push({waiter,seeded,priorFlight,beforeObsoleteSettles:before,afterObsoleteSettles:outcomes});
 }finally{finish?.(21);await settle();dispose();S.flush();}
}
console.log(JSON.stringify({expectFixed:fixed,cases}));
