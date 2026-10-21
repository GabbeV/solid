// Typed arrays exercise the same core callback/read machine. These compare
// payload identity, evaluation order and reads; no list reconciliation is here.
import assert from 'node:assert/strict';
import {BendRuntime} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument}),arr=(...array)=>({array}),at=(array,index)=>({arrayAt:{array,index}}),len=arrayLength=>({arrayLength});
let count=0;
async function scenario(name,body){
 const S=await import('../build/solid.mjs?arrays='+count),b=new BendRuntime(),s=new SolidRuntime({module:S});
 try{await body(b,s);assert.deepEqual(b.trace(),s.trace(),name+' trace');assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false]);count++;}
 catch(error){console.error('FAILED arrays: '+name);throw error;}
 finally{for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}}
}
for(const value of [undefined,null,false,true,0,1,NaN,'','text',{ref:8}]){
 await scenario('slots and identity '+String(value),async(b,s)=>{
  const values=[b,s].map(r=>r.evaluate(arr(lit(value),arr(lit(value)))));
  for(const [i,r]of [b,s].entries()){
   assert.equal(r.evaluate(len(lit(values[i]))),2);assert.strictEqual(r.evaluate(at(lit(values[i]),lit(0))),values[i][0]);
   assert.strictEqual(r.evaluate(at(lit(values[i]),lit(1))),values[i][1]);assert.equal(r.evaluate(at(lit(values[i]),lit(99))),undefined);
   assert.equal(r.evaluate({same:[lit(values[i]),lit(values[i])]}),true);assert.equal(r.evaluate({same:[lit(values[i]),arr(lit(value),arr(lit(value)))]}),false);
   assert.equal(r.evaluate({select:[arr(),lit(1),lit(0)]}),1,'empty arrays are truthy');
  }
  assert.deepEqual(b.observe(values[0]),s.observe(values[1]));
 });
}
for(const many of [false,true])for(const index of [0,1,7]){
 await scenario(`captures callback arguments ${many}/${index}`,async(b,s)=>{
  for(const r of [b,s])r.program('make',[['return',arr(arg(index),{arrayLength:arr(arg(0),arg(1))})]]);
  const args=Array.from({length:many?9:2},(_,i)=>lit(i+3)),values=[b,s].map(r=>r.evaluate({call:'make',args}));
  assert.deepEqual(b.observe(values[0]),s.observe(values[1]));assert.deepEqual(b.observe(values[0]),[index<args.length?index+3:undefined,2]);
 });
}
for(const failure of [false,true]){
 await scenario('left-to-right argument effects '+failure,async(b,s)=>{
  for(const r of [b,s]){r.signal('x',0);r.program('first',[['set','x',1],['return',read('x')]]);r.program('last',[['set','x',2],...(failure?[['throw',7]]:[['return',read('x')]])]);}
  const expr=arr({call:'first'},read('x'),{call:'last'},read('x'));
  assert.deepEqual(b.attempt('evaluate',expr),s.attempt('evaluate',expr));
  for(const r of [b,s]){r.flush();assert.equal(r.read('x'),2);}
 });
}
for(const updater of [false,true]){
 await scenario('array signal payload and strict equality '+updater,async(b,s)=>{
  const arrays=[b,s].map(r=>r.evaluate(arr(lit(2),lit(3))));
  for(const [i,r]of [b,s].entries()){
   r.signal('rows',arrays[i]);r.memo('size',len(read('rows')));r.effect('view',at(read('rows'),lit(1)));r.flush();
   const next=r.evaluate(arr(lit(5),lit(8),lit(13)));
   if(updater)r.update('rows',lit(next));else r.set('rows',next);
   assert.strictEqual(r.read('rows'),arrays[i]);r.flush();assert.strictEqual(r.read('rows'),next);assert.equal(r.read('size'),3);assert.equal(r.screen(),8);
   r.set('rows',next);r.flush();
  }
 });
}
await scenario('local signal captured through array expressions',async(b,s)=>{
 const expr={signalScope:{initial:lit(7),body:arr({localRead:0},len(arr({localRead:0})),at(arr({localAccessor:0}),lit(0)))}};
 const values=[b,s].map(r=>r.evaluate(expr));assert.deepEqual(b.observe(values[0]),s.observe(values[1]));
 for(const [i,r]of [b,s].entries())assert.equal(r.evaluate({invoke:lit(values[i][2])}),7);
});
await scenario('arrays survive throw as raw imperative payload',async(b,s)=>{
 const values=[b,s].map(r=>r.evaluate(arr(lit(7),lit(undefined))));
 for(const [i,r]of [b,s].entries()){
  r.program('fail',[['throwExpr',lit(values[i])]]);let caught;try{r.evaluate({call:'fail'});}catch(e){caught=e;}assert.strictEqual(caught,values[i]);
 }
});
console.log(`${count} typed-array histories match pinned TS values, identities, evaluation order, callback/local captures, staged reads and signal equality. External mutation, arbitrary input arrays and array StatusError coercion remain outside this profile.`);
