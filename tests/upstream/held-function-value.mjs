// Source-only evidence. The writable-memo overload is not yet in Bend's ABI.
// Preserve the actual bug and passing controls; never patch the vendored source.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
let cases=0;
for(const held of [false,true])for(const memo of [false,true])for(const outcome of ['value','undefined','throw']){
  const S=await import('../../build/solid.mjs?held-function='+cases);
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
    const bug=held&&memo;
    assert.equal(updaterCalls,1);
    assert.equal(previous,memo?(held?original:derived):undefined,'updater receives the source-selected frame');
    assert.equal(calls,bug?1:0,'only the held writable-memo path invokes the returned function');
    if(bug&&outcome==='throw')assert.equal(thrown,failure);
    else{assert.equal(thrown,undefined);assert.equal(returned,bug?(outcome==='value'?'replacement':undefined):replacement);}
    cases++;
  }finally{app.dispose();S.flush();release(1);await setImmediate();}
}
console.log(`${cases} source-only held function-value cases preserve the unexpected invocation and plain-signal/non-held controls.`);
