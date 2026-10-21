// Public onSettled, including native owned/tracked and unowned plain callbacks.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),seq=(...seq)=>({seq}),select=(c,y,n)=>({select:[c,y,n]});
const fn=callback=>lit({callback}),future=future=>({future}),body=(...parts)=>seq(...parts,lit(undefined));
let count=0;
async function scenario(name,commands,verify,{nativeGetter=false}={}){
 const S=await import('../build/solid.mjs?settled-history='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),logs=[];
 const original=console.error;console.error=(...args)=>logs.push(args);
 try{
  for(const [op,...args]of commands){
   if(process.env.DEBUG_SETTLED)original(name,op,...args);
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
 }catch(error){original('FAILED onSettled: '+name);throw error;}
 finally{for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();console.error=original;}
}

for(const owner of ['root',null])for(const writeBefore of [false,true])for(const lazy of [false,true]){
 await scenario('one-shot untracked signal read '+JSON.stringify({owner,writeBefore,lazy}),[
  ['signal','x',0],['memo','double',{mul:[read('x'),lit(2)]},{lazy}],
  ['settled','ready',body(read('x'),read('double')),{owner}],...(writeBefore?[['set','x',1]]:[]),['flush'],['set','x',2],['flush'],['dispose'],['flush']
 ],(op,args,result,b,s)=>{if(op==='settled'&&owner===null){assert.equal(b.nodes().length,4);assert.equal(s.sourceNames.size,1);}});
}
for(const owner of ['root',null])for(const cleanup of ['none','program','setter','getter','root']){
 const value=cleanup==='none'?lit(undefined):cleanup==='program'?fn('clean'):cleanup==='root'?lit({rootDisposer:'victim'}):lit({[cleanup==='getter'?'accessor':'setter']:'marker'});
 await scenario('owned cleanup versus production unowned dropped return '+JSON.stringify({owner,cleanup}),[
  ['signal','x',0],['signal','marker',7],['root','victim',lit(0)],['program','clean',[['emit',31]]],
  ['settled','ready',seq(read('x'),value),{owner}],['flush'],['set','x',1],['flush'],['dispose'],['flush']
 ],undefined,{nativeGetter:cleanup==='getter'});
}
for(const owner of ['root',null])for(const immediate of [false,true])for(const reject of [false,true])for(const seeded of [false,true]){
 await scenario('initial pending and rejection '+JSON.stringify({owner,immediate,reject,seeded}),[
  ['future','p',{immediate}],['memo','data',future('p'),seeded?{loadingValue:0}:{}],['settled','ready',body(read('data')),{owner}],['flush'],
  [reject?'reject':'resolve','p',7],['tick'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
 ]);
}
for(const owner of ['root',null])for(const firstRun of [false,true]){
 await scenario('dispose before or after first callback '+JSON.stringify({owner,firstRun}),[
  ['signal','x',0],['program','clean',[['emit',31]]],['settled','ready',seq(read('x'),fn('clean')),{owner}],...(firstRun?[['flush']]:[]),['dispose'],['flush']
 ]);
 await scenario('callback exception '+JSON.stringify({owner,firstRun}),[
  ['settled','ready',{raise:8},{owner}],...(firstRun?[['flush']]:[]),['resetErrorHalt'],['flush'],['resetErrorHalt'],['dispose'],['flush']
 ]);
}
for(const owner of ['root',null]){
 await scenario('nested callback uses plain queue '+owner,[
  ['signal','x',1],['program','clean',[['emit',31]]],['settled','ready',body(read('x'),{settled:seq(read('x'),fn('clean'))}),{owner}],['flush'],['dispose'],['flush']
 ]);
 await scenario('render write re-derivation '+owner,[
  ['signal','x',0],['signal','seen',99],['memo','double',{mul:[read('x'),lit(2)]}],['program','write',[['set','x',2]]],
  ['effect','writer',read('x'),{program:'write'}],['flush'],['set','x',1],
  ['program','save',[['setExpr','seen',read('double')]]],['settled','ready',body({call:'save'}),{owner}],['flush'],['read','seen'],['dispose'],['flush']
 ],(op,args,result)=>{if(op==='read')assert.deepEqual(result,['return',owner===null?4:2]);});
}
await scenario('captured callback argument and lexical signal',[
 ['program','make',[['return',{signalScope:{initial:{argument:0},body:{settled:body({localRead:0},{argument:0})}}}]]],
 ['root','scope',{call:'make',args:[lit(7)]}],['flush'],['disposeOwner','scope'],['flush'],['dispose']
]);
await scenario('onSettled created inside tracked callback allocates no child',[
 ['signal','x',1],['tracked','watch',body(read('x'),{settled:body(read('x'))})],['flush'],['set','x',2],['flush'],['dispose'],['flush']
]);
for(const owner of ['root',null]){
 await scenario('throw interrupts detached callback list '+owner,[
  ['signal','marker',0],['program','write',[['set','marker',7]]],['settled','fails',{raise:8},{owner}],
  ['settled','later',body({call:'write'}),{owner}],['flush'],['resetErrorHalt'],['flush'],['read','marker'],['dispose'],['resetErrorHalt'],['flush']
 ]);
 await scenario('queued callbacks retain insertion order '+owner,[
  ['signal','marker',0],['program','first',[['emit',11],['set','marker',7]]],['program','second',[['emit',12]]],
  ['settled','first',body({call:'first'}),{owner}],['settled','second',body(read('marker'),{call:'second'}),{owner}],['flush'],['read','marker'],['dispose'],['flush']
 ]);
 await scenario('creation from render body uses plain queue '+owner,[
  ['signal','x',0],['program','register',[['set','x',7],['eval',{settled:body(read('x'))}]]],
  ['effect','render',lit(1),{program:'register',user:owner===null}],['flush'],['dispose'],['flush']
 ]);
}
console.log(`${count} onSettled histories match actual owned/unowned scheduling, one-shot reads, cleanup, pending, errors and nested callbacks.`);
