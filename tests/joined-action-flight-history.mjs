// The selected rendered-graph slice, checked against independently authored
// native generators. Finite controls challenge the intended observation rule;
// these are separate from the quantified prefix/accounting proofs.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {build} from 'esbuild';
import {BendRuntime,list} from '../host/bend.mjs';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
// Invoke the same translated source helpers on actual public-history snapshots.
// These additional calls are finite Bend boundary checks, not native scan proofs.
const rootDir=fileURLToPath(new URL('../',import.meta.url)),privateDir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-rendered-flight-'));
const privateModules={};
try{
 const activeSource=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):rootDir;
 for(const name of ['transaction','core']){
  const output=path.join(privateDir,name+'.mjs');
  const result=spawnSync(path.join(rootDir,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(activeSource,'runtime',name+'.bend'),'-o',output],{cwd:rootDir,encoding:'utf8',maxBuffer:1024*1024});
  assert.equal(result.status,0,result.stderr);privateModules[name]=(await import(pathToFileURL(output))).default;
 }
}finally{fs.rmSync(privateDir,{recursive:true,force:true});}
const T=privateModules.transaction,C=privateModules.core;
const asList=xs=>xs.reduceRight((tail,head)=>({$:'Cons',head,tail}),{$:'Nil'});
const source=new URL('../upstream/solid/packages/signals/src/',import.meta.url).pathname;
const bundle=await build({stdin:{contents:"export * from './index.ts';export {resolveTx,live,blocked} from './core/scheduler.ts';export {REACTIVE_DIRTY} from './core/constants.ts';",resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'live-transactions-only',setup(b){b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>import('node:fs').then(fs=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {transactions as live};'})));}}]});
const moduleUrl='data:text/javascript;base64,'+Buffer.from(bundle.outputFiles[0].text).toString('base64');
const lit=lit=>({lit}),seq=(...seq)=>({seq}),result=(value,done=false)=>({iteratorResult:{value,done}});
const write=value=>({invokeWith:{callee:lit({setter:'x'}),value:lit(value)}});
let histories=0,prefixes=0,zeroDebtGraphControls=0,renderedScanControls=0,asyncPrefixControls=0,acceptedAsyncPrefixControls=0,trimmedAsyncPrefixControls=0;
for(const direct of [false,true])for(const reverseCreate of [false,true])for(const events of [['a','b','flight'],['b','a','flight'],['a','flight','b'],['b','flight','a'],['flight','a','b'],['flight','b','a']])for(const family of ['text','nullable','references'])for(const independent of [false,true]){
 const S=await import(moduleUrl+'#joined-actions='+histories),b=new BendRuntime({async:true});
 const references=Array.from({length:5},(_,id)=>Object.freeze({id}));
 const raw=family==='text'?['initial','first proposal','second proposal','first result','second result']:family==='nullable'?[undefined,false,true,false,true]:references;
 const encode=value=>family==='references'?{ref:references.indexOf(value)+1}:value;
 const values=raw.map(encode),initial=values[0],seen=[],freeSeen=[];
 const gates=[Promise.withResolvers(),Promise.withResolvers()],flight=Promise.withResolvers();
 const created=reverseCreate?[1,0]:[0,1];
 let get,set,free,setFree,dispose;const native=[],ported=[];
 const name=JSON.stringify({direct,reverseCreate,events,family,independent});
 try{
  S.createRoot(d=>{
   dispose=d;[get,set]=S.createSignal(raw[0]);[free,setFree]=S.createSignal(10);
   const compute=()=>get()===raw[0]?raw[0]:flight.promise;
   const derived=direct?compute:S.createMemo(compute);
   S.createRenderEffect(derived,value=>{seen.push(encode(value));});
   S.createRenderEffect(free,value=>{freeSeen.push(value);});
  });
  b.future('flight');b.signal('x',initial);b.signal('free',10);const compute={select:[{same:[{read:'x'},lit(initial)]},lit(initial),{future:'flight'}]};if(direct)b.effect('view',compute);else{b.memo('derived',compute);b.effect('view',{read:'derived'});}b.effect('freeView',{read:'free'});b.future('a');b.future('b');
  S.flush();b.flush();
  const applies=target=>b.trace().filter(e=>e[0]==='apply'&&e[1]===target).map(e=>e[2]);
  const compare=()=>{
   assert.deepEqual(b.read('x'),encode(get()),name+' committed read');
   assert.deepEqual(applies('view'),seen,name+' ordinary renderer');
   assert.deepEqual(applies('freeView'),freeSeen,name+' independent renderer');
   assert.deepEqual(b.asyncErrors,[],name+' host errors');
   assert.equal(b.world.fault.$,'Healthy');assert.equal(b.world.actionDepth,0);assert.equal(b.world.question.$,'QuestionZero');prefixes++;
  };
  const action=S.action(function* (index){set(raw[index+1]);yield gates[index].promise;return raw[index+3];});
  let root;
  for(const index of created){
   native[index]=action(index);
   ported[index]=b.runAction(index?'two':'one',{steps:[{next:seq(write(values[index+1]),result({future:index?'b':'a'}))},{next:result(lit(values[index+3]),true)}]});
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
  let completed=0,flightDone=false;
  for(const event of events){
   if(event==='flight'){flight.resolve(raw[4]);b.resolve('flight',values[4]);flightDone=true;}
   else{
    const index=event==='a'?0:1;
    gates[index].resolve();b.resolve(index?'b':'a',undefined);
    const [nativeValue,bendValue]=await Promise.all([native[index],ported[index]]);
    assert.deepEqual(encode(nativeValue),values[index+3]);assert.deepEqual(bendValue,values[index+3]);completed++;
   }
   await setImmediate();compare();
   assert.equal(root._open,2-completed,name+' source debt');
   assert.equal(list(b.world.txArena)[representative].open,2-completed,name+' Bend debt');
   if(completed===2&&!flightDone){
    const before=b.world,pair=T.blocked(before,representative);
    assert.equal(pair.right,true,name+' actual Bend graph blocker at zero action debt');
    assert.deepEqual(pair.left,before,name+' complete World/judge retained');zeroDebtGraphControls++;
    const index=list(before.transactions).indexOf(representative);assert.ok(index>=0);
    const frame={$:'SeamFrame',transaction:representative,renders:asList([37]),users:asList([{$:'NodeRun',node:41}]),laneRenders:asList([]),laneUsers:asList([])};
    const rest=asList([{$:'Discard'}]),stack=asList([{$:'StringValue',s:'caller value'}]);
    const scan=C.landTransactions(before,rest,stack,frame,1+index);
    assert.deepEqual(scan.world,before,name+' blocked graph scan retains World');
    assert.deepEqual(list(scan.tasks),[{$:'LandTransactions',frame,remaining:index},...list(rest)]);
    assert.deepEqual(list(scan.values),list(stack));renderedScanControls++;
    // Fork a callback-free fulfillment prefix; do not install or drain it in
    // the real history. The public native/control event sequence stays intact.
    const asyncId=b.ids[direct?'view':'derived'],node=list(before.nodes)[asyncId],extension=list(before.extensions)[node.x];
    assert.equal(extension.inFlight.$,'FlightActive');assert.equal(extension.inFlight.result,b.futures.flight);
    const then=asList([{$:'AsyncFlush'}]),valueStack=asList([{$:'StringValue',s:'outer callback'},{$:'Number',n:17}]);
    for(const reply of [values[4],initial]){
    const committed=world=>({values:list(world.nodes).map(n=>n.value),tree:world.tree,events:world.events});
    const original=structuredClone(before),originalView=structuredClone(committed(before));
    const prefix=C.asyncWrite(before,rest,valueStack,asyncId,b.futures.flight,b.encode(reply),then);
    assert.deepEqual(before,original,name+' forked fulfillment leaves its input snapshot intact');
    assert.deepEqual(committed(prefix.world),originalView,name+' fulfillment prefix retains committed storage/tree/trace');
    assert.deepEqual(list(prefix.values),list(valueStack),name+' fulfillment prefix retains caller stack');
    assert.equal(prefix.world.fault.$,'Healthy');
    if((node.flags&S.REACTIVE_DIRTY)===0){
     const ending=[{$:'AsyncWriteAfterTrim',id:asyncId},{$:'AsyncWriteSchedule'},{$:'AsyncFlush'},...list(then),...list(rest)];
     const tasks=list(prefix.tasks);
     assert.deepEqual(tasks.slice(-ending.length),ending,name+' fulfillment prefix retains trim/schedule/flush/then/caller task order');
     if(tasks.length>ending.length){assert.equal(tasks[0].$,'OwnerTasks');assert.deepEqual(list(tasks[0].tasks),[{$:'TrimDeps',id:asyncId}]);trimmedAsyncPrefixControls++;}
     acceptedAsyncPrefixControls++;
    }else assert.deepEqual(list(prefix.tasks),list(rest),name+' dirty arrival is ignored');
    asyncPrefixControls++;
    }
   }
   if(completed<2||!flightDone){assert.equal(S.blocked(root),true);assert.deepEqual(seen,[initial],name+' action or rendered flight still blocks publication');}
  }
  assert.equal(S.blocked(root),false,name+' completed actions and flight are eligible');
  assert.deepEqual(seen,[initial,values[4]],name+' one joined rendered publication');assert.deepEqual(b.read('x'),values[created[1]+1]);
  histories++;
 }catch(error){console.error('FAILED joined action history '+name,error);throw error;}
 finally{
  flight.resolve(raw[4]);b.attempt('resolve','flight',values[4]);for(const [index,gate] of gates.entries()){gate.resolve();b.attempt('resolve',index?'b':'a',undefined);}await Promise.allSettled([...native,...ported]);
  dispose?.();b.dispose();S.flush();b.flush();await setImmediate();
 }
}
assert.ok(acceptedAsyncPrefixControls>0,'fulfillment prefix fixtures must cover actual accepted arrivals');
assert.ok(trimmedAsyncPrefixControls>0,'fulfillment prefix fixtures must cover queued owner trim');
console.log(JSON.stringify({publicHistories:histories,observedPrefixes:prefixes,nativeGeneratorControls:histories,zeroDebtGraphControls,renderedScanControls,asyncPrefixControls,acceptedAsyncPrefixControls,trimmedAsyncPrefixControls,scope:'two joined held actions and a rendered flight, all completion/flight orders, opaque/text/nullable payloads and independent publication, direct render or memo-backed render; finite evidence, not a general proof'}));
