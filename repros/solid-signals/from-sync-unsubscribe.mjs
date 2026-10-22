// Source-only repro of the public from() iterator. No Bend adapter is involved.
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const fixed=process.argv.includes('--expect-fixed'),entry=process.argv.slice(2).find(x=>!x.startsWith('--'));
const S=await import(entry?pathToFileURL(path.resolve(entry)):new URL('../../build/solid.mjs',import.meta.url));
const cases=[];
for(const synchronous of[false,true])for(const failed of[false,true])for(const object of[false,true]){
 const sourceError=new Error('source failed');let finish,closed=0,iterator;
 const open=()=>S.from((next,error,complete)=>{if(!failed)next(7);finish=()=>failed?error(sourceError):complete();if(synchronous)finish();const unsubscribe=()=>{closed++;throw new Error('unsubscribe failed');};return object?{unsubscribe}:unsubscribe;})[Symbol.asyncIterator]();
 if(synchronous&&!fixed){assert.throws(open,/unsubscribe failed/);assert.equal(closed,1);cases.push({synchronous,failed,object,error:'unsubscribe failed'});continue;}
 iterator=open();if(!synchronous)finish();if(failed)await assert.rejects(iterator.next(),error=>error===sourceError);else assert.deepEqual(await iterator.next(),{value:7,done:false});
 assert.deepEqual(await iterator.next(),{value:undefined,done:true});await iterator.return?.();assert.equal(closed,1);cases.push({synchronous,failed,object,result:failed?'original source error':'value 7',closed});
}
console.log(JSON.stringify({expectFixed:fixed,cases}));
