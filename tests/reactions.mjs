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
 const S=await import('../build/solid.mjs?reaction-history='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),logs=[];
 const original=console.error;console.error=(...args)=>logs.push(args);
 try{
  for(const [op,...args]of commands){
   if(process.env.DEBUG_REACTION)original(name,op,...args);
   if(op==='tick')await setImmediate();
   else{
    const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
    if(actual[0]==='return'&&expected[0]==='return'&&!['evaluate','root','future','read','set','update'].includes(op))actual[1]=expected[1]=undefined;
    assert.deepEqual(actual,expected,`${name}: ${op} result`);verify?.(op,args,expected,b,s);
   }
   const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: nodes after ${op}`);
   const bt=b.trace().filter(e=>e[0]!=='apply'),st=s.trace().filter(e=>e[0]!=='apply');assert.deepEqual(nativeGetter?bt.filter(e=>e[0]!=='read'):bt,nativeGetter?st.filter(e=>e[0]!=='read'):st,`${name}: trace after ${op}`);
   const links=list(b.world.links);
   const id=node=>{if(!node)return 0;const label=s.sourceNames.get(node)??s.namedOwners.get(node)??Object.entries(s.owners).find(([,owner])=>owner===node)?.[0];assert.ok(label,'native owner has a comparison label');return b.ownerId(label);};
   for(const [node,name]of s.sourceNames){const n=b.nodes()[b.ids[name]];for(const [field,native]of [['parent','_parent'],['firstChild','_firstChild'],['nextSibling','_nextSibling'],['prevSibling','_prevSibling']])assert.equal(n[field],id(node[native]),`${name}: ${field} after ${op}`);}
   for(const [name,owner]of Object.entries(s.owners)){const disposal=owner._disposal,expected=Array.isArray(disposal)?disposal.length:disposal?1:0,d=b.nodes()[b.ownerId(name)].disposal;assert.equal('callbacks'in d?list(d.callbacks).length:'callback'in d?1:0,expected,`${name}: root cleanup captures after ${op}`);}
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
 }catch(error){original('FAILED reaction: '+name);throw error;}
 finally{for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();console.error=original;}
}

for(const owner of ['root',null])for(const schedule of [false,true])for(const sync of [false,true]){
 await scenario('fire once and re-arm '+JSON.stringify({owner,schedule,sync}),[
  ['signal','x',0],['signal','count',0],['program','fire',[['updateExpr','count',{add:[{prev:true},lit(1)]}]]],
  ['reaction','ready',body({call:'fire'}),{owner,schedule,sync}],['flush'],['track','ready',read('x')],['flush'],['read','count'],
  ['set','x',1],['flush'],['set','x',2],['flush'],['read','count'],['track','ready',read('x')],['set','x',3],['flush'],['read','count'],['dispose'],['flush']
 ],(op,args,result,b,s)=>{if(op==='reaction'){assert.equal(b.nodes().length,4);assert.equal(s.sourceNames.size,0);}});
}
for(const firstFlush of [false,true])for(const queueOld of [false,true])for(const owner of ['root',null]){
 await scenario('replace the previous subscription '+JSON.stringify({firstFlush,queueOld,owner}),[
  ['signal','a',0],['signal','b',0],['signal','count',0],['program','fire',[['updateExpr','count',{add:[{prev:true},lit(1)]}]]],['reaction','ready',body({call:'fire'}),{owner}],
  ['track','ready',read('a')],...(firstFlush?[['flush']]:[]),...(queueOld?[['set','a',1]]:[]),['track','ready',read('b')],
  ['set','a',2],['flush'],['read','count'],['set','b',1],['flush'],['read','count'],['set','b',2],['flush'],['read','count'],['dispose'],['flush']
 ]);
}
for(const cleanup of ['none','program','setter','getter','root'])for(const owner of ['root',null]){
 const value=cleanup==='none'?lit(undefined):cleanup==='program'?fn('clean'):cleanup==='root'?lit({rootDisposer:'victim'}):lit({[cleanup==='getter'?'accessor':'setter']:'marker'});
 await scenario('cleanup retained until next fire or owner disposal '+JSON.stringify({cleanup,owner}),[
  ['signal','x',0],['signal','marker',7],['root','victim',lit(0)],['program','clean',[['emit',31]]],['reaction','ready',value,{owner}],
  ['track','ready',read('x')],['set','x',1],['flush'],['track','ready',read('x')],['set','x',2],['flush'],['dispose'],['flush']
 ],undefined,{nativeGetter:cleanup==='getter'});
}
for(const immediate of [false,true])for(const reject of [false,true])for(const seeded of [false,true])for(const handler of [false,true]){
 await scenario('tracking dependency pending/error delivery '+JSON.stringify({immediate,reject,seeded,handler}),[
  ['signal','count',0],['program','fire',[['updateExpr','count',{add:[{prev:true},lit(1)]}]]],['program','error',[['emit',41]]],
  ['future','p',{immediate}],['memo','data',future('p'),seeded?{loadingValue:0}:{}],['reaction','ready',body({call:'fire'}),handler?{errorProgram:'error'}:{}],
  ['track','ready',read('data')],['flush'],[reject?'reject':'resolve','p',7],['tick'],['resetErrorHalt'],['flush'],['read','count'],['dispose'],['resetErrorHalt'],['flush']
 ]);
}
for(const armed of [false,true])for(const firstFire of [false,true]){
 await scenario('owner disposal stops arms and calls retained cleanup '+JSON.stringify({armed,firstFire}),[
  ['signal','x',0],['program','clean',[['emit',31]]],['reaction','ready',fn('clean')],...(armed?[['track','ready',read('x')]]:[]),
  ...(firstFire?[['set','x',1],['flush']]:[]),['dispose'],['set','x',2],['flush']
 ]);
}
for(const when of ['callback','cleanup','tracking','replace']){
 const tracking=when==='tracking'?seq(read('x'),{raise:8}):when==='replace'?seq(read('x'),{onCleanup:fn('clean')}):read('x');
 await scenario('throw and partial closure state '+when,[
  ['signal','x',0],['program','clean',[['emit',31],['throw',9]]],['reaction','ready',when==='callback'?{raise:8}:fn('clean')],
  ['track','ready',tracking],['flush'],...(when==='replace'?[['track','ready',read('x')]]:[['set','x',1],['flush'],['track','ready',read('x')],['set','x',2],['flush']]),
  ['resetErrorHalt'],['dispose'],['resetErrorHalt'],['flush']
 ]);
}
for(const rearm of [false,true]){
 await scenario('arm assignment follows a tracking body with zero dependencies '+rearm,[
  ['signal','readDep',true],['signal','x',0],['program','fire',[['emit',31]]],['reaction','ready',body({call:'fire'})],
  ['track','ready',select(read('readDep'),read('x'),lit(undefined))],['flush'],['set','readDep',false],['set','x',1],['flush'],
  ...(rearm?[['track','ready',lit(undefined)]]:[]),['set','x',2],['flush'],['dispose'],['flush']
 ]);
}
await scenario('re-arm from the reaction callback',[
 ['signal','x',0],['signal','count',0],['program','fire',[['updateExpr','count',{add:[{prev:true},lit(1)]}]]],
 ['reaction','ready',body({call:'fire'},{reactionArm:{callee:lit({reaction:'ready'}),tracking:read('x')}})],
 ['track','ready',read('x')],['set','x',1],['flush'],['read','count'],['set','x',2],['flush'],['read','count'],['dispose'],['flush']
]);
await scenario('captured owner remains the owner when armed elsewhere',[
 ['signal','x',0],['program','clean',[['emit',31]]],['root','scope',lit(0)],['reaction','ready',fn('clean'),{owner:'scope'}],
 ['track','ready',read('x')],['set','x',1],['flush'],['disposeOwner','scope'],['flush'],['dispose'],['flush']
]);
await scenario('returned track function retains first-class identity',[
 ['reaction','ready',lit(undefined)],['evaluate',{same:[lit({reaction:'ready'}),lit({reaction:'ready'})]}],
 ['reaction','other',lit(undefined)],['evaluate',{same:[lit({reaction:'ready'}),lit({reaction:'other'})]}],['dispose'],['flush']
],(op,args,result)=>{if(op==='evaluate')assert.deepEqual(result,['return',args[0].same[1].lit.reaction==='ready']);});
for(const cleanup of [false,true]){
 await scenario('error bundle receives actual thrown argument '+cleanup,[
  ['signal','fail',false],['signal','x',0],['signal','error',0],['program','clean',[['emit',31]]],
  ['program','handle',[...(cleanup?[['previousCleanup']]:[]),['setExpr','error',{argument:0}]]],['reaction','ready',fn('clean'),{errorProgram:'handle'}],
  ['track','ready',select(read('fail'),{raise:8},read('x'))],['set','x',1],['flush'],['set','fail',true],
  ['track','ready',select(read('fail'),{raise:9},read('x'))],['flush'],['read','error'],['dispose'],['flush']
 ],(op,args,result)=>{if(op==='read')assert.deepEqual(result,['return',9]);});
}
// Deliberately preserve the pinned source's #2861 pending-arm hole. A loading
// seed makes tracking return successfully, so the replacement control works.
for(const immediate of [false,true])for(const seeded of [false,true])for(const flushBetween of [false,true]){
 let reads=0;
 await scenario('pending replacement source bug/control '+JSON.stringify({immediate,seeded,flushBetween}),[
  ['signal','current',0],['signal','count',0],['future','old',{immediate}],['memo','obsolete',future('old'),seeded?{loadingValue:0}:{}],
  ['program','fire',[['updateExpr','count',{add:[{prev:true},lit(1)]}]]],['reaction','ready',body({call:'fire'})],
  ['track','ready',read('obsolete')],...(flushBetween?[['flush']]:[]),['track','ready',read('current')],['flush'],
  ['resolve','old',7],['tick'],['flush'],['read','count'],['set','current',1],['flush'],['read','count'],['dispose'],['flush']
 ],(op,args,result)=>{if(op==='read'){assert.deepEqual(result,['return',(seeded?0:1)+reads]);reads++;}});
}
let recoveredArmReads=0;
await scenario('superseded initial tracking error retains its pinned arm',[
 ['signal','failed',true],['signal','current',0],['signal','count',0],['program','handle',[['emit',41]]],
 ['program','fire',[['updateExpr','count',{add:[{prev:true},lit(1)]}]]],['reaction','ready',body({call:'fire'}),{errorProgram:'handle'}],
 ['track','ready',select(read('failed'),{raise:8},lit(undefined))],['track','ready',read('current')],['flush'],
 ['set','failed',false],['flush'],['read','count'],['set','current',1],['flush'],['read','count'],['dispose'],['flush']
],(op,args,result)=>{if(op==='read')assert.deepEqual(result,['return',++recoveredArmReads]);});
console.log(`${count} reaction histories match actual replacement arms, one-shot firing, re-arming, cleanup, pending/errors, owner capture and returned identity.`);
