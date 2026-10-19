import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?waiter-history='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const consoleError=console.error;console.error=(...args)=>logs.push(args);
  function compare(op){
    const expectedNodes=solidStates(s);assert.deepEqual(bendStates(b,expectedNodes.map(([name])=>name)),expectedNodes,`${name}: node state after ${op}`);
    assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
    for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
    assert.deepEqual(b.portSnapshots,s.portSnapshots,`${name}: screen at promise observer after ${op}`);
    assert.deepEqual(b.portEvents,s.portEvents,`${name}: promise delivery after ${op}`);
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
for(const value of [undefined,null,false,0,7,NaN,{ref:3}]){
  await scenario('resolve literal '+String(value),[['awaitValue','r',lit(value)],['microtick'],['microtick'],['tick']]);
}
for(const value of [undefined,null,false,0,99,{ref:3}]){
  await scenario('resolve rejects raw '+String(value),[['awaitValue','r',{raise:value}],['microtick'],['microtick'],['tick']]);
}
for(const immediate of [false,true])for(const loading of [false,true])for(const reject of [false,true]){
  await scenario(`resolve async ${immediate}/${loading}/${reject}`, [
    ['future','p',{immediate}],['memo','a',future('p'),loading?{loadingValue:0}:{}],['awaitValue','r',read('a')],['microtick'],
    [reject?'reject':'resolve','p',reject?99:7],['microtick'],['microtick'],['tick'],['read','a']
  ]);
}
for(const immediate of [false,true])for(const before of [false,true]){
  await scenario(`multiple resolve waiters ${immediate}/${before}`, [
    ['future','p',{immediate}],...(before?[['resolve','p',7]]:[]),['memo','a',future('p')],
    ['awaitValue','r',read('a')],['awaitValue','s',read('a')],['awaitValue','t',add(read('a'),lit(1))],
    ...(!before?[['resolve','p',7]]:[]),['microtick'],['microtick'],['tick']
  ]);
}
await scenario('watch catches a nested expression throw with a saved value stack',[
  ['memo','a',{raise:99}],['awaitValue','r',add(lit(17),read('a'))],['microtick'],['microtick'],['tick']
]);
await scenario('watch disposal runs registered cleanup',[
  ['program','clean',[['emit',71]]],['program','register',[['cleanup','clean']]],['signal','x',7],
  ['awaitValue','r',seq({call:'register'},read('x'))],['microtick'],['microtick'],['tick']
]);
await scenario('plain signal refresh and invalid target',[
  ['signal','x',7],['awaitRefresh','r','x'],['awaitRefresh','invalid','missing'],['microtick'],['microtick'],['tick']
]);
for(const calls of [1,2,3]){
  await scenario('sync refresh coalesces '+calls,[
    ['signal','x',7],['memo','a',read('x')],['effect','view',read('a')],['flush'],
    ...Array.from({length:calls},(_,i)=>['awaitRefresh','r'+i,'a']),['microtick'],['microtick'],['tick'],['read','a']
  ]);
}
for(const immediate of [false,true])for(const reject of [false,true])for(const refreshBeforeFirst of [false,true]){
  await scenario(`refresh reask ${immediate}/${reject}/${refreshBeforeFirst}`, [
    ['future','p',{immediate}],['future','q',{immediate}],['signal','on',true],
    ['memo','a',select(read('on'),future('p'),future('q'))],['effect','view',read('a')],['flush'],
    ...(!refreshBeforeFirst?[['resolve','p',1],['tick']]:[]),['set','on',false],
    ['awaitRefresh','r','a'],['awaitRefresh','s','a'],['microtick'],['awaitValue','ordinary',read('a')],
    [reject?'reject':'resolve','q',reject?99:7],['microtick'],['microtick'],['tick'],['read','a']
  ]);
}

await scenario('promise settles before disposal throws',[
  ['program','bad',[['emit',71],['throw',99]]],['program','register',[['cleanup','bad']]],
  ['awaitValue','r',seq({call:'register'},lit(7))],['microtick'],['microtick'],['tick']
]);
await scenario('promise reaction runs before cleanup-staged flush',[
  ['signal','x',0],['effect','view',read('x')],['flush'],['program','clean',[['emit',71],['set','x',2]]],['program','register',[['cleanup','clean']]],
  ['awaitValue','r',seq({call:'register'},lit(7))],['microtick'],['microtick'],['tick']
]);

for(const immediate of [false,true])for(const lazy of [false,true])for(const equal of [false,true]){
  await scenario(`refresh waiter is rooted ${immediate}/${lazy}/${equal}`, [
    ['future','p',{immediate}],['memo','a',future('p'),{lazy}],['awaitRefresh','r','a'],['microtick'],
    ['resolve','p',7],['microtick'],['microtick'],['tick'],
    ...(equal?[['awaitRefresh','same','a'],['microtick'],['microtick'],['tick']]:[]),['read','a']
  ]);
}
for(const immediate of [false,true])for(const lazy of [false,true]){
  await scenario(`resolve owns its pending watcher ${immediate}/${lazy}`, [
    ['future','p',{immediate}],['memo','a',future('p'),{lazy}],['awaitValue','r',read('a')],['microtick'],['resolve','p',7],['tick'],['read','a']
  ]);
  await scenario(`refresh tracks a superseding flight ${immediate}/${lazy}`, [
    ['future','p',{immediate}],['future','q',{immediate}],['future','r',{immediate}],['signal','which',0],
    ['memo','a',select({same:[read('which'),lit(0)]},future('p'),select({same:[read('which'),lit(1)]},future('q'),future('r'))),{lazy}],
    ['effect','view',read('a')],['flush'],['resolve','p',7],['tick'],['set','which',1],['awaitRefresh','next','a'],['microtick'],
    ['set','which',2],['flush'],['resolve','q',99],['microtick'],['awaitValue','first',read('a')],['resolve','r',7],['tick'],['read','a']
  ]);
}
for(const before of [false,true]){
  await scenario(`refresh disposed target ${before}`, [
    ['memo','a',lit(7)],...(before?[['dispose']]:[]),['awaitRefresh','r','a'],...(!before?[['dispose']]:[]),['microtick'],['microtick'],['tick']
  ]);
  await scenario(`resolve iterable landing ${before}`, [
    ['future','step',{immediate:before}],['stream','s',[{future:'step'},{value:8}]],['memo','a',future('s')],['awaitValue','r',read('a')],
    ['resolveStep','step',7],['microtick'],['microtick'],['tick']
  ]);
}
await scenario('fire and forget refresh uses the public waiter path',[
  ['memo','a',lit(7)],['refresh','a'],['microtick'],['microtick'],['tick']
]);

let seed=0xd431a7;const rng=n=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return(seed>>>0)%n;};
for(let index=0;index<96;index++){
  const user=!!rng(2),commands=[['program','error',[['emit',71]]],['future','p',{immediate:!!rng(2)}],['future','q',{immediate:!!rng(2)}],['signal','on',true],
    ['memo','a',select(read('on'),future('p'),future('q')),{lazy:!!rng(2),...(rng(2)?{loadingValue:0}:{})}],
    ['effect','view',read('a'),{user,...(user?{error:'error'}:{})}],['flush']];
  for(let stage=0;stage<3;stage++){
    for(let call=0,n=1+rng(3);call<n;call++)commands.push(rng(2)?['awaitRefresh',`r${stage}_${call}`,'a']:['awaitValue',`v${stage}_${call}`,read('a')]);
    if(stage===0)commands.push([rng(5)?'resolve':'reject','p',rng(2)?7:99]);
    if(stage===1)commands.push(['set','on',false]);
    if(stage===2)commands.push([rng(5)?'resolve':'reject','q',rng(2)?7:99]);
    commands.push(rng(2)?['microtick']:['tick']);
    if(rng(2))commands.push(['flush']);
  }
  commands.push(['tick'],['read','a'],['dispose']);
  await scenario('generated public waiter '+index,commands);
}
console.log(`${count} public promise-watcher histories match pinned TS eager resolve, deferred/coalesced refresh, pending/error answers, cleanup and delivery timing.`);
