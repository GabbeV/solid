import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';

// Explicit external timer delivery, shared as a host contract only. Source
// setTimeout/clearTimeout calls are intercepted, not its until/watch bodies.
class Timers {
  next=1;tasks=new Map();events=[];
  setTimeout=(callback,delay)=>{
    const id=this.next++;this.tasks.set(id,callback);this.events.push(['set',id,delay]);return id;
  };
  clearTimeout=id=>{this.tasks.delete(id);this.events.push(['clear',id]);};
  fire(){
    const first=this.tasks.entries().next().value;
    if(first){const [id,callback]=first;this.tasks.delete(id);this.events.push(['fire',id]);callback();}
  }
  observe(signal,name){
    const add=signal.addEventListener.bind(signal),remove=signal.removeEventListener.bind(signal);
    signal.addEventListener=(type,callback,options)=>{this.events.push(['listen',name,type,options?.once]);return add(type,callback,options);};
    signal.removeEventListener=(type,callback)=>{this.events.push(['unlisten',name,type]);return remove(type,callback);};
  }
}
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future});
let count=0;
async function scenario(name,commands,expected){
  const module=await import('../build/solid.mjs?until-options='+count);
  const bc=new Timers(),sc=new Timers(),b=new BendRuntime({async:true,clock:bc}),s=new SolidRuntime({module,clock:sc});
  const original=console.error,logs=[];console.error=(...args)=>logs.push(args);
  function compare(op){
    const nodes=solidStates(s);
    assert.deepEqual(bendStates(b,nodes.map(([name])=>name)),nodes,`${name}: node state after ${op}`);
    assert.deepEqual(b.trace(),s.trace(),`${name}: execution trace after ${op}`);
    assert.deepEqual(b.portEvents,s.portEvents,`${name}: promise outcomes after ${op}`);
    assert.deepEqual(b.portSnapshots,s.portSnapshots,`${name}: screen at promise observer after ${op}`);
    assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: escaping host callbacks after ${op}`);
    assert.deepEqual(bc.events,sc.events,`${name}: ordered timer/listener IO after ${op}`);
    assert.equal(bc.tasks.size,sc.tasks.size,`${name}: active timers after ${op}`);
    assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],`${name}: ambient restoration`);
    const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
    assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports`);
  }
  try{
    for(const [op,...args] of commands){
      if(op==='tick')await setImmediate();
      else if(op==='microtick')await Promise.resolve();
      else if(op==='fire'){bc.fire();sc.fire();}
      else{
        const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
        if(actual[0]==='return'&&wanted[0]==='return'&&!['read','set','update','future'].includes(op))actual[1]=wanted[1]=undefined;
        assert.deepEqual(actual,wanted,`${name}: ${op} result`);
        if(op==='controller'){
          bc.observe(b.controllers[args[0]].signal,args[0]);sc.observe(s.controllers[args[0]].signal,args[0]);
        }
      }
      compare(op);
    }
    assert.deepEqual(b.portEvents,expected,`${name}: expected promise outcome`);
    assert.equal(bc.tasks.size,0,`${name}: timeout released`);
    count++;
  }catch(error){original('FAILED: '+name);throw error;}
  finally{b.attempt('dispose');s.attempt('dispose');b.resetErrorHalt();s.resetErrorHalt();b.attempt('flush');s.attempt('flush');await setImmediate();console.error=original;}
}
const timeout={timeoutError:true,name:'TimeoutError',message:'Timed out waiting for condition'};
const resolved=(value,name='r')=>['resolve',name,value],rejected=(value,name='r')=>['reject',name,value];
for(const reason of [null,false,0,NaN,'',true,99,{ref:7}]){
  await scenario('already aborted '+String(reason),[
    ['controller','cancel'],['abort','cancel',reason],['awaitUntil','r',lit(7),{signal:'cancel',timeout:0}],['tick']
  ],[rejected(reason)]);
  await scenario('abort a live falsy watch '+String(reason),[
    ['controller','cancel'],['signal','x',0],['awaitUntil','r',read('x'),{signal:'cancel',timeout:5}],
    ['tick'],['abort','cancel',reason],['tick'],['set','x',7],['flush'],['tick'],['fire']
  ],[rejected(reason)]);
}
for(const preAborted of [false,true]){
  await scenario('abort reason is an async object identity '+preAborted,[
    ['future','reason',{immediate:true}],['controller','cancel'],
    ...(preAborted?[['abort','cancel',{async:1}]]:[]),
    ['awaitUntil','r',lit(false),{signal:'cancel'}],
    ...(!preAborted?[['abort','cancel',{async:1}]]:[]),['tick']
  ],[rejected({async:1})]);
}
for(const delay of [0,1,25,2**31-1]){
  await scenario('timeout while false '+delay,[
    ['awaitUntil','r',lit(0),{timeout:delay}],['tick'],['fire'],['tick']
  ],[rejected(timeout)]);
  await scenario('truthy first answer cancels timeout '+delay,[
    ['controller','cancel'],['awaitUntil','r',lit(7),{timeout:delay,signal:'cancel'}],['tick'],['fire'],['abort','cancel',99],['tick']
  ],[resolved(7)]);
}
await scenario('initial truthy answer is still queued when abort arrives',[
  ['controller','cancel'],['awaitUntil','r',lit(7),{signal:'cancel',timeout:0}],['abort','cancel',99],['tick'],['fire']
],[rejected(99)]);
await scenario('initial error answer is still queued when abort arrives',[
  ['controller','cancel'],['awaitUntil','r',{raise:66},{signal:'cancel',timeout:0}],['abort','cancel',99],['tick'],['fire']
],[rejected(99)]);
await scenario('queued initial error cancels both resources',[
  ['controller','cancel'],['awaitUntil','r',{raise:66},{signal:'cancel',timeout:0}],['tick'],['abort','cancel',99],['fire']
],[rejected(66)]);
await scenario('timeout cancels abort listener',[
  ['controller','cancel'],['awaitUntil','r',lit(0),{signal:'cancel',timeout:5}],['fire'],['tick'],['abort','cancel',99],['tick']
],[rejected(timeout)]);
await scenario('abort without timer',[
  ['controller','cancel'],['awaitUntil','r',lit(false),{signal:'cancel'}],['tick'],['abort','cancel',99],['tick']
],[rejected(99)]);
await scenario('explicit undefined timeout registers no timer',[
  ['awaitUntil','r',lit(7),{timeout:undefined}],['tick']
],[resolved(7)]);
await scenario('timer wins against an undelivered truthy callback',[
  ['signal','x',0],['awaitUntil','r',read('x'),{timeout:5}],['tick'],['set','x',7],['flush'],['fire'],['tick']
],[rejected(timeout)]);
for(const immediate of [false,true])for(const lazy of [false,true])for(const fail of [false,true]){
  await scenario(`async answer releases timer and listener ${immediate}/${lazy}/${fail}`,[
    ['controller','cancel'],['future','p',{immediate}],['memo','data',future('p'),{lazy}],
    ['awaitUntil','r',read('data'),{timeout:10,signal:'cancel'}],['tick'],[fail?'reject':'resolve','p',fail?99:7],
    ['tick'],['fire'],['abort','cancel',88],['tick']
  ],[fail?rejected(99):resolved(7)]);
  await scenario(`timeout while async source is pending ${immediate}/${lazy}/${fail}`,[
    ['controller','cancel'],['future','p',{immediate}],['memo','data',future('p'),{lazy}],
    ['awaitUntil','r',read('data'),{timeout:10,signal:'cancel'}],['tick'],['fire'],['tick'],
    [fail?'reject':'resolve','p',fail?99:7],['tick'],['abort','cancel',88],['tick']
  ],[rejected(timeout)]);
}
for(const trigger of ['fire','abort']){
  await scenario('cleanup exception preserves '+trigger+' rejection',[
    ['controller','cancel'],['program','bad',[['emit',71],['throw',88]]],['program','register',[['cleanup','bad']]],
    ['awaitUntil','r',{seq:[{call:'register'},lit(false)]},{timeout:5,signal:'cancel'}],['tick'],
    trigger==='fire'?['fire']:['abort','cancel',99],['tick'],['fire']
  ],[rejected(trigger==='fire'?timeout:99)]);
}
await scenario('two watchers share a native abort signal',[
  ['controller','cancel'],['signal','x',0],['awaitUntil','a',read('x'),{signal:'cancel',timeout:1}],
  ['awaitUntil','b',read('x'),{signal:'cancel',timeout:2}],['tick'],['abort','cancel',99],['tick'],['fire']
],[rejected(99,'a'),rejected(99,'b')]);

