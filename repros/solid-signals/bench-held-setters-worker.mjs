import assert from 'node:assert/strict';
import {performance} from 'node:perf_hooks';
import {pathToFileURL} from 'node:url';
const S=await import(pathToFileURL(process.argv[2]));
const test=process.argv[3];
const [domain,kind,mode]=test.split('/');
const up=n=>n+1, down=n=>n-1;
const callbacks=[up,down];
async function batch(count){
 let finish;const request=new Promise(r=>finish=r);
 const app=S.createRoot(dispose=>{
  const [version,setVersion]=S.createSignal(1);
  const [value,setValue]=domain==='plain'?S.createSignal(100):S.createSignal(()=>version()*100);
  if(domain==='held'){
   const slow=S.createMemo(()=>version()===1?1:request);
   S.createRenderEffect(()=>[version(),value(),slow()],()=>{});
  }
  return {dispose,value,setValue,setVersion};
 });
 try{
  S.flush();
  if(domain==='held'){app.setVersion(2);S.flush();assert.equal(S.isPending(app.value),true);}
  let checksum=0;
  const start=performance.now();
  if(mode==='flush'){
   if(kind==='value')for(let i=0;i<count;i++){checksum+=app.setValue(100+(i&1));S.flush();}
   else for(let i=0;i<count;i++){checksum+=app.setValue(up);S.flush();}
  }else{
   if(kind==='value')for(let i=0;i<count;i++)checksum+=app.setValue(100+(i&1));
   else if(kind==='repeat')for(let i=0;i<count;i++)checksum+=app.setValue(up);
   else for(let i=0;i<count;i++)checksum+=app.setValue(callbacks[i&1]);
  }
  const elapsed=performance.now()-start;
  assert.equal(typeof checksum,'number');assert.equal(Number.isFinite(checksum),true);
  if(domain==='held')assert.equal(app.value(),100);
  return {elapsed,checksum};
 }finally{app.dispose();S.flush();finish(1);await new Promise(r=>setImmediate(r));}
}
for(let i=0;i<3;i++)await batch(500000);
const count=mode==='flush'?500000:3000000;
const samples=[];let checksum;
for(let i=0;i<7;i++){const r=await batch(count);samples.push(r.elapsed);checksum=r.checksum;}
console.log(JSON.stringify({test,count,samples,checksum,median:[...samples].sort((a,b)=>a-b)[3]}));
