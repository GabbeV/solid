import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?deferred-first-stream='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const consoleError=console.error;console.error=(...args)=>logs.push(args);
  function compare(op){
    const expectedNodes=solidStates(s);assert.deepEqual(bendStates(b,expectedNodes.map(([name])=>name)),expectedNodes,`${name}: node state after ${op}`);
    assert.deepEqual(b.iteratorIO(),s.iteratorIO(),`${name}: iterator protocol after ${op}`);
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
        if(actual[0]==='return'&&expected[0]==='return'&&!['read','set','update','screen','future'].includes(op))actual[1]=expected[1]=undefined;
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
 await scenario(`first stream initial drain ${JSON.stringify(steps)}/${lazy}/${seeded}`,[['stream','s',steps],['deferred','d',future('s'),{lazy,...(seeded?{loadingValue:0}:{})}],['read','d'],['effect','view',read('d')],['flush'],['tick'],['read','d'],['dispose']]);
}
for(const immediate of[false,true])for(const seeded of[false,true])for(const before of[false,true])for(const lazy of[false,true]){
 await scenario(`first stream promised step ${immediate}/${seeded}/${before}/${lazy}`,[['future','step',{immediate}],...(before?[['resolveStep','step',7]]:[]),['stream','s',[{future:'step'},{value:8}]],['deferred','d',future('s'),{lazy,...(seeded?{loadingValue:0}:{})}],['effect','view',read('d')],['flush'],...(!before?[['resolveStep','step',7]]:[]),['microtick'],['read','d'],['tick'],['read','d'],['dispose']]);
}
for(const immediate of[false,true])for(const hadValue of[false,true])for(const before of[false,true])for(const seeded of[false,true]){
 await scenario(`first stream empty completion ${immediate}/${hadValue}/${before}/${seeded}`,[['future','step',{immediate}],...(before?[['resolveStep','step',99,true]]:[]),['stream','s',[...(hadValue?[{value:1}]:[]),{future:'step'}]],['deferred','d',future('s'),seeded?{loadingValue:0}:{}],['effect','view',read('d')],['flush'],...(!before?[['resolveStep','step',99,true]]:[]),['microtick'],['read','d'],['tick'],['dispose']]);
}
for(const immediate of[false,true])for(const before of[false,true])for(const hadValue of[false,true])for(const lazy of[false,true]){
 await scenario(`first stream rejection ${immediate}/${before}/${hadValue}/${lazy}`,[['program','error',[['emit',71]]],['future','step',{immediate}],...(before?[['reject','step',99]]:[]),['stream','s',[...(hadValue?[{value:1}]:[]),{future:'step'}]],['deferred','d',future('s'),{lazy}],['read','d'],['effect','view',read('d'),{user:true,error:'error'}],['flush'],...(!before?[['reject','step',99]]:[]),['microtick'],['read','d'],['tick'],['dispose']]);
}
for(const initialValue of[false,true])for(const lazy of[false,true])await scenario(`first stream next throws ${initialValue}/${lazy}`,[['stream','s',[...(initialValue?[{value:1}]:[]),{throw:99}]],['deferred','d',future('s'),{lazy}],['read','d'],['tick'],['dispose']]);
for(const immediate of[false,true])for(const hasReturn of[false,true])for(const returnThrows of[undefined,99])await scenario(`first stream cancellation ${immediate}/${hasReturn}/${returnThrows}`,[['future','step',{immediate}],['stream','s',[{value:1},{future:'step'},{value:3}],{hasReturn,...(returnThrows===undefined?{}:{returnThrows})}],['deferred','d',future('s')],['effect','view',read('d')],['flush'],['dispose'],['resolveStep','step',7],['tick']]);
for(const immediate of[false,true])for(const before of[false,true])for(const steps of[[],[{value:1},{value:2}]])for(const seeded of[false,true])await scenario(`first promise-to-stream ${immediate}/${before}/${steps.length}/${seeded}`,[['future','p',{immediate}],['stream','s',steps],...(before?[['resolveStream','p','s']]:[]),['deferred','d',future('p'),seeded?{loadingValue:0}:{}],['effect','view',read('d')],['flush'],...(!before?[['resolveStream','p','s']]:[]),['microtick'],['read','d'],['tick'],['dispose']]);
for(const immediate of[false,true])for(const loadingValue of[undefined,0,10])for(const method of['awaitUntil','awaitRefresh']){
 const options=loadingValue===undefined?{}:{loadingValue};
 await scenario(`first stream truth/read/reask ${immediate}/${loadingValue}/${method}`,[['future','step',{immediate}],['stream','s',[{future:'step'},{done:true}]],['deferred','d',future('s'),options],['memo','derived',add(read('d'),lit(1))],['flush'],['expect',{isPending:read('d')},false],[method,'answer',...(method==='awaitRefresh'?['d']:[read('derived')])],['microtick'],['resolveStep','step',7],['tick'],['expect',read('d'),7],['expect',{isPending:read('d')},false],['dispose']]);
}
console.log(`${count} first-load deferred stream histories compare iterator calls/results, initial drains, promise gaps, empty/rejected completion, seeds, laziness, cancellation and first-load flattening.`);
