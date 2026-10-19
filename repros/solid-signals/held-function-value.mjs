import assert from 'node:assert/strict';
import {createMemo,createRenderEffect,createRoot,createSignal,flush} from '@solidjs/signals';
const mode=process.argv[2]??'held';
assert.ok(['held','no-hold','plain'].includes(mode));
let finish,calls=0;
const request=new Promise(resolve=>finish=resolve);
const replacement=()=>{calls++;return 'replacement';};
const app=createRoot(dispose=>{
  const [version,setVersion]=createSignal(0);
  const [callback,setCallback]=mode==='plain'?createSignal(undefined):createSignal(()=>{version();return()=> 'derived';});
  const slow=createMemo(()=>mode!=='no-hold'&&version()?request:0);
  createRenderEffect(()=>[version(),callback(),slow()],()=>{});
  return{dispose,setVersion,setCallback};
});
try{
  flush();app.setVersion(1);flush();
  const result=app.setCallback(()=>replacement);
  console.log({mode,returned:typeof result,returnedOriginal:result===replacement,unexpectedInvocations:calls});
  assert.equal(calls,0,'storing a returned callback must not invoke it');
  assert.equal(result,replacement,'the setter must return the callback value');
}finally{app.dispose();flush();finish(1);await new Promise(resolve=>setImmediate(resolve));}
