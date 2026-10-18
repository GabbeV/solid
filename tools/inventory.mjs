import {scanTree} from './source-inventory.mjs';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));
const base=path.join(root,'upstream/solid/packages/signals/src');
const map=JSON.parse(fs.readFileSync(path.join(root,'upstream/correspondence.json'))).mappings;
const records=scanTree(base,map);

for(const key of Object.keys(map))if(!records.some(r=>r.units.some(u=>u.key===key)))throw new Error('Correspondence target not found: '+key);
const output={schemaVersion:1,scope:'All signals source files; stores excluded, all other unported units and branches remain open.',files:records};
const text=JSON.stringify(output,null,2)+'\n';
const dest=path.join(root,'upstream/inventory.json');
if(process.argv.includes('--check')) {
  if(fs.readFileSync(dest,'utf8')!==text)throw new Error('Source inventory is stale: run node tools/inventory.mjs');
  console.log('Source-unit and branch inventory is current.');
} else {fs.writeFileSync(dest,text);console.log(`Inventoried ${records.length} source files; every unreviewed branch remains open.`);}
