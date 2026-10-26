import {RuntimeArrays} from './arrays.mjs';
import {RootDisposers,SourceAccessors,SourceSetters,ProgramFunctions} from './functions.mjs';
import {requireTeardownProgram,requireFunctionProgram} from './programs.mjs';
import {requireActionProtocol} from './actions.mjs';
const {default:R}=await import(process.env.BEND_EMIT_FILE ?? '../build/runtime.mjs');
import {HostErrors,errorKind} from './errors.mjs';

// All constructed values/expressions come from ONE emitted closure. This is
// the only module that knows the pinned emitter's list/record representation.
export const ABI = R;
// Derive list tags from real emitted constructors. Handwritten lookalike tags
// are not valid ABI data even when a particular helper ignores the tag.
const listNilTag=R.emptyNexts().$;
const listConTag=R.bareNext(false,R.vUndefined(),R.emptyNexts()).$;
export function encodeList(items) {
  return items.reduceRight((tail,head)=>({$:listConTag,head,tail}),R.emptyNexts());
}
export function list(xs) {
  const out=[];
  for(;;){
    if(!xs||typeof xs!=='object')throw new TypeError('Malformed Bend list ABI value');
    if(xs.$===listNilTag)return out;
    if(xs.$!==listConTag||!Object.hasOwn(xs,'head')||!Object.hasOwn(xs,'tail'))throw new TypeError('Malformed Bend list ABI tag or fields');
    out.push(xs.head);xs=xs.tail;
  }
}

