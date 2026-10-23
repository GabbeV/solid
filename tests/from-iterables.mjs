import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?from-iterables='+count);
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

const wrap=source=>({from:source});
for(const steps of[[],[{value:0}],[{value:1},{value:2},{value:3}],[{value:false}],[{value:undefined}],[{value:{ref:19}}]])for(const deferred of[false,true])for(const lazy of[false,true])for(const refetch of[false,true]){
 await scenario(`wrapped bare ${steps.length}/${deferred}/${lazy}/${refetch}`, [
  ['stream','source',steps],['signal','mode',refetch?0:1],
  [deferred?'deferred':'memo','value',select(read('mode'),wrap(future('source')),lit(7)),{lazy}],
  ['effect','view',read('value')],['flush'],...(refetch?[['set','mode',1],['flush']]:[]),['tick'],['dispose'],['tick']
 ]);
}
for(const immediate of[false,true])for(const before of[false,true])for(const deferred of[false,true])for(const refetch of[false,true])for(const rejected of[false,true])for(const seeded of[false,true]){
 await scenario(`wrapped promised ${immediate}/${before}/${deferred}/${refetch}/${rejected}/${seeded}`, [
  ['program','error',[['emit',71]]],['future','step',{immediate}],...(before?[[rejected?'reject':'resolveStep','step',9]]:[]),
  ['stream','source',[{future:'step'},{value:3}]],['signal','mode',refetch?0:1],
  [deferred?'deferred':'memo','value',select(read('mode'),wrap(future('source')),lit(7)),{...(seeded?{loadingValue:0}:{})}],
  ['effect','view',read('value'),{user:true,error:'error'}],['flush'],...(refetch?[['set','mode',1],['flush']]:[]),['awaitUntil','truth',read('value')],['microtick'],
  ...(!before?[[rejected?'reject':'resolveStep','step',9]]:[]),['tick'],['read','value'],['dispose'],['tick']
 ]);
}
for(const immediate of[false,true])for(const deferred of[false,true])for(const bareFirst of[false,true])for(const hasReturn of[false,true])for(const returnThrows of[false,true]){
 await scenario(`wrapped cancellation ${immediate}/${deferred}/${bareFirst}/${hasReturn}/${returnThrows}`, [
  ['future','step',{immediate}],['stream','source',[...(bareFirst?[{value:1}]:[]),{future:'step'},{value:3}],{hasReturn,...(returnThrows?{returnThrows:99}:{})}],
  [deferred?'deferred':'memo','value',wrap(future('source'))],['effect','view',read('value')],['flush'],['dispose'],['resolveStep','step',9],['tick']
 ]);
}
for(const immediate of[false,true])for(const deferred of[false,true])for(const rejectOld of[false,true])for(const oldFirst of[false,true]){
 await scenario(`wrapped replacement ${immediate}/${deferred}/${rejectOld}/${oldFirst}`, [
  ['future','old',{immediate}],['future','current',{immediate}],['stream','a',[{future:'old'},{value:2}]],['stream','b',[{future:'current'},{value:4}]],
  ['signal','mode',0],[deferred?'deferred':'memo','value',wrap(select(read('mode'),future('b'),future('a')))],['effect','view',read('value')],['flush'],['set','mode',1],['flush'],
  ...(oldFirst?[[rejectOld?'reject':'resolveStep','old',7],['tick']]:[]),['resolveStep','current',9],['tick'],['expect',read('value'),4],
  ...(!oldFirst?[[rejectOld?'reject':'resolveStep','old',7],['tick'],['expect',read('value'),4]]:[]),['dispose'],['tick']
 ]);
}
for(const immediate of[false,true])for(const deferred of[false,true])for(const rejectReturn of[false,true]){
 await scenario(`wrapped promised return ${immediate}/${deferred}/${rejectReturn}`, [
  ['future','step',{immediate}],['future','close',{immediate}],['stream','source',[{future:'step'}],{returnFuture:'close'}],
  [deferred?'deferred':'memo','value',wrap(future('source'))],['effect','view',read('value')],['flush'],['dispose'],
  [rejectReturn?'reject':'resolve','close',9],['resolveStep','step',8],['tick']
 ]);
}
for(const deferred of[false,true])for(const first of[false,true])for(const factory of[false,true])for(const prior of[false,true]){
 await scenario(`wrapped preserved protocol error ${deferred}/${first}/${factory}/${prior}`, [
  ['program','error',[['emit',71]]],['future','old'],['stream','source',[...(first?[{value:1}]:[]),{throw:99}],{...(factory?{factoryThrows:99}:{})}],['signal','mode',0],
  [deferred?'deferred':'memo','value',select({same:[read('mode'),lit(2)]},wrap(future('source')),select(read('mode'),future('old'),lit(7)))],
  ['effect','view',read('value'),{user:true,error:'error'}],['flush'],...(prior?[['set','mode',1],['flush']]:[]),['set','mode',2],['flush'],['tick'],['resolve','old',9],['tick'],['dispose'],['tick']
 ]);
}
for(const depth of[1,2,3])for(const deferred of[false,true])for(const immediate of[false,true]){
 let expr=future('source');for(let i=0;i<depth;i++)expr=wrap(expr);
 await scenario(`nested wrapped ${depth}/${deferred}/${immediate}`, [
  ['future','step',{immediate}],['stream','source',[{value:1},{future:'step'},{value:3}]],
  [deferred?'deferred':'memo','value',expr],['effect','view',read('value')],['flush'],['resolveStep','step',9],['tick'],['expect',read('value'),3],['dispose'],['tick']
 ]);
}

const arg=argument=>({argument}),fn=name=>lit({callback:name});
const root=lit({owner:'root'}),get=name=>({getContext:{name,owner:root}});
for(const depth of[1,2])for(const deferred of[false,true])for(const throwCleanup of[false,true]){
 let source=wrap(fn('subscribe'));for(let i=0;i<depth;i++)source=wrap(source);
 await scenario(`wrapped callback subscription ${depth}/${deferred}/${throwCleanup}`, [
  ['context','factory',undefined],['context','next',undefined],['signal','version',0],
  ['program','end',[['emit',71],...(throwCleanup?[['throw',99]]:[])]],
  ['program','subscribe',[['eval',{setContext:{name:'next',value:arg(0),owner:root}}],['return',fn('end')]],3],
  ['evaluate',{setContext:{name:'factory',value:source,owner:root}}],
  [deferred?'deferred':'memo','value',seq(read('version'),get('factory'))],['effect','view',read('value')],['flush'],
  ['capture','old',get('next')],['captured','old',1],['tick'],['expect',read('value'),1],
  ['set','version',1],['flush'],['capture','current',get('next')],['different','old','current'],
  ['captured','old',88],['captured','current',2],['tick'],['expect',read('value'),2],['dispose'],['tick']
 ]);
}
console.log(`${count} from AsyncIterable histories compare every value/error/flight/iterator/cleanup prefix, including bare and promised steps, argument forwarding, cancellation, nested wrappers and preserved protocol errors.`);
