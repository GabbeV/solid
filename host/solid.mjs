import * as DefaultSolid from '../build/solid.mjs';
export class SolidRuntime {
  constructor({module=DefaultSolid}={}) {
    this.S=module;
    this.accessors={}; this.setters={}; this.traceEvents=[]; this.current=null; this.screens={};
    this.futures={};this.futureIdentities=new Map();this.asyncErrors=[];this.nextFuture=1;this.sourceNames=new Map(); this.encountered=new Map(); this.refs=new Map(); this.programs={}; this.nextProgram=1; this.S.createRoot(dispose=> { this.disposeRoot=dispose; this.owner=this.S.getOwner(); });
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
    if(e.future)return this.futures[e.future].object;
    if(e.read) return this.read(e.read);
    if(e.add) return this.evaluate(e.add[0],prev)+this.evaluate(e.add[1],prev);
    if(e.mul) return this.evaluate(e.mul[0],prev)*this.evaluate(e.mul[1],prev);
    if(e.same) return this.evaluate(e.same[0],prev)===this.evaluate(e.same[1],prev);
    if(e.select) return this.evaluate(e.select[0],prev) ? this.evaluate(e.select[1],prev) : this.evaluate(e.select[2],prev);
    if(e.untrack) return this.S.untrack(()=>this.evaluate(e.untrack,prev));
    if(e.call)return this.programs[e.call]();
    if(e.seq){let value;for(const part of e.seq)value=this.evaluate(part,prev);return value;}
    if(Object.hasOwn(e,'raise')) throw this.value(e.raise);
    throw new TypeError('Unknown expression');
  }
  observe(value) {
    if(this.futureIdentities.has(value))return {async:this.futureIdentities.get(value)};
    return value;
  }
  errorShape(e) {
    if(e instanceof this.S.NotReadyError){
      if(!this.encountered.has(e))this.encountered.set(e,this.encountered.size+1);
      return {notReady:this.encountered.get(e),source:this.sourceNames.get(e.source)??null};
    }
    if(e instanceof Error&&Object.hasOwn(e,'source')&&Object.hasOwn(e,'cause')){
      if(!this.encountered.has(e))this.encountered.set(e,this.encountered.size+1);
      return {statusError:this.encountered.get(e),source:this.sourceNames.get(e.source),cause:this.errorShape(e.cause)};
    }
    return e;
  }
  attempt(op,...args) {try{return ['return',this.observe(this[op](...args))];}catch(e){return ['throw',this.errorShape(e)];}}
  program(name,actions) {
    const self=this,id=this.nextProgram++;
    this.programs[name]=function callback(previousCleanup) {
      for(const [op,...args] of actions) {
        if(op==='emit')self.traceEvents.push(['cleanup',id,args[0]]);
        else if(op==='set')self.setters[args[0]](self.value(args[1]));
        else if(op==='dispose'&&args[0]==='root')self.disposeRoot();
        else if(op==='previousCleanup')previousCleanup();
        else if(op==='cleanup')self.S.onCleanup(self.programs[args[0]]);
        else if(op==='throw')throw self.value(args[0]);
        else throw new TypeError('Unsupported callback action');
      }
    };
    return id;
  }
  future(name,{immediate=false}={}) {
    const id=this.nextFuture++,record={settled:false,rejected:false,value:undefined,observers:[]};
    if(immediate){
      record.object={then:(yes,no)=>{if(record.settled)(record.rejected?no:yes)(record.value);else record.observers.push([yes,no]);}};
      record.deliver=(rejected,value)=>{if(record.settled)return;record.settled=true;record.rejected=rejected;record.value=value;for(const [yes,no] of record.observers)(rejected?no:yes)(value);};
    }else{
      let resolve,reject;const promise=new Promise((a,b)=>{resolve=a;reject=b;});
      // Native promise microtasks invoke the actual source callbacks. Observe
      // callback exceptions as host outcomes instead of unhandled rejections.
      const observed=fn=>value=>{try{return fn(value);}catch(e){this.asyncErrors.push(this.errorShape(e));}};
      record.object={then:(yes,no)=>promise.then(observed(yes),observed(no))};
      promise.catch(()=>{}); // unobserved external rejection is outside engine IO
      record.deliver=(rejected,value)=>{if(record.settled)return;record.settled=true;(rejected?reject:resolve)(value);};
    }
    this.futures[name]=record;this.futureIdentities.set(record.object,id);return id;
  }
  resolve(name,value){this.futures[name].deliver(false,this.value(value));}
  reject(name,error){this.futures[name].deliver(true,this.value(error));}
  signal(name,value,equals=true) {
    const opts=typeof equals==='boolean'?{equals}:equals;
    const [get,set]=this.S.createSignal(this.value(value), {...opts,equals:opts.equals===false?false:undefined,_noSnapshot:opts.noSnapshot,unobserved:this.programs[opts.unobserved]}); this.accessors[name]=get; this.setters[name]=set;
  }
  callback(name,expr) { return prev=> {
    this.sourceNames.set(this.S.getOwner(),name);
    const saved=this.current; this.current=name; this.traceEvents.push(['compute',name]);
    try { return this.evaluate(expr,prev); } finally {this.current=saved;}
  }; }
  memo(name,expr,options={}) {
    const opts={...options,equals:options.equals===false?false:undefined,_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
    if(Object.hasOwn(options,'loadingValue'))opts.loadingValue=this.value(options.loadingValue);
    this.accessors[name]=this.S.runWithOwner(this.owner,()=>this.S.createMemo(this.callback(name,expr),opts));
  }
  effect(name,expr,options={}) {
    const {user=false,target=2}=options;
    const apply=(v,p)=> {
      this.traceEvents.push(['apply',name,v,p]); if(!user)this.screens[target]=v;
      if(options.program)this.programs[options.program]();
      return options.cleanup?this.programs[options.cleanup]:undefined;
    };
    const bundle=options.error?{effect:apply,error:(err,cleanup)=>this.programs[options.error](cleanup)}:apply;
    this.S.runWithOwner(this.owner,()=> (user ? this.S.createEffect : this.S.createRenderEffect)(this.callback(name,expr),bundle,options));
  }
  set(name,value) { return this.setters[name](this.value(value)); }
  update(name,expr) { return this.setters[name](prev=>this.evaluate(expr,prev)); }
  read(name) {const value=this.accessors[name](); this.traceEvents.push(['read',this.current,name,value]); return value;}
  flush() { this.S.flush(); }
  refresh(name) { this.S.refresh(this.accessors[name]); }
  resetErrorHalt() { this.S.resetErrorHalt(); }
  dispose() { this.disposeRoot(); }
  trace() { return this.traceEvents.map(e=>e.map(v=>this.observe(v))); }
  screen(target=2) { return this.observe(this.screens[target]); }
}
