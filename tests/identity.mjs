import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const module=await import('../build/solid.mjs?identity-observation');
for(const runtime of [new BendRuntime({async:true}),new SolidRuntime({module})]){
 runtime.signal('x',{ref:1});runtime.signal('alias',{ref:1});runtime.signal('other',{ref:2});
 const first=runtime.read('x'),second=runtime.read('other');
 assert.equal(runtime.read('x'),first);assert.equal(runtime.read('alias'),first);assert.notEqual(first,second);
 runtime.memo('copy',{read:'x'});assert.equal(runtime.read('copy'),first);
 runtime.effect('view',{read:'x'});assert.equal(runtime.screen(),first);
 assert.equal(runtime.set('x',{ref:2}),second,'setter returns the same represented object as existing observations');
 runtime.flush();assert.equal(runtime.read('x'),second);assert.equal(runtime.read('copy'),second);assert.equal(runtime.screen(),second);
 assert.equal(runtime.update('x',{read:'alias'}),first);runtime.flush();assert.equal(runtime.read('x'),first);
 runtime.awaitValue('r',{read:'x'});await setImmediate();assert.equal(await runtime.promise('r'),first);
 runtime.awaitUntil('u',{read:'x'});await setImmediate();assert.equal(await runtime.promise('u'),first);
 runtime.memo('bad',{raise:{ref:1}});let failure;try{runtime.read('bad');}catch(e){failure=e;}
 assert.ok(failure);assert.equal(failure.cause,first,'wrapped causes share the reference observation cache');
 const pId=runtime.future('p');runtime.memo('data',{future:'p'},{sync:true});assert.equal(runtime.read('data'),runtime.read('data'));assert.notEqual(runtime.read('data'),first);
 runtime.memo('tokenData',{lit:{async:pId}},{sync:true});assert.equal(runtime.read('tokenData'),runtime.read('data'));
 runtime.stream('s',[]);runtime.memo('streamData',{future:'s'},{sync:true});assert.equal(runtime.read('streamData'),runtime.read('streamData'));
 runtime.program('badClean',[['throw',{ref:1}]]);runtime.program('registerBad',[['cleanup','badClean']]);
 runtime.attempt('awaitUntil','badCleanup',{seq:[{call:'registerBad'},{lit:7}]});await setImmediate();assert.equal(runtime.asyncErrors.at(-1),first);
 runtime.dispose();runtime.resetErrorHalt();runtime.flush();await setImmediate();
}
console.log('Host reference identity matches TS across repeated/aliased reads, writes/updaters, memo values, native promise outcomes, error causes and async-object data tokens.');
