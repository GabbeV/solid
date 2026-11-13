/** Array structure owns a publication boundary without guessing array contents. */
import { computed, read, signal } from "../core/core.js";
import { CONFIG_AUTO_DISPOSE, REACTIVE_DISPOSED } from "../core/constants.js";
import { flushTransaction, insertSubs, joinFuture, schedule } from "../core/scheduler.js";
import {
  createOptimisticSlot,
  createOptimisticStoreInput,
  entangleOptimisticSlotRead
} from "../layers/optimistic.js";
import {
  getNode,
  getContainerNode,
  pullFamilyInput,
  targetsEqual,
  sameKey,
  unwrapValue
} from "./store.js";
import { optHooks } from "./hooks.js";
import { dispose } from "../core/owner.js";
import type { StoreTarget } from "./target.js";
import { isWrappable } from "./types.js";

type Slot = ReturnType<typeof createOptimisticSlot<any>>;
type ArraySlots = {
  slots: Map<PropertyKey, Slot>;
  presence: Map<PropertyKey, Slot>;
  shape: Map<PropertyKey, Slot>;
};
type ArrayState = { retiring: Set<Slot>; length?: Slot; structure?: Slot };
const arrays = new WeakMap<StoreTarget, ArrayState>();
const active = new Set<StoreTarget>();
const ownedInputs = new WeakMap<Slot, ReturnType<typeof computed>>();

function state(t: StoreTarget): ArrayState {
  let r = arrays.get(t);
  if (!r) arrays.set(t, (r = { retiring: new Set() }));
  return r;
}
function discover(t: StoreTarget) {
  if (t.k) insertSubs(t.k);
  if (t.n?.length) insertSubs(t.n.length);
  // Existing readers must rediscover a newly selected length or unlink a
  // retired selected length before its companion can be released.
  const r = arrays.get(t);
  if (r?.length) insertSubs(r.length.output);
  if (r) for (const retired of r.retiring) insertSubs(retired.output);
  schedule();
}
export function arrayIndex(key: PropertyKey): number {
  if (typeof key !== "string" || key === "") return -1;
  const n = Number(key);
  return Number.isInteger(n) && n >= 0 && n < 4294967295 && String(n) === key ? n : -1;
}

export function selectedArrayLength(
  t: StoreTarget,
  base: number | (() => number),
  writer = false
): number {
  const slot = arrays.get(t)?.length;
  return slot
    ? ((writer ? slot.writerValue() : read(slot.output)) as number)
    : typeof base === "function"
      ? base()
      : base;
}
export function arrayGrowthStands(t: StoreTarget): boolean {
  const r = arrays.get(t);
  return !!(r?.length?.activeOwner() || r?.structure?.activeOwner());
}

export function readArrayLength(t: StoreTarget): void {
  const slot = arrays.get(t)?.length;
  if (slot) entangleOptimisticSlotRead(slot);
}

/** Shared net array-shape test; row arrangement can add another boundary. */
export function arrayStructureChanged(
  t: StoreTarget,
  previous: Record<PropertyKey, any>,
  next: Record<PropertyKey, any>
): boolean {
  if (previous.length !== next.length) return true;
  for (const key of new Set([...Reflect.ownKeys(previous), ...Reflect.ownKeys(next)])) {
    if (arrayIndex(key) < 0) continue;
    const before = Object.getOwnPropertyDescriptor(previous, key);
    const after = Object.getOwnPropertyDescriptor(next, key);
    if (
      !!before !== !!after ||
      before?.enumerable !== after?.enumerable ||
      before?.configurable !== after?.configurable ||
      before?.writable !== after?.writable ||
      before?.get !== after?.get ||
      before?.set !== after?.set
    )
      return true;
  }
  const keyFn = t._fam?.key;
  if (keyFn) {
    for (const key of Reflect.ownKeys(previous)) {
      if (arrayIndex(key) < 0) continue;
      const a = unwrapValue(Object.getOwnPropertyDescriptor(previous, key)?.value);
      const b = unwrapValue(Object.getOwnPropertyDescriptor(next, key)?.value);
      const before = isWrappable(a) ? keyFn(a) : undefined;
      const after = isWrappable(b) ? keyFn(b) : undefined;
      if ((before !== undefined || after !== undefined) && !sameKey(before, after)) return true;
    }
  }
  // A permutation rearranges existing positional identities. Replacing a
  // value with a new value leaves the multiset different and remains a leaf edit.
  const counts = new Map<any, number>();
  const negativeZero = {};
  const identity = (value: any) => (Object.is(value, -0) ? negativeZero : value);
  let moved = false;
  for (const key of Reflect.ownKeys(previous)) {
    if (arrayIndex(key) < 0) continue;
    const a = unwrapValue(Object.getOwnPropertyDescriptor(previous, key)?.value);
    const b = unwrapValue(Object.getOwnPropertyDescriptor(next, key)?.value);
    moved ||= !Object.is(a, b) && !targetsEqual(a, b);
    const before = identity(a),
      after = identity(b);
    counts.set(before, (counts.get(before) ?? 0) + 1);
    counts.set(after, (counts.get(after) ?? 0) - 1);
  }
  return moved && [...counts.values()].every(count => count === 0);
}

