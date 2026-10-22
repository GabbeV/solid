import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
import {BendRuntime} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
const lit=lit=>({lit}),read=read=>({read}),future=future=>({future});
const select=(c,y,n)=>({select:[c,y,n]}),call=call=>({call});
let count=0;
async function scenario(name,commands){
  const module=await import('../build/solid.mjs?async-cleanup-pin='+count);
  const b=new BendRuntime({async:true}),s=new SolidRuntime({module});
  try{
    for(const [op,...args] of commands){
      if(op==='tick')await setImmediate();
      else if(op==='expectTrace'){
        const expected=args[0];
        assert.deepEqual(s.trace().filter(e=>e[0]==='cleanup').map(e=>e[2]),expected,name+' native cleanup order');
        assert.deepEqual(b.trace().filter(e=>e[0]==='cleanup').map(e=>e[2]),expected,name+' Bend cleanup order');
      }else{
        const actual=b.attempt(op,...args),expected=s.attempt(op,...args);
        if(actual[0]==='return'&&expected[0]==='return'&&!['read','set','future'].includes(op))actual[1]=expected[1]=undefined;
        assert.deepEqual(actual,expected,`${name}: ${op} result`);
      }
      const states=solidStates(s);
      assert.deepEqual(bendStates(b,states.map(([key])=>key)),states,`${name}: state after ${op}`);
      assert.deepEqual(b.trace(),s.trace(),`${name}: trace after ${op}`);
      assert.deepEqual(b.asyncErrors,s.asyncErrors,`${name}: callback errors after ${op}`);
      assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false],`${name}: ambient restoration`);
    }
    count++;
  }finally{
    b.attempt('dispose');s.attempt('dispose');
    b.resetErrorHalt();s.resetErrorHalt();
    b.attempt('flush');s.attempt('flush');await setImmediate();
  }
}
for(const immediate of[false,true])for(const rejects of[false,true])for(const supersede of[false,true])for(const child of[false,true]){
  const value=select({same:[read('step'),lit(0)]},future('a'),select({same:[read('step'),lit(1)]},future('b'),future('c')));
  const body=[['cleanup','clean'],...(child?[['eval',{memoRead:call('child')}]]:[]),['return',value]];
  const cleaned=child?[12,11]:[11];
  await scenario(`replacement cleanup ${immediate}/${rejects}/${supersede}/${child}`,[
    ['future','a',{immediate}],['future','b',{immediate}],['future','c',{immediate}],['signal','step',0],
    ['program','clean',[['emit',11]]],['program','childClean',[['emit',12]]],
    ['program','child',[['cleanup','childClean'],['return',lit(0)]]],['program','body',body],
    ['program','error',[['emit',99]]],['memo','m',call('body')],
    ['effect','view',read('m'),{user:true,error:'error'}],['flush'],['resolve','a',10],['tick'],
    ['expectTrace',[]],['set','step',1],['flush'],['expectTrace',[]],
    ...(supersede?[['set','step',2],['flush'],['expectTrace',cleaned]]:[]),
    [rejects?'reject':'resolve',supersede?'c':'b',21],['tick'],
    ['expectTrace',[...(supersede?cleaned:[]),...cleaned,...(rejects?[99]:[])]],
    ['set','step',supersede?1:2],['flush'],
    ['expectTrace',[...(supersede?cleaned:[]),...cleaned,...(rejects?[99,...cleaned]:[])]],['dispose']
  ]);
}
console.log(`${count} async replacement cleanup histories compare rejected/successful answers, never-committed supersession, child-first cleanup, later replacement and native/immediate delivery.`);
