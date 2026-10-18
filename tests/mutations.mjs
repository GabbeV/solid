import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));
const mutations=[
  ['lost subscriber wake','runtime/scheduler.bend','B.schedule(insertSubs(w, id))','B.schedule(w)'],
  ['leaked staging','runtime/core.bend','_ => R.Node.value(n), _ => B.current(n))','_ => B.current(n), _ => B.current(n))'],
  ['untrack subscribes','runtime/core.bend','Machine{R.World.with_tracking(w, False{}), Evaluate{body, prev}','Machine{R.World.with_tracking(w, True{}), Evaluate{body, prev}'],
  ['wrong render result','runtime/core.bend','T.setText(w, R.Node.target(n), R.Node.value(n))','T.setText(w, R.Node.target(n), R.Undefined{})'],
];
let caught=0;
for(const [name,file,before,after] of mutations) {
  const dir=await fs.mkdtemp(path.join(os.tmpdir(),'bend-signals-mutation-'));
  try {
    for(const d of ['runtime','representation','observation'])await fs.cp(path.join(root,d),path.join(dir,d),{recursive:true});
    const p=path.join(dir,file),text=await fs.readFile(p,'utf8');
    if(!text.includes(before))throw new Error('Stale mutation '+name);
    await fs.writeFile(p,text.replace(before,after));
    const emit=path.join(dir,'runtime.mjs');
    const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),[path.join(root,'upstream/bend/bend2/main.ts'),path.join(dir,'runtime/api.bend'),'-o',emit],{encoding:'utf8'});
    if(compile.status!==0)throw new Error('Mutation did not compile: '+name+'\n'+compile.stderr.slice(-3000));
    const run=spawnSync(process.execPath,['tests/differential.mjs'],{cwd:root,env:{...process.env,BEND_EMIT_FILE:emit},encoding:'utf8',maxBuffer:1024*1024});
    if(run.status===0)throw new Error('Test oracle accepted mutation: '+name);
    if(!run.stderr.includes('AssertionError'))throw new Error('Mutation failed for an unrelated reason: '+name+'\n'+run.stderr.slice(-3000));
    caught++;console.log('Rejected mutation: '+name);
  } finally {await fs.rm(dir,{recursive:true,force:true});}
}
console.log(`${caught} incorrect implementations rejected by differential assertions.`);
