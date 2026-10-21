// Actual mapper Function.length metadata and identity-keyed index accessors.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument}),seq=(...seq)=>({seq}),fn=callback=>lit({callback}),select=(c,y,n)=>({select:[c,y,n]});
const arr=values=>({array:values.map(lit)}),invoke=get=>({invoke:lit(get)}),mapped=(list=read('items'),map=fn('row'),options={})=>({mapArray:{list,map,...options}});
let count=0;
async function scenario(name,body){
 const S=await import('../build/solid.mjs?mapindices='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),rs=[b,s],logs=[],pointers=new Map([[s.owner,1]]);
 const original=console.error;console.error=(...args)=>logs.push(args);
 const compare=()=>{
  const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,name+' computed nodes');
  assert.deepEqual(b.trace(),s.trace(),name+' callback/read/cleanup trace');assert.deepEqual(b.screen(),s.screen(),name+' screen');assert.deepEqual(b.asyncErrors,s.asyncErrors,name+' async errors');
  const nodes=b.nodes(),seen=new Set();
  for(const [row,label]of s.rowSources??[]){
   const target=nodes[b.ids[label]];assert.ok(target,name+' row signal allocated');
   assert.equal(target.config,row._config,name+' row config');assert.equal(target.time,row._time,name+' row clock');
   assert.deepEqual(b.observe(b.decode(target.value)),s.observe(row._value),name+' row committed value');
   const pending='value'in target.pending;assert.equal(pending,row._pendingValue!==s.notPending,name+' row pending presence');
   if(pending)assert.deepEqual(b.observe(b.decode(target.pending.value)),s.observe(row._pendingValue),name+' row pending value');
  }
  const pair=(id,node)=>{
   if(!node){assert.equal(id,0,name+' absent owner');return;}
   if(pointers.has(node))assert.equal(pointers.get(node),id,name+' owner identity');else pointers.set(node,id);
   if(seen.has(node))return;seen.add(node);
   const target=nodes[id];assert.ok(target,name+' allocated owner');
   pair(target.firstChild,node._firstChild);pair(target.nextSibling,node._nextSibling);pair(target.parent,node._parent);pair(target.parentComputed,node._parentComputed);
  };
  for(const [node,label]of s.sourceNames)pointers.set(node,b.ids[label]);
  for(const [label,node]of Object.entries(s.owners))pointers.set(node,label==='root'?1:b.ids[label]);
  for(const [node,label]of s.anonymousOwners){
   const entry=[...b.anonymousOwners].find(([,value])=>value===label);if(entry)pointers.set(node,entry[0]);
  }
  for(const [node,id]of [...pointers])pair(id,node);
  const ptr=node=>{if(node==null)return 0;assert.ok(pointers.has(node),name+' discoverable owner pointer');return pointers.get(node);};
  for(const [node,id]of pointers){
   const target=nodes[id];
   for(const [field,native]of [['parent','_parent'],['parentComputed','_parentComputed'],['firstChild','_firstChild'],['nextSibling','_nextSibling'],['prevSibling','_prevSibling']])assert.equal(target[field],ptr(node[native]),name+' owner '+field);
   assert.equal(target.flags,node._flags,name+' owner flags');assert.equal(target.config,node._config,name+' owner config');
   const d=target.disposal,sd=node._disposal;
   assert.equal('callbacks'in d?list(d.callbacks).length:'callback'in d?1:0,Array.isArray(sd)?sd.length:sd?1:0,name+' cleanup slots');
  }
  assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],name+' ambient restoration');
  assert.equal(S.getOwner(),null);
  const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
  assert.deepEqual(reports,logs.map(args=>args.map(value=>s.errorShape(value))),name+' reports');
 };
 const step=(op,...args)=>{
  const a=b.attempt(op,...args),e=s.attempt(op,...args);
  if(a[0]==='return'&&e[0]==='return'&&!['evaluate','read','set','update'].includes(op))a[1]=e[1]=undefined;
  assert.deepEqual(a,e,name+': '+op);compare();return a;
 };
 const make=(expr,owner='root')=>{
  const values=rs.map(r=>r.evaluate({withOwner:[lit({owner}),expr]}));assert.deepEqual(b.observe(values[0]),s.observe(values[1]));compare();return values;
 };
 const get=values=>{const result=rs.map((r,i)=>r.evaluate(invoke(values[i])));assert.deepEqual(b.observe(result[0]),s.observe(result[1]),name+' mapped values');compare();return result;};
 try{
  for(const r of rs){r.signal('items',r.evaluate(arr([])));r.signal('version',0);r.program('clean',[['emit',11]]);r.program('row',[['eval',{onCleanup:fn('clean')}],['return',arg(0)]]);}
  await body({b,s,rs,step,make,get,compare});compare();count++;
 }catch(error){original('FAILED mapArray indices: '+name);throw error;}
 finally{for(const r of rs){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();console.error=original;}
}



