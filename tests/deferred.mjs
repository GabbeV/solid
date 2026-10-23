import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(c,y,n)=>({select:[c,y,n]}),seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
let count=0;
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?deferred-history='+count);
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

for(const lazy of[false,true])for(const value of[undefined,null,false,0,7,NaN,{ref:3}]){
 await scenario('deferred data '+String(value)+'/'+lazy,[['deferred','d',lit(value),{lazy}],['read','d'],['flush'],['read','d'],['dispose']]);
}
for(const immediate of[false,true])for(const seed of[false,true])for(const reject of[false,true]){
 const options=seed?{loadingValue:0}:{};
 await scenario(`first load ${immediate}/${seed}/${reject}`,[['future','p',{immediate}],['deferred','d',future('p'),options],['read','d'],['awaitValue','ordinary',read('d')],['microtick'],[reject?'reject':'resolve','p',reject?99:7],['microtick'],['microtick'],['tick'],['read','d'],['dispose']]);
 await scenario(`refetch ${immediate}/${seed}/${reject}`,[['future','p',{immediate}],['signal','version',0],['deferred','d',select(read('version'),future('p'),lit(7)),options],['program','caught',[['emit',91]]],['effect','view',read('d'),{user:true,error:'caught'}],['flush'],['set','version',1],['flush'],['read','d'],['awaitValue','ordinary',read('d')],['awaitUntil','truth',read('d')],['microtick'],[reject?'reject':'resolve','p',reject?99:21],['microtick'],['microtick'],['tick'],['read','d'],['dispose']]);
}

const pending=body=>({isPending:body}),latest=body=>({latest:body}),normal=read('d');
for(const lazy of[false,true])for(const equals of[false,true])for(const initial of[0,7])for(const next of[0,17]){
 await scenario(`data update ${lazy}/${equals}/${initial}/${next}`,[['signal','x',initial],['deferred','d',read('x'),{lazy,equals}],['effect','view',read('d')],['flush'],['set','x',next],['flush'],['expect',normal,next],['expect',pending(normal),false],['dispose']]);
}
for(const immediate of[false,true])for(const oldReject of[false,true])for(const newReject of[false,true])for(const oldFirst of[false,true]){
 const value=select({same:[read('mode'),lit(1)]},future('p'),select({same:[read('mode'),lit(2)]},future('q'),lit(7)));
 await scenario(`replaced flight ${immediate}/${oldReject}/${newReject}/${oldFirst}`,[['future','p',{immediate}],['future','q',{immediate}],['signal','mode',0],['deferred','d',value],['program','caught',[['emit',91]]],['effect','view',normal,{user:true,error:'caught'}],['flush'],['set','mode',1],['flush'],['expect',normal,7],['expect',pending(normal),true],['set','mode',2],['flush'],['awaitUntil','truth',normal],...(oldFirst?[[oldReject?'reject':'resolve','p',11],['tick'],['expect',normal,7],['expect',pending(normal),true]]:[]),[newReject?'reject':'resolve','q',21],['tick'],...(!oldFirst?[[oldReject?'reject':'resolve','p',11],['tick']]:[]),['read','d'],['dispose']]);
}
for(const immediate of[false,true])for(const lazy of[false,true])for(const rejected of[false,true]){
 await scenario(`same settled thenable re-registration ${immediate}/${lazy}/${rejected}`,[['future','p',{immediate}],['signal','x',0],[rejected?'reject':'resolve','p',17],['deferred','d',seq(read('x'),future('p')),{lazy}],['program','caught',[['emit',91]]],['effect','view',normal,{user:true,error:'caught'}],['flush'],['tick'],['set','x',1],['flush'],['tick'],['set','x',2],['flush'],['tick'],['read','d'],['dispose']]);
}
for(const immediate of[false,true])for(const loadingValue of[undefined,0])for(const target of['d','derived']){
 await scenario(`unready source wrapping ${immediate}/${loadingValue}/${target}`,[['future','p',{immediate}],['signal','mode',0],['memo','input',select(read('mode'),future('p'),lit(7))],['deferred','d',read('input'),{loadingValue}],['memo','derived',add(normal,lit(1))],['effect','view',normal],['flush'],['set','mode',1],['flush'],['expect',normal,7],['expect',pending(read(target)),true],['awaitUntil','truth',read(target)],['awaitValue','ordinary',normal],['microtick'],['resolve','p',21],['tick'],['expect',normal,21],['expect',pending(read(target)),false],['dispose']]);
}
for(const immediate of[false,true])for(const disposeBefore of[false,true]){
 await scenario(`disposal pending flight ${immediate}/${disposeBefore}`,[['future','p',{immediate}],['signal','mode',0],['deferred','d',select(read('mode'),future('p'),lit(7))],['effect','view',normal],['flush'],['set','mode',1],['flush'],...(disposeBefore?[['dispose']]:[]),['resolve','p',21],['tick'],...(!disposeBefore?[['dispose']]:[]),['tick']]);
}
for(const immediate of[false,true])for(const obsoleteFirst of[false,true]){
 await scenario(`never leads held input ${immediate}/${obsoleteFirst}`,[['future','gate',{immediate}],['future','rows',{immediate}],['signal','mode',0],['memo','gate',select(read('mode'),future('gate'),lit(1))],['deferred','d',select(read('mode'),future('rows'),lit(7))],['effect','gate-view',read('gate'),{target:2}],['effect','rows-view',normal,{target:3}],['flush'],['set','mode',1],['flush'],...(obsoleteFirst?[['resolve','rows',21],['tick'],['read','d'],['expect',latest(normal),21],['resolve','gate',2]]:[['resolve','gate',2],['tick'],['resolve','rows',21]]),['tick'],['expect',normal,21],['flush'],['dispose']]);
}
for(const method of['awaitUntil','awaitRefresh'])for(const priorFlight of[false,true]){
 const value=select({same:[read('mode'),lit(2)]},{raise:99},select(read('mode'),future('p'),lit(7)));
 await scenario(`superseded synchronous-error answer ${method}/${priorFlight}`,[['future','p'],['signal','mode',0],['deferred','d',value],...(priorFlight?[['set','mode',1],['flush']]:[]),['set','mode',2],['flush'],[method,'truth',...(method==='awaitRefresh'?['d']:[normal])],['tick'],...(priorFlight?[['resolve','p',21],['tick']]:[]),['read','d'],['dispose']],(op,args,b)=>{if(op==='tick'){assert.equal(list(b.world.deferredArena.lagging).length,0,'a synchronous error ends the obsolete deferred flight');assert.equal(b.portEvents.length,1,'the current error settles truth without the old promise');}});
}
for(const accessor of[false,true])for(const lazy of[false,true]){
 const value=accessor?{invoke:{deferredAccessor:lit(7),options:{lazy}}}:{deferredRead:lit(7),options:{lazy}};
 await scenario(`nested deferred expression ${accessor}/${lazy}`,[['root','nested',value],['flush'],['dispose']]);
}

