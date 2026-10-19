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
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?writable-signals='+count);
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
        verify?.(op,args,actual,wanted,b,s);
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
      assert.deepEqual(b.iteratorIO(),s.iteratorIO(),`${name}: iterator calls after ${op}`);
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

const scope=(compute,body,options={})=>({signalComputeScope:{compute,body,options}});
const seq=(...seq)=>({seq}),setter=depth=>({localSetter:depth}),accessor=depth=>({localAccessor:depth});
const get=()=>({localRead:0});
const write=(value,{depth=0,updater=false}={})=>({localWrite:{depth,value,updater}});
const invokeWith=(callee,value={lit:undefined},updater=false)=>({invokeWith:{callee,value,updater}});
const capture=[['signal','saved',undefined],['signal','setSaved',undefined],['program','save',[['updateExpr','saved',arg(0)],['updateExpr','setSaved',arg(1)]]]];
const save=()=>callWith('save',accessor(0),setter(0));
const readSaved=()=>invoke(read('saved'));
for(const lazy of [false,true])for(const value of [undefined,null,false,true,0,7,NaN,'derived',{ref:3}]){
  await scenario('function initializer with lazy/value '+JSON.stringify({lazy,value}),[
    ['root','scope',scope(lit(value),get(),{lazy})],['flush'],['dispose']
  ]);
}
for(const lazy of [false,true])for(const equals of [false,true]){
  await scenario('writable initializer rederives after a manual write '+JSON.stringify({lazy,equals}),[
    ['signal','input',1],...capture,['root','scope',scope(add(read('input'),lit(2)),save(),{lazy,equals})],
    ['effect','view',readSaved()],['flush'],['evaluate',invokeWith(read('setSaved'),lit(11))],['flush'],
    ['set','input',4],['flush'],['set','input',7],['flush'],['dispose']
  ]);
  await scenario('writable initializer composes two manual updaters '+JSON.stringify({lazy,equals}),[
    ...capture,['root','scope',scope(lit(1),save(),{lazy,equals})],['effect','view',readSaved()],['flush'],
    ['evaluate',seq(invokeWith(read('setSaved'),add({prev:true},lit(2)),true),invokeWith(read('setSaved'),add({prev:true},lit(3)),true))],
    ['flush'],['evaluate',readSaved()],['dispose']
  ]);
}
for(const lazy of [false,true]){
  await scenario('lexical writes use setMemo rather than setSignal '+lazy,[
    ['signal','input',1],['root','scope',scope(read('input'),seq(write(lit(8)),write(add({prev:true},lit(2)),{updater:true}),get()),{lazy})],
    ['flush'],['set','input',4],['flush'],['dispose']
  ]);
  await scenario('writable memo remains owned after its setter escapes '+lazy,[
    ['signal','input',1],...capture,['root','scope',scope(add(read('input'),lit(2)),save(),{lazy})],
    ['effect','view',readSaved()],['flush'],['set','input',4],['flush'],['disposeOwner','scope'],
    ['set','input',7],['flush'],['evaluate',readSaved()],['evaluate',invokeWith(read('setSaved'),lit(20))],['flush'],['evaluate',readSaved()],['dispose']
  ]);
}
for(const immediate of [false,true])for(const loading of [false,true]){
  await scenario('writable initializer async landing follows a manual write '+JSON.stringify({immediate,loading}),[
    ...capture,['future','p',{immediate}],['root','scope',scope(future('p'),save(),loading?{loadingValue:2}:{lazy:true})],['flush'],
    ['effect','view',readSaved()],['flush'],['evaluate',invokeWith(read('setSaved'),lit(9))],['flush'],
    ['resolve','p',7],['tick'],['flush'],['evaluate',readSaved()],['dispose']
  ]);
}
for(const lazy of [false,true]){
  await scenario('writable derivation receives the manual staging as previous '+lazy,[
    ['signal','input',1],...capture,['root','scope',scope(add(select({prev:true},{prev:true},lit(0)),read('input')),save(),{lazy})],
    ['effect','view',readSaved()],['flush'],['evaluate',invokeWith(read('setSaved'),lit(10))],['set','input',3],['flush'],
    ['set','input',2],['flush'],['evaluate',readSaved()],['dispose']
  ]);
}
await scenario('function initializer captures outer locals and callback arguments',[
  ['program','make',[['return',{signalScope:{initial:arg(0),body:scope(add({localRead:0},arg(1)),accessor(0),{lazy:true})}}]]],
  ['signal','saved',undefined],['program','save',[['updateExpr','saved',arg(0)]]],
  ['root','scope',callWith('save',callWith('make',lit(3),lit(5)))],['flush'],['evaluate',readSaved()],['dispose']
]);
for(const immediate of [false,true])for(const held of [false,true])for(const updater of [false,true]){
  await scenario('numeric held writable derivation '+JSON.stringify({immediate,held,updater}),[
    ['signal','version',0],...capture,['future','p',{immediate}],
    ['root','scope',scope(add(select({prev:true},{prev:true},lit(0)),read('version')),save())],['flush'],
    ['memo','slow',select(read('version'),held?future('p'):lit(0),lit(0))],
    ['effect','view',seq(read('version'),readSaved(),read('slow'))],['flush'],['set','version',1],['flush'],
    ['evaluate',invokeWith(read('setSaved'),updater?add({prev:true},lit(10)):lit(10),updater)],['flush'],
    ['resolve','p',7],['tick'],['flush'],['evaluate',readSaved()],['set','version',2],['flush'],['dispose']
  ]);
}
for(const immediate of [false,true])for(const held of [false,true])for(const derived of [false,true])for(const throws of [false,true]){
  await scenario('preserved held function result bug '+JSON.stringify({immediate,held,derived,throws}),[
    ['signal','version',0],['signal','previous',undefined],...capture,
    ['program','replacementCleanup',[['emit',51],...(throws?[['throw',7]]:[])]],
    ['program','attach',[['cleanup','replacementCleanup'],['return',arg(0)]]],
    ['root','replacement',callWith('attach',arg(0)),{owner:null}],
    ['root','original',arg(0),{owner:null}],['root','derived',arg(0),{owner:null}],
    ['program','replace',[['updateExpr','previous',arg(0)],['return',lit({rootDisposer:'replacement'})]]],
    ['future','p',{immediate}],['root','scope',derived?
      scope(select(read('version'),lit({rootDisposer:'derived'}),lit({rootDisposer:'original'})),save()):
      {signalScope:{initial:lit(undefined),body:save()}}],['flush'],
    ['memo','slow',select(read('version'),held?future('p'):lit(0),lit(0))],
    ['effect','view',seq(read('version'),readSaved(),read('slow'))],['flush'],['set','version',1],['flush'],
    ['evaluate',invokeWith(read('setSaved'),callWith('replace',{prev:true}),true)],
    ['evaluate',{disposed:lit({owner:'replacement'})}],['flush'],['resolve','p',7],['tick'],['flush'],['read','previous'],['dispose']
  ],(op,args,actual,wanted)=>{
    const bug=held&&derived;
    if(op==='evaluate'&&args[0].invokeWith){
      assert.deepEqual(wanted,bug&&throws?['throw',7]:['return',bug?undefined:{rootDisposer:{owner:'replacement'}}],'pinned function-result outcome');
    }
    if(op==='evaluate'&&args[0].disposed)assert.deepEqual(wanted,['return',bug],'only held writable-memo updater invokes the returned disposer');
    if(op==='read'&&args[0]==='previous')assert.deepEqual(wanted,['return',derived?{rootDisposer:{owner:held?'original':'derived'}}:undefined],'updater receives the source-selected frame');
  });
}
for(const owner of [false,true]){
  await scenario('initial compute error is stored before the const-pair body '+owner,[
    ['program','afterConstruct',[['emit',99]]],
    owner?['root','scope',scope({raise:7},call('afterConstruct'))]:['evaluate',scope({raise:7},call('afterConstruct'))],
    ['flush'],['dispose']
  ]);
  await scenario('unseeded eager async initializer retains its pending construction '+owner,[
    ['future','p',{immediate:true}],
    owner?['root','scope',scope(future('p'),lit(99))]:['evaluate',scope(future('p'),lit(99))],
    ['flush'],['resolve','p',7],['tick'],['flush'],['dispose']
  ]);
}
for(const immediate of [false,true]){
  await scenario('writable async result stores function data without invoking it '+immediate,[
    ...capture,['root','replacement',arg(0),{owner:null}],['future','p',{immediate}],
    ['root','scope',scope(future('p'),save(),{loadingValue:0})],['flush'],['effect','view',readSaved()],['flush'],
    ['evaluate',invokeWith(read('setSaved'),lit(9))],['flush'],
    ['resolve','p',{rootDisposer:'replacement'}],['tick'],['flush'],['evaluate',readSaved()],
    ['evaluate',{disposed:lit({owner:'replacement'})}],['dispose']
  ]);
}
for(const lazy of [false,true]){
  await scenario('writable constructor preserves unobserved and revival paths '+lazy,[
    ['signal','input',1],...capture,['program','gone',[['emit',52]]],
    ['root','scope',scope(read('input'),save(),{lazy,unobserved:'gone'})],['flush'],
    ['root','reader',{effectCreate:readSaved(),body:lit(undefined)}],['flush'],['disposeOwner','reader'],
    ['set','input',4],['flush'],['evaluate',readSaved()],['flush'],['dispose']
  ]);
  await scenario('writable lazy node disposed before its first accessor call '+lazy,[
    ['signal','input',1],...capture,['root','scope',scope(read('input'),save(),{lazy})],['flush'],
    ['disposeOwner','scope'],['set','input',4],['flush'],['evaluate',readSaved()],['dispose']
  ]);
}
for(const immediate of [false,true])for(const loading of [false,true])for(const cancel of [false,true]){
  await scenario('writable streaming derivation and manual proposals '+JSON.stringify({immediate,loading,cancel}),[
    ...capture,['future','first',{immediate}],['future','second',{immediate}],
    ['stream','items',[{future:'first'},{future:'second'},{done:true}]],
    ['root','scope',scope(future('items'),save(),loading?{loadingValue:0}:{lazy:true})],['flush'],
    ['effect','view',readSaved()],['flush'],['evaluate',invokeWith(read('setSaved'),lit(9))],['flush'],
    ['resolveStep','first',7],['tick'],['flush'],
    ...(cancel?[['disposeOwner','scope']]:[['evaluate',invokeWith(read('setSaved'),lit(11))],['flush']]),
    ['resolveStep','second',13],['tick'],['flush'],['evaluate',readSaved()],['dispose']
  ]);
}
for(const lazy of [false,true]){
  await scenario('manual write before the first accessor activation '+lazy,[
    ...capture,['root','scope',scope(lit(1),save(),{lazy})],['flush'],
    ['evaluate',invokeWith(read('setSaved'),lit(7))],['flush'],['evaluate',readSaved()],['flush'],['dispose']
  ]);
}
console.log(`${count} writable-signal histories match pinned TS function construction, manual writes, reruns, previous arguments, ownership and async landing.`);
// Function tokens retain the constructor's actual bound identities, including
// a pair whose initial computation stored an error. A read-only memo has no setter.
for(const errored of [false,true]){
  const b=new BendRuntime(),s=new SolidRuntime({module:await import('../build/solid.mjs?native-writable='+errored)});
  try{
    for(const runtime of [b,s]){
      const native=runtime.root('scope',scope(errored?{raise:7}:lit(1),setter(0),{lazy:!errored}));
      assert.equal(typeof native,'function');
      const described=runtime.observe(native);
      if(runtime===b)assert.equal(runtime.decode(runtime.encode(described)),native);
      else assert.equal(runtime.value(described),native);
      if(errored)assert.throws(()=>runtime.evaluate(invoke(lit({accessor:'#nested1'}))));
      else{
        assert.equal(native(7),7);runtime.flush();
        assert.equal(runtime.evaluate(invoke(lit({accessor:'#nested1'}))),1,'first lazy accessor call follows the source activation rule');
      }
      runtime.memo('readonly',lit(2));
      assert.throws(()=>runtime===b?runtime.encode({setter:'readonly'}):runtime.value({setter:'readonly'}),/Unknown signal setter/);
    }
  }finally{for(const runtime of [b,s]){runtime.attempt('dispose');runtime.resetErrorHalt();runtime.attempt('flush');}}
}
for(const runtime of [new BendRuntime(),new SolidRuntime({module:await import('../build/solid.mjs?constructor-body-throw')})]){
  try{
    assert.throws(()=>runtime.root('scope',scope(lit(1),{raise:7})));
    const described={setter:'#nested1'};
    const native=runtime instanceof BendRuntime?runtime.decode(runtime.encode(described)):runtime.value(described);
    assert.equal(native(8),8);
  }finally{runtime.attempt('dispose');runtime.resetErrorHalt();runtime.attempt('flush');}
}
// These native bound-function combinations compare actual results, node state
// and lifetime. Complete traces of getters invoked internally by setMemo are
// not yet observed by the reference adapter; they are not counted as histories.
for(const raw of [false,true])for(const functionResult of [false,true]){
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module:await import('../build/solid.mjs?native-held-getter='+raw+functionResult)});
  const commands=[['signal','version',0],...capture,['root','replacement',arg(0),{owner:null}],
    ['signal','payload',undefined],['update','payload',lit(functionResult?{rootDisposer:'replacement'}:7)],['flush'],['future','p',{immediate:true}],
    ['root','scope',scope(read('version'),save())],['flush'],
    ['memo','slow',select(read('version'),future('p'),lit(0))],['effect','view',seq(read('version'),readSaved(),read('slow'))],
    ['flush'],['set','version',1],['flush']];
  try{
    for(const [op,...args] of commands){
      const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
      if(actual[0]==='return'&&wanted[0]==='return'&&!['read','set','update','future','root','evaluate'].includes(op))actual[1]=wanted[1]=undefined;
      assert.deepEqual(actual,wanted,'native control setup');assert.equal(actual[0],'return','native setup must be valid: '+op);
    }
    const result=invokeWith(read('setSaved'),lit({accessor:'payload'}),!raw);
    assert.deepEqual(b.attempt('evaluate',result),s.attempt('evaluate',result));
    const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states);
    assert.deepEqual(b.attempt('evaluate',{disposed:lit({owner:'replacement'})}),['return',raw&&functionResult]);
    assert.deepEqual(s.attempt('evaluate',{disposed:lit({owner:'replacement'})}),['return',raw&&functionResult]);
  }finally{for(const runtime of [b,s]){runtime.attempt('dispose');runtime.resetErrorHalt();runtime.attempt('flush');runtime.attempt('resolve','p',1);}await setImmediate();}
}
