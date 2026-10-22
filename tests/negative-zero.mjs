// Value-representation regression: distinguish payload -0 from +0 while
// retaining JavaScript strict equality, truthiness and signed-zero arithmetic.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const lit=lit=>({lit}),read=read=>({read});let histories=0,operations=0;
async function scenario(commands,inspect){
 const S=await import('../build/solid.mjs?negative-zero='+histories),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S});
 try{for(const[op,...args]of commands){
  if(op==='tick')await setImmediate();else{
   const a=b.attempt(op,...args),e=s.attempt(op,...args);
   if(a[0]==='return'&&e[0]==='return'&&!['set','update','read','evaluate','flush'].includes(op))a[1]=e[1]=undefined;
   assert.deepEqual(a,e,op);assert.deepEqual(b.trace(),s.trace(),op+' trace');inspect?.(op,b,s,e);
  }
 }histories++;}finally{for(const r of[b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}}
}
for(const equals of[true,false])for(const initial of[-0,0]){
 await scenario([['signal','n',initial,equals],['read','n'],['set','n',Object.is(initial,-0)?0:-0],['read','n'],['flush'],['read','n'],['set','n',-0],['flush'],['read','n']],(op,b,s)=>{if(op==='read')assert.equal(Object.is(b.read('n'),-0),Object.is(s.read('n'),-0));});
}
for(const equals of[true,false])await scenario([
 ['signal','n',-0,false],['memo','copy',read('n'),{equals}],['memo','add',{add:[read('n'),lit(0)]},{equals}],['memo','mul',{mul:[read('n'),lit(2)]},{equals}],['render','view','copy'],['flush'],['read','copy'],['read','add'],['read','mul'],['set','n',0],['flush'],['read','copy'],['read','add'],['read','mul'],['set','n',-0],['flush'],['read','copy'],['read','mul']
]);
await scenario([['signal','marker',0,false],['program','cmp',[['setExpr','marker',{argument:0}],['return',lit(false)]]],['signal','n',-0,{equals:{callback:'cmp'}}],['set','n',0],['flush'],['read','marker'],['read','n']]);
await scenario([['signal','n',0,false],['program','u',[['return',lit(-0)]]],['set','n',{callback:'u'}],['flush'],['read','n']]);
await scenario([['future','p'],['memo','n',{future:'p'}],['flush'],['fulfill','p',-0],['tick'],['flush'],['read','n']]);
await scenario([['program','fail',[['throwExpr',lit(-0)]]],['memo','m',{call:'fail'}],['read','m'],['flush'],['read','m']]);
await scenario([['program','clean',[['throwExpr',lit(-0)]]],['root','r',{seq:[{onCleanup:lit({callback:'clean'})},lit(undefined)]}],['disposeOwner','r'],['flush']]);
const b=new BendRuntime(),s=new SolidRuntime();
try{
 for(const op of['add','mul','same'])for(const left of[-0,0,1,2])for(const right of[-0,0,1,2]){
  const expr={[op]:[lit(left),lit(right)]};const a=b.attempt('evaluate',expr),e=s.attempt('evaluate',expr);assert.deepEqual(a,e,`${op} ${Object.is(left,-0)?'-0':left},${Object.is(right,-0)?'-0':right}`);operations++;
 }
 for(const value of[-0,0,NaN])assert.deepEqual(b.attempt('evaluate',{select:[lit(value),lit('truthy'),lit('falsey')]}),s.attempt('evaluate',{select:[lit(value),lit('truthy'),lit('falsey')]}));
 assert.deepEqual(b.attempt('evaluate',{arrayAt:{array:{array:[lit(9)]},index:lit(-0)}}),s.attempt('evaluate',{arrayAt:{array:{array:[lit(9)]},index:lit(-0)}}));
}finally{for(const r of[b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}}
console.log(`${histories} public signed-zero histories and ${operations+4} primitive controls preserve storage/returns, strict equality, arithmetic signs, falseyness, comparator arguments, async data, error causes/messages and cleanup throws.`);
