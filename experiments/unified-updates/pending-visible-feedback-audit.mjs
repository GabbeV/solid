import { pathToFileURL } from 'node:url';
const {createRoot,createSignal,createMemo,createRenderEffect,isPending,flush} = await import(pathToFileURL(process.argv[2]));
const results=[];
for (const order of [process.argv[3] || 'count-first']) {
 const request=Promise.withResolvers();
 const shown={}, calls=[];
 let write,dispose;
 createRoot(d=>{
  dispose=d;
  const [count,setCount]=createSignal(0); write=setCount;
  const data=createMemo(()=>{
   let n,pending;
   if(order==='count-first') {n=count();pending=isPending(count);}
   else {pending=isPending(count);n=count();}
   calls.push({n,pending});
   const answer={value:n*10,pending};
   return n===0?answer:request.promise.then(()=>answer);
  });
  for(const [key,read] of Object.entries({count,data,pending:()=>isPending(count)}))
   createRenderEffect(read,v=>{shown[key]=v},{schedule:true});
 });
 flush();write(1);flush();await new Promise(r=>setTimeout(r,0));
 const held=structuredClone({shown,calls});
 request.resolve();await new Promise(r=>setTimeout(r,0));
 results.push({order,held,settled:structuredClone({shown,calls})});
 dispose();flush();
}
console.log(JSON.stringify(results,null,2));
