import assert from 'node:assert/strict';
import {setImmediate} from 'node:timers/promises';
const {createRoot,createSignal,createMemo,createReaction,flush}=await import(process.env.SOLID_MODULE??'@solidjs/signals');
const mode=process.argv[2]??'pending';
assert.ok(['pending','seeded','skip-old'].includes(mode));
let finish,dispose,calls=0;
const {track,oldResult,currentField,setCurrentField}=createRoot(d=>{
 dispose=d;
 const oldResult=createMemo(()=>new Promise(resolve=>finish=resolve),mode==='seeded'?{loadingValue:0}:undefined);
 const [currentField,setCurrentField]=createSignal(0);
 const track=createReaction(()=>{calls++;});
 return {track,oldResult,currentField,setCurrentField};
});
try{
 if(mode!=='skip-old')track(oldResult);
 track(currentField);
 flush();
 finish(1);await setImmediate();flush();const afterOld=calls;
 setCurrentField(1);flush();const afterCurrent=calls;
 console.log(JSON.stringify({mode,afterOld,afterCurrent,expected:[0,1]}));
 assert.deepEqual([afterOld,afterCurrent],[0,1],'Only the current arm should fire');
}finally{dispose();flush();}
