// Read-only export of the actual source helper; native comparator functions stay
// unchanged. This checks raw verdicts as well as the public callers' truthiness.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {build} from 'esbuild';
import {BendRuntime,list,ABI} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-comparator-probe-'));
const source=new URL('../upstream/solid/packages/signals/src/',import.meta.url).pathname;
const {outputFiles}=await build({stdin:{contents:"export * from './index.ts';export {isSame} from './core/core.ts';",resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}});
const lit=lit=>({lit}),arg=argument=>({argument}),read=read=>({read}),fn=callback=>lit({callback});
let count=0;
async function probe(name,commands){
 const file=path.join(dir,'source-'+count+'.mjs');fs.writeFileSync(file,outputFiles[0].text);
 const S=await import(file),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),logs=[],original=console.error;
 console.error=(...args)=>logs.push(args);
 b.rawCompare=(name,a,c)=>{const m=ABI.compareValues(b.fuel,b.world,b.ids[name],b.encode(a),b.encode(c));b.world=ABI.resultWorld(m);b.check();return b.decode(ABI.resultValue(m));};
 s.rawCompare=(name,a,c)=>{const get=s.accessors[name],node=Object.getOwnPropertySymbols(get).map(k=>get[k]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v);return S.isSame(node,s.value(a),s.value(c));};
 try{
  for(const [op,...args]of commands){
   const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
   if(op!=='rawCompare'&&actual[0]==='return'&&expected[0]==='return')actual[1]=expected[1]=undefined;
   assert.deepEqual(actual,expected,`${name}: ${op} raw result`);
   const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([n])=>n)),states,`${name}: computed state`);
   assert.deepEqual(b.trace(),s.trace(),`${name}: trace`);
   for(const [label,get]of Object.entries(s.accessors)){
    const node=Object.getOwnPropertySymbols(get).map(k=>get[k]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v);if(!node)continue;
    const n=b.nodes()[b.ids[label]],x=list(b.world.extensions)[n.x];
    assert.equal(n.status,node._statusFlags??0,`${name}: status of ${label}`);
    assert.equal(n.x===0,node._x===null,`${name}: extension presence of ${label}`);
    if(n.x)assert.deepEqual(b.errorShape(b.decode(x.error)),s.errorShape(node._x._error),`${name}: error wrapper of ${label}`);
   }
   assert.equal(b.world.context,0);assert.equal(b.world.tracking,false);assert.equal(b.world.syncDepth,0);
   assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: host errors`);
   const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
   assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports`);
  }
  count++;
 }finally{for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}console.error=original;}
}
try{
 for(const equals of [true,false])for(const [a,b]of [[undefined,undefined],[null,undefined],[0,0],[0,-0],[1,2],[true,true],[false,0],[NaN,NaN],['same','same'],[{ref:1},{ref:1}],[{ref:1},{ref:2}]]){
  await probe('default/disabled '+JSON.stringify({equals,a,b}),[['signal','value',0,equals],['rawCompare','value',a,b]]);
 }
 for(const body of [lit(true),lit(false),lit(0),lit(7),lit(null),lit(undefined),lit(''),lit('truthy'),lit({ref:7}),arg(0),arg(1),fn('unused')]){
  await probe('raw custom verdict '+JSON.stringify(body),[['program','unused',[['throw',99]]],['program','cmp',[['emit',31],['return',body]]],['signal','value',0,{equals:{callback:'cmp'}}],['rawCompare','value',2,3]]);
 }
 for(const error of [undefined,null,false,0,8,'failed',{ref:7},{error:1,kind:'TypeError',message:'comparison failed'}]){
  await probe('raw ordinary error '+JSON.stringify(error),[['program','cmp',[['emit',31],['throw',error]]],['signal','value',0,{equals:{callback:'cmp'}}],['rawCompare','value',2,3]]);
 }
 for(const seeded of [false,true]){
  await probe('raw NotReady control '+seeded,[['future','gate'],['memo','gate',{future:'gate'},seeded?{loadingValue:0}:{}],['program','cmp',[['emit',31],['eval',read('gate')],['return',lit(true)]]],['signal','value',0,{equals:{callback:'cmp'}}],['rawCompare','value',2,3]]);
 }
 for(const immediate of [false,true]){
  await probe('raw promise verdict '+immediate,[['future','token',{immediate}],['program','cmp',[['return',{future:'token'}]]],['signal','value',0,{equals:{callback:'cmp'}}],['rawCompare','value',2,3]]);
 }
 console.log(`${count} direct native isSame comparisons preserve raw verdicts, callback arguments/identity, status-error routing and NotReady behavior.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
