// Independently authored native generators control the typed-method adapter.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,ABI} from '../host/bend.mjs';
import {build} from 'esbuild';
const source=new URL('../upstream/solid/packages/signals/src/',import.meta.url).pathname;
const bundle=await build({stdin:{contents:"export * from './index.ts';export {question,actionDepth,flushTransaction} from './core/scheduler.ts';",resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}});
const sourceModule='data:text/javascript;base64,'+Buffer.from(bundle.outputFiles[0].text).toString('base64');
const question=q=>q.$==='QuestionZero'?0:q.$==='QuestionOdd'?2*question(q.half)+1:2*question(q.half)+2;
let count=0;
const lit=lit=>({lit}),arg={argument:0},seq=(...seq)=>({seq});
const write=value=>({invokeWith:{callee:lit({setter:'x'}),value}});
const result=(value=lit(undefined),done=false)=>({iteratorResult:{done,value}});
async function setup(){
 const S=await import(sourceModule+'#action-native='+count),b=new BendRuntime({async:true}),seen=[];
 let get,set,dispose;
 S.createRoot(d=>{dispose=d;[get,set]=S.createSignal(0);S.createRenderEffect(get,value=>{seen.push(value);});});
 b.signal('x',0);b.effect('view',{read:'x'});b.flush();S.flush();
 const assertState=()=>{
  assert.equal(b.read('x'),get());assert.deepEqual(b.trace().filter(e=>e[0]==='apply'&&e[1]==='view').map(e=>e[2]),seen);
  assert.equal(b.world.actionDepth,S.actionDepth);assert.equal(question(b.world.question),S.question);
  assert.equal(b.world.flushTransaction===0,S.flushTransaction===null);
  if(S.flushTransaction){const tx=list(b.world.txArena)[b.world.flushTransaction];assert.equal(tx.open,S.flushTransaction._open);assert.equal(tx.acted,S.flushTransaction._acted);}
 };
 return {S,b,get,set,seen,assertState,finish:async()=>{dispose();b.dispose();S.flush();b.flush();await setImmediate();count++;}};
}
for(const rejected of [false,true])for(const catches of [false,true]){
 const {S,b,get,set,seen,assertState,finish}=await setup();
 try{
  let yes,no;const request=new Promise((a,c)=>{yes=a;no=c;});request.catch(()=>{});
  b.future('request');
  const native=S.action(function*(){set(1);try{set(yield request);}catch(error){if(!catches)throw error;set(4);}return 'saved';})();native.catch(()=>{});
  const port=b.runAction('save',{steps:[{next:seq(write(lit(1)),result({future:'request'}))},{next:seq(write(arg),result(lit('saved'),true)),...(catches?{throw:seq(write(lit(4)),result(lit('saved'),true))}:{})}]});
  S.flush();b.flush();assert.equal(get(),0);assert.deepEqual(seen,[0]);assertState();
  if(rejected){no(3);b.reject('request',3);}else{yes(3);b.resolve('request',3);}
  const outcome=p=>p.then(v=>['value',v],e=>['error',e]);
  assert.deepEqual(await outcome(port),await outcome(native));assertState();
 }finally{await finish();}
}
for(const nested of [false,true]){
 const {S,b,get,set,seen,assertState,finish}=await setup();
 try{
  let calls=0;
  const inner=S.action(function*(){set(2);yield;set(3);return 'inner';});
  const native=S.action(function*(){S.flush(()=>{calls++;});set(1);const value=nested?inner():Promise.resolve('plain');assert.deepEqual(seen,[0]);set(4);return value;})();
  const innerPlan={steps:[{next:seq(write(lit(2)),result())},{next:seq(write(lit(3)),result(lit('inner'),true))}]};
  b.signal('calls',0);
  // A native returned Promise is represented by the existing external IO port.
  if(!nested){b.future('plain');b.resolve('plain','plain');}
  const port=b.runAction('save',{steps:[{next:seq({flush:{invokeWith:{callee:lit({setter:'calls'}),value:lit(1)}}},write(lit(1)),nested?{action:innerPlan}:lit(undefined),write(lit(4)),result(nested?lit('inner'):{future:'plain'},true))}]});
  assert.equal(calls,1);assert.equal(get(),0);assert.deepEqual(seen,[0]);assert.equal(b.read('calls'),0);assertState();
  S.flush();b.flush();assert.equal(get(),4);assert.deepEqual(seen,[0,4]);assertState();assert.equal(await port,await native);
 }finally{await finish();}
}

