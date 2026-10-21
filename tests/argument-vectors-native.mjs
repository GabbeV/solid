// Hand-written generators/factories control the typed vector binder independently
// of bindActionArguments and the source adapter's generator-method descriptors.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
const lit=lit=>({lit}),arg=argument=>({argument}),param=actionArgument=>({actionArgument});
const seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
const write=value=>({invokeWith:{callee:lit({setter:'x'}),value}});
const result=(value,done=true)=>({iteratorResult:{value,done}});
const outcome=promise=>promise.then(value=>['value',value],error=>['error',error]);
let count=0;
for(const direct of [false,true])for(const rejected of [false,true]){
 const S=await import('../build/solid.mjs?vector-native='+count),b=new BendRuntime({async:true}),seen=[];
 let get,set,dispose,yes,no;
 S.createRoot(stop=>{dispose=stop;[get,set]=S.createSignal(0);S.createRenderEffect(get,value=>{seen.push(value);});});
 b.signal('x',0);b.effect('view',{read:'x'});S.flush();b.flush();
 const request=new Promise((resolve,reject)=>{yes=resolve;no=reject;});request.catch(()=>{});b.future('request');
 const source=S.action(function*(_a,_b,start,request,extra){
  set(start);
  try{const value=yield request;set(start+value+extra);}catch{set(extra);}
  return extra;
 });
 const plan={steps:[{next:seq(write(param(2)),result(param(3),false))},{next:seq(write(add(add(param(2),arg(0)),param(4))),result(param(4))),throw:seq(write(param(4)),result(param(4)))}]};
 const fn=b.evaluate({actionCreate:plan}),values=[0,1,3,b.decode(b.encode({async:b.futures.request})),11];
 const compare=()=>{
  assert.equal(b.read('x'),get());assert.deepEqual(b.trace().filter(e=>e[0]==='apply'&&e[1]==='view').map(e=>e[2]),seen);
  assert.equal(b.world.actionDepth,0);assert.equal(b.world.context,0);assert.equal(b.world.tracking,false);
 };
 try{
  let port;assert.doesNotThrow(()=>{port=direct?fn(...values):b.evaluate({invokeArgs:{callee:lit(fn),args:values.map(lit)}});},'valid vector action invocation');
  const native=source(0,1,3,request,11);assert.ok(port instanceof Promise);assert.equal(fn.length,source.length);
  S.flush();b.flush();compare();assert.equal(get(),0);
  (rejected?no:yes)(5);b[rejected?'reject':'resolve']('request',5);
  assert.deepEqual(await outcome(port),['value',11]);assert.deepEqual(await outcome(native),['value',11]);await setImmediate();compare();
  assert.equal(get(),rejected?11:19);assert.equal(list(b.world.txArena).filter(t=>t.open).length,0);
 }finally{dispose();b.dispose();S.flush();b.flush();await setImmediate();count++;}
}
for(const failed of [false,true]){
 const S=await import('../build/solid.mjs?vector-native='+count),b=new BendRuntime({async:true});
 try{
  const source=S.action(function(_first,_second,third){if(third==='failed')throw third;return {next(){return {done:true,value:third};}};});
  const plan={factory:{select:[{same:[param(2),lit('failed')]},{raise:'failed'},lit(undefined)]},steps:[{next:result(param(2))}]};
  const fn=b.evaluate({actionCreate:plan}),values=[0,1,failed?'failed':'ready',99];
  let port;assert.doesNotThrow(()=>{port=fn(...values);});
  assert.deepEqual(await outcome(port),[failed?'error':'value',values[2]]);
  assert.deepEqual(await outcome(source(...values)),[failed?'error':'value',values[2]]);
  if(failed)assert.equal(list(b.world.actions).at(-1).transaction,0,'factory rejection precedes transaction allocation');
 }finally{b.dispose();b.flush();await setImmediate();count++;}
}
console.log(`${count} independent native generator/factory controls validate vector forwarding, held writes, resumption and pre-transaction errors.`);