for(const arity of [0,1,2,9])for(const byIndex of [false,true]){
 await scenario(`function metadata ${arity}/${byIndex}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.program('formal',[['return',{array:[arg(0),arg(1),arg(8)]}]],arity);const value=r.evaluate(fn('formal'));assert.equal(value.length,arity,'canonical function exposes its source arity');assert.strictEqual(r.evaluate(fn('formal')),value);r.set('items',r.evaluate(arr([4,5])));r.flush();}
  const getters=make(mapped(read('items'),fn('formal'),byIndex?{keyed:false}:{}));let values=get(getters);
  for(const [i,r]of rs.entries())for(const [j,row]of values[i].entries()){
   assert.equal(row[2],undefined,'formal arity does not invent actual arguments');
   if(byIndex){assert.equal(row[1],j);assert.equal(r.evaluate(invoke(row[0])),j+4);}
   else if(arity>1){assert.equal(typeof row[1],'function');assert.equal(row[1].length,0);assert.equal(r.evaluate(invoke(row[1])),j);}
   else assert.equal(row[1],undefined);
  }
  compare();for(const r of rs)r.set('items',r.evaluate(arr([5,4,6])));step('flush');values=get(getters);
  for(const [i,r]of rs.entries())if(!byIndex&&arity>1)for(const [j,row]of values[i].entries())assert.equal(r.evaluate(invoke(row[1])),j);
  compare();step('dispose');
 });
}
for(const initial of [[],[1,2,3],[1,2,1]])for(const memo of [false,true]){
 await scenario(`indexed retained windows ${JSON.stringify(initial)}/${memo}`,async({rs,step,make,get,compare})=>{
  const pair={array:[arg(0),{invoke:arg(1)}]},value=memo?{memoAccessor:pair}:{array:[arg(0),arg(1),{owner:true}]};
  for(const r of rs){r.program('indexed',[['eval',{onCleanup:fn('clean')}],['return',value]],2);r.set('items',r.evaluate(arr(initial)));r.flush();}
  const getters=make(mapped(read('items'),fn('indexed')));get(getters);
  for(const shape of [[3,1,2,4],[4,3,1,2],[2,1],[1,2,1,3],[1,1,2],[4,5],[],[6,7]]){
   for(const r of rs)r.set('items',r.evaluate(arr(shape)));step('flush');const values=get(getters);
   for(const [i,r]of rs.entries())for(const [j,row]of values[i].entries())if(memo)assert.deepEqual(r.evaluate(invoke(row)),[shape[j],j]);else assert.equal(r.evaluate(invoke(row[1])),j);
   compare();
  }
  step('dispose');
 });
}
for(const immediate of [false,true])for(const initial of [[],[1,2,3]]){
 await scenario(`indexed pending stage ${immediate}/${JSON.stringify(initial)}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.future('p',{immediate});r.memo('data',{future:'p'});r.program('pendingIndex',[['eval',{onCleanup:fn('clean')}],['return',select({same:[arg(0),lit(9)]},read('data'),{array:[arg(0),arg(1)]})]],2);r.set('items',r.evaluate(arr(initial)));r.flush();}
  const getters=make(mapped(read('items'),fn('pendingIndex')));get(getters);for(const r of rs)r.set('items',r.evaluate(arr([3,8,1,9,7])));step('flush');for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();step('resolve','p',7);await setImmediate();compare();step('flush');const values=get(getters);
  for(const [i,r]of rs.entries())for(const [j,row]of values[i].entries())if(Array.isArray(row))assert.equal(r.evaluate(invoke(row[1])),j);compare();step('dispose');
 });
}
for(const fail of [false,true])for(const initial of [[1,2,3,4],[1,2,1,3]]){
 await scenario(`indexed removal cleanup ${fail}/${JSON.stringify(initial)}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.signal('fail',false);r.program('explode',[['emit',12],['eval',select(read('fail'),{raise:77},lit(undefined))]]);r.program('indexed',[['eval',{onCleanup:fn('explode')}],['return',{array:[arg(0),arg(1),{owner:true}]}]],2);r.set('items',r.evaluate(arr(initial)));r.flush();}
  const getters=make(mapped(read('items'),fn('indexed')));get(getters);step('set','fail',fail);for(const r of rs)r.set('items',r.evaluate(arr([3,1])));step('flush');for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();step('resetErrorHalt');step('set','fail',false);step('dispose');
 });
}
for(const shape of ['rotate','remove','reverse']){
 await scenario('indexed wide general path '+shape,async({rs,step,make,get,compare})=>{
  const old=Array.from({length:80},(_,i)=>i+1),next=shape==='rotate'?[...old.slice(1),old[0]]:shape==='remove'?old.filter((_,i)=>i%4!==0):old.slice().reverse();
  for(const r of rs){r.program('indexed',[['eval',{onCleanup:fn('clean')}],['return',{array:[arg(0),arg(1),{owner:true}]}]],2);r.set('items',r.evaluate(arr(old)));r.flush();}
  const getters=make(mapped(read('items'),fn('indexed')));get(getters);for(const r of rs)r.set('items',r.evaluate(arr(next)));step('flush');const values=get(getters);for(const [i,r]of rs.entries())for(const [j,row]of values[i].entries())assert.equal(r.evaluate(invoke(row[1])),j);compare();step('dispose');
 });
}
for(const formal of [0,2]){
 await scenario('mapper metadata captured once '+formal,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.signal('which',formal===2);r.program('short',[['return',{array:[arg(0),arg(1)]}]],0);r.program('long',[['return',{array:[arg(0),arg(1)]}]],2);r.set('items',r.evaluate(arr([1,2])));r.flush();}
  const getters=make(mapped(read('items'),select(read('which'),fn('long'),fn('short'))));get(getters);step('set','which',formal!==2);for(const r of rs)r.set('items',r.evaluate(arr([2,1,3])));step('flush');const values=get(getters);for(const [i,r]of rs.entries())for(const [j,row]of values[i].entries())if(formal===2)assert.equal(r.evaluate(invoke(row[1])),j);else assert.equal(row[1],undefined);compare();step('dispose');
 });
}
console.log(`${count} formal-arity/index-accessor histories match native Function.length, source mode selection, index identity/updates, nested memos, pending stages, cleanup errors and wide keyed updates.`);
