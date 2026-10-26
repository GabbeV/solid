// Private, consistently seeded source-carrier controls; no public reachability claim.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-retirement-controls-'));
try{
 const modules={};
 for(const [name,input]of [['fixture','proof/memo-render-fixture.bend'],['construct','runtime/construct-state.bend'],['pending','runtime/pending-state.bend'],['settle','runtime/pending.bend'],['extension','runtime/extension.bend'],['base','representation/base.bend'],['graph','runtime/graph-state.bend'],['transaction','runtime/transaction.bend']]){
  const output=path.join(dir,name+'.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',input,'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stdout+'\n'+r.stderr);modules[name]=(await import(pathToFileURL(output))).default;
 }
 const bundled=await build({stdin:{contents:`export {computed,ext,setContextInternal} from './core/core.ts';export {link} from './core/graph.ts';export {settlePendingSource} from './core/async.ts';export {NotReadyError} from './core/error.ts';export {probeReset,probeScheduled,newTransaction} from './core/scheduler.ts';export * as K from './core/constants.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'scheduler-control',setup(b){b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`\nexport {scheduled as probeScheduled};export function probeReset(){transactions.length=0;flushTransaction=passTx=passLane=null;clock=5;notifyEpoch=0;scheduled=false;syncDepth=1;pendingNodes.length=heldTrims.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;halted=haltNotified=false;}`}));}}]});
 const native=path.join(dir,'native.mjs');fs.writeFileSync(native,bundled.outputFiles[0].text);const S=await import(pathToFileURL(native));
 const F=modules.fixture,C=modules.construct,P=modules.pending,Q=modules.settle,E=modules.extension,B=modules.base,G=modules.graph,T=modules.transaction,b=new BendRuntime();let cases=0;
 const content=w=>({values:list(w.nodes).map(n=>n.value),tree:w.tree,events:w.events});
 for(const size of [0,3,7])for(const flags of [1,3,5,7,9,11,13,15])for(const held of [false,true])for(const blocked of [false,true])for(const additional of [false,true]){
  let w={...F.input(encodeList(Array.from({length:size},(_,i)=>b.encode(i)))),clock:5,syncDepth:1};const source=list(w.nodes).length;
  for(let i=0;i<3;i++)w=C.computed(w,{$:'Literal',value:b.encode(i)},C.defaults(),0);
  const node=source+1,other=source+2;w=G.link(w,source,node);w=B.store_node(w,node,{...B.node(w,node),config:held?S.K.CONFIG_HELD:0,flags:0,status:flags});w=P.addPendingSource(w,node,source).left;if(additional)w=P.addPendingSource(w,node,other).left;
  if(held){const tx=T.newTransaction(w,false,0);w=tx.left;w=B.store_extension(w,node,{...B.extension(w,node),transaction:tx.right});}
  const oldError=b.encode('failed'),error=flags&2?oldError:{$:'NotReadyFailure',identity:1,source};w=B.store_extension(w,node,{...B.extension(w,node),error,blocked:{$:'Present',value:{$:'Boolean',b:blocked}}});const before=content(w);
  const direct=Q.visitRemoved(w,encodeList([]),encodeList([19]),encodeList([23]),false,node,source,source),actual=Q.settlePendingSource(w,source,source);
  assert.equal(actual.fault.$,'Healthy');assert.deepEqual(content(actual),before);assert.equal(P.hasSource(actual,node,source),false);assert.equal(B.node(actual,node).status,B.node(direct.world,node).status);assert.deepEqual(list(direct.visited),[node,19]);assert.deepEqual(list(direct.released),[23]);assert.deepEqual(list(direct.tasks),[{$:'Walk',edge:0,root:source,source}]);
  assert.equal(B.node(actual,node).status,additional?flags:flags&~1);assert.equal(B.node(actual,node).time,5);
  S.probeReset();S.setContextInternal(null);const ns=S.computed(()=>0,{lazy:true}),nn=S.computed(()=>1,{lazy:true}),no=S.computed(()=>2,{lazy:true});S.link(ns,nn);nn._config=held?S.K.CONFIG_HELD:0;nn._flags=0;nn._statusFlags=flags;const ext=S.ext(nn);if(held)ext._transaction=S.newTransaction(false);ext._pendingSources=new Set([ns,...(additional?[no]:[])]);ext._error=flags&2?'failed':new S.NotReadyError(ns);ext._blocked=blocked;S.settlePendingSource(ns);
  assert.equal(nn._statusFlags,B.node(actual,node).status);assert.equal(nn._time,B.node(actual,node).time);assert.equal(Boolean(nn._x._pendingSources),additional);assert.equal(nn._x._blocked,additional?blocked:false);assert.equal(actual.scheduled,S.probeScheduled);assert.equal(direct.scheduled,blocked&&!additional);if(flags&2){assert.equal(nn._x._error,'failed');assert.deepEqual(B.extension(actual,node).error,oldError);}cases++;
 }
 console.log(`${cases} paired native/full Bend source settlements and direct dependent controllers agree on status, clock, membership, blocking, scheduling and retained errors; direct continuations and committed content are checked. Private seeded states, not public callback reachability or general flush.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
