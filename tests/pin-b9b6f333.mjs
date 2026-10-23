import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?b9-sync-error='+count);
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

const pending=body=>({isPending:body}),normal=read('d');
for(const immediate of[false,true])for(const seeded of[false,true])for(const method of['awaitUntil','awaitRefresh'])for(const old of['absent','unresolved','resolve','reject']){
 const prior=old!=='absent';
 const value=select({same:[read('step'),lit(2)]},{raise:99},select(read('step'),future('old'),lit(7)));
 await scenario(`merged synchronous-error flight release ${immediate}/${seeded}/${method}/${old}`,[
  ['future','old',{immediate}],['signal','step',0],['program','caught',[['emit',91]]],
  ['deferred','d',value,seeded?{loadingValue:0}:{}],['effect','view',normal,{user:true,error:'caught'}],['flush'],
  ['expect',normal,7],...(prior?[['set','step',1],['flush'],['expect',pending(normal),true]]:[]),
  ['set','step',2],['flush'],['expect',pending(normal),false],
  [method,'truth',...(method==='awaitRefresh'?['d']:[normal])],['tick'],
  ...(['resolve','reject'].includes(old)?[[old,'old',21],['tick']]:[]),
  ['read','d'],['set','step',0],['flush'],['expect',normal,7],['expect',pending(normal),false],['dispose']
 ],(op,args,b)=>{
  if(op==='tick'){
   assert.deepEqual(b.portEvents,[['reject','truth',99]],'the current error settles without the obsolete flight');
   assert.deepEqual(list(b.world.deferredArena.lagging),[],'no deferred lag membership survives the error');
   const node=b.nodes()[b.ids.d],extension=list(b.world.extensions)[node.x];
   assert.equal(extension?.marks??0,0,'the old deferred mark is released');
  }
 });
}
console.log(`${count} merged deferred synchronous-error histories cover seeds, current error identity, immediate/native obsolete flights, until/refresh, stale success/rejection, application error handling and later recovery.`);
