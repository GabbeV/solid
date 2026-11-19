import fs from 'node:fs';
import {createRoot,createMemo,createSignal,createRenderEffect,isPending,untrack,flush} from '/workspace/layered-next-4fe75321/packages/signals/dist/dev.js';
const permute=a=>a.length?a.flatMap((v,i)=>permute(a.filter((_,j)=>i!==j)).map(p=>[v,...p])):[[]];
const declarations=permute(['data','pending','direct','wrapped','async']).filter(a=>a.indexOf('pending')<a.indexOf('wrapped'));
const renderOrders=permute(['live','direct','wrapped','async']);
const tick=()=>new Promise(resolve=>setImmediate(resolve));
async function run(order,renderOrder,readOrder){
 const answer=Promise.withResolvers();const rows={};const history={};const trace=[];let phase='initial';let setId,setRevision;
 const dispose=createRoot(dispose=>{
  const [id,writeId]=createSignal(0);setId=writeId;
  const [revision,writeRevision]=createSignal(0);setRevision=writeRevision;
  const memos={};
  const sample=(name,mask)=>{
   revision();let value,inside,sampled;
   const probe=()=>{if(name==='wrapped')({inside,sampled}=untrack(memos.pending));else sampled=untrack(()=>isPending(()=>inside=id()));};
   if(readOrder&mask)probe();value=id();if(!(readOrder&mask))probe();
   const result=`${value}/${inside}/${sampled}`;trace.push({phase,name,result});return result;
  };
  const factories={
   data:()=>createMemo(()=>{const v=id();trace.push({phase,name:'data',result:v===0?'0':'promise'});return v===0?0:answer.promise;}),
   pending:()=>createMemo(()=>{let inside;const sampled=isPending(()=>inside=id());trace.push({phase,name:'pending',result:`${inside}/${sampled}`});return{inside,sampled};}),
   direct:()=>createMemo(()=>sample('direct',1)),
   wrapped:()=>createMemo(()=>sample('wrapped',2)),
   async:()=>createMemo(async()=>sample('async',4))
  };
  for(const name of order)memos[name]=factories[name]();
  const observe=(name,fn)=>createRenderEffect(fn,value=>{rows[name]=String(value);const h=history[name]??=[];if(h.at(-1)!==String(value))h.push(String(value));},{schedule:true});
  for(const name of renderOrder){
   if(name==='live'){observe('id',id);observe('data',memos.data);observe('pending',()=>isPending(id));}
   else observe(name,memos[name]);
  }
  return dispose;
 });
 const frames=[];
 try{
  await tick();frames.push({...rows});
  phase='setId';setId(1);await tick();frames.push({...rows});
  phase='revision';setRevision(1);await tick();frames.push({...rows});
  phase='resolve';answer.resolve(1);await tick();await tick();frames.push({...rows});
  return{frames,history,trace};
 }finally{dispose();flush();}
}
const variants=new Map();let total=0;const started=Date.now();
for(const order of declarations)for(const renderOrder of renderOrders)for(let readOrder=0;readOrder<8;readOrder++){
 const result=await run(order,renderOrder,readOrder);
 const normalized={frames:result.frames.map(f=>Object.fromEntries(Object.entries(f).sort())),history:Object.fromEntries(Object.entries(result.history).sort())};
 const key=JSON.stringify(normalized);let variant=variants.get(key);
 if(!variant){variant={count:0,order,renderOrder,readOrder,...result};variants.set(key,variant);}
 variant.count++;total++;if(total%1000===0)console.log(JSON.stringify({total,variants:variants.size,elapsed:Date.now()-started}));
}
const report={runtime:'4fe75321 (same runtime as next 45648f78)',total,elapsed:Date.now()-started,declarationOrders:declarations.length,renderOrders:renderOrders.length,readOrders:8,variants:[...variants.values()]};
fs.writeFileSync(new URL('./results.json',import.meta.url),JSON.stringify(report,null,2));
console.log(JSON.stringify({total,variants:variants.size,elapsed:Date.now()-started,results:report.variants.map(v=>({count:v.count,order:v.order,renderOrder:v.renderOrder,readOrder:v.readOrder,frames:v.frames,history:v.history}))}));
