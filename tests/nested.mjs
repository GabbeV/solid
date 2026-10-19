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
  const module=await import('../build/solid.mjs?nested='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const original=console.error;console.error=(...args)=>logs.push(args);
  try{
    for(const [op,...args] of commands){
      if(process.env.DEBUG_NESTED)original(name,op,...args);
      if(op==='tick')await setImmediate();
      else{
        const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
        // Names are read-only observations of actual arena allocation order.
        // No node, callback, dependency or scheduler state is installed here.
        let serial=Object.keys(b.ids).filter(name=>name.startsWith('#nested')).length;
        for(const [id,node] of b.nodes().entries())if(node.kind.$==='Memo'&&!b.reverse[id]&&!b.hiddenNodes.has(id)){
          const name='#nested'+(++serial);b.ids[name]=id;b.reverse[id]=name;
        }
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
const nested=(memoRead,options={})=>({memoRead,options});
for(const lazy of [false,true])for(const transparent of [false,true])for(const sync of [false,true]){
  const options={lazy,transparent,sync};
  await scenario('nested memo reruns and retires old children '+JSON.stringify(options),[
    ['signal','s',1],['memo','m',add(lit(3),nested(add(read('s'),lit(2)),options))],
    ['effect','view',read('m')],['read','m'],['set','s',2],['read','m'],['flush'],
    ['set','s',3],['flush'],['read','m'],['dispose'],['set','s',4],['flush'],['read','m']
  ]);
  await scenario('two levels preserve child setup height '+JSON.stringify(options),[
    ['signal','s',2],['memo','m',nested(nested(read('s'),options),options)],
    ['effect','view',read('m')],['set','s',4],['flush'],['read','m'],['dispose']
  ]);
  await scenario('captured call arguments and own prev '+JSON.stringify(options),[
    ['program','make',[['return',nested(add(arg(0),select({prev:true},{prev:true},lit(1))),options)]]],
    ['signal','s',2],['memo','m',callWith('make',read('s'))],['effect','view',read('m')],
    ['set','s',7],['flush'],['read','m'],['dispose']
  ]);
  await scenario('nested construction in untracked application '+JSON.stringify(options),[
    ['signal','s',1],['signal','trigger',0],
    ['program','apply',[['eval',nested(read('s'),options)]]],
    ['effect','view',read('trigger'),{program:'apply'}],['set','s',2],['flush'],
    ['set','trigger',1],['flush'],['set','s',3],['flush'],['dispose']
  ]);
  await scenario('context inherited before first pass '+JSON.stringify(options),[
    ['context','key',1],['signal','s',1],
    ['memo','m',{seq:[{setContext:{name:'key',value:read('s')}},nested({getContext:{name:'key'}},options)]}],
    ['effect','view',read('m')],['set','s',8],['flush'],['read','m'],['dispose']
  ]);
  await scenario('root scope forwards computed parent '+JSON.stringify(options),[
    ['signal','s',1],['memo','m',{root:nested(read('s'),options)}],['effect','view',read('m')],
    ['set','s',9],['flush'],['read','m'],['dispose']
  ]);
  await scenario('nested throw catches in source frame '+JSON.stringify(options),[
    ['signal','s',false],['memo','m',add(lit(10),nested(select(read('s'),{raise:7},lit(2)),options))],
    ['effect','view',read('m')],['set','s',true],['flush'],['read','m'],
    ['set','s',false],['flush'],['read','m'],['dispose']
  ]);
  await scenario('nested branch cleanup '+JSON.stringify(options),[
    ['program','gone',[['emit',51]]],['signal','s',1],
    ['memo','m',nested(read('s'),{...options,unobserved:'gone'})],['effect','view',read('m')],
    ['set','s',2],['flush'],['set','s',3],['flush'],['dispose']
  ]);
}
for(const lazy of [false,true])for(const seed of [undefined,5]){
  const options={lazy,loadingValue:seed};
  await scenario('pending nested memo loading '+JSON.stringify(options),[
    ['future','p',{immediate:false}],['root','scope',nested(future('p'),options)],
    ['flush'],['resolve','p',6],['tick'],['flush'],['dispose']
  ]);
}
console.log(`${count} nested-memo histories match pinned TS allocation, initial execution, callbacks, lifetime, loading and error behavior.`);
