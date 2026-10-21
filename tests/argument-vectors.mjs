// Parameter/call ABI comparisons; the source functions and action wrapper run
// unchanged. These finite histories are separate from the quantified laws.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),arg=argument=>({argument}),param=actionArgument=>({actionArgument});
const seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
const result=(value,done=true)=>({iteratorResult:{value,done}});
const write=value=>({invokeWith:{callee:lit({setter:'x'}),value}});
const invoke=(callee,args)=>({invokeArgs:{callee,args}});
let count=0;
async function scenario(name,body){
 const S=await import('../build/solid.mjs?argument-vector='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S});
 const compare=()=>{
  const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,name+' nodes');
  assert.deepEqual(b.trace(),s.trace(),name+' trace');assert.deepEqual(b.screen(),s.screen(),name+' screen');
  assert.deepEqual(b.asyncErrors,s.asyncErrors,name+' delivery');
  assert.deepEqual([b.world.context,b.world.tracking,b.world.actionDepth],[0,false,0],name+' ambient');
 };
 try{
  for(const r of [b,s]){r.signal('x',0);r.memo('twice',{mul:[{read:'x'},lit(2)]});r.effect('view',{read:'twice'});r.flush();}
  await assert.doesNotReject(()=>body(b,s,compare),'admitted vector scenario: '+name);compare();count++;
 }catch(error){console.error('FAILED argument vector: '+name);throw error;}
 finally{for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();}
}
function call(r,kind,name,values){
 if(kind==='static')return r.evaluate({call:name,args:values.map(lit)});
 const fn=r.evaluate(lit({callback:name}));
 return kind==='raw'?fn(...values):r.evaluate(invoke(lit(fn),values.map(lit)));
}
function actionCall(r,fn,values,direct){
 if(!direct)return r.evaluate(invoke(lit(fn),values.map(lit)));
 const index=r instanceof BendRuntime?0:r.actionFunctions.get(fn).calls.length;
 const promise=fn(...values);
 if(r instanceof SolidRuntime)assert.equal(r.observeActionReturn(fn,promise,index),promise);
 return promise;
}
for(const kind of ['static','value','raw'])for(const arity of [3,4,9])for(const index of new Set([0,2,arity-1,arity+2])){
 await scenario(`callback ${kind}/${arity}/${index}`,async(b,s)=>{
  for(const r of [b,s]){r.program('pick',[['return',arg(index)]]);assert.equal(call(r,kind,'pick',Array.from({length:arity},(_,i)=>i+10)),index<arity?index+10:undefined);}
 });
}
for(const direct of [false,true])for(const arity of [3,4,9])for(const index of new Set([2,arity-1,arity+2])){
 await scenario(`action ${direct}/${arity}/${index}`,async(b,s)=>{
  const plan={steps:[{next:result(param(index))}]};
  const fns=[b,s].map(r=>r.evaluate({actionCreate:plan})),values=Array.from({length:arity},(_,i)=>i+10);
  const promises=[b,s].map((r,i)=>actionCall(r,fns[i],values,direct));
  assert.deepEqual(await Promise.all(promises),Array(2).fill(index<arity?index+10:undefined));await setImmediate();
 });
}
for(const failure of [-1,0,1,3]){
 await scenario(`callee/arguments order and throw ${failure}`,async(b,s,compare)=>{
  for(const r of [b,s]){
   r.program('target',[['emit',99],['return',add(arg(0),arg(3))]]);
   r.program('callee',[['emit',1],['return',lit({callback:'target'})]]);
   for(let i=0;i<4;i++)r.program('part'+i,[['emit',10+i],['set','x',i+1],...(failure===i?[['throw',{ref:77}]]:[['return',lit(i+10)]])]);
  }
  const expression=invoke({call:'callee'},Array.from({length:4},(_,i)=>({call:'part'+i})));
  const outcomes=[b,s].map(r=>r.attempt('evaluate',expression));assert.deepEqual(...outcomes);
  assert.deepEqual(outcomes[0],failure<0?['return',23]:['throw',{ref:77}]);compare();
  const emits=b.trace().filter(e=>e[0]==='cleanup').map(e=>e[2]);
  assert.deepEqual(emits,[1,...Array.from({length:failure<0?4:failure+1},(_,i)=>10+i),...(failure<0?[99]:[])]);
  for(const r of [b,s])r.flush();compare();
 });
}
await scenario('callee throws before evaluating argument expressions',async(b,s)=>{
 for(const r of [b,s]){
  r.program('part',[['emit',9],['return',lit(1)]]);
  assert.deepEqual(r.attempt('evaluate',invoke({raise:{ref:7}},Array(4).fill({call:'part'}))),['throw',{ref:7}]);
  assert.deepEqual(r.trace().filter(e=>e[0]==='cleanup'),[]);
 }
});
await scenario('nested calls capture third and fourth enclosing parameters',async(b,s)=>{
 for(const r of [b,s]){
  r.program('inner',[['return',add(arg(0),arg(3))]]);
  r.program('outer',[['return',invoke(lit({callback:'inner'}),[arg(2),lit(0),lit(0),arg(3)])]]);
  assert.equal(call(r,'value','outer',[0,1,7,9]),16);
 }
});
await scenario('argument syntax captures an enclosing local signal',async(b,s)=>{
 for(const r of [b,s]){
  r.program('pick',[['return',add(arg(2),arg(3))]]);
  assert.equal(r.root('scope',{signalScope:{initial:lit(7),body:invoke(lit({callback:'pick'}),[lit(0),lit(0),{localRead:0},lit(9)])}}),16);
 }
});
await scenario('many-argument callback captures the action factory parameter',async(b,s,compare)=>{
 for(const r of [b,s])r.program('make',[['return',{actionCreate:{factory:write(arg(2)),steps:[{next:result(param(3))}]}}]]);
 const fns=[b,s].map(r=>call(r,'static','make',[0,1,7,8]));
 assert.deepEqual(await Promise.all([b,s].map((r,i)=>actionCall(r,fns[i],[10,11,12,13],true))),[13,13]);
 await setImmediate();for(const r of [b,s])r.flush();compare();for(const r of [b,s])assert.equal(r.read('x'),7);
});
await scenario('nested action shadow/capture at higher argument indices',async(b,s)=>{
 const plan={steps:[{next:result({actionCreate:{steps:[{next:result(add(param({depth:1,index:3}),param(3)))}]}})}]};
 const outer=[b,s].map(r=>r.evaluate({actionCreate:plan}));
 const inner=await Promise.all([b,s].map((r,i)=>actionCall(r,outer[i],[0,1,2,7],true)));
 assert.deepEqual(await Promise.all([b,s].map((r,i)=>actionCall(r,inner[i],[10,11,12,13],false))),[20,20]);await setImmediate();
});
for(const kind of ['accessor','setter','rootDisposer']){
 await scenario(`ignored extras are evaluated for bound ${kind}`,async(b,s)=>{
  for(const r of [b,s]){
   r.root('scope',lit(0));r.program('side',[['emit',8],['return',lit(99)]]);
   r.evaluate(invoke(lit({[kind]:kind==='rootDisposer'?'scope':'x'}),[lit(7),{call:'side'},{call:'side'},{call:'side'}]));
   assert.equal(r.trace().filter(e=>e[0]==='cleanup').length,3);
  }
 });
}
for(const rejected of [false,true])for(const reverse of [false,true]){
 await scenario(`overlapping action captures ${rejected}/${reverse}`,async(b,s,compare)=>{
  for(const r of [b,s]){r.future('a');r.future('b');}
  const finish=seq(write(add(arg(0),param(3))),result(param(3)));
  const plan={steps:[{next:seq(write(param(3)),result(param(2),false))},{next:finish,throw:finish}]};
  const fns=[b,s].map(r=>r.evaluate({actionCreate:plan})),pairs=[];
  for(const [gate,n] of [['a',3],['b',11]])pairs.push([b,s].map((r,i)=>actionCall(r,fns[i],[0,1,r instanceof BendRuntime?r.decode(r.encode({async:r.futures[gate]})):r.futures[gate].object,n],true)));
  for(const r of [b,s])r.flush();compare();
  for(const i of reverse?[1,0]:[0,1]){
   for(const r of [b,s])r[rejected?'reject':'resolve'](i?'b':'a',5);
   assert.deepEqual(await Promise.all(pairs[i]),[i?11:3,i?11:3]);await setImmediate();compare();
  }
 });
}
for(const index of [2,3,7]){
 await scenario(`reference and callable aliases ${index}`,async(b,s)=>{
  for(const r of [b,s]){
   r.program('pick',[['return',arg(index)]]);r.program('data',[['return',lit(17)]]);
   const values=[{ref:3},undefined,{ref:7},r.evaluate(lit({callback:'data'})),null,false,1,{ref:7}];
   const value=call(r,'raw','pick',values);
   if(typeof values[index]==='function')assert.equal(value,values[index]);
   else assert.deepEqual(r.observe(value),values[index]);
  }
 });
}
await scenario('callback update and throw expressions bind higher indices',async(b,s,compare)=>{
 for(const r of [b,s]){
  r.program('update',[['updateExpr','x',add({prev:true},arg(3))],['return',arg(2)]]);
  assert.equal(call(r,'value','update',[0,1,7,9]),7);
  r.program('throw',[['throwExpr',arg(3)]]);
  assert.deepEqual(r.attempt('evaluate',invoke(lit({callback:'throw'}),[lit(0),lit(1),lit(2),lit({ref:8})])),['throw',{ref:8}]);
 }
 compare();for(const r of [b,s])r.flush();compare();
});
await scenario('root initializer shadows the outer vector binder',async(b,s)=>{
 for(const r of [b,s]){
  r.program('root',[['return',{root:arg(0)}]]);
  const dispose=call(r,'raw','root',[3,4,5,6]);assert.equal(typeof dispose,'function');dispose();
 }
});
console.log(`${count} arbitrary-arity callback/action histories match pinned Solid argument order, capture, aliases, throws and overlapping invocations.`);