// Also run native timers, independently of the explicit-delivery harness.
for(const Runtime of [BendRuntime,SolidRuntime]){
  const module=await import('../build/solid.mjs?until-native-options='+count);
  const runtime=new Runtime({async:true,module});
  runtime.attempt('awaitUntil','timeout',lit(false),{timeout:0});
  await assert.rejects(runtime.promise('timeout'),error=>error instanceof Error&&error.name==='TimeoutError'&&error.message===timeout.message);
  const first=await runtime.promise('timeout').catch(error=>error);
  runtime.attempt('awaitUntil','secondTimeout',lit(false),{timeout:0});
  const second=await runtime.promise('secondTimeout').catch(error=>error);
  assert.notEqual(first,second,'each timeout constructs a fresh error');
  if(runtime instanceof BendRuntime){
    const state=list(runtime.world.awaiters)[runtime.ports.timeout.id].state;
    assert.equal(runtime.decode(state.error),first,'decoding a timeout preserves its identity');
  }else assert.ok(first instanceof module.TimeoutError);
  runtime.attempt('awaitUntil','ready',lit(7),{timeout:100});
  assert.equal(await runtime.promise('ready'),7);
  runtime.controller('cancel');runtime.signal('reason',{ref:71});
  const reason=runtime.read('reason');
  runtime.attempt('awaitUntil','cancelled',lit(false),{signal:'cancel'});
  runtime.attempt('abort','cancel',{ref:71});
  await assert.rejects(runtime.promise('cancelled'),error=>error===reason,'abort preserves reason identity');
  const identity=runtime.future('asyncReason',{immediate:true});
  runtime.memo('asyncToken',{future:'asyncReason'},{sync:true});runtime.controller('cancelAsync');
  const asyncReason=runtime.read('asyncToken');
  runtime.attempt('awaitUntil','cancelledAsync',lit(false),{signal:'cancelAsync'});
  runtime.attempt('abort','cancelAsync',{async:identity});
  let captured;
  // Do not return the reason from an async rejection observer: that would
  // assimilate this deliberately unresolved thenable in the test itself.
  await runtime.promise('cancelledAsync').then(()=>assert.fail('expected rejection'),error=>{captured=error;});
  assert.equal(captured,asyncReason,'rejection does not assimilate a thenable reason');
  runtime.dispose();runtime.resetErrorHalt();runtime.flush();await setImmediate();
}
console.log(`${count} until option histories match TS timer/listener IO, pre-abort, races, pending/async/error delivery and disposal; native timeout/success controls pass in both runtimes.`);
