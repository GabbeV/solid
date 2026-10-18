import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-read-probe-'));
try {
  const emitted=path.join(dir,'read.mjs');
  const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/read.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);
  const {default:B}=await import(pathToFileURL(emitted));
  const source=path.join(root,'upstream/solid/packages/signals/src');
  const bundle=await build({stdin:{contents:`
    export * from './index.ts';
    export * as K from './core/constants.ts';
    export {read,serve,notePromotedWrite,resyncUnflushedCompanions,unflushedStaged,probeConfigure,probePromotedCount} from './core/core.ts';
    export {globalQueue,dirtyQueue,queuePendingNode} from './core/scheduler.ts';
  `,resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{
    name:'private-read-state-probe',setup(b) {b.onLoad({filter:/[/\\]core[/\\]core\.ts$/},args=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+`
      export function probeConfigure(c,t,u) { context=c; tracking=t; unflushedStaged=u; promotedWrites.length=0; }
      export function probePromotedCount() { return promotedWrites.length; }
    `}));}
  }]});
  const S=await import('data:text/javascript;base64,'+Buffer.from(bundle.outputFiles[0].text).toString('base64'));
  const K=S.K;
  function list(xs) {const a=[];while('head' in xs){a.push(xs.head);xs=xs.tail;}return a;}
  const numeric=v=>Object.hasOwn(v,'n')?v.n:undefined;
  function node(memo=false) {return {_fn:memo?()=>11:undefined,_config:0,_statusFlags:0,_flags:0,_value:11,_pendingValue:K.NOT_PENDING,
    _x:null,_height:0,_parent:null,_deps:null,_depsTail:null,_depGen:0,_subs:null,_subsTail:null};}
  function reference(memo,reader,tracking,running,marked,stage,forbidden,promoted,slow) {
    const n=node(memo),c=reader?node(true):null;
    if(c)c._config=forbidden?K.CONFIG_CHILDREN_FORBIDDEN:0;
    n._pendingValue=stage===0?K.NOT_PENDING:stage===1?23:undefined;
    S.globalQueue._running=running;S.dirtyQueue._min=1;
    S.probeConfigure(c,tracking,marked);
    if(promoted)n._config|=K.CONFIG_PROMOTED;
    const value=slow?S.serve(n,c):S.read(n);
    return {value,flags:c?c._flags:0,linked:c?c._deps!==null:false,height:c?c._height:0,marked:S.unflushedStaged};
  }
  function actual(m) {
    const ns=list(m.world.nodes),c=ns[4];
    return {value:numeric(list(m.values)[0]),flags:c.flags,linked:c.deps!==0,height:c.height,marked:m.world.unflushedStaged};
  }
  let checked=0;
  for(const memo of [false,true])for(const reader of [false,true])for(const tracking of [false,true])
    for(const running of [false,true])for(const marked of [false,true])for(const stage of [0,1,2])
      for(const forbidden of [false,true])for(const promoted of [false,true])for(const slow of [false,true]) {
        const args=[memo,reader,tracking,running,marked,stage,forbidden,promoted,slow];
        assert.deepEqual(actual(B.fixture(...args)),reference(...args),JSON.stringify({memo,reader,tracking,running,marked,stage,forbidden,promoted,slow}));
        checked++;
      }
  // Module state transitions: outside writes set A28, inside writes do not;
  // promoted writes are recorded once and the flush clears both states.
  for(const running of [false,true]) {
    const n=node();S.probeConfigure(null,false,false);S.globalQueue._running=running;
    S.queuePendingNode(n);S.notePromotedWrite(n);S.notePromotedWrite(n);
    const p=B.promotion(running),before=list(p.before.nodes)[2],after=list(p.after.nodes)[2];
    assert.equal(p.before.unflushedStaged,S.unflushedStaged);
    assert.equal(list(p.before.promotedWrites).length,S.probePromotedCount());
    assert.equal(before.config&K.CONFIG_PROMOTED,n._config&K.CONFIG_PROMOTED);
    S.resyncUnflushedCompanions();
    assert.equal(p.after.unflushedStaged,S.unflushedStaged);
    assert.equal(list(p.after.promotedWrites).length,S.probePromotedCount());
    assert.equal(after.config&K.CONFIG_PROMOTED,n._config&K.CONFIG_PROMOTED);
  }
  console.log(`${checked} read-state comparisons match pinned TS signal fast reads and slow serve, including late-linker/staged flags, untrack, frame readers, undefined and promoted writes; promotion/reset helpers match too.`);
} finally {fs.rmSync(dir,{recursive:true,force:true});}
