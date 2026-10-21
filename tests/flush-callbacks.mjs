// scheduler.flush(fn): native source callbacks, nested drains and finally ordering.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),seq=(...seq)=>({seq}),select=(c,y,n)=>({select:[c,y,n]});
const fn=callback=>lit({callback}),future=future=>({future}),body=(...parts)=>seq(...parts,lit(undefined));
let count=0;
async function scenario(name,commands,verify,{nativeGetter=false}={}){
 const S=await import('../build/solid.mjs?flush-history='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),logs=[];
 const original=console.error;console.error=(...args)=>logs.push(args);
 try{
  for(const [op,...args]of commands){
   if(process.env.DEBUG_FLUSH)original(name,op,...args);
   if(op==='tick')await setImmediate();
   else{
    const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
    if(actual[0]==='return'&&expected[0]==='return'&&!['evaluate','root','future','read','set','update','flush'].includes(op))actual[1]=expected[1]=undefined;
    assert.deepEqual(actual,expected,`${name}: ${op} result`);verify?.(op,args,expected,b,s);
   }
   const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: nodes after ${op}`);
   const bt=b.trace(),st=s.trace();assert.deepEqual(nativeGetter?bt.filter(e=>e[0]!=='read'):bt,nativeGetter?st.filter(e=>e[0]!=='read'):st,`${name}: trace after ${op}`);
   const links=list(b.world.links);
   for(const [node,label]of s.sourceNames){
    const expected=[],actual=[],n=b.nodes()[b.ids[label]];
    for(let edge=node._deps;edge;edge=edge._nextDep){const id=[...s.accessorIdentities].find(([get])=>Object.getOwnPropertySymbols(get).some(key=>get[key]===edge._dep))?.[1]??s.sourceNames.get(edge._dep);expected.push([id,edge._gen]);}
    for(let edge=n.deps;edge;edge=links[edge].nextDep)actual.push([b.reverse[links[edge].dep],links[edge].gen]);
    assert.deepEqual(actual,expected,`${name}: ordered deps of ${label} after ${op}`);
    if(node._type===3){assert.equal(n.kind.$,'Tracked');assert.equal(node._cleanup===undefined,n.cleanup===0,`${name}: returned cleanup presence`);}
   }
   assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: native callback errors after ${op}`);
   for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
   assert.deepEqual([b.world.context,b.world.tracking,b.world.running,b.world.stale,b.world.syncDepth],[0,false,false,false,0],`${name}: ambient restoration`);
   const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
   assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports after ${op}`);
  }
  count++;
 }catch(error){original('FAILED flush callback: '+name);throw error;}
 finally{for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();console.error=original;}
}


const write=(name,value)=>({invokeWith:{callee:lit({setter:name}),value}}),flush=flush=>({flush});
for(const returnValue of [undefined,null,false,true,0,7,'value',{ref:7}])for(const pendingBefore of [false,true]){
 await scenario('callback result and coalescing '+JSON.stringify({returnValue,pendingBefore}),[
  ['signal','x',0],['memo','double',{mul:[read('x'),lit(2)]}],['effect','view',read('double')],['flush'],
  ...(pendingBefore?[['set','x',1]]:[]),['flush',seq(write('x',lit(2)),write('x',lit(3)),lit(returnValue))],
  ['read','x'],['read','double'],['dispose'],['flush']
 ]);
}
for(const nested of ['callback','plain','none'])for(const throwInner of [false,true]){
 const inside=seq(write('x',lit(2)),throwInner?{raise:8}:read('x'));
 await scenario('nested drain and saved return '+JSON.stringify({nested,throwInner}),[
  ['signal','x',0],['effect','view',read('x')],['flush'],
  ['flush',seq(write('x',lit(1)),nested==='callback'?flush(inside):nested==='plain'?seq(inside,{flushNow:true}):inside,read('x'))],
  ['read','x'],['set','x',3],['tick'],['read','x'],['dispose'],['flush']
 ],(op,args,result)=>{if(op==='flush'&&args.length&&!throwInner)assert.deepEqual(result,['return',nested==='none'?0:2]);});
}
for(const error of [8,{ref:8},{error:1,kind:'Error',message:'body failed'}]){
 await scenario('throwing body still drains and releases depth '+JSON.stringify(error),[
  ['signal','x',0],['effect','view',read('x')],['flush'],['flush',seq(write('x',lit(1)),{add:[lit(10),{raise:error}]})],
  ['read','x'],['set','x',2],['tick'],['read','x'],['dispose'],['flush']
 ]);
}
for(const bodyThrows of [false,true])for(const nested of [false,true]){
 const failed=seq(write('x',lit(1)),bodyThrows?{raise:8}:lit(77));
 await scenario('drain error overrides callback result/error '+JSON.stringify({bodyThrows,nested}),[
  ['signal','x',0],['program','fail',[['return',select({same:[{argument:0},lit(1)]},{raise:9},lit(undefined))]]],
  ['effect','view',read('x'),{user:true,program:'fail'}],['flush'],['flush',nested?flush(failed):failed],
  ['resetErrorHalt'],['set','x',2],['tick'],['read','x'],['dispose'],['flush']
 ],(op,args,result)=>{if(op==='flush'&&args.length)assert.deepEqual(result,['throw',9]);});
}
for(const user of [false,true])for(const kind of ['effect','tracked','settled']){
 const callback=seq(flush(seq(write('y',{argument:0}),{flushNow:true})),lit(undefined));
 const create=kind==='effect'?['effect','writer',read('x'),{user,program:'write'}]:kind==='tracked'?['tracked','writer',seq(read('x'),flush(write('y',read('x'))),lit(undefined))]:['settled','writer',seq(flush(write('y',read('x'))),lit(undefined))];
 await scenario('flush callback while queue running '+JSON.stringify({user,kind}),[
  ['signal','x',1],['signal','y',0],['program','write',[['return',callback]]],create,['flush'],['set','x',2],['flush'],['read','y'],['dispose'],['flush']
 ]);
}
for(const lazy of [false,true])for(const call of ['body','value']){
 await scenario('ambient tracking survives flush '+JSON.stringify({lazy,call}),[
  ['signal','x',1],['program','read',[['return',read('x')]]],
  ['memo','copy',call==='body'?flush(read('x')):{flushCall:fn('read')},{lazy}],
  ['effect','view',read('copy')],['flush'],['set','x',2],['flush'],['read','copy'],['dispose'],['flush']
 ]);
}
for(const native of ['program','getter','setter','disposer']){
 const callee=native==='program'?fn('return'):native==='disposer'?lit({rootDisposer:'victim'}):lit({[native==='getter'?'accessor':'setter']:'x'});
 await scenario('original native function passed directly '+native,[
  ['signal','x',7],['root','victim',lit(0)],['program','return',[['return',lit(31)]]],
  ['evaluate',{flushCall:callee}],['read','x'],['dispose'],['flush']
 ],undefined,{nativeGetter:native==='getter'});
}
for(const value of [undefined,null,false,0,'']){
 await scenario('falsy optional callback selects plain drain '+JSON.stringify(value),[
  ['signal','x',0],['set','x',1],['evaluate',{flushCall:lit(value)}],['read','x'],['dispose'],['flush']
 ]);
}
for(const halted of [false,true]){
 await scenario('callback runs despite halt '+halted,[
  ['signal','x',0],...(halted?[['program','fail',[['throw',8]]],['effect','bad',lit(1),{user:true,program:'fail'}],['flush']]:[]),
  ['flush',seq(write('x',lit(1)),lit(31))],['resetErrorHalt'],['flush'],['read','x'],['dispose'],['flush']
 ],(op,args,result)=>{if(op==='flush'&&args.length)assert.deepEqual(result,['return',31]);});
}
await scenario('callback captures its lexical signal and outer arguments',[
 ['root','scope',{signalScope:{initial:lit(7),body:flush({add:[{localRead:0},lit(1)]})}}],
 ['program','return',[['return',flush({add:[{argument:0},lit(1)]})]]],['evaluate',{call:'return',args:[lit(9)]}],['dispose'],['flush']
],(op,args,result)=>{if(op==='root')assert.deepEqual(result,['return',8]);if(op==='evaluate')assert.deepEqual(result,['return',10]);});
await scenario('root owner cleanup registered from flush callback',[
 ['program','clean',[['emit',31]]],['root','scope',flush(seq({onCleanup:fn('clean')},{owner:true}))],
 ['disposeOwner','scope'],['flush'],['dispose'],['flush']
]);

for(const immediate of [false,true])for(const seeded of [false,true])for(const reject of [false,true]){
 await scenario('pending callback read still drains '+JSON.stringify({immediate,seeded,reject}),[
  ['signal','x',0],['future','old',{immediate}],['memo','data',future('old'),seeded?{loadingValue:0}:{}],
  ['flush',seq(write('x',lit(1)),read('data'))],['read','x'],[reject?'reject':'resolve','old',7],['tick'],['flush'],['read','data'],['dispose'],['flush']
 ]);
}
for(const reentrant of [false,true]){
 await scenario('updater previous value captured across callback drain '+reentrant,[
  ['signal','x',0],['signal','y',0],['effect','view',read('x')],['flush'],
  ['update','x',flush(seq(write(reentrant?'x':'y',lit(5)),{add:[{prev:true},lit(1)]}))],['read','x'],['flush'],['read','x'],['dispose'],['flush']
 ]);
}
for(const immediate of [false,true]){
 await scenario('callback returns original promise without waiting '+immediate,[
  ['future','old',{immediate}],['signal','x',0],['flush',seq(write('x',lit(1)),future('old'))],
  ['read','x'],['resolve','old',7],['tick'],['dispose'],['flush']
 ],(op,args,result)=>{if(op==='flush'&&args.length)assert.deepEqual(result,['return',{async:1}]);});
}
let io=0;
for(const pendingBefore of [false,true])for(const throws of [false,true])for(const nested of [false,true]){
 const S=await import('../build/solid.mjs?flush-io='+io),b=new BendRuntime({async:false}),s=new SolidRuntime({module:S}),queued=[],original=globalThis.queueMicrotask;
 globalThis.queueMicrotask=fn=>queued.push(fn);
 try{
  for(const r of [b,s]){r.signal('x',0);if(pendingBefore)r.attempt('set','x',1);}
  const callback=seq(write('x',lit(2)),throws?{raise:8}:lit(77)),body=nested?flush(callback):callback;
  assert.deepEqual(b.attempt('flush',body),s.attempt('flush',body));
  assert.equal(b.world.syncDepth,0,'callback scope balanced');
  assert.equal(list(b.world.hostJobs).filter(j=>j.$==='FlushJob').length,pendingBefore?1:0);
  assert.equal(queued.length,pendingBefore?1:0,'callback writes request no extra native microtask');
  assert.deepEqual(b.attempt('set','x',3),s.attempt('set','x',3));
  assert.equal(list(b.world.hostJobs).filter(j=>j.$==='FlushJob').length,(pendingBefore?1:0)+1);
  assert.equal(queued.length,(pendingBefore?1:0)+1,'ordinary scheduling resumes');
  io++;
 }finally{globalThis.queueMicrotask=original;for(const r of [b,s]){r.attempt('dispose');r.attempt('flush');}}
}
console.log(`${count} flush callback histories and ${io} native microtask-IO controls match nested drains, committed reads, returned values, errors, scheduling recovery and native callbacks.`);