const tags = {
  array:R.vArray(0).$, undefined:R.vUndefined().$, null:R.vNull().$, number:R.vNumber(0).$, negativeZero:R.vNegativeZero().$,
  bool:R.vBoolean(false).$, ref:R.vReference(0).$, owner:R.vOwner(0).$, nan:R.vNaN().$,
  text:R.vText('').$, async:R.vAsync(0).$, healthy:R.createWorld().fault.$,
  contextFailure:R.vContextFailure(0,0).$, timeout:R.vTimeout(0).$, disposer:R.vRootDisposer(0).$, accessor:R.vAccessor(0).$, setter:R.vSetter(0).$, callback:R.vProgram(0).$,
  externalError:R.vExternalError(0,false,0,'','',true,0).$,
};
export class BendNoOwnerError extends Error {
  constructor(identity){super('');this.identity=identity;}
}
export class BendContextNotFoundError extends Error {
  constructor(identity){super('');this.identity=identity;}
}
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
export function decode(v,errors=new Map(),refs=new Map(),asyncRefs=new Map(),externalErrors=new HostErrors(),rootDisposers=new RootDisposers(()=>{throw new TypeError('A bound disposer needs its runtime');}),accessors=new SourceAccessors(()=>{throw new TypeError('An accessor needs its runtime');}),setters=new SourceSetters(()=>{throw new TypeError('A setter needs its runtime');}),callbacks=new ProgramFunctions(()=>{throw new TypeError('A callback needs its runtime');}),arrayValue=()=>{throw new TypeError('An array needs its runtime');}) {
  if (Object.hasOwn(v,'identity')&&Object.hasOwn(v,'source')&&!Object.hasOwn(v,'cause')) {
    if(!errors.has(v.identity))errors.set(v.identity,new BendNotReady(v.identity,v.source));
    return errors.get(v.identity);
  }
  if (Object.hasOwn(v,'identity')&&Object.hasOwn(v,'cause')) {
    if(!errors.has(v.identity))errors.set(v.identity,new BendStatusError(v.identity,v.source,decode(v.cause,errors,refs,asyncRefs,externalErrors,rootDisposers,accessors,setters,callbacks,arrayValue),typeof v.message==='string'?v.message:decodeString(v.message)));
    return errors.get(v.identity);
  }
  switch (v.$) {
    case tags.array: return arrayValue(v.id);
    case tags.undefined: return undefined;
    case tags.null: return null;
    case tags.number: return v.n;
    case tags.negativeZero: return -0;
    case tags.bool: return v.b;
    case tags.contextFailure:
      if(!errors.has(v.identity))errors.set(v.identity,v.kind===0?new BendNoOwnerError(v.identity):new BendContextNotFoundError(v.identity));
      return errors.get(v.identity);
    case tags.disposer: return rootDisposers.get(v.owner);
    case tags.accessor: return accessors.get(v.signal);
    case tags.setter: return setters.get(v.signal);
    case tags.callback: return callbacks.get(v.callback);
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
    if (Object.is(v,-0)) return R.vNegativeZero();
    if (!Number.isSafeInteger(v) || v < 0 || v > 2 ** 48 - 1) throw new RangeError('Payload arithmetic supports naturals through 2^48-1');
    return R.vNumber(v);
  }
  if (typeof v === 'object' && Number.isSafeInteger(v.async) && v.async > 0) return R.vAsync(v.async);
  if (typeof v === 'object' && Number.isSafeInteger(v.rootDisposer) && v.rootDisposer > 0)return R.vRootDisposer(v.rootDisposer);
  if (typeof v === 'object' && Number.isSafeInteger(v.owner) && v.owner > 0)return R.vOwner(v.owner);
  if (typeof v === 'object' && Number.isSafeInteger(v.ref) && v.ref >= 0) return R.vReference(v.ref);
  if (typeof v === 'object' && Number.isSafeInteger(v.error) && typeof v.native==='boolean')return R.vExternalError(v.error,v.explicit,errorKind(v),v.name,v.message,v.native,v.code);
  throw new TypeError('Use an opaque {ref: id} token for arbitrary host objects');
}
// The linked argument syntax is user-code data, not a runtime JS evaluator.
function argumentSyntax(parts){
  return parts.reduceRight((tail,part)=>R.callArgumentsItem(part,tail),R.callArgumentsEnd());
}
export function expression(e, ids, programs={},futures={},encodeValue=encode,contexts={}) {
  if (Object.hasOwn(e,'lit')) return R.literal(encodeValue(e.lit));
  if (e.future) return R.literal(R.vAsync(futures[e.future]));
  if (e.read) return R.source(ids[e.read]);
  if (e.prev) return R.previous();
  if(e.flatten)return R.flatten(expression(e.flatten.children,ids,programs,futures,encodeValue,contexts),e.flatten.skipNonRendered??false,e.flatten.doNotUnwrap??false);
  if(e.mapArray){
    const {list,map,fallback,keyed}=e.mapArray;
    const mode=keyed===undefined||typeof keyed==='boolean'?R.literal(encodeValue(keyed)):expression(keyed,ids,programs,futures,encodeValue,contexts);
    return R.mapArrayInput(expression(list,ids,programs,futures,encodeValue,contexts),expression(map,ids,programs,futures,encodeValue,contexts),Object.hasOwn(e.mapArray,'fallback')?R.repeatBody(expression(fallback,ids,programs,futures,encodeValue,contexts)):R.noRepeatBody(),mode);
  }
  if(e.repeat){
    const {count,map,from,fallback}=e.repeat;
    return R.repeatCreate(expression(count,ids,programs,futures,encodeValue,contexts),expression(map,ids,programs,futures,encodeValue,contexts),Object.hasOwn(e.repeat,'from')?R.repeatBody(expression(from,ids,programs,futures,encodeValue,contexts)):R.noRepeatBody(),Object.hasOwn(e.repeat,'fallback')?R.repeatBody(expression(fallback,ids,programs,futures,encodeValue,contexts)):R.noRepeatBody());
  }
  if(e.array){
    if(!Array.isArray(e.array)||Array.from({length:e.array.length},(_,i)=>Object.hasOwn(e.array,i)).some(own=>!own))throw new TypeError('Typed array literals require dense expression syntax');
    return R.arrayLiteral(argumentSyntax(e.array.map(part=>expression(part,ids,programs,futures,encodeValue,contexts))));
  }
  if (e.arrayAt)return R.arrayAt(expression(e.arrayAt.array,ids,programs,futures,encodeValue,contexts),expression(e.arrayAt.index,ids,programs,futures,encodeValue,contexts));
  if (e.arrayLength)return R.arrayLength(expression(e.arrayLength,ids,programs,futures,encodeValue,contexts));
  if(e.action||e.actionCreate){
    const plan=e.action??e.actionCreate;
    requireActionProtocol(plan);
    let methods=R.emptyActionMethods();
    for(const step of [...plan.steps].reverse())methods=R.actionMethod(expression(step.next,ids,programs,futures,encodeValue,contexts),Object.hasOwn(step,'throw'),expression(step.throw??{lit:undefined},ids,programs,futures,encodeValue,contexts),methods);
    return (e.actionCreate?R.actionCreate:R.actionInvoke)(expression(plan.factory??{lit:undefined},ids,programs,futures,encodeValue,contexts),methods);
  }
  if(Object.hasOwn(e,'actionArgument')){const arg=e.actionArgument;return R.actionParameter(typeof arg==='number'?0:arg.depth??0,typeof arg==='number'?arg:arg.index??0);}
  if(e.iteratorResult)return R.iteratorResult(e.iteratorResult.done??false,expression(e.iteratorResult.value??{lit:undefined},ids,programs,futures,encodeValue,contexts));
  if (e.getContext){const {name,owner={lit:undefined}}=e.getContext;return R.contextGet(contexts[name],expression(owner,ids,programs,futures,encodeValue,contexts));}
  if (e.setContext){const {name,value={lit:undefined},owner={lit:undefined}}=e.setContext;return R.contextSet(contexts[name],expression(value,ids,programs,futures,encodeValue,contexts),expression(owner,ids,programs,futures,encodeValue,contexts));}
  if (e.owner) return R.currentOwner();
  if (e.observer) return R.currentObserver();
  if(e.reactionCreate){const {body,options={}}=e.reactionCreate;return R.reactionCreate(expression(body,ids,programs,futures,encodeValue,contexts),programs[options.errorProgram]??0,nodeOptions(options,programs,encodeValue),options.schedule??false);}
  if(e.reactionArm)return R.reactionArm(expression(e.reactionArm.callee,ids,programs,futures,encodeValue,contexts),expression(e.reactionArm.tracking,ids,programs,futures,encodeValue,contexts));
  if(Object.hasOwn(e,'flush'))return R.flushCallback(expression(e.flush,ids,programs,futures,encodeValue,contexts));
  if(Object.hasOwn(e,'flushCall'))return R.flushValue(expression(e.flushCall,ids,programs,futures,encodeValue,contexts));
  if(e.flushNow)return R.flushNow();
  if(e.settled)return R.settled(expression(e.settled,ids,programs,futures,encodeValue,contexts));
  if(Object.hasOwn(e,'onFlush'))return R.afterFlush(expression(e.onFlush,ids,programs,futures,encodeValue,contexts));
  if(e.trackedCreate)return R.trackedCreate(expression(e.trackedCreate,ids,programs,futures,encodeValue,contexts));
  if(e.optimisticComputeScope){
    const {compute,options={},body={lit:undefined}}=e.optimisticComputeScope;
    if(programs.teardownActions)requireTeardownProgram(programs.teardownActions,options.unobserved);
    return R.optimisticComputeScope(expression(compute,ids,programs,futures,encodeValue,contexts),nodeOptions(options,programs,encodeValue),expression(body,ids,programs,futures,encodeValue,contexts));
  }
  if(e.optimisticScope){
    const {initial={lit:undefined},options={},body={lit:undefined}}=e.optimisticScope;
    if(programs.teardownActions)requireTeardownProgram(programs.teardownActions,options.unobserved);
    return R.optimisticScope(expression(initial,ids,programs,futures,encodeValue,contexts),nodeOptions(options,programs,encodeValue),expression(body,ids,programs,futures,encodeValue,contexts));
  }
  if(e.signalComputeScope){
    const {compute,options={},body={lit:undefined}}=e.signalComputeScope;
    if(programs.teardownActions)requireTeardownProgram(programs.teardownActions,options.unobserved);
    return R.signalComputeScope(expression(compute,ids,programs,futures,encodeValue,contexts),nodeOptions(options,programs,encodeValue),expression(body,ids,programs,futures,encodeValue,contexts));
  }
  if(e.signalScope){
    const {initial={lit:undefined},options={},body={lit:undefined}}=e.signalScope;
    if(programs.teardownActions)requireTeardownProgram(programs.teardownActions,options.unobserved);
    return R.signalScope(expression(initial,ids,programs,futures,encodeValue,contexts),nodeOptions(options,programs,encodeValue),expression(body,ids,programs,futures,encodeValue,contexts));
  }
  if(Object.hasOwn(e,'localSetter'))return R.localSetter(e.localSetter);
  if(Object.hasOwn(e,'localAccessor'))return R.localAccessor(e.localAccessor);
  if(Object.hasOwn(e,'localRead'))return R.localRead(e.localRead);
  if(e.localWrite){const {depth=0,value={lit:undefined},updater=false}=e.localWrite;return R.localWrite(depth,expression(value,ids,programs,futures,encodeValue,contexts),updater);}
  if (e.effectCreate){
    const options=e.options??{};
    if(programs.teardownActions){requireTeardownProgram(programs.teardownActions,options.unobserved);requireTeardownProgram(programs.teardownActions,options.cleanup);}
    if(options.returnCleanup){
      if(options.cleanup)throw new TypeError('Use either returned or static effect cleanup');
      if(Object.hasOwn(e,'body')&&options.program)throw new TypeError('Use either an inline effect body or a named program');
      if(!Object.hasOwn(e,'body')&&!options.program)throw new TypeError('Returned cleanup requires an effect body');
      const body=e.body??{call:options.program,args:[{argument:0},{argument:1}]};
      return R.nestedReturningEffect(expression(e.effectCreate,ids,programs,futures,encodeValue,contexts),options.user??true,options.target??3,nodeOptions(options,programs,encodeValue),options.schedule??false,options.defer??false,expression(body,ids,programs,futures,encodeValue,contexts),programs[options.error]??0);
    }
    if(Object.hasOwn(e,'body')){
      if(options.program)throw new TypeError('Use either an inline effect body or a named program');
      return R.nestedEffectBody(expression(e.effectCreate,ids,programs,futures,encodeValue,contexts),options.user??true,options.target??3,nodeOptions(options,programs,encodeValue),options.schedule??false,options.defer??false,expression(e.body,ids,programs,futures,encodeValue,contexts),programs[options.cleanup]??0,programs[options.error]??0);
    }
    return R.nestedEffect(expression(e.effectCreate,ids,programs,futures,encodeValue,contexts),options.user??true,options.target??3,nodeOptions(options,programs,encodeValue),options.schedule??false,options.defer??false,programs[options.program]??0,programs[options.cleanup]??0,programs[options.error]??0);
  }
  if (e.deferredAccessor){
    if(programs.teardownActions)requireTeardownProgram(programs.teardownActions,e.options?.unobserved);
    return R.deferredAccessor(expression(e.deferredAccessor,ids,programs,futures,encodeValue,contexts),nodeOptions(e.options,programs,encodeValue));
  }
  if (e.deferredRead){
    if(programs.teardownActions)requireTeardownProgram(programs.teardownActions,e.options?.unobserved);
    return R.deferredRead(expression(e.deferredRead,ids,programs,futures,encodeValue,contexts),nodeOptions(e.options,programs,encodeValue));
  }
  if (e.memoAccessor){
    if(programs.teardownActions)requireTeardownProgram(programs.teardownActions,e.options?.unobserved);
    return R.memoAccessor(expression(e.memoAccessor,ids,programs,futures,encodeValue,contexts),nodeOptions(e.options,programs,encodeValue));
  }
  if (e.memoRead){
    if(programs.teardownActions)requireTeardownProgram(programs.teardownActions,e.options?.unobserved);
    return R.memoRead(expression(e.memoRead,ids,programs,futures,encodeValue,contexts),nodeOptions(e.options,programs,encodeValue));
  }
  if (e.root) return R.rootScope(expression(e.root,ids,programs,futures,encodeValue,contexts),e.transparent??false);
  if (e.createOwner) return R.ownerCreate(e.createOwner.transparent??false);
  if (e.disposeRoot) return R.disposeRootWithSelf(expression(e.disposeRoot,ids,programs,futures,encodeValue,contexts),e.self??true);
  if (e.disposed) return R.ownerDisposed(expression(e.disposed,ids,programs,futures,encodeValue,contexts));
  if (e.withOwner) return R.withOwner(...e.withOwner.map(x=>expression(x,ids,programs,futures,encodeValue,contexts)));
  if (e.add) return R.add(...e.add.map(x=>expression(x,ids,programs,futures,encodeValue,contexts)));
  if (e.mul) return R.multiply(...e.mul.map(x=>expression(x,ids,programs,futures,encodeValue,contexts)));
  if (e.same) return R.same(...e.same.map(x=>expression(x,ids,programs,futures,encodeValue,contexts)));
  if (e.select) return R.select(...e.select.map(x=>expression(x,ids,programs,futures,encodeValue,contexts)));
  if(e.affects)return R.affects(expression(e.affects.target??e.affects,ids,programs,futures,encodeValue,contexts),expression(e.affects.key??{lit:undefined},ids,programs,futures,encodeValue,contexts));
  if(e.latest)return R.latest(expression(e.latest,ids,programs,futures,encodeValue,contexts));
  if(e.isPending)return R.isPending(expression(e.isPending,ids,programs,futures,encodeValue,contexts));
  if (e.untrack) return R.untrack(expression(e.untrack,ids,programs,futures,encodeValue,contexts));
  if (Object.hasOwn(e,'argument'))return R.argument(e.argument);
  if(e.invokeArgs){
    const {callee,args=[]}=e.invokeArgs,fn=expression(callee,ids,programs,futures,encodeValue,contexts);
    if(args.length>2)return R.invokeMany(fn,argumentSyntax(args.map(arg=>expression(arg,ids,programs,futures,encodeValue,contexts))));
    return R.invokeArguments(fn,...Array.from({length:2},(_,i)=>expression(args[i]??{lit:undefined},ids,programs,futures,encodeValue,contexts)));
  }
  if(e.invokeWith){const {callee,value={lit:undefined},updater=false}=e.invokeWith;return R.invokeWith(expression(callee,ids,programs,futures,encodeValue,contexts),expression(value,ids,programs,futures,encodeValue,contexts),updater);}
  if (e.invoke)return R.invoke(expression(e.invoke,ids,programs,futures,encodeValue,contexts));
  if (Object.hasOwn(e,'from'))return R.fromInput(expression(e.from,ids,programs,futures,encodeValue,contexts));
  if (e.onCleanup)return R.onCleanup(expression(e.onCleanup,ids,programs,futures,encodeValue,contexts));
  if (e.call){
    if(e.args){
      if(e.args.length>2)return R.invokeMany(R.literal(R.vProgram(programs[e.call])),argumentSyntax(e.args.map(arg=>expression(arg,ids,programs,futures,encodeValue,contexts))));
      return R.callWith(programs[e.call],...Array.from({length:2},(_,i)=>expression(e.args[i]??{lit:undefined},ids,programs,futures,encodeValue,contexts)));
    }
    return R.callProgram(programs[e.call]);
  }
  if (e.seq) return e.seq.map(x=>expression(x,ids,programs,futures,encodeValue,contexts)).reduceRight((next,current)=>next?R.then(current,next):current,null) ?? R.literal(R.vUndefined());
  if (Object.hasOwn(e,'raise')) return R.throwError(encodeValue(e.raise));
  throw new TypeError('Unknown expression');
}
function nodeOptions(options={},programs={},encodeValue=encode) {
  const {equals=true,transparent=false,ownedWrite=false,lazy=false,sync=false,noSnapshot=false}=options;
  const callback=equals&&typeof equals==='object'?equals.callback:undefined;
  if(callback!==undefined&&programs.teardownActions)requireFunctionProgram(programs.teardownActions,callback);
  return R.nodeComparator(R.nodeOptions(equals!==false,transparent,ownedWrite,lazy,sync,noSnapshot,
    Object.hasOwn(options,'loadingValue'),encodeValue(options.loadingValue),programs[options.unobserved]??0),callback===undefined?0:programs[callback]);
}
export class BendRuntime {
  constructor({fuel=100000,async=false,clock}={}) { this.world=R.createWorld(); this.arrayViews=new RuntimeArrays(id=>{const item=list(this.world.arrays)[id];if(!item)throw new TypeError('Unknown array identity');return list(item.slots);},value=>this.decode(value)); this.ids={}; this.fuel=fuel; this.reverse={1:'root'}; this.programs={};this.contexts=Object.create(null);this.programActions=new Map();this.programNames=new Map();this.callbacks=new ProgramFunctions((id,...args)=>this.evaluate({invokeArgs:{callee:{lit:this.callbacks.get(id)},args:args.map(lit=>({lit}))}}),id=>list(this.world.cleanupPrograms)[id]?.arity??0); this.errors=new Map();this.refs=new Map();this.asyncRefs=new Map(); this.encountered=new Map(); this.futures={};this.programLabels=new Map();this.hostAsync=async;this.asyncErrors=[];this.ports={};this.portNames=new Map();this.portEvents=[];this.portSnapshots=[];this.hiddenNodes=new Set();this.clock=clock??{setTimeout,clearTimeout};this.timers=new Map();this.controllers={};this.abortNames=new Map();this.abortListeners=new Map();this.hostErrors=new HostErrors();this.anonymousOwners=new Map();this.rootDisposers=new RootDisposers(id=>{this.world=R.invokeRootDisposer(this.world,id);this.check();}); this.accessors=new SourceAccessors(id=>this.evaluate({invoke:{lit:this.accessors.get(id)}}));this.boundAccessors=new Set();this.writableSetters=new Set();this.setters=new SourceSetters((id,value)=>this.evaluate({invokeWith:{callee:{lit:this.setters.get(id)},value:{lit:value}}}));this.programActions.isAccessor=value=>this.accessors.identity(value)!==undefined||this.setters.identity(value)!==undefined||this.callbacks.identity(value)!==undefined; }
  decode(value){return decode(value,this.errors,this.refs,this.asyncRefs,this.hostErrors,this.rootDisposers,this.accessors,this.setters,this.callbacks,id=>this.arrayViews.get(id));}
  ownerId(name){
    if(name===null)return 0;
    const id=name==='root'?1:this.ids[name];
    if(!id||!R.validOwner(this.world,id))throw new TypeError('Unknown owner: '+name);
    return id;
  }
  encode(value){
    if(Array.isArray(value)){
      const id=this.arrayViews.identity(value);if(id===undefined)throw new TypeError('Build arrays with the typed array expression');return R.vArray(id);
    }
    for(const [id,port]of this.actionPorts??[])if(value===port.promise)return R.vAsync(id);
    if(value&&typeof value==='object'&&typeof value.reaction==='string'){
      const ref=this.reactionValues?.get(value.reaction);if(!ref)throw new TypeError('Unknown reaction: '+value.reaction);return ref;
    }
    const callback=this.callbacks.identity(value);
    if(callback!==undefined)return R.vProgram(callback);
    if(value&&typeof value==='object'&&typeof value.callback==='string'){
      const id=this.programs[value.callback];
      if(!id)throw new TypeError('Unknown callback function: '+value.callback);
      requireFunctionProgram(this.programActions,value.callback);
      return R.vProgram(id);
    }
    if((value instanceof BendNoOwnerError||value instanceof BendContextNotFoundError)&&this.errors.get(value.identity)===value)return R.vContextFailure(value.identity,value instanceof BendNoOwnerError?0:1);
    const setter=this.setters.identity(value);
    if(setter!==undefined)return R.vSetter(setter);
    if(value&&typeof value==='object'&&typeof value.setter==='string'){
      const id=this.ids[value.setter];
      if(!id||(this.nodes()[id].kind.$!=='Signal'&&!this.writableSetters.has(id)))throw new TypeError('Unknown signal setter: '+value.setter);
      return this.optimisticSetters?.has(id)?R.vProgram(this.optimisticSetters.get(id)):R.vSetter(id);
    }
    const accessor=this.accessors.identity(value);
    if(accessor!==undefined)return R.vAccessor(accessor);
    if(value&&typeof value==='object'&&typeof value.accessor==='string'){
      const id=this.ids[value.accessor];
      if(!id||(this.nodes()[id].kind.$!=='Signal'&&!this.boundAccessors.has(id)))throw new TypeError('Unknown signal accessor: '+value.accessor);
      return R.vAccessor(id);
    }
    const disposer=this.rootDisposers.identity(value);
    if(disposer!==undefined)return R.vRootDisposer(disposer);
    const described=this.hostErrors.describe(value);
    if(described&&typeof described==='object'&&typeof described.rootDisposer==='string'){
      const id=this.ownerId(described.rootDisposer);
      if(!R.validRoot(this.world,id))throw new TypeError('No bound disposer for owner: '+described.rootDisposer);
      return R.vRootDisposer(id);
    }
    if(described&&typeof described==='object'&&Object.hasOwn(described,'owner')&&typeof described.owner==='string')return R.vOwner(this.ownerId(described.owner));
    return encode(described);
  }
  context(name,value,description){
    if(Object.hasOwn(this.contexts,name))throw new TypeError('Context names must be unique');
    if(description!==undefined&&typeof description!=='string')throw new TypeError('Context descriptions must be strings');
    const encoded=this.encode(value),id=R.nextContextId(this.world);
    this.world=R.createContext(this.world,encoded,description===undefined?R.noDescription():R.contextDescription(description));this.contexts[name]=id;this.check();return id;
  }
  observe(value){
    if(Array.isArray(value)){
      this.observingArrays??=new Set();if(this.observingArrays.has(value))throw new TypeError('Cyclic arrays are outside the observation grammar');this.observingArrays.add(value);
      try{return value.map(item=>this.observe(item));}finally{this.observingArrays.delete(value);}
    }
    for(const [id,port]of this.actionPorts??[])if(value===port.promise)return {async:id};
    const callback=this.callbacks.identity(value);
    if(callback!==undefined){
      const node=[...(this.optimisticSetters??[])].find(([,id])=>id===callback)?.[0];
      if(node!==undefined)return {setter:this.reverse[node]};
      const name=this.programNames.get(callback);if(name!==undefined)return {callback:name};
      this.opaqueFunctions??=new WeakMap();
      if(!this.opaqueFunctions.has(value))this.opaqueFunctions.set(value,this.opaqueFunctionSerial=(this.opaqueFunctionSerial??0)+1);
      return {opaqueFunction:this.opaqueFunctions.get(value)};
    }
    if(value instanceof BendNoOwnerError||value instanceof BendContextNotFoundError){
      if(!this.encountered.has(value))this.encountered.set(value,this.encountered.size+1);
      return {[value instanceof BendNoOwnerError?'noOwnerError':'contextNotFoundError']:this.encountered.get(value)};
    }
    const setter=this.setters.identity(value);
    if(setter!==undefined)return {setter:this.reverse[setter]};
    const accessor=this.accessors.identity(value);
    if(accessor!==undefined)return {accessor:this.reverse[accessor]};
    const disposer=this.rootDisposers.identity(value);
    if(disposer!==undefined)return {rootDisposer:this.observe(this.decode(R.vOwner(disposer)))};
    if(value instanceof BendOwner){
      if(this.reverse[value.owner])return {owner:this.reverse[value.owner]};
      if(!this.anonymousOwners.has(value.owner))this.anonymousOwners.set(value.owner,this.anonymousOwners.size+1);
      return {anonymousOwner:this.anonymousOwners.get(value.owner)};
    }
    return this.hostErrors.observe(value);
  }
  evaluate(expr,previous){
    const m=R.evaluateExpression(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),this.encode(previous));
    this.world=R.resultWorld(m);this.check();return this.decode(R.resultValue(m));
  }
  root(name,expr,{owner='root',transparent=false}={}){
    const parent=this.ownerId(owner),id=R.nextId(this.world);this.ids[name]=id;this.reverse[id]=name;
    const m=R.createRoot(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>v?.owner===name?R.vOwner(id):this.encode(v),this.contexts),parent,transparent);
    this.world=R.resultWorld(m);this.check();return this.decode(R.resultValue(m));
  }
  disposeOwner(name){this.world=R.dispose(this.world,this.ownerId(name));this.check();}
  drainJobs() {
    if(!this.hostAsync)return;
    const jobs=list(this.world.hostJobs);this.world=R.clearHostJobs(this.world);
    for(const job of jobs){
      const kind=R.hostJobKind(job);
      if(kind===9){
        const port=this.actionPorts.get(job.result);
        (job.rejected?port.reject:port.resolve)(this.decode(job.value));
        continue;
      }
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
          if(kind===11)this.world=R.runOnFlush(this.fuel,this.world,job.body);
          else if(kind===10)this.world=R.adoptAction(this.fuel,this.world,job.action,job.value);
          else if(kind===1)this.world=R.deliver(this.fuel,this.world,job.observer,job.rejected,job.value);
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
    this.actionPorts??=new Map();
    for(const state of list(this.world.actions))if(!this.actionPorts.has(state.result)){
      let resolve,reject;const promise=new Promise((yes,no)=>{resolve=yes;reject=no;});
      promise.catch(()=>{}); // observe rejection through explicit user ports
      this.actionPorts.set(state.result,{promise,resolve,reject});this.asyncRefs.set(state.result,promise);
    }
    // Generated action callables share the function arena, not the reactive tree.
    for(const [id,program]of list(this.world.cleanupPrograms).entries())if(list(program.actions).some(action=>action.$==='ActionFunction')&&!this.programNames.has(id)){
      const name='@action'+(this.actionFunctionSerial=(this.actionFunctionSerial??0)+1);
      this.programNames.set(id,name);this.programs[name]=id;this.programActions.set(name,[]);
    }
    for(const [id,program]of list(this.world.cleanupPrograms).entries())if(list(program.actions).some(action=>action.$==='FlattenChildren')&&!this.programNames.has(id)){
      const name='@flatten'+(this.flattenSerial=(this.flattenSerial??0)+1);
      this.programNames.set(id,name);this.programs[name]=id;this.programActions.set(name,[]);
    }
    // Observe returned source closures; these labels do not create or arm nodes.
    for(const [index,state]of list(this.world.reactions).entries())if(!this.programNames.has(state.track)){
      const name='@reaction'+(index+1);this.programNames.set(state.track,name);this.programs[name]=state.track;this.programActions.set(name,[]);
    }
    this.optimisticSetters??=new Map();
    for(const [id,program]of list(this.world.cleanupPrograms).entries()){
      const [action,...tail]=list(program.actions);
      if(action?.$==='OptimisticSetter'&&!tail.length){
        this.optimisticSetters.set(action.signal,id);
        if(!this.programNames.has(id))this.programNames.set(id,'@optimistic:'+action.signal);
      }
    }
    // Observation labels come from the user ABI's actual allocation events.
    // Internal waiter nodes and ordinary top-level constructors are untouched.
    for(const event of list(this.world.events))if('created'in event&&!this.reverse[event.created]){
      const name='#nested'+(this.nestedSerial=(this.nestedSerial??0)+1);
      this.ids[name]=event.created;this.reverse[event.created]=name;
    }
    for(const event of list(this.world.events)){
      if('boundSetter'in event){this.writableSetters.add(event.boundSetter);this.boundAccessors.add(event.boundSetter);}
      if('boundAccessor'in event)this.boundAccessors.add(event.boundAccessor);
      if('indexBound'in event&&!this.reverse[event.indexBound]){
        const name='#listIndex'+(this.listIndexSerial=(this.listIndexSerial??0)+1);this.ids[name]=event.indexBound;this.reverse[event.indexBound]=name;this.boundAccessors.add(event.indexBound);
      }
      if('rowBound'in event&&!this.reverse[event.rowBound]){
        const name='#row'+(this.rowSerial=(this.rowSerial??0)+1);this.ids[name]=event.rowBound;this.reverse[event.rowBound]=name;this.boundAccessors.add(event.rowBound);
      }
    }
    this.arrayViews.sync();
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
  program(name,actions,arity=0) {
    if(!Number.isSafeInteger(arity)||arity<0)throw new TypeError('Function arity must be a natural number');
    if(this.programActions.has(name))throw new TypeError('Callback programs cannot be redefined');
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
      else if(op==='eval')p=R.programEvaluate(expression(args[0],this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),p);
      else if(op==='return')p=R.programReturn(expression(args[0],this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),p);
      else if(op==='updateExpr')p=R.programUpdateExpr(this.ids[args[0]],expression(args[1],this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),p);
      else if(op==='setExpr')p=R.programWriteExpr(this.ids[args[0]],expression(args[1],this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),p);
      else if(op==='throwExpr')p=R.programThrowExpr(expression(args[0],this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),p);
      else throw new TypeError('Unsupported callback action');
    }
    const id=R.nextProgramId(this.world);this.programs[name]=id;this.programNames.set(id,name);this.programLabels.set(id,this.programLabels.size+1);
    this.world=R.registerProgram(this.world,R.programArity(p,arity));this.check();return id;
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
    this.world=R.resolveValue(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts));this.bindAwaiter(id);this.check();
  }
  awaitUntil(name,expr,options={}){
    const id=R.nextAwaiterId(this.world);this.makePort(name,id);
    const timed=options.timeout!==undefined;
    if(timed&&(!Number.isSafeInteger(options.timeout)||options.timeout<0||options.timeout>2**31-1))throw new RangeError('Timeout protocol admits natural milliseconds through 2^31-1');
    const signal=options.signal===undefined?0:this.controllers[options.signal].id;
    this.world=R.untilWithOptions(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),timed,options.timeout??0,signal);this.bindAwaiter(id);this.check();
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
  runAction(name,plan){
    const promise=this.evaluate({action:plan});
    this.ports[name]={promise};
    promise.then(value=>{this.portEvents.push(['resolve',name,this.observe(value)]);this.portSnapshots.push([name,this.screen()]);},error=>{this.portEvents.push(['reject',name,this.errorShape(error)]);this.portSnapshots.push([name,this.screen()]);});
    return promise;
  }
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
    this.world=Object.hasOwn(options,'factoryThrows')
      ?R.createStreamWithFactory(this.world,inputs,options.hasReturn??true,Object.hasOwn(options,'returnThrows'),this.encode(options.returnThrows),this.futures[options.returnFuture]??0,true,this.encode(options.factoryThrows))
      :R.createStream(this.world,inputs,options.hasReturn??true,Object.hasOwn(options,'returnThrows'),this.encode(options.returnThrows),this.futures[options.returnFuture]??0);
    this.check();return id;
  }
  resolveStep(name,value,done=false){this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],false,R.vStepResult(done,this.encode(value)));this.check();}
  resolveStream(name,stream){this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],false,R.vAsync(this.futures[stream]));this.check();}
  thenIO(){
    const objects=list(this.world.asyncObjects);
    return Object.entries(this.futures).filter(([,id])=>!objects[id].stream).map(([name,id])=>[name,list(objects[id].observers).length]);
  }
  iteratorMethods(){
    const external=new Map(),calls=[];
    for(const event of list(this.world.iteratorEvents)){
      if('object'in event&&'iterator'in event){if(!external.has(event.iterator))external.set(event.iterator,external.size+1);}
      if('argument'in event){
        if(!external.has(event.iterator))throw new Error('Iterator method precedes its external factory call');
        calls.push(['index'in event?'next':'return',external.get(event.iterator),'value'in event.argument?[this.observe(this.decode(event.argument.value))]:[]]);
      }
    }
    return calls;
  }
  iteratorIO(){
    const names=new Map(Object.entries(this.futures).map(([name,id])=>[id,name]));
    // Internal deferred wrappers share the typed arena but are not producer
    // objects. Normalize external identities by first observed factory call,
    // retaining every event and all subsequent identity/alias relationships.
    const external=new Map();
    return list(this.world.iteratorEvents).map(e=>{
      if('error'in e)return ['factory-throw',names.get(e.object),this.errorShape(this.decode(e.error))];
      if('object'in e){if(!external.has(e.iterator))external.set(e.iterator,external.size+1);return ['start',names.get(e.object),external.get(e.iterator)];}
      if(!external.has(e.iterator))throw new Error('Iterator event precedes its external factory call');
      return 'index'in e?['next',external.get(e.iterator),e.index]:['return',external.get(e.iterator)];
    });
  }
  resolve(name,value) {this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],false,this.encode(value));this.check();}
  reject(name,error) {this.world=R.resolveThenable(this.fuel,this.world,this.futures[name],true,this.encode(error));this.check();}
  signal(name,value,equals=true) {
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    const options=typeof equals==='boolean'?{equals}:equals;
    requireTeardownProgram(this.programActions,options.unobserved);
    const encoded=this.encode(value);
    this.world=[tags.disposer,tags.accessor,tags.setter,tags.callback].includes(encoded.$)?R.createSignalInput(this.fuel,this.world,encoded,nodeOptions(options,this.programs,v=>this.encode(v))):R.createSignalWithOptions(this.world,encoded,nodeOptions(options,this.programs,v=>this.encode(v))); this.check(); return id;
  }
  deferred(name,expr,options={}) {
    requireTeardownProgram(this.programActions,options.unobserved);
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    this.world=R.createDeferred(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),nodeOptions(options,this.programs,v=>this.encode(v)),this.ownerId(Object.hasOwn(options,'owner')?options.owner:'root')); this.check(); return id;
  }
  memo(name,expr,options={}) {
    requireTeardownProgram(this.programActions,options.unobserved);
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    this.world=R.createMemoWithOptions(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),nodeOptions(options,this.programs,v=>this.encode(v)),this.ownerId(Object.hasOwn(options,'owner')?options.owner:'root')); this.check(); return id;
  }
  reaction(name,body,options={}){
    this.reactionValues??=new Map();const id=R.nextProgramId(this.world)+1;this.reactionValues.set(name,R.vProgram(id));
    const m=R.createReaction(this.fuel,this.world,expression(body,this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),this.programs[options.errorProgram]??0,nodeOptions(options,this.programs,v=>this.encode(v)),options.schedule??false,this.ownerId(Object.hasOwn(options,'owner')?options.owner:'root'));
    this.world=R.resultWorld(m);this.check();return this.decode(R.resultValue(m));
  }
  track(name,body){
    return this.evaluate({reactionArm:{callee:{lit:{reaction:name}},tracking:body}});
  }
  settled(name,body,{owner='root'}={}) {
    const before=R.nextId(this.world);
    this.world=R.onSettled(this.fuel,this.world,expression(body,this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),this.ownerId(owner));
    if(R.nextId(this.world)>before){this.ids[name]=before;this.reverse[before]=name;}
    this.check();
  }
  onFlush(body) {
    this.world=R.onFlush(this.world,expression(body,this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts));
    this.check();
  }
  tracked(name,body,{owner='root'}={}) {
    const id=R.nextId(this.world);this.ids[name]=id;this.reverse[id]=name;
    this.world=R.createTrackedEffect(this.fuel,this.world,expression(body,this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),this.ownerId(owner));this.check();return id;
  }
  effect(name,expr,options={}) {
    requireTeardownProgram(this.programActions,options.unobserved);
    requireTeardownProgram(this.programActions,options.cleanup);
    if(options.returnCleanup&&(options.cleanup||!options.program))throw new TypeError('Returned cleanup requires a body and excludes static cleanup');
    const {user=false,target=2,schedule=false,defer=false}=options;
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    if (!user) this.world=R.attach(this.world,1,target);
    this.world=(options.returnCleanup?R.createReturningEffect:R.createEffectWithHandlers)(this.fuel,this.world,expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts),user,target,schedule,defer,nodeOptions(options,this.programs,v=>this.encode(v)),this.ownerId(Object.hasOwn(options,'owner')?options.owner:'root'),this.programs[options.program]??0,...(options.returnCleanup?[]:[this.programs[options.cleanup]??0]),this.programs[options.error]??0); this.check(); return id;
  }
  set(name,value) {
    const m=R.setValue(this.fuel,this.world,this.ids[name],this.encode(value));
    this.world=R.resultWorld(m);this.check();return typeof value==='number'?value:this.decode(R.resultValue(m));
  }
  update(name,expr) {
    // The Bend engine evaluates the updater against its staged slot.
    const encoded=expression(expr,this.ids,this.programs,this.futures,v=>this.encode(v),this.contexts);
    const m=R.updateValue(this.fuel,this.world,this.ids[name],encoded);
    this.world=R.resultWorld(m);this.check();return this.decode(R.resultValue(m));
  }
  read(name) {
    const m=R.read(this.fuel,this.world,this.ids[name]);
    this.world=R.resultWorld(m); this.check(); return this.decode(R.resultValue(m));
  }
  flush(body) { if(arguments.length)return this.evaluate({flush:body});this.world=R.flush(this.fuel,this.world); this.check(); }
  markRefresh(name) { this.world=R.markRefresh(this.world,this.ids[name]); this.check(); }
  refresh(name) { this.awaitRefresh('refresh#'+Object.keys(this.ports).length,name); }
  resetErrorHalt() { this.world=R.resetErrorHalt(this.world); }
  dispose() { this.world=R.dispose(this.world,1); this.check(); }
  nodes() { return list(this.world.nodes); }
  trace() {
    const name=id=>this.reverse[id] ?? null;
    return list(this.world.events).filter(e=>!('created'in e)&&!('boundSetter'in e)&&!('boundAccessor'in e)&&!('rowBound'in e)&&!('indexBound'in e)&&!this.hiddenNodes.has(e.reader??e.id)).map(e=> {
      if ('callback' in e) return ['cleanup',this.programLabels.get(e.callback)??e.callback,e.code];
      if ('previous' in e) return ['apply',name(e.id),this.observe(this.decode(e.value)),this.observe(this.decode(e.previous))];
      if ('reader' in e) return ['read',name(e.reader),name(e.source),this.observe(this.decode(e.value))];
      return ['compute',name(e.id)];
    });
  }
  screen(target=2) { return this.observe(this.decode(R.displayed(this.world,target))); }
}
