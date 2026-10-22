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
 const module=await import('../build/solid.mjs?verdict='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
 const original=console.error;console.error=(...args)=>logs.push(args);
 try{
  for(const[op,...args]of commands){
   if(process.env.DEBUG_VERDICT)original(name,op);
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
   assert.deepEqual([b.world.verdictState.latestActive,b.world.verdictState.probing,b.world.verdictState.probeFound,b.world.verdictState.dispatch],[false,false,false,false],`${name}: window restoration`);
   const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
   assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports`);
  }
  count++;
 }catch(e){original('FAILED: '+name);throw e;}finally{b.attempt('dispose');s.attempt('dispose');b.resetErrorHalt();s.resetErrorHalt();b.attempt('flush');s.attempt('flush');await setImmediate();console.error=original;}
}

const latest=latest=>({latest}),pending=isPending=>({isPending});
for(const value of[undefined,null,false,true,0,7,-0,NaN,'screen',{ref:2}]){
 await scenario('plain windows '+JSON.stringify(value),[['signal','x',value],['evaluate',latest(read('x'))],['evaluate',pending(read('x'))],['set','x',9],['evaluate',latest(read('x'))],['evaluate',pending(read('x'))],['flush'],['evaluate',latest(read('x'))],['evaluate',pending(read('x'))],['dispose']]);
}
for(const window of[latest,pending])for(const nested of[latest,pending])for(const value of[1,undefined,false]){
 await scenario('nested windows '+window.name+'/'+nested.name+'/'+value,[['signal','x',value],['evaluate',window(nested(read('x')))],['evaluate',window(seq(nested({raise:7}),read('x')))],['evaluate',read('x')],['dispose']]);
}
for(const value of[undefined,7,{ref:3}])for(const window of[latest,pending]){
 await scenario('ordinary user error '+window.name+'/'+JSON.stringify(value),[['evaluate',window({raise:value})],['signal','x',1],['evaluate',read('x')],['dispose']]);
}
for(const lazy of[false,true])for(const reject of[false,true])for(const seed of[false,true]){
 const opts={lazy,...(seed?{loadingValue:0}:{})};
 await scenario('loading windows '+JSON.stringify({lazy,reject,seed}),[['future','request'],['memo','result',{future:'request'},opts],['evaluate',pending(read('result'))],['evaluate',latest(read('result'))],['root','probe',pending(read('result'))],['flush'],[reject?'reject':'resolve','request',7],['tick'],['flush'],['evaluate',pending(read('result'))],['evaluate',latest(read('result'))],['dispose']]);
}
for(const lazy of[false,true])for(const reject of[false,true])for(const window of[latest,pending])for(const untracked of[false,true]){
 const body=untracked?{untrack:read('result')}:read('result');
 await scenario('tracked flight verdict '+JSON.stringify({lazy,reject,window:window.name,untracked}),[['future','request'],['signal','version',0],['memo','result',{select:[read('version'),{future:'request'},lit(1)]},{lazy}],['effect','view',window(body)],['flush'],['set','version',1],['flush'],['evaluate',pending(read('result'))],['evaluate',latest(read('result'))],[reject?'reject':'resolve','request',7],['tick'],['flush'],['dispose']]);
}
for(const lazy of[false,true])for(const reject of[false,true])for(const window of[latest,pending]){
 await scenario('optimistic flight verdict '+JSON.stringify({lazy,reject,window:window.name}),[['future','request'],['signal','version',0],...capture,['root','scope',computed({select:[read('version'),{future:'request'},lit(1)]},save,{lazy})],['flush'],['effect','view',window(getSaved)],['flush'],['set','version',1],['flush'],['evaluate',putSaved(lit(9))],['flush'],['evaluate',latest(getSaved)],['evaluate',pending(getSaved)],[reject?'reject':'resolve','request',7],['tick'],['flush'],['evaluate',latest(getSaved)],['evaluate',pending(getSaved)],['dispose']]);
}

for(const lazy of[false,true])for(const window of[latest,pending])for(const branchWindow of[false,true]){
 await scenario('window pulls a nested derivation '+JSON.stringify({lazy,window:window.name,branchWindow}),[['future','request'],['signal','version',0],['memo','result',{select:[read('version'),{future:'request'},lit(1)]}],['memo','branch',add(branchWindow?latest(read('result')):read('result'),lit(2)),{lazy}],['memo','answer',window(read('branch'))],['effect','view',read('answer')],['flush'],['set','version',1],['flush'],['resolve','request',7],['tick'],['flush'],['dispose']]);
}
for(const window of[latest,pending])for(const hold of[false,true])for(const lazy of[false,true]){
 await scenario('window reader born after unflushed write '+JSON.stringify({window:window.name,hold,lazy}),[['future','request'],['signal','x',1],['signal','version',0],['memo','result',{select:[read('version'),{future:'request'},lit(1)]}],['effect','old',read('result'),{target:3}],['flush'],['set','x',2],...(hold?[['set','version',1]]:[]),['memo','answer',window(read('x')),{lazy}],['effect','view',read('answer')],['flush'],['resolve','request',7],['tick'],['flush'],['dispose']]);
}
for(const window of[latest,pending])for(const transparent of[false,true]){
 await scenario('window in a root forwards to its reader '+JSON.stringify({window:window.name,transparent}),[['future','request'],['signal','version',0],['memo','result',{select:[read('version'),{future:'request'},lit(1)]}],['memo','answer',{root:window(read('result')),transparent}],['effect','view',read('answer')],['flush'],['set','version',1],['flush'],['resolve','request',7],['tick'],['flush'],['dispose']]);
}
for(const foundFirst of[false,true])for(const owned of[false,true])for(const nested of[false,true]){
 const body=pending(seq(...(foundFirst?[read('result')]:[]),...(nested?[pending({raise:9})]:[]),read('loading')));
 await scenario('probe loading catch retains outer found '+JSON.stringify({foundFirst,owned,nested}),[['future','request'],['future','never'],['signal','version',0],['memo','result',{select:[read('version'),{future:'request'},lit(1)]}],['memo','loading',{future:'never'}],['effect','view',read('result')],['flush'],['set','version',1],['flush'],[owned?'root':'evaluate',...(owned?['scope',body]:[body])],['evaluate',lit(3)],['resolve','request',7],['tick'],['flush'],['dispose']]);
}
for(const window of[latest,pending])for(const thunk of[false,true]){
 await scenario('window body captures callback and local arguments '+JSON.stringify({window:window.name,thunk}),[['signal','x',1],['program','probe',[['return',window(thunk?{invoke:arg(0)}:arg(0))]]],['root','scope',scope(lit(4),{call:'probe',args:[thunk?getter:get]})],['flush'],['set','x',2],['flush'],['dispose']]);
}
const result=(value=lit(undefined),done=false)=>({iteratorResult:{value,done}}),method=next=>({next});
const put=(name,value)=>({invokeWith:{callee:lit({setter:name}),value}});
for(const window of[latest,pending])for(const reverse of[false,true])for(const rewrite of[false,true]){
 const first=reverse?'b':'a',second=reverse?'a':'b';
 await scenario('imperative verdict read of another action '+JSON.stringify({window:window.name,reverse,rewrite}),[['signal','x',1],['signal','y',0],['effect','view',read('x')],['effect','other',read('y'),{target:3}],['flush'],['future','a'],['future','b'],['runAction','one',{steps:[method(seq(put('x',lit(2)),result({future:'a'}))),method(result(lit('one'),true))]}],['flush'],...(rewrite?[['set','x',3]]:[]),['runAction','two',{steps:[method(seq(put('y',window(read('x'))),result({future:'b'}))),method(result(lit('two'),true))]}],['flush'],['resolve',first,7],['tick'],['flush'],['resolve',second,9],['tick'],['flush'],['dispose']]);
}

for(const lazy of[false,true])for(const window of[latest,pending]){
 await scenario('untracked loading read still wakes its owner '+JSON.stringify({lazy,window:window.name}),[['future','request'],['memo','result',{future:'request'},{lazy}],['memo','answer',window({untrack:read('result')})],['effect','view',read('answer')],['flush'],['resolve','request',7],['tick'],['flush'],['dispose']]);
}
console.log(`${count} public verdict-window histories compare actual latest/isPending reads, pulls, throws, nested restoration, loading/held states and optimistic lanes with pinned Solid.`);
