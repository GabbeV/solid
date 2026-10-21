// Source-only public controls for the next engine dependency. These do not
// assert or imply that Bend implements actions.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
let count=0;
async function scenario(name,run){
 const S=await import('../../build/solid.mjs?action-contract='+count),seen=[];
 let get,set,dispose;
 S.createRoot(d=>{dispose=d;[get,set]=S.createSignal(0);S.createRenderEffect(get,value=>{seen.push(value);});});
 try{await run({S,get,set,seen});count++;}
 catch(error){error.message=name+': '+error.message;throw error;}
 finally{dispose();S.flush();await setImmediate();}
}
await scenario('first slice schedules; flush callback runs without a drain',async({S,get,set,seen})=>{
 let called=0;
 const save=S.action(function*(){S.flush(()=>{called++;});set(1);return 'saved';});
 const done=save();assert.equal(called,1);assert.equal(get(),0);assert.deepEqual(seen,[0]);
 S.flush();assert.equal(get(),1);assert.deepEqual(seen,[0,1]);assert.equal(await done,'saved');
});
await scenario('yielded promise holds writes until the return',async({S,get,set,seen})=>{
 let finish;const request=new Promise(resolve=>{finish=resolve;});
 const save=S.action(function*(){set(1);const value=yield request;set(value);return 'saved';});
 const done=save();S.flush();assert.equal(get(),0);assert.deepEqual(seen,[0]);
 finish(3);assert.equal(await done,'saved');assert.equal(get(),3);assert.deepEqual(seen,[0,3]);
});
await scenario('yield rejection is catchable in the generator',async({S,get,set,seen})=>{
 const failed=new Error('request failed');
 const save=S.action(function*(){set(1);try{yield Promise.reject(failed);}catch(error){assert.equal(error,failed);set(4);}return 'recovered';});
 const done=save();S.flush();assert.equal(get(),0);assert.deepEqual(seen,[0]);
 assert.equal(await done,'recovered');assert.equal(get(),4);assert.deepEqual(seen,[0,4]);
});
await scenario('nested bare-yield slice cannot flush the outer body',async({S,get,set,seen})=>{
 const inner=S.action(function*(){set(2);yield;set(3);return 'inner';});
 const outer=S.action(function*(){set(1);const done=inner();assert.deepEqual(seen,[0]);set(4);return done;});
 const done=outer();assert.equal(get(),0);assert.deepEqual(seen,[0]);
 S.flush();assert.equal(get(),4);assert.deepEqual(seen,[0,4]);assert.equal(await done,'inner');
});
console.log(`${count} source-only action controls preserve first/resumed-slice scheduling, production callback-without-drain behavior, held writes, rejection and nested depth; Bend actions remain unfinished.`);
