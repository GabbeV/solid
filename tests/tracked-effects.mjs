// Public createTrackedEffect, using Solid's actual single-body API.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),seq=(...seq)=>({seq}),select=(c,y,n)=>({select:[c,y,n]});
const fn=callback=>lit({callback}),future=future=>({future}),body=(...parts)=>seq(...parts,lit(undefined));
let count=0;
async function scenario(name,commands,verify,{nativeGetter=false}={}){
 const S=await import('../build/solid.mjs?tracked-history='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),logs=[];
 const original=console.error;console.error=(...args)=>logs.push(args);
 try{
  for(const [op,...args]of commands){
   if(process.env.DEBUG_TRACKED)original(name,op,...args);
   if(op==='tick')await setImmediate();
   else{
    const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
    if(actual[0]==='return'&&expected[0]==='return'&&!['evaluate','root','future','read','set','update'].includes(op))actual[1]=expected[1]=undefined;
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
   assert.deepEqual([b.world.context,b.world.tracking,b.world.running,b.world.stale],[0,false,false,false],`${name}: ambient restoration`);
   const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
   assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports after ${op}`);
  }
  count++;
 }catch(error){original('FAILED tracked effect: '+name);throw error;}
 finally{for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();console.error=original;}
}
for(const untracked of [false,true])for(const writeFirst of [false,true])for(const batch of [false,true]){
 await scenario('initial run and batched tracking '+JSON.stringify({untracked,writeFirst,batch}),[
  ['signal','x',0],['tracked','watch',body(untracked?{untrack:read('x')}:read('x'))],
  ...(writeFirst?[['set','x',1]]:[]),['flush'],['set','x',2],...(batch?[]:[['flush']]),['set','x',3],['flush'],['set','x',3],['flush'],['dispose'],['flush']
 ]);
}
for(const lazy of [false,true])for(const flip of [false,true]){
 await scenario('derived and dynamic dependencies '+JSON.stringify({lazy,flip}),[
  ['signal','pick',flip],['signal','left',1],['signal','right',2],['memo','selected',select(read('pick'),read('left'),read('right')),{lazy}],
  ['tracked','watch',body(read('selected'))],['flush'],['set','pick',!flip],['flush'],['set',flip?'left':'right',7],['flush'],['set',flip?'right':'left',8],['flush'],['dispose'],['flush']
 ]);
}
for(const cleanup of ['none','program','setter','getter','root'])for(const owner of ['root','scope']){
 const value=cleanup==='none'?lit(undefined):cleanup==='program'?fn('clean'):cleanup==='root'?lit({rootDisposer:'victim'}):lit({[cleanup==='getter'?'accessor':'setter']:'marker'});
 await scenario('returned cleanup call and replacement '+JSON.stringify({cleanup,owner}),[
  ['signal','x',0],['signal','marker',7],['root','scope',lit(0)],['root','victim',lit(0)],['program','clean',[['emit',31]]],
  ['tracked','watch',seq(read('x'),value),{owner}],['flush'],['set','x',1],['flush'],['set','x',2],['flush'],['dispose'],['flush']
 ],undefined,{nativeGetter:cleanup==='getter'});
}
for(const immediate of [false,true])for(const reject of [false,true])for(const seeded of [false,true]){
 await scenario('pending and rejected dependency '+JSON.stringify({immediate,reject,seeded}),[
  ['future','p',{immediate}],['memo','data',future('p'),seeded?{loadingValue:0}:{}],['tracked','watch',body(read('data'))],['flush'],
  [reject?'reject':'resolve','p',7],['tick'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
 ]);
}
for(const immediate of [false,true])for(const changed of [false,true]){
 await scenario('refetch uses an existing value while pending '+JSON.stringify({immediate,changed}),[
  ['signal','version',0],['future','p',{immediate}],['memo','data',select(read('version'),future('p'),lit(1))],
  ['tracked','watch',body(read('data'))],['flush'],['set','version',1],['flush'],['resolve','p',changed?7:1],['tick'],['flush'],['dispose'],['flush']
 ]);
}
for(const when of ['first','later','cleanup']){
 await scenario('throw routing '+when,[
  ['signal','fail',when==='first'],['signal','version',0],['program','clean',[['emit',31],['throw',9]]],
  ['tracked','watch',seq(read('version'),select(read('fail'),{raise:8},when==='cleanup'?fn('clean'):lit(undefined)))],['flush'],
  ['set','version',1],...(when==='later'?[['set','fail',true]]:[]),['flush'],['resetErrorHalt'],['set','fail',false],['flush'],['dispose'],['resetErrorHalt'],['flush']
 ]);
}
for(const firstRun of [false,true])for(const pending of [false,true]){
 await scenario('owner disposal before queued or resumed run '+JSON.stringify({firstRun,pending}),[
  ['signal','x',0],['future','p',{immediate:false}],['memo','data',pending?future('p'):read('x')],['root','scope',lit(0)],
  ['tracked','watch',body(read('data')),{owner:'scope'}],...(firstRun?[['flush']]:[]),['disposeOwner','scope'],['set','x',1],['flush'],['resolve','p',7],['tick'],['flush'],['dispose'],['flush']
 ]);
}
await scenario('creation from a render callback reads after its write commits',[
 ['signal','x',0],['program','produce',[['set','x',7],['eval',{trackedCreate:body(read('x'))}]]],
 ['effect','producer',lit(1),{program:'produce'}],['flush'],['set','x',9],['flush'],['dispose'],['flush']
]);
for(const user of [false,true]){
 await scenario('tracked callback writes are committed before the next body '+user,[
  ['signal','x',0],['signal','copy',0],['program','copy',[['setExpr','copy',read('x')]]],
  ['tracked','watch',{call:'copy'}],['effect','view',read('copy'),{user}],['flush'],['set','x',7],['flush'],['set','x',9],['flush'],['dispose'],['flush']
 ]);
}
await scenario('captured lexical signal and callback argument',[
 ['program','make',[['return',{signalScope:{initial:{argument:0},body:{trackedCreate:body({localRead:0},{argument:0})}}}]]],
 ['root','scope',{call:'make',args:[lit(7)]}],['flush'],['disposeOwner','scope'],['flush'],['dispose']
]);
for(const firstWrite of [false,true]){
 await scenario('ownerless tracked effect survives disposal of an unrelated root '+firstWrite,[
  ['signal','x',0],['signal','copy',0],['program','copy',[['setExpr','copy',read('x')]]],
  ['tracked','watch',{call:'copy'},{owner:null}],...(firstWrite?[['set','x',1]]:[]),['flush'],['dispose'],['set','x',7],['flush'],['read','copy']
 ],(op,args,result)=>{if(op==='read')assert.deepEqual(result,['return',7]);});
}
console.log(`${count} tracked-effect histories match actual Solid heap/user-phase ordering, dependency tracking, cleanup, writes, pending/errors and disposal.`);
