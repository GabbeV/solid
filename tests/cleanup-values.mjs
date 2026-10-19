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
  const module=await import('../build/solid.mjs?cleanup-values='+count);
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
for(const count of [1,2,3])for(const throws of [false,true])for(const detached of [false,true]){
  await scenario(`register same bound disposer ${count}/${throws}/${detached}`,[
    ['program','clean',[['emit',30],...(throws?[['throw','bad']]:[])]],
    ['program','body',[['cleanup','clean'],['return',arg(0)]]],['root','target',callWith('body',arg(0)),{owner:detached?null:'root'}],
    ...Array.from({length:count},()=>['evaluate',under(owner('root'),onCleanup(disposer('target')))]),
    ['dispose'],['evaluate',{disposed:owner('target')}],['disposeOwner','target']
  ]);
}
for(const first of ['first','second']){
  await scenario('same function identity shared by separate owners '+first,[
    ['program','clean',[['emit',30]]],['program','body',[['cleanup','clean'],['return',arg(0)]]],
    ['root','target',callWith('body',arg(0)),{owner:null}],['root','first',lit(0)],['root','second',lit(0)],
    ['evaluate',under(owner('first'),onCleanup(disposer('target')))],['evaluate',under(owner('second'),onCleanup(disposer('target')))],
    ['disposeOwner',first],['evaluate',{disposed:owner('target')}],['dispose'],['disposeOwner','target']
  ]);
}
for(const before of [false,true]){
  await scenario('LIFO bound disposer mixed with named callbacks '+before,[
    ['program','clean',[['emit',30]]],['program','marker',[['emit',20]]],
    ['program','body',[['cleanup','clean'],['return',arg(0)]]],['root','target',callWith('body',arg(0)),{owner:null}],
    ['program','register',before?[['eval',onCleanup(disposer('target'))],['cleanup','marker']]:[['cleanup','marker'],['eval',onCleanup(disposer('target'))]]],
    ['evaluate',under(owner('root'),call('register'))],['dispose']
  ]);
}
await scenario('registration without an owner returns its function and does not attach it',[
  ['program','clean',[['emit',30]]],['program','body',[['cleanup','clean'],['return',arg(0)]]],
  ['root','target',callWith('body',arg(0)),{owner:null}],['evaluate',onCleanup(disposer('target'))],['dispose'],
  ['evaluate',{disposed:owner('target')}],['disposeOwner','target']
]);
await scenario('self disposer registration is inert during its own teardown',[
  ['root','target',onCleanup(arg(0)),{owner:null}],['disposeOwner','target'],['disposeOwner','target']
]);
await scenario('root init can pass a disposer through a named cleanup callback',[
  ['program','body',[['return',onCleanup(arg(0))]]],['root','target',callWith('body',arg(0)),{owner:null}],['disposeOwner','target']
]);
await scenario('mutually registered disposers retain detached-list reentry semantics',[
  ['root','first',arg(0),{owner:null}],['root','second',arg(0),{owner:null}],
  ['evaluate',under(owner('first'),onCleanup(disposer('second')))],['evaluate',under(owner('second'),onCleanup(disposer('first')))],
  ['disposeOwner','first'],['evaluate',{disposed:owner('first')}],['evaluate',{disposed:owner('second')}]
]);
await scenario('a child cleanup can dispose its parent while the child list is draining',[
  ['program','clean',[['emit',30]]],['program','marker',[['emit',20]]],['program','register',[['cleanup','clean'],['return',arg(0)]]],
  ['root','parent',callWith('register',arg(0))],['root','child',onCleanup(disposer('parent')),{owner:'parent'}],
  ['root','sibling',call('register'),{owner:'parent'}],['disposeOwner','child'],['evaluate',{disposed:owner('parent')}],['dispose']
]);
await scenario('registering on a dead owner follows production behavior',[
  ['root','owner',lit(0)],['root','target',arg(0),{owner:null}],['disposeOwner','owner'],
  ['evaluate',under(owner('owner'),onCleanup(disposer('target')))],['disposeOwner','owner'],['evaluate',{disposed:owner('target')}],['disposeOwner','target']
]);
for(const immediate of [false,true]){
  await scenario('pending disposer expression registers only after delivery '+immediate,[
    ['root','target',arg(0),{owner:null}],['future','p',{immediate}],['memo','fn',future('p')],
    ['memo','m',onCleanup(read('fn'))],['effect','user',read('m'),{user:true}],['flush'],
    ['resolve','p',{rootDisposer:'target'}],['tick'],['read','m'],['dispose'],['evaluate',{disposed:owner('target')}]
  ]);
}
for(const Runtime of [BendRuntime,SolidRuntime]){
  const runtime=new Runtime(),dispose=runtime.root('target',arg(0),{owner:null});
  const before=Runtime===BendRuntime?list(runtime.world.cleanupPrograms).length:undefined;
  assert.equal(runtime.evaluate(onCleanup(disposer('target'))),dispose,'onCleanup returns its original callable');
  if(Runtime===BendRuntime)assert.equal(list(runtime.world.cleanupPrograms).length,before,'no owner means no callback-arena allocation');
  assert.equal(runtime.evaluate(under(owner('root'),onCleanup(disposer('target')))),dispose,'owned registration preserves function identity');
  runtime.evaluate(under(owner('root'),onCleanup(disposer('target'))));
  if(Runtime===BendRuntime){
    const ids=list(runtime.nodes()[1].disposal.callbacks);
    assert.equal(ids[0],ids[1],'repeated registrations share a canonical callable ID');
    assert.equal(list(runtime.world.cleanupPrograms).length,before+1,'one admitted bound function receives one callable encoding');
  }
  runtime.dispose();assert.equal(runtime.evaluate({disposed:owner('target')}),true);runtime.flush();
}
console.log(`${count} bound-cleanup histories match pinned TS callable return/alias identity, LIFO order, no-owner behavior, pending registration and reentrant/throwing teardown.`);
