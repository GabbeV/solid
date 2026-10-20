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
  const module=await import('../build/solid.mjs?locals='+count);
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
const localRead=depth=>({localRead:depth});
const write=(value,{depth=0,updater=false}={})=>({localWrite:{depth,value,updater}});
const seq=(...seq)=>({seq});
const effect=(effectCreate,body,options={})=>({effectCreate,body,options});
const nested=(memoRead,options={})=>({memoRead,options});
const get=()=>localRead(0);
for(const value of [undefined,null,false,true,0,7,NaN,'value',{ref:7},{owner:'root'},{error:1,kind:'Error',message:'value'}]){
  await scenario('local initializer and result '+String(value),[['evaluate',scope(lit(value),get())],['flush']]);
  await scenario('local setter return and staged read '+String(value),[
    ['evaluate',scope(lit(1),seq(write(lit(value)),get()))],['flush']
  ]);
}
for(const equals of [false,true])for(const ownedWrite of [false,true])for(const noSnapshot of [false,true]){
  const options={equals,ownedWrite,noSnapshot};
  await scenario('local staged updater composition '+JSON.stringify(options),[
    ['root','scope',scope(lit(1),seq(write(add({prev:true},lit(2)),{updater:true}),write(add({prev:true},lit(3)),{updater:true}),nested(get())),options)],
    ['flush'],['dispose']
  ]);
  await scenario('local binding survives queued closure '+JSON.stringify(options),[
    ['signal','s',1],['root','scope',scope(lit(0),seq(
      effect(read('s'),write(add({prev:true},arg(0)),{updater:true})),
      effect(get(),lit(undefined),{user:false,target:3})
    ),options)],
    ['flush'],['set','s',3],['flush'],['set','s',5],['flush'],['dispose'],['set','s',8],['flush']
  ]);
}
await scenario('shadowed locals and initializer see their respective lexical scope',[
  ['root','scope',scope(lit(7),scope(add(get(),lit(3)),seq(
    write(lit(8),{depth:1}),write(add({prev:true},localRead(1)),{updater:true}),
    add(get(),localRead(1))
  )))],['flush'],['dispose']
]);
await scenario('nested root rebinds arguments but captures local signal',[
  ['root','scope',scope(lit(7),{root:seq(write(arg(0)),get())})],['flush'],['dispose']
]);
await scenario('new effect application owns arguments and retains local bindings',[
  ['root','scope',scope(lit(7),seq(effect(lit(3),write(add({prev:true},arg(0)),{updater:true})),effect(get(),lit(undefined),{user:false,target:3})))],
  ['flush'],['dispose']
]);
await scenario('separate closure instances retain separate signal identities',[
  ['signal','s',1],['root','one',scope(lit(0),effect(read('s'),write(add({prev:true},arg(0)),{updater:true})))],
  ['root','two',scope(lit(10),effect(read('s'),write(add({prev:true},arg(0)),{updater:true})))],
  ['flush'],['set','s',2],['flush'],['disposeOwner','one'],['set','s',3],['flush'],['dispose']
]);
await scenario('parent rerun allocates fresh locals and retires captured callbacks',[
  ['signal','s',1],['signal','trigger',0],
  ['memo','m',seq(read('trigger'),scope(lit(0),seq(effect(read('s'),write(arg(0))),effect(get(),lit(undefined),{user:false,target:3}),lit(3))))],
  ['effect','view',read('m')],['flush'],['set','s',2],['flush'],['set','trigger',1],['flush'],['dispose']
]);
await scenario('initializer executes before allocating its signal',[
  ['signal','s',1],['root','scope',scope(nested(read('s')),nested(get()))],['flush'],['dispose']
]);
await scenario('throwing updater does not write and preserves enclosing operands',[
  ['memo','m',add(lit(5),scope(lit(1),write({raise:7},{updater:true})))],['read','m'],['flush'],['dispose']
]);
await scenario('throwing initializer never allocates a signal',[
  ['memo','m',scope({raise:7},get())],['read','m'],['flush'],['dispose']
]);
for(const updater of [false,true]){
  await scenario('bound disposer raw input versus returned function '+updater,[
    ['root','target',arg(0),{owner:null}],['root','scope',scope(lit(1),write(lit({rootDisposer:'target'}),{updater}))],
    ['evaluate',{disposed:lit({owner:'target'})}],['flush'],['dispose']
  ]);
}
for(const immediate of [false,true]){
  await scenario('local signal stores async identity without awaiting '+immediate,[
    ['future','p',{immediate}],['root','scope',scope(future('p'),nested(get(),{loadingValue:0}))],
    ['flush'],['resolve','p',7],['tick'],['flush'],['dispose']
  ]);
}

