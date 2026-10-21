// Actual reusable S.action callables are returned unchanged. A direct native
// call is labeled afterward, just as returned reaction functions are observed;
// that label neither wraps the function nor changes the Promise it returned.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),seq=(...seq)=>({seq}),arg=index=>({actionArgument:index}),resume={argument:0};
const result=(value,done=true)=>({iteratorResult:{value,done}});
const write=value=>({invokeWith:{callee:lit({setter:'x'}),value}});
let count=0;
async function scenario(name,body){
 const S=await import('../build/solid.mjs?action-functions='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S});
 const compare=()=>{
  const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,name+' nodes');
  assert.deepEqual(b.trace(),s.trace(),name+' trace');assert.deepEqual(b.screen(),s.screen(),name+' screen');
  assert.deepEqual(b.asyncErrors,s.asyncErrors,name+' delivery errors');
  assert.deepEqual([b.world.context,b.world.tracking,b.world.actionDepth],[0,false,0],name+' ambient');
 };
 try{for(const r of [b,s]){r.signal('x',0);r.memo('twice',{mul:[{read:'x'},lit(2)]});r.effect('view',{read:'twice'});r.flush();}
  await body(b,s,compare);compare();count++;
 }catch(error){console.error('FAILED action function: '+name);throw error;}
 finally{for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();}
}
function create(r,plan){
 const before=r instanceof BendRuntime?[r.nodes().length,list(r.world.txArena).length,list(r.world.actions).length,list(r.world.asyncObjects).length,r.world.scheduled]:[r.owner._firstChild,r.nextFuture];
 const fn=r.evaluate({actionCreate:plan});
 const after=r instanceof BendRuntime?[r.nodes().length,list(r.world.txArena).length,list(r.world.actions).length,list(r.world.asyncObjects).length,r.world.scheduled]:[r.owner._firstChild,r.nextFuture];
 assert.deepEqual(after,before,'creating action must not invoke it or schedule work');
 assert.equal(typeof fn,'function');
 if(r instanceof BendRuntime)assert.equal(r.decode(r.encode(fn)),fn,'Bend canonical callable');
 else assert.equal(r.callbackValue(r.callbackIdentities.get(fn)),fn,'actual source wrapper');
 return fn;
}
function invoke(r,fn,args,direct=false){
 let promise;
 assert.doesNotThrow(()=>{
  if(!direct)promise=r.evaluate({invokeArgs:{callee:lit(fn),args:args.map(lit)}});
  else if(r instanceof BendRuntime)promise=fn(...args);
  else{
   const index=r.actionFunctions.get(fn).calls.length;
   promise=fn(...args);assert.equal(r.observeActionReturn(fn,promise,index),promise,'observing preserves original Promise');
  }
 },'an admitted action call returns a Promise rather than throwing synchronously');
 assert.ok(promise instanceof Promise,'action returns an actual native Promise');return promise;
}
for(const direct of [false,true])for(const index of [0,1,2])for(const args of [[],[7],[7,9]]){
 await scenario(`argument ${index}/${args.length}/direct=${direct}`,async(b,s,compare)=>{
  const plan={steps:[{next:result(arg(index))}]},bf=create(b,plan),sf=create(s,plan);
  assert.deepEqual(b.observe(bf),s.observe(sf));
  const promises=[invoke(b,bf,args,direct),invoke(s,sf,args,direct)];compare();
  assert.deepEqual(b.observe(promises[0]),s.observe(promises[1]));
  assert.deepEqual(await Promise.all(promises),[args[index],args[index]]);
  const second=[invoke(b,bf,args,direct),invoke(s,sf,args,direct)];
  assert.notEqual(second[0],promises[0]);assert.notEqual(second[1],promises[1]);
  await Promise.all(second);await setImmediate();
 });
}
for(const direct of [false,true])for(const rejected of [false,true])for(const reverse of [false,true]){
 await scenario(`overlap ${direct}/${rejected}/${reverse}`,async(b,s,compare)=>{
  for(const r of [b,s]){r.future('a');r.future('b');}
  const finish=seq(write({add:[resume,arg(1)]}),result(arg(1)));
  const plan={steps:[{next:seq(write(arg(1)),result(arg(0),false))},{next:finish,throw:finish}]};
  const bf=create(b,plan),sf=create(s,plan),pairs=[];
  for(const [gate,n]of [['a',3],['b',11]])pairs.push([invoke(b,bf,[b.decode(b.encode({async:b.futures[gate]})),n],direct),invoke(s,sf,[s.futures[gate].object,n],direct)]);
  for(const r of [b,s])r.flush();compare();for(const r of [b,s])assert.equal(r.read('x'),0);
  for(const index of reverse?[1,0]:[0,1]){
   const gate=index?'b':'a';for(const r of [b,s])r[rejected?'reject':'resolve'](gate,5);
   const values=await Promise.all(pairs[index]);assert.deepEqual(values,[index?11:3,index?11:3]);await setImmediate();compare();
  }
 });
}
for(const depth of [0,1])for(const dispose of [false,true]){
 await scenario(`captured signal ${depth}/${dispose}`,async(b,s,compare)=>{
  const plan={steps:[{next:seq({localWrite:{depth,value:arg(0)}},result({localRead:depth}))}]};
  const fn=r=>r.root('scope',{signalScope:{initial:lit(2),body:depth?{signalScope:{initial:lit(4),body:{actionCreate:plan}}}:{actionCreate:plan}}});
  const bf=fn(b),sf=fn(s);compare();if(dispose)for(const r of [b,s])r.disposeOwner('scope');
  assert.deepEqual(await Promise.all([invoke(b,bf,[17]),invoke(s,sf,[17])]),[2,2]);await setImmediate();compare();
 });
}
for(const error of [false,true])for(const nested of [false,true]){
 await scenario(`factory/capture ${error}/${nested}`,async(b,s,compare)=>{
  const value=nested?{actionArgument:{depth:1,index:0}}:arg(0);
  const inner={actionCreate:{steps:[{next:result({add:[value,arg(1)]})}]}};
  const plan={factory:error?{raise:{ref:29}}:write(arg(0)),steps:[{next:result(nested?inner:arg(1))}]};
  const bf=create(b,plan),sf=create(s,plan);
  const outcomes=await Promise.allSettled([invoke(b,bf,[7,9]),invoke(s,sf,[7,9])]);
  if(error){assert.deepEqual(outcomes.map((o,i)=>[o.status,[b,s][i].observe(o.reason)]),[['rejected',{ref:29}],['rejected',{ref:29}]]);assert.equal(list(b.world.actions).at(-1).transaction,0);}
  else if(nested){const fns=outcomes.map(o=>o.value);assert.deepEqual(b.observe(fns[0]),s.observe(fns[1]));assert.deepEqual(await Promise.all([invoke(b,fns[0],[100,13]),invoke(s,fns[1],[100,13])]),[20,20]);}
  else assert.deepEqual(outcomes.map(o=>o.value),[9,9]);
  await setImmediate();compare();
 });
}
// The outer callback parameter is captured in the factory; method argument zero
// is independently rebound to the value sent back into the generator.
for(const direct of [false,true]){
 await scenario(`callback and resume binders ${direct}`,async(b,s,compare)=>{
  const plan={factory:write({argument:0}),steps:[{next:result(lit(6),false)},{next:result({add:[resume,arg(0)]})}]};
  for(const r of [b,s])r.program('make',[['return',{actionCreate:plan}]]);
  const bf=b.evaluate({call:'make',args:[lit(17)]}),sf=s.evaluate({call:'make',args:[lit(17)]});
  assert.deepEqual(await Promise.all([invoke(b,bf,[9],direct),invoke(s,sf,[9],direct)]),[15,15]);await setImmediate();compare();
 });
}
for(const stored of [false,true])for(const passed of [false,true]){
 await scenario(`function identity through data ${stored}/${passed}`,async(b,s,compare)=>{
  const plan={steps:[{next:result(arg(0))}]},functions=[];
  for(const r of [b,s]){
   let fn=create(r,plan);const other=create(r,plan);assert.notEqual(fn,other,'two action constructors create distinct wrappers');
   if(stored){r.signal('function',undefined);r.update('function',lit(fn));r.flush();assert.equal(r.read('function'),fn);fn=r.read('function');}
   if(passed){r.program('pass',[['return',{argument:0}]]);const returned=r.evaluate({call:'pass',args:[lit(fn)]});assert.equal(returned,fn);fn=returned;}
   functions.push(fn);
  }
  compare();assert.deepEqual(await Promise.all(functions.map((fn,i)=>invoke([b,s][i],fn,[31]))),[31,31]);await setImmediate();compare();
 });
}
// The updater's previous value is lexical state at wrapper creation. Calling
// the wrapper later must not replace it with the call entry's undefined prev.
for(const previous of [0,17])for(const direct of [false,true]){
 await scenario(`captured updater previous ${previous}/${direct}`,async(b,s,compare)=>{
  const functions=[];
  for(const r of [b,s]){
   r.signal('holder',previous);
   r.update('holder',{actionCreate:{factory:write({prev:true}),steps:[{next:result(arg(0))}]}});
   r.flush();functions.push(r.read('holder'));
  }
  compare();assert.deepEqual(await Promise.all(functions.map((fn,i)=>invoke([b,s][i],fn,[3],direct))),[3,3]);
  await setImmediate();compare();for(const r of [b,s])assert.equal(r.read('x'),previous);
 });
}
// Cleanup ignores the returned Promise; the action still uses the real shared
// transaction driver.
{
 await scenario('onCleanup',async(b,s,compare)=>{
  const plan={factory:lit(undefined),steps:[{next:seq(write(lit(23)),result(lit(5)))}]};
  for(const r of [b,s])r.root('cleanup',{onCleanup:{actionCreate:plan}});
  compare();for(const r of [b,s])r.disposeOwner('cleanup');await setImmediate();compare();
  for(const r of [b,s])assert.equal(r.read('x'),23);
 });
}
console.log(`${count} reusable action-function histories preserve actual wrapper identity, fresh invocation Promises, two call arguments, nested parameter capture, overlapping suspensions, factory/resume errors and cleanup invocation.`);
