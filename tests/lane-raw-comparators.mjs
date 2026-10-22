// Raw _equals call sites must not inherit core.isSame's status catch. These
// helper probes use ordinary public callbacks, with explicit lane metadata.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-raw-lane-comparators-'));
try{
 const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const d of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,d),path.join(dir,d),{recursive:true});
 const api=path.join(dir,'runtime/api.bend');fs.writeFileSync(api,'import ./extension.bend as ProbeExt\nimport ./constants.bend as ProbeK\n'+fs.readFileSync(api,'utf8'));
 fs.appendFileSync(api,`

def rawLaneEquals(fuel: Nat, w: R.World, id: Nat, a: R.Value, b: R.Value) -> C.Machine:
  C.run(fuel, C.rawEquals(w, [], [], id, a, b))

def rawHeldNotFinal(fuel: Nat, w: R.World, id: Nat) -> C.Machine:
  C.run(fuel, C.heldNotFinal(w, [], [], id))

def rawTruthRead(fuel: Nat, w: R.World, id: Nat) -> C.Machine:
  C.run(fuel, C.truthRead(w, [], [], id))

def primeRawLane(+w: R.World, +id: Nat, +mode: U32, proposal: R.Value) -> R.World:
  +w = ProbeExt.ext(w, id)
  +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{proposal}))
  +w = B.choose(~R.World, U32.is_eq(mode, 1), _ => B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), ProbeK.CONFIG_HELD()))),
    _ => B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), U32.or(ProbeK.CONFIG_OVERRIDE(), ProbeK.CONFIG_GUESS())))))
  B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.Present{R.Node.value(B.node(w, id))}))
`);
 const emitted=path.join(dir,'runtime.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'runtime/api.bend'),'-o',emitted],{cwd:root,encoding:'utf8'});assert.equal(compile.status,0,compile.stderr);
 process.env.BEND_EMIT_FILE=emitted;
 const {BendRuntime,ABI,list}=await import('../host/bend.mjs?raw-lane');delete process.env.BEND_EMIT_FILE;
 const {SolidRuntime}=await import('../host/solid.mjs');
 const native=await build({stdin:{contents:`export * from './index.ts';export {ext} from './core/core.ts';export * as K from './core/constants.ts';export {truthRead} from './core/truth.ts';export {probeHeld} from './core/verdict.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'held-private-export',setup(b){b.onLoad({filter:/[/\\]core[/\\]verdict\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {heldNotFinal as probeHeld};'}));}}]});
 const nativeFile=path.join(dir,'solid.mjs');fs.writeFileSync(nativeFile,native.outputFiles[0].text);
 const lit=lit=>({lit}),read=read=>({read}),arg=argument=>({argument});let count=0;
 async function scenario(route,body,setup=[]){
  const S=await import(pathToFileURL(nativeFile).href+'?case='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S});
  const node=name=>Object.getOwnPropertySymbols(s.accessors[name]).map(k=>s.accessors[name][k]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v);
  b.raw=()=>{if(route!=='equals')b.world=ABI.primeRawLane(b.world,b.ids.value,route==='held'?1:2,b.encode(3));const m=route==='equals'?ABI.rawLaneEquals(b.fuel,b.world,b.ids.value,b.encode(2),b.encode(3)):route==='held'?ABI.rawHeldNotFinal(b.fuel,b.world,b.ids.value):ABI.rawTruthRead(b.fuel,b.world,b.ids.value);b.world=ABI.resultWorld(m);b.check();return b.decode(ABI.resultValue(m));};
  s.raw=()=>{const n=node('value');if(route!=='equals'){S.ext(n)._lane=n._value;n._pendingValue=3;n._config|=route==='held'?S.K.CONFIG_HELD:S.K.CONFIG_OVERRIDE|S.K.CONFIG_GUESS;}return route==='equals'?n._equals(2,3):route==='held'?S.probeHeld(n):S.truthRead(n);};
  const commands=[['program','unused',[['throw',91]]],...setup,['program','cmp',[['emit',31],...body]],['signal','value',2,{equals:{callback:'cmp'}}],['raw']];
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
 for(const route of['equals','held','truth']){
  for(const verdict of[true,false,0,7,null,undefined,'','yes',{ref:7},{callback:'unused'}])await scenario(route,[['return',lit(verdict)]]);
  for(const error of[undefined,null,false,0,9,'failed',{ref:8},{error:1,kind:'TypeError',message:'comparison failed'}])await scenario(route,[['throwExpr',lit(error)]]);
  for(const seeded of[false,true])await scenario(route,[['eval',read('gate')],['return',lit(true)]],[['future','p'],['memo','gate',{future:'p'},seeded?{loadingValue:0}:{}]]);
  for(const side of[0,1])await scenario(route,[['return',arg(side)]]);
 }
 console.log(`${count} native raw comparator controls preserve arbitrary return truthiness, arguments, identity, user throws/NotReady and absence of isSame error wrapping across lane/truth/held-finality sites.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
