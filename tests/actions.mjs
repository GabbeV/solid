import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,ABI} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),seq=(...seq)=>({seq}),arg={argument:0};
const write=(name,value)=>({invokeWith:{callee:lit({setter:name}),value}});
const result=(value=lit(undefined),done=false)=>({iteratorResult:{done,value}});
const method=(next,thrown)=>({next,...(thrown===undefined?{}:{throw:thrown})});
const setup=[['signal','x',0],['memo','twice',{mul:[read('x'),lit(2)]}],['effect','view',read('twice')],['flush']];
let count=0;
const question=q=>q.$==='QuestionZero'?0:q.$==='QuestionOdd'?2*question(q.half)+1:2*question(q.half)+2;
async function scenario(name,commands,verify){
 const S=await import('../build/solid.mjs?action-history='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S});
 try{
  for(const [op,...args]of commands){
   if(process.env.DEBUG_ACTION)console.log(name,op,...args);
   if(op==='tick')await setImmediate();
   else{
    const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
    if(!['evaluate','runAction','read','set','flush','future'].includes(op)&&actual[0]==='return'&&expected[0]==='return')actual[1]=expected[1]=undefined;
    assert.deepEqual(actual,expected,`${name}: ${op} result`);verify?.(op,args,expected,b,s);
   }
   const states=solidStates(s);
   assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: nodes after ${op}`);
   for(const [node,label]of s.sourceNames)if(node._x){const n=b.nodes()[b.ids[label]],x=list(b.world.extensions)[n.x];assert.equal(question(x.q),node._x._q,`${name}: question provenance of ${label} after ${op}`);}
   assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
   assert.deepEqual(b.screen(),s.screen(),`${name}: screen after ${op}`);
   assert.deepEqual(b.portEvents,s.portEvents,`${name}: promise outcomes after ${op}`);
   assert.deepEqual(b.portSnapshots,s.portSnapshots,`${name}: promise callback screens after ${op}`);
   assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: callback errors after ${op}`);
   assert.deepEqual([b.world.context,b.world.tracking,b.world.actionDepth,b.world.syncDepth],[0,false,0,0],`${name}: restored ambient state`);
   assert.equal(b.world.question.$,'QuestionZero',`${name}: restored question`);
  }
  count++;
 }catch(error){console.error('FAILED action: '+name);throw error;}
 finally{for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();}
}

