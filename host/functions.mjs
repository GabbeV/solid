// Materialization only: invocation re-enters the Bend owner implementation.
// One bound disposer exists per root, in a separate namespace from owner data.
export class RootDisposers {
  constructor(invoke){this.invoke=invoke;this.byOwner=new Map();this.identities=new WeakMap();}
  get(owner){
    if(!this.byOwner.has(owner)){
      const dispose=()=>this.invoke(owner);
      this.byOwner.set(owner,dispose);this.identities.set(dispose,owner);
    }
    return this.byOwner.get(owner);
  }
  identity(value){return typeof value==='function'?this.identities.get(value):undefined;}
}

// One escaped accessor per admitted signal. Invocation re-enters core.read;
// this cache supplies native callable identity only.
export class SourceAccessors extends RootDisposers {}

// Escaped data-signal setters retain a separate function identity. One raw
// argument is passed back to the Bend call machine; arbitrary JS updaters are
// outside this codec and are represented by the explicit expression-call ABI.
export class SourceSetters {
  constructor(invoke){this.invoke=invoke;this.bySignal=new Map();this.identities=new WeakMap();}
  get(signal){
    if(!this.bySignal.has(signal)){
      const set=value=>this.invoke(signal,value);
      this.bySignal.set(signal,set);this.identities.set(set,signal);
    }
    return this.bySignal.get(signal);
  }
  identity(value){return typeof value==='function'?this.identities.get(value):undefined;}
}

// The public named function binds the helper parameter to undefined. It keeps
// its own stable identity, separate from the static cleanup program wrapper.
export class ProgramFunctions extends SourceSetters {
  get(program){
    if(!this.bySignal.has(program)){
      const call=(first,second)=>this.invoke(program,first,second);
      this.bySignal.set(program,call);this.identities.set(call,program);
    }
    return this.bySignal.get(program);
  }
}
