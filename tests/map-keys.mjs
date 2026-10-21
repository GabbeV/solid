// Actual extracted-key callbacks, item/index signals and failure return points.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument}),seq=(...seq)=>({seq}),fn=callback=>lit({callback}),select=(c,y,n)=>({select:[c,y,n]});
const arr=values=>({array:values.map(lit)}),invoke=get=>({invoke:lit(get)}),mapped=(list=read('items'),map=fn('row'),options={})=>({mapArray:{list,map,...options}});
const rows=values=>({array:values.map(value=>({array:value.map(lit)}))});
const at=(array,index)=>({arrayAt:{array,index:lit(index)}}),invokeArg=index=>({invoke:arg(index)});
let count=0;
async function scenario(name,body){
 const S=await import('../build/solid.mjs?mapkeys='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),rs=[b,s],logs=[],pointers=new Map([[s.owner,1]]);
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
 }catch(error){original('FAILED mapArray key functions: '+name);throw error;}
 finally{for(const r of rs){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();console.error=original;}
}



function keyProgram(r,{body=at(arg(0),0),count=false}={}){
 for(const [label,code]of [['one',1],['two',2],['three',3],['other',9]])r.program('key:'+label,[['emit',code]]);
 const item=at(arg(0),0),log=select({same:[item,lit(1)]},{call:'key:one'},select({same:[item,lit(2)]},{call:'key:two'},select({same:[item,lit(3)]},{call:'key:three'},{call:'key:other'})));
 if(count)r.signal('keyCalls',0,{ownedWrite:true});
 r.program('key',[['eval',log],...(count?[['updateExpr','keyCalls',{add:[{prev:true},lit(1)]}]]:[]),['return',body]],1);
}
const shapes=[[[1,11],[2,22],[3,33]],[[3,30],[1,10],[2,20],[4,40]],[[4,44],[3,33],[1,11],[2,22]],[[3,300],[1,100]],[[2,200],[1,100],[2,201]],[[1,1],[1,2],[2,2]],[],[[6,60],[7,70]]];
for(const arity of [0,1,2,9])for(const memo of [false,true]){
 await scenario(`keyed item/index windows ${arity}/${memo}`,async({rs,step,make,get,compare})=>{
  const pair={array:[invokeArg(0),arity>1?invokeArg(1):lit(undefined)]};
  for(const r of rs){keyProgram(r,{count:true});r.program('rich',[['eval',{onCleanup:fn('clean')}],['return',memo?{memoAccessor:pair}:{array:[arg(0),arg(1),{owner:true}]}]],arity);r.set('items',r.evaluate(rows([[1,10],[2,20],[3,30]])));r.flush();}
  const getters=make(mapped(read('items'),fn('rich'),{keyed:fn('key')}));const initial=get(getters);for(const r of rs)assert.equal(r.read('keyCalls'),0,'create-all never calls key');
  let before=initial;
  for(const [n,values]of shapes.entries()){
   for(const r of rs)r.set('items',r.evaluate(rows(values)));step('flush');const after=get(getters);
   if(n===0)for(const i of [0,1])assert.strictEqual(after[i],before[i],'same keys retain mapped array despite fresh item objects');
   for(const [i,r]of rs.entries())for(const [j,row]of after[i].entries()){
    if(memo)assert.deepEqual(r.evaluate(invoke(row)),[values[j],arity>1?j:undefined]);
    else{assert.deepEqual(r.evaluate(invoke(row[0])),values[j]);if(arity>1)assert.equal(r.evaluate(invoke(row[1])),j);else assert.equal(row[1],undefined);}
   }
   assert.equal(rs[0].read('keyCalls'),rs[1].read('keyCalls'));compare();before=after;
  }
  step('dispose');
 });
}
for(const key of [undefined,null,false,0,'',NaN,{ref:3}])for(const arity of [1,2]){
 await scenario('falsy/duplicate extracted key '+String(key)+'/'+arity,async({rs,step,make,get,compare})=>{
  for(const r of rs){keyProgram(r,{body:lit(key)});r.program('rich',[['eval',{onCleanup:fn('clean')}],['return',{array:[arg(0),arg(1),{owner:true}]}]],arity);r.set('items',r.evaluate(rows([[1,10],[2,20],[3,30]])));r.flush();}
  const getters=make(mapped(read('items'),fn('rich'),{keyed:fn('key')}));get(getters);
  for(const values of [[[3,31],[2,21],[1,11]],[[4,40],[5,50]],[[6,60],[7,70],[8,80]],[]]){
   for(const r of rs)r.set('items',r.evaluate(rows(values)));step('flush');const result=get(getters);for(const [i,r]of rs.entries())for(const [j,row]of result[i].entries())assert.deepEqual(r.evaluate(invoke(row[0])),values[j]);compare();
  }
  step('dispose');
 });
}
for(const initial of [[[1,10],[2,20],[3,30]],[[1,10],[2,20],[1,11],[3,30]]])for(const next of [[[2,22],[3,33]],[[2,22],[1,11]],[[2,22],[4,44]],[[3,33],[2,22],[1,11],[4,44]]]){
 await scenario(`key call order removal/map ${JSON.stringify(initial)}/${JSON.stringify(next)}`,async({rs,step,make,get,compare})=>{
  for(const r of rs){keyProgram(r,{count:true});r.program('rich',[['eval',{onCleanup:fn('clean')}],['return',{array:[arg(0),arg(1),{owner:true}]}]],2);r.set('items',r.evaluate(rows(initial)));r.flush();}
  const getters=make(mapped(read('items'),fn('rich'),{keyed:fn('key')}));get(getters);for(const r of rs)r.set('items',r.evaluate(rows(next)));step('flush');get(getters);assert.equal(rs[0].read('keyCalls'),rs[1].read('keyCalls'));compare();step('dispose');
 });
}
for(const failure of [1,2,3])for(const next of [[[1,11],[2,22],[3,33]],[[3,33],[2,22]],[[4,44],[3,33],[1,11],[2,22]]]){
 await scenario(`throwing key ${failure}/${JSON.stringify(next)}`,async({rs,step,make,get,compare})=>{
  const item=at(arg(0),0);
  for(const r of rs){r.signal('fail',false);keyProgram(r,{body:select({same:[item,lit(failure)]},select(read('fail'),{raise:77},item),item)});r.program('rich',[['eval',{onCleanup:fn('clean')}],['return',{array:[arg(0),arg(1),{owner:true}]}]],2);r.set('items',r.evaluate(rows([[1,10],[2,20],[3,30]])));r.flush();}
  const getters=make(mapped(seq(read('version'),read('items')),fn('rich'),{keyed:fn('key')}));get(getters);step('set','fail',true);for(const r of rs)r.set('items',r.evaluate(rows(next)));step('flush');for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();step('set','fail',false);step('set','version',1);step('flush');get(getters);step('dispose');
 });
}
for(const immediate of [false,true])for(const next of [[[1,11],[2,22],[3,33]],[[3,33],[2,22]],[[4,44],[3,33],[1,11],[2,22]]]){
 await scenario(`pending key ${immediate}/${JSON.stringify(next)}`,async({rs,step,make,get,compare})=>{
  const item=at(arg(0),0);
  for(const r of rs){r.future('p',{immediate});r.memo('data',{future:'p'});keyProgram(r,{body:select({same:[item,lit(2)]},read('data'),item)});r.program('rich',[['eval',{onCleanup:fn('clean')}],['return',{array:[arg(0),arg(1),{owner:true}]}]],2);r.set('items',r.evaluate(rows([[1,10],[2,20],[3,30]])));r.flush();}
  const getters=make(mapped(read('items'),fn('rich'),{keyed:fn('key')})),prior=get(getters);for(const r of rs)r.set('items',r.evaluate(rows(next)));step('flush');for(const [i,r]of rs.entries())r.attempt('evaluate',invoke(getters[i]));compare();
  for(const [i,r]of rs.entries())r.evaluate(invoke(prior[i][0][0]));compare();step('resolve','p',2);await setImmediate();compare();step('flush');get(getters);step('dispose');
 });
}
for(const stateful of [false,true]){
 await scenario('stateful key values '+stateful,async({rs,step,make,get,compare})=>{
  for(const r of rs){keyProgram(r,{count:true,body:stateful?read('keyCalls'):at(arg(0),0)});r.program('rich',[['eval',{onCleanup:fn('clean')}],['return',{array:[arg(0),arg(1),{owner:true}]}]],2);r.set('items',r.evaluate(rows([[1,10],[2,20],[3,30]])));r.flush();}
  const getters=make(mapped(read('items'),fn('rich'),{keyed:fn('key')}));get(getters);
  for(const values of [[[2,22],[3,33]],[[3,333],[1,111],[4,444]],[[1,11],[2,22],[1,12]],[[3,3],[2,2]]]){for(const r of rs)r.set('items',r.evaluate(rows(values)));step('flush');get(getters);assert.equal(rs[0].read('keyCalls'),rs[1].read('keyCalls'));compare();}step('dispose');
 });
}
for(const many of [false,true]){
 await scenario('captured key function '+many,async({rs,step,make,get})=>{
  for(const r of rs){keyProgram(r);r.program('rich',[['return',{array:[arg(0),arg(1)]}]],2);r.program('factory',[['return',mapped(read('items'),fn('rich'),{keyed:arg(many?7:0)})]]);r.set('items',r.evaluate(rows([[1,10],[2,20]])));r.flush();}
  const getters=make({call:'factory',args:many?Array.from({length:9},(_,i)=>i===7?fn('key'):lit(i)): [fn('key')]});get(getters);for(const r of rs)r.set('items',r.evaluate(rows([[2,22],[1,11],[3,33]])));step('flush');get(getters);step('dispose');
 });
}

