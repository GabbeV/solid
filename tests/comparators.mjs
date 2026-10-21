// Custom _equals calls use the actual source function and shared Bend driver.
import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),seq=(...seq)=>({seq}),select=(c,y,n)=>({select:[c,y,n]});
const fn=callback=>lit({callback}),future=future=>({future}),body=(...parts)=>seq(...parts,lit(undefined));
let count=0;
async function scenario(name,commands,verify,{nativeGetter=false}={}){
 const S=await import('../build/solid.mjs?comparator-history='+count),b=new BendRuntime({async:true}),s=new SolidRuntime({module:S}),logs=[];
 const original=console.error;console.error=(...args)=>logs.push(args);
 try{
  for(const [op,...args]of commands){
   if(process.env.DEBUG_COMPARE)original(name,op,...args);
   if(op==='tick')await setImmediate();
   else{
    const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
    if(actual[0]==='return'&&expected[0]==='return'&&!['evaluate','root','future','read','set','update','flush'].includes(op))actual[1]=expected[1]=undefined;
    assert.deepEqual(actual,expected,`${name}: ${op} result`);verify?.(op,args,expected,b,s);
   }
   for(const [label,get]of Object.entries(s.accessors)){
    const node=Object.getOwnPropertySymbols(get).map(k=>get[k]).find(v=>v&&typeof v==='object'&&'_pendingValue'in v);
    if(!node)continue;
    const id=b.ids[label],binding=list(b.world.comparators).find(x=>x.node===id),custom=s.callbackIdentities.get(node._equals);
    assert.equal(binding?b.programNames.get(binding.callback):undefined,custom,`${name}: original comparator identity of ${label}`);
    assert.equal(b.nodes()[id].x===0,node._x===null,`${name}: source extension presence of ${label}`);
   }
   const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: nodes after ${op}`);
   const bt=b.trace(),st=s.trace();assert.deepEqual(nativeGetter?bt.filter(e=>e[0]!=='read'):bt,nativeGetter?st.filter(e=>e[0]!=='read'):st,`${name}: trace after ${op}`);
   const links=list(b.world.links);
   for(const [node,label]of s.sourceNames){
    const expected=[],actual=[],n=b.nodes()[b.ids[label]];
    for(let edge=node._deps;edge;edge=edge._nextDep){const id=[...s.accessorIdentities].find(([get])=>Object.getOwnPropertySymbols(get).some(key=>get[key]===edge._dep))?.[1]??s.sourceNames.get(edge._dep);expected.push([id,edge._gen]);}
    for(let edge=n.deps;edge;edge=links[edge].nextDep)actual.push([b.reverse[links[edge].dep],links[edge].gen]);
    assert.deepEqual(actual,expected,`${name}: ordered deps of ${label} after ${op}`);
    if(node._type===3){assert.equal(n.kind.$,'Tracked');assert.equal(node._cleanup===undefined,n.cleanup===0,`${name}: returned cleanup presence`);}
   }
   assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: native callback errors after ${op}`);
   for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
   assert.deepEqual([b.world.context,b.world.tracking,b.world.running,b.world.stale,b.world.syncDepth],[0,false,false,false,0],`${name}: ambient restoration`);
   const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
   assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports after ${op}`);
  }
  count++;
 }catch(error){original('FAILED comparator: '+name);throw error;}
 finally{for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}await setImmediate();console.error=original;}
}



const arg=index=>({argument:index}),write=(name,value)=>({invokeWith:{callee:lit({setter:name}),value}});
const eq={equals:{callback:'cmp'}};
for(const kind of ['signal','memo','writable'])for(const result of [true,false,undefined,null,0,7,'',{ref:8}])for(const seeded of [false,true]){
 const options={...eq,...(seeded?{loadingValue:0}:{})};
 const make=kind==='signal'?['signal','value',0,eq]:kind==='memo'?['memo','value',read('base'),options]:['signal','value',{callback:'init'},options];
 await scenario('truthy/falsy comparator verdict '+JSON.stringify({kind,result,seeded}),[
  ['signal','base',0],['program','cmp',[['emit',31],['return',lit(result)]]],['program','init',[['return',read('base')]]],make,
  ['effect','view',read('value')],['flush'],[kind==='signal'?'set':'set',kind==='signal'?'value':'base',1],['read','value'],['flush'],['read','value'],
  ['set',kind==='signal'?'value':'base',2],['flush'],['read','value'],['dispose'],['flush']
 ]);
}
for(const kind of ['signal','memo','writable'])for(const seeded of [false,true]){
 const options={...eq,...(seeded?{loadingValue:0}:{})},make=kind==='signal'?['signal','value',0,eq]:kind==='memo'?['memo','value',read('base'),options]:['signal','value',{callback:'init'},options];
 await scenario('actual old/new arguments '+JSON.stringify({kind,seeded}),[
  ['signal','base',0],['program','cmp',[['emit',31],['return',{same:[arg(0),arg(1)]}]]],['program','init',[['return',read('base')]]],make,
  ['effect','view',read('value')],['flush'],['set',kind==='signal'?'value':'base',1],['set',kind==='signal'?'value':'base',1],['flush'],['read','value'],
  ['set',kind==='signal'?'value':'base',0],['flush'],['read','value'],['dispose'],['flush']
 ]);
}
for(const kind of ['signal','memo'])for(const throws of [false,true]){
 await scenario('comparator reads and writes other sources '+JSON.stringify({kind,throws}),[
  ['signal','base',0],['signal','guard',false],['signal','marker',0],['program','cmp',[['emit',31],['setExpr','marker',{add:[arg(1),lit(10)]}],['return',select(read('guard'),throws?{raise:8}:lit(true),lit(false))]]],
  kind==='signal'?['signal','value',0,eq]:['memo','value',read('base'),eq],['effect','view',read('value'),{user:true}],['flush'],
  ['set',kind==='signal'?'value':'base',1],['flush'],['read','value'],['read','marker'],['set','guard',true],['flush'],
  ['set',kind==='signal'?'value':'base',2],['flush'],['read','value'],['read','marker'],['resetErrorHalt'],['dispose'],['flush']
 ]);
}

for(const kind of ['signal','memo','writable'])for(const immediate of [false,true])for(const seeded of [false,true]){
 const options={...eq,loadingValue:0},make=kind==='signal'?['signal','value',0,eq]:kind==='memo'?['memo','value',read('base'),options]:['signal','value',{callback:'init'},options];
 await scenario('unready comparator read means changed '+JSON.stringify({kind,immediate,seeded}),[
  ['signal','base',0],['future','gate',{immediate}],['memo','gate',future('gate'),seeded?{loadingValue:0}:{}],
  ['program','cmp',[['emit',31],['eval',read('gate')],['return',{same:[arg(0),arg(1)]}]]],['program','init',[['return',read('base')]]],make,
  ['effect','view',read('value'),{user:true}],['flush'],['set',kind==='signal'?'value':'base',1],['flush'],['read','value'],
  ['resolve','gate',7],['tick'],['flush'],['read','value'],['set',kind==='signal'?'value':'base',2],['flush'],['read','value'],['dispose'],['flush']
 ]);
}
for(const immediate of [false,true])for(const seeded of [false,true])for(const verdict of [true,false,'throw']){
 await scenario('promise landings invoke comparator '+JSON.stringify({immediate,seeded,verdict}),[
  ['signal','step',0],['future','first',{immediate}],['future','second',{immediate}],
  ['program','cmp',[['emit',31],['return',verdict==='throw'?{raise:8}:lit(verdict)]]],
  ['memo','value',select({same:[read('step'),lit(0)]},future('first'),future('second')),{...eq,...(seeded?{loadingValue:0}:{})}],
  ['effect','view',read('value'),{user:true}],['flush'],['resolve','first',1],['tick'],['flush'],['read','value'],
  ['set','step',1],['flush'],['resolve','second',2],['tick'],['flush'],['read','value'],['resetErrorHalt'],['dispose'],['flush']
 ]);
}
for(const verdict of [false,true,'same'])for(const markerWrite of [false,true]){
 const compare=verdict==='same'?{same:[arg(0),arg(1)]}:lit(verdict);
 await scenario('held seam uses actual comparator '+JSON.stringify({verdict,markerWrite}),[
  ['signal','step',0],['signal','marker',0],['future','hold'],
  ['program','cmp',[['emit',31],...(markerWrite?[['setExpr','marker',arg(1)]]:[]),['return',compare]]],
  ['memo','slow',select({same:[read('step'),lit(0)]},lit(0),future('hold'))],['memo','value',read('step'),eq],
  ['effect','view',{add:[read('slow'),read('value')]}],['flush'],['set','step',1],['flush'],['read','value'],['read','marker'],
  ['resolve','hold',2],['tick'],['flush'],['read','value'],['read','marker'],['dispose'],['flush']
 ]);
}
for(const immediate of [false,true]){
 const nested={memoAccessor:select({same:[read('step'),lit(0)]},lit(0),future('hold'))};
 await scenario('owned pending child prevents seam comparator call '+immediate,[
  ['signal','step',0],['future','hold',{immediate}],
  ['program','cmp',[['emit',31],['return',{same:[{invoke:arg(0)},{invoke:arg(1)}]}]]],
  ['memo','value',nested,eq],['effect','view',{invoke:read('value')}],['flush'],['set','step',1],['flush'],
  ['resolve','hold',2],['tick'],['flush'],['read','value'],['dispose'],['flush']
 ]);
}

for(const frame of ['child','cleanup'])for(const immediate of [false,true]){
 await scenario('parked '+frame+' skips comparator before held intake '+immediate,[
  ['signal','step',0],['future','hold',{immediate}],
  ['program','cmp',[['emit',31],['return',lit(false)]]],
  ['memo','slow',select({same:[read('step'),lit(0)]},lit(0),future('hold'))],
  ['program','gone',[['emit',71]]],['memo','value',seq(read('step'),frame==='child'?{memoAccessor:lit(0)}:{onCleanup:fn('gone')},read('step')),eq],
  ['effect','view',{add:[read('slow'),read('value')]}],['flush'],['set','step',1],['flush'],['read','value'],
  ['resolve','hold',2],['tick'],['flush'],['read','value'],['dispose'],['flush']
 ]);
}

for(const kind of ['signal','memo'])for(const error of [undefined,null,false,0,8,'failed',{ref:8},{error:1,kind:'TypeError',message:'comparison failed'}]){
 await scenario('ordinary comparator error is status, not equality '+JSON.stringify({kind,error}),[
  ['signal','base',0],['signal','failed',true],['program','cmp',[['emit',31],['return',select(read('failed'),{raise:error},lit(false))]]],
  kind==='signal'?['signal','value',0,eq]:['memo','value',read('base'),eq],['effect','view',read('value'),{user:true}],['flush'],
  ['set',kind==='signal'?'value':'base',1],['flush'],['read','value'],['set','failed',false],['flush'],['set',kind==='signal'?'value':'base',2],['flush'],['read','value'],['dispose'],['flush']
 ]);
}
for(const kind of ['signal','memo']){
 await scenario('existing status wrapper is reused by comparator '+kind,[
  ['signal','base',0],['signal','failed',true],['memo','failure',select(read('failed'),{raise:8},lit(0))],
  ['program','cmp',[['emit',31],['eval',read('failure')],['return',lit(false)]]],
  kind==='signal'?['signal','value',0,eq]:['memo','value',read('base'),eq],['effect','view',read('value'),{user:true}],['flush'],
  ['set',kind==='signal'?'value':'base',1],['flush'],['read','value'],['set','failed',false],['flush'],['set',kind==='signal'?'value':'base',2],['flush'],['read','value'],['dispose'],['flush']
 ]);
}
for(const immediate of [false,true])for(const seeded of [false,true]){
 await scenario('comparator error after synchronous replacement of pending source '+JSON.stringify({immediate,seeded}),[
  ['signal','step',0],['future','hold',{immediate}],
  ['program','cmp',[['emit',31],['throw',8]]],
  ['memo','value',select({same:[read('step'),lit(0)]},future('hold'),lit(1)),{...eq,...(seeded?{loadingValue:0}:{})}],
  ['effect','view',read('value'),{user:true}],['flush'],['set','step',1],['flush'],['read','value'],
  ['resolve','hold',2],['tick'],['flush'],['read','value'],['dispose'],['flush']
 ]);
}

for(const kind of ['signal','memo'])for(const result of ['function','thenable','promise']){
 await scenario('returned function/promise is a truthy verdict '+JSON.stringify({kind,result}),[
  ['signal','base',0],['future','token',{immediate:result==='thenable'}],['program','unused',[['throw',99]]],
  ['program','cmp',[['emit',31],['return',result==='function'?fn('unused'):future('token')]]],
  kind==='signal'?['signal','value',0,eq]:['memo','value',read('base'),eq],['effect','view',read('value')],['flush'],
  ['set',kind==='signal'?'value':'base',1],['flush'],['read','value'],['dispose'],['flush']
 ],(op,args,result,b,s)=>{assert.equal(list(b.world.asyncObservers).length,1,'comparator promise verdict is not assimilated');if(s.futures.token?.object.then&&s.futures.token.observers.length)assert.fail('comparator verdict registered a then observer');});
}
for(const user of [false,true]){
 await scenario('effect ignores comparator option '+user,[
  ['signal','base',0],['program','cmp',[['throw',99]]],['effect','view',read('base'),{user,...eq}],['flush'],['set','base',1],['flush'],['dispose'],['flush']
 ]);
}

for(const verdict of [false,true]){
 await scenario('setter proposal is returned even when comparator suppresses '+verdict,[
  ['program','cmp',[['return',lit(verdict)]]],['signal','value',{ref:1},eq],['set','value',{ref:2}],['flush'],['read','value'],['dispose'],['flush']
 ],(op,args,result)=>{if(op==='set')assert.deepEqual(result,['return',{ref:2}]);});
 await scenario('native setter cleanup uses custom comparison '+verdict,[
  ['program','cmp',[['emit',31],['return',lit(verdict)]]],['signal','value',7,eq],['effect','view',read('value')],['flush'],
  ['root','scope',{onCleanup:lit({setter:'value'})}],['disposeOwner','scope'],['flush'],['read','value'],['dispose'],['flush']
 ]);
 await scenario('returned setter cleanup uses custom comparison '+verdict,[
  ['signal','base',0],['program','cmp',[['emit',31],['return',lit(verdict)]]],['signal','value',7,eq],
  ['program','apply',[['return',lit({setter:'value'})]]],['effect','view',read('base'),{user:true,program:'apply',returnCleanup:true}],['flush'],
  ['set','base',1],['flush'],['read','value'],['dispose'],['flush']
 ]);
 await scenario('unobserved callback writes use custom comparison '+verdict,[
  ['signal','base',0],['program','cmp',[['emit',31],['return',lit(verdict)]]],['signal','value',7,eq],
  ['program','unseen',[['set','value',9]]],['memo','lazy',read('base'),{lazy:true,unobserved:'unseen'}],
  ['root','scope',seq({effectCreate:read('lazy'),options:{user:false}},lit(0))],['flush'],['disposeOwner','scope'],['flush'],['read','value'],['dispose'],['flush']
 ]);
}
for(const immediate of [false,true]){
 await scenario('async function values are data at custom setter boundary '+immediate,[
  ['signal','step',0],['future','first',{immediate}],['future','second',{immediate}],['program','firstValue',[['return',lit(31)]]],['program','secondValue',[['return',lit(41)]]],
  ['program','cmp',[['emit',31],['return',{same:[arg(0),arg(1)]}]]],
  ['memo','value',select({same:[read('step'),lit(0)]},future('first'),future('second')),{...eq,loadingValue:{callback:'firstValue'}}],
  ['effect','view',read('value'),{user:true}],['flush'],['resolve','first',{callback:'firstValue'}],['tick'],['flush'],['read','value'],
  ['set','step',1],['flush'],['resolve','second',{callback:'secondValue'}],['tick'],['flush'],['read','value'],['dispose'],['flush']
 ]);
}
console.log(`${count} custom comparator histories match source callback identity, old/new arguments, verdict truthiness, reads/writes, pending, status errors, async landings and held seams.`);
