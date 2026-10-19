import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),raise=raise=>({raise}),read=read=>({read}),future=future=>({future});
const select=(condition,yes,no)=>({select:[condition,yes,no]});
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?host-errors='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module}),logs=[];
  const original=console.error;console.error=(...args)=>logs.push(args);
  try{
    for(const [op,...args] of commands){
      if(op==='tick')await setImmediate();
      else{
        const actual=b.attempt(op,...args),wanted=s.attempt(op,...args);
        if(actual[0]==='return'&&wanted[0]==='return'&&!['read','set','update','future'].includes(op))actual[1]=wanted[1]=undefined;
        assert.deepEqual(actual,wanted,`${name}: ${op} result`);
      }
      const states=solidStates(s);
      assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,`${name}: node state after ${op}`);
      assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
      assert.deepEqual(b.portEvents,s.portEvents,`${name}: promise results after ${op}`);
      assert.deepEqual(b.portSnapshots,s.portSnapshots,`${name}: promise-observer screen after ${op}`);
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

for(const cause of [undefined,null,false,true,0,99,2**48-1,NaN,'','boom','å😀',{ref:2}]){
  await scenario('StatusError formatting '+String(cause),[
    ['memo','bad',raise(cause)],['read','bad'],['memo','derived',read('bad')],['read','derived'],['tick']
  ]);
}
for(const kind of ['Error','TypeError','RangeError','SyntaxError','ReferenceError','EvalError','URIError','DOMException'])for(const message of ['','bad 😀']){
  const error={error:1,kind,message,...(kind==='DOMException'?{name:'AbortError'}:{})};
  await scenario('sync failure/recovery '+kind+message,[
    ['signal','ok',false],['memo','a',select(read('ok'),lit(7),raise(error))],['memo','b',read('a')],
    ['effect','user',read('b'),{user:true}],['flush'],['read','a'],['read','b'],['set','ok',true],['flush'],['read','b'],['tick']
  ]);
  await scenario('Error is successful data '+kind+message,[
    ['signal','x',error],['memo','copy',read('x')],['effect','view',read('copy')],['flush'],
    ['awaitValue','r',read('copy')],['awaitUntil','u',read('copy')],['tick'],['read','copy'],['set','x',error],['flush']
  ]);
  for(const immediate of [false,true]){
    await scenario('async rejection '+kind+message+immediate,[
      ['future','p',{immediate}],['memo','data',future('p')],['awaitValue','r',read('data')],['awaitUntil','u',read('data')],
      ['tick'],['reject','p',error],['tick'],['read','data']
    ]);
  }
  await scenario('fulfilled Error stays data '+kind+message,[
    ['future','p'],['memo','data',future('p')],['awaitValue','r',read('data')],['awaitUntil','u',read('data')],
    ['tick'],['resolve','p',error],['tick'],['read','data']
  ]);
}
await scenario('explicit/native identities cannot alias',[
  ['signal','x',{error:1,message:'same'}],['signal','y',new Error('same')],
  ['memo','same',{same:[read('x'),read('y')]}],['read','same'],
  ['memo','alias',{same:[read('x'),lit({error:1,message:'same'})]}],['read','alias']
]);
await scenario('matching error properties do not imply equal identity',[
  ['signal','x',{error:1,message:'same'}],['signal','y',{error:2,message:'same'}],
  ['memo','same',{same:[read('x'),read('y')]}],['read','same'],
  ['signal','a',new Error('same')],['signal','b',new Error('same')],
  ['memo','nativeSame',{same:[read('a'),read('b')]}],['read','nativeSame']
]);
await scenario('unused native input does not control observable error identity',[
  ['controller','cancel'],['abort','cancel'],
  ['awaitUntil','r',select(lit(false),raise(new TypeError('unused')),lit(false)),{signal:'cancel'}],['tick'],
  ['memo','actual',raise(new Error('actual'))],['read','actual']
]);
for(const trigger of ['compute','effect','cleanup','errorHandler']){
  const error={error:1,kind:'TypeError',message:'callback failed'};
  const prefix=[['program','fail',[['throw',error]]],['signal','x',0]];
  const commands=trigger==='compute'
    ?[['memo','data',{call:'fail'}],['read','data']]
    :trigger==='effect'
      ?[['effect','user',lit(7),{user:true,program:'fail'}],['flush']]
      :trigger==='cleanup'
        ?[['effect','user',read('x'),{user:true,cleanup:'fail'}],['flush'],['set','x',1],['flush']]
        :[['effect','user',raise(99),{user:true,error:'fail'}],['flush']];
  await scenario('native callback failure '+trigger,[...prefix,...commands,['tick']]);
}

// Independent native identity and formatting assertions, beyond token parity.
for(const Runtime of [BendRuntime,SolidRuntime]){
  const module=await import('../build/solid.mjs?native-host-error-identity='+count);
  const r=new Runtime({async:true,module}),input=new TypeError('original',{cause:71});
  input.source={userMetadata:true}; // User fields must not identify a StatusError.
  input.error={details:'opaque metadata'}; // Or turn a native Error into an input token.
  r.signal('input',input);assert.equal(r.read('input'),input);
  r.memo('bad',raise(input));let wrapped;
  try{r.read('bad');}catch(error){wrapped=error;}
  assert.equal(wrapped.cause,input);assert.equal(wrapped.message,'original');
  r.memo('copy',read('bad'));try{r.read('copy');}catch(error){assert.equal(error,wrapped);}
  r.awaitValue('good',read('input'));assert.equal(await r.promise('good'),input);
  r.awaitUntil('truthy',read('input'));assert.equal(await r.promise('truthy'),input);
  r.controller('cancel');r.awaitUntil('aborted',lit(false),{signal:'cancel'});r.abort('cancel');
  const reason=r.controllers.cancel.signal.reason;let caught;
  await r.promise('aborted').catch(error=>{caught=error;});
  assert.equal(caught,reason);assert.ok(caught instanceof DOMException);assert.equal(caught.name,'AbortError');
  assert.equal(caught.message,reason.message);assert.equal(caught.code,reason.code);
  r.abort('cancel',new Error('ignored'));assert.equal(r.controllers.cancel.signal.reason,reason);
  r.controller('other');r.abort('other',undefined);assert.notEqual(r.controllers.other.signal.reason,reason);
  r.awaitUntil('already',raise(new Error('must not run')),{signal:'other'});
  await r.promise('already').catch(error=>{assert.equal(error,r.controllers.other.signal.reason);});
  r.dispose();r.resetErrorHalt();r.flush();await setImmediate();
}
console.log(`${count} host-error histories match TS captured wrapper messages, native Error/DOMException identity, success versus failure, callback paths and default abort; native identity assertions pass.`);
