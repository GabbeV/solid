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
 const module=await import('../build/solid.mjs?affects='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
 const original=console.error;console.error=(...args)=>logs.push(args);
 try{
  for(const[op,...args]of commands){
   if(process.env.DEBUG_AFFECTS)original(name,op);
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
   const getters=[...Object.values(s.accessors),...[...(s.localSignals??[])].map(([,v])=>v.get),...[...(s.localComputedSignals??[])].map(([,v])=>v.get)],known=new Map();
   for(const get of getters)if(typeof get==='function'){
    const n=Object.getOwnPropertySymbols(get).map(k=>get[k]).find(n=>n&&typeof n==='object'&&'_pendingValue'in n);
    if(n)known.set(n,s.accessorIdentities.get(get));
   }
   let active=0;
   for(const[n,label]of known){const marks=n._x?._marks??0;active+=marks;const bn=b.nodes()[b.ids[label]];if(bn)assert.equal(list(b.world.extensions)[bn.x]?.marks??0,marks,`${name}: ${label} marks after ${op}`);}
   assert.equal(b.world.activeMarks,active,`${name}: total mark count after ${op}`);
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
const affect=target=>({affects:{target}}),mark=name=>affect(lit({accessor:name})),put=(name,value)=>({invokeWith:{callee:lit({setter:name}),value}});
const setup=[['signal','x',1],['memo','twice',{mul:[read('x'),lit(2)]}],['memo','busy',pending(read('twice'))],['effect','view',read('busy')],['effect','data',read('twice'),{target:3}],['flush']];
for(const duplicates of[1,2,3])for(const target of['x','twice']){
 await scenario('ambient declaration '+JSON.stringify({duplicates,target}),[...setup,...Array.from({length:duplicates},()=>['evaluate',mark(target)]),['evaluate',pending(read('x'))],['evaluate',latest(read('twice'))],['flush'],['read','busy'],['dispose']]);
}
for(const target of[undefined,null,false,0,NaN,'invalid',{ref:3},{setter:'x'},{callback:'unused'}]){
 await scenario('invalid target still evaluates its key '+JSON.stringify(target),[...setup,['signal','side',0],['program','unused',[['return',lit(1)]]],['evaluate',{affects:{target:lit(target),key:put('side',lit(3))}}],['flush'],['read','side'],['dispose']]);
}
const result=(value=lit(undefined),done=false)=>({iteratorResult:{value,done}}),method=next=>({next});
for(const rejected of[false,true])for(const duplicate of[false,true]){
 await scenario('action scoped declaration '+JSON.stringify({rejected,duplicate}),[...setup,['future','request'],['runAction','reload',{steps:[method(seq(mark('x'),...(duplicate?[mark('x')]:[]),result({future:'request'}))),{next:result(lit('done'),true),throw:result(lit('failed'),true)}]}],['flush'],['read','busy'],[rejected?'reject':'resolve','request',7],['tick'],['flush'],['read','busy'],['dispose']]);
}
for(const marked of[false,true])for(const viaAction of[false,true]){
 const commands=[['future','first'],['future','second'],['memo','result',{select:[{prev:true},{future:'second'},{future:'first'}]}],['memo','busy',pending(read('result'))],['effect','view',read('busy')],['effect','data',latest(read('result')),{target:3}],['resolve','first',1],['tick'],['flush']];
 const body=seq(...(marked?[mark('result')]:[]),result({future:'second'}));
 await scenario('declared quiet reload '+JSON.stringify({marked,viaAction}),[...commands,...(viaAction?[['runAction','reload',{steps:[method(body),method(result(lit('done'),true))]}],['refresh','result']]:[...(marked?[['evaluate',mark('result')]]:[]),['refresh','result']]),['flush'],['read','busy'],['resolve','second',2],['tick'],['flush'],['read','busy'],['dispose']]);
}
for(const reverse of[false,true])for(const merge of[false,true]){
 const first=reverse?'b':'a',second=reverse?'a':'b',plan=request=>({steps:[method(seq(mark('x'),...(merge?[put('x',lit(2))]:[]),result({future:request}))),method(result(lit('done'),true))]});
 await scenario('overlapping declaration scopes '+JSON.stringify({reverse,merge}),[...setup,['future','a'],['future','b'],['runAction','one',plan('a')],['flush'],['runAction','two',plan('b')],['flush'],['read','busy'],['resolve',first,7],['tick'],['flush'],['read','busy'],['resolve',second,9],['tick'],['flush'],['read','busy'],['dispose']]);
}
for(const compute of[false,true]){
 const make=compute?computed:scope;
 await scenario('lexical target and callback binding '+compute,[['program','declare',[['return',affect(arg(0))]]],['root','scope',make(lit(1),{call:'declare',args:[getter]})],['flush'],['dispose']]);
}

for(const duplicate of[false,true]){
 await scenario('ambient declaration parks with unrelated async frame '+duplicate,[...setup,['signal','trigger',0],['future','request'],['memo','slow',{select:[read('trigger'),{future:'request'},lit(1)]}],['effect','wait',read('slow'),{target:4}],['flush'],['evaluate',mark('x')],...(duplicate?[['evaluate',mark('x')]]:[]),['set','trigger',1],['flush'],['read','busy'],['resolve','request',7],['tick'],['flush'],['read','busy'],['dispose']]);
}
for(const marked of[false,true]){
 await scenario('unobserved own flight keeps ambient declaration '+marked,[['future','first'],['future','second'],['program','fetch',[['return',{select:[arg(0),{future:'second'},{future:'first'}]}]]],['signal','result',{callback:'fetch'}],['resolve','first',1],['tick'],['flush'],...(marked?[['evaluate',mark('result')]]:[]),['refresh','result'],['flush'],['evaluate',pending(read('result'))],['resolve','second',2],['tick'],['flush'],['evaluate',pending(read('result'))],['dispose']]);
}
for(const fail of[false,true]){
 await scenario('target and key finish before registration '+fail,[...setup,['signal','side',0],['evaluate',{affects:{target:seq(put('side',lit(2)),lit({accessor:'x'})),key:fail?{raise:9}:put('side',lit(3))}}],['flush'],['read','side'],['dispose']]);
}
for(const rejected of[false,true]){
 await scenario('declaration in resumed action slice '+rejected,[...setup,['future','firstWait'],['future','secondWait'],['runAction','reload',{steps:[method(result({future:'firstWait'})),method(seq(mark('x'),result({future:'secondWait'}))),{next:result(lit('done'),true),throw:result(lit('failed'),true)}]}],['flush'],['resolve','firstWait',1],['tick'],['flush'],['read','busy'],[rejected?'reject':'resolve','secondWait',2],['tick'],['flush'],['read','busy'],['dispose']]);
}
for(const reverse of[false,true])for(const duplicate of[false,true]){
 const names=reverse?['result','x']:['x','result'];
 await scenario('ambient compaction retains live flight '+JSON.stringify({reverse,duplicate}),[['signal','x',7],['future','first'],['future','second'],['program','fetch',[['return',{select:[arg(0),{future:'second'},{future:'first'}]}]]],['signal','result',{callback:'fetch'}],['resolve','first',1],['tick'],['flush'],...names.flatMap(n=>Array.from({length:duplicate?2:1},()=>['evaluate',mark(n)])),['refresh','result'],['flush'],['evaluate',pending(read('x'))],['evaluate',pending(read('result'))],['resolve','second',2],['tick'],['flush'],['evaluate',pending(read('result'))],['dispose']]);
}

for(const target of['x','result'])for(const initialError of[false,true]){
 await scenario('mark direct/inherited error '+JSON.stringify({target,initialError}),[['signal','x',initialError],['memo','result',{select:[read('x'),{raise:9},lit(1)]}],['memo','busy',pending(read('result'))],['effect','view',read('busy')],['flush'],['evaluate',mark(target)],['evaluate',pending(read('result'))],['flush'],['set','x',!initialError],['flush'],['evaluate',mark(target)],['evaluate',pending(read('result'))],['flush'],['dispose']]);
}
for(const seeded of[false,true])for(const rejected of[false,true])for(const target of['x','result']){
 await scenario('mark during first loading '+JSON.stringify({seeded,rejected,target}),[['signal','x',1],['future','request'],['memo','result',seq(read('x'),{future:'request'}),seeded?{loadingValue:0}:{}],['memo','busy',pending(read('result'))],['effect','view',read('busy')],['flush'],['evaluate',mark(target)],['evaluate',pending(read('result'))],['flush'],[rejected?'reject':'resolve','request',9],['tick'],['flush'],['evaluate',pending(read('result'))],['dispose']]);
}
for(const inline of[false,true]){
 const declaration=inline?mark('x'):{call:'declare'};
 await scenario('declaration in computation '+inline,[['signal','x',1],['program','declare',[['return',mark('x')]]],['memo','result',seq(read('x'),declaration,read('x'))],['memo','busy',pending(read('result'))],['effect','view',read('busy')],['effect','data',read('result'),{target:3}],['flush'],['set','x',2],['flush'],['read','busy'],['dispose']]);
}
for(const fail of[false,true])for(const detached of[false,true]){
 const clean=seq(mark('x'),...(fail?[{raise:9}]:[]),lit(undefined));
 await scenario('cleanup declares a pending mark '+JSON.stringify({fail,detached}),[...setup,['program','declare',[['return',clean]]],['root','child',seq({onCleanup:lit({callback:'declare'})},lit(1)),{owner:detached?null:'root'}],['flush'],['disposeOwner','child'],['evaluate',pending(read('x'))],['flush'],['evaluate',pending(read('x'))],['dispose']]);
}
for(const depth of[0,1])for(const rejected of[false,true]){
 const target={localAccessor:depth},body={action:{steps:[method(result({future:'gate'})),{next:seq(affect(target),result(lit(1),true)),throw:seq(affect(target),result(lit(2),true))}]}};
 const expr={signalScope:{initial:lit(5),body:depth?{signalScope:{initial:lit(7),body}}:body}};
 await scenario('captured declaration in action resume '+JSON.stringify({depth,rejected}),[['future','gate'],['root','scope',expr],['flush'],[rejected?'reject':'resolve','gate',1],['tick'],['flush'],['dispose']]);
}

for(const index of[0,1])for(const rejected of[false,true]){
 const target={actionArgument:index},plan={steps:[method(seq(affect(target),result({future:'gate'}))),{next:seq(affect(target),result(lit(1),true)),throw:seq(affect(target),result(lit(2),true))}]};
 await scenario('action argument declaration '+JSON.stringify({index,rejected}),[...setup,['future','gate'],['evaluate',{invokeArgs:{callee:{actionCreate:plan},args:[...(index?[lit(0)]:[]),lit({accessor:'x'})]}}],['flush'],[rejected?'reject':'resolve','gate',1],['tick'],['flush'],['dispose']]);
}
for(const depth of[0,1]){
 const body={affects:{target:lit({accessor:'x'}),key:{localWrite:{depth,value:lit(3)}}}};
 await scenario('local capture in optional key '+depth,[...setup,['root','scope',{signalScope:{initial:lit(0),body:depth?{signalScope:{initial:lit(1),body}}:body}}],['flush'],['dispose']]);
}
for(const keyTarget of['x','side']){
 await scenario('callback argument in optional key '+keyTarget,[...setup,['signal','side',0],['program','declare',[['return',{affects:{target:arg(0),key:{invokeWith:{callee:arg(1),value:lit(3)}}}}]]],['evaluate',{call:'declare',args:[lit({accessor:'x'}),lit({setter:keyTarget})]}],['flush'],['dispose']]);
}

for(const keyTarget of['x','side']){
 const key={invokeWith:{callee:{actionArgument:1},value:lit(3)}},plan={steps:[method(seq({affects:{target:{actionArgument:0},key}},result({future:'gate'}))),method(result(lit(1),true))]};
 await scenario('action argument in optional key '+keyTarget,[...setup,['signal','side',0],['future','gate'],['evaluate',{invokeArgs:{callee:{actionCreate:plan},args:[lit({accessor:'x'}),lit({setter:keyTarget})]}}],['flush'],['resolve','gate',1],['tick'],['flush'],['dispose']]);
}
console.log(`${count} public non-store affects histories compare declaration counts, pending readers, ambient/transaction release, quiet reloads, merges and argument order with pinned Solid.`);
