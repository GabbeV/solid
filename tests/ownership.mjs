import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,ABI} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),call=call=>({call}),future=future=>({future});
const select=(c,y,n)=>({select:[c,y,n]}),add=(a,b)=>({add:[a,b]});
const owner=owner=>lit({owner}),withOwner=(owner,body)=>({withOwner:[owner,body]});
const current={owner:true},observer={observer:true},disposed=disposed=>({disposed});
const bendOwnerValue=id=>ABI.vOwner(id);
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?ownership='+count);
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
      const ownerName=o=>o===null?null:Object.entries(s.owners).find(([,value])=>value===o)?.[0]??s.sourceNames.get(o)??s.namedOwners.get(o)??s.observe(o);
      for(const [rootName,root] of Object.entries(s.owners)){
        const n=b.nodes()[b.ownerId(rootName)],bn=id=>id?(b.reverse[id]??b.observe(b.decode(bendOwnerValue(id)))):null;
        assert.deepEqual({flags:n.flags,config:n.config,parent:bn(n.parent),computed:bn(n.parentComputed),first:bn(n.firstChild),next:bn(n.nextSibling),prev:bn(n.prevSibling),scope:n.scope,children:n.childCount},
          {flags:root._flags,config:root._config,parent:ownerName(root._parent),computed:ownerName(root._parentComputed),first:ownerName(root._firstChild),next:ownerName(root._nextSibling),prev:ownerName(root._prevSibling),scope:0,children:root._childCount},`${name}: ${rootName} owner state after ${op}`);
      }
      for(const [node,nodeName] of s.sourceNames){
        assert.equal(b.nodes()[b.ids[nodeName]].height,node._height,`${name}: ${nodeName} height`);
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
await scenario('owner APIs outside a callback',[
  ['evaluate',current],['evaluate',observer],['evaluate',withOwner(owner('root'),current)],['evaluate',current],
  ['evaluate',withOwner(owner('root'),observer)],['evaluate',disposed(owner('root'))]
]);
for(const transparent of [false,true])for(const detached of [false,true])for(const body of [lit(7),current,observer,{untrack:current}]){
  await scenario(`root callback ${transparent}/${detached}/${JSON.stringify(body)}`,[
    ['root','inner',body,{owner:detached?null:'root',transparent}],['evaluate',disposed(owner('inner'))],
    ['evaluate',withOwner(owner('inner'),current)],['evaluate',withOwner(owner('inner'),observer)],
    ['dispose'],['evaluate',disposed(owner('inner'))],['disposeOwner','inner'],['evaluate',disposed(owner('inner'))]
  ]);
}
for(const transparent of [false,true])for(const parent of ['root','first']){
  await scenario(`nested roots and ownership ${transparent}/${parent}`,[
    ['root','first',lit(1)],['root','second',current,{owner:parent,transparent}],['root','third',observer,{owner:'second'}],
    ['disposeOwner','second'],['evaluate',disposed(owner('third'))],['disposeOwner','first'],['evaluate',disposed(owner('second'))]
  ]);
}
for(const lazy of [false,true])for(const user of [false,true]){
  await scenario(`memo/effect under a root ${lazy}/${user}`,[
    ['root','inner',lit(0)],['signal','x',1],['memo','m',read('x'),{lazy,owner:'inner'}],['effect','effect',read('m'),{user,owner:'inner'}],
    ['flush'],['set','x',4],['flush'],['disposeOwner','inner'],['set','x',7],['flush'],['read','m']
  ]);
}
for(const ownerExpr of [current,observer,{untrack:current},{untrack:observer}]){
  await scenario('computed owner introspection '+JSON.stringify(ownerExpr),[
    ['signal','x',1],['memo','m',{seq:[read('x'),ownerExpr]}],['read','m'],['effect','effect',read('m'),{user:true}],
    ['flush'],['set','x',4],['flush'],['read','m'],['dispose'],['evaluate',disposed(owner('m'))]
  ]);
}
for(const target of ['root','captured',null])for(const untracked of [false,true]){
  const chosen=target===null?lit(null):owner(target),body=withOwner(chosen,read('x'));
  await scenario(`runWithOwner read ${target}/${untracked}`,[
    ['root','captured',lit(0)],['signal','x',1],['signal','tick',0],
    ['memo','m',add(read('tick'),untracked?{untrack:body}:body)],['effect','effect',read('m')],
    ['set','x',7],['flush'],['read','m'],['set','tick',1],['flush'],['read','m']
  ]);
}
for(const target of ['root','captured',null]){
  const chosen=target===null?lit(null):owner(target);
  await scenario('cleanup attaches to entered owner '+target,[
    ['root','captured',lit(0)],['program','clean',[['emit',30]]],['program','register',[['cleanup','clean'],['return',current]]],
    ['evaluate',withOwner(chosen,call('register'))],['disposeOwner','captured'],['dispose']
  ]);
  await scenario('withOwner restores a failed compute '+target,[
    ['root','captured',lit(0)],['signal','on',false],['signal','x',1],
    ['memo','m',select(read('on'),read('x'),withOwner(chosen,{raise:'bad'}))],['effect','user',read('m'),{user:true}],
    ['flush'],['read','m'],['set','on',true],['flush'],['read','m'],['set','x',4],['flush']
  ]);
}
for(const cause of [undefined,null,99,'bad',{owner:'root'},{error:1,kind:'TypeError',message:'bad'}]){
  await scenario('failed root remains linked '+String(cause),[
    ['program','clean',[['emit',30]]],['program','body',[['cleanup','clean'],['throw',cause]]],
    ['root','failed',call('body')],['evaluate',disposed(owner('failed'))],['dispose'],['evaluate',disposed(owner('failed'))]
  ]);
}
await scenario('entered computed owner restores observer after body',[
  ['signal','x',1],['memo','captured',lit(7)],['program','body',[['return',withOwner(owner('captured'),current)]]],
  ['memo','m',{seq:[call('body'),read('x'),observer]}],['effect','view',read('m')],['set','x',4],['flush'],['read','m']
]);
await scenario('owner values preserve strict identity in data and throws',[
  ['root','inner',current],['signal','which',{owner:'inner'}],['memo','m',read('which')],
  ['effect','view',read('m')],['evaluate',{same:[read('m'),owner('inner')]}],
  ['set','which',{owner:'inner'}],['flush'],['set','which',{owner:'root'}],['flush'],['evaluate',{same:[read('m'),owner('root')]}]
]);
await scenario('cleanup registration with a disposed owner follows production behavior',[
  ['root','inner',lit(1)],['disposeOwner','inner'],['program','clean',[['emit',30]]],['program','register',[['cleanup','clean']]],
  ['evaluate',withOwner(owner('inner'),call('register'))],['disposeOwner','inner'],['evaluate',disposed(owner('inner'))]
]);
for(const transparent of [false,true])for(const detached of [false,true]){
  const root={root:current,transparent},body=detached?withOwner(lit(null),root):root;
  await scenario(`inline root callback ${transparent}/${detached}`,[
    ['signal','saved',null],['signal','x',1],['program','save',[['setExpr','saved',body]]],
    ['evaluate',withOwner(owner('root'),call('save'))],['flush'],['evaluate',disposed(read('saved'))],
    ['dispose'],['evaluate',disposed(read('saved'))],['evaluate',{disposeRoot:read('saved')}],['evaluate',disposed(read('saved'))]
  ]);
}
for(const transparent of [false,true])for(const throwBody of [false,true]){
  await scenario(`inline root cleanup and partial state ${transparent}/${throwBody}`,[
    ['signal','saved',null],['program','clean',[['emit',30]]],['program','body',[
      ['cleanup','clean'],['setExpr','saved',current],throwBody?['throw','bad']:['return',observer]
    ]],
    ['evaluate',withOwner(owner('root'),{root:call('body'),transparent})],['flush'],
    ['evaluate',withOwner(read('saved'),current)],['evaluate',{disposeRoot:read('saved')}],['evaluate',disposed(read('saved'))],['dispose']
  ]);
}
for(const immediate of [false,true])for(const value of [false,7]){
  await scenario(`inline root during pending compute ${immediate}/${value}`,[
    ['signal','saved',null],['future','p',{immediate}],['memo','data',future('p')],
    ['program','clean',[['emit',30]]],['program','body',[['cleanup','clean'],['setExpr','saved',current],['return',read('data')]]],
    ['memo','m',{root:call('body')}],['effect','view',read('m')],['flush'],['resolve','p',value],['tick'],['read','m'],
    ['evaluate',disposed(read('saved'))],['dispose'],['evaluate',disposed(read('saved'))]
  ]);
}
await scenario('inline root reads keep enclosing previous argument as lexical data',[
  ['signal','x',1],['memo','m',{seq:[read('x'),{root:{select:[{prev:true},lit(7),lit(3)]}}]}],
  ['effect','view',read('m')],['set','x',2],['flush'],['read','m']
]);
await scenario('nested inline roots share nearest computed without tracking',[
  ['signal','x',1],['signal','tick',0],['memo','m',add(read('tick'),{root:{root:read('x')}})],
  ['effect','view',read('m')],['set','x',4],['flush'],['read','m'],['set','tick',1],['flush'],['read','m']
]);
for(const immediate of [false,true])for(const reject of [false,true]){
  await scenario(`owner argument pending/error ${immediate}/${reject}`,[
    ['root','target',lit(0)],['future','p',{immediate}],['memo','chosen',future('p')],
    ['memo','m',withOwner(read('chosen'),current)],['effect','user',read('m'),{user:true}],['flush'],
    [reject?'reject':'resolve','p',reject?'bad':{owner:'target'}],['tick'],['read','m'],['dispose']
  ]);
}
await scenario('owner identity is distinct from other owners and opaque references',[
  ['root','target',lit(0)],['evaluate',{same:[owner('root'),owner('target')]}],
  ['evaluate',{same:[owner('root'),lit({ref:1})]}],['evaluate',{same:[owner('target'),owner('target')]}]
]);
for(const lazy of [false,true])for(const transparent of [false,true]){
  await scenario(`root forwards nearest computed ${lazy}/${transparent}`,[
    ['signal','tick',0],['signal','x',1],['memo','parent',read('tick')],
    ['root','nested',current,{owner:'parent',transparent}],['memo','child',read('x'),{owner:'nested',lazy}],
    ['effect','view',read('child')],['set','x',4],['flush'],['set','tick',1],['flush'],['read','child'],
    ['evaluate',disposed(owner('nested'))],['set','x',7],['flush'],['read','child']
  ]);
}
for(const Runtime of [BendRuntime,SolidRuntime]){
  const runtime=new Runtime(),handle=runtime.root('inner',current);
  assert.equal(runtime.evaluate(withOwner(owner('inner'),current)),handle,'owner result preserves actual identity');
  runtime.signal('saved',{owner:'inner'});
  assert.equal(runtime.read('saved'),handle,'owner data does not clone the owner');
  const error=new Error('opaque');error.owner='application data';
  runtime.signal('error',error);
  assert.equal(runtime.read('error'),error,'an opaque native Error.owner is not an owner token');
  runtime.dispose();runtime.flush();
}
console.log(`${count} ownership histories match pinned TS roots, owner/observer identity, runWithOwner scopes, cleanup attachment and restoration.`);