// The yielded-value settled cell belongs to each yield, independently of the
// future object. Feed the same native callbacks and the same Bend closure twice.
for(const firstReject of [false,true])for(const secondReject of [false,true]){
 const {S,b,set,assertState,finish}=await setup();
 try{
  let yes,no;const request={then:(a,c)=>{yes=a;no=c;}};
  b.future('request',{immediate:true});
  const native=S.action(function*(){set(1);let value;try{value=yield request;}catch(error){value=error;}set(value);return value;})();
  const tail=seq(write(arg),result(arg,true));
  const port=b.runAction('save',{steps:[{next:seq(write(lit(1)),result({future:'request'}))},{next:tail,throw:tail}]});
  S.flush();b.flush();const observer=list(b.world.actionWaits)[0].observer;
  (firstReject?no:yes)(3);b.world=ABI.deliver(b.fuel,b.world,observer,firstReject,ABI.vNumber(3));b.check();
  assertState();(secondReject?no:yes)(9);b.world=ABI.deliver(b.fuel,b.world,observer,secondReject,ABI.vNumber(9));b.check();
  assertState();assert.equal(await port,3);assert.equal(await native,3);
  assert.equal(list(b.world.txArena)[1].open,0);
 }finally{await finish();}
}

for(const rejected of [false,true]){
 const {S,b,get,set,assertState,finish}=await setup();
 try{
  let yes,no,end;const request={then:(a,c)=>{yes=a;no=c;}},later={then:a=>{end=a;}};
  b.future('request',{immediate:true});b.future('later',{immediate:true});
  const native=S.action(function*(){set(1);try{yield request;}catch{}set(3);set(yield later);return 'saved';})();
  const second=seq(write(lit(3)),result({future:'later'}));
  const port=b.runAction('save',{steps:[{next:seq(write(lit(1)),result({future:'request'}))},{next:second,throw:second},{next:seq(write(arg),result(lit('saved'),true))}]});
  S.flush();b.flush();const observer=list(b.world.actionWaits)[0].observer;
  (rejected?no:yes)(3);b.world=ABI.deliver(b.fuel,b.world,observer,rejected,ABI.vNumber(3));b.check();assertState();
  // An old callback cannot resume the generator at its newer suspension point.
  yes(9);b.world=ABI.deliver(b.fuel,b.world,observer,false,ABI.vNumber(9));b.check();assertState();assert.equal(get(),0);
  assert.equal(list(b.world.txArena)[1].open,1);
  end(6);b.resolve('later',6);assertState();assert.equal(get(),6);assert.equal(await port,await native);
 }finally{await finish();}
}

{
 const {S,b,assertState,finish}=await setup();
 try{
  let called=0;const returned={then:yes=>{called++;yes(7);}};
  b.future('returned',{immediate:true});b.resolve('returned',7);
  const native=S.action(function*(){return returned;})();
  const port=b.runAction('save',{steps:[{next:result({future:'returned'},true)}]});
  assert.equal(called,0,'native Promise adoption must defer then()');
  assert.equal(list(b.world.actionWaits).length,0,'Bend must defer the same then() registration');
  assert.equal(await port,await native);assert.equal(called,1);assertState();
 }finally{await finish();}
}
// The run() catch covers only a synchronous .then call. A later callback's
// drain error escapes to its caller, while a throw after synchronous settlement
// is ignored. Both cases retain the original action result and global halt.
for(const immediate of [false,true]){
 const {S,b,get,set,assertState,finish}=await setup(),original=console.error,logs=[];
 console.error=(...args)=>logs.push(args);
 try{
  S.createRoot(()=>S.createRenderEffect(get,value=>{if(value===2)throw 8;}));
  b.program('fail',[['return',{select:[{same:[arg,lit(2)]},{raise:8},lit(undefined)]}]]);
  b.effect('failure',{read:'x'},{user:false,program:'fail'});b.flush();S.flush();
  let yes;const request={then:callback=>{yes=callback;if(immediate)callback(3);}};
  b.future('request',{immediate:true});if(immediate)b.resolve('request',3);
  const native=S.action(function*(){set(1);yield request;set(2);return 7;})();
  const port=b.runAction('save',{steps:[{next:seq(write(lit(1)),result({future:'request'}))},{next:seq(write(lit(2)),result(lit(7),true))}]});
  if(!immediate){
   S.flush();b.flush();const observer=list(b.world.actionWaits)[0].observer;
   const attempt=fn=>{try{fn();return ['return'];}catch(error){return ['throw',error];}};
   assert.deepEqual(attempt(()=>yes(3)),['throw',8]);
   assert.deepEqual(attempt(()=>{b.world=ABI.deliver(b.fuel,b.world,observer,false,ABI.vNumber(3));b.check();}),['throw',8]);
  }
  assert.equal(await port,7);assert.equal(await native,7);assertState();
  assert.equal(b.world.halted,true);assert.equal(logs.length,1);
 }finally{console.error=original;await finish();}
}

