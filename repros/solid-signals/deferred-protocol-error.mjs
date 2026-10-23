// Native source regression/control matrix. No candidate fix is installed.
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const fixed=process.argv.includes('--expect-fixed');
const entry=process.argv.slice(2).find(arg=>!arg.startsWith('--'));
const url=entry?pathToFileURL(path.resolve(entry)):new URL('../../build/solid.mjs',import.meta.url);
const delay=(ms,result)=>new Promise(resolve=>setTimeout(resolve,ms,result));
const cases=[];
for(const deferred of[false,true])for(const where of['body','factory','next','async-next','later-next'])for(const prior of[false,true])for(const waiter of['until','refresh']){
  const S=await import(url+'?deferred-protocol='+cases.length);
  const error=new Error('stream failed'),old=Promise.withResolvers(),outcomes=[],controller=new AbortController();
  let value,setStep,dispose;
  S.createRoot(stop=>{
    dispose=stop;
    const [step,set]=S.createSignal(0);setStep=set;
    value=(deferred?S.createDeferred:S.createMemo)(()=>{
      if(step()===0)return 0;
      if(step()===1)return old.promise;
      if(where==='body')throw error;
      return {[Symbol.asyncIterator](){
        if(where==='factory')throw error;
        let first=true;
        return {next(){
          if(where==='async-next')return Promise.reject(error);
          if(where==='later-next'&&first){first=false;return {done:false,value:1};}
          throw error;
        }};
      }};
    });
  });
  try{
    // Automatic scheduling matches the JSX repro; flush is unnecessary here.
    if(prior){setStep(1);await delay(0);}
    setStep(2);await delay(0);
    const result=S[waiter](value,{signal:controller.signal});
    void(async()=>{try{outcomes.push({value:await result});}catch(reason){outcomes.push({originalError:reason===error});}})();
    await delay(0);
    const stuck=deferred&&(where==='next'||(where==='factory'&&prior))&&!fixed;
    const before=structuredClone(outcomes),pendingBefore=S.isPending(value);
    assert.deepEqual(before,stuck?[]:[{originalError:true}],JSON.stringify({deferred,where,prior,waiter,before}));
    assert.equal(pendingBefore,stuck);
    old.resolve(9);await delay(0);
    const stillStuck=stuck&&where==='next',after=structuredClone(outcomes),pendingAfter=S.isPending(value);
    assert.deepEqual(after,stillStuck?[]:[{originalError:true}]);
    assert.equal(pendingAfter,stillStuck);
    cases.push({deferred,where,prior,waiter,before,pendingBefore,after,pendingAfter});
  }finally{
    controller.abort();old.resolve(9);dispose();S.resetErrorHalt();S.flush();await delay(0);
  }
}
console.log(JSON.stringify({expectFixed:fixed,cases}));
