import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?from-subscriptions='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[],capturedB=new Map(),capturedS=new Map();
  const consoleError=console.error;console.error=(...args)=>logs.push(args);
  function compare(op){
    const expectedNodes=solidStates(s);assert.deepEqual(bendStates(b,expectedNodes.map(([name])=>name)),expectedNodes,`${name}: node state after ${op}`);
    assert.deepEqual(b.iteratorIO(),s.iteratorIO(),`${name}: iterator protocol after ${op}`);
    assert.deepEqual(b.thenIO(),s.thenIO(),`${name}: then registration count after ${op}`);
    assert.deepEqual(b.iteratorMethods(),s.iteratorMethods(),`${name}: iterator method arguments after ${op}`);
    assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
    for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
    assert.deepEqual(b.portSnapshots,s.portSnapshots,`${name}: screen at promise observer after ${op}`);
    assert.deepEqual(b.portEvents,s.portEvents,`${name}: promise delivery after ${op}`);
    assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: callback failures after ${op}`);
    for(const key of ['context','tracking','running'])assert.equal(b.world[key],key==='context'?0:false,`${name}: ${key}`);
    const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value' in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
    assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports after ${op}`);
  }
  try{
    for(const [op,...args] of commands){
      if(op==='capture'){
        const [label,expr]=args,a=b.evaluate(expr),n=s.evaluate(expr);
        assert.equal(typeof a,'function');assert.equal(typeof n,'function');
        assert.equal(b.evaluate(expr),a);assert.equal(s.evaluate(expr),n);
        capturedB.set(label,a);capturedS.set(label,n);assert.deepEqual(b.observe(a),s.observe(n));
      }
      else if(op==='captured'){
        const [label,...values]=args;
        const expression=fn=>({invokeArgs:{callee:{lit:fn},args:values.map(lit)}});
        assert.deepEqual(b.attempt('evaluate',expression(capturedB.get(label))),s.attempt('evaluate',expression(capturedS.get(label))));
      }
      else if(op==='different'){
        assert.notEqual(capturedB.get(args[0]),capturedB.get(args[1]));assert.notEqual(capturedS.get(args[0]),capturedS.get(args[1]));
      }
      else if(op==='expect'){const a=b.attempt('evaluate',args[0]),n=s.attempt('evaluate',args[0]);assert.deepEqual(a,['return',args[1]],name+' expected value');assert.deepEqual(n,a);}
      else if(op==='tick')await setImmediate();
      else if(op==='microtick')await Promise.resolve();
      else {
        const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
        if(actual[0]==='return'&&expected[0]==='return'&&!['read','set','update','screen'].includes(op))actual[1]=expected[1]=undefined;
        assert.deepEqual(actual,expected,`${name}: ${op} result`);
      }
      compare(op);verify?.(op,args,b,s);
      const extensions=list(b.world.extensions);for(const [label,get]of Object.entries(s.accessors)){const native=Object.getOwnPropertySymbols(get).map(k=>get[k]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v),node=b.nodes()[b.ids[label]];if(native&&node)assert.equal(extensions[node.x]?.marks??0,native._x?._marks??0,name+' marks on '+label);}
    }
    count++;
  }catch(e){consoleError('FAILED: '+name);throw e;}
  finally{b.attempt('dispose');s.attempt('dispose');b.resetErrorHalt();s.resetErrorHalt();b.attempt('flush');s.attempt('flush');await setImmediate();console.error=consoleError;}
}


const arg=argument=>({argument});
const fn=name=>lit({callback:name});
const invokeArg=(index,value)=>({invokeWith:{callee:arg(index),value:lit(value)}});
const cleanup=[['program','end',[['emit',71]]]];
for(const values of [[],[0],[false],[undefined],[null],[''],[1,2,3]])for(const end of ['none','complete','error'])for(const deferred of [false,true])for(const lazy of [false,true])for(const throwCleanup of[false,true]){
 const actions=values.map(value=>['eval',invokeArg(0,value)]);
 if(end==='complete')actions.push(['eval',{invoke:arg(2)}]);
 if(end==='error')actions.push(['eval',invokeArg(1,99)]);
 actions.push(['return',fn('end')]);
 await scenario(`synchronous subscription ${JSON.stringify(values)}/${end}/${deferred}/${lazy}`, [
  ['program','end',[['emit',71],...(throwCleanup?[['throw',77]]:[])]],['program','error',[['emit',72]]],['program','subscribe',actions,3],
  [deferred?'deferred':'memo','value',{from:fn('subscribe')},{lazy}],
  ['effect','view',read('value'),{user:true,error:'error'}],['flush'],['tick'],['dispose'],['tick']
 ]);
}

