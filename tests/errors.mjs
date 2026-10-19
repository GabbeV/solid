import assert from 'node:assert/strict';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const lit=lit=>({lit}),read=read=>({read}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),call=call=>({call}),raise=raise=>({raise});
let count=0;
function scenario(name,commands){
  const b=new BendRuntime(),s=new SolidRuntime(),logs=[];
  const consoleError=console.error;console.error=(...args)=>logs.push(args);
  try{
    for(const [op,...args] of commands){
      const actual=b.attempt(op,...args),before=logs.length,expected=s.attempt(op,...args);
      if(actual[0]==='return'&&expected[0]==='return'&&!['read','set','update','screen'].includes(op)){actual[1]=expected[1]=undefined;}
      assert.deepEqual(actual,expected,`${name}: ${op} result`);
      assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
      for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
      assert.equal(b.world.context,0,`${name}: context`);assert.equal(b.world.tracking,false,`${name}: tracking`);assert.equal(b.world.running,false,`${name}: running`);
      // Production reports are explicit host IO; ordering and payloads agree.
      const recent=list(b.world.reports).slice(s.reportCount??0).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value' in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
      assert.deepEqual(recent,logs.slice(before).map(args=>args.map(e=>s.errorShape(e))),`${name}: reports after ${op}`);s.reportCount=list(b.world.reports).length;
    }
    count++;
  }catch(e){consoleError('FAILED: '+name);throw e;}
  finally{s.attempt('dispose');s.resetErrorHalt();s.attempt('flush');console.error=consoleError;}
}
scenario('initial throw is stored; top-level reads retain wrapper identity',[
  ['memo','a',raise(null)],['read','a'],['read','a'],['flush'],['read','a']
]);
scenario('error propagation preserves wrapper through a multi-hop chain',[
  ['signal','on',false],['memo','a',select(read('on'),lit(7),raise(99))],['memo','b',read('a')],['memo','c',read('b')],
  ['read','a'],['read','b'],['read','c'],['set','on',true],['flush'],['read','c']
]);
scenario('user compute error logs in effect phase then recovers',[
  ['signal','on',true],['effect','user',select(read('on'),lit(7),raise(99)),{user:true}],['flush'],['set','on',false],['flush'],['set','on',true],['flush']
]);
scenario('user error handler can write and explicitly release previous cleanup',[
  ['signal','on',true],['signal','y',0],['program','clean',[['emit',101]]],
  ['program','error',[['emit',102],['previousCleanup'],['set','y',8]]],
  ['effect','user',select(read('on'),lit(7),raise(99)),{user:true,error:'error',cleanup:'clean'}],
  ['effect','view',read('y')],['flush'],['set','on',false],['flush'],['read','y'],['set','on',true],['flush']
]);
scenario('user error before first application takes error handler only',[
  ['program','error',[['emit',101]]],['effect','user',raise(undefined),{user:true,error:'error'}],['flush']
]);
scenario('untrack restores tracking through a caught compute error',[
  ['signal','x',true],['memo','a',{untrack:seq(read('x'),raise(false))}],['read','a'],['set','x',false],['flush'],['read','a']
]);
scenario('render compute throw halts synchronously and further scheduling is ignored',[
  ['signal','on',true],['effect','view',select(read('on'),lit(1),raise('bad'))],['set','on',false],['flush'],['set','on',true],['flush'],['set','on',false],['flush']
]);
scenario('render creation throw halts and surfaces a status wrapper',[
  ['effect','view',raise(99)],['flush']
]);
scenario('effect callback throw stores wrapped status but rethrows raw cause',[
  ['program','fail',[['emit',101],['throw',99]]],['effect','user',lit(1),{user:true,program:'fail'}],['flush'],['flush']
]);
scenario('previous effect cleanup throw skips callback but runs finally',[
  ['signal','x',1],['program','fail',[['emit',101],['throw',99]]],['effect','user',read('x'),{user:true,cleanup:'fail'}],['flush'],['set','x',2],['flush']
]);
scenario('error handler throw escalates while preserving compute error',[
  ['program','fail',[['emit',101],['throw',42]]],['effect','user',raise(99),{user:true,error:'fail'}],['flush']
]);
scenario('same-committed-value recovery wakes error-carrying dependents',[
  ['signal','on',true],['memo','a',select(read('on'),lit(7),raise(99))],['memo','b',read('a')],
  ['effect','user',read('b'),{user:true}],['flush'],['set','on',false],['flush'],['set','on',true],['flush'],['read','b']
]);
scenario('error in retained dependency tail is not pruned before successful replacement',[
  ['signal','on',true],['signal','x',1],['memo','a',select(read('on'),read('x'),raise(99))],['effect','user',read('a'),{user:true}],
  ['flush'],['set','on',false],['flush'],['set','x',2],['flush'],['set','on',true],['flush']
]);
scenario('nested failure restores the callers partial expression stack',[
  ['signal','on',false],['memo','a',select(read('on'),lit(2),raise(99))],
  ['memo','b',{add:[lit(17),read('a')]}],['memo','c',{mul:[lit(3),read('b')]}],
  ['effect','user',read('c'),{user:true}],['flush'],['set','on',true],['flush'],['read','c']
]);
scenario('later tracked reads retry an error while top-level reads do not',[
  ['signal','tick',0],['memo','a',raise(99)],['effect','user',seq(read('tick'),read('a')),{user:true}],['flush'],
  ['read','a'],['set','tick',1],['flush'],['read','a'],['set','tick',2],['flush']
]);
scenario('error arm keeps prior cleanup unless the handler invokes its helper',[
  ['signal','on',true],['program','clean',[['emit',101]]],['program','error',[['emit',102]]],
  ['effect','user',select(read('on'),lit(7),raise(99)),{user:true,error:'error',cleanup:'clean'}],['flush'],
  ['set','on',false],['flush'],['set','on',true],['flush'],['dispose']
]);
scenario('cleanup helper throw escalates without wrapping the handler failure',[
  ['signal','on',true],['program','clean',[['emit',101],['throw',42]]],['program','error',[['emit',102],['previousCleanup']]],
  ['effect','user',select(read('on'),lit(7),raise(99)),{user:true,error:'error',cleanup:'clean'}],['flush'],['set','on',false],['flush']
]);
scenario('finally trim hook throw overrides an effect callback throw',[
  ['signal','on',true],['program','hook',[['emit',101],['throw',42]]],['signal','x',1,{unobserved:'hook'}],
  ['program','fail',[['emit',102],['throw',99]]],['effect','user',select(read('on'),read('x'),lit(2)),{user:true,defer:true,program:'fail'}],
  ['set','on',false],['flush']
]);
console.log(`${count} synchronous error histories match pinned TS throws, wrapper identity, propagation/recovery, effect error arms/cleanup, reports, halts and finally restoration.`);
