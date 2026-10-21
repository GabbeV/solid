// Resource failures must remain distinguishable from rejected proof assertions.
import assert from 'node:assert/strict';
import {proofProcess} from '../tools/proof-process.mjs';

const run=(source,options={})=>proofProcess(process.execPath,['-e',source],options);
const ok=await run('process.stdout.write("verdict");');
assert.equal(ok.status,0);assert.equal(ok.error,undefined);assert.equal(ok.stdout,'verdict');

const rejected=await run('process.stderr.write("proof rejected");process.exitCode=1;');
assert.equal(rejected.status,1);assert.equal(rejected.error,undefined);
assert.equal(rejected.stderr,'proof rejected');

const timed=await run('setInterval(()=>{},1000);',{timeout:100});
assert.match(timed.error?.message??'',/timeout/);
const output=await run('process.stdout.write("x".repeat(1024));',{maxBuffer:32});
assert.match(output.error?.message??'',/output limit/);

if(process.platform==='linux'){
 const memory=await run('setInterval(()=>{},1000);',{maxRss:1,timeout:5000});
 assert.match(memory.error?.message??'',/RSS limit/);
}
const missing=await proofProcess('/no-such-bend-proof-executable',[]);
assert.equal(missing.error?.code,'ENOENT');
console.log('Proof process success, rejection and infrastructure/resource stops remain distinct.');
