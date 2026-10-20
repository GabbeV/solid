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
  const module=await import('../build/solid.mjs?arguments='+count);
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
for(const value of [undefined,null,false,true,0,3,NaN,'hello',{ref:7},{error:1,kind:'TypeError',message:'data'},{owner:'root'}])for(const index of [0,1,2]){
  await scenario(`ordinary arguments ${index}/${String(value)}`,[
    ['program','body',[['return',arg(index)],['emit',90]]],['memo','m',callWith('body',lit(value),lit(17))],['read','m'],['effect','view',read('m')],['flush']
  ]);
}
await scenario('argument reads run before callee statements in left-to-right order',[
  ['signal','x',1],['signal','y',2],['program','body',[['emit',10],['return',add(arg(0),arg(1))]]],
  ['memo','m',add(lit(17),callWith('body',read('x'),read('y')))],['effect','view',read('m')],['set','x',3],['set','y',5],['flush']
]);
await scenario('nested arguments bind to their own invocation',[
  ['program','inner',[['return',add(arg(0),arg(1))]]],['program','outer',[['eval',callWith('inner',arg(1),lit(2))],['return',callWith('inner',arg(0),lit(3))]]],
  ['memo','m',callWith('outer',lit(7),lit(11))],['read','m'],['effect','view',read('m')]
]);
await scenario('argument side effects precede later arguments and caller body',[
  ['signal','x',1],['program','first',[['emit',1],['set','x',7],['return',lit(3)]]],
  ['program','body',[['emit',2],['return',add(arg(0),arg(1))]]],
  ['memo','m',callWith('body',call('first'),read('x'))],['effect','view',read('m')],['flush'],['read','m']
]);
for(const immediate of [false,true])for(const reject of [false,true]){
  await scenario(`argument suspension ${immediate}/${reject}`,[
    ['future','p',{immediate}],['memo','data',future('p')],['program','body',[['emit',10],['return',add(arg(0),arg(1))]]],
    ['memo','m',add(lit(17),callWith('body',lit(3),read('data')))],['effect','view',read('m')],['flush'],
    [reject?'reject':'resolve','p',reject?'bad':7],['tick'],['read','m']
  ]);
}
for(const user of [false,true])for(const index of [0,1]){
  await scenario(`effect receives current/previous ${user}/${index}`,[
    ['signal','x',1],['signal','out',0],['program','body',[['setExpr','out',arg(index)]]],
    ['effect','effect',read('x'),{user,program:'body'}],['effect','sink',read('out'),{user:true}],['flush'],
    ['set','x',4],['flush'],['read','out'],['set','x',7],['flush'],['read','out']
  ]);
}
for(const cause of [undefined,null,false,99,'bad',{owner:'root'},{error:1,kind:'TypeError',message:'bad'}]){
  await scenario('error body receives original cause '+String(cause),[
    ['signal','on',true],['signal','out',0],['program','body',[['setExpr','out',arg(0)]]],
    ['effect','effect',select(read('on'),lit(1),{raise:cause}),{user:true,error:'body'}],['effect','sink',read('out'),{user:true}],['flush'],
    ['set','on',false],['flush'],['read','out'],['set','on',true],['flush']
  ]);
}
for(const transparent of [false,true])for(const detached of [false,true]){
  await scenario(`retain real init disposer ${transparent}/${detached}`,[
    ['signal','saved',null],['program','clean',[['emit',30]]],['program','body',[['cleanup','clean'],['return',arg(0)]]],
    ['root','inner',callWith('body',arg(0)),{transparent,owner:detached?null:'root'}],
    ['update','saved',lit({rootDisposer:'inner'})],['flush'],['read','saved'],['evaluate',invoke(read('saved'))],['evaluate',{disposed:lit({owner:'inner'})}],['evaluate',invoke(read('saved'))]
  ]);
}
for(const viaUpdater of [false,true])for(const cleanupThrows of [false,true]){
  await scenario(`setter distinguishes function input/result ${viaUpdater}/${cleanupThrows}`,[
    ['signal','saved',0],['program','clean',[['emit',30],...(cleanupThrows?[['throw','bad']]:[])]],
    ['program','body',[['cleanup','clean'],['return',arg(0)]]],['root','inner',callWith('body',arg(0))],
    [viaUpdater?'update':'set','saved',viaUpdater?lit({rootDisposer:'inner'}):{rootDisposer:'inner'}],['flush'],['read','saved'],
    ['evaluate',{disposed:lit({owner:'inner'})}],...(viaUpdater?[['evaluate',invoke(read('saved'))]]:[])
  ]);
}
for(const update of [false,true])for(const cleanupThrows of [false,true]){
  await scenario(`evaluated setter function branch ${update}/${cleanupThrows}`,[
    ['signal','saved',0],['program','clean',[['emit',30],...(cleanupThrows?[['throw','bad']]:[])]],
    ['program','register',[['cleanup','clean'],['return',arg(0)]]],['root','inner',callWith('register',arg(0))],
    ['program','body',[[update?'updateExpr':'setExpr','saved',lit({rootDisposer:'inner'})]]],
    ['evaluate',call('body')],['flush'],['read','saved'],['evaluate',{disposed:lit({owner:'inner'})}]
  ]);
}
await scenario('imperative teardown setter invokes function updater before writing',[
  ['signal','saved',0],['root','inner',arg(0)],['program','write',[['set','saved',{rootDisposer:'inner'}],['emit',10]]],
  ['program','register',[['cleanup','write']]],['evaluate',{withOwner:[lit({owner:'root'}),call('register')]}],
  ['dispose'],['flush'],['read','saved'],['evaluate',{disposed:lit({owner:'inner'})}]
]);
await scenario('inline roots introduce fresh disposer parameter bindings',[
  ['signal','outer',null],['signal','inner',null],
  ['program','saveOuter',[['updateExpr','outer',arg(0)],['return',arg(0)]]],
  ['program','saveInner',[['updateExpr','inner',arg(0)],['return',arg(0)]]],
  ['root','first',{seq:[callWith('saveOuter',arg(0)),{root:callWith('saveInner',arg(0))}]}],['flush'],
  ['evaluate',{same:[read('outer'),read('inner')]}],['evaluate',invoke(read('inner'))],
  ['evaluate',{disposed:lit({owner:'first'})}],['evaluate',invoke(read('outer'))],['evaluate',{disposed:lit({owner:'first'})}]
]);
await scenario('bound disposer retains receiver when called under another owner',[
  ['root','first',arg(0)],['root','second',arg(0)],
  ['evaluate',{withOwner:[lit({owner:'second'}),invoke(lit({rootDisposer:'first'}))]}],
  ['evaluate',{disposed:lit({owner:'first'})}],['evaluate',{disposed:lit({owner:'second'})}]
]);
await scenario('a bound disposer can be a wrapped error cause',[
  ['root','inner',arg(0)],['program','fail',[['throwExpr',lit({rootDisposer:'inner'})]]],
  ['memo','m',call('fail')],['read','m'],['read','m'],['effect','user',read('m'),{user:true}],['flush']
]);
for(const immediate of [false,true]){
  await scenario('bound function travels as an async result '+immediate,[
    ['root','inner',arg(0)],['future','p',{immediate}],['memo','m',future('p')],['awaitValue','wait',read('m')],
    ['resolve','p',{rootDisposer:'inner'}],['tick'],['read','m'],['evaluate',invoke(read('m'))]
  ]);
}
for(const cleanupThrows of [false,true]){
  await scenario('teardown setter invokes a live detached disposer '+cleanupThrows,[
    ['signal','saved',0],['program','targetClean',[['emit',30],...(cleanupThrows?[['throw','bad']]:[])]],
    ['program','targetBody',[['cleanup','targetClean'],['return',arg(0)]]],
    ['root','target',callWith('targetBody',arg(0)),{owner:null}],
    ['program','write',[['emit',1],['set','saved',{rootDisposer:'target'}],['emit',2]]],
    ['program','register',[['cleanup','write']]],['evaluate',{withOwner:[lit({owner:'root'}),call('register')]}],
    ['dispose'],['flush'],['read','saved'],['evaluate',{disposed:lit({owner:'target'})}]
  ]);
}
for(const Runtime of [BendRuntime,SolidRuntime]){
  const runtime=new Runtime();runtime.program('clean',[['emit',30]]);runtime.program('body',[['cleanup','clean'],['return',arg(0)]]);
  const dispose=runtime.root('inner',callWith('body',arg(0)));
  assert.equal(typeof dispose,'function','returned init disposer must be callable');
  assert.equal(runtime.evaluate(lit({rootDisposer:'inner'})),dispose,'disposer materialization preserves identity');
  runtime.signal('saved',null);
  assert.equal(runtime.update('saved',lit({rootDisposer:'inner'})),dispose,'updater returns actual function data');
  runtime.flush();
  assert.equal(runtime.read('saved'),dispose,'stored function data retains identity');
  dispose.call({unrelated:true});
  assert.equal(runtime.evaluate({disposed:lit({owner:'inner'})}),true,'plain/bound call disposes its captured owner');
  assert.deepEqual(runtime.trace().filter(e=>e[0]==='cleanup'),[['cleanup',1,30]],'cleanup runs exactly once');
  dispose();
  assert.deepEqual(runtime.trace().filter(e=>e[0]==='cleanup'),[['cleanup',1,30]],'repeated disposer call is inert');
  runtime.signal('disposerInitializer',dispose);assert.equal(runtime.read('disposerInitializer'),undefined,'a disposer initializer selects the computed overload');
  assert.throws(()=>runtime.evaluate(callWith('body',lit(1),lit(2),lit(3))),/at most two arguments/);
  runtime.dispose();runtime.flush();
}
console.log(`${count} callback-argument histories match pinned TS binding/order, effect/error parameters, callable root disposers and setter function branches.`);
