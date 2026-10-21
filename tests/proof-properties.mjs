// Kernel checks for quantified semantic properties. Mutations use their actual
// copied Bend sources, not the emitted JS object or an unchanged proof fixture.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-semantic-properties-'));
try{
 const sourceRoot=process.env.BEND_EMIT_FILE?path.dirname(process.env.BEND_EMIT_FILE):root;
 for(const name of ['runtime','representation','observation'])fs.cpSync(path.join(sourceRoot,name),path.join(dir,name),{recursive:true});
 fs.mkdirSync(path.join(dir,'proof'));
 for(const name of ['arena','publication','publication-stage','extension-laws','cleanup-laws','read-policy','paths','chain','memo-driver','memo-states','memo-cuts','memo-staging'])fs.copyFileSync(path.join(root,'proof',name+'.bend'),path.join(dir,'proof',name+'.bend'));
 const selected=process.env.BEND_PROOF_MODULE;
 const modules=['publication','publication-stage','extension-laws','cleanup-laws','read-policy','memo-staging'];
 if(selected&&!modules.includes(selected))throw new Error('Unknown proof module: '+selected);
 for(const name of selected?[selected]:modules){
  const result=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts',path.join(dir,'proof',name+'.bend'),'--verdict'],{cwd:root,env:{...process.env,PATH:path.join(root,'.tools/lean/bin')+path.delimiter+process.env.PATH},encoding:'utf8',maxBuffer:1024*1024,timeout:90000});
  if(result.error||result.signal||result.status===null||/infrastructure|out of (?:fuel|memory)|INTERNAL PANIC/.test(result.stdout+'\n'+result.stderr))throw new Error(name+' proof check resource/infrastructure failure: '+(result.error?.message??result.signal??'resource limit')+'\n'+result.stdout.slice(-1000)+'\n'+result.stderr.slice(-1000));
  assert.equal(result.status,0,name+' kernel properties: '+result.stdout+'\n'+result.stderr);
  assert.ok(result.stdout.includes('ALL PROOFS CHECK'),name+' needs the independent verdict');
 }
 console.log('Quantified publication, extension allocation, cleanup capture/order, read policy and conditional memo-drain properties pass the independent kernel.');
}finally{fs.rmSync(dir,{recursive:true,force:true});}
