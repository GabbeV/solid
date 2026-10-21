import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import {createRequire} from 'node:module';
import {setImmediate} from 'node:timers/promises';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
const require=createRequire(new URL('../../package.json',import.meta.url)),{build}=require('esbuild');
const [base,patched,output]=process.argv.slice(2);
assert.ok(base&&patched&&output,'Usage: node repros/solid-signals/benchmark-reaction-fix.mjs BASE_CHECKOUT PATCHED_CHECKOUT OUTPUT_JSON');
const dirs={base,patched},mods={};
const temp=fs.mkdtempSync(path.join(os.tmpdir(),'solid-reaction-benchmark-'));
for(const [name,dir]of Object.entries(dirs)){
 const out=path.join(temp,name+'.mjs');
 await build({entryPoints:[dir+'/packages/signals/dist/prod/index.js'],outfile:out,bundle:true,platform:'node',format:'esm',minify:true});
 mods[name]=await import(pathToFileURL(out));
}
function run(S,shape,n){
 let count=0;
 const start=process.hrtime.bigint();
 S.createRoot(dispose=>{
  const [value,setValue]=S.createSignal(0),read=shape==='derived'?S.createMemo(()=>value()*2):value;
  let track;
  track=S.createReaction(()=>{count++;if(shape==='callback-rearm')track(read);});
  if(shape==='callback-rearm')track(read);
  for(let i=0;i<n;i++){
   if(shape!=='callback-rearm')track(read);
   if(shape!=='replace'){setValue(i+1);S.flush();}
  }
  dispose();S.flush();
 });
 const ms=Number(process.hrtime.bigint()-start)/1e6;
 assert.equal(count,shape==='replace'?0:n);
 return ms;
}
const rows=[];
for(const shape of ['replace','fire','callback-rearm','derived']){
 for(let warm=0;warm<5;warm++)for(const mod of Object.values(mods)){run(mod,shape,4000);await setImmediate();}
 const raw={base:[],patched:[]};
 for(let round=0;round<11;round++)for(const name of round%2?['patched','base']:['base','patched']){
  let total=0;for(let batch=0;batch<40;batch++){total+=run(mods[name],shape,4000);await setImmediate();}raw[name].push(total);
 }
 const median=xs=>[...xs].sort((a,b)=>a-b)[Math.floor(xs.length/2)],base=median(raw.base),patched=median(raw.patched);
 rows.push({shape,iterations:160000,batchSize:4000,warmups:5,rounds:11,baseMedianMs:base,patchedMedianMs:patched,ratio:patched/base,raw});
}
const result={node:process.version,bundler:'esbuild 0.25.12 over built production artifacts, minified',method:'Five 4000-cycle warm-up batches then 11 alternating rounds of 40 measured 4000-cycle batches; host no-op microtasks drained outside measured batches; noisy local microbenchmarks, not an application-performance guarantee.',rows};
fs.writeFileSync(output,JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));

fs.rmSync(temp,{recursive:true,force:true});
