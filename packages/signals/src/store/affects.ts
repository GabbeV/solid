/**
 * Store — the store half of `affects()` (plan sec. 29, plan sec. 37; A24 (4), #2882,
 * #2893, #2904).
 *
 * A declaration belongs to the targeted reactive source, not to every
 * store borrowing the same backing object. Keyed marks cover one output
 * slot. Keyless marks cover the record's descendants at declaration. Captured row
 * wrappers retain the declaration across backing replacement. An independent
 * input store remains unaffected, even when its data backs a derived row.
 *
 * A declaration materializes descendant wrappers, but leaves their signal
 * nodes lazy. Wrapper identity retains coverage when backing changes.
 * Chained views can inherit declarations from their inputs;
 * declarations on those views never travel in the reverse direction.
 *
 * Imported by `affects()`, which installs it on its first store target
 * (#3891, after #3912): a program with stores that never declares a mark
 * carries none of it. It never imports store.ts — the engine's top level —
 * so a program declaring marks without stores carries this module alone:
 * the store's nodes and child wrapping come through `GlobalQueue`
 * (`_storeNode`, `_storeChild`), and node birth and the untracked traps
 * reach back through `affectsHooks` (hooks.ts).
 */
import { GlobalQueue, releaseMarksHook } from "../core/scheduler.js";
import type { Computed, Signal } from "../core/types.js";
import { installAffectsHooks, optHooks, type AffectsHooks } from "./hooks.js";
import { $OWNER, type StoreTarget } from "./target.js";
import { $TARGET } from "./types.js";

type Marked = Signal<any> | Computed<any>;

/** The keyless mark's carrier key: a leaf of the record no read serves. */
const $AFFECTS: unique symbol = Symbol(__DEV__ ? "STORE_AFFECTS" : 0);

/** Source-local coverage and late-born nodes sharing one carrier's lifetime.
 * The scope dies when the carrier's last registration ends. */
interface Scope {
  _scope: Set<StoreTarget>;
  _inherited: Marked[];
  _key: PropertyKey | undefined;
}
const scopes = new Map<Marked, Scope>();

function scopeOf(carrier: Marked, key: PropertyKey | undefined): Scope {
  let entry = scopes.get(carrier);
  if (entry === undefined)
    scopes.set(
      carrier,
      (entry = {
        _scope: new Set(),
        _inherited: [],
        _key: key
      })
    );
  return entry;
}

/** The nodes an `affects(store[, key])` declaration marks (affects.ts
 * registers each). */
export function storeMarks(t: StoreTarget, key: PropertyKey | undefined): Marked[] {
  const node = GlobalQueue._storeNode!(t, key === undefined ? $AFFECTS : key);
  const entry = scopeOf(node, key);
  entry._scope.add(t);
  if (key === undefined) {
    const found: Marked[] = [node];
    walk(t, entry, found, new Set());
    return found;
  }
  return [node];
}

/** Capture this store's descendant wrappers without pulling derivations or
 * reading through their reactive traps. Leaf nodes remain lazy. */
function walk(t: StoreTarget, entry: Scope, found: Marked[], visited: Set<StoreTarget>): void {
  if (visited.has(t)) return;
  visited.add(t);
  entry._scope.add(t);
  let raw = t.pb ?? t.v;
  while (raw[$TARGET]) {
    const inner = raw[$TARGET] as StoreTarget;
    raw = inner.pb ?? inner.v;
  }
  if (optHooks !== null && t.o) raw = optHooks.view(t, raw, true);
  const nodes = t.n;
  if (nodes !== null)
    for (const k of Reflect.ownKeys(nodes))
      // Another mark's carrier retains its own lifetime.
      if (k !== $AFFECTS) found.push(nodes[k as any]);
  const has = t.h;
  if (has !== null) for (const k of Reflect.ownKeys(has)) found.push(has[k as any]);
  if (t.k !== null) found.push(t.k);
  if (t.dk !== null) found.push(t.dk);
  for (const k of Reflect.ownKeys(raw))
    if (k !== $OWNER) {
      const d = Object.getOwnPropertyDescriptor(raw, k)!;
      if (d.get === undefined) {
        const child = GlobalQueue._storeChild!(t, k, d.value);
        if (child) walk(child, entry, found, visited);
      }
    }
}

/** Match this source or a directed input of a chained view. Shared backing
 * identity alone never transfers a declaration between source families. */
function covers(t: StoreTarget, key: PropertyKey | undefined, entry: Scope): boolean {
  if (entry._key !== undefined && entry._key !== key) return false;
  for (let source: StoreTarget = t; ; ) {
    if (entry._scope.has(source)) return true;
    const inner: StoreTarget | undefined = source.v?.[$TARGET];
    if (inner === undefined) break;
    if (inner === source) break;
    source = inner;
  }
  return false;
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
