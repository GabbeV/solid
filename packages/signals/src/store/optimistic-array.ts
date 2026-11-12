/** Array shape policy for shared optimistic outputs. Index writes carry a
 * minimum length, not a snapshot of other actions' array contents. */
import { computed, read, runWithOwner, signal } from "../core/core.js";
import { flushTransaction, insertSubs, resolveTx, schedule } from "../core/scheduler.js";
import { createOptimisticSlot, entangleOptimisticSlotRead } from "../layers/optimistic.js";
import { committed, getNode, getContainerNode } from "./store.js";
import { dispose } from "../core/owner.js";
import type { StoreTarget } from "./target.js";

type Slot = ReturnType<typeof createOptimisticSlot<any>>;
type ArrayState = { floors: Set<Slot>; retiring: Set<Slot>; resize?: Slot };
const arrays = new WeakMap<StoreTarget, ArrayState>();
const active = new Set<StoreTarget>();
const ownedInputs = new WeakMap<Slot, ReturnType<typeof computed>>();

function state(t: StoreTarget): ArrayState {
  let r = arrays.get(t);
  if (!r) arrays.set(t, (r = { floors: new Set(), retiring: new Set() }));
  return r;
}
function discover(t: StoreTarget) {
  if (t.k) insertSubs(t.k);
  if (t.n?.length) insertSubs(t.n.length);
  schedule();
}
export function arrayIndex(key: PropertyKey): number {
  if (typeof key !== "string" || key === "") return -1;
  const n = Number(key);
  return Number.isInteger(n) && n >= 0 && n < 4294967295 && String(n) === key ? n : -1;
}

export function selectedArrayLength(t: StoreTarget, base: number, writer = false): number {
  const r = arrays.get(t);
  if (!r) return base;
  let n = r.resize ? ((writer ? r.resize.writerValue() : read(r.resize.output)) as number) : base;
  for (const floor of r.floors) {
    const required = (writer ? floor.writerValue() : read(floor.output)) as number;
    if (required > n) n = required;
  }
  return n;
}

export function readArrayLength(t: StoreTarget): void {
  const r = arrays.get(t);
  if (!r) return;
  let n = r.resize ? (r.resize.writerValue() as number) : (committed(t) as any[]).length;
  let provider = r.resize;
  for (const floor of r.floors) {
    const required = floor.writerValue() as number;
    if (required > n) {
      n = required;
      provider = floor;
    }
  }
  if (provider) entangleOptimisticSlotRead(provider);
}

/** Called after successful JS mutation, with length before and after it. */
export function writeArray(
  t: StoreTarget,
  key: PropertyKey,
  before: number,
  after: number,
  kind: "set" | "delete",
  slots: {
    slots: Map<PropertyKey, Slot>;
    presence: Map<PropertyKey, Slot>;
    shape: Map<PropertyKey, Slot>;
  }
): void {
  const index = arrayIndex(key);
  let r = arrays.get(t);
  if (r?.resize) entangleOptimisticSlotRead(r.resize);
  if (key === "length" && after !== before) {
    r ??= state(t);
    // A genuine resize conflicts with all live edits on this array.
    for (const map of [slots.slots, slots.presence, slots.shape])
      for (const slot of map.values()) entangleOptimisticSlotRead(slot);
    for (const floor of r.floors) entangleOptimisticSlotRead(floor);
    if (!r.resize) {
      const input = t.ch
        ? runWithOwner(null, () => computed(() => (read(getContainerNode(t)) as any[]).length))
        : getNode(t, "length");
      r.resize = createOptimisticSlot(input, undefined, () => discover(t));
      if (t.ch) ownedInputs.set(r.resize, input as ReturnType<typeof computed>);
    }
    r.resize.propose(after);
    // The explicit resize supersedes earlier implicit growth requirements.
    for (const floor of r.floors) floor.propose(0);
    active.add(t);
  } else if (index >= 0 && kind === "set") {
    r ??= state(t);
    const owner = flushTransaction && resolveTx(flushTransaction);
    let floor: Slot | undefined;
    for (const candidate of r.floors) {
      if (candidate.activeOwner() === owner) {
        floor = candidate;
        break;
      }
    }
    if (!floor) {
      floor = createOptimisticSlot(signal(0), undefined, () => discover(t));
      r.floors.add(floor);
    }
    const required = Math.max(floor.writerValue() as number, index + 1);
    floor.propose(required);
    active.add(t);
  }
}

export function sweepArrays(): void {
  for (const t of active) {
    const r = arrays.get(t)!;
    for (const floor of r.floors) {
      const out = floor.output;
      if (floor.isIdle() && out._value === 0) {
        r.floors.delete(floor);
        r.retiring.add(floor);
      }
    }
    if (r.resize?.isIdle()) {
      r.retiring.add(r.resize);
      r.resize = undefined;
    }
    for (const slot of r.retiring)
      if (slot.tryRelease()) {
        r.retiring.delete(slot);
        const input = ownedInputs.get(slot);
        if (input) dispose(input);
      }
    if (!r.floors.size && !r.retiring.size && !r.resize) {
      active.delete(t);
      arrays.delete(t);
    }
  }
}
