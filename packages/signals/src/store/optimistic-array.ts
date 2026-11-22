/** Array structure owns a publication boundary without guessing array contents. */
import { read, setSignal, signal, untrack } from "../core/core.js";
import {
  CONFIG_INPUTS_PUBLISHED,
  CONFIG_AUTO_DISPOSE,
  REACTIVE_DISPOSED,
  STATUS_UNINITIALIZED
} from "../core/constants.js";
import { flushTransaction, holdNode, insertSubs, joinFuture, schedule } from "../core/scheduler.js";
import {
  createOptimisticSlot,
  createOptimisticStoreInput,
  entangleOptimisticSlotRead
} from "../layers/optimistic.js";
import {
  committed,
  getContainerNode,
  pullFamilyInput,
  targetsEqual,
  sameKey,
  unwrapValue
} from "./store.js";
import { optHooks } from "./hooks.js";
import { dispose } from "../core/owner.js";
import { enqueueSub, markNode } from "../core/heap.js";
import { NotReadyError } from "../core/error.js";
import type { Computed, Signal } from "../core/types.js";
import { $OWNER, type StoreTarget } from "./target.js";
import { isWrappable, $TARGET } from "./types.js";

type Slot = ReturnType<typeof createOptimisticSlot<any>>;
type ArraySlots = {
  slots: Map<PropertyKey, Slot>;
  presence: Map<PropertyKey, Slot>;
  shape: Map<PropertyKey, Slot>;
};
type ArrayState = { structure?: Slot };
/** Only answers that joined a structural edit after their question published. */
const pendingAnswers = new Map<StoreTarget, Signal<boolean>>();
const arrays = new WeakMap<StoreTarget, ArrayState>();
const active = new Set<StoreTarget>();
const ownedInputs = new WeakMap<Slot, Computed<any>>();

function state(t: StoreTarget): ArrayState {
  let r = arrays.get(t);
  if (!r) arrays.set(t, (r = {}));
  return r;
}
function discoverStructure(slots: ArraySlots): void {
  for (const map of [slots.slots, slots.presence, slots.shape])
    for (const slot of map.values()) {
      markNode(slot.output);
      enqueueSub(slot.output);
    }
  schedule();
}
/** A structural frame contains descriptors, never data values. */
function metadata(source: Record<PropertyKey, any>): any[] {
  const shape: any[] = [];
  for (const key of Reflect.ownKeys(source)) {
    if (key === $OWNER) continue;
    const descriptor = Object.getOwnPropertyDescriptor(source, key)!;
    Object.defineProperty(
      shape,
      key,
      key === "length" || !("value" in descriptor)
        ? descriptor
        : { ...descriptor, value: undefined }
    );
  }
  return shape;
}

function sameMetadata(a: any[], b: any[]): boolean {
  if (a === b) return true;
  if (!a || !b || a.length !== b.length) return false;
  const keys = Reflect.ownKeys(a),
    other = Reflect.ownKeys(b);
  if (keys.length !== other.length) return false;
  return keys.every((key, index) => {
    if (key !== other[index]) return false;
    const left = Object.getOwnPropertyDescriptor(a, key)!;
    const right = Object.getOwnPropertyDescriptor(b, key)!;
    return (
      left.enumerable === right.enumerable &&
      left.configurable === right.configurable &&
      left.writable === right.writable &&
      left.get === right.get &&
      left.set === right.set &&
      "value" in left === "value" in right
    );
  });
}

function publishedShape(t: StoreTarget): any[] | undefined {
  if (t._fam?.node?._statusFlags! & STATUS_UNINITIALIZED) return;
  const slot = arrays.get(t)?.structure;
  if (slot && !(slot.output._statusFlags & STATUS_UNINITIALIZED)) return slot.output._value;
  const source = committed(t);
  const inner = source[$TARGET] as StoreTarget | undefined;
  return inner && inner !== t ? publishedShape(inner) : metadata(source);
}

