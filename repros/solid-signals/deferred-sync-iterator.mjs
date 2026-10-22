// Generic deferred-wrapper repro: no from() adapter is involved.
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const fixed=process.argv.includes('--expect-fixed');
const entry=process.argv.slice(2).find(arg=>!arg.startsWith('--'));
const S=await import(entry?pathToFileURL(path.resolve(entry)):new URL('../../build/solid.mjs',import.meta.url));
const cases=[];
for(const deferred of[false,true])for(const promised of[false,true]){
  let value,setStep,dispose;
  S.createRoot(stop=>{
    dispose=stop;
    const [step,set]=S.createSignal(0);setStep=set;
    value=(deferred?S.createDeferred:S.createMemo)(()=>{
      const current=step();
      if(current===0)return 0;
      if(promised)return {async *[Symbol.asyncIterator](){yield current;}};
      return {*[Symbol.asyncIterator](){yield current;}};
    });
  });
  try{
    S.flush();assert.equal(value(),0);setStep(1);S.flush();
    await new Promise(resolve=>setTimeout(resolve,0));
    let answer,error;
    try{answer=value();}catch(cause){error=cause.message;}
    if(deferred&&!promised&&!fixed)assert.match(error??'',/p\.then is not a function/);
    else{assert.equal(error,undefined);assert.equal(answer,1);}
    cases.push({deferred,promised,...(error?{error}:{value:answer})});
  }finally{dispose();S.resetErrorHalt();S.flush();}
}
console.log(JSON.stringify({expectFixed:fixed,cases}));
