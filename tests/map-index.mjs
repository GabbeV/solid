// mapArray's actual keyed:false engine; rows bind positions and expose item accessors.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument}),seq=(...seq)=>({seq}),fn=callback=>lit({callback}),select=(c,y,n)=>({select:[c,y,n]});
const arr=values=>({array:values.map(lit)}),invoke=get=>({invoke:lit(get)}),mapped=(list=read('items'),map=fn('row'),options={})=>({mapArray:{list,map,keyed:false,...options}});
let count=0;
async function scenario(name,body){
 const S=await import('../build/solid.mjs?mapindex='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),rs=[b,s],logs=[],pointers=new Map([[s.owner,1]]);
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
 }catch(error){original('FAILED mapArray index: '+name);throw error;}
 finally{for(const r of rs){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();console.error=original;}
}

for(const initial of [[],[1],[1,2,3]])for(const rows of ['accessor','value','memo','owner']){
 await scenario(`index retention/resize ${JSON.stringify(initial)}/${rows}`,async({rs,step,make,get,compare})=>{
  const rowValue=rows==='accessor'?arg(0):rows==='value'?invokeArg(0):rows==='memo'?{memoAccessor:invokeArg(0)}:{owner:true};
  for(const r of rs){r.program('rich',[['eval',{onCleanup:fn('clean')}],['return',rowValue]]);r.set('items',r.evaluate(arr(initial)));r.flush();}
  const getters=make(mapped(read('items'),fn('rich')));let previous=get(getters);
  for(const values of [[4,5,6],[6,5,4],[9],[7,8,9,10],[],[11,12]]){
   for(const r of rs)r.set('items',r.evaluate(arr(values)));step('flush');const next=get(getters);
   for(const i of [0,1]){
    if(values.length===previous[i].length)assert.strictEqual(next[i],previous[i],'equal length keeps mappings identity');
    if(rows==='accessor'||rows==='memo')for(const getter of next[i])rInvoke(rs[i],getter);
   }
   if(rows==='accessor'||rows==='memo'||rows==='owner')for(const i of [0,1])for(let j=0;j<Math.min(previous[i].length,next[i].length);j++)assert.strictEqual(previous[i][j],next[i][j],'positional row identity retained');
   compare();previous=next;
  }
  step('dispose');
 });
}
function invokeArg(index){return {invoke:arg(index)};}
function rInvoke(r,getter){return r.evaluate(invoke(getter));}
for(const fallback of [undefined,null,false,0,'',1,'empty',{array:[]}]){
 await scenario('empty fallback '+JSON.stringify(fallback),async({rs,step,make,get})=>{
  for(const r of rs)r.program('empty',[['eval',{onCleanup:fn('clean')}],['return',fallback?.array?fallback:lit(fallback)]]);
  const getters=make(mapped(seq(read('version'),read('items')),fn('row'),{fallback:{call:'empty'}}));const initial=get(getters);
  for(let n=1;n<=3;n++){step('set','version',n);step('flush');const next=get(getters);for(const i of [0,1])assert.strictEqual(next[i],initial[i]);}
  for(const r of rs)assert.equal(r.trace().filter(e=>e[0]==='cleanup').length,0,'successful falsy fallback stays mounted');
  for(const r of rs)r.set('items',r.evaluate(arr([1,2])));step('flush');get(getters);
  for(const r of rs)r.set('items',r.evaluate(arr([])));step('flush');get(getters);step('dispose');
 });
}
for(const initial of [false,true])for(const failAt of [0,1,3]){
 await scenario(`mapper throw/retry ${initial}/${failAt}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.signal('fail',initial);r.program('fallible',[['eval',{onCleanup:fn('clean')}],['return',select({same:[arg(1),lit(failAt)]},select(read('fail'),{raise:99},arg(0)),arg(0))]]);r.set('items',r.evaluate(arr(initial?[1,2,3,4]:[1])));r.flush();}
  const getters=make(mapped(seq(read('version'),read('items')),fn('fallible')));
  if(!initial){get(getters);step('set','fail',true);for(const r of rs)r.set('items',r.evaluate(arr([5,6,7,8])));step('flush');}
  for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();
  step('set','fail',false);step('set','version',1);step('flush');get(getters);step('dispose');
 });
}
for(const immediate of [false,true])for(const initial of [false,true])for(const fallback of [false,true]){
 await scenario(`pending row/fallback ${immediate}/${initial}/${fallback}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.future('p',{immediate});r.memo('data',{future:'p'});r.program('pending',[['eval',{onCleanup:fn('clean')}],['return',select({same:[arg(1),lit(2)]},read('data'),arg(0))]]);r.set('items',r.evaluate(arr(fallback?[]:initial?[1,2,3,4]:[1])));r.flush();}
  const getters=make(mapped(read('items'),fn('pending'),fallback?{fallback:seq({onCleanup:fn('clean')},read('data'))}:{}));
  if(!initial&&!fallback){get(getters);for(const r of rs)r.set('items',r.evaluate(arr([5,6,7,8])));step('flush');}
  for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();step('resolve','p',7);await setImmediate();compare();step('flush');get(getters);step('dispose');
 });
}
for(const initial of [[],[1,2],[1,2,3,4]])for(const fail of [false,true]){
 await scenario(`commit cleanup throws ${JSON.stringify(initial)}/${fail}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.signal('fail',false);r.program('explode',[['emit',12],['eval',select(read('fail'),{raise:77},lit(undefined))]]);r.program('badClean',[['eval',{onCleanup:fn('explode')}],['return',arg(0)]]);r.set('items',r.evaluate(arr(initial)));r.flush();}
  const getters=make(mapped(read('items'),fn('badClean'),{fallback:seq({onCleanup:fn('explode')},lit(1))}));get(getters);
  step('set','fail',fail);for(const r of rs)r.set('items',r.evaluate(arr(initial.length===0?[8,9]:initial.length===2?[]:[8])));step('flush');for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();
  step('resetErrorHalt');step('set','fail',false);step('dispose');
 });
}
for(const empty of [undefined,null,false,0,'']){
 await scenario('falsy list '+String(empty),async({rs,step,make,get})=>{
  const getters=make(mapped(seq(read('items'),lit(empty))));get(getters);for(const r of rs)r.set('items',r.evaluate(arr([1])));step('flush');get(getters);step('dispose');
 });
}
for(const many of [false,true])for(const local of [false,true]){
 await scenario(`factory capture ${many}/${local}`,async({rs,step,make,get})=>{
  for(const r of rs)r.program('factory',[['return',mapped(arg(many?7:0),fn('row'),{fallback:arg(many?8:1)})]]);
  const expr=local?{signalScope:{initial:arr([4,5]),body:mapped({localRead:0},fn('row'),{fallback:{localRead:0}})}}:{call:'factory',args:many?Array.from({length:9},(_,i)=>i===7?arr([4,5]):lit(i)): [arr([4,5]),lit('empty')]};
  const getters=make(expr),values=get(getters);for(const [i,r]of rs.entries())assert.deepEqual(values[i].map(getter=>rInvoke(r,getter)),[4,5]);step('dispose');
 });
}

for(const initial of [[],[1]])for(const cleanupThrows of [false,true]){
 await scenario(`abort cleanup error precedence ${JSON.stringify(initial)}/${cleanupThrows}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){r.signal('armed',false);r.program('abortCleanup',[['emit',44],['eval',cleanupThrows?{raise:55}:lit(undefined)]]);r.program('abortRow',[['eval',{onCleanup:fn('abortCleanup')}],['return',select(read('armed'),select({same:[arg(1),lit(2)]},{raise:99},arg(0)),arg(0))]]);r.set('items',r.evaluate(arr(initial)));r.flush();}
  const getters=make(mapped(seq(read('version'),read('items')),fn('abortRow')));get(getters);
  step('set','armed',true);for(const r of rs)r.set('items',r.evaluate(arr([5,6,7,8])));step('flush');
  for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();
  step('set','armed',false);step('set','version',1);step('flush');get(getters);
 });
}

