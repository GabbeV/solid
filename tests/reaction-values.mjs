// Original returned track functions and original tracking inputs are unwrapped.
// Direct native getters bypass the expression read observer; this family checks
// results, cleanup emits, complete arm state and ordered edges, not read/compute
// or internal application markers. Nodes are labeled after the actual call.
import assert from 'node:assert/strict';
import {BendRuntime,list} from '../host/bend.mjs';
import {SolidRuntime} from '../host/solid.mjs';
import {bendStates,solidStates} from './node-state.mjs';
let count=0;
for(const input of ['getter','program','returnedFunction'])for(const rearm of [false,true])for(const copied of [false,true]){
 const S=await import('../build/solid.mjs?reaction-values='+count),b=new BendRuntime(),s=new SolidRuntime({module:S});
 const commands=[['signal','x',0],['signal','count',0],['program','clean',[['emit',31]]],['program','track',[['eval',{read:'x'}],['return',{lit:input==='returnedFunction'?{callback:'clean'}:undefined}]]],['program','fire',[['updateExpr','count',{add:[{prev:true},{lit:1}]}],['return',{lit:{callback:'clean'}}]]]];
 for(const c of commands){b.attempt(...c);s.attempt(...c);}
 const bf=b.reaction('ready',{call:'fire'}),sf=s.reaction('ready',{call:'fire'});
 assert.equal(bf,b.decode(b.encode(bf)),'original Bend closure materializes once');
 assert.equal(sf,s.value({reaction:'ready'}),'native returned tracker is unchanged');
 assert.equal(s.callbackValue('@reaction1'),sf,'source codec returns the actual tracker');
 const arg=r=>input==='getter'?(r===b?b.accessors.get(b.ids.x):s.accessors.x):(r===b?b.decode(b.encode({callback:'track'})):s.callbackValue('track'));
 function compare(label){
  const states=solidStates(s);assert.deepEqual(bendStates(b,states.map(([name])=>name)),states,label);
  assert.deepEqual(b.trace().filter(e=>e[0]==='cleanup'),s.trace().filter(e=>e[0]==='cleanup'),label+' cleanup');
  const links=list(b.world.links);
  for(const [node,name]of s.sourceNames){
   const actual=[],expected=[];for(let edge=b.nodes()[b.ids[name]].deps;edge;edge=links[edge].nextDep)actual.push([b.reverse[links[edge].dep],links[edge].gen]);
   for(let edge=node._deps;edge;edge=edge._nextDep){const name=[...s.accessorIdentities].find(([fn])=>Object.getOwnPropertySymbols(fn).some(key=>fn[key]===edge._dep))?.[1];expected.push([name,edge._gen]);}
   assert.deepEqual(actual,expected,label+' ordered deps');
  }
 }
 const call=()=>{
  const before=b.nodes().length;assert.equal((copied?b.decode(b.encode(bf)):bf)(arg(b)),undefined);assert.equal((copied?s.value({reaction:'ready'}):sf)(arg(s)),undefined);
  const node=s.owner._firstChild,name='#nested'+(s.nestedSerial=(s.nestedSerial??0)+1);s.sourceNames.set(node,name);s.notPending??=node._pendingValue;
  assert.equal(b.ids[name],before);compare('after direct call');
 };
 call();if(rearm)call();
 for(const value of [1,2]){b.set('x',value);s.set('x',value);b.flush();s.flush();compare('after invalidation '+value);assert.equal(b.read('count'),s.read('count'));}
 call();b.set('x',3);s.set('x',3);b.flush();s.flush();compare('after new cycle');
 b.dispose();s.dispose();b.flush();s.flush();compare('after disposal');
 assert.deepEqual([b.world.context,b.world.tracking,b.world.running],[0,false,false]);count++;
}
console.log(`${count} original reaction function-value histories preserve native tracker/input identity, results, arm states, ordered dependencies and cleanup.`);
