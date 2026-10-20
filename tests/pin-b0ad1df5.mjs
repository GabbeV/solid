// The updated untrack documentation describes existing production behavior.
// These public histories do not enable lanes, actions, boundaries or dev guards.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future});
const reference=process.env.SOLID_REFERENCE??new URL('../build/solid.mjs',import.meta.url).href;
let count=0;
for(const immediate of [false,true])for(const seed of ['absent','undefined','zero'])for(const lazy of [false,true]){
  const module=await import(reference+'?pin-b0ad1df5='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const original=console.error;console.error=(...args)=>logs.push(args);
  const name=JSON.stringify({immediate,seed,lazy});
  const initial=seed==='zero'?0:undefined,settled=seed==='absent'?7:initial;
  let phase=0;
  const commands=[
    ['future','p',{immediate}],['future','q',{immediate}],['signal','second',false],
    ['memo','source',{select:[read('second'),future('q'),future('p')]},seed==='absent'?{}:{loadingValue:initial}],
    ['memo','snapshot',{untrack:read('source')},{lazy}],['effect','view',read('snapshot')],['flush'],
    ['read','snapshot'],['resolve','p',7],['tick'],['flush'],['read','snapshot'],
    ['set','second',true],['flush'],['resolve','q',9],['tick'],['flush'],['read','snapshot'],['read','source'],
    ['dispose'],['flush']
  ];
  try{
    for(const [op,...args]of commands){
      if(op==='tick')await setImmediate();
      else{
        const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
        if(actual[0]==='return'&&expected[0]==='return'&&!['read','set','future'].includes(op))actual[1]=expected[1]=undefined;
        assert.deepEqual(actual,expected,`${name}: ${op} result`);
        if(op==='read'&&args[0]==='snapshot'){
          if(phase++===0&&seed==='absent')assert.equal(expected[0],'throw','untrack still suspends before the first value');
          else assert.deepEqual(expected,['return',phase===1?initial:settled],'untracked value stays a snapshot after the initial value');
        }
        if(op==='read'&&args[0]==='source')assert.deepEqual(expected,['return',9],'the source itself advances');
      }
      const states=solidStates(s);
      assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: nodes after ${op}`);
      assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
      assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: async errors after ${op}`);
      assert.deepEqual(b.screen(2),s.screen(2),`${name}: screen after ${op}`);
      assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],`${name}: ambient restoration`);
      assert.deepEqual(list(b.world.reports),[],`${name}: Bend reports`);
      assert.deepEqual(logs,[],`${name}: Solid reports`);
    }
    assert.equal(s.traceEvents.filter(e=>e[0]==='compute'&&e[1]==='snapshot').length,seed==='absent'?2:1,'only the missing initial value retries the untracked reader');
    count++;
  }catch(error){original('FAILED pin update history: '+name);throw error;}
  finally{for(const runtime of [b,s]){runtime.attempt('dispose');runtime.resetErrorHalt();runtime.attempt('flush');}await setImmediate();console.error=original;}
}
console.log(`${count} pin-update histories match untracked initial suspension, seeded snapshots and later source updates.`);
