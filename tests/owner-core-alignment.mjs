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
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?owner-core='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
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
fs.rmSync(dir,{recursive:true,force:true});
console.log(`${count} direct owner/core continuation probes match actual pinned Solid disposal, callback reads, partial throws, pending and effect cleanup return points. Public read-capable teardown admission remains restricted.`);
