// rc.17 public cleanup policy: complete each owner walk/drain, then rethrow
// the first raw payload once. Pair real native APIs with the active Bend driver.
import assert from 'node:assert/strict';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const lit=lit=>({lit}),fn=callback=>lit({callback}),read=read=>({read});
const seq=(...seq)=>({seq}),under=(name,body)=>({withOwner:[lit({owner:name}),body]});
const clean=name=>({onCleanup:fn(name)});
let count=0;
for(const cause of [undefined,null,false,0,9])for(const insideFlush of [false,true])for(const children of [0,1,2]){
 const S=await import('../build/solid.mjs?cleanup-policy='+count),b=new BendRuntime(),s=new SolidRuntime({module:S}),rs=[b,s],logs=[];
 const original=console.error;console.error=(...args)=>logs.push(args);
 const step=(op,...args)=>{
  const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
  if(actual[0]==='return'&&expected[0]==='return'&&!['read','evaluate'].includes(op)){actual[1]=expected[1]=undefined;}
  assert.deepEqual(actual,expected,`${count}: ${op}`);assert.deepEqual(b.trace(),s.trace(),`${count}: trace`);
  assert.equal(b.world.running,false);assert.equal(b.world.context,0);assert.equal(b.world.tracking,false);
  return expected;
 };
 try{
  step('signal','marker',0);
  const program=(name,code,error)=>step('program',name,[['emit',code],['updateExpr','marker',{add:[{prev:true},lit(1)]}],['throwExpr',lit(error)],['emit',999]]);
  program('older',10,42);program('newer',20,cause);
  step('root','target',seq(clean('older'),clean('newer'),lit(undefined)));
  for(let i=0;i<children;i++){
   program('child'+i,30+i,cause);step('root','child'+i,seq(clean('child'+i),lit(undefined)),{owner:'target'});
  }
  if(insideFlush){
   step('program','drop',[['eval',{disposeRoot:lit({owner:'target'})}]]);
   step('effect','dropper',lit(1),{program:'drop',schedule:true});
  }
  const result=insideFlush?step('flush'):step('disposeOwner','target');
  assert.deepEqual(result,['throw',cause],'first raw payload escapes after teardown, including thrown undefined');
  const codes=b.trace().filter(e=>e[0]==='cleanup').map(e=>e[2]);
  assert.deepEqual(codes,[...Array.from({length:children},(_,i)=>30+children-1-i),20,10],'children and LIFO callbacks all run; throwing callback remainder does not');
  assert.equal(b.nodes()[b.ids.target].disposal.$,'NoDisposal');
  assert.equal(b.world.cleanupError.$,'Empty','error is consumed once');
  assert.deepEqual(step('flush'),['return',undefined],'no repeated cleanup error');
  assert.deepEqual(step('read','marker'),['return',children+2],'cleanup writes finish in the drain');
  step('disposeOwner','target');step('flush');assert.equal(b.trace().filter(e=>e[0]==='cleanup').length,children+2,'no replay');
  assert.equal(logs.length,0,'collected cleanup throws do not halt reactivity');
  count++;
 }finally{for(const r of rs){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}console.error=original;}
}
// Reentrant disposal can consume an existing error and throw it back into the
// outer runCleanup guard. It must keep that first payload and abort only the
// nested-disposer callback's remainder, while older outer callbacks still run.
for(const cause of [undefined,false,9])for(const insideFlush of [false,true]){
 const S=await import('../build/solid.mjs?cleanup-reentry='+count),b=new BendRuntime(),s=new SolidRuntime({module:S}),rs=[b,s];
 const step=(op,...args)=>{const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
  if(actual[0]==='return'&&expected[0]==='return'){actual[1]=expected[1]=undefined;}
  assert.deepEqual(actual,expected,'reentrant '+op);assert.deepEqual(b.trace(),s.trace());return expected;};
 try{
  step('program','inner',[['emit',30],['throwExpr',lit(42)]]);
  step('root','inner',seq(clean('inner'),lit(undefined)));
  step('program','older',[['emit',10]]);
  step('program','middle',[['emit',15],['eval',{disposeRoot:lit({owner:'inner'})}],['emit',999]]);
  step('program','newer',[['emit',20],['throwExpr',lit(cause)]]);
  step('root','target',seq(clean('older'),clean('middle'),clean('newer'),lit(undefined)));
  if(insideFlush){step('program','drop',[['eval',{disposeRoot:lit({owner:'target'})}]]);step('effect','dropper',lit(1),{program:'drop',schedule:true});}
  assert.deepEqual(insideFlush?step('flush'):step('disposeOwner','target'),['throw',cause]);
  assert.deepEqual(b.trace().filter(e=>e[0]==='cleanup').map(e=>e[2]),insideFlush?[20,15,30,999,10]:[20,15,30,10],
    'nested root defers inside flush; outside it rethrows into the outer guard');
  assert.equal(b.world.cleanupError.$,'Empty');assert.deepEqual(step('flush'),['return',undefined]);
  count++;
 }finally{for(const r of rs){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}}
}
console.log(`${count} public cleanup-policy histories match native complete child/LIFO teardown, first-error identity (including undefined), callback abort, once-only rethrow, flush completion and continued reactivity.`);
