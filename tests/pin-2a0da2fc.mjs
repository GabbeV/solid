import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?pin-2a0da2fc='+count);
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
      let opResult;
      if(op==='expect'){const a=b.attempt('evaluate',args[0]),n=s.attempt('evaluate',args[0]);assert.deepEqual(a,['return',args[1]],name+' expected value');assert.deepEqual(n,a);}
      else if(op==='tick')await setImmediate();
      else if(op==='microtick')await Promise.resolve();
      else {
        const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
        if(actual[0]==='return'&&expected[0]==='return'&&!['read','set','update','screen','future','evaluate'].includes(op))actual[1]=expected[1]=undefined;
        assert.deepEqual(actual,expected,`${name}: ${op} result`);opResult=actual;
      }
      compare(op);verify?.(op,args,opResult,b,s);
      const extensions=list(b.world.extensions);for(const [label,get]of Object.entries(s.accessors)){const native=Object.getOwnPropertySymbols(get).map(k=>get[k]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v),node=b.nodes()[b.ids[label]];if(native&&node)assert.equal(extensions[node.x]?.marks??0,native._x?._marks??0,name+' marks on '+label);}
    }
    count++;
  }catch(e){consoleError('FAILED: '+name);throw e;}
  finally{b.attempt('dispose');s.attempt('dispose');b.resetErrorHalt();s.resetErrorHalt();b.attempt('flush');s.attempt('flush');await setImmediate();console.error=consoleError;}
}

// #4250: an initial error records absence of a usable value. A real
// successful undefined and an explicit loading seed remain usable values.
for(const initial of ['never','number','undefined'])for(const asyncError of [false,true])for(const seeded of [false,true])for(const user of [false,true]){
 const bad=asyncError?future('bad'):{raise:99};
 const first=initial==='never'?bad:lit(initial==='number'?7:undefined);
 const compute=select({same:[read('phase'),lit(2)]},future('next'),select(read('phase'),bad,first));
 await scenario(`first rejection re-ask ${initial}/${asyncError}/${seeded}/${user}`,[
  ['future','bad'],['future','next'],['signal','phase',0],['program','caught',[['emit',91]]],
  ['memo','d',compute,seeded?{loadingValue:3}:{}],...(user?[['effect','view',read('d'),{user:true,error:'caught'}]]:[]),['flush'],
  ...(initial!=='never'?[['expect',read('d'),initial==='number'?7:undefined],['set','phase',1],['flush']]:[]),
  ...(asyncError?[['reject','bad',99],['tick']]:[]),['read','d'],
  ['set','phase',2],['flush'],['evaluate',{isPending:read('d')}],['evaluate',{latest:read('d')}],
  ['resolve','next',13],['tick'],['flush'],['expect',read('d'),13],['expect',{isPending:read('d')},false],['dispose']
 ],(op,args,result,b)=>{
  if(op==='evaluate'&&args[0]?.latest){
   if(initial==='never'&&!seeded)assert.ok(result[0]==='throw'&&result[1]?.notReady,'an unseeded never-valued re-ask cannot fabricate undefined');
   else assert.ok(!(result[0]==='throw'&&result[1]?.notReady),'a genuine prior value or loading seed is not uninitialized');
  }
 });
}
console.log(`${count} merged first-error re-ask histories distinguish no value from successful undefined, loading seeds, sync/async errors, plain/user observers, latest/pending and final recovery.`);
