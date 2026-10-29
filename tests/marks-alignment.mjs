import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {build} from 'esbuild';

const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-marks-probe-'));
try {
  // Mutation runs compile their copied runtime, just as ordinary helper probes do.
  const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
  for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(dir,name),{recursive:true});
  fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});
  const probe=path.join(dir,'tests/probes/affects-marks.bend');
  fs.copyFileSync(path.join(root,'tests/probes/affects-marks.bend'),probe);
  const emitted=path.join(dir,'marks.mjs');
  const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',probe,'-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);
  const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts'; export * as K from './core/constants.ts';
    export {signal,computed,setContextInternal,ext} from './core/core.ts';
    export {link} from './core/graph.ts';
    export {mark,unmark,repoll,probeMarked,probeActive,probeResetMarks} from './affects-marks.ts';
    export {dirtyQueue,globalQueue,GlobalQueue,probeResetQueue} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'private-mark-observation',setup(b){
      b.onLoad({filter:/[/\\]affects-marks\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
        export {marked as probeMarked};
        export function probeActive(){return active;}
        export function probeResetMarks(){active=0;}
      `}));
      b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
        export function probeResetQueue(){guessing=false;clock=0;notifyEpoch=0;scheduled=false;syncDepth=1;pendingNodes.length=heldTrims.length=0;globalQueue._running=false;globalQueue._queues=[[],[]];dirtyQueue._heap=[];dirtyQueue._min=9;dirtyQueue._max=0;dirtyQueue._marked=false;}
      `}));
    }
  }]});
  const referenceFile=path.join(dir,'solid.mjs');fs.writeFileSync(referenceFile,bundle.outputFiles[0].text);
  const S=await import(pathToFileURL(referenceFile)),K=S.K;
  const list=xs=>{const result=[];while('head'in xs){result.push(xs.head);xs=xs.tail;}return result;};
  const adt=xs=>xs.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$: 'Nil'});
  const link=([dep,sub])=>({$: 'Link',dep,sub,nextDep:0,prevSub:0,nextSub:0,gen:0});
  const shapes=[
    [[1,2],[2,3],[3,4],[4,5],[5,6]],
    [[1,2],[1,3],[2,4],[3,4],[4,5],[5,6]],
    [[1,3],[2,3],[3,4],[2,5],[5,6]],
    [[1,2],[2,3],[3,2],[3,4],[4,5]],
    [[1,2],[1,3],[2,5],[3,5],[5,6]],
    []
  ];
  function actual(c){
    const pair=B.fixture(c.op,adt(c.edges.map(link)),adt(c.configs),adt(c.flags),adt(c.statuses),c.target,c.markedAt,c.marks,c.active,adt(c.seen),c.readers,c.tailMode,c.heapMarked),w=pair.left;
    const extensions=list(w.extensions),nodes=list(w.nodes);
    assert.equal(w.fault.$,'Healthy',JSON.stringify(c));
    return {answer:pair.right,active:w.activeMarks,nodes:nodes.slice(1).map(n=>({flags:n.flags,height:n.height,next:n.nextHeap,prev:n.prevHeap,x:n.x!==0,marks:extensions[n.x]?.marks??0})),heap:list(w.buckets).slice(0,w.maximum+1),min:w.minimum,max:w.maximum,marked:w.marked,pending:list(w.pendingNodes),scheduled:w.scheduled};
  }
  function reference(c){
    S.probeResetQueue();S.probeResetMarks();S.setContextInternal(null);
    const nodes=[null,S.signal(1),...Array.from({length:5},(_,i)=>S.computed(()=>i+2,{lazy:true}))];
    nodes[4]._type=1;
    for(let i=1;i<nodes.length;i++)Object.assign(nodes[i],{_config:c.configs[i-1],_flags:c.flags[i-1],_statusFlags:c.statuses[i-1]});
    for(const [dep,sub]of c.edges)S.link(nodes[dep],nodes[sub]);
    const target=nodes[c.target];
    if(c.tailMode===1)target._depsTail=target._deps;
    if(c.tailMode===2)target._depsTail=null;
    if(c.markedAt){S.ext(nodes[c.markedAt]);for(let i=0;i<c.marks;i++)S.mark(nodes[c.markedAt]);}
    // Gate controls deliberately vary the active global independently of node
    // metadata; all unmark cases below use balanced, reachable counts.
    if(c.active===0)S.probeResetMarks();
    S.dirtyQueue._marked=c.heapMarked;
    let answer=false;
    if(c.op===0)answer=S.probeMarked(target,new Set(c.seen.map(i=>nodes[i])));
    if(c.op===1)answer=S.GlobalQueue._marked(target);
    if(c.op===2)S.repoll(target,new Set(c.seen.map(i=>nodes[i])),c.readers);
    if(c.op===3)S.mark(target);
    if(c.op===4)answer=S.unmark(target);
    const id=n=>n?nodes.indexOf(n):0;
    return {answer,active:S.probeActive(),nodes:nodes.slice(1).map(n=>({flags:n._flags??0,height:n._height??0,next:id(n._nextHeap),prev:id(n._prevHeap),x:n._x!==null,marks:n._x?._marks??0})),heap:Array.from({length:S.dirtyQueue._max+1},(_,i)=>id(S.dirtyQueue._heap[i])),min:S.dirtyQueue._min,max:S.dirtyQueue._max,marked:S.dirtyQueue._marked,pending:[],scheduled:false};
  }
  const base={op:0,edges:shapes[0],configs:[0,K.CONFIG_VERDICT,K.CONFIG_AUTHORITATIVE,K.CONFIG_VERDICT,K.CONFIG_AUTHORITATIVE,K.CONFIG_VERDICT],flags:[0,0,0,0,0,0],statuses:[0,0,0,0,0,0],target:4,markedAt:1,marks:1,active:1,seen:[],readers:K.CONFIG_VERDICT|K.CONFIG_AUTHORITATIVE,tailMode:0,heapMarked:false};
  let count=0;
  const check=changes=>{const c={...base,...changes};assert.deepEqual(actual(c),reference(c),JSON.stringify(c));count++;};
  for(const edges of shapes)for(const markedAt of [0,1,2,3,4,5])for(const error of [0,2,3,4])for(const target of [2,3,4,6]){
    const statuses=base.statuses.map((_,i)=>i+1===error?K.STATUS_ERROR:0);
    check({edges,markedAt,active:markedAt?1:0,statuses,target});
  }
  for(const edges of shapes)for(const target of [2,3,4,5,6])for(const markedAt of [1,2,3,5])for(const tailMode of [0,1,2])for(const seen of [[],[1],[2],[3]]){
    check({edges,target,markedAt,tailMode,seen,flags:base.flags.map((_,i)=>i+1===target?K.REACTIVE_RECOMPUTING_DEPS:0)});
  }
  for(const edges of shapes)for(const active of [0,1])for(const markedAt of [1,2,3,4])check({op:1,edges,active,markedAt});
  for(const edges of shapes)for(const readers of [0,K.CONFIG_VERDICT,K.CONFIG_AUTHORITATIVE,base.readers])for(const seen of [[],[2],[3],[4],[5]])for(const mode of [0,K.REACTIVE_RECOMPUTING_DEPS,K.REACTIVE_CHECK,K.REACTIVE_IN_HEAP_HEIGHT]){
    check({op:2,edges,readers,seen,flags:base.flags.map((_,i)=>i===1?mode:0)});
  }
  for(const edges of shapes.filter((_,i)=>i!==3))for(const heapMarked of [false,true])for(const marks of [1,2,3])for(const target of [1,2,3]){
    check({op:4,edges,heapMarked,marks,active:marks,target,markedAt:target});
  }
  for(const target of [1,2,3,4,5,6])for(const markedAt of [0,1,2,4])for(const marks of [1,3])check({op:3,target,markedAt,marks,active:markedAt?marks:0});
  console.log(`${count} affects-marks helper comparisons match pinned TS counts, exact heap state/order, current dependency prefixes, errors, cycles, shared seen sets and effect cutoffs.`);
} finally {fs.rmSync(dir,{recursive:true,force:true});}
