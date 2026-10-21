// Source-only #4207 controls, adapted from the unchanged upstream regression.
// Active verdict/lane/loading-boundary engines are not implemented in Bend.
import assert from 'node:assert/strict';
import {setTimeout} from 'node:timers/promises';
const reference=process.env.SOLID_REFERENCE??new URL('../../build/solid.mjs',import.meta.url).href;
const settle=async S=>{for(let i=0;i<3;i++){await setTimeout(0);S.flush();}};
for(const pending of process.argv.includes('--settled-control')?[false]:[true,false]){
 const S=await import(reference+'?unread-pending-mount='+pending);
 let slot,screen,inner,release;
 const [x,setX]=S.createSignal(0);
 const dispose=S.createRoot(dispose=>{
  if(pending){
   const content=()=>{
    const [version,setVersion]=S.createSignal(0,{ownedWrite:true});
    setVersion(1);
    S.createMemo(()=>{version();return new Promise(()=>{});}); // deliberately unread
    return 'CHILD';
   };
   const gate=S.createMemo(async()=>'x');
   const outer=S.createLoadingBoundary(()=>{
    const when=S.createMemo(()=>S.latest(gate)??gate());
    const condition=S.createMemo(()=>!!when());
    const children=S.createMemo(()=>condition()?S.untrack(()=>S.createLoadingBoundary(content,()=>'INNER LOADING')):undefined);
    return ()=>{const child=children();return typeof child==='function'?child():child;};
   },()=>'OUTER LOADING');
   S.createRenderEffect(()=>{let value=outer();while(typeof value==='function')value=value();return value;},value=>{slot=value;});
  }else{
   S.createRenderEffect(x,value=>{screen=value;});
   const content=()=>{const double=S.createMemo(()=>x()*2);S.createRenderEffect(double,value=>{inner=value;});return 'p';};
   const when=S.createMemo(()=>S.latest(x)>0);
   const children=S.createMemo(()=>when()?S.untrack(()=>S.createLoadingBoundary(content,()=>'pending')):'closed');
   S.createRenderEffect(()=>{const child=children();return typeof child==='function'?child():child;},value=>{slot=value;});
  }
  return dispose;
 });
 try{
  S.flush();
  if(pending){await settle(S);assert.equal(slot,'CHILD','an unread pending memo must not retain the verdict-mounted loading boundary');}
  else{
   const done=S.action(function*(){setX(1);yield new Promise(resolve=>{release=resolve;});})();
   await settle(S);assert.deepEqual([screen,slot,inner],[0,'pending',undefined],'a read settled memo remains held');
   release();await done;await settle(S);assert.deepEqual([screen,slot,inner],[1,'p',2]);
  }
 }finally{dispose();S.flush();}
}
console.log('Source-only verdict-mount pending/settled controls pass; active mount/lane/boundary engines remain unported.');
