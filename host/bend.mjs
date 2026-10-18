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
  text:R.vText('').$, healthy:R.createWorld().fault.$,
};
export function decode(v) {
  switch (v.$) {
    case tags.undefined: return undefined;
    case tags.null: return null;
    case tags.number: return v.n;
    case tags.bool: return v.b;
    case tags.ref: return {ref:v.id};
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
  if (typeof v === 'object' && Number.isSafeInteger(v.ref) && v.ref >= 0) return R.vReference(v.ref);
  throw new TypeError('Use an opaque {ref: id} token for arbitrary host objects');
}
export function expression(e, ids) {
  if (Object.hasOwn(e,'lit')) return R.literal(encode(e.lit));
  if (e.read) return R.source(ids[e.read]);
  if (e.prev) return R.previous();
  if (e.add) return R.add(...e.add.map(x=>expression(x,ids)));
  if (e.mul) return R.multiply(...e.mul.map(x=>expression(x,ids)));
  if (e.same) return R.same(...e.same.map(x=>expression(x,ids)));
  if (e.select) return R.select(...e.select.map(x=>expression(x,ids)));
  if (e.untrack) return R.untrack(expression(e.untrack,ids));
  if (Object.hasOwn(e,'raise')) return R.unsupportedError(encode(e.raise));
  throw new TypeError('Unknown expression');
}
export class BendRuntime {
  constructor({fuel=100000}={}) { this.world=R.createWorld(); this.ids={}; this.fuel=fuel; this.reverse={1:'root'}; }
  check() { if(this.world.fault.$ !== tags.healthy) throw new Error(`Bend runtime stopped: ${JSON.stringify(this.world.fault)}`); }
  signal(name,value,equals=true) {
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    this.world=R.createSignal(this.world,encode(value),equals); this.check(); return id;
  }
  memo(name,expr,{equals=true,lazy=false}={}) {
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    this.world=R.createMemo(this.fuel,this.world,expression(expr,this.ids),equals,lazy,1); this.check(); return id;
  }
  effect(name,expr,{user=false,target=2,schedule=false,defer=false}={}) {
    const id=R.nextId(this.world); this.ids[name]=id; this.reverse[id]=name;
    if (!user) this.world=R.attach(this.world,1,target);
    this.world=R.createEffect(this.fuel,this.world,expression(expr,this.ids),user,target,schedule,defer,1); this.check(); return id;
  }
  set(name,value) { this.world=R.setSignal(this.world,this.ids[name],encode(value)); this.check(); return value; }
  update(name,expr) {
    // The Bend engine evaluates the updater against its staged slot.
    const encoded=expression(expr,this.ids);
    this.world=R.setUpdater(this.fuel,this.world,this.ids[name],encoded); this.check();
    const n=this.nodes()[this.ids[name]];
    return decode(Object.hasOwn(n.pending,'value') ? n.pending.value : n.value);
  }
  read(name) {
    const m=R.read(this.fuel,this.world,this.ids[name]);
    this.world=R.resultWorld(m); this.check(); return decode(R.resultValue(m));
  }
  flush() { this.world=R.flush(this.fuel,this.world); this.check(); }
  refresh(name) { this.world=R.refresh(this.world,this.ids[name]); this.check(); }
  dispose() { this.world=R.dispose(this.world,1); this.check(); }
  nodes() { return list(this.world.nodes); }
  trace() {
    const name=id=>this.reverse[id] ?? null;
    return list(this.world.events).map(e=> {
      if ('previous' in e) return ['apply',name(e.id),decode(e.value),decode(e.previous)];
      if ('reader' in e) return ['read',name(e.reader),name(e.source),decode(e.value)];
      return ['compute',name(e.id)];
    });
  }
  screen(target=2) { return decode(R.displayed(this.world,target)); }
}
