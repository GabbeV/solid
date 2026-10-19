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
  const module=await import('../build/solid.mjs?setter-cleanup='+count);
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
        const bd=callbackIds(b.nodes()[b.ownerId(nodeName)].disposal),sd=callbacks(node._disposal);
        assert.equal(bd.length,sd.length,`${name}: ${nodeName} disposal length after ${op}`);
        actual.push(...bd);wanted.push(...sd);
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
const seq=(...seq)=>({seq});
const scope=(compute,body,options={})=>({signalComputeScope:{compute,body,options}});
const fn=kind=>kind===0?lit({setter:'target'}):read('saved');
const get=kind=>kind===0?read('target'):invoke(lit({accessor:'#nested1'}));
const target=(kind,activate=true)=>kind===0?[['signal','target',1]]:[
  ['signal','saved',undefined],['program','save',[['updateExpr','saved',arg(0)]]],
  ['root','targetScope',callWith('save',scope(lit(1),{localSetter:0},{lazy:kind===2}))],['flush'],
  ...(activate?[['evaluate',get(kind)],['flush']]:[])
];
for(const kind of [0,1,2])for(const copies of [1,2,3]){
  await scenario('same setter cleanup retains canonical aliases '+JSON.stringify({kind,copies}),[
    ...target(kind),['root','cleaner',lit(0)],
    ...Array.from({length:copies},()=>['evaluate',under(owner('cleaner'),onCleanup(fn(kind)))]),
    ['disposeOwner','cleaner'],['flush'],['evaluate',get(kind)],['dispose']
  ]);
}
for(const kind of [0,1,2])for(const first of ['first','second']){
  await scenario('setter cleanup shared by independent owners '+JSON.stringify({kind,first}),[
    ...target(kind),['root','first',lit(0)],['root','second',lit(0)],
    ['evaluate',under(owner('first'),onCleanup(fn(kind)))],['evaluate',under(owner('second'),onCleanup(fn(kind)))],
    ['disposeOwner',first],['flush'],['evaluate',get(kind)],['dispose'],['flush']
  ]);
}
for(const kind of [0,1,2])for(const before of [false,true]){
  await scenario('setter cleanup follows LIFO with named writes '+JSON.stringify({kind,before}),[
    ...target(kind),['signal','marker',0],['program','mark',[['set',kind===0?'target':'marker',9]]],['program','attach',[['cleanup','mark']]],
    ['root','cleaner',before?seq(onCleanup(fn(kind)),call('attach')):seq(call('attach'),onCleanup(fn(kind)))],
    ['disposeOwner','cleaner'],['flush'],['read','marker'],['evaluate',get(kind)],['dispose']
  ]);
}
for(const kind of [0,1,2])for(const before of [false,true]){
  await scenario('throwing cleanup interrupts setter list in source order '+JSON.stringify({kind,before}),[
    ...target(kind),['program','bad',[['throw',7]]],['program','attach',[['cleanup','bad']]],
    ['root','cleaner',before?seq(onCleanup(fn(kind)),call('attach')):seq(call('attach'),onCleanup(fn(kind)))],
    ['disposeOwner','cleaner'],['flush'],['evaluate',get(kind)],['disposeOwner','cleaner'],['flush'],['dispose']
  ]);
}
for(const kind of [0,1,2])for(const immediate of [false,true]){
  await scenario('pending setter registers only after function delivery '+JSON.stringify({kind,immediate}),[
    ...target(kind),['future','p',{immediate}],['memo','function',future('p')],
    ['memo','m',onCleanup(read('function'))],['effect','user',read('m'),{user:true}],['flush'],
    ['resolve','p',{setter:kind===0?'target':'#nested1'}],['tick'],['flush'],['read','m'],
    ['dispose'],['flush'],['evaluate',get(kind)]
  ]);
}
for(const kind of [0,1,2]){
  await scenario('registration on a dead owner preserves production behavior '+kind,[
    ...target(kind),['root','cleaner',lit(0)],['disposeOwner','cleaner'],
    ['evaluate',under(owner('cleaner'),onCleanup(fn(kind)))],['disposeOwner','cleaner'],['flush'],['evaluate',get(kind)],['dispose']
  ]);
  await scenario('setter and root cleanup retain detached-list reentry '+kind,[
    ...target(kind),['root','first',lit(0)],['root','second',lit(0)],
    ['evaluate',under(owner('first'),onCleanup(fn(kind)))],['evaluate',under(owner('first'),onCleanup(disposer('second')))],
    ['evaluate',under(owner('second'),onCleanup(disposer('first')))],
    ['disposeOwner','first'],['flush'],['evaluate',get(kind)],['dispose']
  ]);
}
for(const immediate of [false,true]){
  await scenario('setter cleanup of a held writable derivation '+immediate,[
    ['signal','version',0],['signal','saved',undefined],['signal','getter',undefined],
    ['program','save',[['updateExpr','saved',arg(0)],['updateExpr','getter',arg(1)]]],
    ['root','targetScope',scope(read('version'),callWith('save',{localSetter:0},{localAccessor:0}))],['flush'],
    ['future','p',{immediate}],['memo','slow',select(read('version'),future('p'),lit(0))],
    ['effect','view',seq(read('version'),invoke(read('getter')),read('slow'))],['flush'],
    ['root','cleaner',onCleanup(read('saved'))],['set','version',1],['flush'],['disposeOwner','cleaner'],['flush'],
    ['resolve','p',7],['tick'],['flush'],['evaluate',invoke(read('getter'))],['dispose']
  ]);
}
await scenario('cleanup before first lazy accessor follows its activation rule',[
  ...target(2,false),['root','cleaner',onCleanup(fn(2))],['disposeOwner','cleaner'],['flush'],['evaluate',get(2)],['dispose']
]);
for(const kind of [0,1,2]){
  const b=new BendRuntime(),s=new SolidRuntime({module:await import('../build/solid.mjs?native-setter-cleanup='+kind)});
  try{
    for(const runtime of [b,s])for(const [op,...args] of target(kind))runtime[op](...args);
    for(const runtime of [b,s]){
      const value=runtime.evaluate(fn(kind)),before=runtime===b?list(b.world.cleanupPrograms).length:0;
      assert.equal(runtime.evaluate(onCleanup(fn(kind))),value,'no-owner registration returns the original setter');
      if(runtime===b)assert.equal(list(b.world.cleanupPrograms).length,before,'no owner allocates no callback encoding');
      runtime.evaluate(under(owner('root'),onCleanup(fn(kind))));runtime.evaluate(under(owner('root'),onCleanup(fn(kind))));
      if(runtime===b){
        const ids=callbackIds(b.nodes()[1].disposal);assert.equal(ids[0],ids[1]);
        assert.equal(list(b.world.cleanupPrograms).length,before+1,'one canonical callback per setter');
      }
      runtime.dispose();runtime.flush();
    }
  }finally{for(const runtime of [b,s]){runtime.attempt('dispose');runtime.resetErrorHalt();runtime.attempt('flush');}}
}
console.log(`${count} setter-cleanup histories match pinned TS callable aliases, no-argument writes, LIFO, pending/held frames, exceptions and reentrant disposal.`);
