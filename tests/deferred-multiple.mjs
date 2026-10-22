import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?deferred-multiple='+count);
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

const a=read('a'),b=read('b'),pair=add(a,b),pending=value=>({isPending:value});
for(const immediate of[false,true])for(const lazyA of[false,true])for(const lazyB of[false,true])for(const reverse of[false,true])for(const disposed of[false,true]){
 const first=reverse?'b':'a',second=reverse?'a':'b',firstValue=reverse?21:11,secondValue=reverse?11:21;
 const commands=[['future','pa',{immediate}],['future','pb',{immediate}],['signal','xa',0],['signal','xb',0],['deferred','a',select(read('xa'),future('pa'),lit(10)),{lazy:lazyA}],['deferred','b',select(read('xb'),future('pb'),lit(20)),{lazy:lazyB}],['effect','view-a',a,{target:2}],['effect','view-b',b,{target:3}],['flush'],['set','xa',1],['flush'],['set','xb',1],['flush'],['expect',pending(a),true],['expect',pending(b),true],['awaitUntil','a-answer',a],['awaitUntil','b-answer',b],['awaitUntil','pair-answer',pair],['microtick'],...(disposed?[['dispose']]:[]),['resolve',reverse?'pb':'pa',firstValue],['tick'],...(!disposed?[['expect',read(first),firstValue],['expect',pending(read(first)),false],['expect',pending(read(second)),true]]:[]),['resolve',reverse?'pa':'pb',secondValue],['tick'],...(!disposed?[['expect',pair,32],['expect',pending(pair),false],['dispose']]:[])];
 await scenario(`two deferred values ${immediate}/${lazyA}/${lazyB}/${reverse}/${disposed}`,commands,(op,args,br)=>{if(op==='tick'&&!disposed&&br.portEvents.some(e=>e[1]==='pair-answer'))assert.deepEqual(br.portEvents.find(e=>e[1]==='pair-answer'),['resolve','pair-answer',32]);});
}
console.log(`${count} multiple-deferred histories retain the shared lagging Set, independent flight/callback identities, truth waiters, both landing orders and disposal.`);
