// The selected rendered-graph slice, checked against independently authored
// native generators. Finite controls challenge the intended observation rule;
// these are separate from the quantified prefix/accounting proofs.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {build} from 'esbuild';
import {BendRuntime,list} from '../host/bend.mjs';
const source=new URL('../upstream/solid/packages/signals/src/',import.meta.url).pathname;
const bundle=await build({stdin:{contents:"export * from './index.ts';export {resolveTx,live,blocked} from './core/scheduler.ts';",resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'live-transactions-only',setup(b){b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>import('node:fs').then(fs=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {transactions as live};'})));}}]});
const moduleUrl='data:text/javascript;base64,'+Buffer.from(bundle.outputFiles[0].text).toString('base64');
const lit=lit=>({lit}),seq=(...seq)=>({seq}),result=(value,done=false)=>({iteratorResult:{value,done}});
const write=value=>({invokeWith:{callee:lit({setter:'x'}),value:lit(value)}});
let histories=0,prefixes=0;
for(const reverseCreate of [false,true])for(const reverseFinish of [false,true])for(const family of ['text','nullable','references'])for(const independent of [false,true])for(const finishWrite of [false,true]){
 const S=await import(moduleUrl+'#joined-actions='+histories),b=new BendRuntime({async:true});
 const references=Array.from({length:5},(_,id)=>Object.freeze({id}));
 const raw=family==='text'?['initial','first proposal','second proposal','first result','second result']:family==='nullable'?[undefined,false,true,false,true]:references;
 const encode=value=>family==='references'?{ref:references.indexOf(value)+1}:value;
 const values=raw.map(encode),initial=values[0],seen=[],freeSeen=[];
 const gates=[Promise.withResolvers(),Promise.withResolvers()];
 const created=reverseCreate?[1,0]:[0,1],finished=reverseFinish?[1,0]:[0,1];
 let get,set,free,setFree,dispose;const native=[],ported=[];
 const name=JSON.stringify({reverseCreate,reverseFinish,family,independent,finishWrite});
 try{
  S.createRoot(d=>{
   dispose=d;[get,set]=S.createSignal(raw[0]);[free,setFree]=S.createSignal(10);
   const derived=S.createMemo(get);
   S.createRenderEffect(derived,value=>{seen.push(encode(value));});
   S.createRenderEffect(free,value=>{freeSeen.push(value);});
  });
  b.signal('x',initial);b.signal('free',10);b.memo('derived',{read:'x'});b.effect('view',{read:'derived'});b.effect('freeView',{read:'free'});b.future('a');b.future('b');
  S.flush();b.flush();
  const applies=target=>b.trace().filter(e=>e[0]==='apply'&&e[1]===target).map(e=>e[2]);
  const compare=()=>{
   assert.deepEqual(b.read('x'),encode(get()),name+' committed read');
   assert.deepEqual(applies('view'),seen,name+' ordinary renderer');
   assert.deepEqual(applies('freeView'),freeSeen,name+' independent renderer');
   assert.deepEqual(b.asyncErrors,[],name+' host errors');
   assert.equal(b.world.fault.$,'Healthy');assert.equal(b.world.actionDepth,0);assert.equal(b.world.question.$,'QuestionZero');prefixes++;
  };
  const action=S.action(function* (index){set(raw[index+1]);yield gates[index].promise;if(finishWrite)set(raw[index+3]);return raw[index+3];});
  let root;
  for(const index of created){
   native[index]=action(index);
   ported[index]=b.runAction(index?'two':'one',{steps:[{next:seq(write(values[index+1]),result({future:index?'b':'a'}))},{next:seq(...(finishWrite?[write(values[index+3])]:[]),result(lit(values[index+3]),true))}]});
   root??=S.live[0];compare();
  }
  S.flush();b.flush();compare();
  assert.equal(root._open,2,name+' both obligations are live');assert.equal(S.blocked(root),true);assert.deepEqual(seen,[initial]);
  const txs=list(b.world.txArena),firstTx=list(b.world.actions)[1].transaction;
  const representative=(()=>{let t=firstTx;while(txs[t].into)t=txs[t].into;return t;})();
  assert.equal(txs[representative].open,2);
  // Repeated imperative observations do not publish the held proposal.
  for(let i=0;i<3;i++){compare();assert.deepEqual(b.read('x'),initial);}
  if(independent){setFree(11);b.set('free',11);S.flush();b.flush();compare();assert.deepEqual(freeSeen,[10,11]);assert.deepEqual(seen,[initial]);}
  for(const [position,index]of finished.entries()){
   gates[index].resolve();b.resolve(index?'b':'a',undefined);
   const [nativeValue,bendValue]=await Promise.all([native[index],ported[index]]);
   assert.deepEqual(encode(nativeValue),values[index+3]);assert.deepEqual(bendValue,values[index+3]);
   await setImmediate();compare();
   assert.equal(root._open,1-position,name+' source debt');
   assert.equal(list(b.world.txArena)[representative].open,1-position,name+' Bend debt');
   if(position===0){assert.equal(S.blocked(root),true);assert.deepEqual(seen,[initial],name+' other action still blocks publication');}
  }
  const last=finishWrite?values[finished[1]+3]:values[created[1]+1];
  assert.deepEqual(seen,[initial,last],name+' one joined publication');assert.deepEqual(b.read('x'),last);
  histories++;
 }catch(error){console.error('FAILED joined action history '+name,error);throw error;}
 finally{
  for(const [index,gate] of gates.entries()){gate.resolve();b.attempt('resolve',index?'b':'a',undefined);}await Promise.allSettled([...native,...ported]);
  dispose?.();b.dispose();S.flush();b.flush();await setImmediate();
 }
}
console.log(JSON.stringify({publicHistories:histories,observedPrefixes:prefixes,nativeGeneratorControls:histories,scope:'two joined held actions, both creation/completion orders, opaque/text/nullable payloads, independent publication and optional final writes; finite evidence, not a general proof'}));
