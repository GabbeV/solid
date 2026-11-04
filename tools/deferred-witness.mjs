// Untrusted canonical data from core.step and its named read-gate cut. Both
// proposed suffixes and the actual source gate equation require kernel checks.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url)),payload=process.argv.includes('--payload');
const checking=process.argv.includes('--check');
function save(name,text){const dest=path.join(root,'proof',name+'.bend');if(checking){if(fs.readFileSync(dest,'utf8')!==text)throw Error(name+' is stale');}else fs.writeFileSync(dest,text);}
if(!payload){
 let out=`# Numeric specialization of the independently checked ordinary-payload path.
import Base
import ../runtime/core.bend as C
import ../representation/records.bend as R
import ./ordinary-payload.bend as Payload
import ./deferred-payload-program.bend as Program
import ./deferred-driver.bend as Driver
import ./natural-netted-value.bend as Natural

`;
 for(let i=0;i<=103;i++)out+=`def state_${i}(+initial: Nat,+next: Nat) -> C.Machine:
  Program.state_${i}(Payload.DataNatural{initial},Payload.DataNatural{next})

`;
 out+=`def complete(+initial: Nat,+next: Nat,+extra: Nat) -> {C.run(Nat.add(103n,extra),Driver.before(initial,next)) == state_103(initial,next) : C.Machine}:
  Program.complete(Payload.DataNatural{initial},Payload.DataNatural{next},extra)

def result(+initial: Nat,+next: Nat,+extra: Nat) -> {C.values(C.run(Nat.add(103n,extra),Driver.before(initial,next))) == [R.Number{next}] : List<&2,R.Value>}:
  Equal.trans(List<&2,R.Value>,C.values(C.run(Nat.add(103n,extra),Driver.before(initial,next))),[Program.answer(Payload.DataNatural{initial},Payload.DataNatural{next})],[R.Number{next}],Program.result(Payload.DataNatural{initial},Payload.DataNatural{next},extra),Equal.cong(R.Value,List<&2,R.Value>,value=>[value],Program.answer(Payload.DataNatural{initial},Payload.DataNatural{next}),R.Number{next},Natural.pickSame(initial,next)))
`;
 save('deferred-program',out);console.log('Numeric deferred path specializes the full ordinary-payload path.');process.exit(0);
}
const dir=fs.mkdtempSync(path.join(os.tmpdir(),'solid-deferred-witness-'));
try{
 const emitted=path.join(dir,'driver.mjs');
 const built=spawnSync(path.join(root,'node_modules/.bin/bun'),['upstream/bend/bend2/main.ts','proof/deferred-payload-driver.bend','-o',emitted],{cwd:root,encoding:'utf8'});
 if(built.status!==0)throw Error(built.stderr);
 const {default:D}=await import(pathToFileURL(emitted));
 const constructors=new Map();
 function split(text){let depth=0,start=0,out=[];for(let i=0;i<text.length;i++){if('<({'.includes(text[i]))depth++;if('>)}'.includes(text[i]))depth--;if(text[i]===','&&depth===0){out.push(text.slice(start,i).trim());start=i+1;}}if(text.slice(start).trim())out.push(text.slice(start).trim());return out;}
 for(const [file,ns]of[['representation/records.bend','R'],['runtime/core.bend','C'],['runtime/owner.bend','O'],['runtime/pending.bend','Q']]){
  let data=false,family;for(const line of fs.readFileSync(path.join(root,file),'utf8').replace(/\n    /g,' ').split('\n')){
   if(/^type .* is Data:/.test(line)){data=true;family=line.match(/^type (\w+)/)[1];continue;}if(/^[^ #\t]/.test(line))data=false;if(!data)continue;
   const m=line.match(/^  (\w+)\{(.*)\}$/);if(!m)continue;
   constructors.set(ns+'.'+family+'.'+m[1],{ns,fields:split(m[2]).map(x=>{const i=x.indexOf(':');return[x.slice(0,i).trim(),x.slice(i+1).trim()];})});
  }
 }
 const shared=new Map(),declarations=[];
 function qualified(type,ns){if(['Nat','Bool','U32','String'].includes(type))return type;if(type.startsWith('List<'))return 'List<&2, '+qualified(split(type.slice(5,-1))[1],ns)+'>';return type.includes('.')?type:ns+'.'+type;}
 function intern(body,type){const key=type+'#'+body;if(shared.has(key))return shared.get(key);const name='data_'+shared.size,variables=['initial','next'].filter(v=>new RegExp('\\b'+v+'\\b').test(body)),call=name+'('+variables.join(', ')+')';shared.set(key,call);declarations.push(`def ${name}(${variables.map(v=>'+'+v+': Payload.Ordinary').join(', ')}) -> ${type}:\n  ${body}\n`);return call;}
 let branch='plain';
 function show(value,type,ns='R'){
  const plain=type.replace(/^\w+\./,'');
  if(plain==='Nat')return value+'n';if(plain==='U32')return String(value);if(plain==='Bool')return value?'True{}':'False{}';if(plain==='String')return JSON.stringify(value);
  if(type.startsWith('List<')){const elem=split(type.slice(5,-1))[1],items=[];while('head'in value){items.push(show(value.head,elem,ns));value=value.tail;}return intern('['+items.join(', ')+']',qualified(type,ns));}
  const family=type.includes('.')?type:ns+'.'+type;
  if(family==='R.Value'){
   const initial=value.$==='Number'&&value.n===11;
   const next=value.$==='Number'&&value.n===17;
   if(initial)return intern('Payload.value(initial)','R.Value');if(next)return intern('Payload.value(next)','R.Value');
  }
  const con=constructors.get(family+'.'+value.$);if(!con)throw Error('Unknown '+family+' '+JSON.stringify(value));
  return intern(con.ns+'.'+value.$+'{'+con.fields.map(([name,t])=>{if(value[name]===undefined)throw Error('Missing '+family+'.'+value.$+'.'+name);return show(value[name],t,con.ns);}).join(', ')+'}',qualified(type,ns));
 }
 function trace(initial,next,netted=false){let m=D.before(initial,next),states=[m];for(let i=0;i<128&&'head'in m.tasks;i++){m=netted&&i===50?D.branchRead(m,true):D.step(m);states.push(m);}if('head'in m.tasks||m.world.fault.$!=='Healthy'||states.length!==104)throw Error('Review changed deferred execution');return states;}
 const sampleInitial={$:'DataNatural',value:11},sampleNext={$:'DataNatural',value:17};
 const traces={plain:trace(sampleInitial,sampleNext),netted:trace(sampleInitial,sampleNext,true)};
 const data={};for(branch of ['plain','netted'])data[branch]=traces[branch].map(state=>show(state,'C.Machine'));
 for(let i=0;i<=50;i++)if(data.plain[i]!==data.netted[i])throw Error('Unexpected pre-read branch at '+i);
 branch='plain';
 let out=`# Generated by tools/deferred-witness.mjs from core.step and a read-gate cut.
# Branch-independent prefixes are shared; the read gate and both suffixes are
# checked, including strict equality and SameValue. No sample is proof credit.
import Base
import ../runtime/core.bend as C
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./paths.bend as P
import ../runtime/equality.bend as DeferredEQ
import ../runtime/constants.bend as DeferredK
import ./memo-setter-cuts.bend as SetterCuts
import ./deferred-heap-cuts.bend as HeapCuts
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../runtime/owner.bend as O
import ../runtime/pending.bend as Q
import ./deferred-payload-driver.bend as Driver
import ./ordinary-payload.bend as Payload
import ./deferred-driver.bend as NumericDriver
import ./deferred-read-cut.bend as ReadCut

`;
 const params='+initial: Payload.Ordinary,+next: Payload.Ordinary',call='initial,next';
 out+=`def netted(${params}) -> Bool:
  Bool.and(B.equal(Payload.value(next),Payload.value(initial)),B.objectIs(Payload.value(next),Payload.value(initial)))

def answerAt(${params},gate: Bool) -> R.Value:
  B.choose(~R.Value,gate,_=>Payload.value(initial),_=>Payload.value(next))

def answer(${params}) -> R.Value:
  answerAt(${call},netted(${call}))

`;
 for(let i=0;i<=103;i++){
  if(i<=50)out+=`def state_${i}(${params}) -> C.Machine:
  ${data.plain[i]}

`;
  else{
   out+=`def at_${i}(${params},gate: Bool) -> C.Machine:
  B.choose(~C.Machine,gate,_=>${data.netted[i]},_=>${data.plain[i]})

def state_${i}(${params}) -> C.Machine:
  at_${i}(${call},netted(${call}))

`;
  }
 }
 const states=traces.plain,setterIndex=34;
 if(states[setterIndex].tasks.head?.$!=='SetSignalResolved')throw Error('Setter position changed');
 const slotted=D.stageSlot(states[setterIndex].world,sampleNext),stamped=D.stageStamp(slotted),flagged=D.stageFlags(stamped),inserted=D.stageInsert(slotted),scheduled=D.stageSchedule(inserted);
 if(JSON.stringify(scheduled)!==JSON.stringify(states[setterIndex+1].world))throw Error('Setter cuts fail');
 for(const [name,value,type]of[['Origin',states[setterIndex].world,'R.World'],['Slot',slotted,'R.World'],['Stamped',stamped,'R.World'],['Flagged',flagged,'R.World'],['Inserted',inserted,'R.World'],['Scheduled',scheduled,'R.World'],['Rest',states[setterIndex+1].tasks,'List<&2, C.Task>']])out+=`def cut${name}(${params}) -> ${type}:
  ${show(value,type)}

`;
 let equations=fs.readFileSync(path.join(root,'proof/deferred-setter-equations.txt'),'utf8').trimEnd().replaceAll('initial: Nat','initial: Payload.Ordinary').replaceAll('next: Nat','next: Payload.Ordinary').replaceAll('R.Number{initial}','Payload.value(initial)').replaceAll('R.Number{next}','Payload.value(next)');
 out+=equations+'\n\n';
 const readRest=show(states[51].tasks,'List<&2, C.Task>'),readStack=show(states[50].values,'List<&2, R.Value>');
 out+=`def readAt(${params},gate: Bool) -> C.Machine:
  ReadCut.read(C.world(state_50(${call})),${readRest},${readStack},3n,gate)

def readCase(${params},gate: Bool) -> {readAt(${call},gate) == at_51(${call},gate) : C.Machine}:
  match gate:
    case True{}: {==}
    case False{}: {==}

`;
 const cases=variable=>'match '+variable+':\n'+['DataUndefined{}','DataNull{}','DataBoolean{value}','DataNatural{value}','DataNegativeZero{}','DataNaN{}','DataString{value}','DataReference{identity}'].map(pattern=>'    case Payload.'+pattern+': {==}').join('\n');
 for(let i=0;i<103;i++){
  let body=i===34?'setterStep(initial,next)':'{==}';
  if([4,15,16,33].includes(i))body=cases(i===33?'next':'initial');
  if(i===50)body=`Equal.trans(C.Machine,C.step(state_50(${call})),readAt(${call},netted(${call})),state_51(${call}),{==},readCase(${call},netted(${call})))`;
  if(i>=51){
   if([51,52].includes(i)){
    out+=`def stepNetted_${i}(${params}) -> {C.step(at_${i}(${call},True{})) == at_${i+1}(${call},True{}) : C.Machine}:
  ${cases('initial')}

def stepPlain_${i}(${params}) -> {C.step(at_${i}(${call},False{})) == at_${i+1}(${call},False{}) : C.Machine}:
  ${cases('next')}

`;
   }
   const yes=[51,52].includes(i)?`stepNetted_${i}(${call})`:'{==}',no=[51,52].includes(i)?`stepPlain_${i}(${call})`:'{==}';
   out+=`def stepAt_${i}(${params},gate: Bool) -> {C.step(at_${i}(${call},gate)) == at_${i+1}(${call},gate) : C.Machine}:
  match gate:
    case True{}: ${yes}
    case False{}: ${no}

`;
   body=`stepAt_${i}(${call},netted(${call}))`;
  }
  out+=`def step_${i}(${params}) -> {C.step(state_${i}(${call})) == state_${i+1}(${call}) : C.Machine}:
  ${body}

`;
 }
 out+=`def endAt(${params},+gate: Bool) -> {at_103(${call},gate) == C.Machine{C.world(at_103(${call},gate)),[],[answerAt(${call},gate)]} : C.Machine}:
  match gate:
    case True{}: {==}
    case False{}: {==}

def witness(${params}) -> P.Path<state_0(${call}),state_103(${call})>:
  `;
 for(let i=0;i<103;i++)out+=`P.PathStep{state_${i+1}(${call}),step_${i}(${call}),`;
 out+=`P.PathEnd{C.world(state_103(${call})),[answer(${call})],endAt(${call},netted(${call})),endAt(${call},netted(${call}))}`+'}'.repeat(103)+'\n';
 out+=`
def entry(${params}) -> {Driver.before(${call}) == state_0(${call}) : C.Machine}:
  {==}

def connect(-fuel: Nat,-start: C.Machine,-canonical: C.Machine,-end: C.Machine,linked: {start == canonical : C.Machine},run: {C.run(fuel,canonical) == end : C.Machine}) -> {C.run(fuel,start) == end : C.Machine}:
  Equal.trans(C.Machine,C.run(fuel,start),C.run(fuel,canonical),end,Equal.cong(C.Machine,C.Machine,m=>C.run(fuel,m),start,canonical,linked),run)

def complete(${params},+extra: Nat) -> {C.run(Nat.add(103n,extra),Driver.before(${call})) == state_103(${call}) : C.Machine}:
  connect(Nat.add(103n,extra),Driver.before(${call}),state_0(${call}),state_103(${call}),entry(${call}),P.retimed(state_0(${call}),state_103(${call}),witness(${call}),extra,Nat.add(103n,extra),{==}))

def result(${params},+extra: Nat) -> {C.values(C.run(Nat.add(103n,extra),Driver.before(${call}))) == [answer(${call})] : List<&2,R.Value>}:
  Equal.cong(C.Machine,List<&2,R.Value>,m=>C.values(m),C.run(Nat.add(103n,extra),Driver.before(${call})),C.Machine{C.world(state_103(${call})),[],[answer(${call})]},Equal.trans(C.Machine,C.run(Nat.add(103n,extra),Driver.before(${call})),state_103(${call}),C.Machine{C.world(state_103(${call})),[],[answer(${call})]},complete(${call},extra),endAt(${call},netted(${call}))))

def specializesNumeric(+initial: Nat,+next: Nat) -> {Driver.before(Payload.DataNatural{initial},Payload.DataNatural{next}) == NumericDriver.before(initial,next) : C.Machine}:
  {==}
`;
 const dataIndex=out.indexOf('def netted(');out=out.slice(0,dataIndex)+declarations.join('\n')+'\n'+out.slice(dataIndex);
 save('deferred-payload-program',out);console.log('103-step ordinary-payload path records both strict-equality read outcomes.');
}finally{fs.rmSync(dir,{recursive:true,force:true});}
