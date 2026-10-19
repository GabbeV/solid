import {requireTeardownProgram} from './programs.mjs';
const {default:R}=await import(process.env.BEND_EMIT_FILE ?? '../build/runtime.mjs');
import {HostErrors,errorKind} from './errors.mjs';

// All constructed values/expressions come from ONE emitted closure. This is
// the only module that knows the pinned emitter's list/record representation.
export const ABI = R;
export function list(xs) {
  const out = [];
  while ('head' in xs) { out.push(xs.head); xs = xs.tail; }
  return out;
}
const tags = {
  undefined:R.vUndefined().$, null:R.vNull().$, number:R.vNumber(0).$,
  bool:R.vBoolean(false).$, ref:R.vReference(0).$, owner:R.vOwner(0).$, nan:R.vNaN().$,
  text:R.vText('').$, async:R.vAsync(0).$, healthy:R.createWorld().fault.$,
  timeout:R.vTimeout(0).$,
  externalError:R.vExternalError(0,false,0,'','',true,0).$,
};
export class BendOwner {
  constructor(id){this.owner=id;Object.freeze(this);}
}
export class BendTimeoutError extends Error {
  constructor(identity){super('Timed out waiting for condition');this.name='TimeoutError';this.identity=identity;}
}
export class BendStatusError extends Error {
  constructor(identity,source,cause,message){super(message,{cause});this.identity=identity;this.source=source;}
}
export class BendNotReady extends Error {
  constructor(identity,source){super();this.identity=identity;this.source=source;}
}
export function decode(v,errors=new Map(),refs=new Map(),asyncRefs=new Map(),externalErrors=new HostErrors()) {
  if (Object.hasOwn(v,'identity')&&Object.hasOwn(v,'source')&&!Object.hasOwn(v,'cause')) {
    if(!errors.has(v.identity))errors.set(v.identity,new BendNotReady(v.identity,v.source));
    return errors.get(v.identity);
  }
  if (Object.hasOwn(v,'identity')&&Object.hasOwn(v,'cause')) {
    if(!errors.has(v.identity))errors.set(v.identity,new BendStatusError(v.identity,v.source,decode(v.cause,errors,refs,asyncRefs,externalErrors),typeof v.message==='string'?v.message:decodeString(v.message)));
    return errors.get(v.identity);
  }
  switch (v.$) {
    case tags.undefined: return undefined;
    case tags.null: return null;
    case tags.number: return v.n;
    case tags.bool: return v.b;
    case tags.owner:
      if(!refs.has('owner:'+v.id))refs.set('owner:'+v.id,new BendOwner(v.id));return refs.get('owner:'+v.id);
    case tags.ref:
      if(!refs.has(v.id))refs.set(v.id,{ref:v.id});return refs.get(v.id);
    case tags.async:
      if(!asyncRefs.has(v.identity))asyncRefs.set(v.identity,{async:v.identity});return asyncRefs.get(v.identity);
    case tags.nan: return NaN;
    case tags.text: return typeof v.s === 'string' ? v.s : decodeString(v.s);
    case tags.timeout:
      if(!errors.has(v.identity))errors.set(v.identity,new BendTimeoutError(v.identity));
      return errors.get(v.identity);
    case tags.externalError:
      return externalErrors.decode(v.id,v.explicit,v.kind,typeof v.name==='string'?v.name:decodeString(v.name),typeof v.message==='string'?v.message:decodeString(v.message),v.native,v.code);
    default: throw new Error('Unsupported Bend payload shape');
  }
}
function decodeString(s) {
  let result = '';
  while ('head' in s) { result += String.fromCodePoint(s.head); s = s.tail; }
  return result;
}
export function encode(v) {
  if (v === undefined) return R.vUndefined();
  if (v === null) return R.vNull();
  if (typeof v === 'boolean') return R.vBoolean(v);
  if (typeof v === 'string') return R.vText(v);
  if (typeof v === 'number') {
    if (Number.isNaN(v)) return R.vNaN();
    if (!Number.isSafeInteger(v) || v < 0 || v > 2 ** 48 - 1) throw new RangeError('Payload arithmetic supports naturals through 2^48-1');
    return R.vNumber(v === 0 ? 0 : v); // strict equality identifies +/-0
  }
  if (typeof v === 'object' && Number.isSafeInteger(v.async) && v.async > 0) return R.vAsync(v.async);
  if (typeof v === 'object' && Number.isSafeInteger(v.owner) && v.owner > 0)return R.vOwner(v.owner);
  if (typeof v === 'object' && Number.isSafeInteger(v.ref) && v.ref >= 0) return R.vReference(v.ref);
  if (typeof v === 'object' && Number.isSafeInteger(v.error) && typeof v.native==='boolean')return R.vExternalError(v.error,v.explicit,errorKind(v),v.name,v.message,v.native,v.code);
  throw new TypeError('Use an opaque {ref: id} token for arbitrary host objects');
}
export function expression(e, ids, programs={},futures={},encodeValue=encode) {
  if (Object.hasOwn(e,'lit')) return R.literal(encodeValue(e.lit));
  if (e.future) return R.literal(R.vAsync(futures[e.future]));
  if (e.read) return R.source(ids[e.read]);
  if (e.prev) return R.previous();
  if (e.owner) return R.currentOwner();
  if (e.observer) return R.currentObserver();
  if (e.root) return R.rootScope(expression(e.root,ids,programs,futures,encodeValue),e.transparent??false);
  if (e.disposeRoot) return R.disposeRoot(expression(e.disposeRoot,ids,programs,futures,encodeValue));
  if (e.disposed) return R.ownerDisposed(expression(e.disposed,ids,programs,futures,encodeValue));
  if (e.withOwner) return R.withOwner(...e.withOwner.map(x=>expression(x,ids,programs,futures,encodeValue)));
  if (e.add) return R.add(...e.add.map(x=>expression(x,ids,programs,futures,encodeValue)));
  if (e.mul) return R.multiply(...e.mul.map(x=>expression(x,ids,programs,futures,encodeValue)));
  if (e.same) return R.same(...e.same.map(x=>expression(x,ids,programs,futures,encodeValue)));
  if (e.select) return R.select(...e.select.map(x=>expression(x,ids,programs,futures,encodeValue)));
  if (e.untrack) return R.untrack(expression(e.untrack,ids,programs,futures,encodeValue));
  if (e.call) return R.callProgram(programs[e.call]);
  if (e.seq) return e.seq.map(x=>expression(x,ids,programs,futures,encodeValue)).reduceRight((next,current)=>next?R.then(current,next):current,null) ?? R.literal(R.vUndefined());
  if (Object.hasOwn(e,'raise')) return R.throwError(encodeValue(e.raise));
  throw new TypeError('Unknown expression');
}
function nodeOptions(options={},programs={},encodeValue=encode) {
  const {equals=true,transparent=false,ownedWrite=false,lazy=false,sync=false,noSnapshot=false}=options;
  return R.nodeOptions(equals,transparent,ownedWrite,lazy,sync,noSnapshot,
    Object.hasOwn(options,'loadingValue'),encodeValue(options.loadingValue),programs[options.unobserved]??0);
}
export class BendRuntime {
  constructor({fuel=100000,async=false,clock}={}) { this.world=R.createWorld(); this.ids={}; this.fuel=fuel; this.reverse={1:'root'}; this.programs={};this.programActions=new Map(); this.errors=new Map();this.refs=new Map();this.asyncRefs=new Map(); this.encountered=new Map(); this.futures={};this.programLabels=new Map();this.hostAsync=async;this.asyncErrors=[];this.ports={};this.portNames=new Map();this.portEvents=[];this.portSnapshots=[];this.hiddenNodes=new Set();this.clock=clock??{setTimeout,clearTimeout};this.timers=new Map();this.controllers={};this.abortNames=new Map();this.abortListeners=new Map();this.hostErrors=new HostErrors();this.anonymousOwners=new Map(); }
  decode(value){return decode(value,this.errors,this.refs,this.asyncRefs,this.hostErrors);}
  ownerId(name){
    if(name===null)return 0;
    const id=name==='root'?1:this.ids[name];
    if(!id||!R.validOwner(this.world,id))throw new TypeError('Unknown owner: '+name);
    return id;
  }
  encode(value){
    const described=this.hostErrors.describe(value);
    if(described&&typeof described==='object'&&Object.hasOwn(described,'owner')&&typeof described.owner==='string')return R.vOwner(this.ownerId(described.owner));
    return encode(described);
  }
  observe(value){
    if(value instanceof BendOwner){
      if(this.reverse[value.owner])return {owner:this.reverse[value.owner]};
      if(!this.anonymousOwners.has(value.owner))this.anonymousOwners.set(value.owner,this.anonymousOwners.size+1);
      return {anonymousOwner:this.anonymousOwners.get(value.owner)};
    }
    return this.hostErrors.observe(value);
  }
  evaluate(expr,previous){
    const m=R.evaluateExpression(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v)),this.encode(previous));
    this.world=R.resultWorld(m);this.check();return this.decode(R.resultValue(m));
  }
  root(name,expr,{owner='root',transparent=false}={}){
    const parent=this.ownerId(owner),id=R.nextId(this.world);this.ids[name]=id;this.reverse[id]=name;
    const m=R.createRoot(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>v?.owner===name?R.vOwner(id):this.encode(v)),parent,transparent);
    this.world=R.resultWorld(m);this.check();return this.decode(R.resultValue(m));
  }
  disposeOwner(name){this.world=R.dispose(this.world,this.ownerId(name));this.check();}
  drainJobs() {
    if(!this.hostAsync)return;
    const jobs=list(this.world.hostJobs);this.world=R.clearHostJobs(this.world);
    for(const job of jobs){
      const kind=R.hostJobKind(job);
      if(kind===5){
        this.timers.set(job.awaiter,this.clock.setTimeout(()=>this.hostCallback(()=>{this.world=R.timeoutUntil(this.world,job.awaiter);}),job.delay));
        continue;
      }
      if(kind===6){this.clock.clearTimeout(this.timers.get(job.awaiter));continue;}
      if(kind===7){
        const callback=()=>this.hostCallback(()=>{this.world=R.abortUntil(this.world,job.awaiter);});
        this.abortListeners.set(job.awaiter,callback);
        this.controllers[this.abortNames.get(job.signal)].signal.addEventListener('abort',callback,{once:true});
        continue;
      }
      if(kind===8){
        this.controllers[this.abortNames.get(job.signal)].signal.removeEventListener('abort',this.abortListeners.get(job.awaiter));
        continue;
      }
      if(kind===4){
        const port=this.ports[this.portNames.get(job.awaiter)];
        if(port){
          if(!job.rejected&&job.value.$===tags.async&&list(this.world.asyncObjects)[job.value.identity].stream===0)throw new TypeError('Native promise assimilation of a returned thenable is outside this host protocol');
          (job.rejected?port.reject:port.resolve)(this.decode(job.value));
        }
        continue;
      }
      queueMicrotask(()=>{
        try {
          if(kind===1)this.world=R.deliver(this.fuel,this.world,job.observer,job.rejected,job.value);
          else if(kind===2){this.world=R.startRefresh(this.fuel,this.world,job.awaiter);this.bindAwaiter(job.awaiter);}
          else if(kind===3)this.world=R.deliverWatch(this.world,job.awaiter,job.rejected,job.value);
          else this.world=R.flush(this.fuel,this.world);
          this.check();
        }catch(e){this.asyncErrors.push(this.errorShape(e));}
      });
    }
  }
  hostCallback(callback){try{callback();this.check();}catch(error){this.asyncErrors.push(this.errorShape(error));}}
  check() {
    this.drainJobs();
    if(this.world.fault.$ === tags.healthy)return;
    if(Object.hasOwn(this.world.fault,'cause')) {
      const thrown=this.decode(this.world.fault.cause);this.world=R.clearException(this.world);throw thrown;
    }
    throw new Error(`Bend runtime stopped: ${JSON.stringify(this.world.fault)}`);
  }
  errorShape(e) {
    if(e instanceof BendTimeoutError)return {timeoutError:true,name:e.name,message:e.message};
    if(e instanceof BendNotReady){
      if(!this.encountered.has(e))this.encountered.set(e,this.encountered.size+1);
      return {notReady:this.encountered.get(e),source:this.reverse[e.source]??null};
    }
    if(e instanceof BendStatusError){
      if(!this.encountered.has(e))this.encountered.set(e,this.encountered.size+1);
      return {statusError:this.encountered.get(e),source:this.reverse[e.source],cause:this.errorShape(e.cause),message:e.message};
    }
    return this.observe(e);
  }
  attempt(op,...args) {try{return ['return',this.observe(this[op](...args))];}catch(e){return ['throw',this.errorShape(e)];}}
  program(name,actions) {
    for(const [op,name] of actions)if(op==='cleanup')requireTeardownProgram(this.programActions,name);
    this.programActions.set(name,actions);
    let p=R.emptyProgram();
    for(const [op,...args] of [...actions].reverse()) {
      if(op==='emit')p=R.programEmit(args[0],p);
      else if(op==='set')p=R.programWrite(this.ids[args[0]],this.encode(args[1]),p);
      else if(op==='dispose'&&args[0]==='root')p=R.programDispose(1,p);
      else if(op==='previousCleanup')p=R.programPreviousCleanup(p);
      else if(op==='cleanup')p=R.programCleanup(this.programs[args[0]],p);
      else if(op==='throw')p=R.programThrow(this.encode(args[0]),p);
      else if(op==='eval')p=R.programEvaluate(expression(args[0],this.ids,this.programs,this.futures,v=>this.encode(v)),p);
      else if(op==='return')p=R.programReturn(expression(args[0],this.ids,this.programs,this.futures,v=>this.encode(v)),p);
      else if(op==='setExpr')p=R.programWriteExpr(this.ids[args[0]],expression(args[1],this.ids,this.programs,this.futures,v=>this.encode(v)),p);
      else if(op==='throwExpr')p=R.programThrowExpr(expression(args[0],this.ids,this.programs,this.futures,v=>this.encode(v)),p);
      else throw new TypeError('Unsupported callback action');
    }
    const id=R.nextProgramId(this.world);this.programs[name]=id;this.programLabels.set(id,this.programLabels.size+1);
    this.world=R.registerProgram(this.world,p);this.check();return id;
  }
  makePort(name,id){
    let resolve,reject;const promise=new Promise((a,b)=>{resolve=a;reject=b;});
    this.ports[name]={id,promise,resolve,reject};this.portNames.set(id,name);
    promise.then(value=>{this.portEvents.push(['resolve',name,this.observe(value)]);this.portSnapshots.push([name,this.screen()]);},error=>{this.portEvents.push(['reject',name,this.errorShape(error)]);this.portSnapshots.push([name,this.screen()]);});
  }
  bindAwaiter(id){
    const a=list(this.world.awaiters)[id],name=this.portNames.get(id);
    if(!a?.node)return;
    if(a.refresh)this.hiddenNodes.add(a.node);
    else{this.ids['wait:'+name]=a.node;this.reverse[a.node]='wait:'+name;}
  }
  awaitValue(name,expr){
    const id=R.nextAwaiterId(this.world);this.makePort(name,id);
    this.world=R.resolveValue(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v)));this.bindAwaiter(id);this.check();
  }
  awaitUntil(name,expr,options={}){
    const id=R.nextAwaiterId(this.world);this.makePort(name,id);
    const timed=options.timeout!==undefined;
    if(timed&&(!Number.isSafeInteger(options.timeout)||options.timeout<0||options.timeout>2**31-1))throw new RangeError('Timeout protocol admits natural milliseconds through 2^31-1');
    const signal=options.signal===undefined?0:this.controllers[options.signal].id;
    this.world=R.untilWithOptions(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v)),timed,options.timeout??0,signal);this.bindAwaiter(id);this.check();
  }
  controller(name){
    const id=R.nextAbortId(this.world),controller=new AbortController();controller.id=id;
    this.controllers[name]=controller;this.abortNames.set(id,name);this.world=R.createAbortInput(this.world);
    // Native external property delivery precedes until's own listener. The
    // host creates the default DOMException; the engine receives its identity.
    controller.signal.addEventListener('abort',()=>{this.world=R.setAbortInput(this.world,id,this.encode(controller.signal.reason));},{once:true});
    this.check();
  }
  abort(name,reason){
    const controller=this.controllers[name];
    if(reason===undefined)controller.abort();
    else controller.abort(this.decode(this.encode(reason)));
    this.check();
  }
  awaitRefresh(name,target){
    const id=R.nextAwaiterId(this.world);this.makePort(name,id);
    this.world=R.refreshValue(this.world,this.ids[target]??0);this.check();
  }
  promise(name){return this.ports[name].promise;}
  future(name,{immediate=false}={}) {
    const id=R.nextAsyncId(this.world);this.futures[name]=id;
    this.world=R.createThenable(this.world,immediate);this.check();return id;
  }
  stream(name,steps=[],options={}) {
    let inputs=R.emptyNexts();
    for(const step of [...steps].reverse()){
      if(Object.hasOwn(step,'throw'))inputs=R.throwNext(this.encode(step.throw),inputs);
      else if(step.future)inputs=R.promiseNext(this.futures[step.future],inputs);
      else inputs=R.bareNext(step.done??false,this.encode(step.value),inputs);
    }
    const id=R.nextAsyncId(this.world);this.futures[name]=id;
    this.world=R.createStream(this.world,inputs,options.hasReturn??true,Object.hasOwn(options,'returnThrows'),this.encode(options.returnThrows),this.futures[options.returnFuture]??0);this.check();return id;
  }
  resolveStep(name,value,done=false){this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],false,R.vStepResult(done,this.encode(value)));this.check();}
  resolveStream(name,stream){this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],false,R.vAsync(this.futures[stream]));this.check();}
  iteratorIO(){
    const names=new Map(Object.entries(this.futures).map(([name,id])=>[id,name]));
    return list(this.world.iteratorEvents).map(e=>'object'in e?['start',names.get(e.object),e.iterator]:'index'in e?['next',e.iterator,e.index]:['return',e.iterator]);
  }
  resolve(name,value) {this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],false,this.encode(value));this.check();}
  reject(name,error) {this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],true,this.encode(error));this.check();}
  signal(name,value,equals=true) {
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    const options=typeof equals==='boolean'?{equals}:equals;
    requireTeardownProgram(this.programActions,options.unobserved);
    this.world=R.createSignalWithOptions(this.world,this.encode(value),nodeOptions(options,this.programs,v=>this.encode(v))); this.check(); return id;
  }
  memo(name,expr,options={}) {
    requireTeardownProgram(this.programActions,options.unobserved);
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    this.world=R.createMemoWithOptions(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v)),nodeOptions(options,this.programs,v=>this.encode(v)),this.ownerId(Object.hasOwn(options,'owner')?options.owner:'root')); this.check(); return id;
  }
  effect(name,expr,options={}) {
    requireTeardownProgram(this.programActions,options.unobserved);
    requireTeardownProgram(this.programActions,options.cleanup);
    const {user=false,target=2,schedule=false,defer=false}=options;
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    if (!user) this.world=R.attach(this.world,1,target);
    this.world=R.createEffectWithHandlers(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v)),user,target,schedule,defer,nodeOptions(options,this.programs,v=>this.encode(v)),this.ownerId(Object.hasOwn(options,'owner')?options.owner:'root'),this.programs[options.program]??0,this.programs[options.cleanup]??0,this.programs[options.error]??0); this.check(); return id;
  }
  set(name,value) {
    const encoded=this.encode(value);this.world=R.setSignal(this.world,this.ids[name],encoded);this.check();
    return encoded.$===tags.ref||encoded.$===tags.async||encoded.$===tags.externalError?this.decode(encoded):value;
  }
  update(name,expr) {
    // The Bend engine evaluates the updater against its staged slot.
    const encoded=expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v));
    this.world=R.setUpdater(this.fuel,this.world,this.ids[name],encoded); this.check();
    const n=this.nodes()[this.ids[name]];
    return this.decode(Object.hasOwn(n.pending,'value') ? n.pending.value : n.value);
  }
  read(name) {
    const m=R.read(this.fuel,this.world,this.ids[name]);
    this.world=R.resultWorld(m); this.check(); return this.decode(R.resultValue(m));
  }
  flush() { this.world=R.flush(this.fuel,this.world); this.check(); }
  markRefresh(name) { this.world=R.markRefresh(this.world,this.ids[name]); this.check(); }
  refresh(name) { this.awaitRefresh('refresh#'+Object.keys(this.ports).length,name); }
  resetErrorHalt() { this.world=R.resetErrorHalt(this.world); }
  dispose() { this.world=R.dispose(this.world,1); this.check(); }
  nodes() { return list(this.world.nodes); }
  trace() {
    const name=id=>this.reverse[id] ?? null;
    return list(this.world.events).filter(e=>!this.hiddenNodes.has(e.reader??e.id)).map(e=> {
      if ('callback' in e) return ['cleanup',this.programLabels.get(e.callback)??e.callback,e.code];
      if ('previous' in e) return ['apply',name(e.id),this.observe(this.decode(e.value)),this.observe(this.decode(e.previous))];
      if ('reader' in e) return ['read',name(e.reader),name(e.source),this.observe(this.decode(e.value))];
      return ['compute',name(e.id)];
    });
  }
  screen(target=2) { return this.observe(this.decode(R.displayed(this.world,target))); }
}