await scenario('a new application-local shadows a retained outer binding',[
  ['signal','s',2],['root','scope',scope(lit(10),effect(read('s'),scope(arg(0),seq(
    write(add(get(),localRead(1)),{depth:1}),write(lit(3)),localRead(1)
  ))))],['flush'],['set','s',4],['flush'],['dispose']
]);
await scenario('nested setter argument side effects survive its later throw',[
  ['root','scope',scope(lit(1),scope(lit(2),write(seq(write(lit(9)),{raise:7}),{depth:1})))],
  ['flush'],['dispose']
]);
await scenario('raw function setter throw skips the local write',[
  ['program','bad',[['throw',8]]],['program','attach',[['cleanup','bad'],['return',arg(0)]]],
  ['root','target',callWith('attach',arg(0)),{owner:null}],
  ['root','scope',scope(lit(1),write(lit({rootDisposer:'target'})))],['flush'],['dispose']
]);
await scenario('anonymous closure encodings do not change named callback labels',[
  ['program','first',[['emit',81]]],['root','one',scope(lit(1),effect(lit(2),call('first')))],
  ['program','second',[['emit',82]]],['root','two',scope(lit(1),effect(lit(2),call('second')))],
  ['flush'],['dispose']
]);
await scenario('local unobserved callback retains signal-specific teardown',[
  ['program','gone',[['emit',83]]],['root','scope',scope(lit(1),effect(get(),lit(undefined)),{unobserved:'gone'})],
  ['flush'],['dispose']
]);
console.log(`${count} local-signal and captured-body histories match pinned TS allocation, lexical identity, staged writes, callbacks and lifetime.`);

