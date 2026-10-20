import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),call=call=>({call}),future=future=>({future});
const select=(c,y,n)=>({select:[c,y,n]}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?callbacks='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const original=console.error;console.error=(...args)=>logs.push(args);
  try{
    for(const [op,...args] of commands){
      if(op==='tick')await setImmediate();
      else{
        const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
        if(actual[0]==='return'&&wanted[0]==='return'&&!['read','set','update','future'].includes(op))actual[1]=wanted[1]=undefined;
        assert.deepEqual(actual,wanted,`${name}: ${op} result`);
      }
      const states=solidStates(s);
      assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: node state after ${op}`);
      assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
      assert.deepEqual(b.portEvents,s.portEvents,`${name}: promise results after ${op}`);
      assert.deepEqual(b.portSnapshots,s.portSnapshots,`${name}: observer screen after ${op}`);
      assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: escaping callback failures after ${op}`);
      for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
      assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],`${name}: ambient restoration`);
      const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
      assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports`);
    }
    count++;
  }catch(error){original('FAILED: '+name);throw error;}
  finally{b.attempt('dispose');s.attempt('dispose');b.resetErrorHalt();s.resetErrorHalt();b.attempt('flush');s.attempt('flush');await setImmediate();console.error=original;}
}
for(const value of [undefined,null,false,true,0,3,NaN,'hello',{ref:7},{error:1,kind:'TypeError',message:'data'}]){
  await scenario('early return '+String(value),[
    ['program','body',[['emit',10],['return',lit(value)],['emit',20],['throw','unreachable']]],
    ['memo','m',call('body')],['read','m'],['effect','view',read('m')],['flush'],['dispose']
  ]);
}
for(const lazy of [false,true])for(const equals of [true,false])for(const untracked of [false,true]){
  const expr=untracked?{untrack:read('x')}:read('x');
  await scenario(`callback tracked return ${lazy}/${equals}/${untracked}`,[
    ['signal','x',1],['program','body',[['emit',10],['return',add(expr,lit(2))]]],
    ['memo','m',call('body'),{lazy,equals}],['effect','view',read('m')],['set','x',4],['flush'],['read','m'],['set','x',4],['flush']
  ]);
}
for(const lazy of [false,true])for(const error of [false,true]){
  await scenario(`nested computed pull ${lazy}/${error}`,[
    ['signal','on',!error],['signal','x',1],['memo','inner',select(read('on'),read('x'),{raise:99}),{lazy}],
    ['program','innerBody',[['return',read('inner')]]],['program','outerBody',[['eval',call('innerBody')],['return',add(lit(17),call('innerBody'))]]],
    ['memo','outer',add(lit(5),call('outerBody'))],['effect','user',read('outer'),{user:true}],['flush'],
    ['set','on',true],['set','x',4],['flush'],['read','outer']
  ]);
}
await scenario('fallthrough discards evaluated values',[
  ['signal','x',1],['program','body',[['eval',read('x')],['emit',10]]],['memo','m',call('body')],['effect','view',read('m')],['set','x',4],['flush'],['read','m']
]);
await scenario('nested return exits only nested invocation',[
  ['program','inner',[['emit',1],['return',lit(7)],['emit',2]]],['program','outer',[['eval',call('inner')],['emit',3],['return',lit(9)],['emit',4]]],
  ['memo','m',call('outer')],['read','m'],['effect','view',read('m')]
]);
await scenario('callback has no previous argument',[
  ['signal','x',1],['program','body',[['eval',read('x')],['return',{prev:true}]]],['memo','m',call('body'),{equals:false}],
  ['effect','view',read('m')],['set','x',4],['flush'],['read','m']
]);
for(const cause of [undefined,null,false,99,'bad',{ref:2},{error:2,kind:'RangeError',message:'bad'}]){
  await scenario('throw evaluated cause '+String(cause),[
    ['signal','on',false],['signal','cause',cause],['program','fail',[['throwExpr',read('cause')],['emit',90]]],
    ['memo','m',select(read('on'),lit(7),add(lit(19),call('fail')))],['effect','user',read('m'),{user:true}],['flush'],
    ['read','m'],['set','on',true],['flush'],['read','m']
  ]);
}
for(const immediate of [false,true])for(const reject of [false,true]){
  await scenario(`returned async ${immediate}/${reject}`,[
    ['future','p',{immediate}],['program','body',[['return',future('p')],['emit',90]]],
    ['memo','m',call('body')],['effect','view',read('m')],['awaitValue','wait',read('m')],['tick'],
    [reject?'reject':'resolve','p',reject?'bad':7],['tick'],['read','m']
  ]);
  await scenario(`read async inside callback ${immediate}/${reject}`,[
    ['future','p',{immediate}],['memo','inner',future('p')],['program','body',[['eval',read('inner')],['return',add(lit(3),read('inner'))]]],
    ['memo','m',add(lit(17),call('body'))],['effect','view',read('m')],['awaitValue','wait',read('m')],['tick'],
    [reject?'reject':'resolve','p',reject?'bad':7],['tick'],['read','m']
  ]);
}
await scenario('computed read then write expression uses shared setter',[
  ['signal','x',1],['signal','out',0],['program','body',[['setExpr','out',add(read('x'),lit(2))],['return',read('x')]]],
  ['memo','m',call('body')],['effect','view',read('out')],['set','x',4],['flush'],['read','m'],['read','out']
]);
await scenario('registered cleanup retains owner and ordering',[
  ['signal','x',1],['program','clean',[['emit',30]]],['program','body',[['cleanup','clean'],['return',read('x')]]],
  ['memo','m',call('body')],['effect','view',read('m')],['set','x',2],['flush'],['dispose']
]);
for(const user of [false,true])for(const lazy of [false,true])for(const kind of ['signal','memo','untracked','write','throw']){
  const value=kind==='memo'?read('derived'):kind==='untracked'?{untrack:read('side')}:read('side');
  const action=kind==='write'?['setExpr','out',add(value,lit(2))]:kind==='throw'?['throwExpr',value]:['eval',value];
  await scenario(`imperative effect reads ${user}/${lazy}/${kind}`,[
    ['signal','tick',0],['signal','side',3],['signal','out',0],['memo','derived',add(read('side'),lit(1)),{lazy}],
    ['program','body',[['emit',10],action,['return',lit(42)],['emit',20]]],
    ['effect','sink',read('out'),{user:true}],['effect','effect',read('tick'),{user,program:'body'}],['flush'],
    ['set','side',7],['flush'],['set','tick',1],['flush'],['read','out'],['dispose']
  ]);
}
for(const lazy of [false,true])for(const handlerThrows of [false,true])for(const helper of [false,true]){
  await scenario(`imperative error handler ${lazy}/${handlerThrows}/${helper}`,[
    ['signal','on',true],['signal','side',3],['signal','out',0],['memo','derived',add(read('side'),lit(1)),{lazy}],
    ['program','clean',[['emit',30]]],['program','handler',[
      ['emit',10],...(helper?[['previousCleanup']]:[]),['eval',read('derived')],
      handlerThrows?['throwExpr',read('side')]:['setExpr','out',read('derived')],['return',lit(42)],['emit',20]
    ]],
    ['effect','sink',read('out'),{user:true}],['effect','effect',select(read('on'),lit(1),{raise:'failed'}),{user:true,error:'handler',cleanup:'clean'}],
    ['flush'],['set','side',7],['set','on',false],['flush'],['read','out'],['set','on',true],['flush'],['dispose']
  ]);
}
for(const immediate of [false,true])for(const user of [false,true]){
  await scenario(`pending read in imperative effect ${immediate}/${user}`,[
    ['future','p',{immediate}],['memo','data',future('p')],['program','body',[['eval',read('data')],['emit',20]]],
    ['effect','effect',lit(1),{user,program:'body'}],['flush'],['resolve','p',7],['tick'],['dispose']
  ]);
}
// Restriction checks are not counted as Solid histories: these input programs
// use the error-arm-only helper outside its supplied callback entry.
for(const Runtime of [BendRuntime,SolidRuntime]){
  const runtime=new Runtime();
  runtime.program('readBody',[['previousCleanup']]);
  for(const [op,...args] of [
    ['signal','x',0,{unobserved:'readBody'}],
    ['memo','m',lit(1),{unobserved:'readBody'}],
    ['effect','e',lit(1),{cleanup:'readBody'}],
    ['program','register',[['emit',1],['cleanup','readBody']]]
  ])assert.throws(()=>runtime[op](...args),/helper is unavailable in teardown callbacks/);
  assert.deepEqual(runtime.trace(),[],'restriction must precede callback side effects');
  runtime.dispose();runtime.flush();
}
console.log(`${count} callback histories match pinned TS statement order, returns, reads, writes, suspension and exceptions.`);