for(const immediate of[false,true]){
 await scenario(`held landing survives a later lagging reask ${immediate}`,[['future','gate',{immediate}],['future','first',{immediate}],['future','second',{immediate}],['signal','mode',0],['signal','query',0],['memo','gate',select(read('mode'),future('gate'),lit(1))],['deferred','d',seq(read('mode'),select(read('query'),future('second'),select(read('mode'),future('first'),lit(7))))],['effect','gate-view',read('gate'),{target:2}],['effect','rows-view',normal,{target:3}],['flush'],['set','mode',1],['flush'],['resolve','first',21],['tick'],['expect',latest(normal),21],['set','query',1],['flush'],['expect',latest(normal),21],['resolve','gate',2],['tick'],['expect',normal,21],['expect',pending(normal),true],['resolve','second',31],['tick'],['expect',normal,31],['dispose']]);
 await scenario(`value and verdict publish together ${immediate}`,[['future','p',{immediate}],['signal','mode',0],['deferred','d',select(read('mode'),future('p'),lit(7))],['memo','pending',pending(normal)],['effect','pending-view',read('pending'),{target:3}],['effect','value-view',normal,{target:2}],['flush'],['set','mode',1],['flush'],['awaitUntil','truth',normal],['resolve','p',21],['microtick'],['microtick'],['tick'],['expect',normal,21],['expect',pending(normal),false],['dispose']]);
 await scenario(`quiet refresh keeps verdict quiet ${immediate}`,[['future','p',{immediate}],['deferred','d',future('p')],['effect','value-view',normal],['resolve','p',7],['tick'],['awaitRefresh','refresh','d'],['expect',pending(normal),false],['microtick'],['microtick'],['tick'],['expect',normal,7],['dispose']]);
}

