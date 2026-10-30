import {decodeQuestion} from './question-codec.mjs';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-construct-probe-'));
try {
  const emitted=path.join(dir,'construct.mjs');
  const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/construct.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);
  const {default:B}=await import(pathToFileURL(emitted));
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';
    export * as K from './core/constants.ts';
    export {signal,computed,createEffectNode,ext,setContextInternal,read,probeTracking} from './core/core.ts';
    export {createOwner} from './core/owner.ts';
    export {insertIntoHeap} from './core/heap.ts';
  `,resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'root-tracking-probe',setup(b){b.onLoad({filter:/[/\\]core[/\\]core\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport function probeTracking(v) { tracking=v; }'}));}
  }]});
  const S=await import('data:text/javascript;base64,'+Buffer.from(bundle.outputFiles[0].text).toString('base64'));
  const K=S.K;
  function list(xs) {const a=[];while('head' in xs){a.push(xs.head);xs=xs.tail;}return a;}
  const value=v=>v?.$==='Null'?null:v&&Object.hasOwn(v,'n')?v.n:undefined;
  const stamp=s=>Object.hasOwn(s,'value')?s.value:-1;
  function extension(x,bend) {
    if(!x)return null;
    if(bend)return {inFlight:x.inFlight.result??0,flightTeardown:x.flightTeardown,error:value(x.error),blocked:value(x.blocked.value),
      sources:x.pendingSources!==0,unobserved:x.unobserved,snapshot:Object.hasOwn(x.snapshotValue,'value'),
      pendingFirstChild:x.pendingFirstChild,pendingDisposal:Object.hasOwn(x.pendingDisposal,'callback'),transaction:x.transaction,
      reask:x.reask,flushed:Object.hasOwn(x.flushed,'value'),flushedAt:stamp(x.flushedAt),q:decodeQuestion(x.q),lane:Object.hasOwn(x.lane,'value'),marks:x.marks,shownError:value(x.shownError)};
    return {inFlight:x._inFlight??0,flightTeardown:x._flightTeardown??0,error:x._error,blocked:x._blocked,
      sources:x._pendingSources!==undefined,unobserved:x._unobserved?1:0,snapshot:x._snapshotValue!==undefined,
      pendingFirstChild:x._pendingFirstChild??0,pendingDisposal:x._pendingDisposal!==null,transaction:x._transaction??0,
      reask:x._reask,flushed:x._flushed!==K.NOT_PENDING,flushedAt:x._flushedAt,q:x._q,lane:x._lane!==K.NOT_PENDING,marks:x._marks,shownError:x._shownError};
  }
  function actual(w,kind) {
    const ns=list(w.nodes),n=ns[kind===6?5:4],xs=list(w.extensions),links=list(w.links);
    return {config:n.config,flags:n.flags,status:n.status,loading:n.loading,equals:n.equals,value:value(n.value),
      pending:Object.hasOwn(n.pending,'value'),time:n.time,notified:stamp(n.notified),prevHeap:n.prevHeap,
      height:n.height,deps:n.deps?links[n.deps].dep:0,subs:n.subs,parent:n.parent,parentComputed:n.parentComputed,scope:n.scope,childCount:n.childCount,
      firstChild:n.firstChild,nextSibling:n.nextSibling,prevSibling:n.prevSibling,modified:n.modified,prevValue:value(n.prevValue),
      context:w.context,tracking:w.tracking,extension:extension(n.x?xs[n.x]:null,true),
      children:ns.slice(1,4).map(p=>[p.firstChild,p.nextSibling,p.prevSibling])};
  }
  function reference(kind,bits,load,parentMode,unobserved) {
    S.setContextInternal(null);
    const root=S.createOwner(),shared={};root._context=shared;
    S.setContextInternal(root);
    const parent=S.computed(()=>17,{lazy:true});parent._height=7;
    S.setContextInternal(parent);const nested=S.createOwner();
    const nodes=[null,root,parent,nested];
    S.setContextInternal(nodes[parentMode]);
    const opts={equals:bits&32?false:undefined,transparent:!!(bits&1),ownedWrite:!!(bits&2),lazy:!!(bits&4),sync:!!(bits&8),
      _noSnapshot:!!(bits&16),_extraConfig:K.CONFIG_FRESH_READ,unobserved:unobserved?()=>{}:undefined};
    if(load)opts.loadingValue=load===1?5:undefined;
    let n;
    if(kind===0)n=S.signal(11,opts);
    else if(kind===1)n=S.computed(()=>17,opts);
    else if(kind===4)n=S.createOwner(opts);
    else if(kind===5){
      const [get]=S.createSignal(()=>17,opts);
      n=Object.getOwnPropertySymbols(get).map(key=>get[key]).find(value=>value&&typeof value==='object'&&'_pendingValue'in value);
      assert.ok(n,'native accessor target');
    }
    else if(kind===6){
      const [source]=S.createSignal(11);
      const sourceNode=Object.getOwnPropertySymbols(source).map(key=>source[key]).find(value=>value&&typeof value==='object'&&'_pendingValue'in value);
      nodes.push(sourceNode);
      const [get]=S.createSignal(source,opts);
      n=Object.getOwnPropertySymbols(get).map(key=>get[key]).find(value=>value&&typeof value==='object'&&'_pendingValue'in value);
      assert.ok(n,'actual first-class native getter initializer target');
    }
    else n=S.createEffectNode(()=>17,()=>{},undefined,kind-1,opts);
    nodes.push(n);
    const id=v=>v?nodes.indexOf(v):0;
    const result={config:n._config,flags:n._flags??0,status:n._statusFlags??0,loading:n._loading??false,equals:n._equals!==false,value:n._value,
      pending:n._pendingValue!==undefined&&n._pendingValue!==K.NOT_PENDING,time:n._time??0,notified:n._notifiedAt??-1,prevHeap:id(n._prevHeap),
      height:n._height??0,deps:n._deps?id(n._deps._dep):0,subs:id(n._subs),parent:id(n._parent),parentComputed:id(n._parentComputed),scope:n._context===shared?41:0,childCount:n._childCount??0,
      firstChild:id(n._firstChild),nextSibling:id(n._nextSibling),prevSibling:id(n._prevSibling),modified:n._modified??false,prevValue:n._prevValue,
      context:parentMode,tracking:false,extension:extension(n._x,false),
      children:nodes.slice(1,4).map(p=>[id(p._firstChild),id(p._nextSibling),id(p._prevSibling)])};
    S.setContextInternal(null);
    return result;
  }
  let checked=0;
  for(const kind of [0,1,2,3,4,5,6])for(let bits=0;bits<64;bits++)for(const load of [0,1,2])for(const parent of [0,1,2,3])for(const unobserved of [false,true]) {
    assert.deepEqual(actual(B.fixture(kind,bits,load,parent,unobserved),kind),reference(kind,bits,load,parent,unobserved),JSON.stringify({kind,bits,load,parent,unobserved}));checked++;
  }
  const p=B.allocation(),n=w=>list(w.nodes)[1];
  assert.equal(n(p.before).x,0);assert.equal(list(p.before.extensions).length,1);
  assert.equal(n(p.first).x,n(p.second).x);assert.equal(list(p.first.extensions).length,2);assert.equal(list(p.second.extensions).length,2);
  assert.equal(decodeQuestion(list(p.second.extensions)[n(p.second).x].q),19,'ext must reuse the existing object and retain writes');
  const s=S.signal(11),first=S.ext(s);first._q=19;assert.equal(S.ext(s),first);assert.equal(S.ext(s)._q,19);
  S.setContextInternal(null);const r=S.createOwner();S.setContextInternal(r);
  const parent=S.computed(()=>17,{lazy:true});parent._height=7;S.setContextInternal(parent);
  const nested=S.createOwner();S.setContextInternal(nested);
  const child=S.computed(()=>17,{lazy:true});child._height=0;
  const heap={_heap:[],_marked:false,_min:0,_max:0};S.insertIntoHeap(child,heap);
  const h=B.heapUnderRoot(),hn=list(h.nodes)[4];
  assert.equal(hn.height,child._height);assert.equal(hn.flags,child._flags);assert.equal(h.maximum,heap._max);
  assert.equal(list(h.buckets)[hn.height],4);assert.equal(heap._heap[child._height],child);
  const sourceSignal=S.signal(11);S.probeTracking(true);const result=S.read(sourceSignal);S.probeTracking(false);
  const m=B.readUnderRoot(),ns=list(m.world.nodes),links=list(m.world.links);
  assert.equal(value(list(m.values)[0]),result);assert.equal(ns[3].deps,0);assert.notEqual(ns[2].deps,0);
  assert.equal(links[ns[2].deps].sub,2);assert.equal(links[ns[2].deps].dep,4);
  assert.equal(parent._deps._dep,sourceSignal);assert.equal(sourceSignal._subs._sub,parent);S.setContextInternal(null);
  console.log(`${checked} constructor comparisons match pinned TS signal/writable-memo/memo/effect/owner defaults and option masks, loading presence, parent/root height setup, links and lazy extension defaults; ext identity is retained.`);
} finally {fs.rmSync(dir,{recursive:true,force:true});}
