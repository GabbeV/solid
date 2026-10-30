import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-lane-blockers-'));
try{
 const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(dir,name),{recursive:true});
 fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});const probe=path.join(dir,'tests/probes/blockers.bend');fs.copyFileSync(path.join(root,'tests/probes/blockers.bend'),probe);
 const emitted=path.join(dir,'lanes.mjs'),compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',probe,'-o',emitted],{cwd:root,encoding:'utf8'});assert.equal(compile.status,0,compile.stderr);
 const {default:B}=await import(pathToFileURL(emitted));
 const source=path.join(root,'upstream/solid/packages/signals/src');
 const bundle=await build({stdin:{contents:`export * from './index.ts';export * as K from './core/constants.ts';export {signal,computed,ext,setContextInternal,stagedRead} from './core/core.ts';export {link} from './core/graph.ts';export {probeNewLane,probeLink,probeUnlink,probeUnder,probeLanes,lanesBlocked,linkBlocked,nestedBlocked,guessFlights,probeResetLanes,verdictLane,enterLane,display,laneValueOf} from './core/lanes.ts';export {newTransaction,passLane,setPassLane,laneDirty,sameLane,stagedReaders,probeResetQueue,dirtyQueue,transactions,blocked,ownFlights,judge,probeSetJudge,list,merge} from './core/scheduler.ts';`,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'lane-observation',setup(b){
  b.onLoad({filter:/[/\\]core[/\\]lanes\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {newLane as probeNewLane,linkLanes as probeLink,unlink as probeUnlink,under as probeUnder,lanes as probeLanes,lanesBlocked,linkBlocked,nestedBlocked,guessFlights};export function probeResetLanes(){revealing.length=0;guessed=false;kept.length=0;reverting=false;lanes.length=pendingGuesses.length=judged=0;}'}));
  b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {transactions,judge};export function probeSetJudge(t){judge=t;}export function probeResetQueue(){latestOpened=null;guessing=false;clock=notifyEpoch=0;scheduled=false;syncDepth=1;transactions.length=stagedReaders.length=0;passLane=passTx=flushTransaction=judge=null;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=dirtyQueue._max=0;dirtyQueue._marked=false;}'}));
 }}]});
 const file=path.join(dir,'solid.mjs');fs.writeFileSync(file,bundle.outputFiles[0].text);const S=await import(pathToFileURL(file)),K=S.K;
 const list=xs=>{const a=[];while('head'in xs){a.push(xs.head);xs=xs.tail;}return a;},adt=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$: 'Nil'});
 const encode=([op,left=0,right=0])=>({$: 'Command',op,left,right,bits:right});
 function actual(commands,queries){const pair=B.blockFixture(adt(commands.map(encode)),adt(queries.map(([kind,target])=>({$: 'Query',kind,target})))),w=pair.left,extensions=list(w.extensions);assert.equal(w.fault.$,'Healthy',JSON.stringify(commands));return{answers:list(pair.right).map(a=>[a.value,a.judge]),judge:w.judge,pass:w.passLane,live:list(w.laneState.live),staged:list(w.laneState.stagedReaders),groups:list(w.laneState.groups).slice(1).map(list),transactions:list(w.transactions),tx:list(w.txArena).slice(1).map(t=>({lane:t.lane,parent:t.parent,verdict:t.verdict,links:t.links,into:t.into,shown:t.shown,held:t.held,nodes:list(t.nodes),reruns:list(t.reruns)})),nodes:list(w.nodes).slice(1).map(n=>({flags:n.flags,status:n.status,x:!!n.x,tx:extensions[n.x]?.transaction??0})),scheduled:w.scheduled,pending:list(w.pendingNodes)};}
 function reference(commands,queries){S.probeResetQueue();S.probeResetLanes();S.setContextInternal(null);const nodes=[null,S.signal(1),...Array.from({length:3},(_,i)=>S.computed(()=>i+2,{lazy:true}))];nodes[3]._type=1;for(const i of [2,3,4])S.link(nodes[1],nodes[i]);for(const i of [3,4])S.link(nodes[2],nodes[i]);const tx=[null],groups=[null],answers=[],nid=n=>n?nodes.indexOf(n):0,tid=t=>t?tx.indexOf(t):0;
  for(const [op,left=0,right=0]of commands){let answer=0;if(op===0){const t=S.probeNewLane(tx[left]);tx.push(t);answer=tid(t);}if(op===1){const t=S.verdictLane(tx[left]);if(!tx.includes(t))tx.push(t);answer=tid(t);}if(op===2)S.probeLink(tx[left],tx[right]);if(op===3)S.probeUnlink(tx[left]);if(op===4)answer=Number(S.sameLane(tx[left],tx[right]));if(op===5)answer=Number(S.probeUnder(tx[left],tx[right]));if(op===6)S.enterLane(tx[left],nodes[right]);if(op===7)S.setPassLane(tx[left]);if(op===8)nodes[left]._flags=right;if(op===9)S.ext(nodes[left])._transaction=tx[right];if(op===10)S.laneDirty(nodes[left],tx[right]);if(op===11){const t=S.newTransaction(false);tx.push(t);answer=tid(t);}if(op===12)S.stagedRead(nodes[left],nodes[right]??undefined);if(op===13)nodes[left]._statusFlags=right;if(op===14)tx[left]._open=right;if(op===15)nodes[left]._config=right;if(op===16)tx[left]._into=tx[right];if(op===17)S.probeSetJudge(tx[left]);if(op===18)S.list(nodes[left],tx[right]);if(op===19)S.ext(nodes[left])._pendingSources=right===0?undefined:new Set((right===1?[]:right===2?[1]:[2]).map(i=>nodes[i]));if(op===20)S.merge(tx[left],tx[right]);if(op===21)S.ext(nodes[left])._lane=right;answers.push(answer);
   for(const t of tx.slice(1))if(t._links!==null&&!groups.includes(t._links))groups.push(t._links);
  }
  const methods=[S.blocked,S.ownFlights,S.lanesBlocked,S.linkBlocked,S.nestedBlocked,S.guessFlights];const judgments=queries.map(([kind,target])=>[methods[kind](tx[target]),tid(S.judge)]);
  return{answers:judgments,judge:tid(S.judge),pass:tid(S.passLane),live:S.probeLanes.map(tid),staged:S.stagedReaders.map(nid),groups:groups.slice(1).map(g=>g.map(tid)),transactions:S.transactions.map(tid),tx:tx.slice(1).map(t=>({lane:t._lane,parent:tid(t._parent),verdict:tid(t._verdict),links:t._links===null?0:groups.indexOf(t._links),into:tid(t._into),shown:t._shown,held:t._held,nodes:t._nodes.map(nid),reruns:t._reruns.map(nid)})),nodes:nodes.slice(1).map(n=>({flags:n._flags??0,status:n._statusFlags??0,x:n._x!==null,tx:tid(n._x?._transaction)})),scheduled:false,pending:[]};
 }
 const base=[[11],[11],[0,1],[0,1],[0,2],[0,3],[0,6],[0,4],[0,2]];
 const groups=[[],[[2,3,4]],[[2,3,5]],[[2,3,4],[2,6,8]],[[2,5,9],[2,3,5]]];
 const targets=[1,2,3,4,5,6,7,8,9],queriesFor=ts=>ts.flatMap(target=>[0,1,2,3,4,5].map(kind=>[kind,target]));
 let programs=0,queries=0;const check=(commands,items)=>{assert.deepEqual(actual(commands,items),reference(commands,items),JSON.stringify({commands,items}));programs++;queries+=items.length;};
 for(const group of groups)for(const open of [0,1,2,3,4,6,8,9])for(const judge of [0,1,2])check([...base,...group,...(open?[[14,open,1]]:[]),[17,judge]],queriesFor(targets));
 for(const group of groups)for(const member of [3,4,5,6,7,8])for(const guess of [false,true])for(const observer of [0,1,2,3])for(const sources of [0,1,2,3]){
  const config=K.CONFIG_OVERRIDE|(guess?K.CONFIG_GUESS:0),commands=[...base,...group,[18,2,member],[15,2,config],[21,2,99],[13,2,K.STATUS_PENDING],[13,3,observer&1?K.STATUS_PENDING:0],[8,4,observer&2?K.REACTIVE_FRAME_READ:0],[19,2,sources],[9,1,2]];
  check(commands,queriesFor([1,member,member===4?3:4]));
 }
 // A guess's own refetch holds its parent while its lane/group can show it.
 for(const group of groups)for(const member of [3,4,5,6,7,8])check([...base,...group,[18,2,member],[15,2,K.CONFIG_OVERRIDE|K.CONFIG_GUESS],[21,2,99],[13,2,K.STATUS_PENDING],[13,3,K.STATUS_PENDING]],queriesFor(targets));
 // Real transaction merging redirects a lane's parent; node membership and
 // parent resolution remain the source merge/txOf operations.
 for(const group of groups)for(const member of [1,3,6])for(const pending of [false,true])check([...base,...group,[18,2,member],[15,2,member===1?K.CONFIG_HELD:K.CONFIG_OVERRIDE],[13,2,pending?K.STATUS_PENDING:0],[13,3,K.STATUS_PENDING],[20,1,2]],queriesFor(targets));
 for(const old of [3,4,6,8])for(const current of [3,4,5,6])for(const guess of [false,true])check([...base,[2,3,4],[18,2,old],[18,2,current],[15,2,K.CONFIG_OVERRIDE|(guess?K.CONFIG_GUESS:0)],[21,2,99],[13,2,K.STATUS_PENDING],[13,3,K.STATUS_PENDING]],queriesFor(targets));
 for(const member of [3,4,5,6,7,8])for(const status of [0,K.STATUS_ERROR,K.STATUS_UNINITIALIZED])check([...base,[18,2,member],[15,2,K.CONFIG_OVERRIDE|K.CONFIG_GUESS],[21,2,99],[13,2,status],[13,3,K.STATUS_PENDING]],queriesFor(targets));
 console.log(`${programs} lane-blocking helper programs / ${queries} native judgments match nested/group holds, own-versus-guess flights, source ownership, redirects and judge restoration after every call.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
