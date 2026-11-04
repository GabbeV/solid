// Direct source holdStaging controls: include absent/zero-clock marks and
// raw transaction identity/redirects. No mounted boundary or store is created.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-hold-staging-'));
try{
 const active=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(active,name),path.join(dir,name),{recursive:true});
 fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});fs.copyFileSync(path.join(root,'tests/probes/verdict-staging.bend'),path.join(dir,'tests/probes/verdict-staging.bend'));
 const emitted=path.join(dir,'probe.mjs'),r=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'tests/probes/verdict-staging.bend'),'-o',emitted],{cwd:root,encoding:'utf8'});assert.equal(r.status,0,r.stderr);const B=(await import(pathToFileURL(emitted))).default;
 const source=path.join(root,'upstream/solid/packages/signals/src');
 const bundle=await build({stdin:{contents:`export * from './index.ts';export * as K from './core/constants.ts';export {signal,computed,ext,setContextInternal,probeFrameRead} from './core/core.ts';export {probeHoldStaging} from './core/verdict.ts';export {verdictLane,probeNewLane,probeResetLanes} from './core/lanes.ts';export {newTransaction,merge,setPassLane,passLane,probeReset,probeSet,probeFlush,probePass} from './core/scheduler.ts';`,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'source-segment',setup(b){
  b.onLoad({filter:/[/\\]core[/\\]core\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {frameRead as probeFrameRead};'}));
  b.onLoad({filter:/[/\\]core[/\\]verdict\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {holdStaging as probeHoldStaging};'}));
  b.onLoad({filter:/[/\\]core[/\\]lanes\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {newLane as probeNewLane};export function probeResetLanes(){ahead.length=revealing.length=kept.length=lanes.length=pendingGuesses.length=judged=0;guessed=reverting=false;}'}));
  b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {flushTransaction as probeFlush,passTx as probePass};export function probeReset(){latestOpened=null;clock=notifyEpoch=0;scheduled=false;syncDepth=1;transactions.length=stagedReaders.length=pendingNodes.length=0;passLane=passTx=flushTransaction=judge=null;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=dirtyQueue._max=0;dirtyQueue._marked=false;}export function probeSet(t,k){flushTransaction=t;clock=k;}'}));
 }}]});
 const native=path.join(dir,'source.mjs');fs.writeFileSync(native,bundle.outputFiles[0].text);const S=await import(pathToFileURL(native)),K=S.K;
 const list=xs=>{const result=[];while('head'in xs){result.push(xs.head);xs=xs.tail;}return result;};
 function check(readerConfig,readerFlags,sourceConfig,staged,kind,owner,flush,lane,clock,redirect){
  const args=[readerConfig>>>0,readerFlags,sourceConfig>>>0,staged,kind,owner,flush,lane,clock,redirect],pair=B.fixture(...args),w=pair.left;assert.equal(w.fault.$,'Healthy',JSON.stringify(args));
  S.probeReset();S.probeResetLanes();S.setContextInternal(null);const n=S.signal(7),c=S.computed(()=>2,{lazy:true}),tx=[null,S.newTransaction(false),S.newTransaction(false)];tx.push(S.verdictLane(tx[1]),S.probeNewLane(tx[2]));
  n._config=sourceConfig;n._pendingValue=staged?23:K.NOT_PENDING;c._config=readerConfig;c._flags=readerFlags;const x=S.ext(n);x._transaction=tx[owner];x._askedIn=[undefined,0,9,tx[1],tx[2]][kind];if(redirect)S.merge(tx[1],tx[2]);S.probeSet(tx[flush],clock);S.setPassLane(tx[lane]);
  const answer=!!S.probeHoldStaging(c,n);
  assert.deepEqual({answer:pair.right,lane:w.passLane,into:list(w.txArena).slice(1).map(t=>t.into)},{answer,lane:tx.indexOf(S.passLane),into:tx.slice(1).map(t=>tx.indexOf(t._into))},JSON.stringify(args));count++;return {pair,n,c,tx};
 }
 let count=0;
 // Source _askedIn transaction marks are resolved only with a real captured
 // hold or current flush; malformed null Transaction dereferences are excluded.
 for(const kind of [0,1,2,3,4])for(const owner of [0,1,2])for(const flush of [0,1,2])for(const lane of [0,3,4])for(const clock of [0,9])for(const redirect of [false,true])for(const held of [false,true])if((!held||owner!==0)&&(kind<3||held||flush!==0))check(0,0,held?K.CONFIG_HELD:0,true,kind,owner,flush,lane,clock,redirect);
 for(const readerConfig of [0,K.CONFIG_OWN_PROBE,K.CONFIG_FRAME])for(const readerFlags of [0,K.REACTIVE_WINDOW,K.REACTIVE_PROBE_UNANSWERED])for(const sourceConfig of [0,K.CONFIG_ASYNC,K.CONFIG_OVERRIDE])for(const staged of [false,true])check(readerConfig,readerFlags,sourceConfig,staged,0,0,0,3,9,false);
 const holdCount=count;let frameCount=0;
 // A lane's raw `over` may resolve to the held source's owner. The actual
 // frameRead then refuses the screen before the born/current-flush tests;
 // a verdict reader retains the other branch. Store creation of `over` is
 // outside this profile; these are explicit raw metadata fixtures.
 for(const owner of [1,2])for(const over of [0,1,2])for(const lane of [0,3,4])for(const verdict of [false,true])for(const redirect of [false,true]){
  const {pair,n,c,tx}=check(K.CONFIG_FRAME|(verdict?K.CONFIG_VERDICT:0),0,K.CONFIG_HELD,true,0,owner,0,lane,9,redirect);
  tx[lane||3].over=tx[over]??undefined;const before=B.withOver(pair.left,lane||3,over),actual=B.frame(before),answer=!!S.probeFrameRead(c,n),w=actual.left;
  assert.equal(w.fault.$,'Healthy');assert.deepEqual({answer:actual.right,flush:w.flushTransaction,pass:w.passTx,lane:w.passLane,flags:list(w.nodes)[2].flags},{answer,flush:tx.indexOf(S.probeFlush),pass:tx.indexOf(S.probePass),lane:tx.indexOf(S.passLane),flags:c._flags},JSON.stringify({owner,over,lane,verdict,redirect}));frameCount++;
 }
 console.log(`${holdCount} holdStaging comparisons preserve absent versus zero-clock marks, raw/resolved transaction identity, gate priority and verdict-lane exit; ${frameCount} actual frameRead over-owner/verdict controls also pass.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
