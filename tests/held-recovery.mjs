import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?held-recovery-history='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const consoleError=console.error;console.error=(...args)=>logs.push(args);
  function compare(op){
    const expectedNodes=solidStates(s);assert.deepEqual(bendStates(b,expectedNodes.map(([name])=>name)),expectedNodes,`${name}: node state after ${op}`);
    assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
    for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
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
for(const immediate of [false,true])for(const variant of ['no-error','no-recovery','same-recovery','changed-recovery'])for(const user of [false,true]){
 const commands=[['future','q',{immediate}],['signal','mode',false],['signal','stage',0],['program','error',[['emit',71]]],
  ['memo','b',select(read('mode'),future('q'),lit(1))],
  ['memo','a',select({same:[read('stage'),lit(1)]},{raise:99},select({same:[read('stage'),lit(2)]},lit(7),lit(1)))],
  ['memo','c',add(read('b'),read('a'))],['effect','view',read('c'),user?{user:true,error:'error'}:{}],['flush'],
  ['set','mode',true],...(variant!=='no-error'?[['set','stage',1]]:[]),['flush'],
  ...(variant==='same-recovery'?[['set','stage',0]]:variant==='changed-recovery'?[['set','stage',2]]:[]),['flush'],
  ['read','a'],['resolve','q',2],['tick'],['read','a'],['read','c']];
 await scenario(`held staged recovery ${immediate}/${variant}/user=${user}`,commands);
}
console.log(`${count} held-error recovery histories match source state, delivery, reports and the merged held-error recovery fix, with non-render controls.`);
