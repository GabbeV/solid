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
