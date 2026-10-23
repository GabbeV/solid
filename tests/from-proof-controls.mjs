// Finite controls independently compare every constructor/read/dispose prefix.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';

const root=fileURLToPath(new URL('../',import.meta.url));
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-from-lifecycle-'));
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
  const D=await compile('from-driver');
  const P=await compile('from-program');
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
  const O=await compile('from-outcome');
  let count=0;
  for(const [input,value,expected] of cases) {
    const label=JSON.stringify(input);
    let machine=D.before(input);
    assert.deepEqual(machine,P.state_0(input),label+' initial Machine');
    for(let i=0;i<120;i++) {
      machine=D.step(machine);
      assert.deepEqual(machine,P['state_'+(i+1)](input),label+' prefix '+(i+1));
    }
    for(const budget of [120,121,180])
      assert.deepEqual(D.run(budget,input),machine,label+' budget '+budget);
    assert.deepEqual(O.outcome(machine),{$:'Outcome',value:{$:'Present',value:expected},cleanups:1,fault:{$:'Healthy'}},label+' exact value/cleanup/fault');
    const S=await import(pathToFileURL(path.join(root,'build/solid.mjs'))+'?from-program='+count);
    let stop,cleaned=0;
    const get=S.createRoot(dispose=>{
      stop=dispose;
      return S.createMemo(()=>S.from(next=>{next(value);return ()=>{cleaned++;};}),{equals:false});
    });
    const result=[get(),stop(),S.flush()];
    assert.ok(Object.is(result[0],value),label+' native value/identity');
    assert.deepEqual(result.slice(1),[undefined,undefined],label+' native disposal/flush values');
    assert.equal(cleaned,1,label+' native unsubscribe');
    await new Promise(resolve=>setImmediate(resolve));
    assert.equal(cleaned,1,label+' native queued jobs do not unsubscribe twice');
    count++;
  }
  console.log(`${count} ordinary-payload from lifecycles compare all 120 prefixes, exact final Machines at three budgets, and native values/identities/once-only cleanup.`);
} finally {
  fs.rmSync(dir,{recursive:true,force:true});
}
