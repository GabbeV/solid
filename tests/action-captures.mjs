import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const lit=lit=>({lit}),seq=(...seq)=>({seq}),arg={argument:0};
const result=(value,done=false)=>({iteratorResult:{value,done}});
let count=0;
for(const depth of [0,1])for(const dispose of [false,true])for(const rejected of [false,true]){
 const S=await import('../build/solid.mjs?action-capture='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),events=[[],[]];
 const localWrite=value=>({localWrite:{depth,value}});
 const tail=seq(localWrite(arg),{invokeWith:{callee:lit({setter:'out'}),value:{localRead:depth}}},result({localAccessor:depth},true));
 const plan={steps:[{next:seq(localWrite(lit(10)),result({future:'gate'}))},{next:tail,throw:tail}]};
 const body={action:plan},expr={signalScope:{initial:lit(5),body:depth?{signalScope:{initial:lit(7),body}}:body}};
 const compare=()=>{
  assert.deepEqual(b.screen(),s.screen());
  assert.deepEqual(b.trace().filter(e=>e[0]!=='read'),s.trace().filter(e=>e[0]!=='read'));
  assert.deepEqual(events[0],events[1]);
 };
 try{
  const promises=[b,s].map((r,i)=>{
   r.signal('out',0);r.effect('view',{read:'out'});r.flush();r.future('gate');
   const promise=r.root('scope',expr);promise.then(value=>events[i].push(['resolve',r.observe(value)]),error=>events[i].push(['reject',r.errorShape(error)]));
   return promise;
  });
  compare();for(const r of [b,s]){r.flush();if(dispose)r.disposeOwner('scope');}compare();
  for(const r of [b,s])r[rejected?'reject':'resolve']('gate',3);
  const [bg,sg]=await Promise.all(promises);await setImmediate();compare();
  assert.equal(bg(),sg());assert.equal(bg(),3);assert.equal(b.read('out'),s.read('out'));assert.equal(b.world.actionDepth,0);
  count++;
 }finally{for(const r of [b,s]){r.dispose();r.flush();}await setImmediate();}
}
console.log(`${count} lexical action histories preserve captured signal identities, depth/shadowing, error resumes, escaped getters and continuation after the invoking root is disposed.`);
