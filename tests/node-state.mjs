// State observations only; neither adapter makes a reactive decision here.
import {decode,list} from '../host/bend.mjs';
const disposalSize=d=>'callbacks'in d?list(d.callbacks).length:'callback'in d?1:0;
const nativeDisposalSize=d=>Array.isArray(d)?d.length:d?1:0;
export function bendStates(runtime,names){
  const nodes=runtime.nodes(),extensions=list(runtime.world.extensions),sets=list(runtime.world.pendingSets),value=v=>runtime.errorShape(decode(v,runtime.errors));
  return Object.entries(runtime.ids).filter(([name,id])=>names.includes(name)&&nodes[id].kind.$!=='Signal').sort(([a],[b])=>a.localeCompare(b)).map(([name,id])=>{
    const n=nodes[id],x=extensions[n.x];
    return [name,{flags:n.flags,config:n.config,status:n.status,time:n.time,loading:n.loading,value:value(n.value),pending:'value'in n.pending,pendingValue:'value'in n.pending?value(n.pending.value):undefined,gen:n.depGen,modified:n.modified,previous:value(n.prevValue),disposal:disposalSize(n.disposal),
      x:n.x?{flight:x.inFlight||undefined,teardown:!!x.flightTeardown,error:value(x.error),shown:value(x.shownError),blocked:'value'in x.blocked?value(x.blocked.value):undefined,sources:x.pendingSources?list(sets[x.pendingSources]).filter(id=>id!==0).map(id=>runtime.reverse[id]):undefined,parkedDisposal:disposalSize(x.pendingDisposal)}:null}];
  });
}
export function solidStates(runtime){
  return [...runtime.sourceNames].sort(([,a],[,b])=>a.localeCompare(b)).map(([n,name])=>{
    const x=n._x;
    return [name,{flags:n._flags,config:n._config,status:n._statusFlags,time:n._time,loading:n._loading,value:runtime.errorShape(runtime.observe(n._value)),pending:n._pendingValue!==runtime.notPending,pendingValue:n._pendingValue===runtime.notPending?undefined:runtime.errorShape(runtime.observe(n._pendingValue)),gen:n._depGen,modified:n._modified??false,previous:runtime.errorShape(runtime.observe(n._prevValue)),disposal:nativeDisposalSize(n._disposal),
      x:x?{flight:runtime.futureIdentities.get(x._inFlight),teardown:!!x._flightTeardown,error:runtime.errorShape(x._error),shown:runtime.errorShape(x._shownError),blocked:x._blocked,sources:x._pendingSources?[...x._pendingSources].map(node=>runtime.sourceNames.get(node)):undefined,parkedDisposal:nativeDisposalSize(x._pendingDisposal)}:null}];
  });
}
