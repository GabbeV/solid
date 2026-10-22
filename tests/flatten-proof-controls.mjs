// Finite native/canonical/public controls, separate from the quantified proof.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {BendRuntime} from '../host/bend.mjs';
import * as S from '../build/solid.mjs';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-flatten-controls-'));
try{
 let sourceRoot=root;
 if(process.env.BEND_EMIT_FILE){
  sourceRoot=dir;
  for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(path.dirname(process.env.BEND_EMIT_FILE),name),path.join(dir,name),{recursive:true});
  fs.cpSync(path.join(root,'proof'),path.join(dir,'proof'),{recursive:true});
 }
 const output=path.join(dir,'flatten-natural.mjs'),built=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(sourceRoot,'proof','flatten-natural.bend'),'-o',output],{cwd:root,encoding:'utf8'});
 assert.equal(built.status,0,built.stderr);const M=(await import(pathToFileURL(output))).default;
 const values=[0,1,2,17,255,65535,2**32+3,2**48-2],lit=lit=>({lit}),arr=(...array)=>({array});
 for(const first of values)for(const second of values){
  const extra=[0,1,128,2048][(first+second)%4],b=new BendRuntime({fuel:128+extra}),result=b.evaluate({flatten:{children:arr(lit(first),arr(lit(second),lit(false))),skipNonRendered:true}});
  const canonical=M.programWithBudget(first,second,extra);assert.deepEqual(canonical,M.expected(first,second),'canonical exact machine');
  assert.deepEqual(b.world,canonical.world,'actual public expression reaches the same complete World');
  assert.deepEqual(result,S.flatten([first,[second,false]],{skipNonRendered:true}),'actual pinned native result');
  assert.deepEqual(result,[first,second]);
 }
 console.log('64 finite children-flatten controls match the real public expression, exact canonical machine/World with four sufficient budgets and pinned native values. The arbitrary-natural-payload proof is checked independently by the kernel.');
}finally{fs.rmSync(dir,{recursive:true,force:true});}
