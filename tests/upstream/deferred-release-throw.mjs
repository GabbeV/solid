// Source-only regression introduced by #4164. The thrown cleanup is caught;
// a later, unrelated lazy memo must still release when its observer is disposed.
import assert from 'node:assert/strict';
const reference=process.env.SOLID_REFERENCE??new URL('../../build/solid.mjs',import.meta.url).href;
const fixed=!process.argv.includes('--expect-broken'),rows=[];
for(const throws of [false,true]){
 const S=await import(reference+'?deferred-release-throw='+throws);
 let bump,disposeBroken,disposeOther,releaseObserver,cleaned=0;
 S.createRoot(dispose=>{
  disposeBroken=dispose;
  const [tick,setTick]=S.createSignal(0);bump=setTick;
  S.createMemo(()=>{tick();S.onCleanup(()=>{if(throws)throw 99;});return new Promise(()=>{});});
 });
 S.flush();bump(1);let escaped;try{S.flush();}catch(e){escaped=e;}
 S.createRoot(dispose=>{
  disposeOther=dispose;
  const lazy=S.createMemo(()=>{S.onCleanup(()=>cleaned++);return 1;},{lazy:true});
  S.createRoot(dispose=>{releaseObserver=dispose;S.createRenderEffect(lazy,()=>{});});
 });
 S.flush();releaseObserver();S.flush();
 assert.equal(escaped,throws?99:undefined,'the first cleanup error is already caught');
 assert.equal(cleaned,throws&&!fixed?0:1,'later lazy cleanup after its last observer is disposed');
 rows.push({throws,escaped:escaped??null,cleaned});
 disposeOther();try{disposeBroken();}catch{}S.resetErrorHalt();S.flush();
}
if(process.argv.includes('--json'))console.log(JSON.stringify(rows,null,2));
else console.log(`${rows.length} Source deferred-release throw controls ${fixed?'check cleanup restoration':'preserve the upstream collector-leak regression'}.`);
