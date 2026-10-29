import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-transaction-probe-'));
try{
  const emitted=path.join(dir,'transaction.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/transaction.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';export * as K from './core/constants.ts';
    export {signal,computed,createEffectNode,setContextInternal,ext,joinPass,bornInto,probeFrameRead} from './core/core.ts';
    export {link} from './core/graph.ts';export {createOwner} from './core/owner.ts';export * from './core/scheduler.ts';
    export {merge,newTransaction,joinFuture,joinPassTx,holdNode,list,unhold,staleReader,txOf,liveTx,resolveTx,blocked,ownFlights,blockersOf} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'transaction-state',setup(b){
      b.onLoad({filter:/[/\\]core[/\\]core\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {frameRead as probeFrameRead};'}));
      b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
        export {transactions as probeTransactions,holdFrame as probeHoldFrame,blockedBy as probeBlockedBy,scheduled as probeScheduled};
        export function probeSetState(running,pass,flush){globalQueue._running=running;passTx=pass;flushTransaction=flush;}
        export function probeReset(){guessing=false;clock=0;notifyEpoch=0;scheduled=false;syncDepth=1;pendingNodes.length=heldTrims.length=deferredZombies.length=transactions.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;halted=haltNotified=false;passTx=flushTransaction=passLane=judge=null;}
      `}));
    }
  }]});
  const refFile=path.join(dir,'solid.mjs');fs.writeFileSync(refFile,bundle.outputFiles[0].text);const S=await import(pathToFileURL(refFile)),K=S.K;
  const list=xs=>{const a=[];while('head'in xs){a.push(xs.head);xs=xs.tail;}return a;};
  function actual({world:w,answer}){const xs=list(w.extensions);assert.equal(w.fault.$,'Healthy');return {answer,
    nodes:list(w.nodes).slice(1).map(n=>({config:n.config,flags:n.flags,status:n.status,tx:xs[n.x]?.transaction??0,first:n.firstChild,next:n.nextSibling,prev:n.prevSibling})),
    transactions:list(w.txArena).slice(1).map(t=>({nodes:list(t.nodes),render:list(t.renderQueue),user:list(t.userQueue).map(e=>e.node),reruns:list(t.reruns),into:t.into,parent:t.parent,lane:t.lane,verdict:t.verdict,open:t.open,acted:t.acted,links:t.links,shown:t.shown,held:t.held,marks:'items'in t.marks?list(t.marks.items):null})),
    live:list(w.transactions),flush:w.flushTransaction,pass:w.passTx,lane:w.passLane,judge:w.judge,scheduled:w.scheduled,running:w.running};}
  function reference(op,running,own,config,status,extra){
    S.probeReset();S.setContextInternal(null);const r=S.createOwner(),x=S.signal(7);S.setContextInternal(r);
    const a=S.computed(()=>7,{lazy:true}),render=S.createEffectNode(()=>7,()=>{},undefined,K.EFFECT_RENDER),user=S.createEffectNode(()=>7,()=>{},undefined,K.EFFECT_USER);
    S.setContextInternal(a);const child=S.createOwner();S.setContextInternal(child);const leaf=S.computed(()=>7,{lazy:true});S.setContextInternal(null);
    const ns=[null,r,x,a,render,user,child,leaf],id=n=>n?ns.indexOf(n):0,ts=[null,S.newTransaction(false),S.newTransaction(false)];ts.push(S.newTransaction(true,ts[1]));const txid=t=>t?ts.indexOf(t):0;
    S.list(a,ts[1]);S.list(x,ts[2]);Object.assign(ts[1],{_marks:own?[r]:null});Object.assign(ts[2],{_open:1,_acted:true,_marks:extra?[x]:null});
    const cb4=()=>{},cb5=()=>{},cbid=cb=>cb===cb4?4:5;ts[1]._queues=[[cb4],[cb5]];ts[2]._queues=[[cb4,cb4],[]];ts[2]._reruns=[a];a._flags=0;a._config=config;a._statusFlags=render._statusFlags=user._statusFlags=status;if(extra)S.list(leaf,ts[3]);S.probeSetState(running,null,null);
    let answer=0;
    if(op===0)S.joinFuture(null);
    if(op===1)S.joinFuture(ts[1]);
    if(op===2){S.joinFuture(ts[1]);S.joinFuture(ts[2]);}
    if(op===3){S.joinFuture(ts[2]);S.joinFuture(ts[1]);}
    if(op===4)S.joinPassTx(ts[1],own);
    if(op===5){S.probeSetState(running,ts[1],null);S.joinPassTx(ts[2],own);}
    if(op===6){S.holdNode(a,ts[1]);S.holdNode(a,ts[1]);}
    if(op===7){S.list(a,ts[2]);S.merge(ts[1],ts[2]);answer=txid(S.txOf(a));}
    if(op===8){S.merge(ts[1],ts[2]);S.merge(ts[1],ts[2]);}
    if(op===9){S.merge(ts[3],ts[1]);S.merge(ts[1],ts[3]);}
    if(op===10){S.merge(ts[1],ts[2]);answer=txid(S.liveTx(ts[1]));}
    if(op===11){S.holdNode(a,ts[1]);S.unhold(a);}
    if(op===12){S.staleReader(render,ts[1]);S.staleReader(render,ts[1]);}
    if(op===13)S.probeHoldFrame(a,ts[2]);
    if(op===14)answer=+!!S.bornInto(a,ts[1]);
    if(op===15){if(extra)S.probeSetState(running,null,ts[1]);answer=+S.probeFrameRead(own?render:user,a);}
    if(op===16)S.joinPass(own?render:user,a);
    if(op===17){S.merge(ts[1],ts[2]);answer=txid(S.txOf(a));}
    if(op===0)ts.push(S.flushTransaction);
    return {answer,nodes:ns.slice(1).map(n=>({config:n._config,flags:n._flags??0,status:n._statusFlags??0,tx:txid(n._x?._transaction),first:id(n._firstChild),next:id(n._nextSibling),prev:id(n._prevSibling)})),
      transactions:ts.slice(1).map(t=>({nodes:t._nodes.map(id),render:t._queues[0].map(cbid),user:t._queues[1].map(cbid),reruns:t._reruns.map(id),into:txid(t._into),parent:txid(t._parent),lane:t._lane,verdict:txid(t._verdict),open:t._open,acted:t._acted,links:0,shown:t._shown,held:t._held,marks:t._marks?.map(id)??null})),
      live:S.probeTransactions.map(txid),flush:txid(S.flushTransaction),pass:txid(S.passTx),lane:txid(S.passLane),judge:0,scheduled:S.probeScheduled,running:S.globalQueue._running};
  }
  function referenceBlock(op,status,flags,config,kind,readerStatus,readerFlags,readerConfig,readerKind,stale,error,foreign,merged,ancestor,sources,open){
    S.probeReset();S.setContextInternal(null);const r=S.createOwner(),x=S.signal(7);S.setContextInternal(r);
    const a=S.computed(()=>7,{lazy:true}),render=S.createEffectNode(()=>7,()=>{},undefined,K.EFFECT_RENDER),user=S.createEffectNode(()=>7,()=>{},undefined,K.EFFECT_USER);
    S.setContextInternal(a);const child=S.createOwner();S.setContextInternal(child);const leaf=S.computed(()=>7,{lazy:true});S.setContextInternal(null);
    const ns=[null,r,x,a,render,user,child,leaf],id=n=>n?ns.indexOf(n):0,ts=[null,S.newTransaction(false),S.newTransaction(false)];ts.push(S.newTransaction(true,ts[1]));const txid=t=>t?ts.indexOf(t):0;
    S.list(a,ts[1]);S.list(x,ts[2]);Object.assign(ts[2],{_open:1,_acted:true});
    const cb4=()=>{},cb5=()=>{},cbid=cb=>cb===cb4?4:5;ts[1]._queues=[[cb4],[cb5]];ts[2]._queues=[[cb4,cb4],[]];ts[2]._reruns=[a];
    Object.assign(a,{_config:config,_statusFlags:status,_flags:flags,_type:kind===0?0:kind===1?K.EFFECT_RENDER:K.EFFECT_USER});
    user._statusFlags=status;Object.assign(render,{_statusFlags:readerStatus,_flags:readerFlags,_config:readerConfig,_type:readerKind===0?0:readerKind===1?K.EFFECT_RENDER:K.EFFECT_USER,_parent:a});
    S.link(a,render);if(stale)render._deps._gen=1;if(error)S.ext(render)._error=error===1?null:error===2?false:42;
    if(foreign)S.list(a,ts[2]);if(merged)S.merge(ts[2],ts[1]);if(ancestor)S.holdNode(r,ts[1]);
    S.ext(a)._pendingSources=sources===0?undefined:new Set(sources===1?[]:sources===2?[x]:[x,a]);ts[1]._open=open?1:0;
    let answer=0,blockers=[];if(op===0)answer=+S.blocked(ts[1]);if(op===1)answer=+S.ownFlights(ts[1]);if(op===2)answer=+S.probeBlockedBy([a],ts[1]);if(op===3)blockers=S.blockersOf(ts[1]).map(id);
    return {answer,nodes:ns.slice(1).map(n=>({config:n._config,flags:n._flags??0,status:n._statusFlags??0,tx:txid(n._x?._transaction),first:id(n._firstChild),next:id(n._nextSibling),prev:id(n._prevSibling)})),
      transactions:ts.slice(1).map(t=>({nodes:t._nodes.map(id),render:t._queues[0].map(cbid),user:t._queues[1].map(cbid),reruns:t._reruns.map(id),into:txid(t._into),parent:txid(t._parent),lane:t._lane,verdict:txid(t._verdict),open:t._open,acted:t._acted,links:0,shown:t._shown,held:t._held,marks:t._marks?.map(id)??null})),
      live:S.probeTransactions.map(txid),flush:txid(S.flushTransaction),pass:txid(S.passTx),lane:txid(S.passLane),judge:0,scheduled:S.probeScheduled,running:S.globalQueue._running,blockers};
  }
  let count=0;
  for(let op=0;op<18;op++)for(const running of [false,true])for(const own of [false,true])for(const config of [0,K.CONFIG_HELD,K.CONFIG_HELD|K.CONFIG_HELD_FRAME,K.CONFIG_HELD|K.CONFIG_INPUTS_PUBLISHED,K.CONFIG_HELD|K.CONFIG_LAGS])for(const status of [0,K.STATUS_UNINITIALIZED,K.STATUS_PENDING])for(const extra of [false,true]){
    assert.deepEqual(actual(B.fixture(op,running,own,config,status,extra)),reference(op,running,own,config,status,extra),JSON.stringify({op,running,own,config,status,extra}));count++;
  }
  let seed=0x9e4173,blockCount=0;const rng=n=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return (seed>>>0)%n;};
  for(let index=0;index<4096;index++){
    const args=[index%4,rng(8),[0,K.REACTIVE_DISPOSED,K.REACTIVE_ZOMBIE][rng(3)],[0,K.CONFIG_HELD,K.CONFIG_GUESS][rng(3)],rng(3),rng(8),
      [0,K.REACTIVE_DISPOSED,K.REACTIVE_ZOMBIE,K.REACTIVE_FRAME_READ,K.REACTIVE_FRAME_READ|K.REACTIVE_ZOMBIE][rng(5)],rng(2)?K.CONFIG_REDERIVE:0,rng(3),!!rng(2),rng(4),!!rng(2),!!rng(2),!!rng(2),rng(4),!!rng(2)];
    const result=B.blockFixture(...args);assert.deepEqual({...actual(result),blockers:list(result.blockers)},referenceBlock(...args),'block '+JSON.stringify(args));blockCount++;
  }
  console.log(`${count} transaction-state and ${blockCount} blocker comparisons match TS merging/joins, held frames, own-source filtering, stale-link/error gates, zombie removal judgments and blocker lists.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
