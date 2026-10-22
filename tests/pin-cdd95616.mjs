import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands){
  const module=await import((process.env.SOLID_EMIT_FILE??'../build/solid.mjs')+'?cdd-stale-reader='+count);
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
      if(op==='expectView'){for(const r of[b,s]){assert.equal(r.screen(2),args[0],name+' panel');assert.equal(r.screen(3),args[1],name+' gate');}}
      else if(op==='tick')await setImmediate();
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
for(const immediate of[false,true])for(const chain of[false,true])for(const supersede of[false,true]){
 const value=select({same:[read('src'),lit(0)]},future('p0'),select({same:[read('src'),lit(1)]},future('p1'),future('p2')));
 const commands=[['future','p0',{immediate}],['future','p1',{immediate}],['future','p2',{immediate}],['signal','show',true],['signal','src',0],['memo','m0',value],...(chain?[['memo','m1',read('m0')]]:[]),['effect','panel',select(read('show'),add(read('src'),read(chain?'m1':'m0')),lit(99)),{target:2}],['effect','shown',read('show'),{target:3}],['flush'],['resolve','p0',0],['tick'],['set','show',false],['set','src',1],['flush'],['tick'],['set','show',true],['flush'],['tick'],...(supersede?[['set','src',2],['flush'],['tick'],['expectView',99,false],['resolve','p2',0],['tick'],['expectView',2,true]]:[['resolve','p1',0],['tick'],['expectView',1,true]]),['dispose']];
 await scenario(`stale reader landing ${immediate}/${chain}/${supersede}`,commands);
}
console.log(`${count} cdd95616 histories compare the landed-frame re-derivation barrier, retained render order and no-supersession controls.`);