const root=lit({owner:'root'}),get=name=>({getContext:{name,owner:root}});
const save=(name,value)=>['eval',{setContext:{name,value,owner:root}}];
const callbacks=[['context','next',undefined],['context','errorCallback',undefined],['context','complete',undefined]];
const captureActions=[save('next',arg(0)),save('errorCallback',arg(1)),save('complete',arg(2))];
for(const deferred of[false,true])for(const lazy of[false,true])for(const seeded of[false,true])for(const ending of['complete','error','dispose'])for(const throwCleanup of[false,true]){
 const options={lazy,...(seeded?{loadingValue:0}:{})};
 const endActions=[['emit',71],...(throwCleanup?[['throw',77]]:[])];
 await scenario(`async callback stream ${deferred}/${lazy}/${seeded}/${ending}/${throwCleanup}`, [
  ...callbacks,['program','end',endActions],['program','error',[['emit',72]]],
  ['program','subscribe',[...captureActions,['return',fn('end')]],3],
  [deferred?'deferred':'memo','value',{from:fn('subscribe')},options],['effect','view',read('value'),{user:true,error:'error'}],['flush'],
  ['capture','send',get('next')],['capture','fail',get('errorCallback')],['capture','complete',get('complete')],
  ['awaitUntil','truth',read('value')],['microtick'],
  ['captured','send',1],['captured','send',2],['captured','send',3],['tick'],['expect',read('value'),3],
  ['captured','send',0],['tick'],['expect',read('value'),0],
  ...(ending==='dispose'?[['dispose']]:ending==='complete'?[['captured','complete']]:[['captured','fail',99]]),['tick'],
  ['captured','send',88],['captured','fail',89],['captured','complete'],['tick'],['dispose'],['tick']
 ]);
}
for(const deferred of[false,true])for(const lazy of[false,true])for(const seeded of[false,true])for(const throwCleanup of[false,true]){
 await scenario(`subscription supersedes before new source ${deferred}/${lazy}/${seeded}/${throwCleanup}`, [
  ...callbacks,['program','end',[['emit',71],...(throwCleanup?[['throw',77]]:[])]],['program','error',[['emit',72]]],['signal','step',0],
  ['program','subscribe',[...captureActions,['emit',73],['return',fn('end')]],3],
  [deferred?'deferred':'memo','value',seq(read('step'),{from:fn('subscribe')}),{lazy,...(seeded?{loadingValue:0}:{})}],
  ['effect','view',read('value'),{user:true,error:'error'}],['flush'],['capture','oldNext',get('next')],['capture','oldError',get('errorCallback')],['capture','oldComplete',get('complete')],
  ['captured','oldNext',1],['tick'],['expect',read('value'),1],
  ['set','step',1],['flush'],['capture','next',get('next')],['different','oldNext','next'],
  ['captured','oldNext',88],['captured','oldError',89],['captured','oldComplete'],['tick'],
  ['captured','next',2],['tick'],['expect',read('value'),2],
  ['awaitRefresh','refresh','value'],['tick'],['capture','refreshed',get('next')],['different','next','refreshed'],
  ['captured','next',99],['captured','refreshed',3],['tick'],['expect',read('value'),3],['dispose'],['tick']
 ]);
}

for(const returned of[undefined,null,false,0,'', {ref:19}])for(const deferred of[false,true]){
 await scenario(`noncallable teardown ${JSON.stringify(returned)}/${deferred}`, [
  ['program','subscribe',[['eval',invokeArg(0,7)],['return',lit(returned)]],3],
  [deferred?'deferred':'memo','value',{from:fn('subscribe')}],['effect','view',read('value')],['flush'],['tick'],['expect',read('value'),7],['dispose'],['tick']
 ]);
}
for(const deferred of[false,true])for(const pending of[false,true])for(const error of[undefined,null,false,99,{ref:19}]){
 const from={from:fn('bad')},old=future('old');
 const body=select({same:[read('step'),lit(0)]},lit(0),select({same:[read('step'),lit(1)]},old,from));
 await scenario(`preserved from factory throw ${deferred}/${pending}/${JSON.stringify(error)}`, [
  ['program','bad',[['throw',error]],3],['program','error',[['emit',72]]],['signal','step',0],['future','old'],
  [deferred?'deferred':'memo','value',body],['effect','view',read('value'),{user:true,error:'error'}],['flush'],
  ...(pending?[['set','step',1],['flush']]:[]),['set','step',2],['flush'],['awaitUntil','truth',read('value')],['tick'],
  ['resolve','old',5],['tick'],['dispose'],['tick']
 ]);
}
for(const payload of[undefined,null,false,0,-0,NaN,'λ',{ref:19},{callback:'data'}])for(const deferred of[false,true]){
 await scenario(`buffered payload identity ${String(payload)}/${deferred}`, [
  ['program','data',[['return',lit(99)]]],['program','subscribe',[['eval',invokeArg(0,payload)]],3],
  [deferred?'deferred':'memo','value',{from:fn('subscribe')}],['effect','view',read('value')],['flush'],['tick'],['dispose'],['tick']
 ]);
}
console.log(`${count} direct from subscription histories compare values, pending/error states, synchronous coalescing, late teardown, cleanup, supersession, original callback aliases and callback order.`);
