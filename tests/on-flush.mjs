// Public onFlush programs: the source API schedules a raw microtask callback.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const lit=lit=>({lit}),read=read=>({read}),seq=(...seq)=>({seq});
const write=(name,value)=>({invokeWith:{callee:lit({setter:name}),value}});
let cases=0;
async function scenario(name,commands,expect){
 const module=await import('../build/solid.mjs?on-flush='+cases),b=new BendRuntime({async:true}),s=new SolidRuntime({module});
 function compare(op){
  assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
  for(const id of [2,3,4])assert.deepEqual(b.screen(id),s.screen(id),`${name}: screen ${id} after ${op}`);
  assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: host errors after ${op}`);
  assert.equal(b.world.context,0,`${name}: callback ownership must not leak`);assert.equal(b.world.tracking,false);
 }
 try{
  for(const [op,...args]of commands){
   if(op==='tick')await setImmediate();
   else{
    const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
    if(actual[0]==='return'&&wanted[0]==='return'&&!['read','evaluate','set','update','screen'].includes(op))actual[1]=wanted[1]=undefined;
    assert.deepEqual(actual,wanted,`${name}: ${op} result`);
   }
   compare(op);
  }
  await expect?.(b,s);cases++;
 }finally{b.attempt('dispose');s.attempt('dispose');b.attempt('flush');s.attempt('flush');await setImmediate();}
}
const setup=[['signal','x',0],['effect','view',read('x'),{target:2}],['flush']];
const applied=r=>r.trace().filter(e=>e[0]==='apply'&&e[1]==='view').map(e=>e[2]);
await scenario('registration is deferred and inline write lands first',[
 ...setup,['onFlush',write('x',lit(2))],['read','x'],['set','x',1],['read','x'],['tick']
],b=>assert.deepEqual(applied(b),[0,1,2]));
await scenario('callbacks keep call order and batch into one update',[
 ...setup,['onFlush',write('x',lit(1))],['onFlush',write('x',lit(2))],['tick']
],b=>assert.deepEqual(applied(b),[0,2]));
await scenario('nested callbacks follow the flush they request',[
 ...setup,['onFlush',seq(write('x',lit(1)),{onFlush:write('x',lit(2))})],['tick']
],b=>assert.deepEqual(applied(b),[0,1,2]));
await scenario('manual flush does not invoke the queued callback inline',[
 ...setup,['onFlush',write('x',lit(2))],['set','x',1],['flush'],['read','x'],['tick']
],b=>assert.deepEqual(applied(b),[0,1,2]));
await scenario('disposed registration owner does not cancel a raw microtask',[
 ...setup,['root','temporary',{onFlush:write('x',lit(1))}],['disposeOwner','temporary'],['tick']
],b=>assert.deepEqual(applied(b),[0,1]));
await scenario('callback runs outside the registration owner',[
 ['signal','owner','not run'],['root','temporary',{onFlush:write('owner',{owner:true})}],['tick'],['read','owner']
],b=>assert.equal(b.read('owner'),null));
await scenario('argument binding crosses the queued closure',[
 ...setup,['program','later',[['return',{onFlush:write('x',{argument:0})}]],1],['evaluate',{call:'later',args:[lit(7)]}],['tick']
],b=>assert.deepEqual(applied(b),[0,7]));
await scenario('lexical signal binding crosses the queued closure',[
 ['signal','x',0],['evaluate',{signalScope:{initial:lit(1),body:{onFlush:seq({localWrite:{value:lit(2)}},{onFlush:write('x',{localRead:0})})}}}],['tick'],['read','x']
],b=>assert.equal(b.read('x'),2));
await scenario('callback throws are host errors and do not halt reactivity',[
 ...setup,['program','failure',[['throw',7]]],['onFlush',{call:'failure'}],['tick'],['set','x',2],['tick']
],b=>{assert.deepEqual(b.asyncErrors,[7]);assert.equal(b.world.halted,false);assert.deepEqual(applied(b),[0,2]);});
await scenario('onFlush inside flush(callback) waits for its inline drain',[
 ...setup,['evaluate',{flush:seq({onFlush:write('x',lit(2))},write('x',lit(1)))}],['tick']
],b=>assert.deepEqual(applied(b),[0,1,2]));
await scenario('action parameter binding crosses the queued closure',[
 ...setup,['evaluate',seq({invokeArgs:{callee:{actionCreate:{steps:[{next:seq({onFlush:write('x',{actionArgument:0})},{iteratorResult:{done:true,value:lit(0)}})}]}},args:[lit(9)]}},lit(undefined))],['tick']
],b=>assert.deepEqual(applied(b),[0,9]));
await scenario('registration in a tracked effect runs after that drain',[
 ...setup,['signal','trigger',0],['tracked','listener',{select:[read('trigger'),{onFlush:write('x',lit(10))},lit(undefined)]}],['flush'],['set','trigger',1],['tick']
],b=>assert.deepEqual(applied(b),[0,10]));
await scenario('returned function data is ignored rather than installed as cleanup',[
 ...setup,['program','cleanup',[['emit',17]]],['onFlush',lit({callback:'cleanup'})],['tick']
],b=>assert.equal(b.trace().some(e=>e[0]==='emit'),false));
await scenario('a write before a callback throw still gets its queued flush',[
 ...setup,['program','failure',[['throw',7]]],['onFlush',seq(write('x',lit(1)),{call:'failure'})],['tick']
],b=>{assert.deepEqual(b.asyncErrors,[7]);assert.equal(b.world.halted,false);assert.deepEqual(applied(b),[0,1]);});
for(const first of [true,false])for(const overlap of ['none','memo','user','render']){
 const graph=[['future','request'],['signal','open',true],['signal','route',0],['memo','page',{select:[read('route'),{future:'request'},lit(0)]}],['effect','pageView',read('page'),{target:2}],['effect','openView',read('open'),{target:3}]];
 const combined={add:[{select:[read('open'),lit(10),lit(0)]},read('page')]};
 if(overlap==='memo')graph.push(['memo','both',combined],['effect','bothView',read('both'),{target:4}]);
 if(overlap==='user'||overlap==='render')graph.push(['effect','bothView',combined,{target:4,user:overlap==='user'}]);
 const register=['onFlush',write('open',lit(false))],route=['set','route',1];
 await scenario(`menu close with pending route: ${first}/${overlap}`,[
  ...graph,['flush'],...(first?[register,route]:[route,register]),['tick']
 ],async(b,s)=>{
  assert.equal(b.screen(3),overlap==='memo'||overlap==='user'?true:false,'independent close commits; overlapping derivation joins the hold');
  b.resolve('request',1);s.resolve('request',1);await setImmediate();
  assert.deepEqual(b.trace(),s.trace());assert.equal(b.screen(3),false);assert.equal(b.screen(2),1);
 });
}
console.log(`${cases} public onFlush programs match native Solid on deferral, call/batch order, nested/manual flushes, disposal, ownership, binding, host errors and pending-route independence/overlap. Typed callback grammar; dev warnings and arbitrary host closures are separate.`);
