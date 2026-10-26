import {requireTeardownProgram,requireFunctionProgram} from './programs.mjs';
import {requireActionProtocol,bindActionArguments} from './actions.mjs';
import * as DefaultSolid from '../build/solid.mjs';
import {HostErrors} from './errors.mjs';
export class SolidRuntime {
  constructor({module=DefaultSolid,clock}={}) {
    this.S=module;
    this.clock=clock??{setTimeout,clearTimeout};this.controllers={};this.hostErrors=new HostErrors();
    this.accessors={}; this.setters={}; this.traceEvents=[]; this.current=null; this.screens={};
    this.futures={};this.futureIdentities=new Map();this.asyncErrors=[];this.nextFuture=1;this.nextIterator=1;this.iteratorEvents=[];this.ports={};this.portEvents=[];this.portSnapshots=[];this.sourceNames=new Map(); this.encountered=new Map(); this.refs=new Map(); this.programs={};this.contexts=Object.create(null);this.programActions=new Map();this.callbackFunctions=new Map();this.callbackIdentities=new Map(); this.nextProgram=1; this.S.createRoot(dispose=> { this.disposeRoot=dispose; this.owner=this.S.getOwner(); });this.owners={root:this.owner};this.namedOwners=new Map();this.ownerObjects=new WeakSet();this.anonymousOwners=new Map();this.rootDisposers=new Map([[this.disposeRoot,this.owner]]);this.memoSetters=new WeakSet();this.setterIdentities=new Map();this.setterFunctions=new Map();this.accessorIdentities=new Map();this.programActions.isAccessor=value=>this.accessorIdentities.has(value)||this.setterIdentities.has(value)||this.callbackIdentities.has(value);
  }
  comparator(value){
    if(value&&typeof value==='object'&&typeof value.callback==='string')return this.callbackValue(value.callback);
    return value===false?false:undefined;
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
    if(v&&typeof v==='object'&&typeof v.reaction==='string'){
      const value=this.reactionValues?.get(v.reaction);if(!value)throw new TypeError('Unknown reaction: '+v.reaction);return value;
    }
    if(v&&typeof v==='object'&&typeof v.callback==='string')return this.callbackValue(v.callback);
    if(v instanceof this.S.NoOwnerError||v instanceof this.S.ContextNotFoundError)return v;
    if(typeof v==='function'&&!this.rootDisposers.has(v)&&!this.accessorIdentities.has(v)&&!this.setterIdentities.has(v)&&!this.callbackIdentities.has(v)&&!this.argumentFunctions?.has(v))throw new TypeError('Use an opaque {ref: id} token for arbitrary host objects');
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
    if(e.flatten){
      const {children,skipNonRendered=false,doNotUnwrap=false}=e.flatten;
      const result=this.S.flatten(this.evaluate(children,prev,values,locals),{skipNonRendered,doNotUnwrap});
      if(typeof result==='function'&&!this.callbackIdentities.has(result)&&!this.accessorIdentities.has(result)&&!this.setterIdentities.has(result)&&!this.rootDisposers.has(result)){
        const name='@flatten'+(this.flattenSerial=(this.flattenSerial??0)+1);
        this.callbackFunctions.set(name,result);this.callbackIdentities.set(result,name);this.programActions.set(name,[]);this.programs[name]=(_helper,...args)=>result(...args);
      }
      return result;
    }
    if(e.mapArray){
      const {list,map,fallback,keyed:inputKeyed}=e.mapArray;
      const mapper=this.evaluate(map,prev,values,locals),keyed=inputKeyed===undefined||typeof inputKeyed==='boolean'?inputKeyed:this.evaluate(inputKeyed,prev,values,locals),name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1),options={keyed};
      if(keyed!==undefined&&typeof keyed!=='boolean'&&typeof keyed!=='function')throw new TypeError('Unsupported mapArray keying mode');
      if(typeof keyed==='function')options.keyed=item=>{const value=keyed(item);if(this.accessorIdentities.has(keyed))this.observeAccessorRead(keyed,value);return value;};
      if(Object.hasOwn(e.mapArray,'fallback'))options.fallback=()=>this.evaluate(fallback,undefined,values,locals);
      const observeMapper=(...args)=>{
        if(keyed===false||typeof keyed==='function'){
          const item=args[0],label='#row'+(this.rowSerial=(this.rowSerial??0)+1);
          this.accessorIdentities.set(item,label);this.accessors[label]=item;
          const node=Object.getOwnPropertySymbols(item).map(key=>item[key]).find(value=>value&&typeof value==='object'&&'_pendingValue'in value);
          if(!node)throw new Error('Missing native row accessor metadata');
          (this.rowSources??=new Map()).set(node,label);
        }
        if(keyed!==false&&mapper.length>1){
          const accessor=args[1],label='#listIndex'+(this.listIndexSerial=(this.listIndexSerial??0)+1);
          this.accessorIdentities.set(accessor,label);this.accessors[label]=accessor;
          const node=Object.getOwnPropertySymbols(accessor).map(key=>accessor[key]).find(value=>value&&typeof value==='object'&&'_pendingValue'in value);
          if(!node)throw new Error('Missing native index accessor metadata');
          (this.rowSources??=new Map()).set(node,label);
        }
        const result=mapper(...args);
        if(this.accessorIdentities.has(mapper))this.observeAccessorRead(mapper,result);
        return result;
      };
      Object.defineProperty(observeMapper,'length',{value:mapper.length});
      const get=this.S.mapArray(this.callback(name,list,values,locals),observeMapper,options);
      this.registerComputedAccessor(get,name);return get;
    }
    if(e.repeat){
      const {count,map,from,fallback}=e.repeat,mapper=this.evaluate(map,prev,values,locals);
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1),options={};
      if(Object.hasOwn(e.repeat,'from'))options.from=()=>this.evaluate(from,undefined,values,locals);
      if(Object.hasOwn(e.repeat,'fallback'))options.fallback=()=>this.evaluate(fallback,undefined,values,locals);
      const get=this.S.repeat(this.callback(name,count,values,locals),mapper,options);
      this.registerComputedAccessor(get,name);return get;
    }
    if(e.array){
      if(!Array.isArray(e.array)||Array.from({length:e.array.length},(_,i)=>Object.hasOwn(e.array,i)).some(own=>!own))throw new TypeError('Typed array literals require dense expression syntax');
      return e.array.map(part=>this.evaluate(part,prev,values,locals));
    }
    if(e.arrayAt){const array=this.evaluate(e.arrayAt.array,prev,values,locals),index=this.evaluate(e.arrayAt.index,prev,values,locals);return array[index];}
    if(e.arrayLength)return this.evaluate(e.arrayLength,prev,values,locals).length;
    if(e.actionCreate)return this.createAction(e.actionCreate,prev,values,locals,true);
    if(e.action){const fn=this.createAction(e.action,prev,values,locals,false);return this.invokeAction(fn,[]);}
    if(Object.hasOwn(e,'actionArgument'))throw new TypeError('Unbound action argument');
    if(e.iteratorResult)return {done:e.iteratorResult.done??false,value:this.evaluate(e.iteratorResult.value??{lit:undefined},prev,values,locals)};
    if(e.getContext){const {name,owner={lit:undefined}}=e.getContext;return this.S.getContext(this.contexts[name],this.evaluate(owner,prev,values,locals));}
    if(e.setContext){const {name,value={lit:undefined},owner={lit:undefined}}=e.setContext;return this.S.setContext(this.contexts[name],this.evaluate(value,prev,values,locals),this.evaluate(owner,prev,values,locals));}
    if(e.owner){const owner=this.S.getOwner();if(owner?._root)this.ownerObjects.add(owner);return owner;}
    if(e.observer)return this.S.getObserver();
    if(e.reactionCreate){return this.createReaction(e.reactionCreate.body,e.reactionCreate.options??{},values,locals);}
    if(e.reactionArm){
      const track=this.evaluate(e.reactionArm.callee,prev,values,locals),body=e.reactionArm.tracking;
      return this.armReaction(track,()=>this.evaluate(body,undefined,values,locals));
    }
    if(Object.hasOwn(e,'onFlush')){
      this.S.onFlush(()=>{try{this.evaluate(e.onFlush,undefined,values,locals);}catch(error){this.asyncErrors.push(this.errorShape(error));}});
      return;
    }
    if(e.settled){
      const owner=this.S.getOwner(),owned=owner&&!(owner._config&16);
      const name=owned?'#nested'+(this.nestedSerial=(this.nestedSerial??0)+1):undefined;
      return this.createSettled(name,e.settled,values,locals);
    }
    if(e.trackedCreate){
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1);
      return this.createTracked(name,e.trackedCreate,values,locals);
    }
    if(e.optimisticComputeScope){
      const {compute,options={},body={lit:undefined}}=e.optimisticComputeScope;
      requireTeardownProgram(this.programActions,options.unobserved);
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1);
      const opts={...options,equals:this.comparator(options.equals),_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
      if(Object.hasOwn(options,'loadingValue'))opts.loadingValue=this.value(options.loadingValue);
      const [get,set]=this.S.createOptimistic(next=>{
        const node=this.S.getOwner();this.sourceNames.set(node,name);this.notPending??=node._pendingValue;
        this.traceEvents.push(['compute',name]);return this.evaluate(compute,next,values,locals);
      },opts);
      this.registerComputedAccessor(get,name);this.setterIdentities.set(set,name);this.setterFunctions.set(name,set);
      const binding={get,set,name};(this.localComputedSignals??=new Map()).set(name,binding);
      return this.evaluate(body,prev,values,[binding,...locals]);
    }
    if(e.optimisticScope){
      const {initial={lit:undefined},options={},body={lit:undefined}}=e.optimisticScope;
      requireTeardownProgram(this.programActions,options.unobserved);
      const value=this.evaluate(initial,prev,values,locals);
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1);
      const opts={...options,equals:this.comparator(options.equals),_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
      if(Object.hasOwn(options,'loadingValue'))opts.loadingValue=this.value(options.loadingValue);
      const [get,set]=this.S.createOptimistic(typeof value==='function'?this.initializerCallback(name,value):value,opts);
      const binding={get,set,name};
      if(typeof value==='function'){
        this.registerComputedAccessor(get,name);
        (this.localComputedSignals??=new Map()).set(name,binding);
      }else{
        const node=Object.getOwnPropertySymbols(get).map(key=>get[key]).find(value=>value&&typeof value==='object'&&'_pendingValue'in value);
        this.localNotPending??=node._pendingValue;
        this.accessorIdentities.set(get,name);(this.localSignals??=new Map()).set(name,binding);
      }
      this.setterIdentities.set(set,name);this.setterFunctions.set(name,set);
      return this.evaluate(body,prev,values,[binding,...locals]);
    }
    if(e.signalComputeScope){
      const {compute,options={},body={lit:undefined}}=e.signalComputeScope;
      requireTeardownProgram(this.programActions,options.unobserved);
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1);
      const opts={...options,equals:this.comparator(options.equals),_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
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
      const opts={...options,equals:this.comparator(options.equals),_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
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
    if(e.deferredRead||e.deferredAccessor){
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1),options=e.options??{};
      requireTeardownProgram(this.programActions,options.unobserved);
      const opts={...options,equals:this.comparator(options.equals),_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
      if(Object.hasOwn(options,'loadingValue'))opts.loadingValue=this.value(options.loadingValue);
      const get=this.S.createDeferred(next=>{
        const node=this.S.getOwner();this.sourceNames.set(node,name);this.notPending??=node._pendingValue;
        this.traceEvents.push(['compute',name]);return this.evaluate(e.deferredRead??e.deferredAccessor,next,values,locals);
      },opts);
      this.registerComputedAccessor(get,name);
      if(e.deferredAccessor)return get;
      const value=get(),owner=this.S.getOwner(),reader=owner?._root?owner._parentComputed:owner;
      this.traceEvents.push(['read',this.sourceNames.get(reader)??this.namedOwners.get(reader)??null,name,value]);return value;
    }
    if(e.memoRead||e.memoAccessor){
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1),options=e.options??{};
      requireTeardownProgram(this.programActions,options.unobserved);
      const opts={...options,equals:this.comparator(options.equals),_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
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
    if(e.createOwner){const owner=this.S.createOwner({transparent:e.createOwner.transparent??false});this.ownerObjects.add(owner);return owner;}
    if(e.disposeRoot)return this.evaluate(e.disposeRoot,prev,values,locals).dispose(e.self??true);
    if(e.disposed)return this.S.isDisposed(this.evaluate(e.disposed,prev,values,locals));
    if(e.withOwner)return this.S.runWithOwner(this.evaluate(e.withOwner[0],prev,values,locals),()=>this.evaluate(e.withOwner[1],prev,values,locals));
    if(e.future)return this.futures[e.future].object;
    if(e.read) return this.read(e.read);
    if(e.add) return this.evaluate(e.add[0],prev,values,locals)+this.evaluate(e.add[1],prev,values,locals);
    if(e.mul) return this.evaluate(e.mul[0],prev,values,locals)*this.evaluate(e.mul[1],prev,values,locals);
    if(e.same) return this.evaluate(e.same[0],prev,values,locals)===this.evaluate(e.same[1],prev,values,locals);
    if(e.select) return this.evaluate(e.select[0],prev,values,locals) ? this.evaluate(e.select[1],prev,values,locals) : this.evaluate(e.select[2],prev,values,locals);
    if(Object.hasOwn(e,'flush'))return this.S.flush(()=>this.evaluate(e.flush,prev,values,locals));
    if(Object.hasOwn(e,'flushCall'))return this.S.flush(this.evaluate(e.flushCall,prev,values,locals));
    if(e.flushNow)return this.S.flush();
    if(e.affects){const target=this.evaluate(e.affects.target??e.affects,prev,values,locals),key=this.evaluate(e.affects.key??{lit:undefined},prev,values,locals);return this.S.affects(target,key);}
    if(e.latest)return this.S.latest(()=>this.evaluate(e.latest,prev,values,locals));
    if(e.isPending)return this.S.isPending(()=>this.evaluate(e.isPending,prev,values,locals));
    if(e.untrack) return this.S.untrack(()=>this.evaluate(e.untrack,prev,values,locals));
    if(Object.hasOwn(e,'argument'))return values[e.argument];
    if(e.invokeArgs){
      const {callee,args=[]}=e.invokeArgs;
      const fn=this.evaluate(callee,prev,values,locals),arguments_=args.map(arg=>this.evaluate(arg,prev,values,locals));
      const result=this.setterIdentities.has(fn)?this.writeValue(fn,arguments_[0]):this.invokeAction(fn,arguments_);
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
      const argument=this.evaluate(value,prev,values,locals),result=this.setterIdentities.has(fn)?this.writeValue(fn,argument):this.invokeAction(fn,[argument]);
      if(this.accessorIdentities.has(fn))this.observeAccessorRead(fn,result);
      return result;
    }
    if(e.invoke){
      const callee=this.evaluate(e.invoke,prev,values,locals),value=this.invokeAction(callee,[]);
      if(this.accessorIdentities.has(callee))this.observeAccessorRead(callee,value);
      return value;
    }
    if(Object.hasOwn(e,'from'))return this.S.from(this.evaluate(e.from,prev,values,locals));
    if(e.onCleanup){
      const callee=this.evaluate(e.onCleanup,prev,values,locals);
      if(this.S.getOwner()&&this.callbackIdentities.has(callee))requireTeardownProgram(this.programActions,this.callbackIdentities.get(callee));
      return this.S.onCleanup(callee);
    }
    if(e.call){
      return this.programs[e.call](undefined,...(e.args??[]).map(arg=>this.evaluate(arg,prev,values,locals)));
    }
    if(e.seq){let value;for(const part of e.seq)value=this.evaluate(part,prev,values,locals);return value;}
    if(Object.hasOwn(e,'raise')) throw this.value(e.raise);
    throw new TypeError('Unknown expression');
  }
  createAction(plan,prev,values,locals,firstClass){
    requireActionProtocol(plan);
    const self=this,state={calls:[]};
    const fn=this.S.action(function(...args){
      // Reserve before user factory code, as the invocation Promise already
      // exists when Solid enters genFn. This is an observation identity only.
      state.calls.push(self.nextFuture++);
      const bound=bindActionArguments(plan,args);
      self.evaluate(bound.factory??{lit:undefined},prev,values,locals);
      let cursor=0,closed=false;
      const step=(value,rejected)=>{
        if(closed){if(rejected)throw value;return {done:true,value:undefined};}
        const method=bound.steps[cursor++];
        if(!method){closed=true;if(rejected)throw value;return {done:true,value:undefined};}
        try{
          if(rejected&&!Object.hasOwn(method,'throw'))throw value;
          const result=self.evaluate(rejected?method.throw:method.next,undefined,[value,rejected],locals);
          if(result?.done)closed=true;
          return result;
        }catch(error){closed=true;throw error;}
      };
      return {next:value=>step(value,false),throw:error=>step(error,true)};
    });
    (this.actionFunctions??=new Map()).set(fn,state);
    if(firstClass){
      const name='@action'+(this.actionFunctionSerial=(this.actionFunctionSerial??0)+1);
      this.callbackFunctions.set(name,fn);this.callbackIdentities.set(fn,name);this.programActions.set(name,[]);
      this.programs[name]=(_helper,...args)=>this.invokeAction(fn,args);
    }
    return fn;
  }
  invokeAction(fn,args){
    const state=this.actionFunctions?.get(fn),before=state?.calls.length;
    const result=fn(...args);
    if(state)this.observeActionReturn(fn,result,before);
    return result;
  }
  observeActionReturn(fn,promise,index){
    const state=this.actionFunctions.get(fn),id=state.calls[index];
    if(id===undefined)throw new Error('Missing native action invocation observation');
    promise.catch(()=>{});this.futureIdentities.set(promise,id);return promise;
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
    if(Array.isArray(value)){
      this.observingArrays??=new Set();if(this.observingArrays.has(value))throw new TypeError('Cyclic arrays are outside the observation grammar');this.observingArrays.add(value);
      try{return value.map(item=>this.observe(item));}finally{this.observingArrays.delete(value);}
    }
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
    if(typeof value==='function'){
      this.opaqueFunctions??=new WeakMap();
      if(!this.opaqueFunctions.has(value))this.opaqueFunctions.set(value,this.opaqueFunctionSerial=(this.opaqueFunctionSerial??0)+1);
      return {opaqueFunction:this.opaqueFunctions.get(value)};
    }
    return this.hostErrors.observe(value);
  }
  sourceLabel(node){
    const named=this.sourceNames.get(node);if(named!==undefined)return named;
    for(const [name,get]of Object.entries(this.accessors))if(Object.getOwnPropertySymbols(get).some(key=>get[key]===node))return name;
  }
  errorShape(e) {
    if(e instanceof this.S.TimeoutError)return {timeoutError:true,name:e.name,message:e.message};
    if(e instanceof this.S.NotReadyError){
      if(!this.encountered.has(e))this.encountered.set(e,this.encountered.size+1);
      return {notReady:this.encountered.get(e),source:this.sourceLabel(e.source)??null};
    }
    if(this.hostErrors.ids.has(e))return this.observe(e);
    if(e instanceof Error&&Object.hasOwn(e,'source')&&Object.hasOwn(e,'cause')){
      if(!this.encountered.has(e))this.encountered.set(e,this.encountered.size+1);
      return {statusError:this.encountered.get(e),source:this.sourceLabel(e.source),cause:this.errorShape(e.cause),message:e.message};
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
  program(name,actions,arity=0) {
    if(!Number.isSafeInteger(arity)||arity<0)throw new TypeError('Function arity must be a natural number');
    if(this.programActions.has(name))throw new TypeError('Callback programs cannot be redefined');
    for(const [op,name] of actions)if(op==='cleanup')requireTeardownProgram(this.programActions,name);
    this.programActions.set(name,actions);
    const self=this,id=this.nextProgram++;
    this.programs[name]=function callback(previousCleanup,...values) {
      self.argumentFunctions??=new WeakSet();for(const value of values)if(typeof value==='function')self.argumentFunctions.add(value);
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
    Object.defineProperty(this.programs[name],'length',{value:arity+1});
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
  runAction(name,plan){const promise=this.evaluate({action:plan});this.recordPort(name,promise);return promise;}
  future(name,{immediate=false}={}) {
    const id=this.nextFuture++,record={settled:false,rejected:false,value:undefined,observers:[],thenCalls:0};
    if(immediate){
      record.object={then:(yes,no)=>{record.thenCalls++;if(record.settled)(record.rejected?no:yes)?.(record.value);else record.observers.push([yes,no]);}};
      record.deliver=(rejected,value)=>{if(record.settled)return;record.settled=true;record.rejected=rejected;record.value=value;for(const [yes,no] of record.observers)(rejected?no:yes)?.(value);};
    }else{
      let resolve,reject;const promise=new Promise((a,b)=>{resolve=a;reject=b;});
      // Native promise microtasks invoke the actual source callbacks. Observe
      // callback exceptions as host outcomes instead of unhandled rejections.
      const observed=fn=>value=>{try{return this.withJobs(()=>fn(value));}catch(e){this.asyncErrors.push(this.errorShape(e));}};
      record.object={then:(yes,no)=>{record.thenCalls++;return promise.then(typeof yes==='function'?observed(yes):yes,typeof no==='function'?observed(no):no);}};
      promise.catch(()=>{}); // unobserved external rejection is outside engine IO
      record.deliver=(rejected,value)=>{if(record.settled)return;record.settled=true;(rejected?reject:resolve)(value);};
    }
    this.futures[name]=record;this.futureIdentities.set(record.object,id);return id;
  }
  stream(name,steps=[],options={}) {
    const id=this.nextFuture++,self=this;
    const object={ [Symbol.asyncIterator]() {
      if(Object.hasOwn(options,'factoryThrows')){
        const error=self.value(options.factoryThrows);
        self.iteratorEvents.push(['factory-throw',name,self.errorShape(error)]);
        throw error;
      }
      const iterator=self.nextIterator++;let cursor=0;
      self.iteratorEvents.push(['start',name,iterator]);
      const it={next(...args){
        (self.iteratorMethodEvents??=[]).push(['next',iterator,args.map(value=>self.observe(value))]);
        self.iteratorEvents.push(['next',iterator,cursor]);
        const step=steps[cursor++]??{done:true};
        if(Object.hasOwn(step,'throw'))throw self.value(step.throw);
        if(step.future)return self.futures[step.future].object;
        return {done:step.done??false,value:self.value(step.value)};
      }};
      if(options.hasReturn??true)it.return=(...args)=>{
        (self.iteratorMethodEvents??=[]).push(['return',iterator,args.map(value=>self.observe(value))]);
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
  thenIO(){return Object.entries(this.futures).filter(([,record])=>typeof record.thenCalls==='number').map(([name,record])=>[name,record.thenCalls]);}
  iteratorMethods(){return this.iteratorMethodEvents??[];}
  iteratorIO(){return this.iteratorEvents;}
  resolve(name,value){this.futures[name].deliver(false,this.value(value));}
  reject(name,error){this.futures[name].deliver(true,this.value(error));}
  signal(name,value,equals=true) {
    const opts=typeof equals==='boolean'?{equals}:equals;
    requireTeardownProgram(this.programActions,opts.unobserved);
    const initial=this.value(value);
    const options={...opts,equals:this.comparator(opts.equals),_noSnapshot:opts.noSnapshot,unobserved:this.programs[opts.unobserved]};
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
  deferred(name,expr,options={}) {
    requireTeardownProgram(this.programActions,options.unobserved);
    const opts={...options,equals:this.comparator(options.equals),_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
    if(Object.hasOwn(options,'loadingValue'))opts.loadingValue=this.value(options.loadingValue);
    const parent=this.ownerFor(Object.hasOwn(options,'owner')?options.owner:'root');
    this.accessors[name]=this.S.runWithOwner(parent,()=>this.S.createDeferred(this.callback(name,expr),opts));
    this.registerComputedAccessor(this.accessors[name],name);
    // Read-only construction observation: a lazy body has not called getOwner
    // yet. In this grammar it cannot construct children before its first pass.
    if(options.lazy&&parent)this.namedOwners.set(parent._firstChild,name);
  }
  memo(name,expr,options={}) {
    requireTeardownProgram(this.programActions,options.unobserved);
    const opts={...options,equals:this.comparator(options.equals),_noSnapshot:options.noSnapshot,unobserved:this.programs[options.unobserved]};
    if(Object.hasOwn(options,'loadingValue'))opts.loadingValue=this.value(options.loadingValue);
    const parent=this.ownerFor(Object.hasOwn(options,'owner')?options.owner:'root');
    this.accessors[name]=this.S.runWithOwner(parent,()=>this.S.createMemo(this.callback(name,expr),opts));
    this.registerComputedAccessor(this.accessors[name],name);
    // Read-only construction observation: a lazy body has not called getOwner
    // yet. In this grammar it cannot construct children before its first pass.
    if(options.lazy&&parent)this.namedOwners.set(parent._firstChild,name);
  }
  createReaction(body,options={},values=[],locals=[]){
    const name='@reaction'+(this.reactionSerial=(this.reactionSerial??0)+1);
    const callback=()=>this.returnedCleanup(this.evaluate(body,undefined,values,locals));
    const input=options.errorProgram?{effect:callback,error:(error,cleanup)=>this.programs[options.errorProgram](cleanup,error)}:callback;
    const track=this.S.createReaction(input,options);
    this.callbackFunctions.set(name,track);this.callbackIdentities.set(track,name);this.programActions.set(name,[]);
    this.programs[name]=(_helper,tracking)=>track(tracking);
    return track;
  }
  armReaction(track,body){
    return track(()=>{
      const node=this.S.getOwner();let name=this.sourceNames.get(node);
      if(!name){name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1);this.sourceNames.set(node,name);this.notPending??=node._pendingValue;}
      this.traceEvents.push(['compute',name]);return body();
    });
  }
  reaction(name,body,options={}){
    this.reactionValues??=new Map();
    const value=this.S.runWithOwner(this.ownerFor(Object.hasOwn(options,'owner')?options.owner:'root'),()=>this.createReaction(body,options));
    this.reactionValues.set(name,value);return value;
  }
  track(name,body){return this.armReaction(this.reactionValues.get(name),()=>this.evaluate(body));}
  createSettled(name,body,values=[],locals=[]){
    const parent=this.S.getOwner(),owned=parent&&!(parent._config&16);
    this.S.onSettled(()=>{
      if(owned){const node=this.S.getOwner();this.sourceNames.set(node,name);this.notPending??=node._pendingValue;this.traceEvents.push(['compute',name]);}
      const result=this.evaluate(body,undefined,values,locals);
      return owned?this.returnedCleanup(result):result;
    });
    if(owned){const node=parent._firstChild;this.sourceNames.set(node,name);this.notPending??=node._pendingValue;}
  }
  settled(name,body,{owner='root'}={}){
    return this.S.runWithOwner(this.ownerFor(owner),()=>this.createSettled(name,body));
  }
  createTracked(name,body,values=[],locals=[]){
    const parent=this.S.getOwner();
    this.S.createTrackedEffect(()=>{
      const node=this.S.getOwner();this.sourceNames.set(node,name);this.notPending??=node._pendingValue;
      this.traceEvents.push(['compute',name]);
      return this.returnedCleanup(this.evaluate(body,undefined,values,locals));
    });
    if(parent){const node=parent._firstChild;this.sourceNames.set(node,name);this.notPending??=node._pendingValue;}
  }
  onFlush(body){
    this.S.onFlush(()=>{try{this.evaluate(body);}catch(error){this.asyncErrors.push(this.errorShape(error));}});
  }
  tracked(name,body,{owner='root'}={}){
    return this.S.runWithOwner(this.ownerFor(owner),()=>this.createTracked(name,body));
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
  flush(body) { if(arguments.length)return this.S.flush(()=>this.evaluate(body));return this.S.flush(); }
  refresh(name) { this.awaitRefresh('refresh#'+Object.keys(this.ports).length,name); }
  resetErrorHalt() { this.S.resetErrorHalt(); }
  dispose() { this.disposeRoot(); }
  trace() { return this.traceEvents.map(e=>e.map(v=>this.observe(v))); }
  screen(target=2) { return this.observe(this.screens[target]); }
}
