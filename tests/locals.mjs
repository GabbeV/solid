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
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?locals='+count);
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

const scope=(initial,body,options={})=>({signalScope:{initial,body,options}});
const localRead=depth=>({localRead:depth});
const write=(value,{depth=0,updater=false}={})=>({localWrite:{depth,value,updater}});
const seq=(...seq)=>({seq});
const effect=(effectCreate,body,options={})=>({effectCreate,body,options});
const nested=(memoRead,options={})=>({memoRead,options});
const get=()=>localRead(0);
for(const value of [undefined,null,false,true,0,7,NaN,'value',{ref:7},{owner:'root'},{error:1,kind:'Error',message:'value'}]){
  await scenario('local initializer and result '+String(value),[['evaluate',scope(lit(value),get())],['flush']]);
  await scenario('local setter return and staged read '+String(value),[
    ['evaluate',scope(lit(1),seq(write(lit(value)),get()))],['flush']
  ]);
}
for(const equals of [false,true])for(const ownedWrite of [false,true])for(const noSnapshot of [false,true]){
  const options={equals,ownedWrite,noSnapshot};
  await scenario('local staged updater composition '+JSON.stringify(options),[
    ['root','scope',scope(lit(1),seq(write(add({prev:true},lit(2)),{updater:true}),write(add({prev:true},lit(3)),{updater:true}),nested(get())),options)],
    ['flush'],['dispose']
  ]);
  await scenario('local binding survives queued closure '+JSON.stringify(options),[
    ['signal','s',1],['root','scope',scope(lit(0),seq(
      effect(read('s'),write(add({prev:true},arg(0)),{updater:true})),
      effect(get(),lit(undefined),{user:false,target:3})
    ),options)],
    ['flush'],['set','s',3],['flush'],['set','s',5],['flush'],['dispose'],['set','s',8],['flush']
  ]);
}
await scenario('shadowed locals and initializer see their respective lexical scope',[
  ['root','scope',scope(lit(7),scope(add(get(),lit(3)),seq(
    write(lit(8),{depth:1}),write(add({prev:true},localRead(1)),{updater:true}),
    add(get(),localRead(1))
  )))],['flush'],['dispose']
]);
await scenario('nested root rebinds arguments but captures local signal',[
  ['root','scope',scope(lit(7),{root:seq(write(arg(0)),get())})],['flush'],['dispose']
]);
await scenario('new effect application owns arguments and retains local bindings',[
  ['root','scope',scope(lit(7),seq(effect(lit(3),write(add({prev:true},arg(0)),{updater:true})),effect(get(),lit(undefined),{user:false,target:3})))],
  ['flush'],['dispose']
]);
await scenario('separate closure instances retain separate signal identities',[
  ['signal','s',1],['root','one',scope(lit(0),effect(read('s'),write(add({prev:true},arg(0)),{updater:true})))],
  ['root','two',scope(lit(10),effect(read('s'),write(add({prev:true},arg(0)),{updater:true})))],
  ['flush'],['set','s',2],['flush'],['disposeOwner','one'],['set','s',3],['flush'],['dispose']
]);
await scenario('parent rerun allocates fresh locals and retires captured callbacks',[
  ['signal','s',1],['signal','trigger',0],
  ['memo','m',seq(read('trigger'),scope(lit(0),seq(effect(read('s'),write(arg(0))),effect(get(),lit(undefined),{user:false,target:3}),lit(3))))],
  ['effect','view',read('m')],['flush'],['set','s',2],['flush'],['set','trigger',1],['flush'],['dispose']
]);
await scenario('initializer executes before allocating its signal',[
  ['signal','s',1],['root','scope',scope(nested(read('s')),nested(get()))],['flush'],['dispose']
]);
await scenario('throwing updater does not write and preserves enclosing operands',[
  ['memo','m',add(lit(5),scope(lit(1),write({raise:7},{updater:true})))],['read','m'],['flush'],['dispose']
]);
await scenario('throwing initializer never allocates a signal',[
  ['memo','m',scope({raise:7},get())],['read','m'],['flush'],['dispose']
]);
for(const updater of [false,true]){
  await scenario('bound disposer raw input versus returned function '+updater,[
    ['root','target',arg(0),{owner:null}],['root','scope',scope(lit(1),write(lit({rootDisposer:'target'}),{updater}))],
    ['evaluate',{disposed:lit({owner:'target'})}],['flush'],['dispose']
  ]);
}
for(const immediate of [false,true]){
  await scenario('local signal stores async identity without awaiting '+immediate,[
    ['future','p',{immediate}],['root','scope',scope(future('p'),nested(get(),{loadingValue:0}))],
    ['flush'],['resolve','p',7],['tick'],['flush'],['dispose']
  ]);
}

await scenario('a new application-local shadows a retained outer binding',[
  ['signal','s',2],['root','scope',scope(lit(10),effect(read('s'),scope(arg(0),seq(
    write(add(get(),localRead(1)),{depth:1}),write(lit(3)),localRead(1)
  ))))],['flush'],['set','s',4],['flush'],['dispose']
]);
await scenario('nested setter argument side effects survive its later throw',[
  ['root','scope',scope(lit(1),scope(lit(2),write(seq(write(lit(9)),{raise:7}),{depth:1})))],
  ['flush'],['dispose']
]);
await scenario('raw function setter throw skips the local write',[
  ['program','bad',[['throw',8]]],['program','attach',[['cleanup','bad'],['return',arg(0)]]],
  ['root','target',callWith('attach',arg(0)),{owner:null}],
  ['root','scope',scope(lit(1),write(lit({rootDisposer:'target'})))],['flush'],['dispose']
]);
await scenario('anonymous closure encodings do not change named callback labels',[
  ['program','first',[['emit',81]]],['root','one',scope(lit(1),effect(lit(2),call('first')))],
  ['program','second',[['emit',82]]],['root','two',scope(lit(1),effect(lit(2),call('second')))],
  ['flush'],['dispose']
]);
await scenario('local unobserved callback retains signal-specific teardown',[
  ['program','gone',[['emit',83]]],['root','scope',scope(lit(1),effect(get(),lit(undefined)),{unobserved:'gone'})],
  ['flush'],['dispose']
]);
console.log(`${count} local-signal and captured-body histories match pinned TS allocation, lexical identity, staged writes, callbacks and lifetime.`);
