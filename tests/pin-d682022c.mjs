// #4184 is a documented pre-existing rule, unchanged by the new pin. These
// are paired controls for both effect kinds, with/without a memo/comparator.
import assert from 'node:assert/strict';
import {BendRuntime} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read});
let count=0;
for(const user of [false,true])for(const front of ['none','memo','custom'])for(const schedule of [false,true]){
 const S=await import('../build/solid.mjs?pin-d682='+count),b=new BendRuntime(),s=new SolidRuntime({module:S});
 const positive={select:[{same:[read('value'),lit(0)]},lit(false),lit(true)]};
 try{
  for(const r of [b,s]){
   r.signal('value',1);
   r.program('same',[['return',{same:[{argument:0},{argument:1}]}]]);
   r.program('apply',[['emit',19]]);r.program('cleanup',[['emit',23]]);
   if(front!=='none')r.memo('positive',positive,front==='custom'?{equals:{callback:'same'}}:{});
   r.effect('effect',front==='none'?positive:read('positive'),{user,schedule,program:'apply',cleanup:'cleanup'});r.flush();
  }
  const compare=()=>{
   const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states);
   assert.deepEqual(b.trace(),s.trace());assert.deepEqual(b.screen(),s.screen());
  };
  compare();
  for(const value of [2,3,0]){for(const r of [b,s]){r.set('value',value);r.flush();}compare();}
  const applications=b.trace().filter(e=>e[0]==='apply'&&e[1]==='effect').length;
  assert.equal(applications,front==='none'?4:2,'equal compute returns still apply; a memo can absorb their invalidation');
  for(const r of [b,s]){r.dispose();r.flush();}compare();count++;
 }finally{b.attempt('dispose');s.attempt('dispose');b.attempt('flush');s.attempt('flush');}
}
console.log(`${count} pin-update histories preserve equal-compute effect application/cleanup and memo/custom-comparator suppression in both effect kinds.`);
