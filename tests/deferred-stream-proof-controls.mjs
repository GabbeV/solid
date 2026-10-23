// Finite mixed-payload controls for the universally quantified ordinary-data
// data-to-stream program. They compare every actual step, the full final Machine and native
// Solid's public API, independently of the symbolic proof-data builder.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';

const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-deferred-stream-'));
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
  const D=await compile('deferred-stream-driver');
  const P=await compile('deferred-stream-program');
  const references=new Map([[7,{item:'first'}],[19,{item:'second'}]]);
  const cases=[
    [{$:'DataUndefined'},undefined,{$:'Undefined'}],
    [{$:'DataNull'},null,{$:'Null'}],
    ...[false,true].map(value=>[{$:'DataBoolean',value},value,{$:'Boolean',b:value}]),
    ...[0,1,2**40].map(value=>[{$:'DataNatural',value},value,{$:'Number',n:value}]),
    [{$:'DataNegativeZero'},-0,{$:'NegativeZero'}],
    [{$:'DataNaN'},NaN,{$:'NotANumber'}],
    ...['','opaque','λ'].map(value=>[{$:'DataString',value},value,{$:'StringValue',s:value}]),
    ...[7,19].map(identity=>[{$:'DataReference',identity},references.get(identity),{$:'Reference',id:identity}])
  ];
  let count=0;
  for(const [initial,initialValue] of cases)for(const [next,nextValue,expected] of cases) {
    const label=JSON.stringify([initial,next]);
    let machine=D.before(initial,next);
    assert.deepEqual(machine,P.state_0(initial,next),label+' initial Machine');
    for(let i=0;i<118;i++) {
      machine=D.step(machine);
      assert.deepEqual(machine,P['state_'+(i+1)](initial,next),label+' prefix '+(i+1));
    }
    for(const budget of [118,119,160])
      assert.deepEqual(D.run(budget,initial,next),machine,label+' budget '+budget);
    assert.deepEqual(machine.values,{$:'Con',head:expected,tail:{$:'Nil'}},label+' exact payload');
    assert.equal(machine.world.fault.$,'Healthy',label+' final fault');

    const S=await import(pathToFileURL(path.join(root,'build/solid.mjs'))+'?ordinary-deferred-stream='+count);
    let set,get,dispose,opened=0,pulled=0,returned=0;
    const source={ [Symbol.asyncIterator](){
      opened++;let first=true;
      return {next(){pulled++;if(first){first=false;return {done:false,value:nextValue};}return {done:true,value:undefined};},return(){returned++;}};
    }};
    S.createRoot(stop=>{
      dispose=stop;
      const [mode,update]=S.createSignal(0,{equals:false});
      set=update;get=S.createDeferred(()=>mode()?source:initialValue,{equals:false});
    });
    assert.ok(Object.is(get(),initialValue),label+' native initial value/identity');
    set(1);S.flush();
    assert.ok(Object.is(get(),nextValue),label+' native final value/identity');
    assert.deepEqual([opened,pulled,returned],[1,2,0],label+' native iterator calls');
    dispose();S.flush();count++;
  }
  console.log(`${count} ordinary-payload deferred stream programs compare all 118 prefixes, exact final Machines at three budgets and native values/identities, including mixed types, aliasing, undefined, NaN and signed zero.`);
} finally {
  fs.rmSync(dir,{recursive:true,force:true});
}
