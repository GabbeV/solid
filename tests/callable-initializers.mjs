import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),call=call=>({call}),future=future=>({future});
const select=(c,y,n)=>({select:[c,y,n]}),add=(a,b)=>({add:[a,b]});
const arg=index=>({argument:index}),invoke=invoke=>({invoke}),current={owner:true};
const callWith=(call,...args)=>({call,args});
let count=0;
async function scenario(name,commands,verify){
  const module=await import('../build/solid.mjs?callable-initializers='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const original=console.error;console.error=(...args)=>logs.push(args);
  try{
    for(const [op,...args] of commands){
      if(process.env.DEBUG_NESTED)original(name,op,...args);
      if(op==='tick')await setImmediate();
      else{
        const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
        if(actual[0]==='return'&&wanted[0]==='return'&&!['read','set','update','future','root','evaluate'].includes(op))actual[1]=wanted[1]=undefined;
        assert.deepEqual(actual,wanted,`${name}: ${op} result`);
        verify?.(op,args,actual,wanted,b,s);
      }
      const known=new Map([[s.owner,1],...Object.entries(s.owners).map(([name,node])=>[node,b.ownerId(name)]),...s.sourceNames.entries()].map(([node,name])=>[node,typeof name==='number'?name:b.ids[name]]));
      for(const [node,id] of known){
        const n=b.nodes()[id];
        if(node._height!==undefined)assert.equal(n.height,node._height,`${name}: height of ${b.reverse[id]} after ${op}`);
        for(const [native,key] of [['_parent','parent'],['_firstChild','firstChild'],['_nextSibling','nextSibling'],['_prevSibling','prevSibling']]){
          if(!node[native])assert.equal(n[key],0,`${name}: null ${key} after ${op}`);
          else if(known.has(node[native]))assert.equal(n[key],known.get(node[native]),`${name}: ${key} alias after ${op}`);
          else assert.equal(b.nodes()[n[key]].kind.$,'Root',`${name}: anonymous ${key} is a root after ${op}`);
        }
      }
      for(const [local,binding] of s.localSignals??[]){
        const node=Object.getOwnPropertySymbols(binding.get).map(key=>binding.get[key]).find(value=>value&&typeof value==='object'&&'_pendingValue'in value);
        assert.ok(node,'actual accessor carries its source node');
        const n=b.nodes()[b.ids[local]];
        assert.equal(n.kind.$,'Signal',`${name}: actual signal allocation`);
        assert.equal(n.parent,0,`${name}: signals are unowned`);
        assert.equal(n.config,node._config,`${name}: local signal config`);
        assert.equal(n.equals,typeof node._equals==='function',`${name}: local comparator choice`);
        assert.equal(n.time,node._time,`${name}: local write time`);
        assert.deepEqual(b.errorShape(b.decode(n.value)),s.errorShape(node._value),`${name}: local committed value`);
        assert.equal('value'in n.pending,node._pendingValue!==s.localNotPending,`${name}: local staged presence`);
        if('value'in n.pending)assert.deepEqual(b.errorShape(b.decode(n.pending.value)),s.errorShape(node._pendingValue),`${name}: local staged value`);
      }
      const states=solidStates(s);
      assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: node state after ${op}`);
      assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
      assert.deepEqual(b.iteratorIO(),s.iteratorIO(),`${name}: iterator calls after ${op}`);
      assert.deepEqual(b.portEvents,s.portEvents,`${name}: promise results after ${op}`);
      assert.deepEqual(b.portSnapshots,s.portSnapshots,`${name}: observer screen after ${op}`);
      assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: escaping callback failures after ${op}`);
      for(const target of [2,3,4])assert.deepEqual(b.screen(target),s.screen(target),`${name}: screen after ${op}`);
      assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],`${name}: ambient restoration`);
      const reports=list(b.world.reports).map(r=>r.kind===0?['[REACTIVITY_HALTED]',...('value'in r.cause?[b.errorShape(b.decode(r.cause.value))]:[])]:r.kind===1?['[REACTIVITY_HALTED]']:[b.errorShape(b.decode(r.cause.value))]);
      assert.deepEqual(reports,logs.map(args=>args.map(e=>s.errorShape(e))),`${name}: reports`);
    }
    count++;
  }catch(error){original('FAILED: '+name);throw error;}
  finally{b.attempt('dispose');s.attempt('dispose');b.resetErrorHalt();s.resetErrorHalt();b.attempt('flush');s.attempt('flush');await setImmediate();console.error=original;}
}

