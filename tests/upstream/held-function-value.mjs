// Original arbitrary-function controls remain source-only. The admitted bound-
// function counterpart also has Bend parity in tests/writable-signals.mjs.
// Defaults to the merged fix; --baseline checks a historical reference bundle.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
const baseline=process.argv.includes('--baseline');
const reference=process.env.SOLID_REFERENCE??new URL('../../build/solid.mjs',import.meta.url).href;
let cases=0;
for(const held of [false,true])for(const memo of [false,true])for(const outcome of ['value','undefined','throw']){
  const S=await import(reference+'?held-function='+cases);
  let release;const request=new Promise(resolve=>release=resolve);let calls=0,updaterCalls=0,previous;
  const original=()=> 'original',derived=()=> 'derived',failure=new Error('replacement was invoked');
  const replacement=()=>{calls++;if(outcome==='throw')throw failure;return outcome==='value'?'replacement':undefined;};
  const app=S.createRoot(dispose=>{
    const [version,setVersion]=S.createSignal(0);
    const [callback,setCallback]=memo?S.createSignal(()=>version()?derived:original):S.createSignal(undefined);
    const slow=S.createMemo(()=>held&&version()?request:0);
    S.createRenderEffect(()=>[version(),callback(),slow()],()=>{});
    return{dispose,setVersion,callback,setCallback};
  });
  try{
    S.flush();app.setVersion(1);S.flush();
    let returned,thrown;
    try{returned=app.setCallback(value=>{updaterCalls++;previous=value;return replacement;});}catch(error){thrown=error;}
    const bug=baseline&&held&&memo;
    assert.equal(updaterCalls,1);
    assert.equal(previous,memo?(held?original:derived):undefined,'updater receives the source-selected frame');
    assert.equal(calls,bug?1:0,'held updater results are data; only the historical bug invokes them');
    if(bug&&outcome==='throw')assert.equal(thrown,failure);
    else{assert.equal(thrown,undefined);assert.equal(returned,bug?(outcome==='value'?'replacement':undefined):replacement);}
    cases++;
  }finally{app.dispose();S.flush();release(1);await setImmediate();}
}
console.log(`${cases} source-only held function-value cases pass (${baseline?'historical extra invocation':'upstream function-value fix'}) with plain-signal/non-held controls.`);
