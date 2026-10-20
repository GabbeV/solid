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
  const module=await import('../build/solid.mjs?generated-functions='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const original=console.error;console.error=(...args)=>logs.push(args);
  try{
    for(const [op,...args] of commands){
      if(op==='tick')await setImmediate();
      else{
        const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
        if(actual[0]==='return'&&wanted[0]==='return'&&!['read','set','update','future','root','evaluate'].includes(op))actual[1]=wanted[1]=undefined;
        assert.deepEqual(actual,wanted,`${name}: ${op} result`);
        assert.equal(wanted[0],'return',`${name}: generated program remains in its total natural/function domain at ${op}`);
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
const fn=name=>lit({callback:name}),seq=(...seq)=>({seq});
const invokeArgs=(callee,...args)=>({invokeArgs:{callee,args}});
for(let seed=1;seed<=16;seed++){
  let state=seed*0x9e3779b1>>>0;
  const next=n=>{state^=state<<13;state^=state>>>17;state^=state<<5;return (state>>>0)%n;};
  const commands=[['signal','a',0],['signal','b',1],['signal','mode',false],['signal','holder',undefined],
    ['program','add',[['return',add(select(arg(0),arg(0),lit(0)),read('b'))]]],
    ['program','multiply',[['return',{mul:[select(arg(0),arg(0),lit(0)),lit(2)]}]]],
    ['program','choose',[['return',select(read('mode'),fn('multiply'),fn('add'))]]],
    ['program','derive',[['return',add(read('a'),read('b'))]]],
    ['program','mutate',[['set','b',7],['return',lit(3)]]],['program','clean',[['emit',1]]],
    ['update','holder',fn('add')],['flush'],['signal','derived',{callback:'derive'}],
    ['memo','applied',invokeArgs(read('holder'),read('a'))],['future','p',{immediate:!!(seed&1)}],
    ['memo','slow',select(read('mode'),future('p'),lit(0))],
    ['effect','view',seq(read('derived'),read('applied'),read('slow'))],['flush'],
    ['root','guard',{onCleanup:fn('clean')}]];
  for(let step=0;step<160;step++){
    if(step===40)commands.push(['resolve','p',7],['tick']);
    if(step===90)commands.push(['disposeOwner','guard']);
    switch(next(12)){
      case 0:commands.push(['set','a',next(10)]);break;
      case 1:commands.push(['set','b',next(10)]);break;
      case 2:commands.push(['set','mode',!!next(2)]);break;
      case 3:commands.push(['update','holder',call('choose')]);break;
      case 4:commands.push(['set','a',{callback:'add'}]);break;
      case 5:commands.push(['update','derived',invokeArgs(fn('add'),{prev:true})]);break;
      case 6:commands.push(['set','derived',next(20)]);break;
      case 7:commands.push(['evaluate',invokeArgs(read('holder'),lit(next(10)),lit(next(10)))]);break;
      case 8:commands.push(['evaluate',invokeArgs(call('choose'),call('mutate'),lit(4))]);break;
      case 9:commands.push(['read',next(2)?'derived':'applied']);break;
      case 10:commands.push(['flush']);break;
      case 11:commands.push(['tick']);break;
    }
  }
  commands.push(['flush'],['read','a'],['read','b'],['read','derived'],['read','applied'],['dispose'],['tick'],['flush']);
  await scenario('seeded long function/transaction history '+seed,commands);
}
console.log(`${count} seeded public histories match pinned TS across 2560 generated operations plus setup/teardown, function selection, eager derivation, held/manual writes and native settlement.`);
