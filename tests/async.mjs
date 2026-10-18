import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?async-history='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const consoleError=console.error;console.error=(...args)=>logs.push(args);
  function compare(op){
    const expectedNodes=solidStates(s);assert.deepEqual(bendStates(b,expectedNodes.map(([name])=>name)),expectedNodes,`${name}: node state after ${op}`);
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
for(const immediate of [true,false])for(const loading of [false,true])for(const lazy of [false,true]){
  const options={lazy,...(loading?{loadingValue:0}:{})};
  await scenario(`resolve immediate=${immediate} loading=${loading} lazy=${lazy}`, [
    ['future','p',{immediate}],['memo','a',future('p'),options],['read','a'],
    ['effect','view',read('a')],['flush'],['read','a'],['resolve','p',7],['tick'],['read','a'],['flush'],['read','a']
  ]);
}
for(const immediate of [true,false])for(const reject of [false,true])for(const loadingValue of [undefined,0]){
  await scenario(`settled before registration ${immediate}/${reject}/${loadingValue}`, [
    ['future','p',{immediate}],[reject?'reject':'resolve','p',7],['memo','a',future('p'),{loadingValue}],['read','a'],
    ['program','error',[['emit',7]]],['effect','user',read('a'),{user:true,error:'error'}],['flush'],['tick'],['read','a']
  ]);
}
for(const immediate of [false,true])for(const loading of [false,true]){
  await scenario(`reject after registration ${immediate}/${loading}`, [
    ['future','p',{immediate}],['memo','a',future('p'),loading?{loadingValue:0}:{}],
    ['program','error',[['emit',7]]],['effect','user',read('a'),{user:true,error:'error'}],['flush'],
    ['reject','p',99],['read','a'],['tick'],['read','a'],['flush']
  ]);
}
for(const immediate of [false,true])for(const staleReject of [false,true]){
  await scenario(`supersede ${immediate}/${staleReject}`, [
    ['future','p',{immediate}],['future','q',{immediate}],['signal','on',true],
    ['memo','a',select(read('on'),future('p'),future('q')),{loadingValue:0}],['effect','view',read('a')],['flush'],
    ['set','on',false],['flush'],[staleReject?'reject':'resolve','p',99],['tick'],['read','a'],
    ['resolve','q',7],['tick'],['read','a']
  ]);
}
for(const immediate of [false,true]){
  await scenario(`pending diamond ${immediate}`, [
    ['future','p',{immediate}],['memo','a',future('p')],['memo','b',add(read('a'),lit(1))],['memo','c',add(read('a'),lit(2))],
    ['memo','d',add(read('b'),read('c'))],['effect','view',read('d')],['flush'],['resolve','p',7],['tick'],['read','d']
  ]);
  await scenario(`same result re-registration ${immediate}`, [
    ['future','p',{immediate}],['signal','x',0],['memo','a',seq(read('x'),future('p'))],['effect','view',read('a')],['flush'],
    ['set','x',1],['flush'],['resolve','p',7],['tick'],['read','a']
  ]);
  await scenario(`disposed callback ${immediate}`, [
    ['future','p',{immediate}],['memo','a',future('p')],['effect','view',read('a')],['flush'],['dispose'],['resolve','p',7],['tick']
  ]);
}

for(const immediate of [false,true])for(const seed of [undefined,null,false,0,NaN,{ref:3}]){
  await scenario(`loading payload ${immediate}/${String(seed)}`, [
    ['future','p',{immediate}],['memo','a',future('p'),{loadingValue:seed}],['effect','view',read('a')],['flush'],
    ['resolve','p',seed],['microtick'],['read','a'],['microtick'],['flush'],['read','a']
  ]);
}
for(const immediate of [false,true])for(const settleBeforeFlush of [false,true])for(const reject of [false,true]){
  await scenario(`new dirty write precedes callback ${immediate}/${settleBeforeFlush}/${reject}`, [
    ['future','p',{immediate}],['future','q',{immediate}],['signal','on',true],
    ['memo','a',select(read('on'),future('p'),future('q')),{loadingValue:0}],['effect','view',read('a')],['flush'],
    ['set','on',false],...(settleBeforeFlush?[]:[['flush']]),[reject?'reject':'resolve','p',99],['microtick'],
    ['resolve','q',7],['microtick'],['read','a'],['microtick'],['flush'],['read','a']
  ]);
}
for(const immediate of [false,true])for(const end of [undefined,null,false,7]){
  await scenario(`sync replacement ${immediate}/${end}`, [
    ['future','p',{immediate}],['signal','on',true],['memo','a',select(read('on'),future('p'),lit(end)),{loadingValue:0}],
    ['effect','view',read('a')],['flush'],['set','on',false],['flush'],['resolve','p',99],['microtick'],['read','a']
  ]);
}
for(const immediate of [false,true]){
  await scenario(`repeated external settlement ${immediate}`, [
    ['future','p',{immediate}],['memo','a',future('p')],['effect','view',read('a')],['flush'],
    ['resolve','p',7],['reject','p',99],['resolve','p',9],['tick'],['read','a']
  ]);
  await scenario(`unobserved release hook ${immediate}`, [
    ['program','release',[['emit',71]]],['future','p',{immediate}],['memo','a',future('p'),{lazy:true,unobserved:'release'}],
    ['read','a'],['resolve','p',7],['tick'],['read','a'],['tick']
  ]);
  await scenario(`sync opt-out retains result object ${immediate}`, [
    ['future','p',{immediate}],['memo','a',future('p'),{sync:true}],['read','a'],
    ['resolve','p',7],['microtick'],['read','a']
  ]);
  await scenario(`settled promise shared by siblings ${immediate}`, [
    ['future','p',{immediate}],['memo','a',future('p')],['memo','b',future('p')],['memo','c',add(read('a'),read('b'))],
    ['effect','view',read('c')],['flush'],['resolve','p',7],['microtick'],['read','c'],['microtick'],['read','c']
  ]);
  await scenario(`callback throw is observed ${immediate}`, [
    ['program','bad',[['emit',71],['throw',99]]],['future','p',{immediate}],['effect','user',future('p'),{user:true,program:'bad'}],
    ['flush'],['resolve','p',7],['tick']
  ]);
}
console.log(`${count} promise-like histories match pinned TS registration, loading, delivery, rejection, supersession and pending propagation.`);
