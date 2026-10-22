// Actual public repeat/count/from/fallback, through the shared core machine.
// Full native computed state and ordered owner trees support correspondence.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument}),seq=(...seq)=>({seq}),fn=callback=>lit({callback}),select=(c,y,n)=>({select:[c,y,n]});
const repeat=(count,map=fn('row'),options={})=>({repeat:{count,map,...options}}),invoke=get=>({invoke:lit(get)});
let count=0;
async function scenario(name,body){
 const S=await import('../build/solid.mjs?repeat='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),rs=[b,s],logs=[],pointers=new Map([[s.owner,1]]);
 const original=console.error;console.error=(...args)=>logs.push(args);
 const compare=()=>{
  const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,name+' computed nodes');
  assert.deepEqual(b.trace(),s.trace(),name+' callback/read/cleanup trace');assert.deepEqual(b.screen(),s.screen(),name+' screen');assert.deepEqual(b.asyncErrors,s.asyncErrors,name+' async errors');
  const nodes=b.nodes(),seen=new Set();
  const pair=(id,node)=>{
   if(!node){assert.equal(id,0,name+' absent owner');return;}
   if(pointers.has(node))assert.equal(pointers.get(node),id,name+' owner identity');else pointers.set(node,id);
   if(seen.has(node))return;seen.add(node);
   const target=nodes[id];assert.ok(target,name+' allocated owner');
   pair(target.firstChild,node._firstChild);pair(target.nextSibling,node._nextSibling);
  };
  for(const [node,label]of s.sourceNames)pointers.set(node,b.ids[label]);
  for(const [label,node]of Object.entries(s.owners))pointers.set(node,label==='root'?1:b.ids[label]);
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
  for(const r of rs){r.signal('count',0);r.signal('from',0);r.signal('version',0);r.program('clean',[['emit',11]]);r.program('row',[['eval',{onCleanup:fn('clean')}],['return',arg(0)]]);}
  await body({b,s,rs,step,make,get,compare});compare();count++;
 }catch(error){original('FAILED repeat: '+name);throw error;}
 finally{for(const r of rs){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();console.error=original;}
}
for(const initial of [0,1,3])for(const from of [0,2,7]){
 await scenario(`window growth/shrink/shift ${initial}/${from}`,async({rs,step,make,get})=>{
  for(const r of rs){r.set('count',initial);r.set('from',from);r.flush();}
  const getters=make(repeat(read('count'),fn('row'),{from:read('from')}));let previous=get(getters);
  for(const [key,value]of [['count',5],['from',1],['from',9],['count',2],['from',0],['count',0],['from',7],['count',3]]){
   step('set',key,value);step('flush');const current=get(getters);
   if(current[0].length&&previous[0].length)for(const i of [0,1])assert.notStrictEqual(current[i],previous[i],'nonempty pass returns a fresh array');previous=current;
  }
  step('dispose');
 });
}
for(const fallback of [undefined,null,false,0,'',1,'empty',{array:[]}]){
 await scenario('empty fallback retention '+JSON.stringify(fallback),async({rs,step,make,get})=>{
  for(const r of rs)r.program('empty',[['eval',{onCleanup:fn('clean')}],['return',fallback?.array?fallback:lit(fallback)]]);
  const getters=make(repeat(seq(read('version'),read('count')),fn('row'),{fallback:{call:'empty'}}));const initial=get(getters);
  for(let n=1;n<=3;n++){step('set','version',n);step('flush');const next=get(getters);for(const i of [0,1])assert.strictEqual(next[i],initial[i],'empty mapping array identity is retained');}
  const expected=0;
  for(const r of rs)assert.equal(r.trace().filter(e=>e[0]==='cleanup').length,expected,'merged falsy-fallback retention is preserved');
  step('set','count',2);step('flush');get(getters);step('set','count',0);step('flush');get(getters);step('dispose');
 });
}
for(const rowValue of [lit(false),lit(undefined),{array:[arg(0)]},{owner:true},{memoAccessor:arg(0)}]){
 await scenario('retained row identity '+JSON.stringify(rowValue),async({rs,step,make,get})=>{
  for(const r of rs){r.program('rich',[['eval',{onCleanup:fn('clean')}],['return',rowValue]]);r.set('count',4);r.flush();}
  const getters=make(repeat(read('count'),fn('rich'),{from:read('from')})),before=get(getters);
  step('set','from',1);step('flush');const next=get(getters);
  for(const i of [0,1])for(let j=0;j<3;j++)assert.strictEqual(next[i][j],before[i][j+1],'overlap retains mapped values/owners/functions');
  step('set','count',2);step('flush');get(getters);step('dispose');
 });
}
for(const failAt of [0,1,3])for(const first of [false,true]){
 await scenario(`throwing mapper abort/retry ${failAt}/${first}`,async({rs,step,make,get})=>{
  for(const r of rs){r.signal('fail',first);r.program('fallible',[['eval',{onCleanup:fn('clean')}],['return',select({same:[arg(0),lit(failAt)]},select(read('fail'),{raise:99},arg(0)),arg(0))]]);r.set('count',first?4:1);r.flush();}
  const getters=make(repeat(seq(read('version'),read('count')),fn('fallible'),{from:read('from')}));
  if(!first){get(getters);step('set','fail',true);step('set','from',failAt);step('set','count',4);step('flush');}
  for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));
  step('set','fail',false);step('set','version',1);step('flush');get(getters);step('dispose');
 });
}
for(const immediate of [false,true])for(const first of [false,true])for(const fallback of [false,true]){
 await scenario(`pending mapper/fallback retries ${immediate}/${first}/${fallback}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.future('p',{immediate});r.memo('data',{future:'p'});r.program('pending',[['eval',{onCleanup:fn('clean')}],['return',select({same:[arg(0),lit(2)]},read('data'),arg(0))]]);r.set('count',fallback?0:first?4:1);r.flush();}
  const getters=make(repeat(read('count'),fn('pending'),fallback?{fallback:seq({onCleanup:fn('clean')},read('data'))}:{}));
  if(!first&&!fallback){get(getters);step('set','count',4);step('flush');}
  for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();
  step('resolve','p',7);await setImmediate();compare();step('flush');get(getters);step('dispose');
 });
}
for(const init of [0,2])for(const fail of [false,true]){
 await scenario(`teardown error keeps partial commit ${init}/${fail}`,async({rs,step,make,get})=>{
  for(const r of rs){r.signal('fail',false);r.program('explode',[['emit',12],['eval',select(read('fail'),{raise:77},lit(undefined))]]);r.program('badClean',[['eval',{onCleanup:fn('explode')}],['return',arg(0)]]);r.set('count',init);r.flush();}
  const getters=make(repeat(read('count'),fn('badClean'),{fallback:seq({onCleanup:fn('explode')},lit(1))}));get(getters);
  step('set','fail',fail);step('set','count',init?0:2);step('flush');for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));
  step('resetErrorHalt');step('set','fail',false);step('set','version',1);step('dispose');
 });
}

for(const detached of [false,true])for(const from of [0,3]){
 await scenario(`detached/owned entry ${detached}/${from}`,async({rs,step,make,get})=>{
  for(const r of rs){r.set('count',2);r.set('from',from);r.flush();}
  const getters=detached?rs.map(r=>r.evaluate(repeat(read('count'),fn('row'),{from:read('from')}))):make(repeat(read('count'),fn('row'),{from:read('from')}));
  get(getters);step('set','count',3);step('flush');get(getters);step('set','count',0);step('flush');get(getters);step('dispose');
 });
}
for(const many of [false,true])for(const nested of [false,true]){
 await scenario(`callback/local capture ${many}/${nested}`,async({rs,step,make,get})=>{
  for(const r of rs)r.program('factory',[['return',repeat(arg(many?7:0),fn('row'),{from:arg(many?8:1),fallback:arg(2)})]]);
  const expr={call:'factory',args:many?Array.from({length:9},(_,i)=>lit(i===7?3:i===8?7:i)): [lit(3),lit(7),lit('empty')]};
  const getters=make(nested?{signalScope:{initial:lit(9),body:repeat({localRead:0},fn('row'),{from:seq({localRead:0},lit(4)),fallback:{localRead:0}})}}:expr);
  const values=get(getters);for(const result of values)assert.deepEqual(result,nested?Array.from({length:9},(_,i)=>i+4):[7,8,9]);step('dispose');
 });
}
for(const offset of [0,2]){
 await scenario(`nested repeat accessors ${offset}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.program('inner',[['return',repeat(arg(0),fn('row'),{from:arg(0)})]]);r.set('count',3);r.set('from',offset);r.flush();}
  const getters=make(repeat(read('count'),fn('inner'),{from:read('from')}));const before=get(getters);
  for(const [i,r]of rs.entries())for(const get of before[i])r.evaluate(invoke(get));compare();
  step('set','from',offset+1);step('flush');const after=get(getters);
  for(const i of [0,1])assert.strictEqual(after[i][0],before[i][1]);step('set','count',0);step('flush');get(getters);step('dispose');
 });
}
for(const stage of ['row','fallback','from','count']){
 await scenario('tracking posture '+stage,async({rs,step,make,get})=>{
  for(const r of rs){r.signal('data',7);r.program('tracking',[['return',{array:[arg(0),{owner:true},{observer:true},read('data')]}]]);r.set('count',stage==='fallback'?0:2);r.flush();}
  const getters=make(repeat(stage==='count'?seq(read('data'),read('count')):read('count'),stage==='row'?fn('tracking'):fn('row'),{from:stage==='from'?read('data'):read('from'),...(stage==='fallback'?{fallback:seq(read('data'),lit(1))}:{})}));
  const before=get(getters);step('set','data',8);step('flush');const after=get(getters);
  if(stage==='row'){for(const result of after)for(const row of result)assert.equal(row[2],null,'row callback is untracked');}
  else if(stage==='fallback')for(const i of [0,1])assert.strictEqual(before[i],after[i],'truthy fallback keeps its array');
  step('dispose');
 });
}
console.log(`${count} repeat histories match pinned TS count/offset windows, values/array identity, owner trees, retained rows, cleanup order, staged abort/retry, pending/error recovery and the successful falsy fallback retention.`);
