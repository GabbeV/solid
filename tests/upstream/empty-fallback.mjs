// Source-only candidate: successful falsy fallbacks are mistaken for aborted
// fallback creation. Array/list helpers are not yet represented in Bend.
import assert from 'node:assert/strict';
const reference=process.env.SOLID_REFERENCE??new URL('../../build/solid.mjs',import.meta.url).href;
const fixed=process.argv.includes('--expect-fixed'),rows=[];
for(const helper of ['mapArray','repeat'])for(const [label,value]of [['zero',0],['false',false],['null',null],['undefined',undefined],['empty-string',''],['one',1],['text','empty']]){
 const S=await import(reference+'?empty-fallback='+helper+'-'+label);
 let reload,read,created=0,cleaned=0;
 const dispose=S.createRoot(dispose=>{
  const [items,setItems]=S.createSignal([]);reload=()=>setItems([]);
  read=S[helper](helper==='mapArray'?items:()=>items().length,()=>{throw Error('No rows should be mapped');},{fallback:()=>{
   created++;S.onCleanup(()=>cleaned++);return value;
  }});
  return dispose;
 });
 try{
  S.flush();const before={created,cleaned};const output=read();assert.deepEqual(output,[value]);
  reload();S.flush();assert.equal(read(),output,'empty-to-empty retains the mapped array identity');
  const remount=!fixed&&!value;assert.deepEqual({created,cleaned},remount?{created:2,cleaned:1}:{created:1,cleaned:0});
  rows.push({helper,label,before,after:{created,cleaned}});
 }finally{dispose();S.flush();assert.equal(cleaned,created,'owners are eventually cleaned; this is a remount, not an owner leak');}
}
if(process.argv.includes('--json'))console.log(JSON.stringify(rows,null,2));
else console.log(`${rows.length} source-only falsy/truthy fallback controls ${fixed?'check retention':'reproduce empty-to-empty fallback remounts'}.`);
