// #4284/#4304: latest(guess) stays ahead while ordinary readers wait for the
// guess's derivation, independently of render-effect grouping/read order.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument}),add=(a,b)=>({add:[a,b]});
const seq=(...seq)=>({seq}),result=(value=lit(undefined),done=false)=>({iteratorResult:{value,done}});
const last=(runtime,name)=>runtime.trace().filter(e=>e[0]==='apply'&&e[1]===name).at(-1)?.[2];
let histories=0;
for(const kind of ['held','guess','lane'])for(const mode of ['one','latest-first','split']){
 const module=await import('../build/solid.mjs?frame-grouping='+histories),b=new BendRuntime({async:true}),s=new SolidRuntime({module});
 const errors=[],original=console.error;console.error=(...args)=>errors.push(args);
 const x=kind==='held'?read('x'):{invoke:read('saved')},put=kind==='held'?{invokeWith:{callee:lit({setter:'x'}),value:lit(5)}}:{invokeWith:{callee:read('setSaved'),value:lit(5)}};
 const derived=kind==='lane'?read('derived'):lit('-'),latest={latest:x},prefix={array:[x,derived]};
 const setup=kind==='held'?[['signal','x',1]]:[['signal','base',1],['signal','saved',undefined],['signal','setSaved',undefined],['program','capture',[['updateExpr','saved',arg(0)],['updateExpr','setSaved',arg(1)]]],['root','scope',{optimisticComputeScope:{compute:read('base'),body:{call:'capture',args:[{localAccessor:0},{localSetter:0}]}}}]];
 const commands=[...setup,['flush'],['future','action'],['future','derived'],...(kind==='lane'?[['memo','derived',{select:[{same:[x,lit(1)]},lit('x1'),{future:'derived'}]}]]:[]),
  ...(mode==='split'?[['effect','view',prefix],['effect','ahead',latest,{target:3}]]:mode==='latest-first'?[['program','format',[['return',{array:[arg(1),arg(2),arg(0)]}]]],['effect','view',{call:'format',args:[latest,x,derived]}]]:[['effect','view',{array:[x,derived,latest]}]]),
  ['flush'],['tick'],['expect',[1,kind==='lane'?'x1':'-',1]],
  ['runAction','attempt',{steps:[{next:seq(put,result({future:'action'}))},{next:result(lit(undefined),true)}]}],['flush'],['tick'],
  ['expect',[kind==='guess'?5:1,kind==='lane'?'x1':'-',5]],
  ...(kind==='lane'?[['resolve','derived','x5'],['tick'],['flush'],['expect',[5,'x5',5]]]:[]),
  ['resolve','action',undefined],['tick'],['flush'],...(kind==='held'?[['expect',[5,'-',5]]]:[])];
 const compare=op=>{
  assert.deepEqual(b.trace(),s.trace(),`${kind}/${mode} trace after ${op}`);
  assert.deepEqual(b.portEvents,s.portEvents,`${kind}/${mode} action delivery`);
  assert.deepEqual(b.portSnapshots,s.portSnapshots,`${kind}/${mode} action-time screen`);
  assert.deepEqual(b.asyncErrors,s.asyncErrors,`${kind}/${mode} async errors`);
  for(const target of[2,3])assert.deepEqual(b.screen(target),s.screen(target),`${kind}/${mode} target ${target}`);
  assert.equal(b.world.fault.$,'Healthy');assert.equal(errors.length,0);
 };
 try{
  for(const [op,...args]of commands){
   if(op==='tick')await setImmediate();
   else if(op==='expect')for(const runtime of[b,s])assert.deepEqual(mode==='split'?[...last(runtime,'view'),last(runtime,'ahead')]:last(runtime,'view'),args[0],`${kind}/${mode} expected screen`);
   else{
    const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
    if(actual[0]==='return'&&expected[0]==='return'&&!['evaluate','read','set'].includes(op))actual[1]=expected[1]=undefined;
    assert.deepEqual(actual,expected,`${kind}/${mode}: ${op}`);
   }
   compare(op);
  }
  b.dispose();s.dispose();b.flush();s.flush();compare('dispose');histories++;
 }finally{console.error=original;}
}
console.log(`${histories} source-backed render-grouping histories retain ordinary committed values beside latest(), hold optimistic derivations until landing and complete their actions.`);
