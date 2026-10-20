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
  const module=await import('../build/solid.mjs?setters='+count);
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

const scope=(initial,body,options={})=>({signalScope:{initial,body,options}});
const seq=(...seq)=>({seq});
const localRead=depth=>({localRead:depth});
const write=(value,{depth=0,updater=false}={})=>({localWrite:{depth,value,updater}});
for(const equals of [false,true])for(const staged of [false,true]){
  await scenario('updater equality uses the entry slot '+JSON.stringify({equals,staged}),[
    ['signal','value',1,{equals}],['program','rewrite',[['set','value',9],['return',lit(staged?3:1)]]],
    ...(staged?[['set','value',3]]:[]),['update','value',call('rewrite')],['flush'],['read','value'],['dispose']
  ]);
  await scenario('callback updater retains its entry slot '+JSON.stringify({equals,staged}),[
    ['signal','value',1,{equals}],['program','rewrite',[['set','value',9],['return',lit(staged?3:1)]]],
    ['program','update',[['updateExpr','value',call('rewrite')]]],
    ...(staged?[['set','value',3]]:[]),['evaluate',call('update')],['flush'],['read','value'],['dispose']
  ]);
}
await scenario('throwing updater retains nested writes',[
  ['signal','value',1],['program','rewrite',[['set','value',9],['throw',7]]],
  ['update','value',call('rewrite')],['flush'],['read','value'],['dispose']
]);
for(const teardown of [false,true]){
  await scenario('bound disposer updater retains entry equality '+teardown,[
    ['signal','value',undefined],['program','write',[['set','value',9]]],
    ['program','attach',[['cleanup','write'],['return',arg(0)]]],
    ['root','target',callWith('attach',arg(0)),{owner:null}],
    ...(teardown?[
      ['program','outer',[['set','value',{rootDisposer:'target'}]]],
      ['program','attachOuter',[['cleanup','outer']]],['root','outer',call('attachOuter')],['disposeOwner','outer']
    ]:[['set','value',{rootDisposer:'target'}]]),['flush'],['read','value'],['dispose']
  ]);
}
console.log(`${count} reentrant-setter histories match pinned TS entry-value capture, nested writes, returns and throws.`);
const setter=depth=>({localSetter:depth}),accessor=depth=>({localAccessor:depth});
const invokeWith=(callee,value={lit:undefined},updater=false)=>({invokeWith:{callee,value,updater}});
const capture=[['signal','saved',undefined],['program','save',[['updateExpr','saved',arg(0)]]]];
const setterStart=count;
for(const value of [undefined,null,false,true,0,7,NaN,'text',{ref:2},{owner:'root'},{error:4,kind:'Error',message:'data'}]){
  await scenario('escaped setter retains its unowned target '+String(value),[
    ...capture,['root','scope',scope(lit(1),callWith('save',setter(0)))],['flush'],['disposeOwner','scope'],
    ['evaluate',invokeWith(read('saved'),lit(value))],['flush'],['evaluate',invoke(lit({accessor:'#nested1'}))],['dispose']
  ]);
}
for(const equals of [false,true])for(const ownedWrite of [false,true])for(const noSnapshot of [false,true]){
  await scenario('escaped updater composes on staging '+JSON.stringify({equals,ownedWrite,noSnapshot}),[
    ...capture,['root','scope',scope(lit(1),seq(callWith('save',setter(0)),
      invokeWith(setter(0),add({prev:true},lit(2)),true),invokeWith(setter(0),add({prev:true},lit(3)),true)
    ),{equals,ownedWrite,noSnapshot})],['flush'],
    ['evaluate',invokeWith(read('saved'),add({prev:true},lit(5)),true)],['flush'],
    ['evaluate',invoke(lit({accessor:'#nested1'}))],['dispose']
  ]);
}
for(const data of ['disposer','accessor','setter']){
  await scenario('escaped setter stores returned function data '+data,[
    ...capture,['root','target',arg(0),{owner:null}],['root','scope',scope(lit(1),seq(
      callWith('save',setter(0)),invokeWith(setter(0),data==='disposer'?lit({rootDisposer:'target'}):data==='accessor'?accessor(0):setter(0),true)
    ))],['flush'],['evaluate',invoke(lit({accessor:'#nested1'}))],
    ['evaluate',{disposed:lit({owner:'target'})}],['dispose']
  ]);
}
for(const source of ['named','local']){
  await scenario('raw setter updater invokes its bound target '+source,[
    ['signal','outer',3],['signal','inner',2],...capture,
    ['root','scope',scope(lit(1),callWith('save',setter(0)))],['flush'],
    ['set','outer',{setter:source==='named'?'inner':'#nested1'}],['flush'],['read','outer'],
    ['evaluate',invoke(lit({accessor:source==='named'?'inner':'#nested1'}))],['dispose']
  ]);
}
await scenario('zero argument setter invocation clears the value',[
  ...capture,['root','scope',scope(lit(8),callWith('save',setter(0)))],['flush'],
  ['evaluate',invoke(read('saved'))],['flush'],['evaluate',invoke(lit({accessor:'#nested1'}))],['dispose']
]);
await scenario('setter and accessor are distinct functions for the same signal',[
  ['root','scope',scope(lit(1),{same:[setter(0),accessor(0)]})],['flush'],['dispose']
]);
await scenario('same local setter has stable function identity',[
  ['root','scope',scope(lit(1),{same:[setter(0),setter(0)]})],['flush'],['dispose']
]);
await scenario('shadowed setters retain their respective targets',[
  ['root','scope',scope(lit(1),scope(lit(2),seq(invokeWith(setter(1),lit(7)),invokeWith(setter(0),lit(9)))))],
  ['flush'],['evaluate',add(invoke(lit({accessor:'#nested1'})),invoke(lit({accessor:'#nested2'})))],['dispose']
]);
for(const user of [false,true]){
  await scenario('retained setter body updates a surviving render '+user,[
    ['signal','input',1],...capture,['root','scope',scope(lit(0),seq(
      callWith('save',setter(0)),{effectCreate:read('input'),body:invokeWith(setter(0),arg(0)),options:{user}}
    ))],['effect','view',invoke(lit({accessor:'#nested1'}))],['flush'],
    ['set','input',4],['flush'],['set','input',6],['flush'],['dispose']
  ]);
}
await scenario('callee resolves before argument side effects',[
  ['signal','old',0],['signal','next',0],['signal','which',undefined],
  ['program','switch',[['updateExpr','which',lit({setter:'next'})],['return',lit(7)]]],
  ['update','which',lit({setter:'old'})],['flush'],
  ['evaluate',invokeWith(read('which'),call('switch'))],['flush'],['read','old'],['read','next'],['dispose']
]);
await scenario('callee evaluation side effects precede argument evaluation',[
  ['signal','target',0],['signal','order',0],
  ['program','callee',[['set','order',1],['return',lit({setter:'target'})]]],
  ['program','argument',[['updateExpr','order',add({prev:true},lit(10))],['return',lit(7)]]],
  ['evaluate',invokeWith(call('callee'),call('argument'))],['flush'],['read','order'],['read','target'],['dispose']
]);
await scenario('throwing argument skips setter but keeps earlier writes',[
  ['signal','target',0],['signal','order',0],['program','argument',[['set','order',1],['throw',7]]],
  ['evaluate',invokeWith(lit({setter:'target'}),call('argument'))],['flush'],['read','order'],['read','target'],['dispose']
]);
await scenario('throwing updater skips setter remainder',[
  ['signal','target',0],['signal','order',0],['program','argument',[['set','order',1],['throw',7]]],
  ['evaluate',invokeWith(lit({setter:'target'}),call('argument'),true)],['flush'],['read','order'],['read','target'],['dispose']
]);
for(const ignore of ['accessor','disposer']){
  await scenario('non-setter ignores an unevaluated updater body '+ignore,[
    ['signal','value',3],['signal','order',0],['program','body',[['set','order',9],['throw',7]]],
    ['root','target',arg(0),{owner:null}],
    ['evaluate',invokeWith(lit(ignore==='accessor'?{accessor:'value'}:{rootDisposer:'target'}),call('body'),true)],
    ['flush'],['read','order'],['dispose']
  ]);
}
for(const immediate of [false,true]){
  await scenario('async delivery preserves setter as function data '+immediate,[
    ['signal','target',1],['future','p',{immediate}],['memo','answer',future('p')],['flush'],
    ['resolve','p',{setter:'target'}],['tick'],['flush'],
    ['evaluate',invokeWith(read('answer'),lit(9))],['flush'],['read','target'],['dispose']
  ]);
}
await scenario('setter error payload captures native bound function text',[
  ['signal','value',0],['memo','bad',{raise:{setter:'value'}}],['read','bad'],['flush'],['dispose']
]);
await scenario('escaped updater captures entry value across its nested write',[
  ['signal','value',1],['program','rewrite',[['set','value',9],['return',lit(1)]]],
  ['evaluate',invokeWith(lit({setter:'value'}),call('rewrite'),true)],['flush'],['read','value'],['dispose']
]);
console.log(`${count-setterStart} escaped-setter histories match pinned TS function binding, arguments, updater invocation, identity, returns and lifetime.`);
// Native function aliases and same-runtime cache round trips are checked
// directly, separately from the observer's cross-runtime function names.
{
  const b=new BendRuntime(),s=new SolidRuntime({module:await import('../build/solid.mjs?native-setter')});
  try{
    const expr=scope(lit(2),setter(0)),bf=b.root('scope',expr),sf=s.root('scope',expr);
    assert.equal(typeof bf,'function');assert.equal(typeof sf,'function');
    assert.equal(bf,b.setters.get(b.ids['#nested1']));assert.equal(sf,s.localSignals.get('#nested1').set);
    assert.equal(bf,b.decode(b.encode(bf)));assert.equal(sf,s.value({setter:'#nested1'}));
    for(const runtime of [b,s])runtime.disposeOwner('scope');
    assert.equal(bf(7),sf(7));
    assert.equal(bf(bf),sf(sf)); // selected bound functions are actual updaters
    for(const runtime of [b,s])runtime.flush();
    assert.equal(b.evaluate(invoke(lit({accessor:'#nested1'}))),7);
    assert.equal(s.evaluate(invoke(lit({accessor:'#nested1'}))),7);
    assert.equal(bf(),sf());
    for(const runtime of [b,s])runtime.flush();
    assert.equal(b.evaluate(invoke(lit({accessor:'#nested1'}))),undefined);
    assert.equal(s.evaluate(invoke(lit({accessor:'#nested1'}))),undefined);
    for(const runtime of [b,s]){
      const fn=runtime===b?bf:sf;
      runtime.signal('initializer',fn);assert.equal(runtime.read('initializer'),undefined);
      runtime.signal('sink',0);runtime.program('raw',[['set','sink',fn]]);
      runtime.root('cleanupScope',lit(0));
      assert.doesNotThrow(()=>runtime.effect('setterCleanup',lit(1),{cleanup:'raw',owner:'cleanupScope'}));
      runtime.flush();runtime.disposeOwner('cleanupScope');runtime.flush();
      assert.equal(runtime.evaluate(invoke(lit({accessor:'#nested1'}))),0,'teardown raw setter updater receives the sink entry value');
      assert.equal(runtime.read('sink'),0);
      assert.equal(runtime.evaluate({onCleanup:lit(fn)}),fn);
    }
  }finally{for(const runtime of [b,s]){runtime.attempt('dispose');runtime.resetErrorHalt();runtime.attempt('flush');}}
}
