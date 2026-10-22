// Source-only repro; the Bend public grammar does not admit createDeferred yet.
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const fixed=process.argv.includes('--expect-fixed'),entry=process.argv.slice(2).find(x=>!x.startsWith('--'));
const S=await import(entry?pathToFileURL(path.resolve(entry)):new URL('../../build/solid.mjs',import.meta.url));
const cases=[];
for(const deferred of[false,true])for(const seeded of[false,true]){
 let read,write,dispose;S.createRoot(d=>{dispose=d;const[get,set]=S.createSignal(0);write=set;read=(deferred?S.createDeferred:S.createMemo)(()=>{const current=get();return S.from(next=>next(current));},seeded?{loadingValue:-1}:undefined);});
 try{
  S.flush();assert.equal(read(),0);write(1);S.flush();let value,error;try{value=read();}catch(e){error=e.message;}
  if(deferred&&!fixed)assert.match(error??'',/p\.then is not a function/);else{assert.equal(error,undefined);assert.equal(value,1);}
  cases.push({deferred,seeded,initial:0,...(error?{error}:{value})});
 }finally{dispose();S.resetErrorHalt();S.flush();}
}
console.log(JSON.stringify({expectFixed:fixed,cases}));
