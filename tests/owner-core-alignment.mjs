import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'owner-core-probe-'));
const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(dir,name),{recursive:true});
// Fixture admission only: the active runtime and owner/core step bodies stay
// unchanged. This exposes the real owner cleanup registration for direct probes.
fs.appendFileSync(path.join(dir,'runtime/api.bend'),'\ndef registerOwnerProgram(w: R.World, owner: Nat, callback: Nat) -> R.World:\n  O.cleanup(w, owner, callback)\n\ndef staticOwnerDispose(w: R.World, owner: Nat) -> R.World:\n  O.dispose(w, owner)\n');
process.once('exit',()=>fs.rmSync(dir,{recursive:true,force:true}));
const emitted=path.join(dir,'runtime.mjs');
const compiled=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'runtime/api.bend'),'-o',emitted],{encoding:'utf8'});
assert.equal(compiled.status,0,compiled.stderr);
process.env.BEND_EMIT_FILE=emitted;
const {BendRuntime,list,ABI,expression}=await import('../host/bend.mjs?owner-core-probe');
delete process.env.BEND_EMIT_FILE;

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
class ProbeClock {
  constructor(){this.now=0;this.serial=0;this.tasks=new Map();}
  setTimeout(callback,delay){const id=++this.serial;this.tasks.set(id,{callback,at:this.now+delay});return id;}
  clearTimeout(id){this.tasks.delete(id);}
  advance(ms){this.now+=ms;for(const [id,task]of [...this.tasks].sort((a,b)=>a[1].at-b[1].at||a[0]-b[0]))if(task.at<=this.now&&this.tasks.has(id)){this.tasks.delete(id);task.callback();}}
}
let count=0;
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?owner-core='+count);
  const b=new BendRuntime({async:true,clock:new ProbeClock()}),s=new SolidRuntime({module,clock:new ProbeClock()}),logs=[];
  b.advance=ms=>b.clock.advance(ms);s.advance=ms=>s.clock.advance(ms);
  b.install=(name,program)=>{b.world=ABI.registerOwnerProgram(b.world,b.ownerId(name),b.programs[program]);b.check();};
  b.disposeStatic=name=>{b.world=ABI.staticOwnerDispose(b.world,b.ownerId(name));b.check();};
  s.disposeStatic=name=>s.disposeOwner(name);
  s.install=(name,program)=>s.S.runWithOwner(s.ownerFor(name),()=>s.S.onCleanup(s.programs[program]));
  b.effectRead=(name,expr,cleanup,user=false)=>{
    const id=ABI.nextId(b.world);b.ids[name]=id;b.reverse[id]=name;
    if(!user)b.world=ABI.attach(b.world,1,2);
    b.world=ABI.createEffectWithHandlers(b.fuel,b.world,expression(expr,b.ids,b.programs,b.futures,v=>b.encode(v),b.contexts),user,2,false,false,ABI.nodeOptions(true,false,false,false,false,false,false,ABI.vUndefined(),0),1,0,b.programs[cleanup],0);b.check();
  };
  s.effectRead=(name,expr,cleanup,user=false)=>s.S.runWithOwner(s.owner,()=> (user?s.S.createEffect:s.S.createRenderEffect)(s.callback(name,expr),(v,p)=>{s.traceEvents.push(['apply',name,v,p]);if(!user)s.screens[2]=v;return s.programs[cleanup];}));
  b.memoHook=(name,expr,hook)=>{
    const id=ABI.nextId(b.world);b.ids[name]=id;b.reverse[id]=name;
    b.world=ABI.createMemoWithOptions(b.fuel,b.world,expression(expr,b.ids,b.programs,b.futures,v=>b.encode(v),b.contexts),ABI.nodeOptions(true,false,false,false,false,false,false,ABI.vUndefined(),b.programs[hook]),1);b.check();
  };
  s.memoHook=(name,expr,hook)=>{const get=s.S.runWithOwner(s.owner,()=>s.S.createMemo(s.callback(name,expr),{unobserved:s.programs[hook]}));s.accessors[name]=get;s.registerComputedAccessor(get,name);};
  b.effectApply=(name,expr,body,user=false)=>{
    const id=ABI.nextId(b.world);b.ids[name]=id;b.reverse[id]=name;
    if(!user)b.world=ABI.attach(b.world,1,2);
    b.world=ABI.createEffectWithHandlers(b.fuel,b.world,expression(expr,b.ids,b.programs,b.futures,v=>b.encode(v),b.contexts),user,2,false,false,ABI.nodeOptions(true,false,false,false,false,false,false,ABI.vUndefined(),0),1,b.programs[body],0,0);b.check();
  };
  s.effectApply=(name,expr,body,user=false)=>s.S.runWithOwner(s.owner,()=> (user?s.S.createEffect:s.S.createRenderEffect)(s.callback(name,expr),(v,p)=>{s.traceEvents.push(['apply',name,v,p]);if(!user)s.screens[2]=v;s.programs[body](undefined,v,p);}));
  const original=console.error;console.error=(...args)=>logs.push(args);
  try{
    for(const [op,...args] of commands){
      if(op==='tick')await setImmediate();
      else{
        const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
        if(actual[0]==='return'&&wanted[0]==='return'&&!['read','set','update','future','root','evaluate'].includes(op))actual[1]=wanted[1]=undefined;
        assert.deepEqual(actual,wanted,`${name}: ${op} result`);
        verify?.(op,args,actual,wanted,b,s);
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
      assert.deepEqual(b.iteratorIO(),s.iteratorIO(),`${name}: iterator protocol after ${op}`);
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
for(const lazy of [false,true])for(const route of ['public','function','updater','argument','nested']){
  await scenario('direct owner callback reads resume exact caller '+JSON.stringify({lazy,route}),[
    ['signal','input',1],['signal','marker',0],['memo','double',add(read('input'),read('input')),{owner:null,lazy}],
    ['program','clean',[['setExpr','marker',read('double')]]],['root','target',lit(0)],['install','target','clean'],
    ['set','input',3],['flush'],
    route==='public'?['disposeOwner','target']:route==='function'?['evaluate',{invoke:disposer('target')}]:route==='updater'?['set','marker',{rootDisposer:'target'}]:route==='argument'?['evaluate',add(lit(40),seq({invoke:disposer('target')},lit(2)))]:['evaluate',under(owner('root'),{invoke:disposer('target')})],
    ['flush'],['read','marker'],['dispose'],['flush']
  ]);
}
for(const cause of ['body','getter'])for(const route of ['public','function','updater']){
  await scenario('direct owner callback throws keep partial disposal '+JSON.stringify({cause,route}),[
    ['signal','marker',0],['memo','bad',{raise:7},{owner:null,lazy:true}],
    ['program','clean',[['set','marker',1],...(cause==='body'?[['throwExpr',lit(9)]]:[['eval',read('bad')]]),['set','marker',2]]],
    ['root','target',lit(0)],['install','target','clean'],
    route==='public'?['disposeOwner','target']:route==='function'?['evaluate',{invoke:disposer('target')}]:['set','marker',{rootDisposer:'target'}],
    ['flush'],['read','marker'],['disposeOwner','target'],['dispose'],['flush']
  ]);
}
for(const user of [false,true])for(const error of [false,true]){
  await scenario('effect previous cleanup can read or throw '+JSON.stringify({user,error}),[
    ['signal','input',0],['signal','marker',0],['memo','double',add(read('input'),read('input')),{owner:null,lazy:true}],
    ['program','clean',[['setExpr','marker',read('double')],...(error?[['throwExpr',lit(7)]]:[])]],
    ['effectRead','view',read('input'),'clean',user],['flush'],['set','input',3],['flush'],['read','marker'],
    ['dispose'],['resetErrorHalt'],['flush']
  ]);
}
for(const immediate of [false,true])for(const route of ['public','function','effect']){
  await scenario('cleanup pending getter uses ordinary read failure '+JSON.stringify({immediate,route}),[
    ['signal','input',0],['future','p',{immediate}],['memo','pending',future('p'),{owner:null}],
    ['program','clean',[['eval',read('pending')]]],
    ...(route==='effect'?[['effectRead','view',read('input'),'clean',true],['flush'],['set','input',1],['flush']]:[
      ['root','target',lit(0)],['install','target','clean'],route==='public'?['disposeOwner','target']:['evaluate',{invoke:disposer('target')}]
    ]),['resolve','p',7],['tick'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
  ]);
}
await scenario('cleanup reads preserve the setter entry value across writes',[
  ['signal','input',undefined],['signal','other',7],['program','clean',[['eval',read('other')],['setExpr','input',lit(9)]]],
  ['root','target',lit(0)],['install','target','clean'],['set','input',{rootDisposer:'target'}],['flush'],['read','input'],['dispose'],['flush']
]);
await scenario('cleanup expression observes caller owner and observer',[
  ['signal','savedOwner',undefined],['signal','savedObserver',undefined],
  ['program','clean',[['setExpr','savedOwner',current],['setExpr','savedObserver',{observer:true}]]],
  ['root','target',lit(0)],['install','target','clean'],
  ['memo','caller',seq({invoke:disposer('target')},lit(1))],['effect','view',read('caller')],['flush'],
  ['read','savedOwner'],['read','savedObserver'],['dispose'],['flush']
]);
for(const returned of [false,true])for(const ownRead of [false,true]){
  await scenario('child teardown reads and ignored returns '+JSON.stringify({returned,ownRead}),[
    ['signal','input',3],['signal','other',7],['root','scope',lit(0)],['memo','child',read('input'),{owner:'scope'}],
    ['program','clean',[[returned?'return':'eval',read(ownRead?'child':'other')]]],['install','child','clean'],
    ['evaluate',add(lit(40),seq({invoke:disposer('scope')},lit(2)))],['flush'],['dispose'],['flush']
  ]);
}
await scenario('cleanup can construct a memo in the original caller context',[
  ['root','target',lit(0)],['program','clean',[['eval',{memoRead:lit(3)}]]],['install','target','clean'],
  ['evaluate',{invoke:disposer('target')}],['flush'],['dispose'],['flush']
]);
await scenario('cleanup expression registration follows ambient caller owner',[
  ['root','target',lit(0)],['root','other',lit(0)],['program','clean',[['eval',onCleanup(disposer('other'))]]],
  ['install','target','clean'],['evaluate',under(owner('root'),{invoke:disposer('target')})],['dispose'],['flush']
]);
await scenario('imperative owner helper preserves held setter callback entry',[
  ['signal','input',0],['signal','version',0],['signal','derived',{accessor:'input'}],
  ['program','rewrite',[['set','derived',9]]],['root','replacement',lit(0),{owner:null}],['install','replacement','rewrite'],
  ['future','p',{immediate:true}],['memo','slow',select(read('version'),future('p'),lit(0))],
  ['effect','view',seq(read('version'),read('derived'),read('slow'))],['flush'],
  ['program','write',[['set','derived',{rootDisposer:'replacement'}]]],['root','cleaner',lit(0)],['install','cleaner','write'],
  ['set','input',undefined],['set','version',1],['flush'],['disposeStatic','cleaner'],['flush'],
  ['resolve','p',7],['tick'],['flush'],['read','derived'],['dispose'],['flush']
]);
for(const user of [false,true])for(const appError of [false,true])for(const hook of ['read','throw','pending']){
  let dropping=false;
  await scenario('effect finally trim callback preserves prior fault and overrides '+JSON.stringify({user,appError,hook}),[
    ['signal','choose',true],['signal','input',1],['signal','other',11],['future','p',{immediate:true}],
    ['memo','reader',hook==='pending'?future('p'):add(read('other'),lit(1)),{owner:null,lazy:true}],
    ['program','hook',[['eval',read('reader')],...(hook==='throw'?[['throwExpr',lit(9)]]:[])]],
    ['program','body',[['return',appError?select(arg(0),lit(undefined),{raise:7}):lit(undefined)]]],
    ['memoHook','observed',read('input'),'hook'],['effectApply','view',select(read('choose'),read('observed'),lit(0)),'body',user],
    ['flush'],['set','choose',false],['flush'],['resolve','p',7],['tick'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
  ],(op,args,actual,wanted)=>{
    if(op==='set'&&args[0]==='choose')dropping=true;
    if(op==='flush'&&dropping){
      dropping=false;
      if(hook==='throw')assert.deepEqual(wanted,['throw',9],'native trim throw overrides the application error');
      else if(hook==='pending'){assert.equal(wanted[0],'throw');assert.equal(wanted[1].source,'reader');assert.ok(wanted[1].notReady);}
      else assert.deepEqual(wanted,appError?['throw',7]:['return',undefined],'native body fault remains when trim succeeds');
    }
  });
}
for(const throws of [false,true]){
  await scenario('dormant sweep executes callback reads on the same core loop '+throws,[
    ['signal','input',1],['signal','other',7],['memo','reader',add(read('other'),lit(1)),{owner:null,lazy:true}],
    ['memo','observed',read('input'),{owner:null,lazy:true}],['read','observed'],
    ['program','clean',[['eval',read('reader')],...(throws?[['throwExpr',lit(9)]]:[])]],['install','observed','clean'],
    ['set','other',3],['flush'],['dispose'],['resetErrorHalt'],['flush']
  ]);
}
for(const held of [false,true])for(const immediate of [false,true])for(const cleanup of ['read','throw','pending']){
  let changed=false;
  await scenario('scheduler commit resumes parked cleanup '+JSON.stringify({held,immediate,cleanup}),[
    ['signal','version',0],['signal','marker',0],['signal','other',7],['future','p',{immediate}],['future','q',{immediate}],
    ['memo','reader',cleanup==='pending'?future('q'):read('other'),{owner:null,lazy:true}],
    ['program','clean',[['updateExpr','marker',add({prev:true},read('reader'))],...(cleanup==='throw'?[['throwExpr',lit(9)]]:[])]],
    ['memo','target',read('version')],['install','target','clean'],['memo','slow',select(read('version'),future('p'),lit(0))],
    ['effect','view',held?seq(read('target'),read('slow')):read('target')],['flush'],
    ['set','version',1],['flush'],['resolve','p',7],['tick'],['resolve','q',8],['tick'],['resetErrorHalt'],['flush'],
    ['read','marker'],['dispose'],['resetErrorHalt'],['flush']
  ],(op,args,actual,wanted,b,s)=>{
    if(op==='set'&&args[0]==='version')changed=true;
    if(op==='flush'&&changed){changed=false;
      if(!held){const target=[...s.sourceNames].find(([,name])=>name==='target')[0];assert.equal(target._value,1,'native value publishes before parked cleanup');assert.equal(target._x._pendingDisposal,null,'native cleanup list detaches before callback');}
      if(!held&&cleanup==='throw')assert.deepEqual(wanted,['throw',9]);
    }
  });
}
for(const throws of [false,true]){
  await scenario('unchanged-pass held trim resumes its unobserved hook '+throws,[
    ['signal','choose',true],['signal','input',1],['signal','marker',0],['signal','other',7],
    ['memo','reader',read('other'),{owner:null,lazy:true}],['program','hook',[['setExpr','marker',read('reader')],...(throws?[['throwExpr',lit(9)]]:[])]],
    ['memoHook','observed',read('input'),'hook'],['memo','stable',seq(select(read('choose'),read('observed'),lit(0)),lit(5))],
    ['effect','view',read('stable')],['flush'],['set','choose',false],['flush'],['resetErrorHalt'],['flush'],['read','marker'],['dispose'],['resetErrorHalt'],['flush']
  ]);
}
let changedManual=false;
await scenario('commit callback proposal retains its new manual-write flag',[
  ['signal','choose',true],['signal','input',1],['signal','saved',undefined],
  ['program','hook',[['eval',{invokeWith:{callee:read('saved'),value:lit(9)}}],['throwExpr',lit(9)]]],
  ['memoHook','observed',read('input'),'hook'],['program','compute',[['return',select(read('choose'),read('observed'),lit(0))]]],
  ['signal','target',{callback:'compute'}],['update','saved',lit({setter:'target'})],['flush'],['effect','view',read('target')],['flush'],
  ['set','choose',false],['flush'],['dispose'],['resetErrorHalt'],['flush']
],(op,args,actual,wanted,b,s)=>{
  if(op==='set'&&args[0]==='choose')changedManual=true;
  if(op==='flush'&&changedManual){changedManual=false;const target=[...s.sourceNames].find(([,name])=>name==='target')[0];
    assert.deepEqual(wanted,['throw',9]);assert.equal(target._value,0);assert.equal(target._pendingValue,9);
    assert.ok(target._flags&1024,'native callback proposal sets REACTIVE_MANUAL_WRITE after the commit prefix cleared it');
  }
});
for(const route of ['resolve','until','abort','timeout'])for(const immediate of [false,true])for(const cleanup of ['read','throw','pending']){
  await scenario('native watcher disposal resumes cleanup without changing settlement order '+JSON.stringify({route,immediate,cleanup}),[
    ['signal','input',route==='until'?1:0],['signal','marker',0],['signal','other',8],['effect','view',read('marker')],
    ['future','q',{immediate}],['memo','reader',cleanup==='pending'?future('q'):read('other'),{owner:null,lazy:true}],
    ['program','clean',[['setExpr','marker',read('reader')],...(cleanup==='throw'?[['throwExpr',lit(9)]]:[])]],
    ...(route==='abort'?[['controller','stop']]:[]),
    route==='resolve'?['awaitValue','port',read('input')]:['awaitUntil','port',read('input'),route==='timeout'?{timeout:5}:route==='abort'?{signal:'stop'}:{}],
    ['install','wait:port','clean'],...(route==='abort'?[['abort','stop',3]]:route==='timeout'?[['advance',5]]:[]),
    ['tick'],['resolve','q',7],['tick'],['flush'],['read','marker'],['dispose'],['flush']
  ],(op,args,actual,wanted,b,s)=>{
    if(op==='read'&&args[0]==='marker'){
      assert.equal(s.portEvents.length,1,'native settlement occurs even when disposal throws');
      assert.deepEqual(s.portSnapshots,[['port',0]],'native promise observer precedes cleanup-triggered rendering');
    }
  });
}
for(const immediate of [false,true])for(const value of [1,8])for(const cleanup of ['read','throw','pending']){
  await scenario('asyncWrite landing resumes dependency cleanup '+JSON.stringify({immediate,value,cleanup}),[
    ['signal','version',0],['signal','input',1],['signal','marker',0],['signal','other',7],['future','p',{immediate}],['future','q',{immediate}],
    ['memo','reader',cleanup==='pending'?future('q'):read('other'),{owner:null,lazy:true}],
    ['program','clean',[['emit',10],['setExpr','marker',read('reader')],['emit',11],...(cleanup==='throw'?[['throwExpr',lit(9)]]:[])]],
    ['memo','observed',read('input'),{lazy:true}],['install','observed','clean'],
    ['memo','target',select(read('version'),future('p'),read('observed'))],['flush'],
    ['set','version',1],['flush'],['resolve','p',value],['tick'],['read','marker'],
    ['resolve','q',7],['tick'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
  ],(op,args,actual,wanted,b,s)=>{
    if(op==='read'&&args[0]==='marker'){
      assert.deepEqual(wanted,['return',cleanup==='pending'?0:7],'native landing reached the read-capable cleanup');
      const target=[...s.sourceNames].find(([,name])=>name==='target')[0];
      assert.equal(target._value,value,'native landing retains its settled value');
    }
  });
}
for(const immediate of [false,true])for(const children of [1,2])for(const cleanup of ['read','throw','pending']){
  const dependents=[];
  for(let i=0;i<children;i++)dependents.push(['memo','child'+i,read('source'),{lazy:true}],['install','child'+i,'clean'],['read','child'+i]);
  await scenario('pending-source deferred releases resume captured walk '+JSON.stringify({immediate,children,cleanup}),[
    ['signal','marker',0],['signal','other',7],['future','p',{immediate}],['future','q',{immediate}],
    ['memo','reader',cleanup==='pending'?future('q'):read('other'),{owner:null,lazy:true}],
    ['program','clean',[['emit',30],['updateExpr','marker',add({prev:true},read('reader'))],['emit',31],...(cleanup==='throw'?[['throwExpr',lit(9)]]:[])]],
    ['memo','source',future('p')],...dependents,['flush'],['resolve','p',8],['tick'],['read','marker'],
    ['resolve','q',7],['tick'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
  ],(op,args,actual,wanted,b,s)=>{
    if(op==='read'&&args[0]==='marker'&&cleanup==='read')assert.deepEqual(wanted,['return',7*children],'native pending-source release walks every captured candidate');
  });
}
for(const immediate of [false,true])for(const route of ['promise','yield','empty','reject'])for(const cleanup of ['read','throw','pending']){
  await scenario('flight last observer release resumes cleanup '+JSON.stringify({immediate,route,cleanup}),[
    ['signal','marker',0],['signal','other',7],['future','p',{immediate}],['future','q',{immediate}],
    ['memo','reader',cleanup==='pending'?future('q'):read('other'),{owner:null,lazy:true}],
    ['program','clean',[['emit',20],['setExpr','marker',read('reader')],['emit',21],...(cleanup==='throw'?[['throwExpr',lit(9)]]:[])]],
    ...(route==='yield'||route==='empty'?[['stream','stream',[{future:'p'},{value:99},{done:true}]]]:[]),
    ['memo','target',future(route==='yield'||route==='empty'?'stream':'p'),{lazy:true}],['install','target','clean'],['read','target'],['flush'],
    route==='reject'?['reject','p',8]:route==='yield'?['resolveStep','p',8]:route==='empty'?['resolveStep','p',8,true]:['resolve','p',8],
    ['tick'],['read','marker'],['resolve','q',7],['tick'],['resetErrorHalt'],['flush'],['dispose'],['resetErrorHalt'],['flush']
  ],(op,args,actual,wanted,b,s)=>{
    if(op==='read'&&args[0]==='marker')assert.deepEqual(wanted,['return',cleanup==='pending'?0:7],'native flight release reached the read-capable cleanup');
  });
}
fs.rmSync(dir,{recursive:true,force:true});
console.log(`${count} direct owner/core continuation probes match actual pinned Solid disposal, callback reads, partial throws, pending and effect cleanup return points. Public teardown-expression histories are checked separately.`);
