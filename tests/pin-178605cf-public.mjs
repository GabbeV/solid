import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument}),invoke=name=>({invoke:read(name)}),set=(name,value)=>({invokeWith:{callee:read(name),value:lit(value)}}),seq=(...seq)=>({seq}),result=(value=lit(undefined),done=false)=>({iteratorResult:{value,done}});
for(const guess of [20,undefined,0,false,null])for(const optimisticInput of [false,true])for(const split of [false,true]){
 const module=await import('../build/solid.mjs?borrow='+String(guess)+optimisticInput+split),b=new BendRuntime({async:true}),s=new SolidRuntime({module});
 const input=optimisticInput?invoke('inputGet'):read('input'),data=invoke('dataGet');
 const setup=[['signal','input',1],['signal','inputGet',undefined],['signal','inputSet',undefined],['signal','dataGet',undefined],['signal','dataSet',undefined],['future','one'],['future','two'],['future','post'],['future','choose'],
  ['program','captureInput',[['updateExpr','inputGet',arg(0)],['updateExpr','inputSet',arg(1)]]],['program','captureData',[['updateExpr','dataGet',arg(0)],['updateExpr','dataSet',arg(1)]]],
  ...(optimisticInput?[['root','inputOwner',{optimisticComputeScope:{compute:read('input'),body:{call:'captureInput',args:[{localAccessor:0},{localSetter:0}]}}}]]:[]),
  ['root','dataOwner',{optimisticComputeScope:{compute:{select:[{same:[input,lit(1)]},{future:'one'},{future:'two'}]},body:{call:'captureData',args:[{localAccessor:0},{localSetter:0}]}}}],
  ...(split?[['effect','selection',input],['effect','comments',data,{target:3}]]:[['effect','view',{array:[input,data]}]]),['flush'],['tick'],['resolve','one',10],['tick'],['flush'],['expect',[1,10]],
  ['runAction','postAction',{steps:[{next:seq(set('dataSet',guess),result({future:'post'}))},{next:result(lit(undefined),true)}]}],['flush'],['tick'],['expect',[1,guess]],
  ...(optimisticInput?[['runAction','chooseAction',{steps:[{next:seq(set('inputSet',2),result({future:'choose'}))},{next:result(lit(undefined),true)}]}]]:[['set','input',2]]),['flush'],['tick'],['expect',[1,guess]],['resolve','two',30],['tick'],['flush'],['expect',optimisticInput?[2,30]:[1,guess]],
  ...(optimisticInput?[['resolve','choose',undefined],['tick'],['flush'],['expect',[1,guess]]]:[]),['resolve','post',undefined],['tick'],['flush'],['expect',optimisticInput?[1,10]:[2,30]]];
 const last=(r,n)=>r.trace().filter(e=>e[0]==='apply'&&e[1]===n).at(-1)?.[2],view=r=>split?[last(r,'selection'),last(r,'comments')]:last(r,'view');
 const errors=[],original=console.error;console.error=(...xs)=>errors.push(xs);
 try{for(const [op,...args] of setup){if(op==='tick')await setImmediate();else if(op==='expect')for(const r of[b,s])assert.deepEqual(view(r),args[0],JSON.stringify({optimisticInput,split,op,kind:r.constructor.name}));else{const a=b.attempt(op,...args),e=s.attempt(op,...args);if(a[0]==='return'&&e[0]==='return'&&!['evaluate','read','set'].includes(op))a[1]=e[1]=undefined;assert.deepEqual(a,e,JSON.stringify({optimisticInput,split,op}));}
  assert.deepEqual(b.trace(),s.trace(),JSON.stringify({optimisticInput,split,op}));assert.deepEqual(b.portEvents,s.portEvents);assert.deepEqual(b.asyncErrors,s.asyncErrors);assert.equal(b.world.fault.$,'Healthy');assert.equal(errors.length,0);
 }assert.deepEqual(list(b.world.laneState.kept),[],'saved guesses retire after both actions');b.dispose();s.dispose();b.flush();s.flush();assert.deepEqual(b.trace(),s.trace());}finally{console.error=original;}
}
console.log('20 native/Bend public question-change and borrowed-guess restoration histories pass, including saved undefined, zero, false and null values.');
