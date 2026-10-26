// A reviewed conversion optimization over the unchanged pinned BendTT source.
// Build the complete Lean development, including soundness and consistency;
// never substitute an executable supplied through an unrecorded BENDTT value.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';

const root=fileURLToPath(new URL('../',import.meta.url));
const digest=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
const read=file=>fs.readFileSync(path.join(root,file));
const spec=JSON.parse(read('tools/kernel/profiles.json'));
const fail=message=>{throw new Error('Proof kernel: '+message);};
function run(bin,args,cwd){
 const r=spawnSync(bin,args,{cwd,encoding:'utf8',maxBuffer:8*1024*1024});
 if(r.status!==0)fail(bin+' failed: '+(r.error?.message??r.signal??r.status)+'\n'+r.stdout.slice(-4000)+'\n'+r.stderr.slice(-4000));
 return r.stdout+r.stderr;
}
function checkAxioms(log){
 if(/sorryAx|declaration uses 'sorry'|\berror:/.test(log))fail('Lean audit contains an admission or error');
 for(const name of spec.congruence.soundnessTheorems){
  const escaped=name.replace(/[.*+?^${}()|[\]\\]/g,'\\$&');
  const match=log.match(new RegExp("^'"+escaped+"' depends on axioms: \\[([^\\]]*)\\]$",'m'));
  if(!match)fail('Missing Lean axiom audit for '+name);
  const axioms=match[1].split(',').map(x=>x.trim()).filter(Boolean);
  if(axioms.some(x=>!spec.congruence.allowedAxioms.includes(x)))fail('Unexpected axiom in '+name+': '+axioms.join(', '));
 }
}
function cacheReceipt(dir,inputs){
 const receipt=JSON.parse(fs.readFileSync(path.join(dir,'receipt.json')));
 if(JSON.stringify(receipt.inputs)!==JSON.stringify(inputs))fail('Cached compiler inputs differ');
 for(const [file,hash]of Object.entries(receipt.outputs)){
  if(digest(fs.readFileSync(path.join(dir,file)))!==hash)fail('Cached artifact changed: '+file);
 }
 checkAxioms(fs.readFileSync(path.join(dir,'lean.log'),'utf8'));
 return receipt;
}

export function prepareKernel({profile=process.env.BEND_KERNEL_PROFILE??spec.defaultProfile}={}){
 const pins=JSON.parse(read('upstream/pins.json'));
 const source=read(spec.baselineSource);
 if(digest(source)!==spec.baselineSha256||pins.files[spec.baselineSource]!==spec.baselineSha256)fail('Pinned baseline source differs');
 if(profile==='baseline')return {profile,bin:null,evidence:{profile,sourceSha256:spec.baselineSha256,fuel:spec.congruence.fuel}};
 if(profile!==spec.congruence.profile)fail('Unknown profile '+profile);
 const patch=read(spec.congruence.patch);
 if(digest(patch)!==spec.congruence.patchSha256)fail('Optimization patch differs');
 const leanRoot=process.env.LEAN_ROOT??path.join(root,'.tools/lean');
 const lean=path.join(leanRoot,'bin/lean'),leanc=path.join(leanRoot,'bin/leanc');
 const leanVersion=run(lean,['--version'],root).trim();
 if(leanVersion.match(/^Lean \(version ([^,\s)]+)/m)?.[1]!==pins.lean.version)fail('Lean version differs from the pin');
 const inputs={baselineSha256:spec.baselineSha256,patchSha256:spec.congruence.patchSha256,sourceSha256:spec.congruence.sourceSha256,profileSha256:digest(JSON.stringify(spec.congruence)),recipeSha256:digest(fs.readFileSync(fileURLToPath(import.meta.url))),leanVersion,leanExecutableSha256:digest(fs.readFileSync(lean)),leancExecutableSha256:digest(fs.readFileSync(leanc))};
 const parent=path.join(root,'build/kernels');fs.mkdirSync(parent,{recursive:true});
 const dir=path.join(parent,profile+'-'+digest(JSON.stringify(inputs)).slice(0,24));
 if(!fs.existsSync(dir)){
  const temp=fs.mkdtempSync(path.join(parent,'.build-'));
  try{
   fs.writeFileSync(path.join(temp,'bendtt.lean'),source);
   run('patch',['--batch','--fuzz=0','-p1','-i',path.join(root,spec.congruence.patch)],temp);
   const optimized=fs.readFileSync(path.join(temp,'bendtt.lean'));
   if(digest(optimized)!==spec.congruence.sourceSha256)fail('Patched source differs');
   if(!optimized.toString().includes('def FUEL : Nat := '+spec.congruence.fuel))fail('Kernel reduction budget differs');
   const audit=optimized.toString()+'\n'+spec.congruence.soundnessTheorems.map(name=>'#print axioms '+name).join('\n')+'\n';
   fs.writeFileSync(path.join(temp,'audit.lean'),audit);
   const log=run(lean,['audit.lean'],temp);checkAxioms(log);
   fs.writeFileSync(path.join(temp,'lean.log'),log);
   const compiled=run(lean,['-c','bendtt.c','bendtt.lean'],temp);
   if(/sorryAx|declaration uses 'sorry'|\berror:/.test(compiled))fail('Compiled Lean source contains an admission or error');
   fs.writeFileSync(path.join(temp,'compile.log'),compiled);
   const linked=run(leanc,['-O3','-DNDEBUG','bendtt.c','-o','bendtt'],temp);
   fs.writeFileSync(path.join(temp,'link.log'),linked);
   const outputs=Object.fromEntries(['bendtt.lean','audit.lean','lean.log','compile.log','link.log','bendtt'].map(file=>[file,digest(fs.readFileSync(path.join(temp,file)))]));
   fs.writeFileSync(path.join(temp,'receipt.json'),JSON.stringify({schemaVersion:1,profile,inputs,outputs,allLeanTheoremsChecked:true,auditedTheorems:spec.congruence.soundnessTheorems,allowedAxioms:spec.congruence.allowedAxioms,fuel:spec.congruence.fuel},null,2)+'\n');
   try{fs.renameSync(temp,dir);}catch(error){if(!fs.existsSync(dir))throw error;}
  }finally{fs.rmSync(temp,{recursive:true,force:true});}
 }
 const receipt=cacheReceipt(dir,inputs);
 return {profile,bin:path.join(dir,'bendtt'),dir,evidence:receipt};
}

export function kernelEnvironment(base,kernel){
 const env={...base};delete env.BENDTT;
 if(kernel.bin)env.BENDTT=kernel.bin;
 return env;
}

export function assertKernelUnchanged(kernel){
 if(kernel.dir)cacheReceipt(kernel.dir,kernel.evidence.inputs);
}

if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url)){
 const kernel=prepareKernel({profile:process.argv[2]??undefined});
 console.log(JSON.stringify({bin:kernel.bin,...kernel.evidence},null,2));
}
