import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?iterator-history='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const consoleError=console.error;console.error=(...args)=>logs.push(args);
  function compare(op){
    const expectedNodes=solidStates(s);assert.deepEqual(bendStates(b,expectedNodes.map(([name])=>name)),expectedNodes,`${name}: node state after ${op}`);
    assert.deepEqual(b.iteratorIO(),s.iteratorIO(),`${name}: iterator protocol after ${op}`);
    assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
    for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
    assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: callback failures after ${op}`);
    for(const key of ['context','tracking','running'])assert.equal(b.world[key],key==='context'?0:false,`${name}: ${key}`);
    const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value' in r.cause?[b.errorShape(decode(r.cause.value,b.errors))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(decode(r.cause.value,b.errors))]);
    assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports after ${op}`);
  }
  try{
    for(const [op,...args] of commands){
      if(op==='tick')await setImmediate();
      else if(op==='microtick')await Promise.resolve();
      else {
        const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
        if(actual[0]==='return'&&expected[0]==='return'&&!['read','set','update','screen','future'].includes(op))actual[1]=expected[1]=undefined;
        assert.deepEqual(actual,expected,`${name}: ${op} result`);
      }
      compare(op);
    }
    count++;
  }catch(e){consoleError('FAILED: '+name);throw e;}
  finally{b.attempt('dispose');s.attempt('dispose');b.resetErrorHalt();s.resetErrorHalt();b.attempt('flush');s.attempt('flush');await setImmediate();console.error=consoleError;}
}
for(const steps of [[],[{value:1}],[{value:1},{value:2},{done:true}],[{done:true,value:99}],[{value:undefined},{value:null},{value:false}]]){
  await scenario('bare initial drain '+JSON.stringify(steps),[
    ['stream','s',steps],['memo','a',future('s')],['read','a'],['effect','view',read('a')],['flush'],['tick'],['read','a'],['dispose']
  ]);
}
for(const immediate of [false,true])for(const hasSeed of [false,true])for(const before of [false,true]){
  await scenario(`promise step ${immediate}/${hasSeed}/${before}`, [
    ['future','step',{immediate}],...(before?[['resolveStep','step',7]]:[]),
    ['stream','s',[{future:'step'},{value:8}]],['memo','a',future('s'),hasSeed?{loadingValue:0}:{}],['effect','view',read('a')],['flush'],
    ...(!before?[['resolveStep','step',7]]:[]),['microtick'],['read','a'],['tick'],['read','a'],['dispose']
  ]);
}
for(const immediate of [false,true])for(const hadValue of [false,true])for(const before of [false,true]){
  await scenario(`empty completion ${immediate}/${hadValue}/${before}`, [
    ['future','step',{immediate}],...(before?[['resolveStep','step',99,true]]:[]),
    ['stream','s',[...(hadValue?[{value:1}]:[]),{future:'step'}]],['memo','a',future('s'),{loadingValue:0}],['effect','view',read('a')],['flush'],
    ...(!before?[['resolveStep','step',99,true]]:[]),['microtick'],['read','a'],['tick'],['dispose']
  ]);
}
for(const immediate of [false,true])for(const before of [false,true])for(const hadValue of [false,true]){
  await scenario(`reject step ${immediate}/${before}/${hadValue}`, [
    ['program','error',[['emit',71]]],['future','step',{immediate}],...(before?[['reject','step',99]]:[]),
    ['stream','s',[...(hadValue?[{value:1}]:[]),{future:'step'}]],['memo','a',future('s')],['read','a'],['effect','user',read('a'),{user:true,error:'error'}],['flush'],
    ...(!before?[['reject','step',99]]:[]),['microtick'],['read','a'],['tick'],['dispose']
  ]);
}
for(const initialValue of [false,true]){
  await scenario(`next throws ${initialValue}`, [
    ['stream','s',[...(initialValue?[{value:1}]:[]),{throw:99}]],['memo','a',future('s')],['read','a'],['tick'],['dispose']
  ]);
}
for(const immediate of [false,true])for(const lazy of [false,true])for(const hasReturn of [false,true]){
  await scenario(`supersede iterator ${immediate}/${lazy}/${hasReturn}`, [
    ['future','step',{immediate}],['stream','s',[{value:1},{future:'step'},{value:3}],{hasReturn}],['signal','on',true],
    ['memo','a',select(read('on'),future('s'),lit(9)),{lazy}],['effect','view',read('a')],['flush'],['set','on',false],['flush'],
    ['resolveStep','step',7],['tick'],['read','a'],['dispose']
  ]);
}
for(const immediate of [false,true]){
  await scenario(`unobserved iterator releases ${immediate}`, [
    ['future','step',{immediate}],['stream','s',[{future:'step'},{value:8}]],['memo','a',future('s'),{lazy:true}],['read','a'],
    ['resolveStep','step',7],['tick'],['dispose']
  ]);
  await scenario(`disposal closes and ignores callback ${immediate}`, [
    ['future','step',{immediate}],['stream','s',[{future:'step'},{value:8}]],['memo','a',future('s')],['effect','view',read('a')],['flush'],
    ['dispose'],['resolveStep','step',7],['tick']
  ]);
  await scenario(`program allocated after internal close ${immediate}`, [
    ['future','step',{immediate}],['stream','s',[{future:'step'}]],['memo','a',future('s')],
    ['program','error',[['emit',71]]],['effect','user',read('a'),{user:true,error:'error'}],['flush'],['reject','step',99],['tick'],['dispose']
  ]);
}
for(const immediate of [false,true])for(const before of [false,true])for(const steps of [[],[{value:1},{value:2}]]){
  await scenario(`promise flattens iterable ${immediate}/${before}/${steps.length}`, [
    ['future','p',{immediate}],['stream','s',steps],...(before?[['resolveStream','p','s']]:[]),
    ['memo','a',future('p'),{loadingValue:0}],['effect','view',read('a')],['flush'],...(!before?[['resolveStream','p','s']]:[]),
    ['microtick'],['read','a'],['tick'],['dispose']
  ]);
}
for(const immediate of [false,true])for(const before of [false,true]){
  await scenario(`flatten starts with pending next ${immediate}/${before}`, [
    ['future','p',{immediate}],['future','step'],['stream','s',[{future:'step'},{value:8}]],...(before?[['resolveStream','p','s']]:[]),
    ['memo','a',future('p'),{loadingValue:0}],['effect','view',read('a')],['flush'],...(!before?[['resolveStream','p','s']]:[]),
    ['microtick'],['resolveStep','step',7],['tick'],['read','a'],['dispose']
  ]);
  await scenario(`return rejection swallowed ${immediate}/${before}`, [
    ['future','step'],['future','returned',{immediate}],...(before?[['reject','returned',99]]:[]),
    ['stream','s',[{future:'step'}],{returnFuture:'returned'}],['memo','a',future('s')],['effect','view',read('a')],['flush'],['dispose'],
    ...(!before?[['reject','returned',99]]:[]),['tick']
  ]);
}
await scenario('return throw swallowed',[
  ['future','step'],['stream','s',[{future:'step'}],{returnThrows:99}],['memo','a',future('s')],['effect','view',read('a')],['flush'],['dispose'],['tick']
]);
await scenario('sync opt-out never starts iterator',[
  ['stream','s',[{value:1}]],['memo','a',future('s'),{sync:true}],['read','a'],['tick'],['dispose']
]);

