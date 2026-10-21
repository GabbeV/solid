// Source-only control for merged #4195 / report #4189. Projection families and
// active boundaries are still outside the Bend profile. This never claims port
// coverage; unchanged upstream Vitest controls were also run before/after repin.
import assert from 'node:assert/strict';
import {setTimeout} from 'node:timers/promises';
for(const nested of [false,true]){
 const S=await import('../../build/solid.mjs?projection-reject='+nested);
 const screen={value:undefined};
 const dispose=S.createRoot(dispose=>{
  const [version,setVersion]=S.createSignal(0,{ownedWrite:true});
  const entry={loading:false,error:undefined,promise:undefined};let chained;
  const stable=base=>chained?.base===base?chained.value:(chained={base,value:base.then(value=>({value}))}).value;
  const load=()=>{
   entry.loading=true;
   entry.promise=Promise.resolve().then(()=>{entry.loading=false;entry.error=new Error('failed');setVersion(v=>v+1);throw entry.error;});
   setVersion(v=>v+1);return entry.promise;
  };
  const store=S.createProjection(()=>{version();if(entry.loading)return stable(entry.promise);if(entry.error)throw entry.error;return stable(load());},{});
  const errored=S.createErrorBoundary(()=>S.untrack(()=>S.createLoadingBoundary(()=>{
   if(!nested)return String(store.value);
   const span={text:undefined};S.createRenderEffect(()=>String(store.value),value=>{span.text=value;});return span;
  },()=>'loading')),error=>'errored: '+error().message);
  S.createRenderEffect(errored,value=>{screen.value=value;});return dispose;
 });
 try{S.flush();await setTimeout(20);S.flush();assert.equal(screen.value,'errored: failed',nested?'nested read':'direct control');}
 finally{dispose();S.flush();}
}
console.log('2 source-only projection-rejection controls pass the merged in-flush error publication fix; projection/boundary engines remain unported.');
