import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument});
const seq=(...seq)=>({seq}),add=(a,b)=>({add:[a,b]});
const get={localRead:0},getter={localAccessor:0},setter={localSetter:0};
const write=(value,updater=false)=>({localWrite:{value,updater}});
const invoke=(callee,value=lit(undefined),updater=false)=>({invokeWith:{callee,value,updater}});
const scope=(initial,body,options={})=>({optimisticScope:{initial,body,options}});
const computed=(compute,body,options={})=>({optimisticComputeScope:{compute,body,options}});
const capture=[['signal','saved',undefined],['signal','setSaved',undefined],['program','save',[['updateExpr','saved',arg(0)],['updateExpr','setSaved',arg(1)]]]];
const save={call:'save',args:[getter,setter]},getSaved={invoke:read('saved')};
const putSaved=(value,updater=false)=>invoke(read('setSaved'),value,updater);
let count=0;
async function scenario(name,commands,verify){
 const module=await import('../build/solid.mjs?optimistic='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
 const original=console.error;console.error=(...args)=>logs.push(args);
 try{
  for(const[op,...args]of commands){
   if(process.env.DEBUG_OPTIMISTIC)original(name,op);
   if(op==='tick')await setImmediate();else{
    const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
    if(actual[0]==='return'&&wanted[0]==='return'&&!['read','set','update','evaluate','runAction'].includes(op))actual[1]=wanted[1]=undefined;
    assert.deepEqual(actual,wanted,`${name}: ${op} result`);verify?.(op,args,actual,b,s);
   }
   if(op==='flush'&&b.ids.setSaved&&s.accessors.setSaved){
    const native=s.accessors.setSaved();
    if(typeof native==='function'){
      const n=b.nodes()[b.ids.setSaved],raw='value'in n.pending?n.pending.value:n.value,actual=b.decode(raw);
      assert.equal(actual.length,1,`${name}: bound setter arity`);assert.equal(native.length,1,`${name}: source bound setter arity`);
      assert.equal(actual,b.decode(raw),`${name}: repeated codec identity`);
    }
   }
   const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: nodes after ${op}`);
   for(const[local,{get:getter}]of s.localSignals??[]){
    const node=Object.getOwnPropertySymbols(getter).map(k=>getter[k]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v),n=b.nodes()[b.ids[local]];
    assert.equal(n.config,node._config,`${name}: signal config`);assert.equal(n.time,node._time,`${name}: signal time`);
    assert.deepEqual(b.errorShape(b.decode(n.value)),s.errorShape(node._value),`${name}: committed`);
    assert.equal('value'in n.pending,node._pendingValue!==s.localNotPending,`${name}: pending presence`);
    if('value'in n.pending)assert.deepEqual(b.errorShape(b.decode(n.pending.value)),s.errorShape(node._pendingValue),`${name}: pending`);
   }
   assert.deepEqual(b.trace(),s.trace(),`${name}: traces after ${op}`);
   assert.deepEqual(b.portEvents,s.portEvents,`${name}: action promises after ${op}`);
   assert.deepEqual(b.portSnapshots,s.portSnapshots,`${name}: action screens after ${op}`);
   assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: escaping errors after ${op}`);
   for(const target of[2,3])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
   assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],`${name}: ambient`);
   const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
   assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports`);
  }
  count++;
 }catch(e){original('FAILED: '+name);throw e;}finally{b.attempt('dispose');s.attempt('dispose');b.resetErrorHalt();s.resetErrorHalt();b.attempt('flush');s.attempt('flush');await setImmediate();console.error=original;}
}
for(const value of[undefined,null,false,true,0,7,-0,NaN,'draft',{ref:3}])for(const equals of[false,true]){
 await scenario('data constructor '+JSON.stringify({value,equals}),[...capture,['root','scope',scope(lit(value),save,{equals})],['flush'],['evaluate',getSaved],['evaluate',putSaved(lit(value))],['evaluate',putSaved(lit(9))],['flush'],['evaluate',getSaved],['dispose']],(op,args,res)=>{if(op==='evaluate'&&args[0]===getSaved)assert.deepEqual(res,['return',value]);});
}
for(const lazy of[false,true])for(const equals of[false,true]){
 await scenario('computed optimistic keeps original derivation '+JSON.stringify({lazy,equals}),[
  ['signal','input',1],...capture,['root','scope',computed(add(read('input'),lit(2)),save,{lazy,equals})],['effect','view',getSaved],['flush'],['evaluate',putSaved(lit(11))],['flush'],['set','input',4],['flush'],['set','input',7],['flush'],['evaluate',getSaved],['dispose']
 ]);
 await scenario('composed pending guesses '+JSON.stringify({lazy,equals}),[...capture,['root','scope',computed(lit(1),save,{lazy,equals})],['effect','view',getSaved],['flush'],['evaluate',seq(putSaved(add({prev:true},lit(2)),true),putSaved(add({prev:true},lit(3)),true))],['flush'],['evaluate',getSaved],['dispose']]);
}
for(const compute of[false,true]){
 const make=compute?computed:scope;
 await scenario('lexical captured setter '+compute,[['root','scope',make(lit(1),seq(write(lit(4)),write(add({prev:true},lit(3)),true),get))],['flush'],['dispose']]);
 await scenario('setter identity and length '+compute,[...capture,['root','scope',make(lit(1),seq(save,{same:[setter,setter]}))],['flush'],['evaluate',{same:[read('setSaved'),read('setSaved')]}],['evaluate',putSaved(lit(9))],['flush'],['dispose']]);
 await scenario('raw updater error '+compute,[...capture,['root','scope',make(lit(1),save)],['flush'],['evaluate',putSaved({raise:undefined},true)],['evaluate',putSaved(lit(4))],['flush'],['dispose']]);
 await scenario('callable setter used as initializer '+compute,[...capture,['root','scope',make(lit(1),save)],['flush'],['root','other',scope(read('setSaved'),get)],['flush'],['dispose']]);
 await scenario('optimistic setter as onCleanup '+compute,[...capture,['root','scope',make(lit(1),seq(save,{onCleanup:setter}))],['flush'],['disposeOwner','scope'],['flush'],['dispose']]);
}
for(const lazy of[false,true])for(const rejected of[false,true]){
 await scenario('held computed guess and landing '+JSON.stringify({lazy,rejected}),[
  ['future','request'],['signal','version',0],...capture,['root','scope',computed({select:[read('version'),{future:'request'},lit(1)]},save,{lazy})],['effect','view',getSaved],['flush'],['set','version',1],['flush'],['evaluate',putSaved(lit(9))],['flush'],['evaluate',getSaved],[rejected?'reject':'resolve','request',7],['tick'],['flush'],['evaluate',getSaved],['dispose']
 ]);
}

const result=(value=lit(undefined),done=false)=>({iteratorResult:{value,done}});
const method=next=>({next});
for(const compute of[false,true])for(const immediate of[false,true])for(const rejected of[false,true]){
 const make=compute?computed:scope;
 await scenario('action guess display and truth '+JSON.stringify({compute,immediate,rejected}),[
  ...capture,['root','scope',make(lit(1),save)],['effect','view',getSaved],['flush'],['signal','server',0],['future','request',{immediate}],
  ['runAction','saveAction',{steps:[method(seq({invokeWith:{callee:lit({setter:'server'}),value:lit(2)}},putSaved(lit(9)),result({future:'request'}))),{next:seq(putSaved(arg(0)),result(lit('saved'),true)),throw:seq(putSaved(lit(4)),result(lit('caught'),true))}]}],
  ['flush'],['evaluate',getSaved],[rejected?'reject':'resolve','request',7],['tick'],['flush'],['evaluate',getSaved],['dispose']
 ]);
}
for(const compute of[false,true]){
 const make=compute?computed:scope;
 await scenario('escaped setter after owner disposal '+compute,[['signal','input',1],...capture,['root','scope',make(read('input'),save)],['flush'],['disposeOwner','scope'],['evaluate',putSaved(lit(9))],['flush'],['evaluate',getSaved],['dispose']]);
 await scenario('all arguments evaluate before optimistic write '+compute,[...capture,['signal','side',0],['root','scope',make(lit(1),save)],['flush'],['evaluate',{invokeArgs:{callee:read('setSaved'),args:[lit(9),{invokeWith:{callee:lit({setter:'side'}),value:lit(3)}},lit(4),lit(5)]}}],['flush'],['read','side'],['evaluate',getSaved],['dispose']]);
 await scenario('nested ordinary and optimistic binding '+compute,[...capture,['root','scope',make(lit(1),{signalScope:{initial:lit(4),body:seq({call:'save',args:[{localAccessor:1},{localSetter:1}]},write(lit(6)),{localWrite:{depth:1,value:lit(9)}},{localRead:1})}})],['flush'],['evaluate',putSaved(lit(7))],['flush'],['evaluate',getSaved],['dispose']]);
}
for(const fail of[false,true])for(const compute of[false,true]){
 const make=compute?computed:scope;
 await scenario('raw optimistic comparator '+JSON.stringify({fail,compute}),[['program','compare',[[fail?'throwExpr':'return',fail?lit(9):lit(false)]]],...capture,['root','scope',make(lit(1),save,{equals:'compare'})],['flush'],['evaluate',putSaved(lit(9))],['evaluate',getSaved],['flush'],['dispose']]);
}

for(const compute of[false,true]){
 const make=compute?computed:scope;
 await scenario('optimistic nested under ordinary binding '+compute,[...capture,['root','scope',{signalScope:{initial:lit(4),body:make(lit(1),seq(save,{localWrite:{depth:1,value:lit(8)}},write(lit(9)),{localRead:1}))}}],['flush'],['evaluate',putSaved(lit(6))],['flush'],['evaluate',getSaved],['dispose']]);
 await scenario('cleanup invokes optimistic comparator '+compute,[['signal','calls',0],['program','compare',[['updateExpr','calls',add({prev:true},lit(1))],['return',lit(false)]]],...capture,['root','scope',make(lit(1),seq(save,{onCleanup:setter}),{equals:'compare'})],['flush'],['disposeOwner','scope'],['flush'],['read','calls'],['dispose']]);
}
console.log(`${count} public optimistic histories compare real constructors, bound setters, guess composition, original derivations, cleanup and held landings with pinned Solid.`);
