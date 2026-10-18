import * as S from '../build/solid.mjs';
export class SolidRuntime {
  constructor() {
    this.accessors={}; this.setters={}; this.traceEvents=[]; this.current=null; this.screens={};
    this.sourceNames=new Map(); this.encountered=new Map(); this.refs=new Map(); this.programs={}; this.nextProgram=1; S.createRoot(dispose=> { this.disposeRoot=dispose; this.owner=S.getOwner(); });
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
    if(e.call)return this.programs[e.call]();
    if(e.seq){let value;for(const part of e.seq)value=this.evaluate(part,prev);return value;}
    if(Object.hasOwn(e,'raise')) throw this.value(e.raise);
    throw new TypeError('Unknown expression');
  }
  errorShape(e) {
    if(e instanceof Error&&Object.hasOwn(e,'source')&&Object.hasOwn(e,'cause')){
      if(!this.encountered.has(e))this.encountered.set(e,this.encountered.size+1);
      return {statusError:this.encountered.get(e),source:this.sourceNames.get(e.source),cause:this.errorShape(e.cause)};
    }
    return e;
  }
  attempt(op,...args) {try{return ['return',this[op](...args)];}catch(e){return ['throw',this.errorShape(e)];}}
  program(name,actions) {
    const self=this,id=this.nextProgram++;
    this.programs[name]=function callback(previousCleanup) {
      for(const [op,...args] of actions) {
        if(op==='emit')self.traceEvents.push(['cleanup',id,args[0]]);
        else if(op==='set')self.setters[args[0]](self.value(args[1]));
        else if(op==='dispose'&&args[0]==='root')self.disposeRoot();
        else if(op==='previousCleanup')previousCleanup();
        else if(op==='cleanup')S.onCleanup(self.programs[args[0]]);
        else if(op==='throw')throw self.value(args[0]);
        else throw new TypeError('Unsupported callback action');
      }
    };
    return id;
  }
  signal(name,value,equals=true) {
    const opts=typeof equals==='boolean'?{equals}:equals;
    const [get,set]=S.createSignal(this.value(value), {...opts,equals:opts.equals===false?false:undefined,_noSnapshot:opts.noSnapshot,unobserved:this.programs[opts.unobserved]}); this.accessors[name]=get; this.setters[name]=set;
  }
  callback(name,expr) { return prev=> {
    this.sourceNames.set(S.getOwner(),name);
    const saved=this.current; this.current=name; this.traceEvents.push(['compute',name]);
    try { return this.evaluate(expr,prev); } finally {this.current=saved;}
  }; }
  memo(name,expr,options={}) {
    const opts={...options,equals:options.equals===false?false:undefined,_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
    if(Object.hasOwn(options,'loadingValue'))opts.loadingValue=this.value(options.loadingValue);
    this.accessors[name]=S.runWithOwner(this.owner,()=>S.createMemo(this.callback(name,expr),opts));
  }
  effect(name,expr,options={}) {
    const {user=false,target=2}=options;
    const apply=(v,p)=> {
      this.traceEvents.push(['apply',name,v,p]); if(!user)this.screens[target]=v;
      if(options.program)this.programs[options.program]();
      return options.cleanup?this.programs[options.cleanup]:undefined;
    };
    const bundle=options.error?{effect:apply,error:(err,cleanup)=>this.programs[options.error](cleanup)}:apply;
    S.runWithOwner(this.owner,()=> (user ? S.createEffect : S.createRenderEffect)(this.callback(name,expr),bundle,options));
  }
  set(name,value) { return this.setters[name](this.value(value)); }
  update(name,expr) { return this.setters[name](prev=>this.evaluate(expr,prev)); }
  read(name) {const value=this.accessors[name](); this.traceEvents.push(['read',this.current,name,value]); return value;}
  flush() { S.flush(); }
  refresh(name) { S.refresh(this.accessors[name]); }
  resetErrorHalt() { S.resetErrorHalt(); }
  dispose() { this.disposeRoot(); }
  trace() { return this.traceEvents; }
  screen(target=2) { return this.screens[target]; }
}