for(const initial of[0,1,11,2**40])for(const next of[0,17]){
 const program={signalScope:{initial:lit(initial),body:seq({call:'keep',args:[{deferredAccessor:{localRead:0},options:{equals:false}}]},{localWrite:{value:lit(next)}},{flushNow:true},{invoke:read('saved')})}};
 await scenario(`setter inside owning root ${initial}/${next}`,[['signal','saved',undefined],['program','keep',[['updateExpr','saved',{argument:0}]]],['root','owned',program],['expect',{invoke:read('saved')},next],['flush'],['dispose']]);
}
for(const result of[true,false,undefined,null,0,7,'',{ref:8}])for(const immediate of[false,true]){
 await scenario(`deferred custom comparator ${String(result)}/${immediate}`,[['signal','x',0],['program','cmp',[['emit',31],['return',lit(result)]]],['future','p',{immediate}],['deferred','d',select(read('x'),future('p'),lit(7)),{equals:{callback:'cmp'}}],['effect','value-view',normal],['set','x',1],['flush'],['resolve','p',21],['tick'],['read','d'],['dispose']]);
}
for(const value of[-0,true,'answer',undefined,null,false,0,NaN,{ref:3}])for(const owner of['root',null]){
 await scenario(`data payload and ownership ${String(value)}/${owner}`,[['deferred','d',lit(value),{owner}],['read','d'],['flush'],['read','d'],['dispose']]);
}
for(const kind of['callback','accessor']){
 const fn=kind==='callback'?{callback:'value'}:{accessor:'source'};
 await scenario(`function-valued deferred answer ${kind}`,[['signal','source',11],['program','value',[['return',lit(17)]]],['deferred','d',lit(fn)],['flush'],['read','d'],['evaluate',{invoke:normal}],['dispose']]);
}

for(const accessor of[false,true]){
 const value=accessor?{deferredAccessor:add({argument:0},read('x'))}:{deferredRead:add({argument:0},read('x'))};
 await scenario(`callback argument capture ${accessor}`,[['signal','x',1],['signal','saved',undefined],['program','make',[['return',value]]],['program','keep',[['updateExpr','saved',{argument:0}]]],['root','owned',accessor?{call:'keep',args:[{call:'make',args:[lit(11)]}]}:{call:'make',args:[lit(11)]}],['set','x',2],['flush'],...(accessor?[['expect',{invoke:read('saved')},13]]:[]),['dispose']]);
 const actionValue=accessor?{deferredAccessor:add({actionArgument:0},read('x'))}:{deferredRead:add({actionArgument:0},read('x'))};
 const action={actionCreate:{steps:[{next:{iteratorResult:{value:actionValue,done:true}}}]}};
 await scenario(`action argument capture ${accessor}`,[['signal','x',1],['signal','saved',undefined],['program','keep',[['updateExpr','saved',{argument:0}]]],['root','owned',{call:'keep',args:[action]}],['flush'],['runAction','result',{steps:[{next:{iteratorResult:{value:{invokeArgs:{callee:read('saved'),args:[lit(11)]}},done:true}}}]}],['tick'],['tick'],['set','x',2],['flush'],['dispose']]);
}
for(const lazy of[false,true])await scenario(`unused accessor respects laziness ${lazy}`,[['root','owned',{deferredAccessor:lit(7),options:{lazy}}],['flush'],['dispose']]);
for(const immediate of[false,true])for(const seeded of[false,true])await scenario(`unready source before first answer ${immediate}/${seeded}`,[['future','p',{immediate}],['memo','input',future('p')],['deferred','d',read('input'),seeded?{loadingValue:0}:{}],['read','d'],['resolve','p',7],['tick'],['expect',normal,7],['dispose']]);
for(const value of[0,7])for(const seeded of[false,true])await scenario(`previous argument before and after updates ${value}/${seeded}`,[['signal','x',value],['deferred','d',select({same:[{prev:true},lit(undefined)]},read('x'),add({prev:true},read('x'))),seeded?{loadingValue:0}:{}],['read','d'],['set','x',3],['flush'],['read','d'],['dispose']]);
for(const immediate of[false,true]){
 await scenario(`landing derived from a held input ${immediate}`,[['future','a',{immediate}],['future','b',{immediate}],['future','rows',{immediate}],['signal','mode',0],['signal','query',0],['memo','a',select(read('mode'),future('a'),lit(1))],['memo','b',select(read('mode'),future('b'),lit(2))],['deferred','d',seq(read('a'),select(read('query'),future('rows'),lit(7)))],['effect','a-view',read('a'),{target:2}],['effect','b-view',read('b'),{target:3}],['effect','d-view',normal,{target:4}],['flush'],['set','mode',1],['flush'],['resolve','a',11],['tick'],['set','query',1],['flush'],['resolve','rows',21],['tick'],['read','d'],['resolve','b',12],['tick'],['read','d'],['dispose']]);
}
for(const accessor of[false,true])await scenario(`lexical deferred capture ${accessor}`,[['root','owned',{signalScope:{initial:lit(11),body:accessor?{deferredAccessor:{localRead:0}}:{deferredRead:{localRead:0}}}}],['flush'],['dispose']]);
console.log(`${count} deferred data/thenable histories match public construction, state, complete traces, cleanup and promise-observer order.`);
