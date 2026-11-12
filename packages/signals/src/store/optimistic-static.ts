/** Interim shared-engine slice: flat plain records with per-property cuts.
 * Truth slots stay store-owned; only their selected outputs accept guesses. */
import { read, untrack, writeHook } from "../core/core.js";
import type { Signal } from "../core/types.js";
import { getObserver } from "../core/owner.js";
import { schedule } from "../core/scheduler.js";
import { createOptimisticSlot, proposeOptimisticSlots } from "../layers/optimistic.js";
import {
  getNode,
  getHasNode,
  getContainerNode,
  devGuardStoreSetterWrite,
  devGuardStoreSetterResult
} from "./store.js";
import { createProjectionInternal } from "./projection.js";
import type { OptHooks } from "./hooks.js";
import type { StoreTarget } from "./target.js";
import { $TARGET, $TRACK, isWrappable } from "./types.js";
import { $OWNER } from "./target.js";

type Slot = ReturnType<typeof createOptimisticSlot>;
type RecordSlots = {
  slots: Map<PropertyKey, Slot>;
  presence: Map<PropertyKey, Slot>;
  nodes: Map<Signal<any>, Slot>;
  container?: Slot;
  prototype: object | null;
};
const records = new WeakMap<StoreTarget, RecordSlots>();
// Only companions without readers wait for a live guess or correction here.
const releases = new Map<Slot, () => void>();
const unsupported = () =>
  new Error(
    "Shared-engine optimistic stores currently support only flat plain records with mutable data properties; derived, nested, array, accessor and immutable descriptor changes are not integrated yet."
  );

function validate(value: any, expected?: RecordSlots): PropertyKey[] {
  if (!value || typeof value !== "object" || value[$TARGET] || Array.isArray(value))
    throw unsupported();
  const prototype = Object.getPrototypeOf(value);
  if (
    (prototype !== Object.prototype && prototype !== null) ||
    (expected && prototype !== expected.prototype)
  )
    throw unsupported();
  const keys = Reflect.ownKeys(value).filter(key => key !== $OWNER);
  for (const key of keys) {
    const d = Object.getOwnPropertyDescriptor(value, key)!;
    if (!("value" in d) || !d.writable || !d.configurable || isWrappable(d.value))
      throw unsupported();
  }
  return keys;
}

function slotFor(t: StoreTarget, key: PropertyKey, presence = false): Slot {
  const record = records.get(t)!;
  const slots = presence ? record.presence : record.slots;
  let slot = key === $TRACK ? record.container : slots.get(key);
  if (!slot) {
    const node =
      key === $TRACK ? getContainerNode(t) : presence ? getHasNode(t, key) : getNode(t, key);
    const candidate = () => {
      releases.set(slot!, () => {
        record.nodes.delete(node);
        if (key === $TRACK) record.container = undefined;
        else slots.delete(key);
      });
      schedule();
    };
    slot = createOptimisticSlot(node, candidate);
    if (key === $TRACK) record.container = slot;
    else slots.set(key, slot);
    record.nodes.set(node, slot);
    candidate();
  }
  return slot;
}

function selectedNode(t: StoreTarget, node: Signal<any>): Signal<any> {
  return records.get(t)?.nodes.get(node)?.output ?? node;
}

function readSelected(t: StoreTarget, node: Signal<any>) {
  const record = records.get(t);
  if (!record) return read(node);
  let slot = record.nodes.get(node);
  if (!slot && getObserver() !== null) {
    const key = (node as any)._key;
    slot = slotFor(t, key, t.h?.[key as any] === node);
  }
  return read(slot?.output ?? node);
}

function truthValue(t: StoreTarget, key: PropertyKey) {
  const node = t.n?.[key as any];
  return node ? read(node) : t.v[key as any];
}

function compose(t: StoreTarget, shape: Record<PropertyKey, any>, writer = false) {
  const record = records.get(t)!;
  const out = Object.create(record.prototype);
  for (const key of Reflect.ownKeys(shape)) {
    if (key === $OWNER) continue;
    const descriptor = Object.getOwnPropertyDescriptor(shape, key)!;
    const slot = record.slots.get(key);
    Object.defineProperty(out, key, {
      ...descriptor,
      value: slot ? (writer ? slot.writerValue() : read(slot.output)) : truthValue(t, key)
    });
  }
  return out;
}

