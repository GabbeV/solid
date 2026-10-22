// Actual core getters/setters with explicit lane metadata. Public optimistic
// construction and flush lifecycle admission remain separate unfinished work.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-lane-core-io-'));
try{
 const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const d of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,d),path.join(dir,d),{recursive:true});
 const api=path.join(dir,'runtime/api.bend');fs.writeFileSync(api,'import ./extension.bend as ProbeExt\nimport ./constants.bend as ProbeK\nimport ./transaction.bend as ProbeTx\nimport ./lanes-state.bend as ProbeLane\n'+fs.readFileSync(api,'utf8'));
 fs.appendFileSync(api,`

def primeGuess(+w: R.World, +id: Nat) -> R.World:
  +w = B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.Present{R.Number{5n}}))
  B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), ProbeK.CONFIG_GUESS())))






def primeRawLifecycle(+w: R.World, +id: Nat, proposal: R.Value) -> B.Bundle<R.World, Nat>:
  +w = ProbeExt.ext(w, id)
  +w = B.store_node(w, id, R.Node.with_pending(R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), ProbeK.CONFIG_OVERRIDE())), R.Present{proposal}))
  +w = B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.Present{R.Node.value(B.node(w, id))}))
  +pair = ProbeTx.newTransaction(w, False{}, 0n)
  +pair = ProbeLane.newLane(B.first(R.World, Nat, pair), B.second(R.World, Nat, pair))
  +w = B.first(R.World, Nat, pair)
  +lane = B.second(R.World, Nat, pair)
  +w = ProbeTx.list(w, id, lane)
  B.Bundle{B.store_transaction(w, lane, R.Transaction.with_shown(B.transaction(w, lane), True{})), lane}
`);
 const emitted=path.join(dir,'runtime.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'runtime/api.bend'),'-o',emitted],{cwd:root,encoding:'utf8'});assert.equal(compile.status,0,compile.stderr);
 process.env.BEND_EMIT_FILE=emitted;
 const {BendRuntime,ABI,list}=await import('../host/bend.mjs?lane-core-io');delete process.env.BEND_EMIT_FILE;
 const {SolidRuntime}=await import('../host/solid.mjs');
 const native=await build({stdin:{contents:`export * from './index.ts';export {ext} from './core/core.ts';export * as K from './core/constants.ts';export {truthRead} from './core/truth.ts';export {newTransaction,GlobalQueue,globalQueue} from './core/scheduler.ts';export {probeNewLane,probeDissolve,probeSeam,probeWrite,probeOutcome,probeCorrections} from './core/lanes.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'lifecycle-private-export',setup(b){b.onLoad({filter:/[/\\]core[/\\]lanes\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {newLane as probeNewLane,dissolveLane as probeDissolve,laneSeam as probeSeam,laneWrite as probeWrite,laneOutcome as probeOutcome,laneCorrections as probeCorrections};'}));}}]});
 const nativeFile=path.join(dir,'solid.mjs');fs.writeFileSync(nativeFile,native.outputFiles[0].text);
 const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument});let count=0;
 for(const comparator of['default','strict',false,true])for(const input of['changed','equal','updater','reentrant','read','throw-zero','throw-undefined']){
  const S=await import(pathToFileURL(nativeFile).href+'?core-io='+count),b=new BendRuntime(),s=new SolidRuntime({module:S});
  const node=name=>Object.getOwnPropertySymbols(s.accessors[name]).map(k=>s.accessors[name][k]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v);
  let ts;
  b.prime=()=>{const pair=ABI.primeRawLifecycle(b.world,b.ids.value,b.encode(3));b.world=ABI.primeGuess(pair.left,b.ids.value);};
  s.prime=()=>{const n=node('value');S.ext(n)._lane=5;n._pendingValue=3;n._config|=S.K.CONFIG_OVERRIDE|S.K.CONFIG_GUESS;const parent=S.newTransaction(),lane=S.probeNewLane(parent);lane._shown=true;lane._nodes.push(n);S.ext(n)._transaction=lane;ts=[null,parent,lane];};
  const step=(op,...args)=>{const a=b.attempt(op,...args),e=s.attempt(op,...args);if(a[0]==='return'&&e[0]==='return'&&!['set','update','read'].includes(op))a[1]=e[1]=undefined;assert.deepEqual(a,e,JSON.stringify({comparator,input,op}));assert.deepEqual(b.trace(),s.trace());return e;};
  const state=()=>{const n=node('value'),bn=b.nodes()[b.ids.value],bx=list(b.world.extensions)[bn.x];assert.equal(b.decode(bn.value),n._value);assert.equal(bn.config,n._config);assert.equal(bn.pending.$==='Present',n._pendingValue!==S.K.NOT_PENDING);if(bn.pending.$==='Present')assert.equal(b.decode(bn.pending.value),n._pendingValue);assert.equal(bx.lane.$==='Present',n._x._lane!==S.K.NOT_PENDING);if(bx.lane.$==='Present')assert.equal(b.decode(bx.lane.value),n._x._lane);assert.equal(bx.transaction,ts.indexOf(n._x._transaction));};
  const original=console.error,errors=[];console.error=(...x)=>errors.push(x);
  try{
   step('program','cmp',[['emit',31],['return',comparator==='strict'?{same:[arg(0),arg(1)]}:lit(comparator)]]);
   step('signal','value',2,comparator==='default'?true:{equals:{callback:'cmp'}});
   step('program','update',[...(input==='reentrant'?[['set','value',19]]:input==='read'?[['eval',read('value')]]:[]),...(input==='throw-zero'?[['throwExpr',lit(0)]]:input==='throw-undefined'?[['throwExpr',lit(undefined)]]:[['return',input==='updater'?{add:[arg(0),lit(1)]}:arg(0)]])]);
   step('prime');state();step('read','value');state();
   if(input==='changed'||input==='equal')step('set','value',input==='changed'?9:5);else step('set','value',{callback:'update'});
   state();assert.equal(list(b.world.reports).length,0);assert.equal(errors.length,0);count++;
  }finally{for(const r of[b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}console.error=original;}
 }
 console.log(`${count} native core read/setter controls retain lane early reads, updater entry values, reentrant corrections, raw updater throws and actual hook dispatch.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
