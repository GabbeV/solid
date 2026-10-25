// Reviewable textual extraction audit, not a TS/Bend equivalence proof.
// Inlining the two source-segment helpers must recover the earlier Bend body.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const runtime=fs.readFileSync(new URL('../runtime/pending.bend',import.meta.url),'utf8');
const original=fs.readFileSync(new URL('../experiments/pending-settlement-frame/original-settled.bend.txt',import.meta.url),'utf8');
const body=(text,name)=>{
 const start=text.indexOf('def '+name+'(');assert.ok(start>=0,name+' definition');
 const end=text.indexOf('\ndef ',start+1),definition=text.slice(start,end<0?undefined:end);
 return definition.slice(definition.indexOf(':\n')+2).split('\n').filter(line=>line.trim()&&!line.trimStart().startsWith('#')).join('\n');
};
const before=body(original,'settled').trimEnd(),status=body(runtime,'settledStatus');
assert.ok(status.endsWith('\n  w'),'status helper returns the updated World');
const tail=body(runtime,'settledTail'),current=body(runtime,'settled');
const statusCall='  +w = settledStatus(w, id, remaining, errored)',tailCall='  settledTail(w, tasks, visited, released, scheduled, id, root, source, Nat.is_eq(remaining, 0n))';
assert.equal(current.split(statusCall).length,2,'one status call');assert.equal(current.split(tailCall).length,2,'one tail call');
const expanded=current.replace(statusCall,status.slice(0,-'\n  w'.length)).replace(tailCall,'  +last = Nat.is_eq(remaining, 0n)\n'+tail);
assert.equal(expanded,before,'inlining source segments preserves the exact previous statements, ordering and branches');
const sha256=text=>createHash('sha256').update(text).digest('hex');
console.log(JSON.stringify({sourceFunction:'settlePendingSource / settled',sourcePin:'2a0da2fc',segments:['settledStatus','settledTail'],bodyStatementsIdenticalAfterInlining:true,originalBodySha256:sha256(before),expandedBodySha256:sha256(expanded),semanticDeviation:false,formalEquivalenceClaim:false}));
