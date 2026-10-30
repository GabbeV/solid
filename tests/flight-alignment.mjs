import {decodeQuestion} from './question-codec.mjs';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-flight-probe-'));
try{
  const emitted=path.join(dir,'flight.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/flight.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';export * as K from './core/constants.ts';
    export {signal,computed,setContextInternal,ext,context,tracking,unflushedStaged} from './core/core.ts';
    export {createOwner,dispose} from './core/owner.ts';export {link} from './core/graph.ts';
    export {handleAsync} from './core/async.ts';export {NotReadyError,StatusError} from './core/error.ts';
    export {newTransaction,holdNode,globalQueue,dirtyQueue,clock,probeReset,probePending,probeTrims,probeTransactions,probeScheduled,probeHalted} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'flight-state',setup(b){
      b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
        export {pendingNodes as probePending,heldTrims as probeTrims,transactions as probeTransactions,scheduled as probeScheduled,halted as probeHalted};
        export function probeReset(){latestOpened=null;guessing=false;clock=5;notifyEpoch=0;scheduled=false;syncDepth=1;pendingNodes.length=heldTrims.length=deferredZombies.length=transactions.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=0;dirtyQueue._max=0;dirtyQueue._marked=false;halted=haltNotified=false;passTx=flushTransaction=passLane=judge=null;}
      `}));
    }
  }]});
  const refFile=path.join(dir,'solid.mjs');fs.writeFileSync(refFile,bundle.outputFiles[0].text);const S=await import(pathToFileURL(refFile)),K=S.K;
  const list=xs=>{const a=[];while('head'in xs){a.push(xs.head);xs=xs.tail;}return a;};
  function actual({world:w,result}){
    const xs=list(w.extensions),sets=list(w.pendingSets),errors=new Map();
    const decode=v=>{if('source'in v&&'identity'in v){if(!errors.has(v.identity))errors.set(v.identity,errors.size+1);return {kind:'cause'in v?'error':'pending',identity:errors.get(v.identity),source:v.source,...('cause'in v?{cause:decode(v.cause)}:{})};}return v.$==='Null'?null:'n'in v?v.n:'b'in v?v.b:undefined;};
    return {returned:'value'in result,result:decode(result.value??{}),nodes:list(w.nodes).slice(1).map(n=>({value:decode(n.value),config:n.config,flags:n.flags,status:n.status,time:n.time,loading:n.loading,pending:'value'in n.pending,pendingValue:decode(n.pending.value??{}),deps:n.deps,tail:n.depsTail,subs:n.subs,subsTail:n.subsTail,first:n.firstChild,next:n.nextSibling,prev:n.prevSibling,gen:n.depGen,
      x:n.x?{flight:(xs[n.x].inFlight.result??0),q:decodeQuestion(xs[n.x].q),error:decode(xs[n.x].error),shown:decode(xs[n.x].shownError),blocked:'value'in xs[n.x].blocked?decode(xs[n.x].blocked.value):undefined,sources:xs[n.x].pendingSources?list(sets[xs[n.x].pendingSources]).filter(id=>id!==0):undefined,tx:xs[n.x].transaction}:null})),
      links:list(w.links).slice(1).map(l=>({...l,$:undefined})),pending:list(w.pendingNodes),trims:list(w.trims),live:list(w.transactions),clock:w.clock,scheduled:w.scheduled,running:w.running,context:w.context,tracking:w.tracking,halted:w.halted,threw:w.fault.$!=='Healthy',exception:decode(w.fault.cause??{}),queues:[list(w.renderQueue),list(w.userQueue).map(e=>e.node)]};
  }
  function reference(mode,action,status,flags,config,loading,subscriber,staging,held,code){
    S.probeReset();S.setContextInternal(null);const root=S.createOwner(),x=S.signal(7);S.setContextInternal(root);
    const n=S.computed(()=>11,{lazy:true}),c=S.computed(()=>0,{lazy:true});S.setContextInternal(null);
    const ns=[null,root,x,n,c],id=n=>n?ns.indexOf(n):0,links=[null];
    Object.assign(n,{_value:11,_statusFlags:status,_flags:flags,_config:config,_loading:loading});c._flags=0;if(staging)n._pendingValue=17;
    S.link(x,n);links.push(n._depsTail);if(subscriber){S.link(n,c);links.push(c._depsTail);}
    Object.assign(S.ext(n),{_error:status&K.STATUS_ERROR?new S.StatusError(n,99):status&K.STATUS_PENDING?new S.NotReadyError(x):undefined,_pendingSources:new Set([x,n])});
    let tx;if(held){tx=S.newTransaction(false);tx._open=1;S.holdNode(n,tx);}
    const value=[23,undefined,null,false,new S.NotReadyError(x)][code];
    let yes,no;const object={then:(y,r)=>{yes=y;no=r;if(mode===1)y(value);if(mode===2)r(value);}};const superseding={};
    let result,returned=false,exception,threw=false;
    S.setContextInternal(n);try{result=S.handleAsync(n,object);returned=true;}catch(e){exception=e;threw=true;}S.setContextInternal(null);
    if(action){exception=undefined;threw=false;
      if(action===3)n._flags|=K.REACTIVE_DIRTY;
      if(action===4)n._x._inFlight=superseding;
      if(action===5)S.dispose(root);
      try{(action===2?no:yes)(value);}catch(e){exception=e;threw=true;}
    }
    const errors=new Map(),decode=v=>{if(v instanceof S.StatusError||v instanceof S.NotReadyError){if(!errors.has(v))errors.set(v,errors.size+1);return {kind:v instanceof S.StatusError?'error':'pending',identity:errors.get(v),source:id(v.source),...(v instanceof S.StatusError?{cause:decode(v.cause)}:{})};}return v;};
    const edge=e=>e?links.indexOf(e):0;
    return {returned,result:decode(result),nodes:ns.slice(1).map(n=>({value:decode(n._value),config:n._config,flags:n._flags??0,status:n._statusFlags??0,time:n._time??0,loading:n._loading??false,pending:!!n._fn&&n._pendingValue!==K.NOT_PENDING,pendingValue:n._pendingValue===K.NOT_PENDING?undefined:decode(n._pendingValue),deps:edge(n._deps),tail:edge(n._depsTail),subs:edge(n._subs),subsTail:edge(n._subsTail),first:id(n._firstChild),next:id(n._nextSibling),prev:id(n._prevSibling),gen:n._depGen??0,
      x:n._x?{flight:n._x._inFlight===object?1:n._x._inFlight===superseding?2:0,q:n._x._q,error:decode(n._x._error),shown:decode(n._x._shownError),blocked:n._x._blocked,sources:n._x._pendingSources?[...n._x._pendingSources].map(id):undefined,tx:n._x._transaction===tx&&tx?1:0}:null})),
      links:links.slice(1).map(l=>({$:undefined,dep:id(l._dep),sub:id(l._sub),nextDep:edge(l._nextDep),prevSub:edge(l._prevSub),nextSub:edge(l._nextSub),gen:l._gen})),pending:S.probePending.map(id),trims:S.probeTrims.map(id),live:S.probeTransactions.map(t=>t===tx?1:0),clock:S.clock,scheduled:S.probeScheduled,running:S.globalQueue._running,context:id(S.context),tracking:S.tracking,halted:S.probeHalted,threw,exception:decode(exception),queues:S.globalQueue._queues.map(q=>q.map(()=>4))};
  }
  let seed=0x9e3779b9,count=0;const rng=n=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return(seed>>>0)%n;};
  for(let index=0;index<4096;index++){
    const mode=index%3,action=mode?0:rng(6),args=[mode,action,[0,1,2,4,5][rng(5)],[0,K.REACTIVE_DIRTY,K.REACTIVE_ZOMBIE,K.REACTIVE_DISPOSED][rng(4)],[0,K.CONFIG_AUTO_DISPOSE,K.CONFIG_VERDICT,K.CONFIG_STAGED_ERROR][rng(4)],!!rng(2),!!rng(2),!!rng(2),!!rng(2),rng(5)];
    assert.deepEqual(actual(B.fixture(...args)),reference(...args),JSON.stringify(args));count++;
  }
  console.log(`${count} flight-state comparisons match TS registration, immediate verdicts, identity/dirty guards, loading parks, rejection/status order, autodisposal and held callback publication.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