function structureSlot(t: StoreTarget): Slot {
  const r = state(t);
  if (r.structure) return r.structure;
  const sourceShape = (source: Record<PropertyKey, any>) => {
    const inner = source[$TARGET] as StoreTarget | undefined;
    if (inner && inner !== t) {
      if (inner._fam?.opt) return selectedArrayShape(inner);
      if (inner._fam) pullFamilyInput(inner);
      return sourceShape(read(getContainerNode(inner)) as Record<PropertyKey, any>);
    }
    return metadata(source);
  };
  const published = publishedShape(t);
  const input = createOptimisticStoreInput(
    () => {
      const body = optHooks?.inputBody?.(t);
      if (body) return sourceShape(body);
      pullFamilyInput(t);
      const source = read(getContainerNode(t)) as Record<PropertyKey, any>;
      return sourceShape(source);
    },
    { equals: sameMetadata, ...(published ? { loadingValue: published } : {}) }
  );
  input._config &= ~CONFIG_AUTO_DISPOSE;
  // Container readers must rediscover the selected structure when its
  // override starts or retires, including an inverse returning to equal shape.
  const discover = () => {
    if (t.k) insertSubs(t.k);
    if (t.n?.length) insertSubs(t.n.length);
    schedule();
  };
  const slot = (r.structure = createOptimisticSlot(
    input,
    undefined,
    discover,
    discover,
    published ? { value: published } : undefined
  ));
  slot.output._equals = sameMetadata;
  ownedInputs.set(slot, input);
  active.add(t);
  return slot;
}

/** A higher pass may use its chosen row immediately. For an unguessed row
 * the old answer belongs to the previous question: suspend until this pass
 * can consume the new answer. The landing itself can build its rows eagerly. */
export function readArrayAnswer(t: StoreTarget): void {
  if (!pendingAnswers.size) return;
  for (let p: StoreTarget | null = t; p; p = p.u) {
    const gate = pendingAnswers.get(p);
    if (gate && !gate._value) {
      readArrayStructure(p);
      if (!read(gate)) throw new NotReadyError(gate);
    }
  }
}
export function selectedArrayShape(t: StoreTarget, consume = true): any[] {
  return structureSlot(t).read(consume);
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
  if (writer) {
    const slot = arrays.get(t)?.structure;
    if (!slot?.activeOwner()) return typeof base === "function" ? base() : base;
    return slot.writerValue().length;
  }
  return selectedArrayShape(t).length;
}
export function arrayGrowthStands(t: StoreTarget): boolean {
  return !!arrays.get(t)?.structure?.activeOwner();
}

export function readArrayLength(t: StoreTarget): void {
  const slot = arrays.get(t)?.structure;
  if (slot) entangleOptimisticSlotRead(slot);
}

/** All ordinary array outputs derive in the selected structural context. */
export function readArrayStructure(t: StoreTarget): void {
  const slot = arrays.get(t)?.structure;
  if (!slot?.activeOwner()) return;
  untrack(() => read(slot.output));
  read(slot.output);
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
    if (r.structure) join(r.structure);
  }
  if (!selected || !flushTransaction) return;
  r ??= state(t);
  // Loading may have let the filter publish while its list was still in
  // flight. Receiving the list settles that flight, but the structural
  // edit we joined can still hold its answer. Stage readiness with the
  // answer so readers in each update see both become available together.
  const producer = t._fam?.node;
  if (producer && producer._config & CONFIG_INPUTS_PUBLISHED && !pendingAnswers.has(t)) {
    const ready = signal(false);
    pendingAnswers.set(t, ready);
    holdNode(ready, flushTransaction);
    setSignal(ready, true);
  }
  const slot = structureSlot(t);
  slot.propose(slot.activeOwner() ? slot.writerValue() : slot.output._value);
  discoverStructure(slots);
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
  if (structural) {
    r ??= state(t);
    for (const map of [slots.slots, slots.presence, slots.shape])
      for (const slot of map.values()) entangleOptimisticSlotRead(slot);
    const slot = structureSlot(t);
    const nextShape = metadata(next);
    if (!slot.activeOwner() || !sameMetadata(slot.writerValue(), nextShape))
      slot.propose(nextShape);
    active.add(t);
  } else {
    // Establish the already published structural frame before a later input
    // change can coordinate this value-only override.
    structureSlot(t);
  }
}

export function sweepArrays(): void {
  for (const [t, ready] of pendingAnswers) {
    if (ready._value || t._fam?.node?._flags! & REACTIVE_DISPOSED) pendingAnswers.delete(t);
  }
  for (const t of active) {
    const r = arrays.get(t)!;
    const abandoned = !!(t._fam?.node?._flags! & REACTIVE_DISPOSED);
    if (r.structure?.tryRelease(abandoned)) {
      const input = ownedInputs.get(r.structure);
      if (input) dispose(input);
      active.delete(t);
      arrays.delete(t);
    }
  }
}