await scenario('raw item identity skips key callbacks',async({rs,step,make,get,compare})=>{
 const values=rs.map(r=>r.evaluate(rows([[1,10],[2,20]])));
 for(const [i,r]of rs.entries()){keyProgram(r,{count:true});r.program('rich',[['return',{array:[arg(0),arg(1)]}]],2);r.set('items',values[i]);r.flush();}
 const getters=make(mapped(read('items'),fn('rich'),{keyed:fn('key')}));const before=get(getters);
 for(const [i,r]of rs.entries())r.set('items',r.evaluate({array:values[i].map(lit)}));step('flush');const after=get(getters);for(const i of [0,1]){assert.strictEqual(after[i],before[i]);assert.equal(rs[i].read('keyCalls'),0);}compare();step('dispose');
});
await scenario('mapper expression precedes keyed expression',async({rs,step,make,get})=>{
 for(const r of rs){keyProgram(r);r.program('rich',[['return',{array:[arg(0),arg(1)]}]],2);r.program('makeMapper',[['emit',101],['return',fn('rich')]]);r.program('makeKey',[['emit',102],['return',fn('key')]]);r.set('items',r.evaluate(rows([[1,10],[2,20]])));r.flush();}
 const getters=make(mapped(read('items'),{call:'makeMapper'},{keyed:{call:'makeKey'}}));get(getters);
 for(const r of rs)assert.deepEqual(r.trace().filter(e=>e[0]==='cleanup').slice(0,2).map(e=>e[2]),[101,102]);step('dispose');
});
for(const nested of [false,true]){
 await scenario('action-captured key '+nested,async({rs,step,get,compare})=>{
  for(const r of rs){keyProgram(r);r.program('rich',[['return',{array:[arg(0),arg(1)]}]],2);r.set('items',r.evaluate(rows([[1,10],[2,20]])));r.flush();}
  const value=mapped(read('items'),fn('rich'),{keyed:{actionArgument:nested?{depth:1,index:0}:0}}),inner={actionCreate:{steps:[{next:{iteratorResult:{done:true,value}}}]}},plan={actionCreate:{steps:[{next:{iteratorResult:{done:true,value:nested?inner:value}}}]}};
  const fns=rs.map(r=>r.evaluate(plan));let getters=await Promise.all(rs.map((r,i)=>r.evaluate({invokeArgs:{callee:lit(fns[i]),args:[fn('key')]}})));
  if(nested)getters=await Promise.all(rs.map((r,i)=>r.evaluate({invokeArgs:{callee:lit(getters[i]),args:[]}})));
  await setImmediate();get(getters);compare();for(const r of rs)r.set('items',r.evaluate(rows([[2,22],[1,11],[3,33]])));step('flush');get(getters);step('dispose');
 });
}
console.log(`${count} extracted-key mapArray histories match actual Solid item/index accessors, duplicate/falsy keys, exact key-call traces, cached removal keys, stateful writes, key errors/pending retries and captured key functions.`);
