// Conservative call-site inventory for the unfinished owner/core boundary.
// It neither executes callbacks nor certifies the value-sensitive driver paths.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));
export function ownerBoundaries(){
  const modules=new Map(),functions=new Map(),files={};
  for(const file of fs.readdirSync(path.join(root,'runtime')).filter(name=>name.endsWith('.bend')).sort()){
    const module=file.slice(0,-5),source=fs.readFileSync(path.join(root,'runtime',file),'utf8');
    files['runtime/'+file]=createHash('sha256').update(source).digest('hex');
    const imports=new Map([...source.matchAll(/^import \.\/([\w-]+)\.bend as (\w+)/gm)].map(([,name,alias])=>[alias,name]));
    const matches=[...source.matchAll(/^def (\w+)\(/gm)],names=new Set(matches.map(match=>match[1]));
    modules.set(module,{imports,names});
    for(let i=0;i<matches.length;i++){
      const match=matches[i],body=source.slice(match.index,matches[i+1]?.index??source.length).replace(/#[^\n]*/g,'');
      functions.set(module+':'+match[1],{module,name:match[1],file:'runtime/'+file,line:source.slice(0,match.index).split('\n').length,body,calls:[]});
    }
  }
  for(const fn of functions.values()){
    const {imports,names}=modules.get(fn.module);
    for(const match of fn.body.slice(fn.body.indexOf('\n')+1).matchAll(/(?<![\w.])(?:(\w+)\.)?(\w+)\(/g)){
      const [,alias,name]=match,module=alias?imports.get(alias):fn.module,target=module+':'+name;
      if(!module||(!alias&&!names.has(name))||!functions.has(target))continue;
      if(!fn.calls.includes(target))fn.calls.push(target);
    }
    fn.calls.sort();
  }
  const seeds=['invoke','invokeAction','dispose','disposeChildren','unobserved','clearDeps','trimStaleDeps','unlinkSubs','sweepDormant','releaseFlightTeardown'].map(name=>'owner:'+name);
  for(const seed of seeds)if(!functions.has(seed))throw new Error('Stale owner boundary seed: '+seed);
  const witness=start=>{
    const queue=[[start]],seen=new Set();
    while(queue.length){const route=queue.shift(),last=route.at(-1);if(seen.has(last))continue;seen.add(last);
      if(seeds.includes(last))return route;
      for(const next of functions.get(last)?.calls??[])queue.push([...route,next]);
    }
    return null;
  };
  const direct=[],core=[];
  for(const [name,fn]of functions)for(const target of fn.calls){
    if(fn.module!=='owner'&&seeds.includes(target))direct.push({from:name,target,file:fn.file,functionLine:fn.line});
    if(fn.module==='core'&&!target.startsWith('core:')){const route=witness(target);if(route)core.push({from:name,target,file:fn.file,functionLine:fn.line,route});}
  }
  return {schemaVersion:1,pin:JSON.parse(fs.readFileSync(path.join(root,'upstream/pins.json'))).solid,
    interpretation:'Possible calls to restricted World owner helpers. Current imperative subsets remain supported; this is not a runtime failure list or a proof of callback reachability/equivalence.',
    exclusions:'OwnerTasks intercepts Invoke before owner.dispatch; callback-free markDisposal/parkChildren are not seeds. Task constructors, branch predicates and callback bodies are not interpreted. Re-audit these assumptions on repin.',
    coreUnbridgedCalls:core,directRestrictedCalls:direct,files};
}
if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url)){
  const report=ownerBoundaries();
  if(process.argv.includes('--json'))console.log(JSON.stringify(report,null,2));
  else {for(const call of report.coreUnbridgedCalls)console.log(call.from+' -> '+call.route.join(' -> '));console.log(`${report.coreUnbridgedCalls.length} core call sites still reach restricted owner helpers; scheduler commit/trim now uses continuations.`);}
}
