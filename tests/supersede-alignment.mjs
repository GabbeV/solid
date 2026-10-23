import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-supersede-probe-'));
const list=xs=>{const out=[];while('head'in xs){out.push(xs.head);xs=xs.tail;}return out;};
try{
 const emitted=path.join(dir,'supersede.mjs');
 let driver=path.join(root,'tests/probes/supersede.bend');
 if(process.env.BEND_EMIT_FILE){
  const sourceRoot=path.dirname(process.env.BEND_EMIT_FILE);
  for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(dir,name),{recursive:true});
  fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});
  const target=path.join(dir,'tests/probes/supersede.bend');fs.copyFileSync(driver,target);driver=target;
 }
 const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',driver,'-o',emitted],{cwd:root,encoding:'utf8'});
 assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
 const source=path.join(root,'upstream/solid/packages/signals/src');
 const bundle=await build({stdin:{contents:`export {onSupersede} from './core/async.ts';export {computed,signal,ext,setContextInternal} from './core/core.ts';export {createOwner} from './core/owner.ts';export * as K from './core/constants.ts';`,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}});
 const reference=path.join(dir,'solid.mjs');fs.writeFileSync(reference,bundle.outputFiles[0].text);const S=await import(pathToFileURL(reference));
 const slot=x=>x.$==='FlightUndefined'?'undefined':x.$==='FlightEmpty'?'null':'active';
 let count=0;
 for(const context of [0,1,2,3])for(const flags of [0,S.K.REACTIVE_RECOMPUTING_DEPS,S.K.REACTIVE_RECOMPUTING_DEPS|S.K.REACTIVE_DIRTY])for(const hasExt of [false,true])for(const flight of [0,1,2])for(const previous of [false,true])for(const hooks of [0,1,2])for(const errors of [[0,0,0],[0,2,0],[1,0,3],[1,2,3]])for(const invoke of [false,true]){
  const actual=B.probe(context,flags,hasExt,flight,previous,hooks,...errors,invoke),w=actual.registered,ns=list(w.nodes),xs=list(w.extensions),n=ns[context],x=n?.x?xs[n.x]:null;
  S.setContextInternal(null);const owner=S.createOwner(),signal=S.signal(0),memo=S.computed(()=>1,{lazy:true});memo._flags=flags;
  const calls=[],payloads=[null,{id:1},{id:2},{id:3}],callbacks=[null,...[1,2,3].map((code,i)=>()=>{calls.push(code);if(errors[i])throw payloads[errors[i]];})];
  const active={};if(hasExt){const x=S.ext(memo);x._inFlight=flight===0?undefined:flight===1?null:active;x._flightTeardown=previous?callbacks[1]:null;}
  const native=[null,owner,signal,memo][context];S.setContextInternal(native);
  for(let i=0;i<hooks;i++)S.onSupersede(callbacks[i+2]);
  const nativeX=native?._x;
  const expected={extension:!!nativeX,flight:nativeX?(nativeX._inFlight===undefined?'undefined':nativeX._inFlight===null?'null':'active'):null,teardown:nativeX?callbacks.indexOf(nativeX._flightTeardown)>0?callbacks.indexOf(nativeX._flightTeardown):nativeX._flightTeardown?'chain':null:null};
  assert.deepEqual({extension:!!x,flight:x?slot(x.inFlight):null,teardown:x?x.flightTeardown>=4?'chain':x.flightTeardown||null:null},expected,JSON.stringify({context,flags,hasExt,flight,previous,hooks,errors,invoke}));
  let error=null;if(invoke&&nativeX?._flightTeardown)try{nativeX._flightTeardown();}catch(e){error=payloads.indexOf(e);}
  const final=actual.final.world;assert.deepEqual(list(final.events).filter(e=>e.$==='CleanupObserved').map(e=>e.code),calls);
  assert.equal(final.fault.$,error===null?'Healthy':'CallbackThrown');if(error!==null)assert.equal(final.fault.cause.id,error);
  assert.deepEqual(list(actual.final.values),error===null&&invoke&&nativeX?._flightTeardown?[{$:'Undefined'}]:[]);
  assert.equal(list(final.extensions).length,list(w.extensions).length);
  S.setContextInternal(null);count++;
 }
 console.log(`${count} actual internal onSupersede controls preserve eligibility, fresh undefined versus null, active identities, closure chaining, order, finally execution and error precedence. These synthetic states are not public histories.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
