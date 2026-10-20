import {requireTeardownProgram,requireFunctionProgram} from './programs.mjs';
import * as DefaultSolid from '../build/solid.mjs';
import {HostErrors} from './errors.mjs';
export class SolidRuntime {
  constructor({module=DefaultSolid,clock}={}) {
    this.S=module;
    this.clock=clock??{setTimeout,clearTimeout};this.controllers={};this.hostErrors=new HostErrors();
    this.accessors={}; this.setters={}; this.traceEvents=[]; this.current=null; this.screens={};
    this.futures={};this.futureIdentities=new Map();this.asyncErrors=[];this.nextFuture=1;this.nextIterator=1;this.iteratorEvents=[];this.ports={};this.portEvents=[];this.portSnapshots=[];this.sourceNames=new Map(); this.encountered=new Map(); this.refs=new Map(); this.programs={};this.contexts=Object.create(null);this.programActions=new Map();this.callbackFunctions=new Map();this.callbackIdentities=new Map(); this.nextProgram=1; this.S.createRoot(dispose=> { this.disposeRoot=dispose; this.owner=this.S.getOwner(); });this.owners={root:this.owner};this.namedOwners=new Map();this.ownerObjects=new WeakSet();this.anonymousOwners=new Map();this.rootDisposers=new Map([[this.disposeRoot,this.owner]]);this.memoSetters=new WeakSet();this.setterIdentities=new Map();this.setterFunctions=new Map();this.accessorIdentities=new Map();this.programActions.isAccessor=value=>this.accessorIdentities.has(value)||this.setterIdentities.has(value)||this.callbackIdentities.has(value);
  }
  ownerFor(name){
    if(name===null)return null;
    const owner=this.owners[name]??[...this.sourceNames,...this.namedOwners].find(([,label])=>label===name)?.[0];
    if(!owner)throw new TypeError('Unknown owner: '+name);
    return owner;
  }
  callbackValue(name){
    if(!this.programs[name])throw new TypeError('Unknown callback function: '+name);
    requireFunctionProgram(this.programActions,name);
    if(!this.callbackFunctions.has(name)){
      const fn=this.programs[name].bind(null,undefined);this.callbackFunctions.set(name,fn);this.callbackIdentities.set(fn,name);
    }
    return this.callbackFunctions.get(name);
  }
  returnedCleanup(value){
    if(this.callbackIdentities.has(value))requireTeardownProgram(this.programActions,this.callbackIdentities.get(value));
    return value;
  }
  value(v) {
    if(v&&typeof v==='object'&&typeof v.callback==='string')return this.callbackValue(v.callback);
    if(v instanceof this.S.NoOwnerError||v instanceof this.S.ContextNotFoundError)return v;
    if(typeof v==='function'&&!this.rootDisposers.has(v)&&!this.accessorIdentities.has(v)&&!this.setterIdentities.has(v)&&!this.callbackIdentities.has(v))throw new TypeError('Use an opaque {ref: id} token for arbitrary host objects');
    const described=this.hostErrors.describe(v);
    if(described&&typeof described==='object'&&Object.hasOwn(described,'error'))return this.hostErrors.materialize(described);
    if(v&&typeof v==='object'&&typeof v.setter==='string'){
      const set=this.setterFunctions.get(v.setter);
      if(!set)throw new TypeError('Unknown signal setter: '+v.setter);
      return set;
    }
    if(v&&typeof v==='object'&&typeof v.accessor==='string'){
      const binding=this.localSignals?.get(v.accessor),get=binding?.get??this.accessors[v.accessor];
      if(!get||!this.accessorIdentities.has(get))throw new TypeError('Unknown signal accessor: '+v.accessor);
      return get;
    }
    if(v&&typeof v==='object'&&typeof v.rootDisposer==='string'){
      const owner=this.ownerFor(v.rootDisposer),entry=[...this.rootDisposers].find(([,target])=>target===owner);
      if(!entry)throw new TypeError('No bound disposer for owner: '+v.rootDisposer);
      return entry[0];
    }
    if(v&&typeof v==='object'&&Object.hasOwn(v,'owner')&&typeof v.owner==='string')return this.ownerFor(v.owner);
    if(v && typeof v === 'object' && Object.hasOwn(v,'ref')) {
      if(!this.refs.has(v.ref)) this.refs.set(v.ref,{ref:v.ref});
      return this.refs.get(v.ref);
    }
    if(v&&typeof v==='object'&&Object.hasOwn(v,'async')){
      for(const [object,id] of this.futureIdentities)if(id===v.async)return object;
      throw new TypeError('Unknown async object identity');
    }
    return v;
  }
  evaluate(e,prev,values=[],locals=[]) {
    if(Object.hasOwn(e,'lit')) return this.value(e.lit);
    if(e.prev) return prev;
    if(e.getContext){const {name,owner={lit:undefined}}=e.getContext;return this.S.getContext(this.contexts[name],this.evaluate(owner,prev,values,locals));}
    if(e.setContext){const {name,value={lit:undefined},owner={lit:undefined}}=e.setContext;return this.S.setContext(this.contexts[name],this.evaluate(value,prev,values,locals),this.evaluate(owner,prev,values,locals));}
    if(e.owner)return this.S.getOwner();
    if(e.observer)return this.S.getObserver();
    if(e.signalComputeScope){
      const {compute,options={},body={lit:undefined}}=e.signalComputeScope;
      requireTeardownProgram(this.programActions,options.unobserved);
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1);
      const opts={...options,equals:options.equals===false?false:undefined,_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
      if(Object.hasOwn(options,'loadingValue'))opts.loadingValue=this.value(options.loadingValue);
      const [get,set]=this.S.createSignal(next=>{
        const node=this.S.getOwner();this.sourceNames.set(node,name);this.notPending??=node._pendingValue;
        this.traceEvents.push(['compute',name]);return this.evaluate(compute,next,values,locals);
      },opts);
      this.registerComputedAccessor(get,name);this.setterIdentities.set(set,name);this.setterFunctions.set(name,set);this.memoSetters.add(set);
      const binding={get,set,name};(this.localComputedSignals??=new Map()).set(name,binding);
      return this.evaluate(body,prev,values,[binding,...locals]);
    }
    if(e.signalScope){
      const {initial={lit:undefined},options={},body={lit:undefined}}=e.signalScope;
      requireTeardownProgram(this.programActions,options.unobserved);
      const value=this.evaluate(initial,prev,values,locals);
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1);
      const opts={...options,equals:options.equals===false?false:undefined,_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
      if(Object.hasOwn(options,'loadingValue'))opts.loadingValue=this.value(options.loadingValue);
      const [get,set]=this.S.createSignal(typeof value==='function'?this.initializerCallback(name,value):value,opts);
      const binding={get,set,name};
      if(typeof value==='function'){
        this.registerComputedAccessor(get,name);this.memoSetters.add(set);
        (this.localComputedSignals??=new Map()).set(name,binding);
      }else{
        const node=Object.getOwnPropertySymbols(get).map(key=>get[key]).find(value=>value&&typeof value==='object'&&'_pendingValue'in value);
        this.localNotPending??=node._pendingValue;
        this.accessorIdentities.set(get,name);(this.localSignals??=new Map()).set(name,binding);
      }
      this.setterIdentities.set(set,name);this.setterFunctions.set(name,set);
      return this.evaluate(body,prev,values,[binding,...locals]);
    }
    if(Object.hasOwn(e,'localSetter')){
      const binding=locals[e.localSetter];if(!binding)throw new TypeError('Unbound local signal');
      return binding.set;
    }
    if(Object.hasOwn(e,'localAccessor')){
      const binding=locals[e.localAccessor];if(!binding)throw new TypeError('Unbound local signal');
      return binding.get;
    }
    if(Object.hasOwn(e,'localRead')){
      const binding=locals[e.localRead];if(!binding)throw new TypeError('Unbound local signal');
      const value=binding.get(),owner=this.S.getOwner(),reader=owner?._root?owner._parentComputed:owner;
      this.traceEvents.push(['read',this.sourceNames.get(reader)??this.namedOwners.get(reader)??null,binding.name,value]);return value;
    }
    if(e.localWrite){
      const {depth=0,value={lit:undefined},updater=false}=e.localWrite,binding=locals[depth];if(!binding)throw new TypeError('Unbound local signal');
      return updater?binding.set(previous=>this.evaluate(value,previous,values,locals)):this.writeValue(binding.set,this.evaluate(value,prev,values,locals));
    }
    if(e.effectCreate){
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1),options=e.options??{};
      requireTeardownProgram(this.programActions,options.unobserved);requireTeardownProgram(this.programActions,options.cleanup);
      if(Object.hasOwn(e,'body')&&options.program)throw new TypeError('Use either an inline effect body or a named program');
      if(options.returnCleanup&&(options.cleanup||(!Object.hasOwn(e,'body')&&!options.program)))throw new TypeError('Returned cleanup requires a body and excludes static cleanup');
      const apply=(v,p)=>{
        this.traceEvents.push(['apply',name,v,p]);
        if(options.user===false)this.screens[options.target??3]=v;
        const result=Object.hasOwn(e,'body')?this.evaluate(e.body,undefined,[v,p],locals):options.program?this.programs[options.program](undefined,v,p):undefined;
        return options.returnCleanup?this.returnedCleanup(result):options.cleanup?this.programs[options.cleanup]:undefined;
      };
      const bundle=options.error?{effect:apply,error:(error,cleanup)=>this.programs[options.error](cleanup,error)}:apply;
      return (options.user===false?this.S.createRenderEffect:this.S.createEffect)(this.callback(name,e.effectCreate,values,locals),bundle,{...options,unobserved:this.programs[options.unobserved]});
    }
    if(e.memoRead||e.memoAccessor){
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1),options=e.options??{};
      requireTeardownProgram(this.programActions,options.unobserved);
      const opts={...options,equals:options.equals===false?false:undefined,_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
      if(Object.hasOwn(options,'loadingValue'))opts.loadingValue=this.value(options.loadingValue);
      const get=this.S.createMemo(next=>{
        const node=this.S.getOwner();this.sourceNames.set(node,name);this.notPending??=node._pendingValue;
        this.traceEvents.push(['compute',name]);return this.evaluate(e.memoRead??e.memoAccessor,next,values,locals);
      },opts);
      this.registerComputedAccessor(get,name);
      if(e.memoAccessor)return get;
      const value=get(),owner=this.S.getOwner(),reader=owner?._root?owner._parentComputed:owner;
      this.traceEvents.push(['read',this.sourceNames.get(reader)??this.namedOwners.get(reader)??null,name,value]);return value;
    }
    if(e.root)return this.S.createRoot(dispose=>{const owner=this.S.getOwner();this.ownerObjects.add(owner);this.rootDisposers.set(dispose,owner);return this.evaluate(e.root,prev,[dispose],locals);},{transparent:e.transparent??false});
    if(e.disposeRoot)return this.evaluate(e.disposeRoot,prev,values,locals).dispose();
    if(e.disposed)return this.S.isDisposed(this.evaluate(e.disposed,prev,values,locals));
    if(e.withOwner)return this.S.runWithOwner(this.evaluate(e.withOwner[0],prev,values,locals),()=>this.evaluate(e.withOwner[1],prev,values,locals));
    if(e.future)return this.futures[e.future].object;
    if(e.read) return this.read(e.read);
    if(e.add) return this.evaluate(e.add[0],prev,values,locals)+this.evaluate(e.add[1],prev,values,locals);
    if(e.mul) return this.evaluate(e.mul[0],prev,values,locals)*this.evaluate(e.mul[1],prev,values,locals);
    if(e.same) return this.evaluate(e.same[0],prev,values,locals)===this.evaluate(e.same[1],prev,values,locals);
    if(e.select) return this.evaluate(e.select[0],prev,values,locals) ? this.evaluate(e.select[1],prev,values,locals) : this.evaluate(e.select[2],prev,values,locals);
    if(e.untrack) return this.S.untrack(()=>this.evaluate(e.untrack,prev,values,locals));
    if(Object.hasOwn(e,'argument'))return values[e.argument];
    if(e.invokeArgs){
      const {callee,args=[]}=e.invokeArgs;
      if(args.length>2)throw new TypeError('Callback ABI currently admits at most two arguments');
      const fn=this.evaluate(callee,prev,values,locals),arguments_=args.map(arg=>this.evaluate(arg,prev,values,locals));
      const result=this.setterIdentities.has(fn)?this.writeValue(fn,arguments_[0]):fn(...arguments_);
      if(this.accessorIdentities.has(fn))this.observeAccessorRead(fn,result);
      return result;
    }
    if(e.invokeWith){
      const {callee,value={lit:undefined},updater=false}=e.invokeWith;
      const fn=this.evaluate(callee,prev,values,locals);
      if(updater){
        if(this.callbackIdentities.has(fn))throw new TypeError('Updater closure arguments to callback values are not yet translated');
        const result=fn(previous=>this.evaluate(value,previous,values,locals));
        if(this.accessorIdentities.has(fn))this.observeAccessorRead(fn,result);
        return result;
      }
      const argument=this.evaluate(value,prev,values,locals),result=this.setterIdentities.has(fn)?this.writeValue(fn,argument):fn(argument);
      if(this.accessorIdentities.has(fn))this.observeAccessorRead(fn,result);
      return result;
    }
    if(e.invoke){
      const callee=this.evaluate(e.invoke,prev,values,locals),value=callee();
      if(this.accessorIdentities.has(callee))this.observeAccessorRead(callee,value);
      return value;
    }
    if(e.onCleanup){
      const callee=this.evaluate(e.onCleanup,prev,values,locals);
      if(this.S.getOwner()&&this.callbackIdentities.has(callee))requireTeardownProgram(this.programActions,this.callbackIdentities.get(callee));
      return this.S.onCleanup(callee);
    }
    if(e.call){
      if((e.args?.length??0)>2)throw new TypeError('Callback ABI currently admits at most two arguments');
      return this.programs[e.call](undefined,...(e.args??[]).map(arg=>this.evaluate(arg,prev,values,locals)));
    }
    if(e.seq){let value;for(const part of e.seq)value=this.evaluate(part,prev,values,locals);return value;}
    if(Object.hasOwn(e,'raise')) throw this.value(e.raise);
    throw new TypeError('Unknown expression');
  }
  root(name,expr,{owner='root',transparent=false}={}){
    return this.S.runWithOwner(this.ownerFor(owner),()=>this.S.createRoot(dispose=>{
      this.owners[name]=this.S.getOwner();this.rootDisposers.set(dispose,this.owners[name]);return this.evaluate(expr,undefined,[dispose]);
    },{transparent}));
  }
  disposeOwner(name){this.ownerFor(name).dispose();}
  context(name,value,description){
    if(Object.hasOwn(this.contexts,name))throw new TypeError('Context names must be unique');
    if(description!==undefined&&typeof description!=='string')throw new TypeError('Context descriptions must be strings');
    this.contexts[name]=this.S.createContext(this.value(value),description);
  }
  registerComputedAccessor(get,name){
    this.accessorIdentities.set(get,name);this.accessors[name]=get;
    // Read-only identity/state observation for lazy nodes whose body has not
    // yet called getOwner. The native accessor and its metadata stay intact.
    const node=Object.getOwnPropertySymbols(get).map(key=>get[key]).find(value=>value&&typeof value==='object'&&'_pendingValue'in value);
    if(!node)throw new Error('Missing source accessor target metadata');
    this.sourceNames.set(node,name);this.notPending??=node._pendingValue;
  }
  observeAccessorRead(callee,value){
    const owner=this.S.getOwner(),reader=owner?._root?owner._parentComputed:owner;
    this.traceEvents.push(['read',this.sourceNames.get(reader)??this.namedOwners.get(reader)??null,this.accessorIdentities.get(callee),value]);
  }
  observe(value) {
    if(this.callbackIdentities.has(value))return {callback:this.callbackIdentities.get(value)};
    if(value instanceof this.S.NoOwnerError||value instanceof this.S.ContextNotFoundError){
      if(!this.encountered.has(value))this.encountered.set(value,this.encountered.size+1);
      return {[value instanceof this.S.NoOwnerError?'noOwnerError':'contextNotFoundError']:this.encountered.get(value)};
    }
    if(this.setterIdentities.has(value))return {setter:this.setterIdentities.get(value)};
    if(this.accessorIdentities.has(value))return {accessor:this.accessorIdentities.get(value)};
    if(this.rootDisposers.has(value))return {rootDisposer:this.observe(this.rootDisposers.get(value))};
    for(const [name,owner] of Object.entries(this.owners))if(value===owner)return {owner:name};
    if(this.sourceNames.has(value))return {owner:this.sourceNames.get(value)};
    if(this.namedOwners.has(value))return {owner:this.namedOwners.get(value)};
    if(value&&typeof value==='object'&&this.ownerObjects.has(value)){
      if(!this.anonymousOwners.has(value))this.anonymousOwners.set(value,this.anonymousOwners.size+1);
      return {anonymousOwner:this.anonymousOwners.get(value)};
    }
    if(this.futureIdentities.has(value))return {async:this.futureIdentities.get(value)};
    return this.hostErrors.observe(value);
  }
  errorShape(e) {
    if(e instanceof this.S.TimeoutError)return {timeoutError:true,name:e.name,message:e.message};
    if(e instanceof this.S.NotReadyError){
      if(!this.encountered.has(e))this.encountered.set(e,this.encountered.size+1);
      return {notReady:this.encountered.get(e),source:this.sourceNames.get(e.source)??null};
    }
    if(this.hostErrors.ids.has(e))return this.observe(e);
    if(e instanceof Error&&Object.hasOwn(e,'source')&&Object.hasOwn(e,'cause')){
      if(!this.encountered.has(e))this.encountered.set(e,this.encountered.size+1);
      return {statusError:this.encountered.get(e),source:this.sourceNames.get(e.source),cause:this.errorShape(e.cause),message:e.message};
    }
    return this.observe(e);
  }
  withJobs(fn){
    const original=globalThis.queueMicrotask;
    const originalSet=globalThis.setTimeout,originalClear=globalThis.clearTimeout;
    globalThis.queueMicrotask=callback=>original(()=>{try{this.withJobs(callback);}catch(e){this.asyncErrors.push(this.errorShape(e));}});
    if(this.clock){
      globalThis.setTimeout=(callback,delay)=>this.clock.setTimeout(()=>{try{this.withJobs(callback);}catch(e){this.asyncErrors.push(this.errorShape(e));}},delay);
      globalThis.clearTimeout=handle=>this.clock.clearTimeout(handle);
    }
    try{return fn();}finally{globalThis.queueMicrotask=original;globalThis.setTimeout=originalSet;globalThis.clearTimeout=originalClear;}
  }
  attempt(op,...args) {try{return ['return',this.observe(this.withJobs(()=>this[op](...args)))];}catch(e){return ['throw',this.errorShape(e)];}}
  program(name,actions) {
    if(this.programActions.has(name))throw new TypeError('Callback programs cannot be redefined');
    for(const [op,name] of actions)if(op==='cleanup')requireTeardownProgram(this.programActions,name);
    this.programActions.set(name,actions);
    const self=this,id=this.nextProgram++;
    this.programs[name]=function callback(previousCleanup,...values) {
      for(const [op,...args] of actions) {
        if(op==='emit')self.traceEvents.push(['cleanup',id,args[0]]);
        else if(op==='set')self.writeValue(self.setters[args[0]],self.value(args[1]));
        else if(op==='dispose'&&args[0]==='root')self.disposeRoot();
        else if(op==='previousCleanup')previousCleanup();
        else if(op==='cleanup')self.S.onCleanup(self.programs[args[0]]);
        else if(op==='throw')throw self.value(args[0]);
        else if(op==='eval')self.evaluate(args[0],undefined,values);
        else if(op==='return')return self.evaluate(args[0],undefined,values);
        else if(op==='updateExpr')self.setters[args[0]](prev=>self.evaluate(args[1],prev,values));
        else if(op==='setExpr')self.writeValue(self.setters[args[0]],self.evaluate(args[1],undefined,values));
        else if(op==='throwExpr')throw self.evaluate(args[0],undefined,values);
        else throw new TypeError('Unsupported callback action');
      }
    };
    return id;
  }
  recordPort(name,promise){
    this.ports[name]={promise};
    promise.then(value=>{this.portEvents.push(['resolve',name,this.observe(value)]);this.portSnapshots.push([name,this.screen()]);},error=>{this.portEvents.push(['reject',name,this.errorShape(error)]);this.portSnapshots.push([name,this.screen()]);});
  }
  awaitValue(name,expr){this.recordPort(name,this.S.resolve(this.callback('wait:'+name,expr)));}
  awaitUntil(name,expr,options={}){
    const signal=options.signal===undefined?undefined:this.controllers[options.signal].signal;
    this.recordPort(name,this.S.until(this.callback('wait:'+name,expr),{...options,signal}));
  }
  controller(name){
    const controller=new AbortController(),signal=controller.signal,callbacks=new Map();
    const add=signal.addEventListener.bind(signal),remove=signal.removeEventListener.bind(signal);
    add('abort',()=>this.hostErrors.describe(signal.reason),{once:true});
    // Host observation of an escaping engine callback, as for future reactions
    // and microtasks. Native AbortSignal still controls once/order/removal.
    signal.addEventListener=(type,callback,options)=>{
      if(type!=='abort')return add(type,callback,options);
      const observed=()=>{try{this.withJobs(callback);}catch(e){this.asyncErrors.push(this.errorShape(e));}};
      callbacks.set(callback,observed);return add(type,observed,options);
    };
    signal.removeEventListener=(type,callback)=>remove(type,callbacks.get(callback)??callback);
    this.controllers[name]=controller;
  }
  abort(name,reason){
    this.controllers[name].abort(this.value(reason));
  }
  awaitRefresh(name,target){this.recordPort(name,this.S.refresh(this.accessors[target]??(()=>undefined)));}
  promise(name){return this.ports[name].promise;}
  future(name,{immediate=false}={}) {
    const id=this.nextFuture++,record={settled:false,rejected:false,value:undefined,observers:[]};
    if(immediate){
      record.object={then:(yes,no)=>{if(record.settled)(record.rejected?no:yes)?.(record.value);else record.observers.push([yes,no]);}};
      record.deliver=(rejected,value)=>{if(record.settled)return;record.settled=true;record.rejected=rejected;record.value=value;for(const [yes,no] of record.observers)(rejected?no:yes)?.(value);};
    }else{
      let resolve,reject;const promise=new Promise((a,b)=>{resolve=a;reject=b;});
      // Native promise microtasks invoke the actual source callbacks. Observe
      // callback exceptions as host outcomes instead of unhandled rejections.
      const observed=fn=>value=>{try{return this.withJobs(()=>fn(value));}catch(e){this.asyncErrors.push(this.errorShape(e));}};
      record.object={then:(yes,no)=>promise.then(typeof yes==='function'?observed(yes):yes,typeof no==='function'?observed(no):no)};
      promise.catch(()=>{}); // unobserved external rejection is outside engine IO
      record.deliver=(rejected,value)=>{if(record.settled)return;record.settled=true;(rejected?reject:resolve)(value);};
    }
    this.futures[name]=record;this.futureIdentities.set(record.object,id);return id;
  }
  stream(name,steps=[],options={}) {
    const id=this.nextFuture++,self=this;
    const object={ [Symbol.asyncIterator]() {
      const iterator=self.nextIterator++;let cursor=0;
      self.iteratorEvents.push(['start',name,iterator]);
      const it={next(){
        self.iteratorEvents.push(['next',iterator,cursor]);
        const step=steps[cursor++]??{done:true};
        if(Object.hasOwn(step,'throw'))throw self.value(step.throw);
        if(step.future)return self.futures[step.future].object;
        return {done:step.done??false,value:self.value(step.value)};
      }};
      if(options.hasReturn??true)it.return=()=>{
        self.iteratorEvents.push(['return',iterator]);
        if(Object.hasOwn(options,'returnThrows'))throw self.value(options.returnThrows);
        return self.futures[options.returnFuture]?.object;
      };
      return it;
    }};
    this.futures[name]={object};this.futureIdentities.set(object,id);return id;
  }
  resolveStep(name,value,done=false){this.futures[name].deliver(false,{done,value:this.value(value)});}
  resolveStream(name,stream){this.futures[name].deliver(false,this.futures[stream].object);}
  iteratorIO(){return this.iteratorEvents;}
  resolve(name,value){this.futures[name].deliver(false,this.value(value));}
  reject(name,error){this.futures[name].deliver(true,this.value(error));}
  signal(name,value,equals=true) {
    const opts=typeof equals==='boolean'?{equals}:equals;
    requireTeardownProgram(this.programActions,opts.unobserved);
    const initial=this.value(value);
    const options={...opts,equals:opts.equals===false?false:undefined,_noSnapshot:opts.noSnapshot,unobserved:this.programs[opts.unobserved]};
    if(Object.hasOwn(opts,'loadingValue'))options.loadingValue=this.value(opts.loadingValue);
    const [get,set]=this.S.createSignal(typeof initial==='function'?this.initializerCallback(name,initial):initial,options);
    this.accessors[name]=get; this.setters[name]=set;this.accessorIdentities.set(get,name);this.setterIdentities.set(set,name);this.setterFunctions.set(name,set);
    if(typeof initial==='function'){this.registerComputedAccessor(get,name);this.memoSetters.add(set);}
  }
  // Observation wrapper for an admitted first-class initializer. It calls the
  // original bound function with exactly its source previous-value argument.
  // Direct unwrapped native controls separately check result/state/lifetime.
  initializerCallback(name,fn){return previous=>{
    const node=this.S.getOwner();this.sourceNames.set(node,name);this.notPending??=node._pendingValue;
    this.traceEvents.push(['compute',name]);
    if(this.setterIdentities.has(fn))return this.writeValue(fn,previous);
    const result=fn(previous);
    if(this.accessorIdentities.has(fn))this.observeAccessorRead(fn,result);
    return result;
  };}
  callback(name,expr,values=[],locals=[]) { return prev=> {
    this.sourceNames.set(this.S.getOwner(),name);
    this.notPending??=this.S.getOwner()._pendingValue; // read-only probe of the fresh-node sentinel
    const saved=this.current; this.current=name; this.traceEvents.push(['compute',name]);
    try { return this.evaluate(expr,prev,values,locals); } finally {this.current=saved;}
  }; }
  memo(name,expr,options={}) {
    requireTeardownProgram(this.programActions,options.unobserved);
    const opts={...options,equals:options.equals===false?false:undefined,_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
    if(Object.hasOwn(options,'loadingValue'))opts.loadingValue=this.value(options.loadingValue);
    const parent=this.ownerFor(Object.hasOwn(options,'owner')?options.owner:'root');
    this.accessors[name]=this.S.runWithOwner(parent,()=>this.S.createMemo(this.callback(name,expr),opts));
    this.registerComputedAccessor(this.accessors[name],name);
    // Read-only construction observation: a lazy body has not called getOwner
    // yet. In this grammar it cannot construct children before its first pass.
    if(options.lazy&&parent)this.namedOwners.set(parent._firstChild,name);
  }
  effect(name,expr,options={}) {
    requireTeardownProgram(this.programActions,options.unobserved);
    requireTeardownProgram(this.programActions,options.cleanup);
    if(options.returnCleanup&&(options.cleanup||!options.program))throw new TypeError('Returned cleanup requires a body and excludes static cleanup');
    const {user=false,target=2}=options;
    const apply=(v,p)=> {
      this.traceEvents.push(['apply',name,v,p]); if(!user)this.screens[target]=v;
      const result=options.program?this.programs[options.program](undefined,v,p):undefined;
      return options.returnCleanup?this.returnedCleanup(result):options.cleanup?this.programs[options.cleanup]:undefined;
    };
    const bundle=options.error?{effect:apply,error:(err,cleanup)=>this.programs[options.error](cleanup,err)}:apply;
    this.S.runWithOwner(this.ownerFor(Object.hasOwn(options,'owner')?options.owner:'root'),()=> (user ? this.S.createEffect : this.S.createRenderEffect)(this.callback(name,expr),bundle,options));
  }
  writeValue(setter,value){
    const result=setter(value);
    // A held setMemo can invoke a getter's returned function again. Its final
    // setter result then differs from the getter result; do not invent that
    // read observation. Native value/state controls cover this combination,
    // while complete internal getter traces remain an observation limit.
    if(this.accessorIdentities.has(value)&&!this.memoSetters.has(setter))this.observeAccessorRead(value,result);
    return result;
  }
  set(name,value) { return this.writeValue(this.setters[name],this.value(value)); }
  update(name,expr) { return this.setters[name](prev=>this.evaluate(expr,prev)); }
  read(name) {
    const value=this.accessors[name](),owner=this.S.getOwner(),reader=owner?._root?owner._parentComputed:owner;
    this.traceEvents.push(['read',this.sourceNames.get(reader)??this.namedOwners.get(reader)??null,name,value]);return value;
  }
  flush() { this.S.flush(); }
  refresh(name) { this.awaitRefresh('refresh#'+Object.keys(this.ports).length,name); }
  resetErrorHalt() { this.S.resetErrorHalt(); }
  dispose() { this.disposeRoot(); }
  trace() { return this.traceEvents.map(e=>e.map(v=>this.observe(v))); }
  screen(target=2) { return this.observe(this.screens[target]); }
}