const accessor=depth=>({localAccessor:depth});
const capture=[['signal','box',undefined],['program','capture',[['updateExpr','box',arg(0)]]]];
const outside=()=>invoke(read('box'));
const escapedStart=count;
for(const value of [undefined,null,false,true,0,7,NaN,'retained',{ref:9},{rootDisposer:'root'}]){
  await scenario('accessor escapes root with data '+String(value),[
    ...capture,['root','scope',scope(lit(undefined),seq(write(lit(value),{updater:true}),callWith('capture',accessor(0))))],
    ['flush'],['evaluate',outside()],['disposeOwner','scope'],['evaluate',outside()],['flush'],['dispose']
  ]);
}
for(const equals of [false,true])for(const user of [false,true]){
  await scenario('escaped accessor tracks and survives scope disposal '+JSON.stringify({equals,user}),[
    ['signal','input',1],...capture,['root','scope',scope(lit(0),seq(
      callWith('capture',accessor(0)),effect(read('input'),write(arg(0)))
    ),{equals})],['effect','view',outside(),{user}],['flush'],
    ['set','input',4],['flush'],['set','input',4],['flush'],['set','input',7],['flush'],
    ['disposeOwner','scope'],['set','input',9],['flush'],['evaluate',outside()],['dispose']
  ]);
}
for(const raw of [false,true]){
  await scenario('raw accessor updater versus returned function data '+raw,[
    ...capture,['signal','target',0],['root','scope',scope(lit(11),callWith('capture',accessor(0)))],['flush'],
    ...(raw?[['set','target',{accessor:'#nested1'}]]:[['update','target',read('box')]]),
    ['read','target'],['flush'],['read','target'],['evaluate',raw?read('target'):invoke(read('target'))],['dispose']
  ]);
  await scenario('local setter receives an escaped accessor '+raw,[
    ...capture,['root','one',scope(lit(12),callWith('capture',accessor(0)))],['flush'],
    ['root','two',scope(lit(2),write(read('box'),{updater:!raw}))],['flush'],
    ['evaluate',raw?invoke(lit({accessor:'#nested2'})):invoke(invoke(lit({accessor:'#nested2'})))],['dispose']
  ]);
}
for(const op of ['set','setExpr','updateExpr']){
  await scenario('named callback handles accessor writes '+op,[
    ...capture,['signal','target',0],['root','scope',scope(lit(13),callWith('capture',accessor(0)))],['flush'],
    ['program','store',[[op,'target',op==='set'?{accessor:'#nested1'}:read('box')]]],
    ['evaluate',call('store')],['flush'],['evaluate',op==='updateExpr'?invoke(read('target')):read('target')],['dispose']
  ]);
}
for(const untracked of [false,true]){
  await scenario('accessor invocation preserves enclosing operand and tracking '+untracked,[
    ['signal','input',1],...capture,['root','scope',scope(lit(3),seq(callWith('capture',accessor(0)),effect(read('input'),write(arg(0)))))],
    ['memo','m',add(lit(10),untracked?{untrack:outside()}:outside())],['effect','view',read('m')],['flush'],
    ['set','input',5],['flush'],['set','input',8],['flush'],['dispose']
  ]);
}
await scenario('shadowed accessor consts preserve distinct function identity',[
  ...capture,['root','scope',scope(lit(2),scope(lit(5),seq(
    callWith('capture',accessor(1)),
    {same:[accessor(0),accessor(1)]},
    add(invoke(accessor(0)),invoke(accessor(1)))
  )))],['flush'],['evaluate',outside()],['dispose']
]);
await scenario('same binding returns the same accessor',[
  ['root','scope',scope(lit(3),{same:[accessor(0),accessor(0)]})],['flush'],['dispose']
]);
await scenario('rerunning a parent allocates a fresh escaped accessor',[
  ['signal','input',1],['signal','old',undefined],['program','save',[['updateExpr','old',arg(0)]]],
  ['memo','factory',scope(read('input'),accessor(0))],['flush'],['evaluate',callWith('save',read('factory'))],
  ['effect','view',invoke(read('factory'))],['flush'],['set','input',4],['flush'],
  ['evaluate',{same:[read('factory'),read('old')]}],['evaluate',invoke(read('old'))],['dispose']
]);
for(const immediate of [false,true]){
  await scenario('async settlement retains escaped function as data '+immediate,[
    ...capture,['root','scope',scope(lit(14),callWith('capture',accessor(0)))],
    ['future','p',{immediate}],['memo','answer',future('p'),{loadingValue:0}],['flush'],
    ['resolve','p',{accessor:'#nested1'}],['tick'],['flush'],['evaluate',invoke(read('answer'))],['dispose']
  ]);
}
await scenario('accessor payload uses native bound function error text',[
  ...capture,['root','scope',scope(lit(15),callWith('capture',accessor(0)))],
  ['memo','bad',{raise:{accessor:'#nested1'}}],['read','bad'],['flush'],['dispose']
]);
await scenario('raw accessor updater adds its actual read dependency',[
  ['signal','input',1],...capture,['signal','sink',0],['program','copy',[['setExpr','sink',read('box')]]],
  ['root','scope',scope(lit(2),seq(callWith('capture',accessor(0)),effect(read('input'),write(arg(0)))))],
  ['memo','copy',call('copy')],['effect','view',read('sink')],['flush'],
  ['set','input',9],['flush'],['read','copy'],['dispose']
]);

