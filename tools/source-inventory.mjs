import ts from 'typescript';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const files=dir=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?files(path.join(dir,e.name)):[path.join(dir,e.name)]).sort();
export const sha=s=>crypto.createHash('sha256').update(s).digest('hex');
export function scanSource(file, source, map={}) {
  const ast=ts.createSourceFile(file,source,ts.ScriptTarget.Latest,true);
  const line=n=>1+ast.getLineAndCharacterOfPosition(n.getStart(ast)).line;
  const end=n=>1+ast.getLineAndCharacterOfPosition(n.getEnd()).line;
  const excluded=file.startsWith('store/');const units=[],branches=[];
  const record={file,sha256:sha(source),lines:source.split('\n').length-1,status:excluded?'excluded-store':'open',units,branches};
  function walk(n,scope='module') {
    let inner=scope;
    const namedClosure=ts.isVariableDeclaration(n)&&ts.isIdentifier(n.name)&&n.initializer&&(ts.isArrowFunction(n.initializer)||ts.isFunctionExpression(n.initializer))&&ts.isVariableDeclarationList(n.parent)&&ts.isVariableStatement(n.parent.parent)&&ts.isSourceFile(n.parent.parent.parent);
    if(ts.isFunctionDeclaration(n) || ts.isMethodDeclaration(n) || ts.isConstructorDeclaration(n) || ts.isGetAccessor(n) || ts.isSetAccessor(n) || namedClosure) {
      let name=ts.isConstructorDeclaration(n)?'constructor':n.name?.getText(ast)??'<anonymous>';
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
  walk(ast);return record;
}

export function scanTree(base, map={}) {
  return files(base).filter(p=>p.endsWith('.ts')).map(absolute=>scanSource(path.relative(base,absolute), fs.readFileSync(absolute,'utf8'), map));
}
