const {default:R}=await import(process.env.BEND_EMIT_FILE ?? '../build/runtime.mjs');

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
  bool:R.vBoolean(false).$, ref:R.vReference(0).$, nan:R.vNaN().$,
  text:R.vText('').$, async:R.vAsync(0).$, healthy:R.createWorld().fault.$,
};
export class BendStatusError extends Error {
  constructor(identity,source,cause){super(String(cause),{cause});this.identity=identity;this.source=source;}
}
export class BendNotReady extends Error {
  constructor(identity,source){super();this.identity=identity;this.source=source;}
}
export function decode(v,errors=new Map(),refs=new Map(),asyncRefs=new Map()) {
  if (Object.hasOwn(v,'identity')&&Object.hasOwn(v,'source')&&!Object.hasOwn(v,'cause')) {
    if(!errors.has(v.identity))errors.set(v.identity,new BendNotReady(v.identity,v.source));
    return errors.get(v.identity);
  }
  if (Object.hasOwn(v,'identity')&&Object.hasOwn(v,'cause')) {
    if(!errors.has(v.identity))errors.set(v.identity,new BendStatusError(v.identity,v.source,decode(v.cause,errors,refs,asyncRefs)));
    return errors.get(v.identity);
  }
  switch (v.$) {
    case tags.undefined: return undefined;
    case tags.null: return null;
    case tags.number: return v.n;
    case tags.bool: return v.b;
    case tags.ref:
      if(!refs.has(v.id))refs.set(v.id,{ref:v.id});return refs.get(v.id);
    case tags.async:
      if(!asyncRefs.has(v.identity))asyncRefs.set(v.identity,{async:v.identity});return asyncRefs.get(v.identity);
    case tags.nan: return NaN;
    case tags.text: return typeof v.s === 'string' ? v.s : decodeString(v.s);
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
  if (typeof v === 'object' && Number.isSafeInteger(v.ref) && v.ref >= 0) return R.vReference(v.ref);
  throw new TypeError('Use an opaque {ref: id} token for arbitrary host objects');
}
export function expression(e, ids, programs={},futures={}) {
  if (Object.hasOwn(e,'lit')) return R.literal(encode(e.lit));
  if (e.future) return R.literal(R.vAsync(futures[e.future]));
  if (e.read) return R.source(ids[e.read]);
  if (e.prev) return R.previous();
  if (e.add) return R.add(...e.add.map(x=>expression(x,ids,programs,futures)));
  if (e.mul) return R.multiply(...e.mul.map(x=>expression(x,ids,programs,futures)));
  if (e.same) return R.same(...e.same.map(x=>expression(x,ids,programs,futures)));
  if (e.select) return R.select(...e.select.map(x=>expression(x,ids,programs,futures)));
  if (e.untrack) return R.untrack(expression(e.untrack,ids,programs,futures));
  if (e.call) return R.callProgram(programs[e.call]);
  if (e.seq) return e.seq.map(x=>expression(x,ids,programs,futures)).reduceRight((next,current)=>next?R.then(current,next):current,null) ?? R.literal(R.vUndefined());
  if (Object.hasOwn(e,'raise')) return R.throwError(encode(e.raise));
  throw new TypeError('Unknown expression');
}
function nodeOptions(options={},programs={}) {
  const {equals=true,transparent=false,ownedWrite=false,lazy=false,sync=false,noSnapshot=false}=options;
  return R.nodeOptions(equals,transparent,ownedWrite,lazy,sync,noSnapshot,
    Object.hasOwn(options,'loadingValue'),encode(options.loadingValue),programs[options.unobserved]??0);
}
export class BendRuntime {
  constructor({fuel=100000,async=false}={}) { this.world=R.createWorld(); this.ids={}; this.fuel=fuel; this.reverse={1:'root'}; this.programs={}; this.errors=new Map();this.refs=new Map();this.asyncRefs=new Map(); this.encountered=new Map(); this.futures={};this.programLabels=new Map();this.hostAsync=async;this.asyncErrors=[];this.ports={};this.portNames=new Map();this.portEvents=[];this.portSnapshots=[];this.hiddenNodes=new Set(); }
  decode(value){return decode(value,this.errors,this.refs,this.asyncRefs);}
  drainJobs() {
    if(!this.hostAsync)return;
    const jobs=list(this.world.hostJobs);this.world=R.clearHostJobs(this.world);
    for(const job of jobs){
      const kind=R.hostJobKind(job);
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
  check() {
    this.drainJobs();
    if(this.world.fault.$ === tags.healthy)return;
    if(Object.hasOwn(this.world.fault,'cause')) {
      const thrown=this.decode(this.world.fault.cause);this.world=R.clearException(this.world);throw thrown;
    }
    throw new Error(`Bend runtime stopped: ${JSON.stringify(this.world.fault)}`);
  }
  errorShape(e) {
    if(e instanceof BendNotReady){
      if(!this.encountered.has(e))this.encountered.set(e,this.encountered.size+1);
      return {notReady:this.encountered.get(e),source:this.reverse[e.source]??null};
    }
    if(e instanceof BendStatusError){
      if(!this.encountered.has(e))this.encountered.set(e,this.encountered.size+1);
      return {statusError:this.encountered.get(e),source:this.reverse[e.source],cause:this.errorShape(e.cause)};
    }
    return e;
  }
  attempt(op,...args) {try{return ['return',this[op](...args)];}catch(e){return ['throw',this.errorShape(e)];}}
  program(name,actions) {
    let p=R.emptyProgram();
    for(const [op,...args] of [...actions].reverse()) {
      if(op==='emit')p=R.programEmit(args[0],p);
      else if(op==='set')p=R.programWrite(this.ids[args[0]],encode(args[1]),p);
      else if(op==='dispose'&&args[0]==='root')p=R.programDispose(1,p);
      else if(op==='previousCleanup')p=R.programPreviousCleanup(p);
      else if(op==='cleanup')p=R.programCleanup(this.programs[args[0]],p);
      else if(op==='throw')p=R.programThrow(encode(args[0]),p);
      else throw new TypeError('Unsupported callback action');
    }
    const id=R.nextProgramId(this.world);this.programs[name]=id;this.programLabels.set(id,this.programLabels.size+1);
    this.world=R.registerProgram(this.world,p);this.check();return id;
  }
  makePort(name,id){
    let resolve,reject;const promise=new Promise((a,b)=>{resolve=a;reject=b;});
    this.ports[name]={id,promise,resolve,reject};this.portNames.set(id,name);
    promise.then(value=>{this.portEvents.push(['resolve',name,value]);this.portSnapshots.push([name,this.screen()]);},error=>{this.portEvents.push(['reject',name,this.errorShape(error)]);this.portSnapshots.push([name,this.screen()]);});
  }
  bindAwaiter(id){
    const a=list(this.world.awaiters)[id],name=this.portNames.get(id);
    if(!a?.node)return;
    if(a.refresh)this.hiddenNodes.add(a.node);
    else{this.ids['wait:'+name]=a.node;this.reverse[a.node]='wait:'+name;}
  }
  awaitValue(name,expr){
    const id=R.nextAwaiterId(this.world);this.makePort(name,id);
    this.world=R.resolveValue(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures));this.bindAwaiter(id);this.check();
  }
  awaitUntil(name,expr){
    const id=R.nextAwaiterId(this.world);this.makePort(name,id);
    this.world=R.untilValue(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures));this.bindAwaiter(id);this.check();
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
      if(Object.hasOwn(step,'throw'))inputs=R.throwNext(encode(step.throw),inputs);
      else if(step.future)inputs=R.promiseNext(this.futures[step.future],inputs);
      else inputs=R.bareNext(step.done??false,encode(step.value),inputs);
    }
    const id=R.nextAsyncId(this.world);this.futures[name]=id;
    this.world=R.createStream(this.world,inputs,options.hasReturn??true,Object.hasOwn(options,'returnThrows'),encode(options.returnThrows),this.futures[options.returnFuture]??0);this.check();return id;
  }
  resolveStep(name,value,done=false){this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],false,R.vStepResult(done,encode(value)));this.check();}
  resolveStream(name,stream){this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],false,R.vAsync(this.futures[stream]));this.check();}
  iteratorIO(){
    const names=new Map(Object.entries(this.futures).map(([name,id])=>[id,name]));
    return list(this.world.iteratorEvents).map(e=>'object'in e?['start',names.get(e.object),e.iterator]:'index'in e?['next',e.iterator,e.index]:['return',e.iterator]);
  }
  resolve(name,value) {this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],false,encode(value));this.check();}
  reject(name,error) {this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],true,encode(error));this.check();}
  signal(name,value,equals=true) {
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    const options=typeof equals==='boolean'?{equals}:equals;
    this.world=R.createSignalWithOptions(this.world,encode(value),nodeOptions(options,this.programs)); this.check(); return id;
  }
  memo(name,expr,options={}) {
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    this.world=R.createMemoWithOptions(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures),nodeOptions(options,this.programs),1); this.check(); return id;
  }
  effect(name,expr,options={}) {
    const {user=false,target=2,schedule=false,defer=false}=options;
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    if (!user) this.world=R.attach(this.world,1,target);
    this.world=R.createEffectWithHandlers(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures),user,target,schedule,defer,nodeOptions(options,this.programs),1,this.programs[options.program]??0,this.programs[options.cleanup]??0,this.programs[options.error]??0); this.check(); return id;
  }
  set(name,value) {
    const encoded=encode(value);this.world=R.setSignal(this.world,this.ids[name],encoded);this.check();
    return encoded.$===tags.ref||encoded.$===tags.async?this.decode(encoded):value;
  }
  update(name,expr) {
    // The Bend engine evaluates the updater against its staged slot.
    const encoded=expression(expr,this.ids,this.programs,this.futures);
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
      if ('previous' in e) return ['apply',name(e.id),this.decode(e.value),this.decode(e.previous)];
      if ('reader' in e) return ['read',name(e.reader),name(e.source),this.decode(e.value)];
      return ['compute',name(e.id)];
    });
  }
  screen(target=2) { return this.decode(R.displayed(this.world,target)); }
}