let seed=0x4a31e9;const rng=n=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return(seed>>>0)%n;};
for(let index=0;index<192;index++){
  const commands=[['program','error',[['emit',71]]]],steps=[],settlements=[];
  for(let step=0;step<3;step++){
    const immediate=!!rng(2),name='p'+step,value=[undefined,null,false,0,2,7][rng(6)],done=rng(5)===0,reject=rng(11)===0;
    commands.push(['future',name,{immediate}]);
    settlements.push(reject?['reject',name,99]:['resolveStep',name,value,done]);
    if(rng(2))commands.push(settlements[step]);
  }
  for(let step=0;step<5;step++){
    const kind=rng(5);
    steps.push(kind<=1?{future:'p'+rng(3)}:kind===2?{value:rng(9)}:kind===3?{done:true}:{throw:99});
  }
  commands.push(['stream','s',steps,{hasReturn:!!rng(2)}],['signal','on',true],['memo','a',select(read('on'),future('s'),lit(9)),{lazy:!!rng(2),...(rng(2)?{loadingValue:0}:{})}],['effect','user',read('a'),{user:true,error:'error'}],['flush']);
  for(const event of settlements){
    if(rng(7)===0)commands.push(['set','on',false],['flush']);
    commands.push(event,rng(2)?['tick']:['microtick'],['read','a']);
  }
  commands.push(['tick'],['read','a'],['dispose']);
  await scenario('generated iterator '+index,commands);
}
console.log(`${count} iterator histories match pinned TS initial drains, async gaps, bare steps, empty/rejected completion, cancellation, close and promise flattening.`);
