/**
 * Store — the store half of `affects()` (plan sec. 29, plan sec. 37; A24 (4), #2882,
 * #2893, #2904).
 *
 * A declaration belongs to the targeted reactive source, not to every
 * store borrowing the same backing object. Keyed marks cover one output
 * slot. Keyless marks cover the record's own descendants; a derived or
 * optimistic root also covers future outputs of that source. Captured row
 * wrappers retain the declaration across backing replacement. An independent
 * input store remains unaffected, even when its data backs a derived row.
 *
 * Raw identities locate descendants that have no nodes yet, qualified by
 * their source family. Existing proxy identities retain coverage when their
 * backing changes. Chained views can inherit declarations from their inputs;
 * declarations on those views never travel in the reverse direction.
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

/** Source-local coverage and late-born nodes sharing one carrier's lifetime.
 * The scope dies when the carrier's last registration ends. */
interface Scope {
  _scope: Set<object>;
  _inputs?: Set<object>;
  _inherited: Marked[];
  _key: PropertyKey | undefined;
  _target: StoreTarget;
  _wholeFamily: boolean;
}
const scopes = new Map<Marked, Scope>();

function scopeOf(carrier: Marked, key: PropertyKey | undefined, target: StoreTarget): Scope {
  let entry = scopes.get(carrier);
  if (entry === undefined)
    scopes.set(
      carrier,
      (entry = {
        _scope: new Set(),
        _inherited: [],
        _key: key,
        _target: target,
        _wholeFamily: key === undefined && target._fam !== null && target.u === null
      })
    );
  return entry;
}

/** The nodes an `affects(store[, key])` declaration marks (affects.ts
 * registers each). */
export function storeMarks(t: StoreTarget, key: PropertyKey | undefined): Marked[] {
  const node = GlobalQueue._storeNode!(t, key === undefined ? $AFFECTS : key);
  const entry = scopeOf(node, key, t);
  entry._scope.add(t.px);
  if (key === undefined) {
    const found: Marked[] = [node];
    if (entry._wholeFamily && t._fam!.node) found.push(t._fam!.node);
    walk(t.px, entry, found, t, new Set());
    return found;
  }
  if (!t.ch) entry._scope.add(t.v);
  if (t.pb !== null) entry._scope.add(t.pb);
  return [node];
}

/** Register existing output nodes and identities for lazy descendants.
 * Walk backing data without reading a foreign source through its proxy. */
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
    // Follow the input's backing and collect identities for this store's view.
    const inputs = (entry._inputs ??= new Set());
    const identity = t?.px ?? raw;
    if (inputs.has(identity)) return;
    inputs.add(identity);
    if (t) {
      const view = scopeKey(parent).map?.get(t.px);
      if (view) {
        if (view.v !== t.px || view.pb !== null)
          return walk(view.px, entry, found, parent, visited);
        entry._scope.add(view.px);
        nodesOf(view, found);
      }
      input = t;
    }
  } else {
    if (t) {
      if (visited.has(t.px)) return;
      visited.add(t.px);
      entry._scope.add(t.px);
      nodesOf(t, found);
      if (t.ch && raw === t.v && !t._fam?.opt) return walk(raw, entry, found, t, visited);
      if (!t.ch) entry._scope.add(t.v);
      if (optHooks && t._fam?.opt === true) raw = optHooks.view(t, raw, true);
      parent = t;
    }
    if (visited.has(raw)) return;
    visited.add(raw);
    entry._scope.add(raw);
  }
  for (const k of Reflect.ownKeys(raw))
    if (k !== $OWNER) {
      const d = Object.getOwnPropertyDescriptor(raw, k)!;
      if (d.get === undefined) walk(d.value, entry, found, parent, visited, input);
    }
}

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

/** Check the target and the inputs it follows. Foreign backing identities
 * only identify views within the marked store. */
function covers(t: StoreTarget, key: PropertyKey | undefined, entry: Scope): boolean {
  if (entry._key !== undefined && entry._key !== key) return false;
  let localView = false;
  for (let source: StoreTarget = t; ; ) {
    const inner: StoreTarget | undefined = source.v?.[$TARGET];
    if (
      entry._scope.has(source.px) ||
      (source._fam === entry._target._fam &&
        (entry._wholeFamily ||
          (!inner && entry._scope.has(source.v)) ||
          (source.pb !== null && entry._scope.has(source.pb))))
    )
      return true;
    if (inner && scopeKey(source) === scopeKey(entry._target)) localView = true;
    if (
      localView &&
      (entry._inputs?.has(source.v) || (source.pb !== null && entry._inputs?.has(source.pb)))
    )
      return true;
    if (inner === undefined || inner === source) return false;
    source = inner;
  }
}

/** The store's side: node birth and the untracked traps call it (store.ts,
 * through `affectsHooks`) — with no live mark too: an empty scope map is
 * no work. */
const hooks: AffectsHooks = {
  // A node born on a record a live mark covers inherits it (released with
  // the carrier's last registration).
  _born(t, node, key) {
    if (scopes.size === 0 || key === $AFFECTS) return;
    for (const [carrier, entry] of scopes) {
      if (carrier === node || !covers(t, key, entry)) continue;
      if (scopeKey(t) === scopeKey(entry._target)) entry._scope.add(t.px);
      GlobalQueue._mark!(node);
      entry._inherited.push(node);
    }
  },
  // An untracked probe (`isPending(() => s.x)` with no observer) reading a
  // record a live mark covers: no node carries the mark for it — the
  // verdict is told directly.
  _witness(t, key) {
    for (const entry of scopes.values())
      if (covers(t, key, entry)) {
        GlobalQueue._witnessMark!();
        return;
      }
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
