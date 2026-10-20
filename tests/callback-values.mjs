import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),call=call=>({call}),future=future=>({future});
const select=(c,y,n)=>({select:[c,y,n]}),add=(a,b)=>({add:[a,b]});
const arg=index=>({argument:index}),invoke=invoke=>({invoke}),current={owner:true};
const callWith=(call,...args)=>({call,args});
const owner=name=>lit({owner:name}),disposer=name=>lit({rootDisposer:name}),onCleanup=onCleanup=>({onCleanup});
const under=(target,body)=>({withOwner:[target,body]});
const callbackIds=d=>'callbacks'in d?list(d.callbacks):'callback'in d?[d.callback]:[];
const callbacks=d=>Array.isArray(d)?d:d?[d]:[];
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?callback-values='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const original=console.error;console.error=(...args)=>logs.push(args);
  try{
    for(const [op,...args] of commands){
      if(op==='tick')await setImmediate();
      else{
        const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
        if(actual[0]==='return'&&wanted[0]==='return'&&!['read','set','update','future','root','evaluate'].includes(op))actual[1]=wanted[1]=undefined;
        assert.deepEqual(actual,wanted,`${name}: ${op} result`);
      }
      const owners=[...Object.entries(s.owners).map(([name,node])=>[node,name]),...s.sourceNames];
      const actual=[],wanted=[];
      for(const [node,nodeName] of owners){
        let bendOwner;assert.doesNotThrow(()=>{bendOwner=b.ownerId(nodeName);},`${name}: source owner must retain its Bend owner kind after ${op}`);
        const bd=callbackIds(b.nodes()[bendOwner].disposal),sd=callbacks(node._disposal);
        assert.equal(bd.length,sd.length,`${name}: ${nodeName} disposal length after ${op}`);
        actual.push(...bd);wanted.push(...sd);
        const bc=b.nodes()[bendOwner].cleanup,sc=node._cleanup;
        assert.equal(!!bc,!!sc,`${name}: ${nodeName} returned cleanup after ${op}`);
        if(bc){actual.push(bc);wanted.push(sc);}
      }
      for(let i=0;i<actual.length;i++)for(let j=0;j<actual.length;j++)
        assert.equal(actual[i]===actual[j],wanted[i]===wanted[j],`${name}: callable alias ${i}/${j} after ${op}`);
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
const seq=(...seq)=>({seq}),fn=name=>lit({callback:name});
const invokeWith=(callee,value={lit:undefined})=>({invokeWith:{callee,value}});
const invokeArgs=(callee,...args)=>({invokeArgs:{callee,args}});
const scope=(initial,body,options={})=>({signalScope:{initial,body,options}});
for(const value of [undefined,null,false,true,0,7,NaN,'text',{ref:3}]){
  await scenario('ordinary callback return '+JSON.stringify(value),[
    ['program','f',[['return',lit(value)]]],['evaluate',invoke(fn('f'))],['evaluate',fn('f')],
    ['signal','saved',undefined],['update','saved',fn('f')],['flush'],['evaluate',invoke(read('saved'))],['dispose']
  ]);
}
for(const tracked of [false,true])for(const lazy of [false,true]){
  await scenario('callback value reads retain ambient context '+JSON.stringify({tracked,lazy}),[
    ['signal','input',1],['memo','double',add(read('input'),read('input')),{lazy}],
    ['program','f',[['return',seq(current,{observer:true},read('double'))]]],
    ...(tracked?[['memo','outer',invoke(fn('f'))],['effect','view',read('outer')]]:[['effect','view',read('input'),{program:'f'}]]),
    ['flush'],['set','input',3],['flush'],['evaluate',invoke(fn('f'))],['dispose'],['flush']
  ]);
}
for(const kind of ['direct','setter','updater','callee','argument']){
  const callExpr=kind==='direct'?invokeWith(fn('f'),lit(3)):kind==='callee'?invokeArgs(call('get'),lit(3),lit(4)):kind==='argument'?invokeArgs(fn('f'),call('arg'),lit(4)):invoke(fn('f'));
  await scenario('callback execution and argument order '+kind,[
    ['signal','input',1],['program','f',[['return',add(select(arg(0),arg(0),lit(0)),select(arg(1),arg(1),lit(0)))]]],
    ['program','get',[['set','input',2],['return',fn('f')]]],['program','arg',[['set','input',3],['return',lit(5)]]],
    ...(kind==='setter'?[['set','input',{callback:'f'}]]:kind==='updater'?[['update','input',invokeWith(fn('f'),{prev:true})]]:[['evaluate',callExpr]]),
    ['flush'],['read','input'],['dispose']
  ]);
}
for(const throwAt of ['callee','first','second','body']){
  await scenario('callback call throws at source evaluation point '+throwAt,[
    ['signal','marker',0],['program','f',[['set','marker',9],...(throwAt==='body'?[['throw',7]]:[['return',arg(0)]])]],
    ['program','arg',[['set','marker',1],['return',lit(3)]]],
    ['evaluate',invokeArgs(throwAt==='callee'?{raise:7}:fn('f'),throwAt==='first'?{raise:7}:call('arg'),throwAt==='second'?{raise:7}:lit(4))],
    ['flush'],['read','marker'],['dispose']
  ]);
}
for(const lazy of [false,true]){
  await scenario('callback value is a function initializer '+lazy,[
    ['signal','input',1],['program','f',[['return',add(select(arg(0),arg(0),lit(0)),read('input'))]]],
    ['signal','derived',{callback:'f'},{lazy}],['read','derived'],['set','derived',7],['flush'],['read','derived'],
    ['set','input',3],['flush'],['read','derived'],['dispose'],['set','input',9],['flush'],['read','derived']
  ]);
  await scenario('callback initializer captured inside local scope '+lazy,[
    ['program','f',[['return',select(arg(0),add(arg(0),lit(1)),lit(2))]]],
    ['root','scope',scope(fn('f'),seq({localRead:0},{localWrite:{value:lit(7)}},{localRead:0}),{lazy})],['flush'],['dispose']
  ]);
}
for(const immediate of [false,true])for(const reject of [false,true]){
  await scenario('callback function as promise payload '+JSON.stringify({immediate,reject}),[
    ['signal','marker',0],['program','f',[['set','marker',7]]],['future','p',{immediate}],['memo','m',future('p')],
    ['awaitValue','wait',read('m')],[reject?'reject':'resolve','p',{callback:'f'}],['tick'],
    ...(reject?[]:[['evaluate',invoke(read('m'))]]),['flush'],['read','marker'],['dispose'],['flush']
  ]);
}
for(const value of [7,{callback:'g'}])for(const held of [false,true]){
  await scenario('callback result function follows setter entry policy '+JSON.stringify({value,held}),[
    ['signal','version',0],['signal','input',1],['signal','derived',{accessor:'input'}],['root','target',lit(0)],
    ['program','g',[['set','input',9]]],['program','f',[['return',lit(value)]]],['future','p',{immediate:true}],
    ['memo','slow',select(read('version'),future('p'),lit(0))],['effect','view',seq(read('version'),read('derived'),read('slow'))],['flush'],
    ...(held?[['set','input',3],['set','version',1],['flush']]:[]),['evaluate',invokeWith(lit({setter:'derived'}),fn('f'))],['flush'],
    ['resolve','p',5],['tick'],['flush'],['read','input'],['read','derived'],['dispose'],['flush']
  ]);
}
for(const user of [false,true])for(const cleanupThrows of [false,true]){
  await scenario('dynamic selected callback cleanup '+JSON.stringify({user,cleanupThrows}),[
    ['signal','version',0],['signal','marker',0],['program','a',[['set','marker',1],...(cleanupThrows?[['throw',7]]:[])]],
    ['program','b',[['set','marker',2]]],['program','choose',[['return',select(arg(0),fn('b'),fn('a'))]]],
    ['effect','view',read('version'),{user,program:'choose',returnCleanup:true}],['flush'],['set','version',1],['flush'],
    ['read','marker'],['dispose'],['resetErrorHalt'],['flush']
  ]);
}
for(const copies of [1,2,3]){
  await scenario('bound callback aliases share a canonical owner entry '+copies,[
    ['signal','marker',0],['program','clean',[['set','marker',9]]],['root','first',lit(0)],['root','second',lit(0)],
    ...Array.from({length:copies},()=>['evaluate',under(owner('first'),onCleanup(fn('clean')))]),
    ['evaluate',under(owner('second'),onCleanup(fn('clean')))],['program','choose',[['return',fn('clean')]]],
    ['effect','view',lit(1),{program:'choose',returnCleanup:true}],['flush'],['disposeOwner','first'],['flush'],
    ['disposeOwner','second'],['flush'],['dispose'],['flush'],['read','marker']
  ]);
}
await scenario('bound program value and original static cleanup have distinct identities',[
  ['signal','marker',0],['program','clean',[['set','marker',9]]],['program','attach',[['cleanup','clean']]],
  ['root','static',call('attach')],['root','bound',onCleanup(fn('clean'))],
  ['effect','view',lit(1),{cleanup:'clean'}],['effect','boundView',lit(1),{program:'attach'}],['flush'],['dispose'],['flush']
]);
await scenario('two-argument call binds enclosing locals and evaluates ignored arguments',[
  ['signal','marker',0],['program','f',[['return',add(arg(0),arg(1))]]],
  ['program','arg',[['set','marker',7],['return',lit(3)]]],
  ['root','scope',scope(lit(2),invokeArgs(fn('f'),{localRead:0},call('arg')))],['flush'],['read','marker'],
  ['evaluate',invokeArgs(lit({accessor:'marker'}),lit(1),call('arg'))],['flush'],['dispose'],['flush']
]);
for(const r of [new BendRuntime(),new SolidRuntime({module:await import('../build/solid.mjs?callback-native')})]){
  try{
    r.program('f',[['return',add(arg(0),arg(1))]]);const f=r.evaluate(fn('f'));
    assert.equal(typeof f,'function');assert.equal(r.evaluate(fn('f')),f);assert.equal(f(2,3),5);
    assert.equal(r.evaluate(onCleanup(fn('f'))),f,'no-owner cleanup returns the same function without installing it');
    r.signal('saved',undefined);assert.equal(r.update('saved',fn('f')),f);r.flush();assert.equal(r.read('saved'),f);
    assert.throws(()=>r.program('f',[]),/cannot be redefined/);
    assert.throws(()=>r.evaluate(invokeArgs(fn('f'),lit(1),lit(2),lit(3))),/at most two/);
  }finally{r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}
}
console.log(`${count} first-class callback histories match pinned TS calls, aliases, arguments, initializers, updates, promise data and imperative cleanup selection.`);
for(const kind of ['rootDisposer','accessor','setter']){
  await scenario('two argument calls evaluate ignored argument effects '+kind,[
    ['signal','input',0],['root','target',lit(0)],['program','first',[['set','input',3],['return',lit(7)]]],
    ['program','second',[['set','input',9],['return',lit(8)]]],
    ['evaluate',invokeArgs(lit({[kind]:kind==='rootDisposer'?'target':'input'}),call('first'),call('second'))],
    ['flush'],['read','input'],['dispose'],['flush']
  ]);
}
await scenario('two argument call retains positional meaning',[
  ['program','f',[['return',add({mul:[arg(0),lit(10)]},arg(1))]]],
  ['evaluate',invokeArgs(fn('f'),lit(3),lit(4))],['dispose']
]);
for(const r of [new BendRuntime(),new SolidRuntime({module:await import('../build/solid.mjs?callback-limits')})]){
  try{
    r.program('helper',[['previousCleanup']]);r.program('indirect',[['return',call('helper')]]);
    assert.throws(()=>r.evaluate(fn('helper')),/helper is unavailable/);
    assert.throws(()=>r.evaluate(fn('indirect')),/helper is unavailable/);
    r.program('reads',[['return',lit(1)]]);
    assert.equal(typeof r.evaluate(onCleanup(fn('reads'))),'function','no owner does not inspect or allocate a cleanup');
    assert.equal(typeof r.root('scope',onCleanup(fn('reads'))),'function');
    assert.doesNotThrow(()=>r.disposeOwner('scope'),'cleanup expression returns are ignored');
  }finally{r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}
}
console.log(`${count} complete first-class callback histories and native alias/domain controls pass.`);
for(const immediate of [false,true])for(const reject of [false,true])for(const lazy of [false,true]){
  await scenario('callback initializer returns a genuine flight '+JSON.stringify({immediate,reject,lazy}),[
    ['future','p',{immediate}],['program','load',[['return',future('p')]]],
    ['signal','derived',{callback:'load'},{lazy,loadingValue:2}],['effect','view',read('derived'),{user:true}],['flush'],
    [reject?'reject':'resolve','p',7],['tick'],['flush'],['read','derived'],['dispose'],['flush']
  ]);
}
for(const immediate of [false,true]){
  await scenario('callback value registers after pending delivery '+immediate,[
    ['signal','marker',0],['program','clean',[['set','marker',9]]],['future','p',{immediate}],['memo','function',future('p')],
    ['memo','registered',onCleanup(read('function'))],['effect','view',read('registered'),{user:true}],['flush'],
    ['resolve','p',{callback:'clean'}],['tick'],['flush'],['read','registered'],['dispose'],['flush'],['read','marker']
  ]);
}
await scenario('callback identity is distinct from accessor setter and root namespaces',[
  ['signal','input',1],['program','a',[]],['program','b',[]],
  ['evaluate',{same:[fn('a'),disposer('root')]}],['evaluate',{same:[fn('b'),lit({accessor:'input'})]}],
  ['evaluate',{same:[fn('b'),lit({setter:'input'})]}],['evaluate',{same:[fn('a'),fn('a')]}],['evaluate',{same:[fn('a'),fn('b')]}],
  ['evaluate',select(fn('a'),lit(1),lit(0))],['dispose'],['flush']
]);
console.log(`${count} final callback-value histories pass.`);
for(const kind of ['callback','accessor','setter','rootDisposer']){
  await scenario('higher-order callback invokes its function argument '+kind,[
    ['signal','input',1],['root','target',lit(0)],['program','g',[['return',add(arg(0),lit(1))]]],
    ['program','apply',[['return',invokeWith(arg(0),arg(1))]]],
    ['evaluate',invokeArgs(fn('apply'),lit({[kind]:kind==='callback'?'g':kind==='rootDisposer'?'target':'input'}),lit(3))],
    ['flush'],['read','input'],['dispose'],['flush']
  ]);
}
await scenario('callee selection is captured before argument effects',[
  ['signal','which',false],['program','left',[['return',lit(1)]]],['program','right',[['return',lit(2)]]],
  ['program','select',[['return',select(read('which'),fn('right'),fn('left'))]]],
  ['program','switch',[['set','which',true],['return',lit(7)]]],
  ['evaluate',invokeArgs(call('select'),call('switch'))],['flush'],['evaluate',invoke(call('select'))],['dispose'],['flush']
]);
console.log(`${count} total first-class callback histories pass.`);

await scenario('long imperative cleanup keeps the source implicit disposal capacity',[
  ['program','clean',Array.from({length:96},(_,i)=>['emit',i])],['root','target',onCleanup(fn('clean'))],
  ['disposeOwner','target'],['dispose'],['flush']
]);
for(const r of [new BendRuntime(),new SolidRuntime({module:await import('../build/solid.mjs?long-native-cleanup')})]){
  r.program('clean',Array.from({length:96},(_,i)=>['emit',i]));r.root('target',onCleanup(fn('clean')));
  const dispose=r.evaluate(disposer('target'));dispose();
  assert.equal(r.trace().filter(e=>e[0]==='cleanup').length,96);
  r.dispose();r.flush();
}
console.log(`${count} complete callback-value histories and native controls pass.`);
