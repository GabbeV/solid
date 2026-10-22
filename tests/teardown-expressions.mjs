// Public API histories: no fixture registration or admission bypass.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future});
const fn=name=>lit({callback:name}),onCleanup=name=>({onCleanup:fn(name)});
const seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]}),select=(c,y,n)=>({select:[c,y,n]});
let count=0;
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?teardown-expression='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const original=console.error;console.error=(...args)=>logs.push(args);
  try{
    for(const [op,...args] of commands){
      if(op==='tick')await setImmediate();
      else{
        const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
        if(actual[0]==='return'&&expected[0]==='return'&&!['read','set','update','evaluate','future','root'].includes(op))actual[1]=expected[1]=undefined;
        assert.deepEqual(actual,expected,`${name}: ${op} result`);
        verify?.(op,args,actual,expected,b,s);
      }
      const states=solidStates(s);
      assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: nodes after ${op}`);
      assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
      assert.deepEqual(b.iteratorIO(),s.iteratorIO(),`${name}: iterator protocol after ${op}`);
      assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: callback failures after ${op}`);
      for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
      assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],`${name}: ambient state after ${op}`);
      const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
      assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports after ${op}`);
    }
    count++;
  }catch(error){original('FAILED: '+name);throw error;}
  finally{b.attempt('dispose');s.attempt('dispose');b.resetErrorHalt();s.resetErrorHalt();b.attempt('flush');s.attempt('flush');await setImmediate();console.error=original;}
}
for(const lazy of [false,true])for(const cleanup of ['read','return','throw','updater']){
  await scenario('public root teardown reads preserve caller '+JSON.stringify({lazy,cleanup}),[
    ['signal','marker',0],['signal','other',7],['memo','reader',read('other'),{owner:null,lazy}],
    ['program','clean',cleanup==='return'?[['return',read('reader')],['set','marker',99]]:cleanup==='updater'?[['set','marker',{accessor:'reader'}]]:[['setExpr','marker',read('reader')],...(cleanup==='throw'?[['throwExpr',lit(9)]]:[])]],
    ['root','scope',seq(onCleanup('clean'),lit(1))],
    ['evaluate',add(lit(40),seq({invoke:lit({rootDisposer:'scope'})},lit(2)))],['flush'],['read','marker'],['dispose'],['flush']
  ],(op,args,actual,expected)=>{
    if(op==='evaluate')assert.deepEqual(expected,cleanup==='throw'?['throw',9]:['return',42]);
    if(op==='read'&&args[0]==='marker')assert.deepEqual(expected,['return',cleanup==='return'?0:7]);
  });
}
for(const user of [false,true])for(const cleanup of ['read','throw','return']){
  await scenario('public returned cleanup programs read '+JSON.stringify({user,cleanup}),[
    ['signal','version',0],['signal','marker',0],['signal','other',7],['memo','reader',read('other'),{owner:null,lazy:true}],
    ['program','clean',cleanup==='return'?[['return',read('reader')]]:[['setExpr','marker',read('reader')],...(cleanup==='throw'?[['throwExpr',lit(9)]]:[])]],
    ['program','body',[['return',fn('clean')]]],['effect','view',read('version'),{user,program:'body',returnCleanup:true}],['flush'],
    ['set','version',1],['flush'],['resetErrorHalt'],['flush'],['read','marker'],['dispose'],['resetErrorHalt'],['flush']
  ],(op,args,actual,expected)=>{
    if(op==='read'&&args[0]==='marker')assert.deepEqual(expected,['return',cleanup==='return'?0:7]);
  });
}
for(const immediate of [false,true])for(const value of [1,8])for(const cleanup of ['read','throw','pending']){
  await scenario('public async dependency trim reads '+JSON.stringify({immediate,value,cleanup}),[
    ['signal','version',0],['signal','input',1],['signal','marker',0],['signal','other',7],['future','p',{immediate}],['future','q',{immediate}],
    ['memo','reader',cleanup==='pending'?future('q'):read('other'),{owner:null,lazy:true}],
    ['program','clean',[['setExpr','marker',read('reader')],...(cleanup==='throw'?[['throwExpr',lit(9)]]:[])]],
    ['memo','observed',seq(onCleanup('clean'),read('input')),{lazy:true}],
    ['memo','target',select(read('version'),future('p'),read('observed'))],['flush'],['set','version',1],['flush'],
    ['resolve','p',value],['tick'],['read','marker'],['resolve','q',7],['tick'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
  ],(op,args,actual,expected)=>{
    if(op==='read'&&args[0]==='marker')assert.deepEqual(expected,['return',cleanup==='pending'?0:7]);
  });
}
for(const immediate of [false,true])for(const children of [1,2])for(const cleanup of ['read','throw','pending']){
  const dependents=[];
  for(let i=0;i<children;i++)dependents.push(['memo','child'+i,seq(onCleanup('clean'),read('source')),{lazy:true}],['read','child'+i]);
  await scenario('public pending-source deferred cleanup '+JSON.stringify({immediate,children,cleanup}),[
    ['signal','marker',0],['signal','other',7],['future','p',{immediate}],['future','q',{immediate}],
    ['memo','reader',cleanup==='pending'?future('q'):read('other'),{owner:null,lazy:true}],
    ['program','clean',[['updateExpr','marker',add({prev:true},read('reader'))],...(cleanup==='throw'?[['throwExpr',lit(9)]]:[])]],
    ['memo','source',future('p')],...dependents,['flush'],['resolve','p',8],['tick'],['read','marker'],
    ['resolve','q',7],['tick'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
  ],(op,args,actual,expected)=>{
    if(op==='read'&&args[0]==='marker'&&cleanup==='read')assert.deepEqual(expected,['return',7*children]);
  });
}
for(const immediate of [false,true])for(const route of ['promise','yield','empty','reject'])for(const cleanup of ['read','throw','pending']){
  await scenario('public flight last observer cleanup '+JSON.stringify({immediate,route,cleanup}),[
    ['signal','marker',0],['signal','other',7],['future','p',{immediate}],['future','q',{immediate}],
    ['memo','reader',cleanup==='pending'?future('q'):read('other'),{owner:null,lazy:true}],
    ['program','clean',[['setExpr','marker',read('reader')],...(cleanup==='throw'?[['throwExpr',lit(9)]]:[])]],
    ...(route==='yield'||route==='empty'?[['stream','stream',[{future:'p'},{value:99},{done:true}]]]:[]),
    ['memo','target',seq(onCleanup('clean'),future(route==='yield'||route==='empty'?'stream':'p')),{lazy:true}],['read','target'],['flush'],
    route==='reject'?['reject','p',8]:route==='yield'?['resolveStep','p',8]:route==='empty'?['resolveStep','p',8,true]:['resolve','p',8],
    ['tick'],['read','marker'],['resolve','q',7],['tick'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
  ],(op,args,actual,expected)=>{
    if(op==='read'&&args[0]==='marker')assert.deepEqual(expected,['return',cleanup==='pending'?0:7]);
  });
}
for(const immediate of [false,true])for(const recovery of ['same','different','error'])for(const cleanup of ['read','throw']){
  await scenario('public silent recovery or catch retirement cleanup '+JSON.stringify({immediate,recovery,cleanup}),[
    ['signal','pending',false],['signal','fail',false],['signal','armed',false],['signal','fallback',1],['signal','marker',0],['signal','other',7],['future','p',{immediate}],
    ['memo','reader',read('other'),{owner:null,lazy:true}],
    ['program','clean',[['setExpr','marker',read('reader')],...(cleanup==='throw'?[['eval',select({untrack:read('armed')},{raise:9},lit(undefined))]]:[])]],
    ['memo','source',future('p')],['memo','middle',select(read('fail'),{raise:8},select(read('pending'),read('source'),read('fallback')))],
    ['memo','child',seq(onCleanup('clean'),read('middle')),{lazy:true}],['root','observer',lit(0)],['effect','view',read('child'),{owner:'observer'}],['flush'],
    ['set','pending',true],['flush'],['disposeOwner','observer'],['set','marker',0],['set','armed',true],
    ...(recovery==='error'?[['set','fail',true]]:[['set','pending',false],...(recovery==='different'?[['set','fallback',2]]:[])]),
    ['flush'],['read','marker'],['resolve','p',7],['tick'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
  ],(op,args,actual,expected)=>{
    if(op==='read'&&args[0]==='marker')assert.deepEqual(expected,['return',7],'cleanup write is committed before the collected error escapes');
  });
}
// A real rejected flight (not a synchronous retry throw) must release lazy
// readers that lost their last observer while pending. Keep this separate from
// cleanup-fault recovery: rc.17 now contains those faults before this path.
for(const immediate of [false,true])for(const cleanup of ['read','throw'])for(const depth of [1,2]){
 const children=[['memo','child',seq(onCleanup('clean'),read('source')),{lazy:true}]];
 if(depth===2)children.push(['memo','leaf',read('child'),{lazy:true}]);
 await scenario('rejected flight releases stranded lazy readers '+JSON.stringify({immediate,cleanup,depth}),[
  ['signal','marker',0],['signal','other',7],['future','p',{immediate}],
  ['memo','reader',read('other'),{owner:null,lazy:true}],
  ['program','clean',[['setExpr','marker',read('reader')],...(cleanup==='throw'?[['throwExpr',lit(9)]]:[])]],
  ['memo','source',future('p')],...children,['root','observer',lit(0)],
  ['effect','view',read(depth===2?'leaf':'child'),{owner:'observer'}],['flush'],['disposeOwner','observer'],
  ['reject','p',8],['tick'],['read','marker'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
 ],(op,args,actual,expected,b)=>{
  if(op==='read'&&args[0]==='marker'){
   assert.deepEqual(expected,['return',7],'rejected flight releases and runs the lazy cleanup');
   assert.ok(b.nodes()[b.ids.child].flags&64,'the stranded child is disposed');
  }
 });
}
console.log(`${count} public teardown-expression histories match actual pinned Solid reads, async release, error/catch/finally ordering and ignored returns.`);