for(const many of [false,true])for(const nested of [false,true]){
 await scenario(`action capture ${many}/${nested}`,async({rs,step,get,compare})=>{
  const parameter={actionArgument:nested?{depth:1,index:many?7:0}:many?7:0};
  const value=mapped(parameter,fn('row'),{fallback:{actionArgument:nested?{depth:1,index:many?8:1}:many?8:1}});
  const inner={actionCreate:{steps:[{next:{iteratorResult:{done:true,value}}}]}};
  const create={actionCreate:{steps:[{next:{iteratorResult:{done:true,value:nested?inner:value}}}]}};
  const actions=rs.map(r=>r.evaluate(create));compare();
  let getters=await Promise.all(rs.map((r,i)=>r.evaluate({invokeArgs:{callee:lit(actions[i]),args:many?Array.from({length:9},(_,j)=>j===7?arr([4,5]):lit(j)): [arr([4,5]),lit('empty')]}})));
  if(nested)getters=await Promise.all(rs.map((r,i)=>r.evaluate({invokeArgs:{callee:lit(getters[i]),args:[lit(100)]}})));
  await setImmediate();compare();const values=get(getters);for(const [i,r]of rs.entries())assert.deepEqual(values[i].map(getter=>rInvoke(r,getter)),[4,5]);compare();step('dispose');
 });
}
console.log(`${count} index-mode mapArray histories match native Solid values/row accessors, retained identity, row-signal state, owner trees, cleanup order, staged abort, pending retry, partial throws and successful falsy fallback retention.`);
