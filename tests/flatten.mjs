// Actual native flatten calls versus the shared Bend callback/read machine.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const lit=lit=>({lit}),arr=(...array)=>({array}),fn=name=>lit({callback:name}),read=read=>({read}),flat=(children,options={})=>({flatten:{children,...options}}),invoke=value=>({invoke:lit(value)});
let count=0;
async function scenario(name,body,{rawReads=false}={}){
 const S=await import('../build/solid.mjs?flatten='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),rs=[b,s];
 try{
  await body(rs);
  const trace=r=>r.trace().filter(e=>!rawReads||e[0]!=='read');
  assert.deepEqual(trace(b),trace(s),name+' trace');assert.deepEqual(b.screen(),s.screen(),name+' screen');
  assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],name+' ambient');
  assert.deepEqual(b.asyncErrors,s.asyncErrors,name+' asynchronous errors');count++;
 }catch(error){console.error('FAILED flatten: '+name);throw error;}
 finally{for(const r of rs){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();}
}
for(const value of [undefined,null,false,true,0,1,NaN,'','text',{ref:7}])for(const skipNonRendered of [false,true]){
 await scenario('scalar '+String(value)+'/'+skipNonRendered,async rs=>{
  const results=rs.map(r=>r.attempt('evaluate',flat(lit(value),{skipNonRendered})));
  assert.deepEqual(...results);assert.deepEqual(results[0],['return',skipNonRendered&&[undefined,null,false,true,''].includes(value)?undefined:value]);
 });
}
for(const skipNonRendered of [false,true])for(const doNotUnwrap of [false,true]){
 await scenario('nested arrays/options '+skipNonRendered+'/'+doNotUnwrap,async rs=>{
  const tree=arr(lit(0),arr(lit(null),arr(),arr(lit(false),lit(''))),lit(3));
  const out=rs.map(r=>r.evaluate(flat(tree,{skipNonRendered,doNotUnwrap})));
  assert.deepEqual(rs[0].observe(out[0]),rs[1].observe(out[1]));assert.deepEqual(out[0],skipNonRendered?[0,3]:[0,null,false,'',3]);
  for(const [i,r]of rs.entries())assert.notStrictEqual(r.evaluate(flat(lit(out[i]))),out[i],'array flatten returns fresh output');
 });
 for(const arity of [0,1,2,9]){
  await scenario('function chain/arity '+arity+'/'+skipNonRendered+'/'+doNotUnwrap,async rs=>{
   for(const r of rs){r.signal('value',4);r.program('last',[['emit',8],['return',arr(read('value'),lit(null))]],arity);r.program('first',[['emit',9],['return',fn('last')]]);}
   const inputs=rs.map(r=>r.evaluate(fn('first'))),out=rs.map((r,i)=>r.evaluate(flat(lit(inputs[i]),{skipNonRendered,doNotUnwrap})));
   assert.deepEqual(rs[0].observe(out[0]),rs[1].observe(out[1]));
   if(doNotUnwrap)for(const i of [0,1])assert.strictEqual(out[i],inputs[i]);
   else if(arity)for(const [i,r]of rs.entries())assert.strictEqual(out[i],r.evaluate(fn('last')));
   else assert.deepEqual(out[0],skipNonRendered?[4]:[4,null]);
  });
 }
 await scenario('deferred sibling OR and captured data '+skipNonRendered+'/'+doNotUnwrap,async rs=>{
  for(const r of rs){r.signal('value',2);r.program('child',[['emit',4],['return',arr(read('value'),lit(null))]]);}
  const tree=arr(fn('child'),arr(lit(7),arr(lit(false))),lit(0));
  const out=rs.map(r=>r.evaluate(flat(tree,{skipNonRendered,doNotUnwrap})));
  assert.deepEqual(rs[0].observe(out[0]),rs[1].observe(out[1]));
  if(doNotUnwrap){
   assert.equal(typeof out[0],'function');assert.equal(out[0].length,0);
   for(const n of [2,5]){
    for(const r of rs){r.set('value',n);r.flush();}
    const values=rs.map((r,i)=>r.evaluate(invoke(out[i])));assert.deepEqual(...values);assert.deepEqual(values[0],skipNonRendered?[n,7,0]:[n,null,7,false,0]);
   }
   const second=rs.map(r=>r.evaluate(flat(tree,{skipNonRendered,doNotUnwrap})));
   for(const i of [0,1])assert.notStrictEqual(out[i],second[i],'each resolving closure is fresh');
  }else assert.deepEqual(out[0],skipNonRendered?[2,7,0]:[2,null,7,false,0]);
 });
}
for(const array of [false,true])for(const skipNonRendered of [false,true]){
 await scenario('bound getter '+array+'/'+skipNonRendered,async rs=>{
  for(const r of rs)r.signal('value',6);
  const getters=rs.map(r=>r.evaluate(lit({accessor:'value'})));
  const out=rs.map((r,i)=>r.evaluate(flat(array?arr(lit(getters[i]),arr(lit(1))):lit(getters[i]),{skipNonRendered})));
  assert.deepEqual(...out);assert.deepEqual(out[0],array?[6,1]:6);
 },{rawReads:true});
}
for(const nested of [false,true])for(const realError of [false,true])for(const deferred of [false,true]){
 await scenario('pending collection and ordinary throw '+nested+'/'+realError+'/'+deferred,async rs=>{
  for(const r of rs){
   r.future('first');r.future('second');r.memo('first', {future:'first'});r.memo('second',{future:'second'});
   r.program('pending1',[['emit',1],['return',read('first')]]);r.program('pending2',[['emit',2],['return',read('second')]]);
   r.program('later',[['emit',3],...(realError?[['throw',17]]:[['return',lit(8)]])]);
  }
  const children=nested?arr(arr(fn('pending1'),fn('pending2')),fn('later')):arr(fn('pending1'),fn('pending2'),fn('later'));
  const wrappers=deferred?rs.map(r=>r.evaluate(flat(children,{doNotUnwrap:true}))):[];
  const outcomes=rs.map((r,i)=>r.attempt('evaluate',deferred?invoke(wrappers[i]):flat(children)));assert.deepEqual(...outcomes);assert.equal(outcomes[0][0],'throw');
  if(realError)assert.deepEqual(outcomes[0],['throw',17]);else assert.equal(outcomes[0][1].source,'second','last pending exception wins');
  for(const r of rs){r.resolve('first',4);r.resolve('second',5);}
  for(let i=0;i<5;i++)await setImmediate();
  if(!realError){const out=rs.map((r,i)=>r.attempt('evaluate',deferred?invoke(wrappers[i]):flat(children)));assert.deepEqual(...out);assert.deepEqual(out[0],['return',[4,5,8]]);}
 });
}
for(const error of [undefined,null,false,0,'broken',{ref:9}]){
 await scenario('immediate error stops sibling '+String(error),async rs=>{
  for(const r of rs){r.program('bad',[['emit',5],['throw',error]]);r.program('later',[['emit',6],['return',lit(8)]]);}
  const out=rs.map(r=>r.attempt('evaluate',flat(arr(fn('bad'),fn('later')))));assert.deepEqual(...out);assert.deepEqual(out[0],['throw',error]);
  for(const r of rs)assert.equal(r.trace().some(e=>e[0]==='cleanup'&&e[2]===6),false);
 });
}
await scenario('lexical and callback argument capture',async rs=>{
 for(const r of rs)r.program('take',[['return',flat({argument:0})]],1);
 const expr={signalScope:{initial:lit(7),body:flat(arr({localRead:0},arr({localAccessor:0})))}};
 const a=rs.map(r=>r.evaluate(expr));assert.deepEqual(...a);assert.deepEqual(a[0],[7,7]);
 const b=rs.map(r=>r.evaluate({call:'take',args:[arr(lit(8),arr(lit(9)))]}));assert.deepEqual(...b);assert.deepEqual(b[0],[8,9]);
},{rawReads:true});
for(const deferred of [false,true]){
 await scenario('reactive memo and teardown '+deferred,async rs=>{
  for(const r of rs){
   r.signal('value',1);r.program('child',[['emit',7],['return',read('value')]]);
   r.memo('children',flat(arr(fn('child'),arr(lit(0))),{doNotUnwrap:deferred}));
  }
  for(const n of [1,3]){
   for(const r of rs){r.set('value',n);r.flush();}
   const values=rs.map(r=>{const value=r.read('children');return deferred?r.evaluate(invoke(value)):value;});
   assert.deepEqual(...values);assert.deepEqual(values[0],[n,0]);
  }
  if(deferred)for(const r of rs)r.evaluate({withOwner:[lit({owner:'root'}),{onCleanup:lit(r.read('children'))}]});
  for(const r of rs)r.dispose();
 });
}
await scenario('action parameter capture',async rs=>{
 const expr={actionCreate:{factory:lit(undefined),steps:[{next:{iteratorResult:{done:true,value:flat({actionArgument:0})}}}]}};
 const functions=rs.map(r=>r.evaluate(expr));
 const promises=rs.map((r,i)=>r.evaluate({invokeArgs:{callee:lit(functions[i]),args:[arr(lit(2),arr(lit(4)))]}}));
 const out=await Promise.all(promises);assert.deepEqual(...out);assert.deepEqual(out[0],[2,4]);
});
console.log(`${count} flatten histories match native scalar/array/accessor resolution, formal arity, option handling, deferred closures, pending collection, error order and lexical capture. Direct native getter read traces are explicitly excluded in five cases.`);
