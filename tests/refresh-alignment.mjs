// Expose the actual pinned helper beside the full index in one module. This
// compares internal scheduling decisions, not a hand-written TS reference.
import assert from 'node:assert/strict';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {build} from 'esbuild';
import {BendRuntime} from '../host/bend.mjs';
const root=fileURLToPath(new URL('../',import.meta.url));
const bundle=await build({stdin:{contents:'export * from "./index.ts"; export {markRefresh as markRefreshProbe} from "./core/core.ts";',resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},treeShaking:true});
const S=await import('data:text/javascript;base64,'+Buffer.from(bundle.outputFiles[0].text).toString('base64'));
let x,a,b,dispose;
S.createRoot(d=>{dispose=d;x=S.createSignal(1)[0];a=S.createMemo(prev=>(prev??0)+x());b=S.createMemo(()=>a()+1);});
const bend=new BendRuntime();
bend.signal('x',1);
bend.memo('a',{add:[{select:[{prev:true},{prev:true},{lit:0}]},{read:'x'}]});
bend.memo('b',{add:[{read:'a'},{lit:1}]});
const tsNode=get=>get[S.$REFRESH];
function flags() {return [tsNode(a)._flags,tsNode(b)._flags];}
function actualFlags() {const ns=bend.nodes();return [ns[bend.ids.a].flags,ns[bend.ids.b].flags];}
try {
  assert.deepEqual(actualFlags(),flags());
  S.markRefreshProbe(tsNode(a));bend.markRefresh('a');
  assert.deepEqual(actualFlags(),flags(),'refresh must preserve target REASK and leave downstream marking to source scheduling');
  S.markRefreshProbe(tsNode(a));bend.markRefresh('a');
  assert.deepEqual(actualFlags(),flags(),'repeated invalidation must use source flag classification');
  S.flush();bend.flush();
  assert.equal(bend.read('a'),a());assert.equal(bend.read('b'),b());
  assert.deepEqual(actualFlags(),flags(),'pass must consume REASK like the sync source');
  S.markRefreshProbe(tsNode(x));bend.markRefresh('x');
  assert.deepEqual(actualFlags(),flags(),'plain signals are not refreshable computations');
  dispose();bend.dispose();
  S.markRefreshProbe(tsNode(a));bend.markRefresh('a');
  assert.deepEqual(actualFlags(),flags(),'dead nodes must refuse invalidation');
} finally {dispose();S.flush();}
console.log('Refresh helper matches pinned TS target/downstream flags, repeated invalidation, pass consumption, and disposed/plain-node refusals.');
