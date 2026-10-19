import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import vm from 'node:vm';
import {build} from 'esbuild';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-error-probe-'));
const text=s=>typeof s==='string'?s:(()=>{let result='';while('head'in s){result+=String.fromCodePoint(s.head);s=s.tail;}return result;})();
try{
  const emitted=path.join(dir,'error.mjs');
  const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','tests/probes/error.bend','-o',emitted],{cwd:root,encoding:'utf8'});
  assert.equal(compile.status,0,compile.stderr);const {default:B}=await import(pathToFileURL(emitted));
  const bundle=await build({stdin:{contents:"export {StatusError,NotReadyError,TimeoutError,unwrapStatusError} from './core/error.ts';",resolveDir:path.join(root,'upstream/solid/packages/signals/src'),loader:'ts'},bundle:true,write:false,platform:'node',format:'esm',define:{__DEV__:'false',__OBSERVE__:'false',__TEST__:'false'}});
  const ref=path.join(dir,'solid.mjs');fs.writeFileSync(ref,bundle.outputFiles[0].text);const S=await import(pathToFileURL(ref));
  const rows=[[0,0,'','',true],[1,0,'','',true],[2,0,'','',true],[2,1,'','',true],[4,0,'','',true],[6,0,'','',true],[7,0,'','',true],[9,0,'','',true],[10,0,'','',true]];
  for(const n of [0,1,9,10,99,100,1000,2**32-1,2**48-1])rows.push([3,n,'','',true]);
  for(const message of ['','99','å😀','Error: already prefixed'])rows.push([5,0,message,'',true],[8,0,'',message,true]);
  for(const native of [false,true])for(const name of ['','Error','TypeError','AbortError'])for(const message of ['','bad','å😀'])rows.push([11,0,name,message,native]);
  const ForeignError=vm.runInNewContext('Error');let count=0;
  for(const args of rows){
    const [kind,n,str,message,native]=args;let original;
    if(kind===0)original=undefined;
    else if(kind===1)original=null;
    else if(kind===2)original=!!n;
    else if(kind===3)original=n;
    else if(kind===4)original=NaN;
    else if(kind===5)original=str;
    else if(kind===6)original={ref:1};
    else if(kind===7)original={then(){}};
    else if(kind===8){original=new S.StatusError(7,99);original.message=message;}
    else if(kind===9)original=new S.NotReadyError(7);
    else if(kind===10)original=new S.TimeoutError();
    else{original=native?new Error(message):new ForeignError(message);original.name=str;}
    const expected=new S.StatusError(3,original),actual=B.wrap(...args);
    assert.equal(text(actual.message),expected.message,JSON.stringify(args));
    assert.equal(actual.source,expected.source);assert.equal(actual.identity,2);
    assert.equal(expected.cause,original);assert.notEqual(expected,original);
    const unwrapped=B.unwrapped(...args),expectedUnwrapped=S.unwrapStatusError(original);
    assert.equal(S.unwrapStatusError(expected),original,'unwrap exactly one layer');
    if(kind===8){assert.equal(unwrapped.n,expectedUnwrapped);assert.equal(actual.cause.identity,1);assert.equal(text(actual.cause.message),message);}
    else{assert.equal(expectedUnwrapped,original);assert.deepEqual(unwrapped,actual.cause);}
    count++;
  }
  console.log(`${count} actual StatusError constructor/unwrap comparisons match captured messages, primitives/numeric bounds, wrappers, NotReady/Timeout errors and native/foreign Error prototype branches.`);
}finally{fs.rmSync(dir,{recursive:true,force:true});}
