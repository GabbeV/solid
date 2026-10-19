import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),call=call=>({call}),future=future=>({future});
const select=(c,y,n)=>({select:[c,y,n]}),add=(a,b)=>({add:[a,b]});
const arg=index=>({argument:index}),invoke=invoke=>({invoke}),current={owner:true};
const callWith=(call,...args)=>({call,args});
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?computed-accessors='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const original=console.error;console.error=(...args)=>logs.push(args);
  try{
    for(const [op,...args] of commands){
      if(process.env.DEBUG_NESTED)original(name,op,...args);
      if(op==='tick')await setImmediate();
      else{
        const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
        if(actual[0]==='return'&&wanted[0]==='return'&&!['read','set','update','future','root','evaluate'].includes(op))actual[1]=wanted[1]=undefined;
        assert.deepEqual(actual,wanted,`${name}: ${op} result`);
      }
      const known=new Map([[s.owner,1],...Object.entries(s.owners).map(([name,node])=>[node,b.ownerId(name)]),...s.sourceNames.entries()].map(([node,name])=>[node,typeof name==='number'?name:b.ids[name]]));
      for(const [node,id] of known){
        const n=b.nodes()[id];
        if(node._height!==undefined)assert.equal(n.height,node._height,`${name}: height of ${b.reverse[id]} after ${op}`);
        for(const [native,key] of [['_parent','parent'],['_firstChild','firstChild'],['_nextSibling','nextSibling'],['_prevSibling','prevSibling']]){
          if(!node[native])assert.equal(n[key],0,`${name}: null ${key} after ${op}`);
          else if(known.has(node[native]))assert.equal(n[key],known.get(node[native]),`${name}: ${key} alias after ${op}`);
          else assert.equal(b.nodes()[n[key]].kind.$,'Root',`${name}: anonymous ${key} is a root after ${op}`);
        }
      }
      for(const [local,binding] of s.localSignals??[]){
        const node=Object.getOwnPropertySymbols(binding.get).map(key=>binding.get[key]).find(value=>value&&typeof value==='object'&&'_pendingValue'in value);
        assert.ok(node,'actual accessor carries its source node');
        const n=b.nodes()[b.ids[local]];
        assert.equal(n.kind.$,'Signal',`${name}: actual signal allocation`);
        assert.equal(n.parent,0,`${name}: signals are unowned`);
        assert.equal(n.config,node._config,`${name}: local signal config`);
        assert.equal(n.equals,typeof node._equals==='function',`${name}: local comparator choice`);
        assert.equal(n.time,node._time,`${name}: local write time`);
        assert.deepEqual(b.errorShape(b.decode(n.value)),s.errorShape(node._value),`${name}: local committed value`);
        assert.equal('value'in n.pending,node._pendingValue!==s.localNotPending,`${name}: local staged presence`);
        if('value'in n.pending)assert.deepEqual(b.errorShape(b.decode(n.pending.value)),s.errorShape(node._pendingValue),`${name}: local staged value`);
      }
      const states=solidStates(s);
      assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: node state after ${op}`);
      assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
      assert.deepEqual(b.portEvents,s.portEvents,`${name}: promise results after ${op}`);
      assert.deepEqual(b.portSnapshots,s.portSnapshots,`${name}: observer screen after ${op}`);
      assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: escaping callback failures after ${op}`);
      for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
      assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],`${name}: ambient restoration`);
      const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
      assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports`);
    }
    count++;
  }catch(error){original('FAILED: '+name);throw error;}
  finally{b.attempt('dispose');s.attempt('dispose');b.resetErrorHalt();s.resetErrorHalt();b.attempt('flush');s.attempt('flush');await setImmediate();console.error=original;}
}

const memo=(memoAccessor,options={})=>({memoAccessor,options});
const seq=(...seq)=>({seq});
const capture=[['signal','saved',undefined],['program','save',[['updateExpr','saved',arg(0)]]]];
const get=()=>invoke(read('saved'));
for(const lazy of [false,true])for(const value of [undefined,null,false,true,0,7,NaN,'memo',{ref:3}]){
  await scenario('computed accessor escapes with lazy/value '+JSON.stringify({lazy,value}),[
    ...capture,['root','scope',callWith('save',memo(lit(value),{lazy}))],['flush'],
    ['evaluate',get()],['flush'],['evaluate',get()],['dispose']
  ]);
}
for(const lazy of [false,true])for(const sync of [false,true])for(const equals of [false,true]){
  await scenario('computed accessor tracks with options '+JSON.stringify({lazy,sync,equals}),[
    ['signal','input',1],...capture,['root','scope',callWith('save',memo(add(read('input'),lit(2)),{lazy,sync,equals}))],
    ['effect','view',get()],['flush'],['set','input',3],['flush'],['set','input',3],['flush'],
    ['set','input',7],['flush'],['dispose']
  ]);
}
for(const lazy of [false,true]){
  await scenario('disposed computed accessor serves its frozen value '+lazy,[
    ['signal','input',1],...capture,['root','scope',callWith('save',memo(add(read('input'),lit(2)),{lazy}))],
    ['effect','view',get()],['flush'],['set','input',3],['flush'],['disposeOwner','scope'],
    ['set','input',7],['flush'],['evaluate',get()],['flush'],['dispose']
  ]);
  await scenario('unobserved lazy accessor disposed before first call '+lazy,[
    ['signal','input',1],...capture,['root','scope',callWith('save',memo(read('input'),{lazy}))],['flush'],
    ['disposeOwner','scope'],['evaluate',get()],['set','input',4],['flush'],['evaluate',get()],['dispose']
  ]);
}
for(const lazy of [false,true])for(const untracked of [false,true]){
  await scenario('computed accessor preserves enclosing operands and tracking '+JSON.stringify({lazy,untracked}),[
    ['signal','input',1],...capture,['root','scope',callWith('save',memo(read('input'),{lazy}))],['flush'],
    ['memo','outer',add(lit(10),untracked?{untrack:get()}:get())],['effect','view',read('outer')],['flush'],
    ['set','input',4],['flush'],['set','input',7],['flush'],['dispose']
  ]);
}
for(const raw of [false,true]){
  await scenario('computed accessor as updater or stored function '+raw,[
    ['signal','input',1],['signal','target',0],...capture,
    ['root','scope',callWith('save',memo(add(read('input'),lit(5)),{lazy:true}))],['flush'],
    ...(raw?[['set','target',{accessor:'#nested1'}]]:[['update','target',read('saved')]]),['flush'],
    ['effect','view',raw?read('target'):invoke(read('target'))],['flush'],['set','input',4],['flush'],['dispose']
  ]);
}
for(const immediate of [false,true])for(const loading of [false,true]){
  await scenario('computed accessor carries actual pending flight '+JSON.stringify({immediate,loading}),[
    ...capture,['future','p',{immediate}],['root','scope',callWith('save',memo(future('p'),loading?{loadingValue:2}:{lazy:true}))],
    ['effect','view',get()],['flush'],['resolve','p',7],['tick'],['flush'],['evaluate',get()],['dispose']
  ]);
  await scenario('computed accessor carries actual rejected flight '+JSON.stringify({immediate,loading}),[
    ...capture,['future','p',{immediate}],['root','scope',callWith('save',memo(future('p'),loading?{loadingValue:2}:{lazy:true}))],
    ['flush'],['evaluate',get()],['reject','p',7],['tick'],['flush'],['evaluate',get()],['dispose']
  ]);
}
for(const lazy of [false,true]){
  await scenario('computed accessor synchronous error and recovery '+lazy,[
    ['signal','input',true],...capture,
    ['root','scope',callWith('save',memo(select(read('input'),lit(3),{raise:7}),{lazy}))],['flush'],
    ['evaluate',get()],['set','input',false],['flush'],['evaluate',get()],
    ['set','input',true],['flush'],['evaluate',get()],['dispose']
  ]);
}
await scenario('computed raw accessor updater captures target before a reentrant write',[
  ['signal','target',1],['program','compute',[['set','target',9],['return',lit(1)]]],...capture,
  ['root','scope',callWith('save',memo(call('compute'),{lazy:true}))],['flush'],
  ['set','target',{accessor:'#nested1'}],['flush'],['read','target'],['dispose']
]);
await scenario('parent reruns allocate distinct computed accessor closures',[
  ['signal','input',1],['signal','old',undefined],['program','save',[['updateExpr','old',arg(0)]]],
  ['memo','factory',seq(read('input'),memo(read('input'),{lazy:true}))],['flush'],
  ['evaluate',callWith('save',read('factory'))],['flush'],['effect','view',invoke(read('factory'))],['flush'],
  ['set','input',4],['flush'],['evaluate',{same:[read('factory'),read('old')]}],['evaluate',invoke(read('old'))],['dispose']
]);
for(const lazy of [false,true]){
  await scenario('computed accessor captures callback parameters '+lazy,[
    ...capture,['program','make',[['return',memo(add(arg(0),lit(2)),{lazy})]]],
    ['root','scope',callWith('save',callWith('make',lit(5)))],['flush'],['evaluate',get()],['flush'],['dispose']
  ]);
}
await scenario('computed accessor captures a local read and setter',[
  ...capture,['signal','input',1],['root','scope',{signalScope:{initial:lit(0),body:callWith('save',memo(seq(
    {invokeWith:{callee:{localSetter:0},value:read('input')}},{localRead:0}
  ),{lazy:true}))}}],['flush'],['effect','view',get()],['flush'],['set','input',4],['flush'],['dispose']
]);
console.log(`${count} computed-accessor histories match pinned TS construction, lazy pulls, identity, dependencies, pending/errors, raw updaters and lifetime.`);
{
  const b=new BendRuntime(),s=new SolidRuntime({module:await import('../build/solid.mjs?native-computed-accessor')});
  try{
    for(const runtime of [b,s])runtime.signal('input',1);
    const expr=memo(add(read('input'),lit(2)),{lazy:true});
    const bf=b.root('scope',expr),sf=s.root('scope',expr);
    assert.equal(typeof bf,'function');assert.equal(typeof sf,'function');
    assert.equal(bf,b.decode(b.encode(bf)));assert.equal(sf,s.value({accessor:'#nested1'}));
    assert.equal(bf(),sf());
    for(const runtime of [b,s]){runtime.set('input',4);runtime.flush();}
    assert.equal(bf(),sf());
    for(const runtime of [b,s]){runtime.disposeOwner('scope');runtime.set('input',7);runtime.flush();}
    assert.equal(bf(),6);assert.equal(sf(),6);
  }finally{for(const runtime of [b,s]){runtime.attempt('dispose');runtime.resetErrorHalt();runtime.attempt('flush');}}
}
