/**
 * Store — the store half of `affects()` (plan sec. 29, plan sec. 37; A24 (4), #2882,
 * #2893, #2904).
 *
 * A mark on a store is a mark on nodes (affects.ts: a count on the node, a
 * dependency walk at probe time): `affects(record, key)` marks the slot's
 * leaf; `affects(record)` marks a carrier (the record's `$AFFECTS` leaf)
 * and every live node in the record's subtree — the edges existing readers
 * subscribed through. Coverage is by RAW IDENTITY, not read path (#2882: a
 * captured row proxy, a derived store sharing the source's raw, never read
 * through the declaration's proxy): the identities reachable at the
 * declaration are the mark's `scope`, so a node born inside the window on
 * a covered record inherits the mark (released with the carrier's last),
 * and an untracked probe through a record with no nodes is witnessed into
 * the verdict. A mark declared on a draft (inside a setter) or over an
 * optimistic family walks the view the writer sees.
 *
 * Imported by `affects()`, which installs it on its first store target
 * (#3891, after #3912): a program with stores that never declares a mark
 * carries none of it. It never imports store.ts — the engine's top level —
 * so a program declaring marks without stores carries this module alone:
 * the store's nodes and its wrappability test come through `GlobalQueue`
 * (`_storeNode`, `_storeWrappable`), and node birth and the untracked traps
 * reach back through `affectsHooks` (hooks.ts).
 */
import { GlobalQueue, releaseMarksHook } from "../core/scheduler.js";
import type { Computed, Signal } from "../core/types.js";
import { installAffectsHooks, optHooks, type AffectsHooks } from "./hooks.js";
import { $OWNER, lookupTarget, scopeKey, type StoreTarget } from "./target.js";
import { $TARGET } from "./types.js";

type Marked = Signal<any> | Computed<any>;

/** The keyless mark's carrier key: a leaf of the record no read serves. */
const $AFFECTS: unique symbol = Symbol(__DEV__ ? "STORE_AFFECTS" : 0);

/** A live mark's scope: the raw identities it covers (keyless: every record
 * reachable at the declaration; keyed: the owning record's), the nodes born
 * inside its window that inherited it, and — keyed — the one key. Dies with
 * the carrier's last registration. */
interface Scope {
  _scope: Set<object>;
  cold?: Set<object>;
  _inherited: Marked[];
  _key: PropertyKey | undefined;
}
const scopes = new Map<Marked, Scope>();

function scopeOf(carrier: Marked, key: PropertyKey | undefined): Scope {
  let entry = scopes.get(carrier);
  if (entry === undefined)
    scopes.set(carrier, (entry = { _scope: new Set(), _inherited: [], _key: key }));
  return entry;
}

/** The nodes an `affects(store[, key])` declaration marks (affects.ts
 * registers each). */
export function storeMarks(t: StoreTarget, key: PropertyKey | undefined): Marked[] {
  const node = GlobalQueue._storeNode!(t, key === undefined ? $AFFECTS : key);
  const entry = scopeOf(node, key);
  if (key === undefined) {
    const found: Marked[] = [node];
    walk(t.px, entry, found, t, new Set());
    return found;
  }
  entry._scope.add(t.v);
  if (t.pb !== null) entry._scope.add(t.pb);
  return [node];
}

/** The identities reachable from `value` into the scope (the draft's and
 * the committed backing both, when a draft is open; an optimistic family's
 * view), every live node under each record into `found`. Untracked by
 * construction: raws, never traps. */
