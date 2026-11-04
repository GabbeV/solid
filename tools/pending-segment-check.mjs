// Reviewable textual source-cut audit, not TS/Bend equivalence. The historical
// 2a0da2fc specimen remains unchanged; rc.21 intentionally moved marking/descent
// after the visitor and added stageMark to its successful-settlement tail.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const runtime=fs.readFileSync(new URL('../runtime/pending.bend',import.meta.url),'utf8');
const original=fs.readFileSync(new URL('../experiments/pending-settlement-frame/rc21-settled.bend.txt',import.meta.url),'utf8');
const body=(text,name)=>{
 const start=text.indexOf('def '+name+'(');assert.ok(start>=0,name+' definition');
 const end=text.indexOf('\ndef ',start+1),definition=text.slice(start,end<0?undefined:end);
 return definition.slice(definition.indexOf(':\n')+2).split('\n').filter(line=>line.trim()&&!line.trimStart().startsWith('#')).join('\n');
};
const before=body(original,'settled'),status=body(runtime,'settledStatus');
assert.ok(status.endsWith('\n  w'),'status helper returns the updated World');
const tail=body(runtime,'settledTailPrefix'),current=body(runtime,'settled');
const statusCall='  +w = settledStatus(w, id, remaining, errored)',tailCall='  settledTail(w, tasks, visited, released, scheduled, id, root, source, Nat.is_eq(remaining, 0n))';
assert.equal(current.split(statusCall).length,2,'one status call');assert.equal(current.split(tailCall).length,2,'one tail call');
assert.equal(body(runtime,'settledTail').trim(),'stageSettled(last,settledTailPrefix(w,tasks,visited,released,scheduled,id,root,source,last),id,root)','tail cuts compose without extra work');
const gate='  B.choose(~Machine,Bool.and(B.ok(w),last),_=>stageMark(w,ending,visited,released,scheduled,id,root),_=>Machine{w,ending,visited,released,scheduled})';
assert.equal(body(runtime,'stageSettled').trim(),'match machine:\n    case Machine{+w,+tasks,+visited,+released,+scheduled}:\n      B.choose(~Machine,Bool.and(B.ok(w),last),_=>stageMark(w,tasks,visited,released,scheduled,id,root),_=>Machine{w,tasks,visited,released,scheduled})','stage return cut is only the source gate');
assert.ok(tail.endsWith('\n  Machine{w,ending,visited,released,scheduled}'));
const expanded=current.replace(statusCall,status.slice(0,-'\n  w'.length)).replace(tailCall,'  +last = Nat.is_eq(remaining, 0n)\n'+tail.slice(0,-'\n  Machine{w,ending,visited,released,scheduled}'.length)+'\n'+gate);
assert.equal(expanded,before,'inlining source cuts preserves the reviewed rc.21 statements, order and branches');
const sha256=text=>createHash('sha256').update(text).digest('hex');
console.log(JSON.stringify({sourceFunction:'settlePendingSource / settled',sourcePin:'2105ffb8',historicalOriginal:'2a0da2fc',segments:['settledStatus','settledTailPrefix','stageSettled'],bodyStatementsIdenticalAfterInlining:true,originalBodySha256:sha256(before),expandedBodySha256:sha256(expanded),semanticDeviation:false,formalEquivalenceClaim:false}));
