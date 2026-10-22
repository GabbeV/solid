// Raw _equals call sites must not inherit core.isSame's status catch. These
// helper probes use ordinary public callbacks, with explicit lane metadata.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-lane-answer-callbacks-'));
try{
 const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const d of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,d),path.join(dir,d),{recursive:true});
 const api=path.join(dir,'runtime/api.bend');fs.writeFileSync(api,'import ./extension.bend as ProbeExt\nimport ./constants.bend as ProbeK\nimport ./transaction.bend as ProbeTx\nimport ./lanes-state.bend as ProbeLane\n'+fs.readFileSync(api,'utf8'));
 fs.appendFileSync(api,`

def rawAnswer(fuel: Nat, +w: R.World, +id: Nat, +lane: Nat, +mode: U32) -> C.Machine:
  +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), ProbeK.CONFIG_GUESS())))
  +w = B.store_transaction(w, R.Transaction.parent(B.transaction(w, lane)), R.Transaction.with_acted(B.transaction(w, R.Transaction.parent(B.transaction(w, lane))), True{}))
  +m = B.choose(~C.Machine, U32.is_eq(mode, 0), _ => C.laneWrite(w, [], [], id, R.Number{3n}),
    _ => B.choose(~C.Machine, U32.is_eq(mode, 1), _ => C.laneOutcome(w, [], [], id, R.Number{3n}, False{}), _ => C.laneCorrections(w, [], [])))
  C.run(fuel, m)

def primeRawShown(+w: R.World, +lane: Nat, shown: Bool) -> R.World:
  B.store_transaction(w, lane, R.Transaction.with_shown(B.transaction(w, lane), shown))

def parkRawFrame(+w: R.World, +id: Nat) -> R.World:
  +w = ProbeExt.ext(w, id)
  +w = B.store_extension(w, id, R.NodeExtension.with_pendingDisposal(R.NodeExtension.with_pendingFirstChild(B.extension(w, id), R.Node.firstChild(B.node(w, id))), R.Node.disposal(B.node(w, id))))
  B.store_node(w, id, R.Node.with_disposal(R.Node.with_firstChild(B.node(w, id), 0n), R.NoDisposal{}))

def rawCleanupFinish(m: C.Machine) -> C.Machine:
  match m:
    case C.Machine{world, tasks, values}:
      C.Machine{R.World.with_running(world, False{}), tasks, values}

def rawCleanupLifecycle(fuel: Nat, +w: R.World, +lane: Nat, +mode: U32) -> C.Machine:
  +w = R.World.with_running(w, True{})
  +rest = {[C.Evaluate{R.Literal{R.Undefined{}}, R.Undefined{}}] : List<&2, C.Task>}
  +m = B.choose(~C.Machine, U32.is_eq(mode, 2), _ => C.laneSeam(w, rest, [], lane, False{}),
    _ => C.dissolveLane(w, rest, [], lane, B.choose(~Nat, U32.is_eq(mode, 0), _ => 0n, _ => R.Transaction.parent(B.transaction(w, lane))), 0n))
  rawCleanupFinish(C.run(fuel, m))

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
 const {BendRuntime,ABI,list}=await import('../host/bend.mjs?answer-callbacks');delete process.env.BEND_EMIT_FILE;
 const {SolidRuntime}=await import('../host/solid.mjs');
 const native=await build({stdin:{contents:`export * from './index.ts';export {ext} from './core/core.ts';export * as K from './core/constants.ts';export {truthRead} from './core/truth.ts';export {newTransaction,GlobalQueue,globalQueue} from './core/scheduler.ts';export {probeNewLane,probeDissolve,probeSeam,probeWrite,probeOutcome,probeCorrections} from './core/lanes.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'lifecycle-private-export',setup(b){b.onLoad({filter:/[/\\]core[/\\]lanes\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {newLane as probeNewLane,dissolveLane as probeDissolve,laneSeam as probeSeam,laneWrite as probeWrite,laneOutcome as probeOutcome,laneCorrections as probeCorrections};'}));}}]});
 const nativeFile=path.join(dir,'solid.mjs');fs.writeFileSync(nativeFile,native.outputFiles[0].text);
 const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument});let count=0;
 async function scenario(route,body,setup=[]){
  const S=await import(pathToFileURL(nativeFile).href+'?case='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S});
  const node=name=>Object.getOwnPropertySymbols(s.accessors[name]).map(k=>s.accessors[name][k]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v);
  const mode=route==='write'?0:route==='outcome'?1:2;
  b.raw=()=>{const pair=ABI.primeRawLifecycle(b.world,b.ids.value,b.encode(3));const m=ABI.rawAnswer(b.fuel,pair.left,b.ids.value,pair.right,mode);b.world=ABI.resultWorld(m);b.check();return b.decode(ABI.resultValue(m));};
  s.raw=()=>{const n=node('value');S.ext(n)._lane=n._value;n._pendingValue=3;n._config|=S.K.CONFIG_OVERRIDE|S.K.CONFIG_GUESS;const parent=S.newTransaction(),lane=S.probeNewLane(parent);parent._acted=true;lane._shown=true;lane._nodes.push(n);S.ext(n)._transaction=lane;return mode===0?S.probeWrite(n,3):mode===1?S.probeOutcome(n,3,false):S.probeCorrections();};
  const commands=[['program','unused',[['throw',91]]],...setup,['program','cmp',[['emit',31],...body]],...(route==='outcome'?[['memo','value',lit(2),{equals:{callback:'cmp'}}],['flush']]:[['signal','value',2,{equals:{callback:'cmp'}}]]),['raw']];
  const errors=[],original=console.error;console.error=(...args)=>errors.push(args);
  try{for(const[op,...args]of commands){
   const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
   if(op!=='raw'&&actual[0]==='return'&&expected[0]==='return')actual[1]=expected[1]=undefined;
   assert.deepEqual(actual,expected,route+': '+JSON.stringify(body));assert.deepEqual(b.trace(),s.trace());
   if(op==='raw'){
    const n=node('value'),bn=b.nodes()[b.ids.value];assert.equal(bn.status,n._statusFlags??0,'raw comparator error is not published as node status');
    assert.equal(list(b.world.reports).length,0);assert.equal(errors.length,0,'no isSame notifier or halt side effect');
    assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false]);
   }
  }count++;}finally{for(const r of[b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}console.error=original;}
 }
 for(const route of['write','outcome','correction']){
  for(const verdict of[true,false,0,7,null,undefined,'','yes',{ref:7},{callback:'unused'}])await scenario(route,[['return',lit(verdict)]]);
  for(const error of[undefined,null,false,0,9,'failed',{ref:8},{error:1,kind:'TypeError',message:'comparison failed'}])await scenario(route,[['throwExpr',lit(error)]]);
  for(const seeded of[false,true])await scenario(route,[['eval',read('gate')],['return',lit(true)]],[['future','p'],['memo','gate',{future:'p'},seeded?{loadingValue:0}:{}]]);
  for(const side of[0,1])await scenario(route,[['return',arg(side)]]);
 }
 console.log(`${count} native raw comparator controls preserve arbitrary return truthiness, arguments, identity, user throws/NotReady and absence of isSame error wrapping at lane write/outcome/correction boundaries.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