/** An incoming structural answer joins active direct edits, and retains that
 * boundary for setters arriving before the structural answer publishes. */
export function joinArrayIncoming(t: StoreTarget, slots: ArraySlots): void {
  let r = arrays.get(t);
  let selected = false;
  const join = (slot: Slot) => {
    const owner = slot.activeOwner();
    if (owner) {
      selected = true;
      joinFuture(owner);
    }
  };
  for (const map of [slots.slots, slots.presence, slots.shape])
    for (const slot of map.values()) join(slot);
  if (r) {
    if (r.length) join(r.length);
    if (r.structure) join(r.structure);
  }
  if (!selected || !flushTransaction) return;
  r ??= state(t);
  r.structure ??= createOptimisticSlot(signal(false), undefined, undefined, () => schedule());
  r.structure.propose(true);
  active.add(t);
}

/** Coordinate the final setter diff, after its direct slots have been created.
 * A structural marker carries ownership only, never an array-value snapshot. */
export function coordinateArrayWrites(
  t: StoreTarget,
  previous: Record<PropertyKey, any>,
  next: Record<PropertyKey, any>,
  slots: ArraySlots,
  rearranged = false
): void {
  if (!Array.isArray(next)) return;
  const keys = new Set([...Reflect.ownKeys(previous), ...Reflect.ownKeys(next)]);
  const structural = rearranged || arrayStructureChanged(t, previous, next);
  let changed = structural;
  for (const key of keys) {
    if (key === "length") continue;
    const before = Object.getOwnPropertyDescriptor(previous, key);
    const after = Object.getOwnPropertyDescriptor(next, key);
    const presence = !!before !== !!after;
    const a = unwrapValue(before?.value),
      b = unwrapValue(after?.value);
    const value = !Object.is(a, b) && !targetsEqual(a, b);
    const metadata =
      before?.enumerable !== after?.enumerable ||
      before?.configurable !== after?.configurable ||
      before?.writable !== after?.writable ||
      before?.get !== after?.get ||
      before?.set !== after?.set;
    if (presence || value || metadata) changed = true;
  }
  if (!changed) return;
  let r = arrays.get(t);
  if (r?.structure) entangleOptimisticSlotRead(r.structure);
  if (r?.length) entangleOptimisticSlotRead(r.length);
  if (structural) {
    r ??= state(t);
    for (const map of [slots.slots, slots.presence, slots.shape])
      for (const slot of map.values()) entangleOptimisticSlotRead(slot);
    if (previous.length === next.length) {
      r.structure ??= createOptimisticSlot(signal(false), undefined, undefined, () => schedule());
      r.structure.propose(true);
    }
    active.add(t);
  }
  if (previous.length !== next.length) {
    r ??= state(t);
    if (!r.length) {
      const owned = t.ch || !!t._fam?.node;
      const input = owned
        ? createOptimisticStoreInput(() => {
            const body = optHooks?.inputBody?.(t);
            if (body) return body.length;
            pullFamilyInput(t, "length");
            return t.ch ? (read(getContainerNode(t)) as any[]).length : read(getNode(t, "length"));
          })
        : getNode(t, "length");
      if (owned) input._config &= ~CONFIG_AUTO_DISPOSE;
      r.length = createOptimisticSlot(
        input,
        undefined,
        () => discover(t),
        () => discover(t)
      );
      if (owned) ownedInputs.set(r.length, input as ReturnType<typeof computed>);
    }
    r.length.propose(next.length);
    active.add(t);
  }
}

export function sweepArrays(): void {
  for (const t of active) {
    const r = arrays.get(t)!;
    const abandoned = !!(t._fam?.node?._flags! & REACTIVE_DISPOSED);
    if (r.length && abandoned && r.length.tryRelease(true)) {
      const input = ownedInputs.get(r.length);
      if (input) dispose(input);
      r.length = undefined;
    }
    if (r.length?.isIdle()) {
      r.retiring.add(r.length);
      r.length = undefined;
    }
    for (const slot of r.retiring)
      if (slot.tryRelease(abandoned)) {
        r.retiring.delete(slot);
        const input = ownedInputs.get(slot);
        if (input) dispose(input);
      }
    if (r.structure?.tryRelease(abandoned)) r.structure = undefined;
    if (!r.retiring.size && !r.length && !r.structure) {
      active.delete(t);
      arrays.delete(t);
    }
  }
}
