import assert from 'node:assert/strict';
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import {spawnSync} from 'node:child_process';import {fileURLToPath,pathToFileURL} from 'node:url';import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-from-bind-'));
const list=xs=>{const out=[];while('head'in xs){out.push(xs.head);xs=xs.tail;}return out;};
const disposals=d=>'callbacks'in d?list(d.callbacks):'callback'in d?[d.callback]:[];
try{
 let driver=path.join(root,'tests/probes/from-bind.bend');
 if(process.env.BEND_EMIT_FILE){for(const name of['runtime','representation','observation'])fs.cpSync(path.join(path.dirname(process.env.BEND_EMIT_FILE),name),path.join(dir,name),{recursive:true});fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});fs.copyFileSync(driver,path.join(dir,'tests/probes/from-bind.bend'));driver=path.join(dir,'tests/probes/from-bind.bend');}
 const emitted=path.join(dir,'probe.mjs'),compiled=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',driver,'-o',emitted],{cwd:root,encoding:'utf8'});assert.equal(compiled.status,0,compiled.stderr.slice(-2400));const {default:B}=await import(pathToFileURL(emitted));
 const source=path.join(root,'upstream/solid/packages/signals/src');const bundle=await build({stdin:{contents:`export {from} from './from.ts';export {computed,ext,setContextInternal} from './core/core.ts';export {createOwner} from './core/owner.ts';export * as K from './core/constants.ts';`,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}});const ref=path.join(dir,'solid.mjs');fs.writeFileSync(ref,bundle.outputFiles[0].text);const S=await import(pathToFileURL(ref));
 let count=0;
 for(const context of[0,1,2])for(const flags of[0,S.K.REACTIVE_RECOMPUTING_DEPS])for(const forbidden of[false,true])for(const hasExt of[false,true])for(const flight of[0,1,2])for(const previous of[false,true])for(const thrown of[false,true]){
  const a=B.probe(context,flags,forbidden,hasExt,flight,previous,thrown),w=a.world,ns=list(w.nodes),xs=list(w.extensions),bn=ns[context],bx=bn?.x?xs[bn.x]:null;
  S.setContextInternal(null);const root=S.createOwner(),memo=S.computed(()=>1,{lazy:true}),owner=[null,root,memo][context];memo._flags=flags;if(owner)owner._config=forbidden?S.K.CONFIG_CHILDREN_FORBIDDEN:0;
  const calls=[],prior=()=>calls.push(1),active={};if(hasExt&&owner){const x=S.ext(owner);x._inFlight=flight===0?undefined:flight===1?null:active;x._flightTeardown=previous?prior:null;}
  S.setContextInternal(owner);const it=S.from(()=>()=>{calls.push(2);if(thrown)throw 99;})[Symbol.asyncIterator]();const nx=owner?._x,d=owner?._disposal,ds=Array.isArray(d)?d:d?[d]:[],nativeFinish=ds.at(-1),bd=bn?disposals(bn.disposal):[];
  assert.equal(!!bx,!!nx);if(bx){assert.equal(bx.inFlight.$,nx._inFlight===undefined?'FlightUndefined':nx._inFlight===null?'FlightEmpty':'FlightActive');assert.equal(bx.flightTeardown===0,!nx._flightTeardown);if(nx._flightTeardown===prior)assert.equal(bx.flightTeardown,1);else if(nx._flightTeardown===nativeFinish)assert.equal(bx.flightTeardown,a.finish);else if(nx._flightTeardown)assert.equal(bx.flightTeardown===a.finish,!(hasExt&&previous&&context===2&&flags===S.K.REACTIVE_RECOMPUTING_DEPS));}
  assert.equal(bd.length,ds.length);if(bd.length)assert.equal(bd.at(-1),a.finish);
  owner?._x?._flightTeardown?.();assert.deepEqual(await it.return(),{done:true,value:undefined});assert.equal(a.returned.world.fault.$,'Healthy');assert.deepEqual(list(a.returned.world.events).filter(e=>e.$==='CleanupObserved').map(e=>e.code),calls);
  const returned=list(a.returned.values)[0];assert.equal(returned.$,'AsyncValue');const state=list(a.returned.world.asyncObjects)[returned.identity].state;assert.equal(state.$,'Fulfilled');assert.deepEqual(state.value,{$:'StepResult',done:true,value:{$:'Undefined'}});
  S.setContextInternal(null);count++;
 }
 console.log(`${count} actual from factory/bindToOwner controls preserve fresh/active flight slots, prior hook identity, forbidden cleanup routing, shared finish identity, callback returns and swallowed unsubscribe errors. These are private protocol controls, not public histories.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
