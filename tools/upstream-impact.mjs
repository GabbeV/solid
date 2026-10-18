// Read-only comparison. A matching fingerprint is not a correspondence proof.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {scanTree} from './source-inventory.mjs';
import {readDeviations} from './deviations.mjs';
const root=fileURLToPath(new URL('../',import.meta.url));
function sourceDir(candidate) {
  for(const dir of [path.join(candidate,'packages/signals/src'),path.join(candidate,'src'),candidate]) {
    if(fs.existsSync(path.join(dir,'core/core.ts')) && fs.existsSync(path.join(dir,'index.ts')))return dir;
  }
  throw new Error('Expected a Solid checkout, signals package, or signals src directory.');
}
function units(file) {
  const result=new Map();
  for(const unit of file?.units??[]) {
    const list=result.get(unit.key)??[];list.push(unit);result.set(unit.key,list);
  }
  return result;
}
const fingerprint=list=>JSON.stringify(list.map(u=>u.sha256));
const range=list=>list.map(u=>({start:u.start,end:u.end}));
export function compare(candidate) {
  const baseline=JSON.parse(fs.readFileSync(path.join(root,'upstream/inventory.json')));
  const correspondence=JSON.parse(fs.readFileSync(path.join(root,'upstream/correspondence.json'))).mappings;
  const pins=JSON.parse(fs.readFileSync(path.join(root,'upstream/pins.json')));
  const dir=sourceDir(path.resolve(candidate));
  const oldFiles=new Map(baseline.files.map(f=>[f.file,f]));
  const newFiles=new Map(scanTree(dir,correspondence).map(f=>[f.file,f]));
  const changed=[];
  for(const file of [...new Set([...oldFiles.keys(),...newFiles.keys()])].sort()) {
    const before=oldFiles.get(file),after=newFiles.get(file);
    if(before?.sha256===after?.sha256)continue;
    const oldUnits=units(before),newUnits=units(after),changedUnits=[];
    for(const key of [...new Set([...oldUnits.keys(),...newUnits.keys()])].sort()) {
      const a=oldUnits.get(key)??[],b=newUnits.get(key)??[];
      if(fingerprint(a)===fingerprint(b))continue;
      const unit=key.slice(file.length+1),mapping=correspondence[key];
      changedUnits.push({key,change:!a.length?'added':!b.length?'removed':'changed',before:range(a),after:range(b),
        bend:mapping?.bend??null,mappingStatus:mapping?.status??'open',
        branchReview:{before:(before?.branches??[]).filter(x=>x.unit===unit).length,after:(after?.branches??[]).filter(x=>x.unit===unit).length,status:'required'}});
    }
    changed.push({file,change:!before?'added':!after?'removed':'changed',excludedStore:file.startsWith('store/'),
      beforeSha256:before?.sha256??null,afterSha256:after?.sha256??null,changedUnits,
      fileReview:'Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.',
      existingMappings:(before?.units??[]).filter(u=>u.mapping).map(u=>({key:u.key,bend:u.mapping.bend}))});
  }
  return {baseline:pins.solid,candidate:{path:dir,kind:'local working-tree snapshot; commit and cleanliness not asserted'},
    scope:'signals src/**/*.ts; separately review tests, documentation, build conditions and initialization reachability',
    evidence:changed.length?'Correspondence and TS parity require review/revalidation. Existing Bend proofs remain about their pinned program, not this candidate.':'No source-file drift detected; this is not a semantic equivalence claim.',
    deviationsToReview:readDeviations().active.map(e=>({id:e.id,title:e.title,status:e.status,source:e.source,upstream:e.upstream,retirement:e.retirement})),
    changedFiles:changed};
}
function markdown(r) {
  const lines=[`Baseline: Solid ${r.baseline.version} (${r.baseline.commit}).`,`Candidate: ${r.candidate.path}`,`Scope: ${r.scope}`,r.evidence,''];
  for(const d of r.deviationsToReview)lines.push(`Review deviation ${d.id} (${d.status}): ${d.title}; retire when: ${d.retirement.trigger}`);
  if(!r.changedFiles.length)return lines.concat('No changed source files.').join('\n');
  for(const f of r.changedFiles) {
    lines.push(`${f.change}: ${f.file}${f.excludedStore?' [store excluded; shared-hook review still required]':''}`);
    for(const u of f.changedUnits)lines.push(`  ${u.change}: ${u.key} -> ${u.bend??'[unported]'}; branch review required`);
    if(!f.changedUnits.length)lines.push('  No indexed function-text change; inspect file-level changes.');
    lines.push('  '+f.fileReview);
  }
  return lines.join('\n');
}
if(process.argv[1] && import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href) {
  const args=process.argv.slice(2),json=args.includes('--json'),paths=args.filter(x=>x!=='--json');
  try {
    if(paths.length!==1)throw new Error('Usage: npm run upstream:impact -- PATH [--json]');
    const report=compare(paths[0]);console.log(json?JSON.stringify(report,null,2):markdown(report));
  } catch(e) {console.error(e.message);process.exitCode=1;}
}
