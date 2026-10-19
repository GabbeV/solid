import {performance} from 'node:perf_hooks';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
const S=await import(pathToFileURL(process.argv[2]));
if(!global.gc)throw new Error('Run with --expose-gc');
function batch(count){
 global.gc();const startHeap=process.memoryUsage().heapUsed;
 const pairs=new Array(count),start=performance.now();
 for(let i=0;i<count;i++)pairs[i]=S.createSignal(i);
 const elapsed=performance.now()-start;
 global.gc();const retained=process.memoryUsage().heapUsed-startHeap;
 let checksum=0;for(let i=0;i<count;i++)checksum+=pairs[i][0]();
 assert.equal(checksum,count*(count-1)/2);
 assert.equal(pairs[0][1].length,1);
 // Bound setters ignore extra arguments. This control checks the public entry too.
 const fn=()=>123;
 assert.equal(pairs[0][1](fn,true),123);
 S.flush();
 return {elapsed,retained,bytesPerSignal:retained/count};
}
for(let i=0;i<3;i++)batch(20000);
const rows=[];for(let i=0;i<7;i++)rows.push(batch(100000));
const median=key=>rows.map(r=>r[key]).sort((a,b)=>a-b)[3];
console.log(JSON.stringify({rows,medianMs:median('elapsed'),medianBytesPerSignal:median('bytesPerSignal')}));
