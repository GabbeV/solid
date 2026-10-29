import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-lane-identities-'));
try{
 const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(dir,name),{recursive:true});
 fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});const probe=path.join(dir,'tests/probes/lanes-state.bend');fs.copyFileSync(path.join(root,'tests/probes/lanes-state.bend'),probe);
 const emitted=path.join(dir,'lanes.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',probe,'-o',emitted],{cwd:root,encoding:'utf8'});assert.equal(compile.status,0,compile.stderr);
 const {default:B}=await import(pathToFileURL(emitted));
 const source=path.join(root,'upstream/solid/packages/signals/src');
 const bundle=await build({stdin:{contents:`export * from './index.ts';export * as K from './core/constants.ts';export {signal,computed,ext,setContextInternal,stagedRead} from './core/core.ts';export {link} from './core/graph.ts';export {probeNewLane,probeLink,probeUnlink,probeUnder,probeLanes,probeResetLanes,verdictLane,enterLane,display,laneValueOf} from './core/lanes.ts';export {newTransaction,passLane,setPassLane,laneDirty,sameLane,stagedReaders,probeResetQueue,dirtyQueue,transactions} from './core/scheduler.ts';`,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'lane-observation',setup(b){
  b.onLoad({filter:/[/\\]core[/\\]lanes\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {newLane as probeNewLane,linkLanes as probeLink,unlink as probeUnlink,under as probeUnder,lanes as probeLanes};export function probeResetLanes(){guessed=false;kept.length=0;reverting=false;lanes.length=pendingGuesses.length=judged=0;}'}));
  b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {transactions};export function probeResetQueue(){guessing=false;clock=notifyEpoch=0;scheduled=false;syncDepth=1;transactions.length=stagedReaders.length=0;passLane=passTx=flushTransaction=null;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=dirtyQueue._max=0;dirtyQueue._marked=false;}'}));
 }}]});
 const file=path.join(dir,'solid.mjs');fs.writeFileSync(file,bundle.outputFiles[0].text);const S=await import(pathToFileURL(file)),K=S.K;
 const list=xs=>{const a=[];while('head'in xs){a.push(xs.head);xs=xs.tail;}return a;},adt=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$: 'Nil'});
 const encode=([op,left=0,right=0])=>({$: 'Command',op,left,right,bits:right});
 function actual(commands){const pair=B.fixture(adt(commands.map(encode))),w=pair.left,extensions=list(w.extensions);assert.equal(w.fault.$,'Healthy',JSON.stringify(commands));return{answers:list(pair.right),pass:w.passLane,live:list(w.laneState.live),staged:list(w.laneState.stagedReaders),groups:list(w.laneState.groups).slice(1).map(list),transactions:list(w.transactions),tx:list(w.txArena).slice(1).map(t=>({lane:t.lane,parent:t.parent,verdict:t.verdict,links:t.links,into:t.into,shown:t.shown,held:t.held,nodes:list(t.nodes),reruns:list(t.reruns)})),nodes:list(w.nodes).slice(1).map(n=>({flags:n.flags,status:n.status,x:!!n.x,tx:extensions[n.x]?.transaction??0})),scheduled:w.scheduled,pending:list(w.pendingNodes)};}
 function reference(commands){S.probeResetQueue();S.probeResetLanes();S.setContextInternal(null);const nodes=[null,S.signal(1),...Array.from({length:3},(_,i)=>S.computed(()=>i+2,{lazy:true}))];nodes[3]._type=1;for(const i of [2,3,4])S.link(nodes[1],nodes[i]);const tx=[null],groups=[null],answers=[],nid=n=>n?nodes.indexOf(n):0,tid=t=>t?tx.indexOf(t):0;
  for(const [op,left=0,right=0]of commands){let answer=0;if(op===0){const t=S.probeNewLane(tx[left]);tx.push(t);answer=tid(t);}if(op===1){const t=S.verdictLane(tx[left]);if(!tx.includes(t))tx.push(t);answer=tid(t);}if(op===2)S.probeLink(tx[left],tx[right]);if(op===3)S.probeUnlink(tx[left]);if(op===4)answer=Number(S.sameLane(tx[left],tx[right]));if(op===5)answer=Number(S.probeUnder(tx[left],tx[right]));if(op===6)S.enterLane(tx[left],nodes[right]);if(op===7)S.setPassLane(tx[left]);if(op===8)nodes[left]._flags=right;if(op===9)S.ext(nodes[left])._transaction=tx[right];if(op===10)S.laneDirty(nodes[left],tx[right]);if(op===11){const t=S.newTransaction(false);tx.push(t);answer=tid(t);}if(op===12)S.stagedRead(nodes[left],nodes[right]??undefined);if(op===13)nodes[left]._statusFlags=right;answers.push(answer);
   for(const t of tx.slice(1))if(t._links!==null&&!groups.includes(t._links))groups.push(t._links);
  }
  return{answers,pass:tid(S.passLane),live:S.probeLanes.map(tid),staged:S.stagedReaders.map(nid),groups:groups.slice(1).map(g=>g.map(tid)),transactions:S.transactions.map(tid),tx:tx.slice(1).map(t=>({lane:t._lane,parent:tid(t._parent),verdict:tid(t._verdict),links:t._links===null?0:groups.indexOf(t._links),into:tid(t._into),shown:t._shown,held:t._held,nodes:t._nodes.map(nid),reruns:t._reruns.map(nid)})),nodes:nodes.slice(1).map(n=>({flags:n._flags??0,status:n._statusFlags??0,x:n._x!==null,tx:tid(n._x?._transaction)})),scheduled:false,pending:[]};
 }
 const base=[[11],[11],[0,1],[0,1],[0,2],[0,3],[0,6],[0,4],[0,2]];
 let count=0;const check=commands=>{assert.deepEqual(actual(commands),reference(commands),JSON.stringify(commands));count++;};
 check([]);for(let i=1;i<=base.length;i++)check(base.slice(0,i));
 for(const a of [1,2,3,4,5,6,7,8,9])for(const b of [1,2,3,4,5,6,7,8,9])check([...base,[4,a,b],[5,a,b]]);
 for(const a of [3,4,5,6,7])for(const b of [3,4,5,8,9])for(const c of [3,5,7,8]){
  const plan=[...base,[2,a,b],[2,c,9],[2,a,c],[4,b,c],[3,b],[4,a,c],[3,a],[2,b,a],[4,b,a]];
  for(const length of [10,11,12,13,14,15,16,17,18,19])check(plan.slice(0,length));
 }
 for(const p of [0,3,4,5,6,7,8,9])for(const l of [3,4,5,6,7,8,9])for(const flags of [0,K.REACTIVE_JOINED,K.REACTIVE_STAGED_READ,K.REACTIVE_JOINED|K.REACTIVE_STAGED_READ])check([...base,[8,2,flags],[7,p],[6,l,2]]);
 for(const parent of [1,2,3,6])check([...base,[1,parent],[1,parent],[1,parent]]);
 for(const initial of [0,3,5])for(const target of [0,3,5,6])for(const other of [0,4,7])check([...base,[2,3,4],[9,2,target],[9,3,initial],[9,4,other],[10,1,3]]);
 for(const p of [0,3,6])for(const status of [0,K.STATUS_PENDING,K.STATUS_UNINITIALIZED,K.STATUS_ERROR])check([...base,[7,p],[13,1,status],[12,2,1],[12,2,0],[12,2,1]]);
 const slots=[undefined,0,false,null,11,NaN];
 const value=v=>v===undefined?{$:'Undefined'}:v===null?{$:'Null'}:typeof v==='boolean'?{$:'Boolean',b:v}:Number.isNaN(v)?{$:'NotANumber'}:{$:'Number',n:v};
 const decode=v=>v.$==='Undefined'?undefined:v.$==='Null'?null:v.$==='Boolean'?v.b:v.$==='NotANumber'?NaN:v.n;
 let valueCount=0;
 for(const config of [0,K.CONFIG_GUESS,K.CONFIG_OVERRIDE,K.CONFIG_OVERRIDE|K.CONFIG_GUESS])for(const shown of [false,true])for(const pendingIndex of [-1,0,1,2,3,4,5])for(const laneIndex of [-1,0,1,2,3,4,5]){
  const pending=pendingIndex===-1?{$:'Empty'}:{$:'Present',value:value(slots[pendingIndex])},lane=laneIndex===-1?{$:'Empty'}:{$:'Present',value:value(slots[laneIndex])};
  const actual=B.values(config,pending,lane,shown);
  S.probeResetQueue();S.probeResetLanes();S.setContextInternal(null);const n=S.signal(7),t=S.newTransaction(true,null);t._shown=shown;n._config=config;n._pendingValue=pendingIndex===-1?K.NOT_PENDING:slots[pendingIndex];Object.assign(S.ext(n),{_transaction:t,_lane:laneIndex===-1?K.NOT_PENDING:slots[laneIndex]});
  assert.deepEqual([decode(actual.left),decode(actual.right)],[S.display(n),S.laneValueOf(n)],JSON.stringify({config,shown,pendingIndex,laneIndex}));valueCount++;
 }
 console.log(`${valueCount} native display/lane-value controls retain guess, staged, shown, absent and falsy-value distinctions.`);
 console.log(`${count} lane-identity/routing helper comparisons match pinned TS allocation, cached verdicts, shared group mutation/retired aliases, ancestry, pass routing, staged-reader intake and lane-dirty flags.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
