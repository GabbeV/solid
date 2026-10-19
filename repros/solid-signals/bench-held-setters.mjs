import {spawnSync} from 'node:child_process';
import {writeFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {resolve} from 'node:path';

const [output,...specs]=process.argv.slice(2);
if(!output||specs.length<2)throw new Error('Usage: node bench-held-setters.mjs OUTPUT_JSON LABEL=MODULE LABEL=MODULE [...]');
const entries=Object.fromEntries(specs.map(s=>{
 const at=s.indexOf('=');if(at<1)throw new Error('Expected LABEL=MODULE');
 return [s.slice(0,at),resolve(s.slice(at+1))];
}));
const names=Object.keys(entries);
const cases=process.env.BENCH_CASES?.split(',')??[
 'held/value/staged','held/updater/staged','held/repeat/staged',
 'plain/value/staged','plain/updater/staged','memo/value/staged','memo/updater/staged',
 'plain/value/flush','plain/updater/flush','memo/value/flush','memo/updater/flush'
];
const cpu=process.env.BENCH_CPU;
const worker=fileURLToPath(new URL('./bench-held-setters-worker.mjs',import.meta.url));
const result={node:process.version,v8:process.versions.v8,platform:process.platform,arch:process.arch,cpuAffinity:cpu??null,entries,claim:'Fresh Node process per variant/case; seven samples after three warmups. Variant order rotates per case. Local microbenchmarks, not application performance guarantees.',rows:[]};
for(let i=0;i<cases.length;i++){
 const ordered=names.slice(i%names.length).concat(names.slice(0,i%names.length));
 for(const name of ordered){
  const args=[worker,entries[name],cases[i]];
  const child=cpu===undefined
   ?spawnSync(process.execPath,args,{encoding:'utf8'})
   :spawnSync('taskset',['-c',cpu,process.execPath,...args],{encoding:'utf8'});
  if(child.status!==0)throw new Error(child.stderr||child.stdout||String(child.error));
  const row={variant:name,...JSON.parse(child.stdout)};result.rows.push(row);
  console.log(JSON.stringify({variant:name,test:row.test,medianMs:row.median}));
  writeFileSync(output,JSON.stringify(result,null,2)+'\n');
 }
}