function walk(
  value: any,
  entry: Scope,
  found: Marked[],
  parent: StoreTarget,
  visited: Set<object>,
  input?: StoreTarget
): void {
  if (!GlobalQueue._storeWrappable!(value)) return;
  const t: StoreTarget | undefined = value[$TARGET] ?? lookupTarget(value, (input ?? parent)._fam);
  if (t && t.px === value && scopeKey(t) !== scopeKey(parent)) input = t;
  let raw = t ? (t.pb ?? t.v) : value;
  if (input) {
    // Follow the input's data, marking only this store's view (§7b, #4914).
    if (t) {
      if (visited.has(t.px)) return;
      visited.add(t.px);
      entry._scope.add(t.px);
      const view = scopeKey(parent).map?.get(t.px);
      if (view) {
        if (view.v !== t.px || view.pb) return walk(view.px, entry, found, parent, visited);
        nodesOf(view, found);
      }
      input = t;
    } else {
      // A child first wrapped during the window inherits through this view.
      const cold = (entry.cold ??= new Set());
      if (cold.has(raw)) return;
      cold.add(raw);
    }
  } else {
    if (t && t.ch && raw === t.v && !t.o) return walk(raw, entry, found, t, visited);
    if (visited.has(raw)) return;
    visited.add(raw);
    entry._scope.add(raw);
    if (t) {
      if (t.pb !== null) entry._scope.add(t.v);
      if (optHooks !== null && t.o) raw = optHooks.view(t, raw, true);
      nodesOf(t, found);
      parent = t;
    }
  }
  for (const k of Reflect.ownKeys(raw))
    if (k !== $OWNER) {
      const d = Object.getOwnPropertyDescriptor(raw, k)!;
      if (d.get === undefined) walk(d.value, entry, found, parent, visited, input);
    }
}

/** Every live node of `t` into `found`. */
function nodesOf(t: StoreTarget, found: Marked[]): void {
  const nodes = t.n;
  if (nodes !== null)
    for (const k of Reflect.ownKeys(nodes))
      // Another mark's carrier is its own channel: counting it here would
      // extend that scope's lifetime to this declaration's.
      if (k !== $AFFECTS) found.push(nodes[k as any]);
  const has = t.h;
  if (has !== null) for (const k of Reflect.ownKeys(has)) found.push(has[k as any]);
  if (t.k !== null) found.push(t.k);
  if (t.dk !== null) found.push(t.dk);
}

/** A live scope covering `t`'s identity (keyed: for `key`). Chained
 * backings (§7b): a view's backing is another store's proxy — marks cover
 * the BASE raw, so every identity along the chain is checked. */
function covering(t: StoreTarget, key: PropertyKey | undefined, skip?: Marked): Marked | null {
  for (const [carrier, entry] of scopes) {
    if (carrier === skip || (entry._key !== undefined && entry._key !== key)) continue;
    let view = t;
    let localView = false;
    for (let r: any = t.v; ; ) {
      const inner: StoreTarget | undefined = r?.[$TARGET];
      if (inner && scopeKey(view) === scopeKey((carrier as any)._host)) localView = true;
      if ((entry._scope.has(r) && (!inner || localView)) || (localView && entry.cold?.has(r)))
        return carrier;
      if (inner === undefined) break;
      const backing = inner.pb ?? inner.v;
      if (backing === r) break;
      view = inner;
      r = backing;
    }
  }
  return null;
}

/** The store's side: node birth and the untracked traps call it (store.ts,
 * through `affectsHooks`) — with no live mark too: an empty scope map is
 * no work. */
const hooks: AffectsHooks = {
  // A node born on a record a live mark covers inherits it (released with
  // the carrier's last registration).
  _born(t, node, key) {
    if (scopes.size === 0 || key === $AFFECTS) return;
    const carrier = covering(t, key, node);
    if (!carrier) return;
    GlobalQueue._mark!(node);
    scopes.get(carrier)!._inherited.push(node);
  },
  // An untracked probe (`isPending(() => s.x)` with no observer) reading a
  // record a live mark covers: no node carries the mark for it — the
  // verdict is told directly.
  _witness(t, key) {
    if (t.n?.[$AFFECTS as any]?._x?._marks || covering(t, key)) GlobalQueue._witnessMark!();
  }
};

/** `affects()` calls it before a store-targeted declaration (idempotent). */
export function installStoreAffects(): void {
  installAffectsHooks(hooks);
}

/** The carrier's last mark released (affects.ts): its scope dies, and the
 * nodes that inherited the mark release theirs. */
export function releaseMarkScope(carrier: Marked): void {
  const entry = scopes.get(carrier);
  if (entry === undefined) return;
  scopes.delete(carrier);
  releaseMarksHook!(entry._inherited);
}
