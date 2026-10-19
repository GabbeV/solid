import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),call=call=>({call}),future=future=>({future});
const select=(c,y,n)=>({select:[c,y,n]}),add=(a,b)=>({add:[a,b]});
const arg=index=>({argument:index}),invoke=invoke=>({invoke}),current={owner:true};
const callWith=(call,...args)=>({call,args});
const owner=name=>lit({owner:name}),get=(name,owner)=>({getContext:{name,...(owner===undefined?{}:{owner})}});
const put=(name,value=lit(undefined),owner)=>({setContext:{name,value,...(owner===undefined?{}:{owner})}});
const under=(target,body)=>({withOwner:[target,body]});
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?contexts='+count);
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
      for(const [node,nodeName] of owners)for(const [other,otherName] of owners){
        assert.equal(b.nodes()[b.ownerId(nodeName)].scope===b.nodes()[b.ownerId(otherName)].scope,node._context===other._context,`${name}: record alias ${nodeName}/${otherName} after ${op}`);
      }
      for(const [node,nodeName] of owners)for(const [keyName,key] of Object.entries(s.contexts)){
        const scope=b.nodes()[b.ownerId(nodeName)].scope,entries=list(list(b.world.contextRecords)[scope].entries);
        const keyNames=new Map(Object.entries(s.contexts).map(([name,key])=>[key.id,name]));
        const ids=new Map(Object.entries(b.contexts).map(([name,id])=>[id,name]));
        assert.deepEqual(entries.map(entry=>ids.get(entry.key)),Reflect.ownKeys(node._context).map(key=>keyNames.get(key)),`${name}: symbol key order after ${op}`);
        const entry=entries.find(e=>e.key===b.contexts[keyName]);
        assert.equal(!!entry,Object.hasOwn(node._context,key.id),`${name}: ${nodeName}/${keyName} key presence after ${op}`);
        if(entry)assert.deepEqual(b.errorShape(b.decode(entry.value)),s.errorShape(node._context[key.id]),`${name}: ${nodeName}/${keyName} record value after ${op}`);
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
for(const value of [undefined,null,false,true,0,3,NaN,'','hello',{ref:7},{error:1,kind:'TypeError',message:'data'},{owner:'root'}]){
  await scenario('context default '+String(value),[
    ['context','k',value,'shared description'],['evaluate',get('k')],['evaluate',get('k',owner('root'))],
    ['root','inner',get('k')],['evaluate',get('k',owner('inner'))],['evaluate',get('k',owner('inner'))],['dispose']
  ]);
  await scenario('provided context value '+String(value),[
    ['context','k',73],['evaluate',put('k',lit(value),owner('root'))],['evaluate',get('k',owner('root'))],
    ['root','inner',get('k')],['evaluate',put('k',lit(undefined),owner('inner'))],['evaluate',get('k',owner('inner'))],['evaluate',get('k',owner('root'))]
  ]);
}
for(const target of [lit(undefined),lit(null),owner('root')])for(const inside of [false,true]){
  const wrap=body=>inside?under(owner('root'),body):body;
  await scenario(`default owner parameters ${JSON.stringify(target)}/${inside}`,[
    ['context','k',7],['evaluate',wrap(get('k',target))],['evaluate',wrap(put('k',lit(11),target))],['evaluate',get('k',owner('root'))]
  ]);
}
await scenario('context records are snapshots copied on each write',[
  ['context','k','default'],['root','before',get('k')],['evaluate',put('k',lit('A'),owner('root'))],['root','afterA',get('k')],
  ['evaluate',put('k',lit('B'),owner('root'))],['root','afterB',get('k')],['evaluate',get('k',owner('before'))],['evaluate',get('k',owner('afterA'))],
  ['evaluate',put('k',lit('C'),owner('afterA'))],['root','grandchild',get('k'),{owner:'afterA'}],
  ['evaluate',get('k',owner('root'))],['evaluate',get('k',owner('afterB'))],['evaluate',get('k',owner('grandchild'))]
]);
for(const lazy of [false,true])for(const user of [false,true]){
  await scenario(`computed/effect record inheritance ${lazy}/${user}`,[
    ['context','k','default'],['signal','tick',0],['evaluate',put('k',lit('A'),owner('root'))],
    ['memo','m',{seq:[read('tick'),get('k')]},{lazy}],['evaluate',put('k',lit('B'),owner('root'))],
    ['effect','effect',read('m'),{user}],['flush'],['read','m'],['set','tick',1],['flush'],['read','m'],
    ['memo','late',get('k')],['read','late'],['evaluate',put('k',lit('M'),owner('m'))],['set','tick',2],['flush'],['read','m']
  ]);
}
for(const immediate of [false,true])for(const reject of [false,true]){
  await scenario(`async context data ${immediate}/${reject}`,[
    ['context','k',0],['future','p',{immediate}],['evaluate',put('k',future('p'),owner('root'))],['memo','m',get('k')],
    ['effect','view',read('m')],['awaitValue','wait',read('m')],['tick'],[reject?'reject':'resolve','p',reject?'bad':7],['tick'],['read','m']
  ]);
}
for(const noOwner of [false,true]){
  const body=noOwner?under(lit(null),get('k')):get('k');
  await scenario('context failures wrap and retain the original error '+noOwner,[
    ['context','k'],['signal','on',false],['signal','error',null],['program','handler',[['setExpr','error',arg(0)]]],
    ['memo','m',select(read('on'),lit(7),body)],['effect','user',read('m'),{user:true,error:'handler'}],['flush'],['read','error'],
    ['read','m'],['read','m'],['set','on',true],['flush'],['read','m']
  ]);
}
for(const failing of ['none','value','owner']){
  await scenario('setContext argument order '+failing,[
    ['context','k',7],['program','value',[['emit',1],...(failing==='value'?[['throw','bad']]:[['return',lit(11)]])]],
    ['program','owner',[['emit',2],...(failing==='owner'?[['throw','bad']]:[['return',owner('root')]])]],
    ['evaluate',put('k',call('value'),call('owner'))],['evaluate',get('k',owner('root'))]
  ]);
}
await scenario('context keys with identical descriptions remain distinct',[
  ['context','first',1,'same'],['context','second',2,'same'],['evaluate',put('first',lit(11),owner('root'))],
  ['evaluate',get('first',owner('root'))],['evaluate',get('second',owner('root'))],['evaluate',put('second',lit(12),owner('root'))],
  ['evaluate',get('first',owner('root'))],['evaluate',get('second',owner('root'))]
]);
await scenario('undefined falls back but null remains provided',[
  ['context','k'],['evaluate',put('k',lit(null),owner('root'))],['evaluate',get('k',owner('root'))],
  ['evaluate',put('k',lit(undefined),owner('root'))],['evaluate',get('k',owner('root'))],['root','inner',get('k')]
]);
await scenario('context access does not add a reactive dependency',[
  ['context','k',1],['signal','tick',0],['memo','m',{seq:[read('tick'),get('k')]}],['effect','view',read('m')],
  ['evaluate',put('k',lit(7),owner('m'))],['flush'],['read','m'],['set','tick',1],['flush'],['read','m']
]);
await scenario('context writes in a computed body target its own record',[
  ['context','k',1],['signal','x',3],['memo','m',{seq:[put('k',read('x')),get('k')]}],['effect','view',read('m')],
  ['set','x',7],['flush'],['read','m'],['evaluate',get('k',owner('root'))]
]);
await scenario('context getters and setters bind user arguments',[
  ['context','k',1],['program','body',[['eval',put('k',arg(0),arg(1))],['return',get('k',arg(1))]]],
  ['evaluate',callWith('body',lit(7),owner('root'))],['root','inner',get('k')],['evaluate',callWith('body',lit(null),owner('inner'))],['evaluate',get('k',owner('root'))]
]);
await scenario('function context defaults and values are stored as data',[
  ['root','target',arg(0)],['context','k',{rootDisposer:'target'}],['root','inner',get('k')],
  ['evaluate',put('k',lit({rootDisposer:'target'}),owner('root'))],['evaluate',invoke(get('k',owner('root')))],
  ['evaluate',{disposed:owner('target')}],['evaluate',get('k',owner('inner'))]
]);
await scenario('disposed owners retain accessible context records in production',[
  ['context','k',7],['root','inner',get('k')],['disposeOwner','inner'],['evaluate',put('k',lit(11),owner('inner'))],['evaluate',get('k',owner('inner'))]
]);
await scenario('copy spread preserves symbol insertion order on replacement',[
  ['context','first',1],['context','second',2],['context','third',3],
  ['evaluate',put('third',lit(30),owner('root'))],['evaluate',put('first',lit(10),owner('root'))],
  ['root','child',lit(0)],['evaluate',put('third',lit(31),owner('root'))],['evaluate',put('second',lit(20),owner('root'))],
  ['evaluate',get('third',owner('child'))],['evaluate',get('third',owner('root'))]
]);
for(const Runtime of [BendRuntime,SolidRuntime]){
  const runtime=new Runtime();runtime.context('missing');runtime.context('value',7);
  assert.throws(()=>runtime.context('value',99),/Context names must be unique/);
  const failures=[];
  for(const expr of [get('value'),get('value'),get('missing',owner('root'))]){
    try{runtime.evaluate(expr);assert.fail('context read must throw');}catch(error){
      assert.equal(error.name,'Error');assert.equal(error.message,'');assert(error instanceof Error);failures.push(error);
    }
  }
  assert.notEqual(failures[0],failures[1],'each missing-owner access allocates a fresh Error');
  runtime.root('child',lit(0));
  const record=Runtime===BendRuntime?runtime.nodes()[1].scope:runtime.owner._context;
  runtime.evaluate(put('value',lit(7),owner('root')));
  const next=Runtime===BendRuntime?runtime.nodes()[1].scope:runtime.owner._context;
  const inherited=Runtime===BendRuntime?runtime.nodes()[runtime.ownerId('child')].scope:runtime.owners.child._context;
  assert.notEqual(next,record,'even an equal context write creates a fresh record');
  assert.equal(inherited,record,'existing children keep their original context record');
  runtime.dispose();runtime.flush();
}
console.log(`${count} context histories match pinned TS default/undefined/null rules, copied records, owner targeting, inheritance, errors, argument order and async/function data.`);
