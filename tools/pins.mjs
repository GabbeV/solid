import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));
export const hash=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
export function files(dir) {
  return fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?files(path.join(dir,e.name)):[path.join(dir,e.name)]).sort();
}
const snapshots=files(path.join(root,'upstream')).filter(p=>!p.endsWith('pins.json')&&!p.endsWith('inventory.json')&&!p.endsWith('correspondence.json'));
const target=path.join(root,'upstream/pins.json');
if(process.argv.includes('--record')) {
  if(fs.existsSync(target))throw new Error('Refusing to overwrite existing source pins; repins need explicit review.');
  const data={solid:{repository:'https://github.com/solidjs/solid',commit:'d2ad8b288886a5c7171e6746ccc019ad1d08d8ab',branch:'next',version:'2.0.0-rc.15'},bend:{repository:'https://github.com/bendlang/bend',commit:'e5527d5be0c441d00f1f7d2fb61eb464fa478e5c',version:'2.0.37'},lean:{version:'4.34.0',linuxArchiveSha256:hash(fs.readFileSync('/workspace/scratch/lean.tar.zst')),url:'https://github.com/leanprover/lean4/releases/download/v4.34.0/lean-4.34.0-linux.tar.zst'},referenceBuild:{entry:'packages/signals/src/index.ts',defines:{__DEV__:false,__OBSERVE__:false,__TEST__:false},bundler:'esbuild',storeModuleInitialization:'Preserved when reachable from full public index; comparisons use no store APIs.'},files:Object.fromEntries(snapshots.map(p=>[path.relative(root,p),hash(fs.readFileSync(p))]))};
  fs.writeFileSync(target,JSON.stringify(data,null,2)+'\n');
} else {
  const pins=JSON.parse(fs.readFileSync(target));
  for(const [file,want] of Object.entries(pins.files)) {
    if(hash(fs.readFileSync(path.join(root,file)))!==want)throw new Error('Upstream snapshot drift: '+file);
  }
  const actual=new Set(snapshots.map(p=>path.relative(root,p)));
  for(const file of actual)if(!Object.hasOwn(pins.files,file))throw new Error('Unpinned upstream file: '+file);
  console.log('Pinned upstream snapshots match their recorded hashes.');
}
