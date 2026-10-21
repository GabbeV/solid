// Canonical data from the actual API/core driver, not an alternate evaluator.
// Generation is untrusted: each transition and the full conditional drain law
// must pass the independent kernel for arbitrary numeric proposals and budgets.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url)),dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-memo-history-witness-'));
try{
for(const kind of ['pass','setter']){
const phase='memo-history';
const emitted=path.join(dir,phase+'-'+kind+'-driver.mjs');
const built=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','proof/memo-repeat-'+(kind==='pass'?'driver':'setter-driver')+'.bend','-o',emitted],{cwd:root,encoding:'utf8'});
if(built.status!==0)throw Error(built.stderr);
const {default:D}=await import(pathToFileURL(emitted));
const constructors=new Map();
function split(text){let depth=0,start=0,out=[];for(let i=0;i<text.length;i++){if('<({'.includes(text[i]))depth++;if('>)}'.includes(text[i]))depth--;if(text[i]===','&&depth===0){out.push(text.slice(start,i).trim());start=i+1;}}if(text.slice(start).trim())out.push(text.slice(start).trim());return out;}
for(const [file,ns]of[['representation/records.bend','R'],['runtime/core.bend','C'],['runtime/owner.bend','O'],['runtime/pending.bend','Q']]){
 let data=false,family;for(const line of fs.readFileSync(root+'/'+file,'utf8').replace(/\n    /g,' ').split('\n')){
  if(/^type .* is Data:/.test(line)){data=true;family=line.match(/^type (\w+)/)[1];continue;}if(/^[^ #\t]/.test(line))data=false;if(!data)continue;
  const m=line.match(/^  (\w+)\{(.*)\}$/);if(!m)continue;
  constructors.set(ns+'.'+family+'.'+m[1],{ns,fields:split(m[2]).map(x=>{const i=x.indexOf(':');return[x.slice(0,i).trim(),x.slice(i+1).trim()];})});
 }
}
const shared=new Map(),declarations=[];
function qualified(type,ns){
 if(['Nat','Bool','U32','String'].includes(type))return type;
 if(type.startsWith('List<'))return 'List<&2, '+qualified(split(type.slice(5,-1))[1],ns)+'>';
 return type.includes('.')?type:ns+'.'+type;
}
function intern(body,type){
 const key=type+'#'+body;if(shared.has(key))return shared.get(key);
 const name='data_'+shared.size,variables=['tick','previous','input','events','jobs'].filter(v=>new RegExp('\\b'+v+'\\b').test(body)),call=name+'('+variables.join(', ')+')';shared.set(key,call);
 declarations.push(`def ${name}(${variables.map(v=>'+'+v+': '+({events:'List<&2, R.TraceEvent>',jobs:'List<&2, R.HostJob>'}[v]??'Nat')).join(', ')}) -> ${type}:\n  ${body}\n`);return call;
}
function show(value,type,ns='R'){
 const plain=type.replace(/^\w+\./,'');
 if(plain==='Nat')return value+'n';if(plain==='U32')return String(value);if(plain==='Bool')return value?'True{}':'False{}';if(plain==='String')return JSON.stringify(value);
 if(type.startsWith('List<')){const elem=split(type.slice(5,-1))[1],items=[];while('head'in value){items.push(show(value.head,elem,ns));value=value.tail;}return intern('['+items.join(', ')+']',qualified(type,ns));}
 const family=type.includes('.')?type:ns+'.'+type;
 if(family==='R.Value'&&value.$==='Number'){
  const terms={11:'previous',12:'Nat.add(previous, 1n)',17:'input',18:'Nat.add(input, 1n)'};
  if(terms[value.n])return intern('R.Number{'+terms[value.n]+'}','R.Value');
 }
 const con=constructors.get(family+'.'+value.$);if(!con)throw Error('Unknown '+type+' '+JSON.stringify(value));
 return intern(con.ns+'.'+value.$+'{'+con.fields.map(([name,t])=>{if(value[name]===undefined)throw Error('Missing '+value.$+'.'+name+' keys '+Object.keys(value));if(family==='R.World'&&name==='events'){
    let suffix=value[name];for(let i=0;i<5;i++){if(!('head'in suffix))throw Error('Missing baseline trace');suffix=suffix.tail;}
    let term='events';while('head'in suffix){term='B.append(R.TraceEvent, '+term+', ['+show(suffix.head,'R.TraceEvent')+'])';suffix=suffix.tail;}return term;
   }
   if(family==='R.World'&&name==='hostJobs'){
    let suffix=value[name];if(!('head'in suffix))throw Error('Missing baseline job');suffix=suffix.tail;
    let term='jobs';while('head'in suffix){term='B.append(R.HostJob, '+term+', ['+show(suffix.head,'R.HostJob')+'])';suffix=suffix.tail;}return term;
   }
   if((family==='R.World'&&['clock','epoch'].includes(name))||(family==='R.Node'&&value.kind.$==='Memo'&&['time','depGen'].includes(name))||(family==='R.Link'&&value.dep!==0&&name==='gen')||(family==='R.Stamp'&&name==='value'))return value[name]===0?'tick':'Nat.add('+value[name]+'n, tick)';
   return show(value[name],t,con.ns);}).join(', ')+'}',qualified(type,ns));
}
let m,states;
if(kind==='pass'){
m=D.before(23,11,17);states=[m];
for(let i=0;i<256&&'head'in m.tasks;i++){m=D.step(m);states.push(m);}
if('head'in m.tasks)throw Error('Driver did not finish');
const steps=states.length-1;if(steps!==40||m.world.fault.$!=='Healthy')throw Error('The memo witness requires a source review after this runtime change');
}
const args='+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>',call='tick, previous, input, events, jobs';
let out=`# SHARED_DATA\n# Generalized steady-pass data from actual core.step. Untrusted generation;\n# equations must pass the original independent kernel before use.\nimport Base\nimport ../runtime/api.bend as A\nimport ../runtime/core.bend as C\nimport ../representation/base.bend as B\nimport ../representation/records.bend as R\nimport ../proof/paths.bend as P\nimport ../runtime/owner.bend as O\nimport ../runtime/pending.bend as Q\n\n`;
if(kind==='pass'){
out+=`def origin(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:\n  ${show(D.base(23,11),'World')}\n\n`;
for(let i=0;i<states.length;i++)out+=`def state_${i}(${args}) -> C.Machine:\n  ${show(states[i],'C.Machine')}\n\n`;
out+=`def finalWorld(${args}) -> R.World:\n  ${show(m.world,'World')}\n\n`;
out+=`def publication_13(${args}) ->\n  {C.publishValue(C.world(state_13(${call})), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})\n    == B.Bundle{C.world(state_14(${call})), True{}} : B.Bundle<R.World, Bool>}:\n  {==}\n`;
}else{
for(const name of ['origin','queued','slotted','stamped','inserted','scheduled'])out+=`def ${name}(${['origin','queued'].includes(name)?args.replace('+input: Nat, ',''):args}) -> R.World:\n  ${show(D[name](23,11,17),'World')}\n\n`;
}
out=out.replace('# SHARED_DATA\n','');const index=out.indexOf('def origin(');out=out.slice(0,index)+declarations.join('\n')+'\n'+out.slice(index);const target=path.join(root,'proof/'+phase+(kind==='pass'?'-states.bend':'-setter-data.bend'));
out=out.trimEnd()+'\n';
if(process.argv.includes('--check')){
 if(fs.readFileSync(target,'utf8')!==out)throw Error('Memo witness is stale; regenerate and run the independent kernel');
}else{
 fs.writeFileSync(target,out);console.log('Regenerated generalized memo '+kind+' data; run the independent kernel before trusting it.');
}
}
}finally{fs.rmSync(dir,{recursive:true,force:true});}