const seq=(...seq)=>({seq}),localRead=depth=>({localRead:depth}),accessor=depth=>({localAccessor:depth}),setter=depth=>({localSetter:depth});
const scope=(initial,body,options={})=>({signalScope:{initial,body,options}});
const computeScope=(compute,body,options={})=>({signalComputeScope:{compute,body,options}});
const invokeWith=(callee,value={lit:undefined},updater=false)=>({invokeWith:{callee,value,updater}});
const disposer=name=>lit({rootDisposer:name});
const capture=[['signal','saved',undefined],['signal','writeSaved',undefined],['program','save',[['updateExpr','saved',arg(0)],['updateExpr','writeSaved',arg(1)]]]];
const save=()=>callWith('save',accessor(0),setter(0));
const readSaved=()=>invoke(read('saved'));
for(const lazy of [false,true])for(const equals of [false,true])for(const callable of ['accessor','setter','rootDisposer']){
  await scenario('first-class initializer selects function overload '+JSON.stringify({lazy,equals,callable}),[
    ['signal','input',1],['root','target',lit(0)],...capture,
    ['root','scope',scope(lit({[callable]:callable==='rootDisposer'?'target':'input'}),seq(save(),localRead(0)),{lazy,equals})],['flush'],
    ['effect','view',readSaved()],['flush'],['set','input',3],['flush'],['evaluate',readSaved()],
    ['evaluate',invokeWith(read('writeSaved'),lit(7))],['flush'],['evaluate',readSaved()],
    ['set','input',9],['flush'],['evaluate',readSaved()],['disposeOwner','scope'],['flush'],
    ['set','input',11],['flush'],['evaluate',readSaved()],['dispose'],['flush']
  ]);
}
for(const lazy of [false,true])for(const callable of ['accessor','setter','rootDisposer']){
  await scenario('unowned host initializer survives explicit root '+JSON.stringify({lazy,callable}),[
    ['signal','input',1],['root','target',lit(0)],
    ['signal','derived',{[callable]:callable==='rootDisposer'?'target':'input'},{lazy}],
    ['read','derived'],['set','input',3],['flush'],['read','derived'],['set','derived',8],['flush'],['read','derived'],
    ['dispose'],['set','input',9],['flush'],['read','derived']
  ]);
}
for(const lazy of [false,true])for(const sourceLazy of [false,true])for(const callable of ['accessor','setter']){
  await scenario('derived accessor/setter initializer '+JSON.stringify({lazy,sourceLazy,callable}),[
    ['signal','input',1],...capture,
    ['root','source',computeScope(read('input'),save(),{lazy:sourceLazy})],
    ['root','scope',scope(lit({[callable]:'#nested1'}),localRead(0),{lazy})],['flush'],
    ['set','input',3],['flush'],['evaluate',invoke(lit({accessor:'#nested2'}))],
    ['disposeOwner','source'],['flush'],['set','input',9],['flush'],['evaluate',invoke(lit({accessor:'#nested2'}))],['dispose'],['flush']
  ]);
}
for(const lazy of [false,true])for(const immediate of [false,true])for(const reject of [false,true]){
  await scenario('pending initializer getter retains pair '+JSON.stringify({lazy,immediate,reject}),[
    ['future','p',{immediate}],['memo','source',future('p')],...capture,
    ['root','scope',scope(lit({accessor:'source'}),save(),{lazy,loadingValue:4})],['flush'],
    ['evaluate',readSaved()],['effect','view',readSaved(),{user:true}],['flush'],
    [reject?'reject':'resolve','p',7],['tick'],['flush'],['evaluate',readSaved()],['dispose'],['flush']
  ]);
}
for(const lazy of [false,true]){
  await scenario('stored getter error still binds constructor pair '+lazy,[
    ['signal','input',0],['memo','source',select(read('input'),lit(5),{raise:7})],...capture,
    ['root','scope',scope(lit({accessor:'source'}),seq(save(),accessor(0)),{lazy})],['flush'],['evaluate',readSaved()],
    ['set','input',1],['flush'],['evaluate',readSaved()],['dispose'],['flush']
  ]);
  await scenario('getter initializer result function stays data '+lazy,[
    ['signal','input',undefined],['root','target',lit(0)],['update','input',disposer('target')],['flush'],...capture,
    ['root','scope',scope(lit({accessor:'input'}),save(),{lazy})],['flush'],['evaluate',readSaved()],
    ['evaluate',{disposed:lit({owner:'target'})}],['disposeOwner','scope'],['evaluate',readSaved()],['dispose'],['flush']
  ]);
  await scenario('initializer value evaluated once before construction '+lazy,[
    ['signal','input',2],['signal','selected',undefined],['update','selected',lit({accessor:'input'})],['flush'],...capture,
    ['root','scope',scope(read('selected'),save(),{lazy})],['set','selected',undefined],['flush'],
    ['set','input',3],['flush'],['evaluate',readSaved()],['dispose'],['flush']
  ]);
  await scenario('raw initializer captures outer local before inner shadow '+lazy,[
    ...capture,['root','scope',scope(lit(3),scope(accessor(0),seq(save(),localRead(0)),{lazy}))],['flush'],
    ['evaluate',readSaved()],['dispose'],['flush']
  ]);
}
for(const cleanupThrows of [false,true])for(const lazy of [false,true]){
  await scenario('disposer initializer executes real target cleanup '+JSON.stringify({cleanupThrows,lazy}),[
    ['signal','marker',0],['program','clean',[['set','marker',5],...(cleanupThrows?[['throw',7]]:[])]],
    ['program','attach',[['cleanup','clean']]],['root','target',call('attach'),{owner:null}],...capture,
    ['root','scope',scope(disposer('target'),seq(save(),accessor(0)),{lazy})],['flush'],['evaluate',readSaved()],['flush'],
    ['read','marker'],['evaluate',{disposed:lit({owner:'target'})}],['dispose'],['flush']
  ]);
}
console.log(`${count} callable-initializer histories match pinned TS overload dispatch, argument/tracking, pending/error setup, pair identity and lifetime.`);
for(const immediate of [false,true])for(const entry of ['set','update','bodySet','bodyExpr','bodyUpdate','teardown']){
  const write=entry==='set'?['set','derived',8]:entry==='update'?['update','derived',add({prev:true},lit(2))]:['evaluate',call('write')];
  const action=entry==='bodyExpr'?['setExpr','derived',lit(8)]:entry==='bodyUpdate'?['updateExpr','derived',add({prev:true},lit(2))]:['set','derived',8];
  await scenario('named writable setter retains held policy '+JSON.stringify({immediate,entry}),[
    ['signal','version',0],['signal','derived',{accessor:'version'}],['future','p',{immediate}],
    ['memo','slow',select(read('version'),future('p'),lit(0))],['effect','view',seq(read('version'),read('derived'),read('slow'))],['flush'],
    ['program','write',[action]],...(entry==='teardown'?[['program','attach',[['cleanup','write']]],['root','cleaner',call('attach')]]:[]),
    ['set','version',1],['flush'],entry==='teardown'?['disposeOwner','cleaner']:write,['flush'],
    ['resolve','p',5],['tick'],['flush'],['read','derived'],['dispose'],['flush']
  ]);
}
for(const entry of ['bodySet','bodyExpr','bodyUpdate']){
  await scenario('named updater preserves held returned-function counterexample '+entry,[
    ['signal','version',0],['signal','derived',{accessor:'version'}],['root','replacement',lit(0)],['future','p',{immediate:true}],
    ['memo','slow',select(read('version'),future('p'),lit(0))],['effect','view',seq(read('version'),read('derived'),read('slow'))],['flush'],
    ['program','write',[[entry==='bodySet'?'set':entry==='bodyExpr'?'setExpr':'updateExpr','derived',entry==='bodySet'?{rootDisposer:'replacement'}:disposer('replacement')]]],
    ['set','version',1],['flush'],['evaluate',call('write')],['flush'],['evaluate',{disposed:lit({owner:'replacement'})}],
    ['resolve','p',5],['tick'],['flush'],['read','derived'],['dispose'],['flush']
  ]);
}
// The reference trace wrapper must not be the only evidence for first-class
// constructor inputs. These controls pass the original native function directly
// to Solid's createSignal and compare results, node fields and owner lifetime.
for(const lazy of [false,true])for(const kind of ['accessor','setter','rootDisposer'])for(const owned of [false,true]){
  const b=new BendRuntime(),s=new SolidRuntime({module:await import('../build/solid.mjs?direct-initializer='+kind+lazy+owned)});
  try{
    for(const r of [b,s]){r.signal('input',1);r.root('target',lit(0));}
    const token={[kind]:kind==='rootDisposer'?'target':'input'};
    let bg,sg,ss;
    if(owned){
      bg=b.root('scope',scope(lit(token),accessor(0),{lazy}));s.root('scope',lit(0));
      [sg,ss]=s.S.runWithOwner(s.ownerFor('scope'),()=>s.S.createSignal(s.value(token),{lazy}));
    }else{
      b.signal('derived',token,{lazy});bg=b.accessors.get(b.ids.derived);
      [sg,ss]=s.S.createSignal(s.value(token),{lazy});
    }
    const name=owned?'#nested1':'derived';
    s.registerComputedAccessor(sg,name);s.setters[name]=ss;s.setterIdentities.set(ss,name);s.setterFunctions.set(name,ss);s.memoSetters.add(ss);
    for(const step of [0,1,2,3,4]){
      if(step===1){b.set('input',3);s.set('input',3);}
      if(step===2){const bf=b.evaluate(lit({setter:name}));assert.equal(bf(8),ss(8));}
      if(step===3){b.dispose();s.dispose();}
      if(step===4){b.set('input',9);s.set('input',9);}
      b.flush();s.S.flush();
      assert.deepEqual(b.errorShape(bg()),s.errorShape(sg()),'unwrapped initializer result '+JSON.stringify({lazy,kind,owned,step}));
      const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,'unwrapped constructor fields/lifetime');
    }
  }finally{for(const r of [b,s]){r.attempt('dispose');r.resetErrorHalt();r.attempt('flush');}}
}
console.log(`${count} total callable-initializer histories, plus 12 direct unwrapped native constructor controls.`);
for(const held of [false,true])for(const teardown of [false,true]){
  await scenario('selected memo setter captures at the correct raw-call entry '+JSON.stringify({held,teardown}),[
    ['signal','input',held?0:undefined],['signal','version',0],['signal','derived',{accessor:'input'}],
    ['program','rewrite',[['set','derived',9]]],['program','attachRewrite',[['cleanup','rewrite']]],['root','replacement',call('attachRewrite'),{owner:null}],
    ['future','p',{immediate:true}],['memo','slow',select(read('version'),future('p'),lit(0))],
    ['effect','view',seq(read('version'),read('derived'),read('slow'))],['flush'],
    ['program','write',[['set','derived',{rootDisposer:'replacement'}]]],
    ...(teardown?[['program','attach',[['cleanup','write']]],['root','cleaner',call('attach')]]:[]),
    ...(held?[['set','input',undefined],['set','version',1],['flush']]:[]),
    teardown?['disposeOwner','cleaner']:['evaluate',call('write')],['flush'],
    ['resolve','p',5],['tick'],['flush'],['read','derived'],['dispose'],['flush']
  ]);
}
await scenario('constructor previous argument is independent of enclosing expression',[
  ['signal','input',1],['evaluate',scope(lit({setter:'input'}),localRead(0)),9],['flush'],['read','input'],['dispose']
]);
console.log(`${count} complete callable-initializer histories and 12 unwrapped native controls pass.`);
