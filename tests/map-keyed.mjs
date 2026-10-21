// Actual plain identity-keyed mapArray engine, without index accessors.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument}),seq=(...seq)=>({seq}),fn=callback=>lit({callback}),select=(c,y,n)=>({select:[c,y,n]});
const arr=values=>({array:values.map(lit)}),invoke=get=>({invoke:lit(get)}),mapped=(list=read('items'),map=fn('row'),options={})=>({mapArray:{list,map,...options}});
let count=0;
async function scenario(name,body){
 const S=await import('../build/solid.mjs?mapkeyed='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),rs=[b,s],logs=[],pointers=new Map([[s.owner,1]]);
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
 }catch(error){original('FAILED mapArray keyed: '+name);throw error;}
 finally{for(const r of rs){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();console.error=original;}
}


const shapes=[[],[1],[1,2,3],[3,2,1],[1,1,2],[1,2,1],[2,1,1],[2,4],[4,1,2,3,5],[0,1,2,3],[1,2],[2,3],[1,3],[4,5,6]];
for(const initial of [[],[1,2,3],[1,2,1]])for(const value of ['scalar','row']){
 await scenario(`keyed window edits ${JSON.stringify(initial)}/${value}`,async({rs,step,make,get})=>{
  for(const r of rs){r.program('mapped',[['eval',{onCleanup:fn('clean')}],['return',value==='scalar'?arg(0):{array:[arg(0),{owner:true}]}]]);r.set('items',r.evaluate(arr(initial)));r.flush();}
  const getters=make(mapped(read('items'),fn('mapped')));get(getters);
  for(const shape of shapes){for(const r of rs)r.set('items',r.evaluate(arr(shape)));step('flush');get(getters);}
  step('dispose');
 });
}
for(const values of [[undefined,null,false,0,''],[NaN,1,NaN,2],[{ref:1},{ref:2},{ref:1}],[false,false,undefined,null]]){
 for(const mode of [undefined,true])await scenario('key identity '+JSON.stringify(values)+'/'+mode,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.program('rich',[['eval',{onCleanup:fn('clean')}],['return',{array:[arg(0),{owner:true},arg(1)]}]]);r.set('items',r.evaluate(arr(values)));r.flush();}
  const getters=make(mapped(read('items'),fn('rich'),mode===undefined?{}:{keyed:mode}));get(getters);
  for(const shape of [[...values].reverse(),values.slice(1),[...values,...values],values,[values[0],values[0]],[],values]){
   for(const r of rs)r.set('items',r.evaluate(arr(shape)));step('flush');const results=get(getters);for(const result of results)for(const row of result)assert.equal(row[2],undefined,'plain mapper receives no index accessor');compare();
  }
  step('dispose');
 });
}
for(const fallback of [undefined,null,false,0,'',1,'empty',{array:[]}]){
 await scenario('keyed fallback '+JSON.stringify(fallback),async({rs,step,make,get})=>{
  for(const r of rs)r.program('empty',[['eval',{onCleanup:fn('clean')}],['return',fallback?.array?fallback:lit(fallback)]]);
  const getters=make(mapped(seq(read('version'),read('items')),fn('row'),{fallback:{call:'empty'}}));const before=get(getters);
  for(let n=1;n<=3;n++){step('set','version',n);step('flush');const after=get(getters);for(const i of [0,1])assert.strictEqual(after[i],before[i]);}
  for(const r of rs)assert.equal(r.trace().filter(e=>e[0]==='cleanup').length,fallback?.array||fallback?0:3);
  for(const shape of [[1,2,3],[],[2,1]]){for(const r of rs)r.set('items',r.evaluate(arr(shape)));step('flush');get(getters);}step('dispose');
 });
}
for(const init of [[],[1,2,3]])for(const cleanupThrows of [false,true]){
 await scenario(`keyed abort/error ${JSON.stringify(init)}/${cleanupThrows}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.signal('armed',false);r.program('badClean',[['emit',44],['eval',cleanupThrows?{raise:55}:lit(undefined)]]);r.program('badRow',[['eval',{onCleanup:fn('badClean')}],['return',select(read('armed'),select({same:[arg(0),lit(9)]},{raise:99},{array:[arg(0),{owner:true}]}),{array:[arg(0),{owner:true}]})]]);r.set('items',r.evaluate(arr(init)));r.flush();}
  const getters=make(mapped(seq(read('version'),read('items')),fn('badRow')));get(getters);
  step('set','armed',true);for(const r of rs)r.set('items',r.evaluate(arr([3,8,1,9,7])));step('flush');for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();
  step('set','armed',false);step('set','version',1);step('flush');if(cleanupThrows&&init.length){for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();}else get(getters);
 });
}
for(const immediate of [false,true])for(const initial of [[],[1,2,3]]){
 await scenario(`keyed pending retry ${immediate}/${JSON.stringify(initial)}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.future('p',{immediate});r.memo('data',{future:'p'});r.program('pendingRow',[['eval',{onCleanup:fn('clean')}],['return',select({same:[arg(0),lit(9)]},read('data'),{array:[arg(0),{owner:true}]})]]);r.set('items',r.evaluate(arr(initial)));r.flush();}
  const getters=make(mapped(read('items'),fn('pendingRow')));get(getters);for(const r of rs)r.set('items',r.evaluate(arr([3,8,1,9,7])));step('flush');for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();step('resolve','p',7);await setImmediate();compare();step('flush');get(getters);step('dispose');
 });
}
for(const initial of [[1,2,3,4],[1,2,1,3]])for(const fail of [false,true]){
 await scenario(`keyed removal cleanup ${JSON.stringify(initial)}/${fail}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.signal('fail',false);r.program('explode',[['emit',12],['eval',select(read('fail'),{raise:77},lit(undefined))]]);r.program('rich',[['eval',{onCleanup:fn('explode')}],['return',{array:[arg(0),{owner:true}]}]]);r.set('items',r.evaluate(arr(initial)));r.flush();}
  const getters=make(mapped(read('items'),fn('rich')));get(getters);step('set','fail',fail);for(const r of rs)r.set('items',r.evaluate(arr([3,1])));step('flush');for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();step('resetErrorHalt');step('set','fail',false);step('dispose');
 });
}

const wide=Array.from({length:80},(_,i)=>i+1);
const wideShapes=[
 ['rotate-one',[...wide.slice(1),wide[0]]],
 ['rotate-five',[...wide.slice(5),...wide.slice(0,5)]],
 ['rotate-thirty-two',[...wide.slice(32),...wide.slice(0,32)]],
 ['remove-thirty-two',wide.filter((_,i)=>i>=31&&i!==75)],
 ['remove-thirty-three',wide.filter((_,i)=>i>=32&&i!==75)],
 ['rotate-thirty-three',[...wide.slice(33),...wide.slice(0,33)]],
 ['reverse',[...wide].reverse()],
 ['swap-far',wide.map((v,i)=>i===0?wide[70]:i===70?wide[0]:v)],
 ['interleaved',wide.filter((_,i)=>i%4!==0)],
 ['replace',wide.map(v=>v+100)],
 ['mixed',wide.map((v,i)=>i===0?999:i===70?wide[0]:v)],
 ['two-removals',wide.filter((_,i)=>i!==1&&i!==75)],
 ['swap-near',wide.map((v,i)=>i===0?wide[1]:i===1?wide[0]:i===75?wide[76]:i===76?wide[75]:v)]
];
for(const [shape,values]of wideShapes)for(const duplicate of [false,true]){
 await scenario(`wide fast/general ${shape}/${duplicate}`,async({rs,step,make,get})=>{
  const before=duplicate?wide.map(v=>v===41?1:v):wide,after=duplicate?values.map(v=>v===41?1:v):values;
  for(const r of rs){r.program('rich',[['eval',{onCleanup:fn('clean')}],['return',{array:[arg(0),{owner:true}]}]]);r.set('items',r.evaluate(arr(before)));r.flush();}
  const getters=make(mapped(read('items'),fn('rich')));get(getters);
  for(const values of [after,before]){for(const r of rs)r.set('items',r.evaluate(arr(values)));step('flush');get(getters);}step('dispose');
 });
}
for(const fail of [false,true]){
 await scenario('wide committed removal cleanup '+fail,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.signal('fail',false);r.program('explode',[['emit',12],['eval',select(read('fail'),{raise:77},lit(undefined))]]);r.program('rich',[['eval',{onCleanup:fn('explode')}],['return',{array:[arg(0),{owner:true}]}]]);r.set('items',r.evaluate(arr(wide)));r.flush();}
  const getters=make(mapped(read('items'),fn('rich')));get(getters);step('set','fail',fail);
  for(const r of rs)r.set('items',r.evaluate(arr(wide.filter((_,i)=>i%4!==0))));step('flush');for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();step('resetErrorHalt');step('set','fail',false);step('dispose');
 });
}
console.log(`${count} plain keyed mapArray histories match actual Solid occurrence matching, prefix/suffix identity, pure removals, growing/shrinking window commits, NaN/duplicate keys, mapper abort/retry and cleanup errors.`);
