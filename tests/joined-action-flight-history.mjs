// The selected rendered-graph slice, checked against independently authored
// native generators. Finite controls challenge the intended observation rule;
// these are separate from the quantified prefix/accounting proofs.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {build} from 'esbuild';
import {BendRuntime,list,encodeList} from '../host/bend.mjs';
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
const asList=encodeList;
const source=new URL('../upstream/solid/packages/signals/src/',import.meta.url).pathname;
const bundle=await build({stdin:{contents:"export * from './index.ts';export {resolveTx,live,blocked} from './core/scheduler.ts';export {REACTIVE_DIRTY,CONFIG_AUTO_DISPOSE} from './core/constants.ts';",resolveDir:source,loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'},plugins:[{name:'live-transactions-only',setup(b){b.onLoad({filter:/[/\\]core[/\\]scheduler\.ts$/},args=>import('node:fs').then(fs=>({loader:'ts',contents:fs.readFileSync(args.path,'utf8')+'\nexport {transactions as live};'})));}}]});
const moduleUrl='data:text/javascript;base64,'+Buffer.from(bundle.outputFiles[0].text).toString('base64');
const lit=lit=>({lit}),seq=(...seq)=>({seq}),result=(value,done=false)=>({iteratorResult:{value,done}});
const write=value=>({invokeWith:{callee:lit({setter:'x'}),value:lit(value)}});
let histories=0,rejectedActionHistories=0,prefixes=0,zeroDebtGraphControls=0,renderedScanControls=0,asyncPrefixControls=0,acceptedAsyncPrefixControls=0,trimmedAsyncPrefixControls=0,settlementPrefixes=0,settlementSteps=0,settlementVisits=0,settlementReleaseBoundaries=0,settlementFlushBoundaries=0,ownerTrimCompleteControls=0,structuralOwnerSteps=0,callbackStartBoundaries=0,independentApplyControls=0,selectedUiChecks=0,emptySettlementSixStepControls=0,trimmedEmptyEightStepControls=0,emptyDriverSplitControls=0,emptyDriverExhaustionControls=0;
// Positive actual-release queueing controls. This fork does not execute the
// queued owner work or claim a native/public release history.
let queuedReleaseFrameControls=0,faultedPendingFrameControls=0,pendingTopologyStepControls=0,settledLeafShapeControls=0;
{
 const fixture=new BendRuntime({async:true});
 fixture.memo('unused',{lit:'cached later'},{lazy:true});
 const id=fixture.ids.unused,snapshot=structuredClone(fixture.world);
 const view=world=>({values:list(world.nodes).map(n=>n.value),tree:world.tree,events:world.events});
 const pending=[{$:'Release',index:0},{$:'End'}],visited=asList([71]),released=asList([id]);
 const rest=asList([{$:'AsyncFlush'}]),values=asList([{$:'StringValue',s:'caller'}]);
 for(const scheduled of [false,true]){
  const head={$:'PendingTasks',tasks:asList(pending),visited,released,scheduled};
  const machine={$:'Machine',world:fixture.world,tasks:asList([head,...list(rest)]),values};
  const result=C.step(machine),tasks=list(result.tasks);
  assert.deepEqual(result.world,fixture.world,'queueing eligible owner release retains whole World');
  assert.deepEqual(view(result.world),view(snapshot));
  assert.deepEqual(tasks[0],{$:'OwnerTasks',tasks:asList([{$:'Unobserved',id}])});
  assert.deepEqual(tasks[1],{$:'PendingTasks',tasks:asList([{$:'Release',index:1},{$:'End'}]),visited,released,scheduled});
  assert.deepEqual(list(result.values),list(values));queuedReleaseFrameControls++;
  const faulted={...machine,world:{...fixture.world,fault:{$:'TypeError'}}},unwound=C.step(faulted);
  assert.deepEqual(unwound.world,faulted.world,'pending fault unwind retains actual World');
  assert.deepEqual(list(unwound.tasks),list(rest));assert.deepEqual(list(unwound.values),list(values));faultedPendingFrameControls++;
 }
 assert.deepEqual(fixture.world,snapshot,'private release calls retain constructor snapshot');
 fixture.dispose();
}
for(const direct of [false,true])for(const reverseCreate of [false,true])for(const events of [['a','b','flight'],['b','a','flight'],['a','flight','b'],['b','flight','a'],['flight','a','b'],['flight','b','a']])for(const {family,rejectAction} of [{family:'text',rejectAction:-1},{family:'nullable',rejectAction:-1},{family:'references',rejectAction:-1},{family:'text',rejectAction:0},{family:'text',rejectAction:1}])for(const independent of [false,true]){
 const S=await import(moduleUrl+'#joined-actions='+histories),b=new BendRuntime({async:true});
 const references=Array.from({length:5},(_,id)=>Object.freeze({id}));
 const raw=family==='text'?['initial','first proposal','second proposal','first result','second result']:family==='nullable'?[undefined,false,true,false,true]:references;
 const encode=value=>family==='references'?{ref:references.indexOf(value)+1}:value;
 const values=raw.map(encode),initial=values[0],seen=[],freeSeen=[];
 const gates=[Promise.withResolvers(),Promise.withResolvers()],flight=Promise.withResolvers();
 const created=reverseCreate?[1,0]:[0,1];
 let get,set,free,setFree,dispose;const native=[],ported=[];
 const name=JSON.stringify({direct,reverseCreate,events,family,independent,rejectAction});
 try{
  S.createRoot(d=>{
   dispose=d;[get,set]=S.createSignal(raw[0]);[free,setFree]=S.createSignal(10);
   const compute=()=>get()===raw[0]?raw[0]:flight.promise;
   const derived=direct?compute:S.createMemo(compute);
   S.createRenderEffect(derived,value=>{seen.push(encode(value));});
   S.createRenderEffect(free,value=>{freeSeen.push(value);});
  });
  b.future('flight');b.signal('x',initial);b.signal('free',10);const compute={select:[{same:[{read:'x'},lit(initial)]},lit(initial),{future:'flight'}]};if(direct)b.effect('view',compute);else{b.memo('derived',compute);b.effect('view',{read:'derived'});}b.effect('freeView',{read:'free'},{target:3});b.future('a');b.future('b');
  S.flush();b.flush();
  const applies=target=>b.trace().filter(e=>e[0]==='apply'&&e[1]===target).map(e=>e[2]);
  const compare=()=>{
   assert.deepEqual(b.read('x'),encode(get()),name+' committed read');
   assert.deepEqual(applies('view'),seen,name+' ordinary renderer');
   assert.deepEqual(applies('freeView'),freeSeen,name+' independent renderer');
   assert.deepEqual(b.asyncErrors,[],name+' host errors');
   assert.equal(b.world.fault.$,'Healthy');assert.equal(b.world.actionDepth,0);assert.equal(b.world.question.$,'QuestionZero');
   const tree=list(b.world.tree);
   assert.deepEqual(b.decode(tree[2].text),seen.at(-1),name+' selected mechanical text matches native renderer result');
   assert.deepEqual(b.decode(tree[3].text),freeSeen.at(-1),name+' independent mechanical text matches native renderer result');selectedUiChecks++;prefixes++;
  };
  const action=S.action(function* (index){set(raw[index+1]);yield gates[index].promise;return raw[index+3];});
  let root;
  for(const index of created){
   native[index]=action(index);native[index].catch(()=>{});
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
    if(index===rejectAction){gates[index].reject(17);b.reject(index?'b':'a',17);}else{gates[index].resolve();b.resolve(index?'b':'a',undefined);}
    const outcome=async promise=>{try{return ['value',await promise];}catch(error){return ['error',error];}};
    const [nativeOutcome,bendOutcome]=await Promise.all([outcome(native[index]),outcome(ported[index])]);
    const observedNative=[nativeOutcome[0],encode(nativeOutcome[1])];
    assert.deepEqual(bendOutcome,observedNative,name+' action result/error');
    assert.deepEqual(observedNative,index===rejectAction?['error',17]:['value',values[index+3]]);completed++;
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
    // A separate renderer/target can apply while this group is held. Fork one
    // actual Core.step without installing the private result in the public run.
    const selected=world=>({texts:[list(world.tree)[2].text],applications:list(world.events).filter(e=>e.$==='Applied'&&e.id===b.ids.view)});
    const callerValues=asList([{$:'StringValue',s:'independent caller'},{$:'Number',n:23}]);
    const saved=structuredClone(before),selectedBefore=structuredClone(selected(before));
    const applied=C.step({$:'Machine',world:before,tasks:asList([{$:'ApplyEffect',id:b.ids.freeView},...list(rest)]),values:callerValues});
    assert.deepEqual(before,saved,name+' private independent apply retains input snapshot');
    assert.deepEqual(selected(applied.world),selectedBefore,name+' independent actual apply retains selected text and application trace');
    assert.notDeepEqual(applied.world.events,before.events,name+' independent apply really records an application');
    assert.deepEqual(list(applied.world.tree)[3].text,list(before.nodes)[b.ids.freeView].value,name+' independent target receives the source committed value');
    assert.deepEqual(list(applied.values),list(callerValues),name+' independent apply retains caller stack');
    assert.equal(applied.world.fault.$,'Healthy');independentApplyControls++;
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
     if(direct){
      const hadTrim=tasks[0].$==='OwnerTasks';
      let input=prefix;
      if(hadTrim){input=C.step(C.step(input));}
      assert.equal(list(input.tasks)[0].$,'AsyncWriteAfterTrim');
      assert.equal(list(input.world.nodes)[asyncId].subs,0,name+' direct renderer has no subscribers');
      assert.equal(input.world.fault.$,'Healthy');
      // The successful write already removed its self carrier and requested a
      // flush. The six-step segment has no further observable/metadata change
      // in these real snapshots, so exact World equality is an independent oracle.
      const ext=list(input.world.extensions)[list(input.world.nodes)[asyncId].x];
      const pendingSlots=list(list(input.world.pendingSets)[ext.pendingSources]);
      assert.ok(!pendingSlots.includes(asyncId),name+' self carrier already retired');
      assert.equal(input.world.scheduled,true,name+' source arrival requested flush');
      let returned=input;for(let step=0;step<6;step++)returned=C.step(returned);
      assert.deepEqual(returned.world,input.world,name+' six-step empty settlement retains exact scheduled World');
      assert.deepEqual(list(returned.tasks),ending.slice(2),name+' six-step empty settlement returns to queued flush');
      assert.deepEqual(list(returned.values),list(valueStack));
      emptySettlementSixStepControls++;
      for(const remaining of [0,1,7]){
       const whole=C.run(6+remaining,input),split=C.run(remaining,returned);
       assert.deepEqual(whole,split,name+' actual driver uses exactly the remaining suffix fuel');emptyDriverSplitControls++;
       if(remaining===0){
        assert.equal(whole.world.fault.$,'Exhausted',name+' queued caller still needs fuel');
        assert.deepEqual(list(whole.tasks),[]);assert.deepEqual(list(whole.values),[]);emptyDriverExhaustionControls++;
       }
      }
      if(hadTrim){
       let trimmed=prefix;for(let step=0;step<8;step++)trimmed=C.step(trimmed);
       assert.deepEqual(trimmed,returned,name+' optional trim plus settlement finishes in exactly eight steps');trimmedEmptyEightStepControls++;
      }
     }
     // Execute the actual core bookkeeping continuations up to the first owner
     // release or flush. Those boundaries can run application code or publish;
     // they are retained, not assumed to preserve every cached node value.
     {
      if(tasks[0].$==='OwnerTasks'){
       const currentNode=list(prefix.world.nodes)[asyncId],tail=currentNode.depsTail;
       const staleEdge=tail?list(prefix.world.links)[tail].nextDep:currentNode.deps;
       assert.equal(staleEdge,0,name+' source trim selector has no stale suffix');
       const returned=C.step(C.step(prefix));
       assert.deepEqual(returned.world,prefix.world,name+' no-stale trim completes with exact World');
       assert.deepEqual(list(returned.tasks),ending,name+' two-step trim retains caller work');
       assert.deepEqual(list(returned.values),list(valueStack),name+' two-step trim retains caller stack');
       ownerTrimCompleteControls++;
      }
      let machine=prefix,steps=0,visits=0;
      for(;;){
       const head=list(machine.tasks)[0];
       if(!head||!['OwnerTasks','AsyncWriteAfterTrim','PendingTasks','AsyncWriteSchedule'].includes(head.$))break;
       if(head.$==='OwnerTasks'){
        const first=list(head.tasks)[0];
        if(first&&['WriteValue','WriteForward','Action'].includes(first.$))break;
        structuralOwnerSteps++;
       }
       if(head.$==='PendingTasks'&&list(head.tasks)[0]?.$==='Visit')visits++;
       const topology=world=>({nodes:list(world.nodes).map(n=>({kind:n.kind,config:n.config,subs:n.subs})),links:world.links});
       const previous=machine;
       machine=C.step(machine);steps++;
       if(head.$!=='OwnerTasks'){
        assert.deepEqual(topology(machine.world),topology(previous.world),name+' actual pending step retains kind/config/subscriber heads and links');pendingTopologyStepControls++;
       }
       if(head.$==='PendingTasks'&&list(head.tasks)[0]?.$==='Visit'){
        const visit=list(head.tasks)[0],leaf=list(previous.world.nodes)[visit.id];
        assert.equal(leaf.subs,0);assert.equal(leaf.config&S.CONFIG_AUTO_DISPOSE,0);
        const next=list(machine.tasks)[0];assert.equal(next.$,'PendingTasks');
        assert.deepEqual(list(next.tasks)[0],{$:'Walk',edge:0,root:visit.root,source:visit.source});
        assert.deepEqual(list(next.visited),[visit.id]);assert.deepEqual(list(next.released),[]);settledLeafShapeControls++;
       }
       assert.ok(steps<200,'finite valid fixture settlement must terminate before its flush');
       assert.equal(machine.world.fault.$,'Healthy',name+' actual settlement stays healthy');
       assert.deepEqual(committed(machine.world),originalView,name+' actual settlement retains committed storage/tree/trace');
       assert.deepEqual(list(machine.values),list(valueStack),name+' actual settlement retains nonempty caller stack');
       const retained=ending.slice(head.$==='OwnerTasks'?0:head.$==='AsyncWriteSchedule'?2:1);
       assert.deepEqual(list(machine.tasks).slice(-retained.length),retained,name+' actual settlement retains exact flush/then/caller tail');
      }
      const boundary=list(machine.tasks)[0];
      assert.ok(boundary&&['Evaluate','OwnerTasks','AsyncFlush'].includes(boundary.$),name+' explicit release/flush boundary');
      if(boundary.$==='OwnerTasks')settlementReleaseBoundaries++;else if(boundary.$==='Evaluate')callbackStartBoundaries++;else settlementFlushBoundaries++;
      assert.ok(steps>0);settlementPrefixes++;settlementSteps+=steps;settlementVisits+=visits;
     }

    }else assert.deepEqual(list(prefix.tasks),list(rest),name+' dirty arrival is ignored');
    asyncPrefixControls++;
    }
   }
   if(completed<2||!flightDone){assert.equal(S.blocked(root),true);assert.deepEqual(seen,[initial],name+' action or rendered flight still blocks publication');}
  }
  assert.equal(S.blocked(root),false,name+' completed actions and flight are eligible');
  assert.deepEqual(seen,[initial,values[4]],name+' one joined rendered publication');assert.deepEqual(b.read('x'),values[created[1]+1]);
  histories++;if(rejectAction>=0)rejectedActionHistories++;
 }catch(error){console.error('FAILED joined action history '+name,error);throw error;}
 finally{
  flight.resolve(raw[4]);b.attempt('resolve','flight',values[4]);for(const [index,gate] of gates.entries()){gate.resolve();b.attempt('resolve',index?'b':'a',undefined);}await Promise.allSettled([...native,...ported]);
  dispose?.();b.dispose();S.flush();b.flush();await setImmediate();
 }
}
assert.ok(acceptedAsyncPrefixControls>0,'fulfillment prefix fixtures must cover actual accepted arrivals');
assert.ok(trimmedAsyncPrefixControls>0,'fulfillment prefix fixtures must cover queued owner trim');
assert.ok(settlementPrefixes>0&&settlementSteps>0&&settlementVisits>0,'settlement fixtures must execute actual dependent traversal');
assert.ok(settlementFlushBoundaries>0,'settlement fixtures must reach their queued flush');
assert.ok(ownerTrimCompleteControls>0&&structuralOwnerSteps>0,'owner trim fixtures must execute actual structural work');
assert.ok(independentApplyControls>0&&selectedUiChecks>0,'selected renderer fixtures must observe real independent applications and text results');
assert.ok(emptySettlementSixStepControls>0,'empty-subscriber fixtures must cover the actual six-step path');
assert.ok(pendingTopologyStepControls>0&&settledLeafShapeControls>0);
console.log(JSON.stringify({pendingTopologyStepControls,settledLeafShapeControls,queuedReleaseFrameControls,faultedPendingFrameControls,publicHistories:histories,rejectedActionHistories,observedPrefixes:prefixes,nativeGeneratorControls:histories,zeroDebtGraphControls,renderedScanControls,asyncPrefixControls,acceptedAsyncPrefixControls,trimmedAsyncPrefixControls,settlementPrefixes,settlementSteps,settlementVisits,settlementReleaseBoundaries,settlementFlushBoundaries,ownerTrimCompleteControls,structuralOwnerSteps,callbackStartBoundaries,independentApplyControls,selectedUiChecks,emptySettlementSixStepControls,trimmedEmptyEightStepControls,emptyDriverSplitControls,emptyDriverExhaustionControls,scope:'two joined held actions and a rendered flight, all completion/flight orders, successful opaque/text/nullable values and text-only rejection of either action, independent publication, direct render or memo-backed render; finite evidence, not a general proof'}));
