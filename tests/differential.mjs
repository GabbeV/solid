import assert from 'node:assert/strict';
import {BendRuntime, list, ABI, encode, decode} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';

export const lit=lit=>({lit}), read=read=>({read}), add=(a,b)=>({add:[a,b]}), mul=(a,b)=>({mul:[a,b]}), select=(c,y,n)=>({select:[c,y,n]});
function checkGraph(b) {
  const ns=b.nodes(), ls=list(b.world.links), active=new Set();
  for(let sub=1;sub<ns.length;sub++) {
    let edge=ns[sub].deps; const seen=new Set();
    while(edge) {
      assert(!seen.has(edge),'dependency list cycle'); seen.add(edge); active.add(edge);
      assert.equal(ls[edge].sub,sub); edge=ls[edge].nextDep;
    }
    if(ns[sub].depsTail) assert(seen.has(ns[sub].depsTail),'invalid validated tail');
  }
  const reverse=new Set();
  for(let dep=1;dep<ns.length;dep++) {
    let edge=ns[dep].subs, prev=0; const seen=new Set();
    while(edge) {
      assert(!seen.has(edge),'subscriber list cycle');seen.add(edge);reverse.add(edge);
      assert.equal(ls[edge].dep,dep);assert.equal(ls[edge].prevSub,prev);
      prev=edge; edge=ls[edge].nextSub;
    }
    assert.equal(ns[dep].subsTail,prev);
  }
  assert.deepEqual(active,reverse,'link directions disagree');
  assert.equal(b.world.context,0,'context leaked'); assert.equal(b.world.tracking,false,'tracking leaked');
  if(!b.world.scheduled) {
    assert.equal(list(b.world.pendingNodes).length,0);
    assert.equal(b.world.unflushedStaged,false,'unflushed state survived a completed drain');
    assert.equal(list(b.world.promotedWrites).length,0,'promoted-write list survived a completed drain');
    for(const n of ns) assert(!('value' in n.pending),'unqueued staging after completed flush');
  }
}
let passed=0;
export function scenario(name,commands,{trace=true}={}) {
  const b=new BendRuntime(), s=new SolidRuntime();
  try {
    for(const [op,...args] of commands) {
      const a=b[op](...args), r=s[op](...args);
      if(['read','set','update','screen'].includes(op)) assert.deepEqual(a,r,`${name}: ${op} result`);
      checkGraph(b);
      if(trace) assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
      for(const target of [2,3,4]) assert.deepEqual(b.screen(target),s.screen(target),`${name}: tree ${target} after ${op}`);
    }
    passed++;
  } catch(error) {
    console.error(`FAILED: ${name}\n${JSON.stringify(commands)}`); throw error;
  } finally {s.dispose();s.flush();}
}
scenario('staged writes and updater composition',[
  ['signal','x',1],['set','x',2],['read','x'],['update','x',add({prev:true},lit(3))],['read','x'],['flush'],['read','x']
]);
scenario('undefined updater is successful data', [['signal','x',3],['update','x',lit(undefined)],['read','x'],['flush'],['read','x']]);
scenario('nonidentity chain and render',[
  ['signal','x',1],['memo','a',add(read('x'),lit(1))],['memo','b',mul(read('a'),lit(2))],['effect','view',add(read('b'),read('x'))],
  ['set','x',7],['read','b'],['flush'],['read','b'],['set','x',8],['set','x',9],['flush']
]);
scenario('diamond',[
  ['signal','x',2],['memo','a',add(read('x'),lit(1))],['memo','b',mul(read('x'),lit(3))],['memo','c',add(read('a'),read('b'))],['effect','view',read('c')],
  ['set','x',8],['flush'],['set','x',0],['flush']
]);
scenario('equality stops downstream work',[
  ['signal','x',2],['memo','a',{same:[read('x'),lit(0)]}],['effect','view',read('a')],['set','x',3],['flush'],['set','x',0],['flush']
]);
scenario('conditional link trimming',[
  ['signal','on',true],['signal','x',2],['signal','y',10],['memo','a',select(read('on'),read('x'),read('y'))],['effect','view',read('a')],
  ['set','on',false],['flush'],['set','x',9],['flush'],['set','y',11],['flush'],['set','on',true],['flush']
]);
scenario('nonconsecutive repeated reads',[
  ['signal','x',2],['signal','y',4],['memo','a',add(add(read('x'),read('y')),read('x'))],['effect','view',read('a')],['set','x',3],['flush'],['set','y',8],['flush']
]);
scenario('untrack keeps the value and suppresses subscription',[
  ['signal','x',1],['signal','y',3],['memo','a',add({untrack:read('x')},read('y'))],['effect','view',read('a')],['set','x',4],['flush'],['set','y',5],['flush']
]);
scenario('render and user phase order',[
  ['signal','x',1],['effect','user',read('x'),{user:true}],['effect','view',read('x')],['flush'],['set','x',4],['flush']
]);
scenario('scheduled and deferred initial effects',[
  ['signal','x',1],['effect','view',read('x'),{schedule:true}],['effect','deferred',read('x'),{defer:true,target:3}],['flush'],['set','x',2],['flush']
]);
scenario('late linking after write',[
  ['signal','x',1],['set','x',2],['memo','a',add(read('x'),lit(1))],['effect','view',read('a')],['flush']
]);
scenario('late untracked reader still reruns in the carrying flush',[
  ['signal','x',1],['set','x',2],['memo','a',{untrack:read('x')}],['effect','view',read('a')],['flush'],['read','a']
]);
scenario('unflushed undefined retains committed data until flush',[
  ['signal','x',11],['set','x',undefined],['memo','a',read('x')],['effect','view',read('a')],['read','x'],['flush'],['read','a']
]);
scenario('unflushed state reopens after an earlier drain',[
  ['signal','x',1],['set','x',2],['flush'],['set','x',3],['memo','a',read('x')],['effect','view',read('a')],['flush'],['read','a']
]);
scenario('lazy initial pull',[
  ['signal','x',1],['memo','a',add(read('x'),lit(1)),{lazy:true}],['read','a'],['effect','view',read('a')],['set','x',3],['flush']
]);
scenario('write and revert still notify direct effects',[
  ['signal','x',1],['effect','view',read('x')],['set','x',2],['set','x',1],['flush']
]);
scenario('previous successful output',[
  ['signal','x',1],['memo','a',add(read('x'),select({prev:true},{prev:true},lit(0)))],['effect','view',read('a')],['set','x',2],['flush'],['set','x',3],['flush']
]);
scenario('constructor flags retain normal synchronous execution',[
  ['signal','x',1,{equals:false,ownedWrite:true,noSnapshot:true}],
  ['memo','a',add(read('x'),lit(1)),{transparent:true,sync:true,noSnapshot:true}],
  ['effect','view',read('a'),{sync:true,ownedWrite:true}],['set','x',1],['flush'],['set','x',3],['flush']
]);
scenario('loading seed participates in previous-value computation',[
  ['signal','x',1],['memo','a',add(read('x'),{prev:true}),{loadingValue:5}],['effect','view',read('a')],
  ['set','x',2],['flush'],['read','a']
]);
scenario('explicit undefined loading seed and effect-specific option rules',[
  ['signal','x',1],['memo','a',add(read('x'),select({prev:true},{prev:true},lit(0))),{loadingValue:undefined,lazy:true}],
  ['effect','view',add(read('a'),select({prev:true},{prev:true},lit(0))),{loadingValue:5,lazy:true,noSnapshot:true}],
  ['set','x',2],['flush'],['read','a']
]);
scenario('refresh pure node',[
  ['memo','a',lit(2)],['effect','view',read('a')],['refresh','a'],['flush']
]);
scenario('refresh ignores plain signal', [['signal','x',3],['effect','view',read('x')],['refresh','x'],['flush'],['read','x']]);
scenario('disposed graph stays frozen',[
  ['signal','x',1],['memo','a',add(read('x'),lit(1))],['effect','view',read('a')],['set','x',3],['dispose'],['flush'],['read','a'],['set','x',4],['flush']
]);
for(const [label,a,b] of [['undefined',1,undefined],['null',undefined,null],['NaN',NaN,NaN],['identity',{ref:1},{ref:2}],['same identity',{ref:1},{ref:1}],['text','a','b'],['boolean',false,true],['signed zero',0,-0]]) {
  scenario(`payload ${label}`,[['signal','x',a],['memo','m',read('x')],['effect','view',read('m')],['set','x',b],['flush']]);
}
// Seeded graph/history generation. The independent interpreter on the Solid
// side evaluates callbacks; only the scenario grammar is shared.
let seed=0x2b3a9e;const rng=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
for(let index=0;index<160;index++) {
  const cmds=[['signal','x',rng(8)],['signal','y',rng(8)],['signal','on',true]];
  const refs=['x','y'];
  for(let i=0;i<4;i++) {
    const a=read(refs[rng(refs.length)]), b=read(refs[rng(refs.length)]);
    const e=[add(a,b),select(read('on'),a,b),mul(a,lit(rng(3))),{same:[a,lit(rng(5))]}][rng(4)];
    // Keep arithmetic over naturals: boolean memos are final read leaves.
    const expr=('same' in e) ? select(e,lit(1),lit(0)) : e;
    cmds.push(['memo',`m${i}`,expr,{equals:rng(4)!==0}]); refs.push(`m${i}`);
  }
  cmds.push(['effect','view',read('m3')],['effect','user',read(refs[rng(refs.length)]),{user:true}],['flush']);
  for(let i=0;i<10;i++) {
    cmds.push(['set',rng(2)?'x':'y',rng(8)]);
    if(rng(3)===0)cmds.push(['set','on',rng(2)===0]);
    if(rng(3)===0)cmds.push(['read',refs[rng(refs.length)]]);
    if(rng(2)===0)cmds.push(['flush']);
  }
  cmds.push(['flush']);scenario(`generated-${index}`,cmds);
}
// ABI/unsupported-path probes exercise the actual emitted closure.
for(const v of [undefined,null,NaN,0,-0,12,true,false,'hello',{ref:42}]) assert.deepEqual(decode(encode(v)),v===0?0:v);
assert.throws(()=>encode(0.5),RangeError);
const exhausted=new BendRuntime({fuel:0});assert.throws(()=>exhausted.memo('x',lit(1)),/stopped/);
const unsupported=new BendRuntime();assert.throws(()=>unsupported.memo('x',{raise:null}),/stopped/);
console.log(`${passed} differential scenarios passed, including generated histories and graph invariants.`);