for(const immediate of [false,true])for(const pre of [false,true])for(const rejected of [false,true])for(const catches of [false,true]){
 const plan={steps:[method(seq(write('x',lit(1)),result({future:'request'}))),method(seq(write('x',arg),result(lit('saved'),true)),catches?seq(write('x',lit(4)),result(arg,true)):undefined)]};
 await scenario('held promise '+JSON.stringify({immediate,pre,rejected,catches}),[
  ...setup,['future','request',{immediate}],...(pre?[[rejected?'reject':'resolve','request',3]]:[]),
  ['runAction','save',plan],['read','x'],['flush'],['read','x'],
  ...(!pre?[[rejected?'reject':'resolve','request',3]]:[]),['tick'],['read','x'],['read','twice'],['flush']
 ],(op,args,res,b)=>{if(op==='read'&&args[0]==='x'&&b.portEvents.length)assert.equal(res[1],rejected?(catches?4:1):3);});
}
for(const value of [undefined,null,false,true,0,7,'done',{ref:8}])for(const flushBody of [false,true]){
 const plan={steps:[method(seq(write('x',lit(1)),...(flushBody?[{flush:write('x',lit(2))},{flushNow:true}]:[]),result(lit(value),true)))]};
 await scenario('initial return and production flush '+JSON.stringify({value,flushBody}),[
  ...setup,['runAction','save',plan],['read','x'],['flush'],['tick'],['read','x']
 ],(op,args,res)=>{if(op==='read'&&args[0]==='x'&&res[1]===0)assert.deepEqual(res,['return',0]);});
}
for(const error of [undefined,7,{ref:5},{error:1,kind:'Error',message:'failed'}])for(const factory of [false,true]){
 const fail={raise:error},plan=factory?{factory:fail,steps:[]}:{steps:[method(seq(write('x',lit(1)),fail))]};
 await scenario('factory/body error '+JSON.stringify({error,factory}),[
  ...setup,['runAction','save',plan],['flush'],['tick'],['read','x']
 ],(op,args,res,b)=>{if(op==='runAction'&&factory)assert.equal(list(b.world.txArena).length,1,'factory failure must precede transaction allocation');});
}
for(const value of [undefined,0,3,'yield',{ref:6}]){
 await scenario('bare yield resumes synchronously '+JSON.stringify(value),[
  ...setup,['runAction','save',{steps:[method(seq(write('x',lit(1)),result(lit(value)))),method(seq(write('x',lit(2)),result(arg,true)))]}],
  ['read','x'],['tick'],['read','x']
 ],(op,args,res)=>{if(op==='read')assert.deepEqual(res,['return',2]);});
}
for(const immediate of [false,true])for(const rejected of [false,true]){
 await scenario('iterator result promise '+JSON.stringify({immediate,rejected}),[
  ...setup,['future','result',{immediate}],['runAction','save',{steps:[method(seq(write('x',lit(1)),{future:'result'})),method(seq(write('x',arg),result(lit('saved'),true)),seq(write('x',lit(9)),result(lit('wrongly caught'),true)))]}],
  ['flush'],[rejected?'reject':'resolveStep','result',3,...(rejected?[]:[false])],['tick'],['read','x'],['flush']
 ],(op,args,res,b)=>{if(op==='read')assert.equal(res[1],rejected?1:3);});
}
for(const waiting of [false,true])for(const bare of [false,true]){
 const inner={steps:[method(seq(write('x',lit(2)),bare?result(lit(0)):result(lit('inner'),true))),...(bare?[method(seq(write('x',lit(3)),result(lit('inner'),true)))]:[])]};
 const outer=waiting?{steps:[method(seq(write('x',lit(1)),result({action:inner}))),method(seq(write('x',lit(4)),result(arg,true)))]}:{steps:[method(seq(write('x',lit(1)),{action:inner},write('x',lit(4)),result(lit('outer'),true)))]};
 await scenario('nested action '+JSON.stringify({waiting,bare}),[...setup,['runAction','save',outer],['read','x'],['flush'],['tick'],['read','x'],['flush']]);
}
for(const reverse of [false,true])for(const rejection of [false,true]){
 const plan=(request,next)=>({steps:[method(seq(write('x',lit(1)),result({future:request}))),method(seq(write('x',lit(next)),result(arg,true)))]});
 const first=reverse?'b':'a',second=reverse?'a':'b';
 await scenario('overlapping actions '+JSON.stringify({reverse,rejection}),[
  ...setup,['future','a'],['future','b'],['runAction','one',plan('a',2)],['runAction','two',plan('b',3)],['flush'],['read','x'],
  [rejection?'reject':'resolve',first,5],['tick'],['read','x'],['resolve',second,6],['tick'],['read','x'],['flush']
 ]);
}
for(const immediate of [false,true])for(const rejected of [false,true]){
 await scenario('return adopts a thenable '+JSON.stringify({immediate,rejected}),[
  ...setup,['future','returned',{immediate}],['runAction','save',{steps:[method(seq(write('x',lit(1)),result({future:'returned'},true)))]}],['flush'],
  [rejected?'reject':'resolve','returned',7],['tick'],['read','x']
 ]);
}
for(const bare of [false,true]){
 const inner={steps:[method(result(lit(7),!bare)),...(bare?[method(result(lit(8),true))]:[])]};
 await scenario('return adopts nested action '+bare,[...setup,['runAction','save',{steps:[method(result({action:inner},true))]}],['flush'],['tick'],['read','x']]);
}

for(const nested of [false,true])for(const resumed of [false,true]){
 const readFlight={memoRead:{future:'flight'},options:{loadingValue:0}};
 const inner={steps:[method(seq(readFlight,result(lit(7),true)))]};
 const middle=nested?{action:inner}:readFlight;
 const plan=resumed?{steps:[method(result({future:'request'})),method(seq(middle,result(lit(7),true)))]}:{steps:[method(seq(middle,result(lit(7),true)))]};
 await scenario('action flight provenance '+JSON.stringify({nested,resumed}),[
  ...setup,['future','flight'],['future','request'],['runAction','save',plan],['flush'],['resolve','request',3],['tick'],['resolve','flight',4],['tick'],['flush']
 ]);
}

console.log(`${count} action histories compare the shared Bend transaction driver with pinned Solid: held writes, production flush guards, yields/errors, result promises, nesting, overlap and return adoption.`);