for(const reverse of [false,true]){
 const {S,b,get,set,assertState,finish}=await setup();
 try{
  const ends=[],requests=[0,1].map(i=>({then:yes=>{ends[i]=yes;}}));
  b.future('a',{immediate:true});b.future('b',{immediate:true});
  const native=requests.map((request,i)=>S.action(function*(){set(1);yield request;set(i+2);return i;})());
  const tx=S.flushTransaction;
  const ports=['a','b'].map((name,i)=>b.runAction(name,{steps:[{next:seq(write(lit(1)),result({future:name}))},{next:seq(write(lit(i+2)),result(lit(i),true))}]}));
  assertState();assert.equal(tx._open,2);assert.equal(tx._acted,true);
  S.flush();b.flush();assertState();
  const first=reverse?1:0,second=1-first;
  ends[first](7);b.resolve(first?'b':'a',7);assertState();assert.equal(get(),0);
  assert.equal(tx._open,1);assert.equal(list(b.world.txArena)[1].open,1);
  ends[second](8);b.resolve(second?'b':'a',8);assertState();assert.equal(get(),second+2);
  assert.equal(tx._open,0);assert.equal(list(b.world.txArena)[1].open,0);
  assert.deepEqual(await Promise.all(ports),await Promise.all(native));
 }finally{await finish();}
}

// One real generator wrapper is called twice with independent arguments. These
// controls do not construct the source generator through the typed plan adapter.
for(const rejected of [false,true])for(const reverse of [false,true]){
 const {S,b,get,set,assertState,finish}=await setup();
 try{
  const ends=[];
  const requests=[0,1].map(i=>new Promise((yes,no)=>{ends[i]=rejected?no:yes;}));
  for(const request of requests)request.catch(()=>{});
  b.future('a');b.future('b');
  const wrapper=S.action(function*(request,n){
   set(n);
   let value;try{value=yield request;}catch(error){value=error;}
   set(value+n);return n;
  });
  const parameter=i=>({actionArgument:i});
  const finishExpr=seq(write({add:[arg,parameter(1)]}),result(parameter(1),true));
  const fn=b.evaluate({actionCreate:{steps:[{next:seq(write(parameter(1)),result(parameter(0)))},{next:finishExpr,throw:finishExpr}]}});
  assert.equal(b.decode(b.encode(fn)),fn);assert.equal(S.flushTransaction,null);
  const native=requests.map((request,i)=>wrapper(request,i?11:3));
  const ports=['a','b'].map((gate,i)=>fn(b.decode(ABI.vAsync(b.futures[gate])),i?11:3));
  assert.notEqual(native[0],native[1]);assert.notEqual(ports[0],ports[1]);
  S.flush();b.flush();assertState();assert.equal(get(),0);
  for(const i of reverse?[1,0]:[0,1]){
   ends[i](5);b[rejected?'reject':'resolve'](i?'b':'a',5);
   assert.equal(await ports[i],await native[i]);await setImmediate();assertState();
  }
 }finally{await finish();}
}

console.log(`${count} native-generator controls validate the action method ABI, held writes, rejection, nested slices, production flush callbacks, native return adoption duplicate yield callbacks and reused wrappers with independent invocation arguments.`);
