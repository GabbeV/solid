// Native bound getters are registered unchanged; no JS wrapper intercepts them.
// Direct getter-boundary read events are not observable in the native host.
// Compare all other traces, node states, dependency order/generations and aliases.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future});
const seq=(...seq)=>({seq}),select=(c,y,n)=>({select:[c,y,n]});
const fn=name=>lit({accessor:name}),onCleanup=onCleanup=>({onCleanup});
const under=(name,body)=>({withOwner:[lit({owner:name}),body]});
const invoke=invoke=>({invoke}),arg=argument=>({argument});
const ids=d=>'callbacks'in d?list(d.callbacks):'callback'in d?[d.callback]:[];
const callbacks=d=>Array.isArray(d)?d:d?[d]:[];
let count=0;
async function scenario(name,commands,verify){
 const module=await import('../build/solid.mjs?getter-cleanup='+count);
 const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
 const original=console.error;console.error=(...args)=>logs.push(args);
 try{
  for(const [op,...args]of commands){
   if(op==='tick')await setImmediate();
   else{
    const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
    if(actual[0]==='return'&&expected[0]==='return'&&!['read','set','update','future','root','evaluate'].includes(op))actual[1]=expected[1]=undefined;
    assert.deepEqual(actual,expected,`${name}: ${op} result`);verify?.(op,args,expected,b,s);
   }
   const owners=[...Object.entries(s.owners).map(([name,node])=>[node,name]),...s.sourceNames];
   const encoded=[],native=[];
   for(const [node,label]of owners){
    const n=b.nodes()[b.ownerId(label)],bd=ids(n.disposal),sd=callbacks(node._disposal);
    assert.equal(bd.length,sd.length,`${name}: disposal count after ${op}`);encoded.push(...bd);native.push(...sd);
    assert.equal(!!n.cleanup,!!node._cleanup,`${name}: returned cleanup presence after ${op}`);
    if(n.cleanup){encoded.push(n.cleanup);native.push(node._cleanup);}
   }
   for(let i=0;i<encoded.length;i++)for(let j=0;j<encoded.length;j++)assert.equal(encoded[i]===encoded[j],native[i]===native[j],`${name}: function alias ${i}/${j} after ${op}`);
   const known=new Map(owners);
   for(const [get,label]of s.accessorIdentities){
    const node=Object.getOwnPropertySymbols(get).map(key=>get[key]).find(value=>value&&typeof value==='object'&&'_pendingValue'in value);
    assert.ok(node,'native accessor metadata is intact');known.set(node,label);
   }
   const links=list(b.world.links);
   for(const [node,label]of known){
    const n=b.nodes()[b.ids[label]??b.ownerId(label)],actual=[],expected=[];
    for(let edge=n.deps;edge;edge=links[edge].nextDep)actual.push([b.reverse[links[edge].dep],links[edge].gen]);
    for(let edge=node._deps;edge;edge=edge._nextDep)expected.push([known.get(edge._dep),edge._gen]);
    assert.deepEqual(actual,expected,`${name}: ordered dependencies of ${label} after ${op}`);
   }
   const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: node state after ${op}`);
   assert.deepEqual(b.trace().filter(e=>e[0]!=='read'),s.trace().filter(e=>e[0]!=='read'),`${name}: non-read trace after ${op}`);
   assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: async failures after ${op}`);
   for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
   assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],`${name}: ambient state after ${op}`);
   const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
   assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports after ${op}`);
  }
  count++;
 }catch(error){original('FAILED getter cleanup: '+name);throw error;}
 finally{for(const runtime of [b,s]){runtime.attempt('dispose');runtime.resetErrorHalt();runtime.attempt('flush');}await setImmediate();console.error=original;}
}
const target=kind=>kind==='data'?[['signal','target',1]]:[['signal','input',1],['memo','target',read('input'),{owner:null,lazy:kind==='lazy'}]];
for(const kind of ['data','memo','lazy'])for(const copies of [1,2,3]){
 await scenario('canonical registration '+JSON.stringify({kind,copies}),[
  ...target(kind),['root','cleaner',lit(0)],...Array.from({length:copies},()=>['evaluate',under('cleaner',onCleanup(fn('target')))]),
  ['disposeOwner','cleaner'],['flush'],['read','target'],['dispose']
 ]);
}
for(const kind of ['data','memo','lazy'])for(const first of ['left','right']){
 await scenario('independent owners share getter '+JSON.stringify({kind,first}),[
  ...target(kind),['root','left',onCleanup(fn('target'))],['root','right',onCleanup(fn('target'))],
  ['disposeOwner',first],['flush'],['dispose'],['flush']
 ]);
}
for(const before of [false,true])for(const fail of [false,true]){
 await scenario('lazy read LIFO and interruption '+JSON.stringify({before,fail}),[
  ['signal','marker',0],['program','mark',[['set','marker',7],...(fail?[['throw',9]]:[])]],
  ['memo','target',seq({call:'mark'},lit(8)),{owner:null,lazy:true}],['program','other',[['emit',31]]],['program','attach',[['cleanup','other']]],
  ['root','cleaner',before?seq(onCleanup(fn('target')),{call:'attach'}):seq({call:'attach'},onCleanup(fn('target')))],
  ['disposeOwner','cleaner'],['disposeOwner','cleaner'],['flush'],['read','marker'],['dispose'],['flush']
 ]);
}
for(const kind of ['data','memo','lazy'])for(const user of [false,true])for(const clear of [false,true]){
 await scenario('returned cleanup shares owner identity '+JSON.stringify({kind,user,clear}),[
  ...target(kind),['signal','version',0],['root','cleaner',onCleanup(fn('target'))],
  ['program','choose',[['return',select(arg(0),clear?lit(undefined):fn('target'),fn('target'))]]],
  ['effect','view',read('version'),{user,program:'choose',returnCleanup:true}],['flush'],
  ['set','version',1],['flush'],['disposeOwner','cleaner'],['dispose'],['flush']
 ]);
}
for(const immediate of [false,true])for(const state of ['resolve','reject','pending'])for(const returned of [false,true]){
 await scenario('async getter cleanup '+JSON.stringify({immediate,state,returned}),[
  ['future','p',{immediate}],['memo','target',future('p'),{owner:null,lazy:true}],['signal','version',0],
  ...(state==='pending'?[]:[[state,'p',7],['tick']]),
  ...(returned?[
   ['program','choose',[['return',fn('target')]]],['root','cleaner',lit(0)],
   ['effect','view',read('version'),{owner:'cleaner',user:true,program:'choose',returnCleanup:true}],['flush']
  ]:[['root','cleaner',onCleanup(fn('target'))]]),
  ['disposeOwner','cleaner'],['resetErrorHalt'],['flush'],['resolve','p',8],['tick'],['dispose'],['resetErrorHalt'],['flush']
 ]);
}
for(const entry of ['owner','render','user']){
 await scenario('getter return is ignored '+entry,[
  ['root','victim',lit(0)],['signal','target',undefined],['program','seed',[['updateExpr','target',lit({rootDisposer:'victim'})]]],['evaluate',{call:'seed'}],['flush'],
  ...(entry==='owner'?[['root','cleaner',onCleanup(fn('target'))]]:[
   ['root','cleaner',lit(0)],['signal','version',0],['program','choose',[['return',fn('target')]]],
   ['effect','view',read('version'),{owner:'cleaner',user:entry==='user',program:'choose',returnCleanup:true}],['flush']
  ]),['disposeOwner','cleaner'],['evaluate',{disposed:lit({owner:'victim'})}],['dispose'],['flush']
 ],(op,args,result)=>{if(op==='evaluate'&&args[0].disposed)assert.deepEqual(result,['return',false],'a returned function is data, not another cleanup invocation');});
}
for(const kind of ['data','memo','lazy']){
 await scenario('getter cleanup inherits computation tracking '+kind,[
  ...target(kind),['signal','version',0],['root','cleaner',onCleanup(fn('target'))],
  ['memo','parent',seq(read('version'),select(read('version'),invoke(lit({rootDisposer:'cleaner'})),lit(0)),lit(9))],
  ['effect','view',read('parent')],['flush'],['set','version',1],['flush'],
  ['set',kind==='data'?'target':'input',7],['flush'],['read','parent'],['dispose']
 ]);
 await scenario('dead owner and reentrant root cycle '+kind,[
  ...target(kind),['root','left',lit(0)],['root','right',onCleanup(lit({rootDisposer:'left'}))],
  ['evaluate',under('left',seq(onCleanup(fn('target')),onCleanup(lit({rootDisposer:'right'}))))],
  ['disposeOwner','left'],['evaluate',under('left',onCleanup(fn('target')))],['disposeOwner','left'],['dispose'],['flush']
 ]);
}
for(const lazy of [false,true]){
 await scenario('captured writable getter cleanup '+lazy,[
  ['signal','saved',undefined],['program','save',[['updateExpr','saved',arg(0)]]],
  ['root','targetScope',{signalComputeScope:{compute:lit(7),options:{lazy},body:{call:'save',args:[{localAccessor:0}]}}}],['flush'],
  ['root','cleaner',onCleanup(read('saved'))],['disposeOwner','cleaner'],['flush'],['evaluate',invoke(read('saved'))],['dispose'],['flush']
 ]);
}
for(const kind of ['data','memo','lazy']){
 const b=new BendRuntime(),s=new SolidRuntime({module:await import('../build/solid.mjs?getter-native='+kind)});
 try{
  for(const runtime of [b,s]){
   for(const [op,...args]of target(kind))runtime[op](...args);
   const value=runtime.evaluate(fn('target')),before=runtime===b?list(b.world.cleanupPrograms).length:0;
   assert.equal(runtime.evaluate(onCleanup(fn('target'))),value,'no owner returns the unchanged native getter');
   if(runtime===b)assert.equal(list(b.world.cleanupPrograms).length,before,'no owner creates no callable');
   runtime.evaluate(under('root',onCleanup(fn('target'))));runtime.evaluate(under('root',onCleanup(fn('target'))));
   assert.equal(runtime.evaluate(fn('target')),value,'registration preserves function identity');
   if(runtime===s)assert.equal(s.owner._disposal[0],value,'Solid stores the actual getter, not a wrapper');
   if(kind==='lazy')assert.equal(runtime.trace().filter(e=>e[0]==='compute'&&e[1]==='target').length,0,'registering a lazy getter does not read it');
   if(runtime===b){assert.equal(list(b.world.cleanupPrograms).length,before+1);const registered=ids(b.nodes()[1].disposal);assert.equal(registered[0],registered[1]);}
  }
 }finally{for(const runtime of [b,s]){runtime.attempt('dispose');runtime.resetErrorHalt();runtime.attempt('flush');}}
}
console.log(`${count} getter-cleanup histories match native aliases, dependencies, lazy pulls, LIFO, returned cleanups, pending/errors and tracking; direct native getter read events are unobserved.`);
