// Operation-level parity for #4254's idle pending-queue scheduling guard.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-idle-disposal-'));
try{
 const output=path.join(dir,'probe.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/idle-owner.bend','-o',output],{cwd:root,encoding:'utf8'});assert.equal(compile.status,0,compile.stderr);
 const B=(await import(pathToFileURL(output))).default;
 const bundled=await build({stdin:{contents:`export {computed,signal,ext,setContextInternal} from './core/core.ts';export {createOwner,disposeChildren} from './core/owner.ts';export * as K from './core/constants.ts';export {probeReset,probePending,probeScheduled} from './core/scheduler.ts';`,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'idle-scheduler-probe',setup(b){b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`\nexport {pendingNodes as probePending, scheduled as probeScheduled};export function probeReset(){rethrowCleanupError(true);pendingNodes.length=0;scheduled=false;globalQueue._running=true;dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;}`}));}}]});
 const native=path.join(dir,'native.mjs');fs.writeFileSync(native,bundled.outputFiles[0].text);const S=await import(pathToFileURL(native));let cases=0;
 for(const queued of [false,true])for(const self of [false,true])for(const computed of [false,true])for(const pending of [false,true])for(const transaction of [false,true])for(const frame of [false,true]){
  S.probeReset();S.setContextInternal(null);const node=computed?S.computed(()=>1,{lazy:true}):S.createOwner();node._flags=frame?S.K.REACTIVE_FRAME_READ:0;node._statusFlags=pending?S.K.STATUS_PENDING:0;
  if(transaction)S.ext(node)._transaction={};if(queued)S.probePending.push(S.signal(0));S.disposeChildren(node,self);
  const want=self&&computed&&((pending&&transaction)||frame||queued);assert.equal(S.probeScheduled,want,'native guard control');assert.equal(B.fixture(queued,self,computed,pending,transaction,frame).scheduled,want,'Bend follows native scheduling');cases++;
 }
 console.log(`${cases} idle-disposal scheduling guard cases match pinned native Solid, including empty queue/non-computed/non-self controls. GC itself is outside the represented heap model.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
