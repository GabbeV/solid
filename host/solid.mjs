import * as S from '../build/solid.mjs';
export class SolidRuntime {
  constructor() {
    this.accessors={}; this.setters={}; this.traceEvents=[]; this.current=null; this.screens={};
    this.refs=new Map(); S.createRoot(dispose=> { this.disposeRoot=dispose; this.owner=S.getOwner(); });
  }
  value(v) {
    if(v && typeof v === 'object' && Object.hasOwn(v,'ref')) {
      if(!this.refs.has(v.ref)) this.refs.set(v.ref,{ref:v.ref});
      return this.refs.get(v.ref);
    }
    return v;
  }
  evaluate(e,prev) {
    if(Object.hasOwn(e,'lit')) return this.value(e.lit);
    if(e.prev) return prev;
    if(e.read) return this.read(e.read);
    if(e.add) return this.evaluate(e.add[0],prev)+this.evaluate(e.add[1],prev);
    if(e.mul) return this.evaluate(e.mul[0],prev)*this.evaluate(e.mul[1],prev);
    if(e.same) return this.evaluate(e.same[0],prev)===this.evaluate(e.same[1],prev);
    if(e.select) return this.evaluate(e.select[0],prev) ? this.evaluate(e.select[1],prev) : this.evaluate(e.select[2],prev);
    if(e.untrack) return S.untrack(()=>this.evaluate(e.untrack,prev));
    if(Object.hasOwn(e,'raise')) throw this.value(e.raise);
    throw new TypeError('Unknown expression');
  }
  signal(name,value,equals=true) {
    const [get,set]=S.createSignal(this.value(value), {equals:equals ? undefined : false}); this.accessors[name]=get; this.setters[name]=set;
  }
  callback(name,expr) { return prev=> {
    const saved=this.current; this.current=name; this.traceEvents.push(['compute',name]);
    try { return this.evaluate(expr,prev); } finally {this.current=saved;}
  }; }
  memo(name,expr,{equals=true,lazy=false}={}) {
    this.accessors[name]=S.runWithOwner(this.owner,()=>S.createMemo(this.callback(name,expr),{equals:equals ? undefined : false,lazy}));
  }
  effect(name,expr,{user=false,target=2,schedule=false,defer=false}={}) {
    S.runWithOwner(this.owner,()=> (user ? S.createEffect : S.createRenderEffect)(this.callback(name,expr),(v,p)=> {
      this.traceEvents.push(['apply',name,v,p]); if(!user)this.screens[target]=v;
    },{schedule,defer}));
  }
  set(name,value) { return this.setters[name](this.value(value)); }
  update(name,expr) { return this.setters[name](prev=>this.evaluate(expr,prev)); }
  read(name) {const value=this.accessors[name](); this.traceEvents.push(['read',this.current,name,value]); return value;}
  flush() { S.flush(); }
  refresh(name) { S.refresh(this.accessors[name]); }
  dispose() { this.disposeRoot(); }
  trace() { return this.traceEvents; }
  screen(target=2) { return this.screens[target]; }
}
