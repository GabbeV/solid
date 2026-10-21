// Direct public createOwner and Owner.dispose(self) run the unchanged native
// functions. Context/callback machinery is shared with existing root support.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),arg=argument=>({argument}),read=read=>({read}),seq=(...seq)=>({seq});
const under=(owner,body)=>({withOwner:[lit(owner),body]});
const own=transparent=>({createOwner:{transparent}});
const dispose=(owner,self=true)=>({disposeRoot:lit(owner),self});
const dead=(r,owner)=>r.evaluate({disposed:lit(owner)});
let count=0;
async function scenario(name,body){
 const S=await import('../build/solid.mjs?direct-owner='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),pairs=[];
 const pair=(bo,so)=>{pairs.push([bo,so]);assert.deepEqual(b.observe(bo),s.observe(so));return [bo,so];};
 const sourcePointers=()=>{
  const map=new Map([[s.owner,1]]);
  for(const [name,owner]of Object.entries(s.owners))map.set(owner,b.ids[name]??1);
  for(const [node,name]of s.sourceNames)if(b.ids[name])map.set(node,b.ids[name]);
  for(const [bo,so]of pairs)map.set(so,bo.owner);
  return map;
 };
 const compare=()=>{
  const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,name+' computed nodes');
  assert.deepEqual(b.trace(),s.trace(),name+' trace');assert.deepEqual(b.screen(),s.screen(),name+' screen');
  assert.deepEqual([b.world.context,b.world.tracking],[0,false],name+' caller scope');assert.equal(s.S.getOwner(),null);
  const pointers=sourcePointers(),scopeIds=new Map(),reverseScopes=new Map();
  const pointer=node=>{if(node==null)return 0;assert.ok(pointers.has(node),'unobserved owner/tree pointer');return pointers.get(node);};
  for(const [bo,so]of pairs){
   const n=b.nodes()[bo.owner];assert.equal(n.kind.$,'Root');assert.equal(so._root,true);
   assert.deepEqual([n.flags,n.config,n.parent,n.parentComputed,n.firstChild,n.nextSibling,n.prevSibling],[so._flags,so._config,pointer(so._parent),pointer(so._parentComputed),pointer(so._firstChild),pointer(so._nextSibling),pointer(so._prevSibling)],name+' owner fields');
   if(scopeIds.has(so._context))assert.equal(n.scope,scopeIds.get(so._context),'shared context record identity');else scopeIds.set(so._context,n.scope);
   if(reverseScopes.has(n.scope))assert.equal(so._context,reverseScopes.get(n.scope),'distinct context record identities');else reverseScopes.set(n.scope,so._context);
  }
 };
 const make=(parents,transparent=false)=>{
  const before=b.nodes().length,programs=list(b.world.cleanupPrograms).length;
  const values=[b,s].map((r,i)=>{
   const expression={call:'capture',args:[{owner:true},{observer:true},own(transparent),{owner:true},{observer:true}]};
   return r.evaluate(parents?under(parents[i],expression):expression);
  });
  assert.equal(b.nodes().length,before+1,'createOwner allocates one owner');assert.equal(list(b.world.cleanupPrograms).length,programs,'createOwner creates no bound callback');
  return pair(...values);
 };
 try{
  for(const r of [b,s]){
   r.signal('x',0);r.memo('twice',{mul:[read('x'),lit(2)]});r.effect('view',read('twice'));r.signal('sameOwner',false);r.signal('sameObserver',false);
   r.program('capture',[['setExpr','sameOwner',{same:[arg(0),arg(3)]}],['setExpr','sameObserver',{same:[arg(1),arg(4)]}],['return',arg(2)]]);r.flush();
  }
  await assert.doesNotReject(()=>body({b,s,pairs,pair,make,compare}),'admitted direct-owner scenario '+name);compare();count++;
 }catch(error){console.error('FAILED direct owner: '+name);throw error;}
 finally{
  for(let i=pairs.length-1;i>=0;i--)for(const [j,r]of [b,s].entries())r.attempt('evaluate',dispose(pairs[i][j]));
  for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();
 }
}
for(const transparent of [false,true]){
 await scenario(`constructor does not schedule a tick ${transparent}`,async({b,s,pair,compare})=>{
  let scheduled=0;const original=globalThis.queueMicrotask;
  globalThis.queueMicrotask=callback=>{scheduled++;return original(callback);};
  try{pair(b.evaluate(own(transparent)),s.evaluate(own(transparent)));}finally{globalThis.queueMicrotask=original;}
  assert.equal(scheduled,0,'native owner construction schedules no microtask');
  assert.equal(b.world.scheduled,false,'Bend owner construction retains the idle queue');compare();
 });
}
for(const parent of ['detached','root','computed'])for(const transparent of [false,true]){
 await scenario(`ambient construction ${parent}/${transparent}`,async({b,s,pair,make,compare})=>{
  let owner;
  if(parent==='computed'){
   for(const r of [b,s])r.memo('maker',seq(read('x'),{call:'capture',args:[{owner:true},{observer:true},own(transparent),{owner:true},{observer:true}]}));
   owner=pair(b.read('maker'),s.read('maker'));
  }else owner=make(parent==='root'?[b.decode(b.encode({owner:'root'})),s.owner]:null,transparent);
  for(const r of [b,s]){r.flush();assert.equal(r.read('sameOwner'),true);assert.equal(r.read('sameObserver'),true);}
  compare();
  if(parent==='computed'){
   for(const r of [b,s]){r.set('x',1);r.flush();}
   const next=pair(b.read('maker'),s.read('maker'));assert.notEqual(next[0],owner[0]);
   for(const [i,r]of [b,s].entries())assert.equal(dead(r,owner[i]),true,'recompute disposes previous owned root');compare();
  }
 });
}
for(const attached of [false,true])for(const transparent of [false,true])for(const self of [false,true]){
 await scenario(`child clear and reuse ${attached}/${transparent}/${self}`,async({b,s,make,compare})=>{
  const parent=make(attached?[b.decode(b.encode({owner:'root'})),s.owner]:null,transparent),child=make(parent,!transparent);
  const getters=[b,s].map((r,i)=>r.evaluate(under(child[i],{memoAccessor:read('x')})));
  for(const [i,r]of [b,s].entries()){
   r.program('parentClean',[['emit',1]]);r.program('childClean',[['emit',2]]);
   r.evaluate(under(parent[i],{onCleanup:lit({callback:'parentClean'})}));r.evaluate(under(child[i],{onCleanup:lit({callback:'childClean'})}));r.flush();
  }
  compare();
  for(const [i,r]of [b,s].entries()){
   r.evaluate(dispose(parent[i],self));assert.equal(dead(r,parent[i]),self);assert.equal(dead(r,child[i]),true);
   assert.deepEqual(r.trace().filter(e=>e[0]==='cleanup').map(e=>e[2]),[2,1]);r.set('x',7);r.flush();assert.equal(r.evaluate({invoke:lit(getters[i])}),0,'dead child getter freezes');
  }
  compare();
  if(!self){
   const next=make(parent,false);
   for(const [i,r]of [b,s].entries()){
    r.program('next',[['emit',3]]);r.evaluate(under(next[i],{onCleanup:lit({callback:'next'})}));
    r.evaluate(dispose(parent[i],false));assert.equal(dead(r,next[i]),true);assert.equal(dead(r,parent[i]),false);
    r.evaluate(dispose(parent[i]));assert.equal(dead(r,parent[i]),true);assert.deepEqual(r.trace().filter(e=>e[0]==='cleanup').map(e=>e[2]),[2,1,3]);
   }
   compare();
  }
 });
}
for(const transparent of [false,true]){
 await scenario(`context snapshot/COW ${transparent}`,async({b,s,make,compare})=>{
  for(const r of [b,s])r.context('theme','fallback');
  const parent=make(null,transparent),before=make(parent,false);
  for(const [i,r]of [b,s].entries())r.evaluate({setContext:{name:'theme',value:lit('blue'),owner:lit(parent[i])}});
  const after=make(parent,true);
  for(const [i,r]of [b,s].entries()){
   assert.equal(r.evaluate({getContext:{name:'theme',owner:lit(before[i])}}),'fallback');
   assert.equal(r.evaluate({getContext:{name:'theme',owner:lit(after[i])}}),'blue');
   r.evaluate({setContext:{name:'theme',value:lit('red'),owner:lit(parent[i])}});
   r.evaluate({setContext:{name:'theme',value:lit('green'),owner:lit(before[i])}});
   assert.equal(r.evaluate({getContext:{name:'theme',owner:lit(parent[i])}}),'red');
   assert.equal(r.evaluate({getContext:{name:'theme',owner:lit(after[i])}}),'blue');
   assert.equal(r.evaluate({getContext:{name:'theme',owner:lit(before[i])}}),'green');r.flush();
  }
  compare();
 });
}
await scenario('cleanup registered during child-only disposal survives for next call',async({b,s,make,compare})=>{
 const parent=make();
 for(const [i,r]of [b,s].entries()){
  r.program('next',[['emit',2]]);r.program('first',[['emit',1],['eval',under(parent[i],{onCleanup:lit({callback:'next'})})]]);
  r.evaluate(under(parent[i],{onCleanup:lit({callback:'first'})}));r.flush();r.evaluate(dispose(parent[i],false));
  assert.deepEqual(r.trace().filter(e=>e[0]==='cleanup').map(e=>e[2]),[1]);r.evaluate(dispose(parent[i],false));
  assert.deepEqual(r.trace().filter(e=>e[0]==='cleanup').map(e=>e[2]),[1,2]);assert.equal(dead(r,parent[i]),false);
  r.evaluate(dispose(parent[i]));assert.equal(dead(r,parent[i]),true);
 }
 compare();
});
for(const transparent of [false,true])for(const self of [false,true]){
 await scenario(`throwing disposal ${transparent}/${self}`,async({b,s,make,compare})=>{
  const parent=make(null,transparent);
  for(const [i,r]of [b,s].entries()){
   r.program('fail',[['emit',7],['throw',{ref:8}]]);r.evaluate(under(parent[i],{onCleanup:lit({callback:'fail'})}));r.flush();
   assert.deepEqual(r.attempt('evaluate',dispose(parent[i],self)),['throw',{ref:8}]);assert.equal(dead(r,parent[i]),self);
   r.evaluate(dispose(parent[i],self));assert.equal(r.trace().filter(e=>e[0]==='cleanup').length,1,'throwing cleanup was detached');
   if(!self)r.evaluate(dispose(parent[i]));
  }
  compare();
 });
}
for(const transparent of [false,true]){
 await scenario(`explicit dead parent scope ${transparent}`,async({b,s,make,compare})=>{
  const parent=make();for(const [i,r]of [b,s].entries())r.evaluate(dispose(parent[i]));
  const child=make(parent,transparent);
  for(const [i,r]of [b,s].entries()){assert.equal(dead(r,parent[i]),true);assert.equal(dead(r,child[i]),false,'production createOwner has no dead-parent guard');r.flush();}
  compare();
 });
}
console.log(`${count} direct-owner histories preserve ambient context/tracking, root links, inherited records, child-only disposal, reuse and cleanup exceptions.`);
