import ts from 'typescript';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));
const base=path.join(root,'upstream/solid/packages/signals/src');
const map=JSON.parse(fs.readFileSync(path.join(root,'upstream/correspondence.json'))).mappings;
const files=dir=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?files(path.join(dir,e.name)):[path.join(dir,e.name)]).sort();
const sha=s=>crypto.createHash('sha256').update(s).digest('hex');
const records=[];
for(const absolute of files(base).filter(p=>p.endsWith('.ts'))) {
  const file=path.relative(base,absolute),source=fs.readFileSync(absolute,'utf8');
  const ast=ts.createSourceFile(file,source,ts.ScriptTarget.Latest,true);
  const line=n=>1+ast.getLineAndCharacterOfPosition(n.getStart(ast)).line;
  const end=n=>1+ast.getLineAndCharacterOfPosition(n.getEnd()).line;
  const excluded=file.startsWith('store/');const units=[],branches=[];
  const record={file,sha256:sha(source),lines:source.split('\n').length-1,status:excluded?'excluded-store':'open',units,branches};
  function walk(n,scope='module') {
    let inner=scope;
    if(ts.isFunctionDeclaration(n) || ts.isMethodDeclaration(n) || ts.isGetAccessor(n) || ts.isSetAccessor(n)) {
      let name=n.name?.getText(ast)??'<anonymous>';
      if(ts.isClassDeclaration(n.parent))name=(n.parent.name?.text??'<class>')+'.'+name;
      inner=name;const key=file+':'+name;
      units.push({key,start:line(n),end:end(n),sha256:sha(n.getText(ast)),status:excluded?'excluded-store':map[key]?.status??'open',mapping:map[key]??null});
    }
    if(ts.isIfStatement(n)||ts.isConditionalExpression(n)||ts.isCaseClause(n)||ts.isWhileStatement(n)||ts.isForStatement(n)||ts.isForOfStatement(n)) {
      const guard=(n.expression??n.condition)?.getText(ast)??'<loop>';
      branches.push({unit:scope,start:line(n),end:end(n),kind:ts.SyntaxKind[n.kind],guard:guard.slice(0,300),status:excluded?'excluded-store':'open-branch-review',sharedStoreHint:/CONFIG_SLOT_NODE|slotUnobserved|store[A-Z]|_slot/.test(guard)});
    }
    ts.forEachChild(n,c=>walk(c,inner));
  }
  walk(ast);records.push(record);
}
for(const key of Object.keys(map))if(!records.some(r=>r.units.some(u=>u.key===key)))throw new Error('Correspondence target not found: '+key);
const output={schemaVersion:1,scope:'All signals source files; stores excluded, all other unported units and branches remain open.',files:records};
const text=JSON.stringify(output,null,2)+'\n';
const dest=path.join(root,'upstream/inventory.json');
if(process.argv.includes('--check')) {
  if(fs.readFileSync(dest,'utf8')!==text)throw new Error('Source inventory is stale: run node tools/inventory.mjs');
  console.log('Source-unit and branch inventory is current.');
} else {fs.writeFileSync(dest,text);console.log(`Inventoried ${records.length} source files; every unreviewed branch remains open.`);}