function selectedView(t: StoreTarget, source: Record<PropertyKey, any>) {
  const record = records.get(t);
  if (!record) return source;
  // Enumeration depends on structure alone. Suppress leaf subscriptions while
  // retaining the active calculation's selection context.
  return untrack(() =>
    compose(
      t,
      record.container ? (read(record.container.output) as Record<PropertyKey, any>) : source
    )
  );
}

export const staticOptimisticHooks: OptHooks = {
  node: selectedNode,
  read: readSelected,
  // Reading outputs discovers coherent publication, without writing a shared
  // guessed deep witness and merging disjoint action lifetimes.
  deep: t => {
    const record = records.get(t);
    if (!record) return;
    const shape = record.container ? (read(record.container.output) as object) : t.v;
    for (const key of Reflect.ownKeys(shape)) {
      if (key === $OWNER) continue;
      const slot = getObserver() !== null ? slotFor(t, key) : record.slots.get(key);
      if (slot) read(slot.output);
    }
  },
  view: selectedView,
  descriptor: (t, key) =>
    untrack(() => {
      const record = records.get(t);
      if (!record) return undefined;
      const shape = record.container ? (read(record.container.output) as object) : t.v;
      const descriptor = Object.getOwnPropertyDescriptor(shape, key);
      const slot = record.slots.get(key);
      return descriptor
        ? { ...descriptor, value: slot ? read(slot.output) : truthValue(t, key) }
        : null;
    }),
  has: (t, key) => {
    const slot = records.get(t)?.presence.get(key);
    return slot ? !!read(slot.output) : undefined;
  },
  draft: () => {
    throw unsupported();
  },
  writes: () => {
    throw unsupported();
  },
  reconcile: () => {
    throw unsupported();
  },
  arrangement: () => false,
  pair: () => {},
  sweep: () => {
    for (const [slot, remove] of releases) {
      if (slot.output._subs !== null) releases.delete(slot);
      else if (slot.tryRelease()) {
        releases.delete(slot);
        remove();
      }
    }
  },
  ask: () => {},
  park: () => {},
  stands: () => false
};

export function createStaticOptimisticStore(first: any, second?: any, third?: any) {
  if (typeof first === "function" || third !== undefined || second?.shallow) throw unsupported();
  validate(first);
  const store = createProjectionInternal(null, first, second, true);
  const target: StoreTarget = (store as any)[$TARGET];
  const record: RecordSlots = {
    slots: new Map(),
    presence: new Map(),
    nodes: new Map(),
    prototype: Object.getPrototypeOf(first)
  };
  records.set(target, record);
  const set = (fn: (draft: any) => any) => {
    if (writeHook !== null) writeHook(store as object);
    if (__DEV__) devGuardStoreSetterWrite();
    // Validate an isolated writer view before submitting any proposal.
    const previous = untrack(() =>
      compose(
        target,
        (record.container?.writerValue() as Record<PropertyKey, any>) ?? target.v,
        true
      )
    );
    const draft = Object.create(record.prototype, Object.getOwnPropertyDescriptors(previous));
    const result = fn(draft);
    if (__DEV__) devGuardStoreSetterResult(result);
    const next = result === undefined ? draft : result;
    const nextKeys = validate(next, record);
    const oldKeys = Reflect.ownKeys(previous);
    const allKeys = new Set([...oldKeys, ...nextKeys]);
    const entries: [Slot, unknown][] = [];
    let structure =
      oldKeys.length !== nextKeys.length || oldKeys.some((key, i) => key !== nextKeys[i]);
    for (const key of allKeys) {
      const old = Object.getOwnPropertyDescriptor(previous, key);
      const neu = Object.getOwnPropertyDescriptor(next, key);
      const inherited =
        key === "__proto__" || key === "prototype" ? undefined : record.prototype?.[key];
      const before = old ? old.value : inherited;
      const after = neu ? neu.value : inherited;
      if (!Object.is(before, after)) entries.push([slotFor(target, key), after]);
      // Missing and present-undefined are distinct structural states.
      if (!!old !== !!neu) {
        const presence = slotFor(target, key, true);
        const present = neu !== undefined || key in Object.create(record.prototype);
        if (presence.writerValue() !== present) entries.push([presence, present]);
      }
      if (old?.enumerable !== neu?.enumerable) structure = true;
    }
    if (structure) {
      // Clone the validated structure: later mutations of a returned object
      // must not mutate an already submitted proposal.
      entries.push([
        slotFor(target, $TRACK),
        Object.create(record.prototype, Object.getOwnPropertyDescriptors(next))
      ]);
    }
    proposeOptimisticSlots(entries);
  };
  return [store, set] as const;
}
