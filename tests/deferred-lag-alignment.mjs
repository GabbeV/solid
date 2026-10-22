// Direct source lagOf and installed hook comparisons. This is dependency
// coverage; no deferred constructor or lifetime is claimed by these fixtures.
import assert from 'node:assert/strict';import fs from 'node:fs';import os from 'node:os';import path from 'node:path';import {spawnSync} from 'node:child_process';import {fileURLToPath,pathToFileURL} from 'node:url';import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-deferred-lag-'));
try{
 const from=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;for(const d of['runtime','representation','observation'])fs.cpSync(path.join(from,d),path.join(dir,d),{recursive:true});fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});for(const name of['affects-marks','deferred-lag'])fs.copyFileSync(path.join(root,`tests/probes/${name}.bend`),path.join(dir,`tests/probes/${name}.bend`));
 const out=path.join(dir,'probe.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'tests/probes/deferred-lag.bend'),'-o',out],{cwd:root,encoding:'utf8'});assert.equal(compile.status,0,compile.stderr);const{default:B}=await import(pathToFileURL(out));
 const source=path.join(root,'upstream/solid/packages/signals/src');const bundle=await build({stdin:{contents:`export * as K from './core/constants.ts';export {signal,computed,setContextInternal} from './core/core.ts';export {link} from './core/graph.ts';export {GlobalQueue} from './core/scheduler.ts';export {probeLagOf,probeLagging} from './deferred.ts';`,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'lag-observation',setup(b){b.onLoad({filter:/[/\\]deferred\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {lagOf as probeLagOf,lagging as probeLagging};'}));}}]});const f=path.join(dir,'solid.mjs');fs.writeFileSync(f,bundle.outputFiles[0].text);const S=await import(pathToFileURL(f)),K=S.K;
 const adt=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'}),link=([dep,sub])=>({$:'Link',dep,sub,nextDep:0,prevSub:0,nextSub:0,gen:0});
 const shapes=[[[1,2],[2,3],[3,4],[4,5],[5,6]],[[1,2],[1,3],[2,4],[3,4],[4,5],[5,6]],[[1,3],[2,3],[3,4],[2,5],[5,6]],[[1,2],[2,3],[3,2],[3,4],[4,5]],[[1,2],[1,3],[2,5],[3,5],[5,6]],[],[[3,6],[2,6],[1,2],[1,3]]];
 let count=0;function check({edges,lagging,target,seen=[],tailMode=0,recomputing=false,error=0,op=0,slot=0}){
  const flags=Array.from({length:6},(_,i)=>recomputing&&i+1===target?K.REACTIVE_RECOMPUTING_DEPS:0),configs=Array.from({length:6},(_,i)=>i+1===slot?K.CONFIG_SLOT_NODE:0),statuses=Array.from({length:6},(_,i)=>i+1===error?K.STATUS_ERROR:0);
  S.setContextInternal(null);const ns=[null,S.signal(1),...Array.from({length:5},(_,i)=>S.computed(()=>i+2,{lazy:true}))];ns[4]._type=1;for(let i=1;i<ns.length;i++)Object.assign(ns[i],{_config:configs[i-1],_flags:flags[i-1],_statusFlags:statuses[i-1]});for(const[d,s]of edges)S.link(ns[d],ns[s]);if(tailMode===1)ns[target]._depsTail=ns[target]._deps;if(tailMode===2)ns[target]._depsTail=null;S.probeLagging.clear();lagging.forEach(i=>S.probeLagging.add(ns[i]));const wanted=op===0?S.probeLagOf(ns[target],new Set(seen.map(i=>ns[i]))):S.GlobalQueue._lagging(ns[target]);
  const result=B.fixture(op,adt(edges.map(link)),adt(configs),adt(flags),adt(statuses),target,adt(lagging),adt(seen),tailMode);assert.equal(result.left.fault.$,'Healthy');assert.equal(result.right,wanted?ns.indexOf(wanted):0,JSON.stringify({edges,lagging,target,seen,tailMode,recomputing,error,op}));
  const empty=B.fixture(1,adt(edges.map(link)),adt(configs),adt(flags),adt(statuses),target,adt([]),adt([]),tailMode);assert.deepEqual(result.left,empty.left,'read-only walk preserves complete World');count++;
 }
 for(const edges of shapes)for(const lagging of[[],[1],[2],[3],[4],[6],[1,3],[2,3],[3,2],[3,6],[6,3]])for(const target of[1,2,3,4,5,6])for(const op of[0,1])check({edges,lagging,target,op});
 for(const edges of shapes)for(const lagging of[[1],[2],[3],[4],[6],[2,3]])for(const target of[2,3,4,5,6])for(const seen of[[],[1],[2],[3],[target]])for(const tailMode of[0,1,2])check({edges,lagging,target,seen,tailMode,recomputing:true});
 for(const edges of shapes)for(const error of[1,2,3,4])for(const target of[2,3,4,6])check({edges,lagging:[1,3],target,error});
 for(const target of[1,2,3,4,5,6])for(const op of[0,1]){
  check({edges:shapes[0],lagging:[target],target,op,slot:target});
  if(op===1)check({edges:shapes[0],lagging:[],target,op,slot:target});
  if(op===0)check({edges:shapes[0],lagging:[target===1?2:1],target,seen:[target],op,slot:target});
 }
 S.probeLagging.clear();console.log(`${count} actual deferred lagOf/installed-hook controls preserve first reachable lag identity, membership-before-seen, dependency-prefix cutoffs, cycles, errors and the complete surrounding World. Public data/thenable lifetimes are checked separately.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
