// Compare unchanged native servesStaged with the Bend leaf, including the
// served-clock latch and allocated-empty Set identity. These are private states.
import assert from 'node:assert/strict';
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import {spawnSync} from 'node:child_process';import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-staged-answer-'));
try{
 const active=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(active,name),path.join(dir,name),{recursive:true});
 fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});fs.copyFileSync(path.join(root,'tests/probes/staged-answer.bend'),path.join(dir,'tests/probes/staged-answer.bend'));
 const output=path.join(dir,'probe.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'tests/probes/staged-answer.bend'),'-o',output],{cwd:root,encoding:'utf8',maxBuffer:1024*1024});assert.equal(r.status,0,r.stderr);const B=(await import(pathToFileURL(output))).default;
 const source=path.join(root,'upstream/solid/packages/signals/src');
 const bundle=await build({stdin:{contents:`export {servesStaged as serve,ext} from './core/core.ts';export {setPassLane,probeSetClock} from './core/scheduler.ts';export * as K from './core/constants.ts';`,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'exports-and-clock-only',setup(b){b.onLoad({filter:/[/\\]core[/\\]core\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport {servesStaged};'}));b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},a=>({loader:'ts',contents:fs.readFileSync(a.path,'utf8')+'\nexport function probeSetClock(v){clock=v;}'}));}}]});
 const ref=path.join(dir,'solid.mjs');fs.writeFileSync(ref,bundle.outputFiles[0].text);const S=await import(pathToFileURL(ref)),K=S.K;
 const list=xs=>{const out=[];while('head'in xs){out.push(xs.head);xs=xs.tail;}return out;};
 const observeB=w=>{const n=B.node(w),x=B.extension(w),pending=B.pending(w);return{flags:n.flags,extension:n.x!==0,served:x.served.$==='Stamped'?x.served.value:undefined,set:pending.$==='Sources'?list(pending.items):undefined};};
 const observeS=(c,source)=>({flags:c._flags,extension:c._x!==null,served:c._x?._served,set:c._x?._pendingSources?[...c._x._pendingSources].map(x=>x===source?2:3):undefined});
 let checked=0;
 for(const rs of [0,K.STATUS_UNINITIALIZED,K.STATUS_UNINITIALIZED|K.STATUS_PENDING])for(const ss of [0,K.STATUS_UNINITIALIZED])for(const flags of [0,K.REACTIVE_MISSED_WAKE])for(const config of [0,K.CONFIG_HELD,K.CONFIG_STAGED_ERROR])for(const effect of [false,true])for(const readerSlot of [false,true])for(const sourceSlot of [false,true])for(const lane of [false,true])for(const clock of [0,1])for(const stamp of [0,1,2])for(const mode of [0,1,2,3,4]){
  let w=B.fixture(rs,ss,flags,config,effect,readerSlot,sourceSlot,lane,clock,stamp,mode);
  const c={_statusFlags:rs,_flags:flags,_pendingValue:readerSlot?1:K.NOT_PENDING,_x:null},source={_statusFlags:ss,_config:config,_pendingValue:sourceSlot?77:K.NOT_PENDING,_x:{_error:{source:null}}};source._x._error.source=source;if(effect)c._type=1;
  if(stamp||mode)S.ext(c);if(stamp)c._x._served=stamp===1?clock:clock+1;
  if(mode)c._x._pendingSources=new Set(mode===2?[source]:mode===3?[c]:mode===4?[source,c]:[]);
  S.setPassLane(lane?{}:null);S.probeSetClock(clock);
  const setId=B.extension(w).pendingSources;
  const set=c._x?._pendingSources,expected=!!S.serve(c,source,source),actual=B.serve(w);w=actual.left;
  const label=JSON.stringify([rs,ss,flags,config,effect,readerSlot,sourceSlot,lane,clock,stamp,mode]);
  assert.equal(actual.right,expected,label);assert.deepEqual(observeB(w),observeS(c,source),label+' poststate');
  if(set){assert.equal(c._x._pendingSources,set,label+' retained Set identity');assert.equal(B.extension(w).pendingSources,setId,label+' retained Bend Set identity');}
  // Repeated reads in a served pass retain its value, then an aborted pass
  // clearing the latch must respect the same-clock served stamp.
  const twice=B.serve(w);assert.equal(twice.right,!!S.serve(c,source,source),label+' repeat');assert.deepEqual(observeB(twice.left),observeS(c,source),label+' repeat state');
  c._flags&=~K.REACTIVE_MISSED_WAKE;const retry=B.serve(B.clearLatch(twice.left));assert.equal(retry.right,!!S.serve(c,source,source),label+' reask');assert.deepEqual(observeB(retry.left),observeS(c,source),label+' reask state');checked++;
 }
 console.log(`${checked} first-answer/reask private fixtures compare three helper calls, served stamps at clocks0/1, optional and allocated-empty Sets, pending deletion, reader kinds and held/error/lane gates against unchanged source.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