for(const equals of [false,true])for(const user of [false,true]){
  await scenario('repeated accessor data uses strict callable equality '+JSON.stringify({equals,user}),[
    ['signal','input',1],['signal','box',undefined,{equals}],['program','capture',[['updateExpr','box',arg(0)]]],
    ['root','scope',scope(lit(17),seq(callWith('capture',accessor(0)),effect(read('input'),callWith('capture',accessor(0)))))],
    ['effect','view',outside(),{user}],['flush'],['set','input',2],['flush'],['set','input',3],['flush'],['dispose']
  ]);
}
await scenario('switching escaped accessors retires the old dependency',[
  ['signal','input',1],['signal','flag',true],['signal','left',undefined],['signal','right',undefined],
  ['program','saveLeft',[['updateExpr','left',arg(0)]]],['program','saveRight',[['updateExpr','right',arg(0)]]],
  ['root','leftScope',scope(lit(2),seq(callWith('saveLeft',accessor(0)),effect(read('input'),write(arg(0)))))],
  ['root','rightScope',scope(lit(20),seq(callWith('saveRight',accessor(0)),effect(read('input'),write(add(arg(0),lit(20))))))],
  ['memo','selected',invoke(select(read('flag'),read('left'),read('right')))],['effect','view',read('selected')],
  ['flush'],['set','input',3],['flush'],['set','flag',false],['flush'],['set','input',5],['flush'],
  ['set','flag',true],['flush'],['dispose']
]);
await scenario('callback parameters retain an accessor during an enclosing expression',[
  ...capture,['program','callRead',[['return',add(lit(5),invoke(arg(0)))]]],
  ['root','scope',scope(lit(19),callWith('capture',accessor(0)))],['flush'],
  ['memo','m',add(lit(3),callWith('callRead',read('box')))],['effect','view',read('m')],['flush'],['dispose']
]);
for(const immediate of [false,true]){
  await scenario('escaped read respects an async held frame '+immediate,[
    ['signal','input',1],...capture,['future','p',{immediate}],
    ['root','scope',scope(lit(0),seq(callWith('capture',accessor(0)),effect(read('input'),write(arg(0)))))],
    ['memo','pending',future('p')],['effect','view',add(outside(),read('pending'))],['flush'],
    ['set','input',7],['flush'],['resolve','p',10],['tick'],['flush'],['set','input',9],['flush'],['dispose']
  ]);
}

for(const storedFunction of ['disposer','accessor']){
  await scenario('raw accessor updater returns function data once '+storedFunction,[
    ['signal','box',undefined],['signal','target',0],
    ['program','capture',[['updateExpr','box',arg(0)]]],['root','targetRoot',arg(0),{owner:null}],
    ['root','scope',scope(lit(23),scope(lit(undefined),seq(
      write(storedFunction==='disposer'?lit({rootDisposer:'targetRoot'}):accessor(1),{updater:true}),
      callWith('capture',accessor(0))
    )))],['flush'],['set','target',{accessor:'#nested2'}],['flush'],
    ['evaluate',storedFunction==='disposer'?{disposed:lit({owner:'targetRoot'})}:invoke(read('target'))],['dispose']
  ]);
}

// Native functions and same-runtime aliases are checked independently of the
// cross-runtime observer's names. Native source calls are observed after return,
// as at the other successful accessor call sites; no function is replaced.
{
  const s=new SolidRuntime({module:await import('../build/solid.mjs?native-accessor')}),b=new BendRuntime();
  try{
    const expr=scope(lit(21),accessor(0));
    const sf=s.root('scope',expr),bf=b.root('scope',expr);
    assert.equal(typeof sf,'function');assert.equal(typeof bf,'function');
    assert.equal(sf,s.localSignals.get('#nested1').get);
    assert.equal(bf,b.accessors.get(b.ids['#nested1']));
    assert.equal(b.encode(bf).signal,b.ids['#nested1']);
    for(const runtime of [s,b])runtime.disposeOwner('scope');
    assert.equal(sf(),21);assert.equal(bf(),21);
    assert.equal(sf,s.value({accessor:'#nested1'}));assert.equal(bf,b.decode(b.encode(bf)));
    for(const runtime of [s,b]){
      runtime.signal('initializer',runtime===s?sf:bf);assert.equal(runtime.read('initializer'),21);
      runtime.signal('sink',0);
      runtime.program('raw',[['set','sink',runtime===s?sf:bf]]);
      assert.throws(()=>runtime.effect('bad',lit(1),{cleanup:'raw'}),/Accessor updater reads in teardown/);
      assert.throws(()=>runtime.evaluate({onCleanup:{lit:runtime===s?sf:bf}}));
    }
  }finally{for(const runtime of [s,b]){runtime.attempt('dispose');runtime.resetErrorHalt();runtime.attempt('flush');}}
}
console.log(`${count-escapedStart} escaped-accessor histories match pinned TS calls, function identity, setter branching, dependency tracking and lifetime.`);
