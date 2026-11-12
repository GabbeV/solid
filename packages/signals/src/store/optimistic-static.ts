/** Interim shared-engine slice: flat static records, with per-property cuts.
 * Truth slots stay store-owned; only their selected outputs accept guesses. */
import { read, untrack, writeHook } from "../core/core.js";
import { createOptimisticSlot, proposeOptimisticSlots } from "../layers/optimistic.js";
import { getNode, devGuardStoreSetterWrite, devGuardStoreSetterResult } from "./store.js";
import { createProjectionInternal } from "./projection.js";
import type { OptHooks } from "./hooks.js";
import type { StoreTarget } from "./target.js";
import { $TARGET, isWrappable } from "./types.js";

type Slot = ReturnType<typeof createOptimisticSlot>;
type RecordSlots = { keys: PropertyKey[]; slots: Map<PropertyKey, Slot>; prototype: object | null };
const records = new WeakMap<StoreTarget, RecordSlots>();
const unsupported = () =>
  new Error(
    "Shared-engine optimistic stores currently support only static flat plain records with existing data properties; derived, nested, structural and descriptor changes are not integrated yet."
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
  const keys = Reflect.ownKeys(value);
  if (
    expected &&
    (keys.length !== expected.keys.length || keys.some(key => !expected.slots.has(key)))
  )
    throw unsupported();
  for (const key of keys) {
    const d = Object.getOwnPropertyDescriptor(value, key)!;
    if (!("value" in d) || !d.enumerable || !d.writable || !d.configurable || isWrappable(d.value))
      throw unsupported();
  }
  return keys;
}

function selectedView(t: StoreTarget, source: Record<PropertyKey, any>) {
  const record = records.get(t);
  if (!record) return source;
  // Structural readers subscribe to the container alone. They must not acquire
  // every property dependency just because enumeration needs a backing.
  return untrack(() => {
    let out: Record<PropertyKey, any> | undefined;
    for (const key of record.keys) {
      const value = read(record.slots.get(key)!.output);
      if (!Object.is(value, source[key])) {
        out ??= Object.create(record.prototype, Object.getOwnPropertyDescriptors(source));
        Object.defineProperty(out!, key, {
          value,
          enumerable: true,
          configurable: true,
          writable: true
        });
      }
    }
    return out ?? source;
  });
}

export const staticOptimisticHooks: OptHooks = {
  read: (t, node) => {
    const slot = records.get(t)?.slots.get((node as any)._key);
    return read(slot ? slot.output : node);
  },
  deep: t => {
    for (const slot of records.get(t)?.slots.values() ?? []) read(slot.output);
  },
  view: selectedView,
  descriptor: (t, key) => {
    const slot = records.get(t)?.slots.get(key);
    return slot
      ? {
          value: untrack(() => read(slot.output)),
          enumerable: true,
          configurable: true,
          writable: true
        }
      : undefined;
  },
  has: () => undefined,
  // This slice proposes from an isolated validated draft, so none of the
  // legacy optimistic drafting or projection hooks is a valid write path.
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
  sweep: () => {},
  ask: () => {},
  park: () => {},
  stands: () => false
};

export function createStaticOptimisticStore(first: any, second?: any, third?: any) {
  if (typeof first === "function" || third !== undefined || second?.shallow) throw unsupported();
  const keys = validate(first);
  const store = createProjectionInternal(null, first, second, true);
  const target: StoreTarget = (store as any)[$TARGET];
  const record: RecordSlots = {
    keys,
    slots: new Map(),
    prototype: Object.getPrototypeOf(first)
  };
  records.set(target, record);
  for (const key of keys) record.slots.set(key, createOptimisticSlot(getNode(target, key)));
  const set = (fn: (draft: any) => any) => {
    if (writeHook !== null) writeHook(store as object);
    if (__DEV__) devGuardStoreSetterWrite();
    // Rejected structural drafts have never touched a slot or truth backing.
    const draft = Object.create(record.prototype);
    const previous = new Map<PropertyKey, unknown>();
    for (const key of keys) {
      const value = record.slots.get(key)!.writerValue();
      previous.set(key, value);
      Object.defineProperty(draft, key, {
        value,
        enumerable: true,
        configurable: true,
        writable: true
      });
    }
    const result = fn(draft);
    if (__DEV__) devGuardStoreSetterResult(result);
    const next = result === undefined ? draft : result;
    validate(next, record);
    const entries: [Slot, unknown][] = [];
    for (const key of keys)
      if (!Object.is(previous.get(key), next[key]))
        entries.push([record.slots.get(key)!, next[key]]);
    proposeOptimisticSlots(entries);
  };
  return [store, set] as const;
}
