// End-to-end regression histories for the audited 71153bf0 pin update.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future}),select=(...select)=>({select}),seq=(...seq)=>({seq}),same=(...same)=>({same}),add=(...add)=>({add});
let count=0;
async function scenario(name,commands,verify){
 const module=await import('../build/solid.mjs?repin-history='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
 const original=console.error;console.error=(...args)=>logs.push(args);
 try{
  for(const [op,...args]of commands){
   if(op==='tick')await setImmediate();
   else{
    const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
    if(actual[0]==='return'&&wanted[0]==='return'&&!['read','set','update','future','root','evaluate'].includes(op))actual[1]=wanted[1]=undefined;
    assert.deepEqual(actual,wanted,`${name}: ${op} result`);verify?.(op,args,actual,wanted,b,s);
   }
   const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: node state after ${op}`);
   assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);assert.deepEqual(b.iteratorIO(),s.iteratorIO(),`${name}: iterator IO after ${op}`);
   assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: native callback failures after ${op}`);
   for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
   assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],`${name}: ambient restoration`);
   const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
   assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports after ${op}`);
  }
  count++;
 }catch(e){original('FAILED: '+name);throw e;}
 finally{for(const runtime of [b,s]){runtime.attempt('dispose');runtime.resetErrorHalt();runtime.attempt('flush');}await setImmediate();console.error=original;}
}
for(const immediate of [false,true])for(const user of [false,true])for(const depth of [1,2]){
 let child=read('lazy');for(let i=0;i<depth;i++)child={memoRead:child};
 await scenario('rebuilt child retains its lazy async source '+JSON.stringify({immediate,user,depth}),[
  ['future','p',{immediate}],['memo','lazy',future('p'),{lazy:true}],['effect','view',child,{user}],['flush'],
  ['resolve','p',7],['tick'],['flush'],['tick'],['read','lazy'],['dispose'],['flush']
 ],(op,args,actual,wanted,b,s)=>{
  if(op==='read'){
   assert.deepEqual(wanted,['return',7]);assert.equal(s.traceEvents.filter(e=>e[0]==='compute'&&e[1]==='lazy').length,1,'native lazy source runs once despite rebuilding its only reader');
   assert.equal(s.traceEvents.filter(e=>e[0]==='apply'&&e[1]==='view').at(-1)[2],7);
  }
 });
}
for(const immediate of [false,true])for(const throws of [false,true]){
 let changed=false;
 await scenario('pass releases the lazy source it stops reading '+JSON.stringify({immediate,throws}),[
  ['signal','tick',0],['future','p',{immediate}],['program','gone',[['emit',51],...(throws?[['throw',7]]:[])]],
  ['memo','lazy',seq({onCleanup:lit({callback:'gone'})},lit(1)),{lazy:true}],
  ['memo','parent',seq(select(same(read('tick'),lit(0)),{memoRead:read('lazy')},lit(0)),future('p'))],
  ['effect','view',read('parent')],['flush'],['set','tick',1],['flush'],['dispose'],['resetErrorHalt'],['flush']
 ],(op,args,actual,wanted,b,s)=>{
  if(op==='set')changed=true;
  if(op==='flush'&&changed){changed=false;assert.deepEqual(wanted,throws?['throw',7]:['return',undefined]);assert.equal(s.traceEvents.filter(e=>e[0]==='cleanup'&&e[2]===51).length,1,'native deferred release runs cleanup once at pass end');}
 });
}
for(const initialError of [false,true])for(const equal of [false,true])for(const updater of [false,true])for(const equals of [false,true]){
 let reads=0;const value=equal?1:7;
 await scenario('writable memo error stays shown until the replacement commits '+JSON.stringify({initialError,equal,updater,equals}),[
  ['signal','fail',initialError],['program','compute',[['return',select(read('fail'),{raise:99},lit(1))]]],['program','error',[['emit',52]]],
  ['signal','value',{callback:'compute'},{equals}],['effect','view',read('value'),{user:true,error:'error'}],['flush'],
  ...(!initialError?[['set','fail',true],['flush']]:[]),['read','value'],updater?['update','value',lit(value)]:['set','value',value],
  ['read','value'],['flush'],['read','value'],['dispose'],['flush']
 ],(op,args,actual,wanted)=>{if(op==='read'){reads++;if(reads<3){assert.equal(wanted[0],'throw');assert.equal(wanted[1].cause,99);}else assert.deepEqual(wanted,['return',value]);}});
}
for(const immediate of [false,true])for(const updater of [false,true]){
 let changed=false;
 await scenario('manual write clears a held staged-error classification '+JSON.stringify({immediate,updater}),[
  ['signal','mode',false],['future','hold',{immediate}],['program','compute',[['return',select(read('mode'),{raise:99},lit(1))]]],
  ['signal','value',{callback:'compute'}],['memo','slow',select(read('mode'),future('hold'),lit(0))],
  ['effect','view',seq(read('slow'),read('value'))],['flush'],['set','mode',true],['flush'],
  updater?['update','value',lit(7)]:['set','value',7],['dispose'],['resetErrorHalt'],['flush']
 ],(op,args,actual,wanted,b,s)=>{
  if(op==='set'&&args[0]==='mode')changed=true;
  const node=[...s.sourceNames].find(([,name])=>name==='value')?.[0];
  if(op==='flush'&&changed){changed=false;assert.ok(node._config&(1<<21),'native error was staged under the hold');}
  if((op==='set'||op==='update')&&args[0]==='value'){assert.deepEqual(wanted,['return',7]);assert.equal(node._config&(1<<21),0,'native setter replaces the staged-error classification before its rederive');}
 });
}
for(const immediate of [false,true])for(const reverse of [false,true])for(const finalError of [false,true]){
 await scenario('a new flight supersedes the staged error '+JSON.stringify({immediate,reverse,finalError}),[
  ['signal','mode',0],['future','slow',{immediate}],['future','inner',{immediate}],['program','error',[['emit',53]]],
  ['memo','slow',select(read('mode'),future('slow'),lit(1))],
  ['memo','value',select(same(read('mode'),lit(1)),{raise:99},select(same(read('mode'),lit(2)),future('inner'),select(same(read('mode'),lit(3)),{raise:55},lit(1))))],
  ['memo','sum',add(read('slow'),read('value'))],['effect','view',read('sum'),{user:true,error:'error'}],['flush'],
  ['set','mode',1],['flush'],['set','mode',2],['flush'],...(finalError?[['set','mode',3],['flush']]:[]),
  ...reverse?[['resolve','slow',2],['tick'],['resolve','inner',7]]:[['resolve','inner',7],['tick'],['resolve','slow',2]],
  ['tick'],['flush'],['read','sum'],['dispose'],['flush']
 ],(op,args,actual,wanted)=>{if(op==='read'){if(finalError){assert.equal(wanted[0],'throw');assert.equal(wanted[1].cause,55);}else assert.deepEqual(wanted,['return',9]);}});
}
for(const immediate of [false,true])for(const flatten of [false,true])for(const rejected of [false,true]){
 await scenario('later iterator failure belongs to its memo '+JSON.stringify({immediate,flatten,rejected}),[
  ['future','first',{immediate}],['future','second',{immediate}],['future','outer',{immediate:false}],['program','error',[['emit',54]]],
  ['stream','stream',[{future:'first'},rejected?{future:'second'}:{throw:99}]],['memo','value',future(flatten?'outer':'stream')],
  ['effect','view',read('value'),{user:true,error:'error'}],['flush'],...(flatten?[['resolveStream','outer','stream'],['tick']]:[]),
  ['resolveStep','first',7],['tick'],...(rejected?[['reject','second',99],['tick']]:[]),['flush'],['read','value'],['dispose'],['flush']
 ],(op,args,actual,wanted,b,s)=>{if(op==='read'){assert.equal(wanted[0],'throw');assert.equal(wanted[1].cause,99);assert.deepEqual(s.asyncErrors,[],'native protocol failure is contained by its memo');}});
}
// Preserve the newly found Source regression: a failed pre-body teardown does
// not restore graph's active release array. This is not a desired guarantee.
for(const throws of [false,true]){
 await scenario('upstream deferred collector survives a throwing teardown '+throws,[
  ['signal','tick',0],['future','p',{immediate:true}],['program','boom',throws?[['throw',99]]:[]],
  ['memo','broken',seq(read('tick'),{onCleanup:lit({callback:'boom'})},future('p'))],['flush'],['set','tick',1],['flush'],
  ['program','gone',[['emit',55]]],['root','other',lit(0)],
  ['memo','lazy',seq({onCleanup:lit({callback:'gone'})},lit(1)),{owner:'other',lazy:true}],
  ['root','observer',lit(0),{owner:'other'}],['effect','view',read('lazy'),{owner:'observer'}],['flush'],
  ['disposeOwner','observer'],['flush']
 ],(op,args,actual,wanted,b,s)=>{
  if(op==='disposeOwner')assert.equal(s.traceEvents.filter(e=>e[0]==='cleanup'&&e[2]===55).length,throws?0:1,'native unrelated cleanup is lost only after the throwing prelude');
 });
}
console.log(`${count} upstream-integration histories match actual Solid, with independent lazy-run/release, writable recovery, flight replacement and protocol-error assertions.`);
