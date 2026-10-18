import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));
const live=new Set(['active','reported','fix-landed']);
const statuses=new Set(['proposed',...live,'retired']);
const commit=x=>typeof x==='string' && /^[a-f0-9]{40}$/.test(x);
const text=x=>typeof x==='string' && x.trim().length>0;
const texts=x=>Array.isArray(x) && x.length>0 && x.every(text);
export function validate(data, {pin,exists=p=>fs.existsSync(path.join(root,p))}) {
  function need(ok,message) {if(!ok)throw new Error('Deviation register: '+message);}
  need(data?.schemaVersion===1 && Array.isArray(data.entries),'expected schemaVersion 1 and entries array');
  const ids=new Set();
  for(const e of data.entries) {
    need(/^DEV-\d{4,}$/.test(e.id??'') && !ids.has(e.id),'invalid or duplicate ID');ids.add(e.id);
    const label=m=>`${e.id}: ${m}`;
    need(text(e.title) && ['upstream-workaround','port-workaround'].includes(e.kind) && statuses.has(e.status),label('title, kind and valid status required'));
    if(e.status==='proposed')continue;
    need(commit(e.source?.commit) && texts(e.source?.units) && text(e.source?.behavior),label('original source commit, units and behavior required'));
    need(texts(e.change?.bendFiles) && ['behavior','reason','scope'].every(k=>text(e.change?.[k])),label('changed behavior, files, reason and scope required'));
    need(['reproFile','baselineResult','deviatingResult','classification','uncertainty'].every(k=>text(e.evidence?.[k])),label('reproducer, both expected results, classification and uncertainty required'));
    need(['under-investigation','suspected-upstream-bug','confirmed-upstream-bug','port-limitation','ambiguous-contract','intentional-source-behavior'].includes(e.evidence.classification),label('unknown evidence classification'));
    need(texts(e.proofImpact),label('explicit proof impact required (use none if none)'));
    need(text(e.retirement?.trigger) && texts(e.retirement?.checks),label('retirement trigger and checks required'));
    need(e.upstream && ['issue','fix','fixCommit'].every(k=>Object.hasOwn(e.upstream,k)),label('upstream fields must be explicit; use null when unknown'));
    for(const k of ['issue','fix'])need(e.upstream[k]===null || (text(e.upstream[k]) && e.upstream[k].startsWith('https://')),label('invalid upstream '+k));
    need(e.upstream.fixCommit===null || commit(e.upstream.fixCommit),label('invalid fix commit'));
    if(live.has(e.status)) {
      need(e.lastReviewedPin===pin,label('review this deviation against the current Solid pin'));
      need(exists(e.evidence.reproFile) && e.change.bendFiles.every(exists),label('active reproducer or affected Bend file is missing'));
    }
    if(e.status==='reported')need(text(e.upstream.issue),label('reported status requires an issue link'));
    if(e.status==='fix-landed')need(commit(e.upstream.fixCommit),label('fix-landed status requires the landed commit'));
    if(e.status==='retired')need(text(e.retirement.result),label('retain retirement result/pin and evidence'));
  }
  return data.entries.filter(e=>live.has(e.status));
}
export function readDeviations() {
  const data=JSON.parse(fs.readFileSync(path.join(root,'tracking/deviations.json')));
  const pins=JSON.parse(fs.readFileSync(path.join(root,'upstream/pins.json')));
  return {data,active:validate(data,{pin:pins.solid.commit})};
}
if(process.argv[1] && import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href) {
  try {const {active}=readDeviations();console.log(`Deviation register is valid; ${active.length} active entries.`);}
  catch(e) {console.error(e.message);process.exitCode=1;}
}
