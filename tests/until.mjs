import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?until-history='+count);
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
    const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value' in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
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
for(const value of [undefined,null,false,0,NaN,'',true,7,'ready',{ref:3}]){
 await scenario('until literal '+String(value),[['awaitUntil','r',lit(value)],['microtick'],['microtick'],['tick']]);
}
for(const value of [undefined,null,false,99,{ref:3}]){
 await scenario('until raw rejection '+String(value),[['awaitUntil','r',{raise:value}],['microtick'],['microtick'],['tick']]);
}
for(const initial of [undefined,null,false,0,NaN,'']){
 await scenario('until waits for truthy after '+String(initial),[
  ['signal','x',initial],['awaitUntil','r',read('x')],['tick'],['set','x',7],['flush'],['microtick'],['microtick'],['tick'],['set','x',8],['flush']
 ]);
}
for(const immediate of [false,true])for(const loading of [false,true])for(const reject of [false,true]){
 await scenario(`until async ${immediate}/${loading}/${reject}`, [
  ['future','p',{immediate}],['memo','a',future('p'),loading?{loadingValue:0}:{}],['awaitUntil','r',read('a')],['tick'],
  [reject?'reject':'resolve','p',reject?99:7],['microtick'],['microtick'],['tick']
 ]);
}
for(const immediate of [false,true])for(const lazy of [false,true]){
 await scenario(`until stays subscribed through a falsy landing ${immediate}/${lazy}`, [
  ['future','p',{immediate}],['future','q',{immediate}],['signal','on',false],
  ['memo','a',select(read('on'),future('q'),future('p')),{lazy}],['awaitUntil','r',read('a')],['resolve','p',0],['tick'],
  ['set','on',true],['flush'],['resolve','q',7],['tick']
 ]);
 await scenario(`until follows a stream's falsy/true values ${immediate}/${lazy}`, [
  ['future','step',{immediate}],['stream','s',[{value:0},{future:'step'},{value:8}]],['memo','a',future('s'),{lazy}],
  ['awaitUntil','r',read('a')],['tick'],['resolveStep','step',7],['tick']
 ]);
}
await scenario('until truthy queued answer wins before a later falsy pass',[
 ['signal','x',0],['awaitUntil','r',read('x')],['set','x',7],['flush'],['set','x',0],['flush'],['microtick'],['microtick'],['tick']
]);
await scenario('until cleanup runs only on truthy settlement',[
 ['program','clean',[['emit',71]]],['program','register',[['cleanup','clean']]],['signal','x',0],
 ['awaitUntil','r',seq({call:'register'},read('x'))],['tick'],['set','x',7],['flush'],['microtick'],['microtick'],['tick']
]);
await scenario('until cleanup throw preserves resolved answer',[
 ['program','bad',[['emit',71],['throw',99]]],['program','register',[['cleanup','bad']]],
 ['awaitUntil','r',seq({call:'register'},lit(7))],['microtick'],['microtick'],['tick']
]);
let seed=0x8b41da;const rng=n=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return(seed>>>0)%n;};
for(let index=0;index<96;index++){
 const commands=[['signal','x',0],['awaitUntil','r',read('x')]];
 for(let stage=0;stage<4;stage++)commands.push(['set','x',[undefined,null,false,0,NaN,'',7,8][rng(8)]],['flush'],rng(2)?['tick']:['microtick']);
 commands.push(['set','x',7],['flush'],['tick']);await scenario('generated until '+index,commands);
}
console.log(`${count} default until histories match TS truthy/falsy delivery, pending/errors, repeated frames, cleanup, streams and native promise observer order.`);
