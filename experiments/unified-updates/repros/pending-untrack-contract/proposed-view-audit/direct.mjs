import fs from 'node:fs';
import {createRoot,createMemo,createSignal,createRenderEffect,isPending,latest,untrack,flush} from '/workspace/layered-next-4fe75321/packages/signals/dist/dev.js';
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
   const probe=()=>{if(name==='wrapped')({inside,sampled}=untrack(memos.pending));else sampled=untrack(()=>isPending(()=>latest(()=>inside=id())));};
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
const result=await run(['data','pending','direct','wrapped','async'],['live','direct','wrapped','async'],0);
console.log(JSON.stringify(result,null,2));
fs.writeFileSync(new URL('./direct-results.json',import.meta.url),JSON.stringify(result,null,2));
