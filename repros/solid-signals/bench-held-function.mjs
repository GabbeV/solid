import assert from 'node:assert/strict';
import {performance} from 'node:perf_hooks';
import {writeFileSync} from 'node:fs';
import {pathToFileURL} from 'node:url';
import {resolve} from 'node:path';
if(!process.argv[2]||!process.argv[3])throw new Error('Usage: node bench-held-function.mjs BASE_MODULE FIXED_MODULE [OUTPUT_JSON]');
const modules={base:await import(pathToFileURL(resolve(process.argv[2]))),fixed:await import(pathToFileURL(resolve(process.argv[3])))};
const updater=previous=>previous+1;
async function batch(S,kind,count){
 let finish;const request=new Promise(r=>finish=r);
 const app=S.createRoot(dispose=>{
  const [a,setA]=S.createSignal(1),[b,setB]=S.createSignal(()=>a()*100);
  const slow=S.createMemo(()=>a()===1?1:request);
  S.createRenderEffect(()=>[a(),b(),slow()],()=>{});
  return{dispose,setA,b,setB};
 });
 try{
  S.flush();app.setA(2);S.flush();
  assert.equal(S.isPending(app.b),true,'synchronous derived memo must be held');
  const start=performance.now();
  if(kind==='value')for(let i=0;i<count;i++)app.setB(i+101);
  else for(let i=0;i<count;i++)app.setB(updater);
  const ms=performance.now()-start;assert.equal(app.b(),100);return ms;
 }finally{app.dispose();S.flush();finish(1);await new Promise(r=>setImmediate(r));}
}
const rows=[];
for(const kind of ['value','updater']){
 for(const S of Object.values(modules))await batch(S,kind,50000);
 const samples={base:[],fixed:[]};
 for(let round=0;round<7;round++)for(const name of round%2?['fixed','base']:['base','fixed'])samples[name].push(await batch(modules[name],kind,200000));
 const median=xs=>[...xs].sort((a,b)=>a-b)[Math.floor(xs.length/2)];
 rows.push({kind,calls:200000,samplesMs:samples,medianMs:{base:median(samples.base),fixed:median(samples.fixed)}});
}
const result={node:process.version,arch:process.arch,platform:process.platform,claim:'Single-process production microbenchmark of held numeric setters, not an application benchmark or performance-equivalence proof.',rows};
if(process.argv[4])writeFileSync(process.argv[4],JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));
