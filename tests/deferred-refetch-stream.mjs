import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?deferred-refetch-stream='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
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
      if(op==='expect'){const a=b.attempt('evaluate',args[0]),n=s.attempt('evaluate',args[0]);assert.deepEqual(a,['return',args[1]],name+' expected value');assert.deepEqual(n,a);}
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

for(const steps of[[],[{value:1}],[{value:1},{value:2},{done:true}],[{done:true,value:99}],[{value:undefined},{value:null},{value:false}]])for(const lazy of[false,true])for(const seeded of[false,true]){
 const expected=steps.some(step=>!step.done)?steps.filter(step=>!step.done).at(-1).value:undefined;
 await scenario(`refetch stream bare drain ${JSON.stringify(steps)}/${lazy}/${seeded}`,[
  ['stream','s',steps],['signal','step',0],['deferred','d',{select:[{read:'step'},{future:'s'},{lit:0}]},{lazy,...(seeded?{loadingValue:7}:{})}],
  ['effect','view',read('d')],['flush'],['set','step',1],['flush'],['tick'],['expect',read('d'),expected],
  ['set','step',0],['flush'],['set','step',1],['flush'],['tick'],['expect',read('d'),expected],['dispose']
 ]);
}
for(const immediate of[false,true])for(const before of[false,true])for(const done of[false,true])for(const lazy of[false,true])for(const seeded of[false,true]){
 await scenario(`refetch first promised step ${immediate}/${before}/${done}/${lazy}/${seeded}`,[
  ['future','step',{immediate}],...(before?[['resolveStep','step',7,done]]:[]),['stream','s',[{future:'step'},{value:8}]],
  ['signal','mode',0],['deferred','d',select(read('mode'),future('s'),lit(0)),{lazy,...(seeded?{loadingValue:1}:{})}],
  ['effect','view',read('d')],['flush'],['set','mode',1],['flush'],['expect',{isPending:read('d')},!(immediate&&before)],
  ['awaitUntil','truth',read('d')],['microtick'],...(!before?[['resolveStep','step',7,done]]:[]),['tick'],
  ['expect',read('d'),done?undefined:8],['expect',{isPending:read('d')},false],['dispose']
 ]);
}
for(const immediate of[false,true])for(const before of[false,true])for(const lazy of[false,true])for(const seeded of[false,true]){
 await scenario(`refetch first rejected step ${immediate}/${before}/${lazy}/${seeded}`,[
  ['program','error',[['emit',71]]],['future','step',{immediate}],...(before?[['reject','step',99]]:[]),['stream','s',[{future:'step'}]],
  ['signal','mode',0],['deferred','d',select(read('mode'),future('s'),lit(0)),{lazy,...(seeded?{loadingValue:1}:{})}],
  ['effect','view',read('d'),{user:true,error:'error'}],['flush'],['set','mode',1],['flush'],['awaitUntil','truth',read('d')],
  ['microtick'],...(!before?[['reject','step',99]]:[]),['tick'],['read','d'],['expect',{isPending:read('d')},false],['dispose']
 ]);
}
for(const immediate of[false,true])for(const bareFirst of[false,true])for(const hasReturn of[false,true])for(const returnThrows of[undefined,99]){
 await scenario(`refetch cancellation ${immediate}/${bareFirst}/${hasReturn}/${returnThrows}`,[
  ['future','step',{immediate}],['stream','s',[...(bareFirst?[{value:1}]:[]),{future:'step'},{value:3}],{hasReturn,...(returnThrows===undefined?{}:{returnThrows})}],
  ['signal','mode',0],['deferred','d',select(read('mode'),future('s'),lit(0))],['effect','view',read('d')],['flush'],
  ['set','mode',1],['flush'],['expect',{isPending:read('d')},!bareFirst],['dispose'],['resolveStep','step',7],['tick']
 ]);
}
for(const immediate of[false,true])for(const oldReject of[false,true])for(const oldFirst of[false,true]){
 await scenario(`refetch superseded first step ${immediate}/${oldReject}/${oldFirst}`,[
  ['program','error',[['emit',71]]],['future','old',{immediate}],['future','current',{immediate}],['stream','a',[{future:'old'},{value:2}]],['stream','b',[{future:'current'},{value:4}]],
  ['signal','mode',0],['deferred','d',select({same:[read('mode'),lit(1)]},future('a'),select(read('mode'),future('b'),lit(0)))],
  ['effect','view',read('d'),{user:true,error:'error'}],['flush'],['set','mode',1],['flush'],['set','mode',2],['flush'],['awaitUntil','truth',read('d')],
  ...(oldFirst?[[oldReject?'reject':'resolveStep','old',7],['tick'],['expect',{isPending:read('d')},true]]:[]),
  ['resolveStep','current',9],['tick'],['expect',read('d'),4],['expect',{isPending:read('d')},false],
  ...(!oldFirst?[[oldReject?'reject':'resolveStep','old',7],['tick'],['expect',read('d'),4]]:[]),['dispose']
 ]);
}
for(const immediate of[false,true])for(const hadValue of[false,true]){
 await scenario(`same producer wrapper identities ${immediate}/${hadValue}`,[
  ['future','step',{immediate}],['stream','s',[...(hadValue?[{value:1}]:[]),{future:'step'},{value:3}]],['signal','version',0],
  ['deferred','d',seq(read('version'),select(read('version'),future('s'),lit(0)))],['effect','view',read('d')],['flush'],
  ['set','version',1],['flush'],['set','version',2],['flush'],['resolveStep','step',7],['tick'],['expect',read('d'),3],['dispose']
 ]);
}
for(const immediate of[false,true])for(const rejectedReturn of[false,true]){
 await scenario(`wrapped promised return ${immediate}/${rejectedReturn}`,[
  ['future','step',{immediate}],['future','close',{immediate}],['stream','s',[{future:'step'}],{returnFuture:'close'}],
  ['signal','mode',0],['deferred','d',select(read('mode'),future('s'),lit(0))],['effect','view',read('d')],['flush'],
  ['set','mode',1],['flush'],['dispose'],[rejectedReturn?'reject':'resolve','close',7],['resolveStep','step',8],['tick']
 ]);
}
for(const immediate of[false,true])for(const before of[false,true])for(const steps of[[],[{value:1},{value:2}]])for(const lazy of[false,true])for(const seeded of[false,true]){
 await scenario(`refetch promise flatten ${immediate}/${before}/${steps.length}/${lazy}/${seeded}`,[
  ['future','p',{immediate}],['stream','s',steps],...(before?[['resolveStream','p','s']]:[]),['signal','mode',0],
  ['deferred','d',select(read('mode'),future('p'),lit(0)),{lazy,...(seeded?{loadingValue:1}:{})}],['effect','view',read('d')],['flush'],
  ['set','mode',1],['flush'],['awaitUntil','truth',read('d')],...(!before?[['resolveStream','p','s']]:[]),['microtick'],['tick'],
  ['expect',read('d'),steps.length?2:undefined],['expect',{isPending:read('d')},false],['dispose']
 ]);
}
for(const immediate of[false,true])for(const rowsFirst of[false,true])for(const bare of[false,true]){
 await scenario(`wrapped stream held landing ${immediate}/${rowsFirst}/${bare}`,[
  ['future','gate',{immediate}],['future','step',{immediate}],['stream','rows',bare?[{value:21}]:[{future:'step'}]],['signal','mode',0],
  ['memo','gate',select(read('mode'),future('gate'),lit(1))],['deferred','d',select(read('mode'),future('rows'),lit(7))],
  ['effect','gate-view',read('gate'),{target:2}],['effect','rows-view',read('d'),{target:3}],['flush'],['set','mode',1],['flush'],
  ...(rowsFirst?[...(!bare?[['resolveStep','step',21],['tick']]:[]),['expect',{latest:read('d')},21],['resolve','gate',2]]:[['resolve','gate',2],['tick'],...(!bare?[['resolveStep','step',21]]:[])]),
  ['tick'],['expect',read('d'),21],['expect',{isPending:read('d')},false],['dispose']
 ]);
}
for(const immediate of[false,true]){
 await scenario(`wrapped held landing retained across reask ${immediate}`,[
  ['future','gate',{immediate}],['future','first',{immediate}],['future','second',{immediate}],['stream','a',[{future:'first'}]],['stream','b',[{future:'second'}]],
  ['signal','mode',0],['signal','query',0],['memo','gate',select(read('mode'),future('gate'),lit(1))],
  ['deferred','d',seq(read('mode'),select(read('query'),future('b'),select(read('mode'),future('a'),lit(7))))],
  ['effect','gate-view',read('gate'),{target:2}],['effect','rows-view',read('d'),{target:3}],['flush'],['set','mode',1],['flush'],
  ['resolveStep','first',21],['tick'],['expect',{latest:read('d')},21],['set','query',1],['flush'],['expect',{latest:read('d')},21],
  ['resolve','gate',2],['tick'],['expect',read('d'),21],['expect',{isPending:read('d')},true],['resolveStep','second',31],['tick'],['expect',read('d'),31],['dispose']
 ]);
}
// Preserve the newly confirmed source protocol-error defect. A throw before
// the first yield leaves this wrapper's flight live; a prior bare yield lands
// it. The body-throw and promised-rejection controls are checked separately.
for(const immediate of[false,true])for(const prior of[false,true])for(const bareFirst of[false,true])for(const method of['awaitUntil','awaitRefresh']){
 let inError=false;
 await scenario(`preserved first protocol throw ${immediate}/${prior}/${bareFirst}/${method}`,[
  ['future','old',{immediate}],['stream','s',[...(bareFirst?[{value:1}]:[]),{throw:99}]],['signal','mode',0],
  ['deferred','d',select({same:[read('mode'),lit(2)]},future('s'),select(read('mode'),future('old'),lit(0)))],['flush'],
  ...(prior?[['set','mode',1],['flush']]:[]),['set','mode',2],['flush'],['expect',{isPending:read('d')},!bareFirst],
  [method,'truth',...(method==='awaitRefresh'?['d']:[read('d')])],['tick'],['resolve','old',9],['tick'],
  ['expect',{isPending:read('d')},!bareFirst],['set','mode',0],['flush'],['tick'],['expect',read('d'),0],['expect',{isPending:read('d')},false],['dispose']
 ],(op,args,b)=>{if(op==='set'&&args[0]==='mode')inError=args[1]===2;if(op==='tick'&&inError)assert.equal(b.portEvents.length,bareFirst?1:0,'source baseline first-throw flight behavior');});
}
for(const immediate of[false,true])for(const deferred of[false,true])for(const prior of[false,true])for(const method of['awaitUntil','awaitRefresh']){
 let inError=false,oldSettled=false;
 await scenario(`factory throw outside source fn catch ${immediate}/${deferred}/${prior}/${method}`,[
  ['future','old',{immediate}],['stream','s',[],{factoryThrows:99}],['signal','mode',0],
  [deferred?'deferred':'memo','d',select({same:[read('mode'),lit(2)]},future('s'),select(read('mode'),future('old'),lit(0)))],['flush'],
  ...(prior?[['set','mode',1],['flush']]:[]),['set','mode',2],['flush'],['expect',{isPending:read('d')},deferred&&prior],
  [method,'truth',...(method==='awaitRefresh'?['d']:[read('d')])],['tick'],['resolve','old',9],['tick'],
  ['expect',{isPending:read('d')},false],['read','d'],['set','mode',0],['flush'],['tick'],['expect',read('d'),0],['dispose']
 ],(op,args,b)=>{
  if(op==='set'&&args[0]==='mode')inError=args[1]===2;
  if(op==='resolve'&&args[0]==='old')oldSettled=true;
  if(op==='tick'&&inError)assert.equal(b.portEvents.length,deferred&&prior&&!oldSettled?0:1,'source baseline factory throw retains only an existing flight');
 });
}
for(const error of[undefined,null,false,99,{ref:3}])for(const deferred of[false,true]){
 await scenario(`factory thrown payload ${String(error)}/${deferred}`,[
  ['future','old'],['stream','s',[],{factoryThrows:error}],['signal','mode',0],
  [deferred?'deferred':'memo','d',select({same:[read('mode'),lit(2)]},future('s'),select(read('mode'),future('old'),lit(0)))],
  ['flush'],['set','mode',1],['flush'],['set','mode',2],['flush'],['read','d'],['awaitUntil','truth',read('d')],['tick'],
  ['resolve','old',9],['tick'],['expect',{isPending:read('d')},false],['read','d'],['dispose']
 ]);
}
console.log(`${count} deferred refetch stream histories compare values, verdicts, callback counts, iterator calls, replacement/held identities, flattening, cleanup and preserved protocol errors.`);
