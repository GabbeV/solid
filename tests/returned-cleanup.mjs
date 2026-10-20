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
  const module=await import('../build/solid.mjs?returned-cleanup='+count);
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
        const bc=b.nodes()[b.ownerId(nodeName)].cleanup,sc=node._cleanup;
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
const seq=(...seq)=>({seq});
const options=(user,extra={})=>({user,program:'choose',returnCleanup:true,...extra});
const setup=()=>[
  ['signal','version',0],['signal','first',1],['signal','second',2],
  ['root','left',lit(0)],['root','right',lit(0)]
];
const choices=[['root',disposer('left'),disposer('right')],['setter',lit({setter:'first'}),lit({setter:'second'})]];
for(const [kind,left,right] of choices)for(const user of [false,true])for(const schedule of [false,true])for(const defer of [false,true]){
  await scenario('dynamic cleanup replacement '+JSON.stringify({kind,user,schedule,defer}),[
    ...setup(),['program','choose',[['return',select(arg(0),right,left)]]],
    ['effect','view',read('version'),options(user,{schedule,defer})],['flush'],
    ['set','version',1],['flush'],['read','first'],['read','second'],
    ['set','version',2],['flush'],['dispose'],['flush'],['read','first'],['read','second']
  ]);
}
for(const [kind,left] of choices)for(const user of [false,true]){
  await scenario('undefined removes prior cleanup '+JSON.stringify({kind,user}),[
    ...setup(),['program','choose',[['return',select(arg(0),lit(undefined),left)]]],
    ['effect','view',read('version'),options(user)],['flush'],['set','version',1],['flush'],['dispose'],['flush']
  ]);
  await scenario('application read selects cleanup without tracking '+JSON.stringify({kind,user}),[
    ...setup(),['signal','selection',0],['program','choose',[['return',select(read('selection'),lit(undefined),left)]]],
    ['effect','view',read('version'),options(user)],['flush'],['set','selection',1],['flush'],
    ['set','version',1],['flush'],['dispose'],['flush']
  ]);
  await scenario('same callable in effect and owner slots '+JSON.stringify({kind,user}),[
    ...setup(),['root','cleaner',onCleanup(left)],['program','choose',[['return',left]]],
    ['effect','view',read('version'),options(user)],['effect','other',read('version'),options(user)],['flush'],
    ['disposeOwner','cleaner'],['flush'],['set','version',1],['flush'],['dispose'],['flush']
  ]);
}
for(const user of [false,true])for(const mode of ['beforeReturn','cleanup']){
  await scenario('throw skips next cleanup assignment '+JSON.stringify({user,mode}),[
    ...setup(),['program','bad',[['throw',7]]],['program','attach',[['cleanup','bad']]],
    ...(mode==='cleanup'?[['root','doomed',call('attach')]]:[]),
    ['program','choose',[['return',select(arg(0),{raise:9},mode==='cleanup'?disposer('doomed'):disposer('left'))]]],
    ['effect','view',read('version'),options(user)],['flush'],['set','version',1],['flush'],
    ['dispose'],['resetErrorHalt'],['flush']
  ]);
}
for(const user of [false,true])for(const immediate of [false,true]){
  await scenario('pending compute retains previous cleanup until apply '+JSON.stringify({user,immediate}),[
    ...setup(),['future','p',{immediate}],['program','choose',[['return',select(arg(0),disposer('right'),disposer('left'))]]],
    ['effect','view',select(read('version'),future('p'),lit(0)),options(user)],['flush'],
    ['set','version',1],['flush'],['resolve','p',1],['tick'],['flush'],['dispose'],['flush']
  ]);
}
for(const cleanup of [false,true])for(const errorReturn of [false,true]){
  await scenario('error arm keeps cleanup unless helper called '+JSON.stringify({cleanup,errorReturn}),[
    ...setup(),['program','choose',[['return',disposer('left')]]],
    ['program','error',[...(cleanup?[['previousCleanup']]:[]),...(errorReturn?[['return',disposer('right')]]:[])]],
    ['effect','view',select(read('version'),{raise:7},lit(0)),options(true,{error:'error'})],['flush'],
    ['set','version',1],['flush'],['dispose'],['flush']
  ]);
}
for(const user of [false,true])for(const lazy of [false,true]){
  await scenario('captured writable setter returned by inline application '+JSON.stringify({user,lazy}),[
    ['signal','version',0],['signal','saved',undefined],['program','save',[['updateExpr','saved',arg(0)]]],
    ['root','scope',{signalComputeScope:{compute:lit(3),options:{lazy},body:seq(
      {call:'save',args:[{localAccessor:0}]},
      {effectCreate:read('version'),body:select(arg(0),lit(undefined),{localSetter:0}),options:{user,returnCleanup:true}}
    )}}],['flush'],['evaluate',invoke(read('saved'))],['set','version',1],['flush'],
    ['evaluate',invoke(read('saved'))],['dispose'],['flush']
  ]);
}
for(const user of [false,true]){
  await scenario('named nested application preserves value and previous arguments '+user,[
    ...setup(),['program','choose',[['return',select(arg(1),disposer('right'),disposer('left'))]]],
    ['root','scope',{effectCreate:read('version'),options:options(user)}],['flush'],
    ['set','version',1],['flush'],['set','version',2],['flush'],['dispose'],['flush']
  ]);
  await scenario('disposing application owner from prior cleanup retains assignment order '+user,[
    ['signal','version',0],['root','scope',lit(0)],['program','choose',[['return',disposer('scope')]]],
    ['effect','view',read('version'),options(user,{owner:'scope'})],['flush'],
    ['set','version',1],['flush'],['disposeOwner','scope'],['dispose'],['flush']
  ]);
}
console.log(`${count} dynamic returned-cleanup histories match pinned TS selection, aliases, replacement, pending/error arms and disposal order.`);
