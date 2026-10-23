// Finite native controls supplement the arbitrary-R.Value kernel families.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';

const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-from-value-controls-'));
try {
  const source=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
  for(const folder of ['runtime','representation','observation'])
    fs.cpSync(path.join(source,folder),path.join(dir,folder),{recursive:true});
  fs.cpSync(path.join(root,'proof'),path.join(dir,'proof'),{recursive:true});
  async function compile(name) {
    const output=path.join(dir,name+'.mjs');
    const built=spawnSync(path.join(root,'node_modules/.bin/bun'),
      ['upstream/bend/bend2/main.ts',path.join(dir,'proof',name+'.bend'),'-o',output],
      {cwd:root,encoding:'utf8',maxBuffer:1024*1024});
    assert.equal(built.status,0,built.stderr);
    return (await import(pathToFileURL(output))).default;
  }
  const references=new Map([[7,{item:'first'}],[19,{item:'second'}]]);
  const ordinary=[
    ['undefined',undefined,{$:'Undefined'}],['null',null,{$:'Null'}],
    ...[false,true].map(value=>['boolean',value,{$:'Boolean',b:value}]),
    ...[0,1,2**40].map(value=>['natural',value,{$:'Number',n:value}]),
    ['negative-zero',-0,{$:'NegativeZero'}],['NaN',NaN,{$:'NotANumber'}],
    ...['','opaque','λ'].map(value=>['string',value,{$:'StringValue',s:value}]),
    ...[7,19].map(identity=>['reference',references.get(identity),{$:'Reference',id:identity}])
  ];
  let count=0,prefixes=0;
  for(const wrapped of[false,true]){
    const D=await compile(wrapped?'from-iterable-value-driver':'from-value-driver');
    const P=await compile(wrapped?'from-iterable-value-program':'from-value-program');
    const O=await compile(wrapped?'from-iterable-outcome':'from-outcome');
    const steps=wrapped?84:120;
    const cases=[...ordinary,['empty-function',null,{$:'ProgramReference',callback:0}],
      ...(!wrapped?[['subscribe-function',null,{$:'ProgramReference',callback:1}],['unsubscribe-function',null,{$:'ProgramReference',callback:2}]]:[]),
      ['disposer-function',null,{$:'RootDisposerReference',owner:2}],
      ['self-iterable',null,{$:'AsyncValue',identity:wrapped?2:1}]];
    for(const [kind,ordinaryValue,input]of cases){
      const label=JSON.stringify([wrapped,kind,input]);let machine=D.before(input);
      assert.deepEqual(machine,P.state_0(input),label+' initial Machine');
      for(let i=0;i<steps;i++){machine=D.step(machine);assert.deepEqual(machine,P['state_'+(i+1)](input),label+' prefix '+i);prefixes++;}
      for(const budget of[steps,steps+1,steps+60])assert.deepEqual(D.run(budget,input),machine,label+' sufficient budget '+budget);
      const outcome=O.outcome(machine);assert.deepEqual(outcome.value,{$:'Present',value:input},label+' exact represented value');assert.equal(outcome.fault.$,'Healthy',label);
      if(wrapped){assert.equal(outcome.returns,1);assert.equal(outcome.closed,true);assert.equal(outcome.pending.$,'Nil');assert.equal(outcome.inner.$,'Unresolved');assert.deepEqual(outcome.pull,{$:'Fulfilled',value:{$:'StepResult',done:true,value:{$:'Undefined'}}});}else assert.equal(outcome.cleanups,1);
      const S=await import(pathToFileURL(path.join(root,'build/solid.mjs'))+'?from-value-control='+count);
      let get,stop,source,cleaned=0,pulled=0,called=0;
      const empty=()=>{called++;return 99;},cleanup=()=>{cleaned++;};
      const value=()=>kind==='empty-function'?empty:kind==='subscribe-function'?subscribe:kind==='unsubscribe-function'?cleanup:kind==='accessor-function'?get:kind==='disposer-function'?stop:kind==='self-iterable'?source:ordinaryValue;
      function subscribe(next){next(value());return cleanup;}
      const pending=new Promise(()=>{});
      if(wrapped)source={ [Symbol.asyncIterator](){return {next(){pulled++;return pulled===1?{done:false,value:value()}:pending;},return:cleanup};} };
      get=S.createRoot(dispose=>{stop=dispose;return S.createMemo(()=>wrapped?S.from(source):(source=S.from(subscribe)),{equals:false});});
      const result=[get(),stop(),S.flush()];
      assert.ok(Object.is(result[0],value()),label+' native payload/identity');assert.deepEqual(result.slice(1),[undefined,undefined]);assert.equal(cleaned,1,label+' native cleanup');assert.equal(called,0,label+' data function not invoked');if(wrapped)assert.equal(pulled,2);
      await new Promise(resolve=>setImmediate(resolve));assert.equal(cleaned,1);assert.equal(called,0);count++;
    }
  }
  console.log(`${count} arbitrary-value from lifecycle controls compare ${prefixes} actual prefixes, three budgets, native value identities, function-as-data preservation and once-only cleanup/cancellation. Kernel quantification is over every R.Value; arbitrary arena-token validity and arbitrary async histories are separate.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
