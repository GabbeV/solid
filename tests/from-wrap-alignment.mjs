import assert from 'node:assert/strict';
import fs from 'node:fs';import os from 'node:os';import path from 'node:path';
import {spawnSync} from 'node:child_process';import {fileURLToPath,pathToFileURL} from 'node:url';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list,ABI} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-from-wrap-'));
try{
 let driver=path.join(root,'tests/probes/from-wrap.bend');
 if(process.env.BEND_EMIT_FILE){for(const name of['runtime','representation','observation'])fs.cpSync(path.join(path.dirname(process.env.BEND_EMIT_FILE),name),path.join(dir,name),{recursive:true});fs.mkdirSync(path.join(dir,'tests/probes'),{recursive:true});fs.copyFileSync(driver,path.join(dir,'tests/probes/from-wrap.bend'));driver=path.join(dir,'tests/probes/from-wrap.bend');}
 const emitted=path.join(dir,'probe.mjs'),compiled=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',driver,'-o',emitted],{cwd:root,encoding:'utf8'});assert.equal(compiled.status,0,compiled.stderr.slice(-2400));const {default:P}=await import(pathToFileURL(emitted));
 let count=0;
 for(const immediate of[false,true])for(const owned of[false,true])for(const mode of['missing','bare','throw','promise'])for(const when of['none','pre','post','one'])for(const rejected of[false,true])for(const args of[[],[undefined],[7]]){
  const S=await import('../build/solid.mjs?from-wrap-private='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S});
  const label=JSON.stringify({immediate,owned,mode,when,rejected,args});
  const options={hasReturn:mode!=='missing',...(mode==='throw'?{returnThrows:99}:{}),...(mode==='promise'?{returnFuture:'close'}:{})};
  for(const r of[b,s]){r.future('first',{immediate});r.future('second',{immediate});r.future('close',{immediate});r.stream('source',[{future:'first'},{future:'second'}],options);}
  const settle=(name,value)=>{if(rejected){b.reject(name,value);s.reject(name,value);}else{b.resolveStep(name,value);s.resolveStep(name,value);}};
  if(when==='pre'){settle('first',10);settle('second',20);}
  const a=P.open(b.world,b.futures.source,owned);b.world=a.world;b.check();
  const it=owned?S.runWithOwner(s.owner,()=>S.from(s.futures.source.object)[Symbol.asyncIterator]()):S.from(s.futures.source.object)[Symbol.asyncIterator]();
  const outcomes=[],outputs=[];
  function pull(vector){const pair=P.pull(b.world,a.iterator,vector.length?{$:'Present',value:b.encode(vector[0])}:{$:'Empty'});b.world=pair.left;b.check();assert.equal(pair.right.$,'PromiseNext',label);outputs.push(pair.right.result);const index=outcomes.length;outcomes.push(['pending']);it.next(...vector).then(value=>{outcomes[index]=['fulfilled',value];},error=>{outcomes[index]=['rejected',error];});}
  pull(args);pull(args);
  if(when==='post'){settle('first',10);settle('second',20);}
  if(when==='one'){settle('first',10);await setImmediate();}
  if(owned){b.dispose();s.dispose();}
  const returnArgument=args.length?{$:'Present',value:b.encode(args[0])}:{$:'Empty'};
  const closed=P.close(b.world,a.iterator,returnArgument);b.world=closed.world;assert.equal(b.world.fault.$,'Healthy',label+' return fault');b.check();
  assert.deepEqual(await it.return(...args),{done:true,value:undefined},label);
  const closeId=list(closed.values)[0].identity;assert.deepEqual(list(b.world.asyncObjects)[closeId].state,{$:'Fulfilled',value:{$:'StepResult',done:true,value:{$:'Undefined'}}},label+' return promise');
  // Late inner results and repeated close cannot overwrite canceled pulls.
  settle('first',10);settle('second',20);b.reject('close',77);s.reject('close',77);
  const again=P.close(b.world,a.iterator,returnArgument);b.world=again.world;assert.equal(b.world.fault.$,'Healthy',label+' repeat return fault');b.check();assert.deepEqual(await it.return(...args),{done:true,value:undefined},label);
  await setImmediate();
  for(let i=0;i<outputs.length;i++){const state=list(b.world.asyncObjects)[outputs[i]].state;const actual=state.$==='Fulfilled'?['fulfilled',{done:state.value.done,value:b.decode(state.value.value)}]:state.$==='Rejected'?['rejected',b.decode(state.error)]:['pending'];assert.deepEqual(actual,outcomes[i],label+' pull '+i);}
  assert.deepEqual(b.iteratorIO(),s.iteratorIO(),label+' iterator IO');assert.deepEqual(b.iteratorMethods(),s.iteratorMethods(),label+' argument vectors');assert.deepEqual(b.thenIO(),s.thenIO(),label+' external then registrations');assert.deepEqual(b.asyncErrors,s.asyncErrors,label+' swallowed rejection');
  // Closed next returns a new fulfilled native Promise and never calls inner next.
  pull(args);await setImmediate();const last=list(b.world.asyncObjects)[outputs.at(-1)].state;assert.deepEqual(last,{$:'Fulfilled',value:{$:'StepResult',done:true,value:{$:'Undefined'}}},label+' closed pull');assert.deepEqual(outcomes.at(-1),['fulfilled',{done:true,value:undefined}],label);assert.deepEqual(b.iteratorMethods(),s.iteratorMethods(),label+' no inner call after close');
  b.dispose();s.dispose();await setImmediate();count++;
 }
 console.log(`${count} actual from wrapped-iterator method controls compare concurrent pending pulls, cancellation races, repeated/owner close, rejected returns, native Promise outcomes and exact argument vectors. These are private protocol controls, not public histories.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
