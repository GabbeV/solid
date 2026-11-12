/** Interim shared-engine slice: flat plain records with per-property cuts.
 * Truth slots stay store-owned; only their selected outputs accept guesses. */
import { read, runWithOwner, untrack, verdict, setVerdict } from "../core/core.js";
import {
  CONFIG_AUTO_DISPOSE,
  CONFIG_HELD,
  REACTIVE_DISPOSED,
  NOT_PENDING,
  STATUS_UNINITIALIZED
} from "../core/constants.js";
import type { Computed, Signal } from "../core/types.js";
import { enqueueSub, markNode } from "../core/heap.js";
import { dispose, getObserver } from "../core/owner.js";
import { insertSubs, schedule } from "../core/scheduler.js";
import {
  createOptimisticSlot,
  createOptimisticStoreInput,
  proposeOptimisticSlots,
  entangleOptimisticSlotRead,
  withOptimisticSlotBatch
} from "../layers/optimistic.js";
import {
  getNode,
  releaseUnobservedStoreNode,
  getHasNode,
  getContainerNode,
  wrap,
  pullFamilyInput,
  storeSetter,
  committed,
  cloneRaw,
  unwrapValue,
  resolveChainedRaw,
  targetsEqual,
  sameKey
} from "./store.js";
import { createProjectionInternal } from "./projection.js";
import {
  arrayIndex,
  arrayGrowthStands,
  readArrayLength,
  selectedArrayLength,
  sweepArrays,
  writeArray
} from "./optimistic-array.js";
import type { OptHooks } from "./hooks.js";
import type { StoreTarget } from "./target.js";
import { $TARGET, $TRACK, isWrappable } from "./types.js";
import { $OWNER, lookupTarget } from "./target.js";
import { reconcileState } from "./reconcile.js";

type Slot = ReturnType<typeof createOptimisticSlot<any>>;
type RecordSlots = {
  slots: Map<PropertyKey, Slot>;
  presence: Map<PropertyKey, Slot>;
  shape: Map<PropertyKey, Slot>;
  nodes: Map<Signal<any>, Slot>;
  inputs: Set<Computed<any>>;
  structure?: Slot;
  prototype: object | null;
  parent?: Slot;
  draft?: { previous: Record<PropertyKey, any>; staged: Record<PropertyKey, any> | null };
};
const records = new WeakMap<StoreTarget, RecordSlots>();
const selectedTargets = new Set<StoreTarget>();
const shapedTargets = new Set<StoreTarget>();
// Only companions without readers wait for a live guess or correction here.
const releases = new Map<Slot, { remove: () => void; target: StoreTarget }>();
const firewallSlots = new WeakSet<Slot>();
function recordFor(t: StoreTarget): RecordSlots {
  let record = records.get(t);
  if (!record) {
    record = {
      slots: new Map(),
      presence: new Map(),
      shape: new Map(),
      nodes: new Map(),
      inputs: new Set(),
      prototype: Object.getPrototypeOf(t.v)
    };
    records.set(t, record);
  }
  return record;
}

/** A selected parent property supplies the body's publication boundary. */
function selectedBody(
  t: StoreTarget,
  writer = false,
  published = false
): Record<PropertyKey, any> | undefined {
  let slot = records.get(t)?.parent;
  if (!slot && t.u && t.pk !== null) {
    const candidate =
      records.get(t.u)?.slots.get(t.pk) ?? records.get(t.u)?.slots.get(String(t.pk));
    if (candidate?.activeOwner()) {
      const value = candidate.writerValue();
      if (isWrappable(value) && lookupTarget(value, t._fam!) === t) {
        recordFor(t).parent = slot = candidate;
        selectedTargets.add(t);
      }
    }
  }
  if (slot) {
    // Selecting the body's identity is an ordinary dependency. A query of
    // a captured child's leaf must not also query the parent's pending mark.
    const previous = verdict;
    setVerdict(null);
    let value;
    try {
      value = writer
        ? slot.writerValue()
        : published && slot.output._statusFlags & STATUS_UNINITIALIZED
          ? undefined
          : read(slot.output);
    } finally {
      setVerdict(previous);
    }
    if (isWrappable(value) && lookupTarget(value, t._fam!) === t) return value;
  }
  if (t.u && t.pk !== null) {
    const parent = selectedBody(t.u, writer, published);
    const value = parent?.[t.pk];
    if (isWrappable(value) && lookupTarget(value, t._fam!) === t) return value;
  }
  return undefined;
}

function slotFor(t: StoreTarget, key: PropertyKey, presence = false): Slot {
  const record = recordFor(t);
  const slots = presence ? record.presence : record.slots;
  let slot = slots.get(key);
  if (!slot) {
    const node = presence ? getHasNode(t, key) : getNode(t, key);
    const body = runWithOwner(null, () => untrack(() => selectedBody(t, false, true)));
    const descriptor = body && Object.getOwnPropertyDescriptor(body, key);
    const bodyValue =
      body &&
      (presence
        ? { value: key in body }
        : descriptor && "value" in descriptor
          ? { value: descriptor.value }
          : !(key in body)
            ? { value: undefined }
            : undefined);
    // A chained target's node is only a subscription point. Its `_value` is
    // assigned during a read, so it cannot notify a selected output when the
    // inner store changes. Give the companion a tracked input that follows
    // both a replacement of the outer backing and the inner selected key.
    const input =
      t.ch || t.u || t._fam?.node
        ? createOptimisticStoreInput(
            () => {
              const body = selectedBody(t);
              if (body) {
                return presence ? key in body : body[key as any];
              }
              const current = !presence && t.v[key as any];
              const child = isWrappable(current)
                ? ((wrap(current, t, key) as any)[$TARGET] as StoreTarget)
                : undefined;
              if (child && readDescendantOutputs(child)) return read(node);
              pullFamilyInput(t, key);
              if (t.ch) {
                const source = read(getContainerNode(t)) as Record<PropertyKey, any>;
                return presence ? key in source : source[key as any];
              }
              return read(node);
            },
            bodyValue || !(t._fam?.node?._statusFlags! & STATUS_UNINITIALIZED)
              ? { loadingValue: bodyValue ? bodyValue.value : node._value }
              : undefined
          )
        : node;
    if (input !== node) {
      input._config &= ~CONFIG_AUTO_DISPOSE;
      if (__OBSERVE__) {
        (input as any)._name = (node as any)._name;
        (input as any)._loc = (node as any)._loc;
      }
    }
    const candidate = () => {
      if (!slot) return;
      releases.set(slot!, {
        target: t,
        remove: () => {
          if (record.nodes.get(node) === slot) record.nodes.delete(node);
          if (slots.get(key) === slot) slots.delete(key);
          if (input !== node) {
            record.inputs.delete(input as Computed<any>);
            dispose(input as any);
          }
          releaseUnobservedStoreNode(node);
        }
      });
      schedule();
    };
    const invalidateAncestors = () => {
      if (t.u) {
        for (let p: StoreTarget | null = t; p; p = p.u) {
          for (const input of records.get(p)?.inputs ?? []) {
            markNode(input);
            enqueueSub(input);
          }
        }
        schedule();
      }
    };
    slot = createOptimisticSlot(
      input,
      candidate,
      () => {
        // First readers may have suspended before discovering this property.
        const fw = t._fam?.node;
        if (fw && fw._subs !== null) insertSubs(fw);
        invalidateAncestors();
        if (!presence) {
          const value = slot!.writerValue();
          const child = isWrappable(value) && lookupTarget(value, t._fam!);
          if (child) {
            const childRecord = recordFor(child);
            childRecord.parent = slot;
            selectedTargets.add(child);
            for (const input of childRecord.inputs) enqueueSub(input);
          }
        }
        if (!presence && Array.isArray(t.v) && arrayIndex(key) >= 0) {
          // A mapped list initially subscribes to $TRACK before this slot
          // exists. Discover it once the first selected value is staged.
          const container = t.k;
          if (container && container._subs !== null) insertSubs(container);
        }
      },
      invalidateAncestors,
      bodyValue ??
        (node._pendingValue !== NOT_PENDING && !(t._fam?.node?._statusFlags! & STATUS_UNINITIALIZED)
          ? { value: node._value }
          : undefined)
    );
    if (input !== node && t._fam?.node) firewallSlots.add(slot);
    slots.set(key, slot);
    record.nodes.set(node, slot);
    if (input !== node) record.inputs.add(input as Computed<any>);
    candidate();
  }
  return slot;
}

// Shape is separate from value and presence: an enumerable-only change has
// neither a new value nor a different `key in store` answer. The source reads
// the ordinary container, while each key's selected output owns only its own
// optimistic metadata. No guessed backing is written to the container.
function shapeBits(descriptor: PropertyDescriptor | undefined): number {
  return descriptor === undefined
    ? 0
    : 1 |
        (descriptor.enumerable ? 2 : 0) |
        (descriptor.configurable ? 4 : 0) |
        ("value" in descriptor && descriptor.writable ? 8 : 0) |
        (!("value" in descriptor) ? 16 : 0);
}

const shapeMask = 31;
type ShapeMeta = { bits: number; get?: () => unknown; set?: (value: unknown) => void };
function shapeMeta(source: object, key: PropertyKey): ShapeMeta {
  const descriptor = Object.getOwnPropertyDescriptor(source, key);
  const bits = shapeBits(descriptor);
  return {
    bits: bits ? bits | ((Reflect.ownKeys(source).indexOf(key as string | symbol) + 1) << 5) : 0,
    get: descriptor?.get,
    set: descriptor?.set
  };
}
function sameShapeMeta(a: ShapeMeta, b: ShapeMeta): boolean {
  return a.bits === b.bits && a.get === b.get && a.set === b.set;
}
function sameShape(a: PropertyDescriptor | undefined, b: PropertyDescriptor | undefined): boolean {
  return shapeBits(a) === shapeBits(b) && a?.get === b?.get && a?.set === b?.set;
}

function shapeSlot(t: StoreTarget, key: PropertyKey): Slot {
  const record = recordFor(t);
  let slot = record.shape.get(key);
  if (slot) return slot;
  // Metadata discovered during a flight still has the displayed body's answer.
  // Without it an accessor probe can suspend before reaching a held value slot.
  const body = runWithOwner(null, () => untrack(() => selectedBody(t, false, true)));
  const published =
    body || !(t._fam?.node?._statusFlags! & STATUS_UNINITIALIZED)
      ? { value: shapeMeta(body ?? committed(t), key) }
      : undefined;
  const input = createOptimisticStoreInput(() => {
    const body = selectedBody(t);
    if (body) return shapeMeta(body, key);
    pullFamilyInput(t, key);
    const source = read(getContainerNode(t)) as Record<PropertyKey, any>;
    return shapeMeta(source, key);
  });
  input._config &= ~CONFIG_AUTO_DISPOSE;
  const candidate = () => {
    if (!slot) return;
    releases.set(slot!, {
      target: t,
      remove: () => {
        if (record.shape.get(key) === slot) record.shape.delete(key);
        dispose(input as any);
      }
    });
    schedule();
  };
  slot = createOptimisticSlot(
    input,
    candidate,
    () => {
      // Equal metadata already on screen needs no structural discovery.
      // Its selected output still owns the override and observes future edits.
      const shown = slot!.output._value as ShapeMeta | undefined;
      if (shown && sameShapeMeta(shown, slot!.writerValue() as ShapeMeta)) return;
      // A discarded ambient proposal must not wake existing readers at all.
      // Discover this candidate only once it has a surviving selected update.
      const container = getContainerNode(t);
      if (container._subs !== null) insertSubs(container);
      if (record.structure?.output._subs) insertSubs(record.structure.output);
      const value = t.n?.[key as any];
      if (value !== undefined && value._subs !== null) insertSubs(value);
      schedule();
    },
    undefined,
    published
  );
  slot.output._equals = sameShapeMeta;
  record.shape.set(key, slot);
  shapedTargets.add(t);
  candidate();
  return slot;
}

function selectedShapes(t: StoreTarget): void {
  const record = records.get(t);
  if (record) for (const slot of record.shape.values()) read(slot.output);
}

function selectedNode(t: StoreTarget, node: Signal<any>): Signal<any> {
  return records.get(t)?.nodes.get(node)?.output ?? node;
}

function descendantStands(t: StoreTarget, key: PropertyKey): boolean {
  for (const child of t._fam?.live ?? []) {
    let p: StoreTarget | null = child;
    while (p?.u && p.u !== t) p = p.u;
    if (p?.u !== t || p.pk !== key) continue;
    if (arrayGrowthStands(child)) return true;
    const record = records.get(child);
    if (!record) continue;
    for (const map of [record.slots, record.presence, record.shape])
      for (const slot of map.values()) if (slot.activeOwner()) return true;
  }
  return false;
}

function readDescendantOutputs(root: StoreTarget): boolean {
  let selected = false;
  for (const target of root._fam?.live ?? []) {
    let p: StoreTarget | null = target;
    while (p && p !== root) p = p.u;
    if (p !== root) continue;
    const record = records.get(target);
    if (!record) continue;
    for (const map of [record.slots, record.presence, record.shape])
      for (const slot of map.values()) if (slot.activeOwner()) selected = true;
    if (arrayGrowthStands(target)) selected = true;
  }
  return selected;
}

/** Enumeration composes selected metadata over a producer-aware base. A
 * higher selected frame can keep that base; a first base stays unanswered. */
function structureSlot(t: StoreTarget): Slot {
  const record = recordFor(t);
  if (record.structure) return record.structure;
  const node = getContainerNode(t);
  const input = createOptimisticStoreInput(() => {
    const body = selectedBody(t);
    if (body) return body;
    pullFamilyInput(t);
    return read(node);
  });
  input._config &= ~CONFIG_AUTO_DISPOSE;
  let slot: Slot;
  const candidate = () => {
    if (!slot) return;
    releases.set(slot, {
      target: t,
      remove: () => {
        if (record.structure === slot) record.structure = undefined;
        if (record.nodes.get(node) === slot) record.nodes.delete(node);
        record.inputs.delete(input);
        dispose(input);
        releaseUnobservedStoreNode(node);
      }
    });
    schedule();
  };
  slot = createOptimisticSlot(input, candidate);
  record.structure = slot;
  record.nodes.set(node, slot);
  record.inputs.add(input);
  candidate();
  return slot;
}

function readSelected(t: StoreTarget, node: Signal<any>) {
  if (Array.isArray(t.v) && node === t.n?.length)
    return selectedArrayLength(t, () => {
      const body = selectedBody(t);
      if (body) return body.length;
      pullFamilyInput(t, "length");
      return t.ch ? (read(getContainerNode(t)) as any[]).length : (read(node) as number);
    });
  if (node === t.k) {
    selectedShapes(t);
    // Discover selected inner outputs before the wrapper's lower structure
    // can suspend this reader. A chained backing already owns this subscription.
    if (t.ch) {
      const source = selectedBody(t) ?? committed(t);
      if ((source as any)[$TARGET] !== undefined) (source as any)[$TRACK];
    }
    const value = t._fam?.node ? read(structureSlot(t).output) : read(node);
    // mapArray's item reads run inside an untracked row owner. Its tracked
    // $TRACK read links the selected index outputs that can change a row
    // without changing the array's ordinary backing or key set.
    if (Array.isArray(t.v)) {
      const record = records.get(t);
      if (record)
        for (const [key, slot] of record.slots) if (arrayIndex(key) >= 0) read(slot.output);
    }
    return value;
  }
  const record = recordFor(t);
  let slot = record.nodes.get(node);
  if (!slot && getObserver() !== null) {
    const key = (node as any)._key;
    slot = slotFor(t, key, t.h?.[key as any] === node);
  }
  if (slot) return read(slot.output);
  const row = selectedBody(t);
  if (row && row !== t.v) {
    const key = (node as any)._key;
    return t.h?.[key as any] === node ? key in row : row[key as any];
  }
  if (t.ch) {
    const source = read(getContainerNode(t)) as Record<PropertyKey, any>;
    const key = (node as any)._key;
    return t.h?.[key as any] === node ? key in source : source[key as any];
  }
  return read(node);
}

function truthValue(t: StoreTarget, key: PropertyKey) {
  const node = t.n?.[key as any];
  return node ? read(node) : t.v[key as any];
}

function compose(t: StoreTarget, shape: Record<PropertyKey, any>, writer = false) {
  const row = selectedBody(t, writer);
  if (row && row !== t.v) shape = row;
  if (writer && t.ch) {
    const inner = (shape as any)[$TARGET] as StoreTarget | undefined;
    // A chained setter composes on unflushed guesses from its inner store.
    // Only the key the callback actually reads entangles ownership below.
    if (inner && records.has(inner)) shape = compose(inner, committed(inner), true);
  }
  const record = recordFor(t);
  const out = Array.isArray(shape) ? [] : Object.create(record.prototype);
  const sourceKeys = Reflect.ownKeys(shape);
  const order = new Map<PropertyKey, number>();
  sourceKeys.forEach((key, index) => order.set(key, index));
  for (const key of Reflect.ownKeys(shape)) {
    if (key === $OWNER) continue;
    const descriptor = Object.getOwnPropertyDescriptor(shape, key)!;
    if (Array.isArray(out) && key === "length") {
      out.length = descriptor.value;
      continue;
    }
    const slot = record.slots.get(key);
    const value = slot
      ? writer
        ? t.ch && slot.activeOwner() === null && Object.is(slot.writerValue(), slot.output._value)
          ? descriptor.value
          : slot.writerValue()
        : untrack(() => read(slot.output))
      : descriptor.value;
    Object.defineProperty(
      out,
      key,
      "value" in descriptor
        ? {
            ...descriptor,
            value,
            configurable: true,
            writable: writer ? true : descriptor.writable
          }
        : { ...descriptor, configurable: true }
    );
  }
  for (const [key, slot] of record.shape) {
    if (Array.isArray(out) && key === "length") continue;
    const meta = writer ? (slot.writerValue() as ShapeMeta) : (read(slot.output) as ShapeMeta);
    const bits = meta.bits & shapeMask;
    if (!(bits & 1)) {
      Reflect.deleteProperty(out, key);
      order.delete(key);
      continue;
    }
    order.set(key, (meta.bits >>> 5) - 1);
    const existing = Object.getOwnPropertyDescriptor(out, key);
    const valueSlot = record.slots.get(key);
    const value = valueSlot
      ? writer
        ? valueSlot.writerValue()
        : untrack(() => read(valueSlot.output))
      : Object.getOwnPropertyDescriptor(shape, key)?.value;
    Object.defineProperty(
      out,
      key,
      bits & 16
        ? { get: meta.get, set: meta.set, enumerable: !!(bits & 2), configurable: true }
        : { value, enumerable: !!(bits & 2), configurable: true, writable: !!(bits & 8) }
    );
  }
  // JS places integer keys first regardless of insertion order. Rebuild the
  // remaining keys in their selected order so a delete/re-add moves only its
  // own key, without guessing the whole container frame.
  if (Array.isArray(out)) out.length = selectedArrayLength(t, (shape as any[]).length, writer);
  const ordered = Reflect.ownKeys(out)
    .filter(key => key !== $OWNER)
    .sort((a, b) => (order.get(a) ?? 0) - (order.get(b) ?? 0));
  if (ordered.some((key, index) => key !== Reflect.ownKeys(out)[index])) {
    const arranged = Array.isArray(out) ? [] : Object.create(record.prototype);
    for (const key of ordered)
      Object.defineProperty(arranged, key, Object.getOwnPropertyDescriptor(out, key)!);
    return arranged;
  }
  return out;
}

function selectedView(t: StoreTarget, source: Record<PropertyKey, any>, writer = false) {
  const body = selectedBody(t, writer);
  const record = records.get(t);
  if (!record) return body ?? source;
  // Shape candidates track; leaf values are read without subscribing the
  // enumerator to every field in the record.
  return compose(t, source, writer);
}

export const staticOptimisticHooks: OptHooks = {
  node: selectedNode,
  inputBody: selectedBody,
  ownsFirewall: (t, key, presence) => {
    if (selectedBody(t)) return true;
    if (key === undefined && records.get(t)?.structure) return true;
    // A resize supplies the full source; a minimum floor still demands it.
    if (!presence && key === "length" && Array.isArray(t.v)) return true;
    if (key === undefined) return false;
    const record = records.get(t);
    const slot = (presence ? record?.presence : record?.slots)?.get(key);
    return !!slot && firewallSlots.has(slot);
  },
  length: (t, base) =>
    selectedArrayLength(t, () => {
      const body = selectedBody(t);
      if (body) return body.length;
      pullFamilyInput(t, "length");
      return t.ch ? (read(getContainerNode(t)) as any[]).length : base();
    }),
  read: readSelected,
  rowValue: (t, key, receiver) => {
    const row = selectedBody(t);
    if (!row || row === t.v || (Array.isArray(row) && key === "length")) return undefined;
    let slot = records.get(t)?.slots.get(key);
    if (!slot && getObserver() !== null) {
      // Data fields need their own correction notifications; accessors keep
      // the proxy receiver used by Reflect.get below.
      const descriptor = Object.getOwnPropertyDescriptor(row, key);
      if (descriptor && "value" in descriptor) slot = slotFor(t, key);
    }
    return { value: slot ? read(slot.output) : Reflect.get(row, key, receiver) };
  },
  accessor: (t, key, receiver) => {
    const slot = records.get(t)?.shape.get(key);
    if (!slot) return undefined;
    const meta = read(slot.output) as ShapeMeta;
    if (!(meta.bits & 16)) return undefined;
    return { value: meta.get?.call(receiver) };
  },
  accessorKind: (t, key) => {
    const slot = records.get(t)?.shape.get(key);
    return slot ? !!((read(slot.output) as ShapeMeta).bits & 16) : undefined;
  },
  // Reading outputs discovers coherent publication, without writing a shared
  // guessed deep witness and merging disjoint action lifetimes.
  deep: t => {
    const record = getObserver() !== null ? recordFor(t) : records.get(t);
    if (!record) return;
    const shape = selectedView(t, t.v);
    for (const key of Reflect.ownKeys(shape)) {
      if (key === $OWNER) continue;
      const slot = getObserver() !== null ? slotFor(t, key) : record.slots.get(key);
      if (slot) read(slot.output);
    }
  },
  view: selectedView,
  descriptor: (t, key, source) => {
    // A presence update can reach a descriptor reader before this key's
    // shape stages. Link the shape output so its own staging corrects that
    // pass, independent of proposal order.
    const selectedShape = records.get(t)?.shape.get(key);
    if (selectedShape && getObserver() !== null) read(selectedShape.output);
    const descriptor = untrack(() => {
      const shape = selectedView(t, source);
      const record = records.get(t);
      if (!record && shape === source) return undefined;
      return Object.getOwnPropertyDescriptor(shape, key) ?? null;
    });
    const slot =
      descriptor && "value" in descriptor && getObserver() !== null
        ? slotFor(t, key)
        : records.get(t)?.slots.get(key);
    return descriptor && "value" in descriptor && slot
      ? { ...descriptor, value: read(slot.output) }
      : descriptor;
  },
  has: (t, key) => {
    const slot = records.get(t)?.presence.get(key);
    if (slot) return !!read(slot.output);
    const row = selectedBody(t);
    return row && row !== t.v ? key in row : undefined;
  },
  draft: t => {
    const record = recordFor(t);
    const base = committed(t);
    const previous = untrack(() => compose(t, base, true));
    record.draft = { previous, staged: t.pb };
    return cloneRaw(previous, t);
  },
  draftRead: (t, key, kind) => {
    if (Array.isArray(t.v) && key === "length") {
      readArrayLength(t);
      return;
    }
    const record = records.get(t);
    if (!record) return;
    // Values written earlier in this draft no longer consume another guess.
    if (key !== undefined && t.wk?.has(key)) return;
    const entangle = (r: RecordSlots): boolean => {
      if (kind === "keys") {
        for (const slot of r.shape.values()) entangleOptimisticSlotRead(slot);
        return r.shape.size > 0;
      }
      const slot = kind === "has" ? r.presence.get(key!) : r.slots.get(key!);
      if (!slot) return false;
      entangleOptimisticSlotRead(slot);
      return slot.activeOwner() !== null;
    };
    if (entangle(record)) return;
    if (t.ch) {
      const inner = (t.v as any)[$TARGET] as StoreTarget | undefined;
      const innerRecord = inner && records.get(inner);
      if (innerRecord) entangle(innerRecord);
    }
  },
  draftWrite: (t, key, before, after, kind) => {
    const record = recordFor(t);
    writeArray(t, key, before, after, kind, record);
  },
  writes: (t, next) => {
    const record = recordFor(t);
    const saved = record.draft;
    const previous = saved?.previous ?? untrack(() => compose(t, committed(t), true));
    record.draft = undefined;
    if (!saved && Array.isArray(next) && previous.length !== next.length)
      writeArray(t, "length", previous.length, next.length, "set", record);
    const oldKeys = Reflect.ownKeys(previous).filter(key => key !== $OWNER);
    const nextKeys = Reflect.ownKeys(next).filter(key => key !== $OWNER);
    const oldSurvivors = oldKeys.filter(key => nextKeys.includes(key));
    const nextSurvivors = nextKeys.filter(key => oldKeys.includes(key));
    const reordered = oldSurvivors.some((key, index) => key !== nextSurvivors[index]);
    const entries: [Slot, unknown][] = [];
    for (const key of new Set([...oldKeys, ...nextKeys])) {
      if (Array.isArray(next) && key === "length") continue;
      const old = Object.getOwnPropertyDescriptor(previous, key);
      const neu = Object.getOwnPropertyDescriptor(next, key);
      const inherited =
        key === "__proto__" || key === "prototype" ? undefined : record.prototype?.[key];
      const before = unwrapValue(old ? old.value : inherited);
      let after = unwrapValue(neu ? neu.value : inherited);
      if (t.ch && isWrappable(after)) after = resolveChainedRaw(t, key, after);
      let changed = !Object.is(before, after) && !targetsEqual(before, after);
      if (!changed && t.ch && t.wk?.has(key)) {
        // The inner store may have supplied this setter its held future.
        // A same-value assignment is still an outer guess when its selected
        // display has not reached that future yet.
        try {
          const shown = untrack(() => (t.v as any)[key]);
          changed = !Object.is(shown, after) && !targetsEqual(shown, after);
        } catch {}
        if (!changed) {
          const inner = (t.v as any)[$TARGET] as StoreTarget;
          changed =
            !!((inner.n?.[key as any]?._config ?? 0) & CONFIG_HELD) ||
            !!((inner.k?._config ?? 0) & CONFIG_HELD) ||
            !!((inner._fam?.node?._config ?? 0) & CONFIG_HELD);
          if (!changed && inner.pb !== null) {
            const truth = committed(inner);
            const future = inner.pb;
            changed =
              (!Object.is(truth[key as any], future[key as any]) &&
                !targetsEqual(truth[key as any], future[key as any])) ||
              key in truth !== key in future;
          }
        }
      }
      if (changed) entries.push([slotFor(t, key), after]);
      if (changed || !!old !== !!neu) {
        const presence = slotFor(t, key, true);
        const present = neu !== undefined || key in Object.create(record.prototype);
        if (changed || presence.writerValue() !== present) entries.push([presence, present]);
      }
      if (key !== "length" || !Array.isArray(next)) {
        if (changed || !sameShape(old, neu) || (reordered && !!old && !!neu))
          entries.push([shapeSlot(t, key), shapeMeta(next, key)]);
      }
    }
    proposeOptimisticSlots(entries);
    return saved?.staged ?? null;
  },
  reconcile: reconcileDraft,
  arrangement: () => false,
  pair: (t, source) => {
    const family = t._fam!;
    const paired = new Set<StoreTarget>();
    const pair = (child: StoreTarget, rowSlot?: Slot) => {
      while (child.u !== t) {
        if (!child.u) return;
        child = child.u;
      }
      if (paired.has(child)) return;
      paired.add(child);
      if (rowSlot) {
        recordFor(child).parent = rowSlot;
        selectedTargets.add(child);
      }
      const key = family.key?.(child.v);
      const incoming =
        Array.isArray(source) && key !== undefined
          ? source.find(row => isWrappable(row) && sameKey(family.key!(row), key))
          : source[child.pk!];
      if (isWrappable(incoming) && !lookupTarget(incoming, family))
        reconcileState(incoming, child.px, family.key, true);
    };
    // Preserve the identity of an already published row before pairing a
    // replacement proposal at the same positional slot.
    for (const child of selectedTargets)
      if (child.u === t && records.get(child)?.parent && !records.get(child)!.parent!.isIdle())
        pair(child, records.get(child)!.parent);
    // An index override selects a row identity. Its unguessed fields still
    // receive matching answers; explicit leaf overrides remain selected.
    for (const slot of records.get(t)?.slots.values() ?? []) {
      if (!slot.activeOwner()) continue;
      const value = slot.writerValue();
      const child = isWrappable(value) && lookupTarget(value, family);
      if (child) pair(child, slot);
    }
    // A guessed leaf can also keep a row that its parent never guessed.
    for (const target of family.live) {
      const record = records.get(target);
      if (!record) continue;
      for (const slots of [record.slots, record.presence, record.shape]) {
        let found = false;
        for (const slot of slots.values())
          if (slot.activeOwner()) {
            pair(target);
            found = true;
            break;
          }
        if (found) break;
      }
    }
  },
  sweep: () => {
    // Once a correction committed, an enumerator no longer needs the extra
    // shape candidate. Wake it through the ordinary discovery node so its
    // next pass unlinks the companion, then the existing release queue frees it.
    for (const t of shapedTargets) {
      const record = records.get(t)!;
      for (const [key, slot] of record.shape)
        if (slot.isIdle()) {
          record.shape.delete(key);
        }
      if (!record.shape.size) shapedTargets.delete(t);
      // Existing readers unlink on their next real update; no extra rendered
      // callback is necessary just because bookkeeping became idle.
    }
    for (const [slot, { remove, target }] of releases) {
      if (slot.output._subs !== null) releases.delete(slot);
      else if (slot.tryRelease(!!(target._fam?.node?._flags! & REACTIVE_DISPOSED))) {
        releases.delete(slot);
        remove();
      }
    }
    for (const child of selectedTargets) {
      const record = records.get(child)!;
      if (!record.parent?.isIdle() && !(record.parent!.output._flags & REACTIVE_DISPOSED)) continue;
      record.parent = undefined;
      selectedTargets.delete(child);
      for (const target of child._fam!.live) {
        let ancestor: StoreTarget | null = target;
        while (ancestor && ancestor !== child) ancestor = ancestor.u;
        if (ancestor === child)
          for (const input of records.get(target)?.inputs ?? []) enqueueSub(input);
      }
    }
    sweepArrays();
  },
  ask: () => {},
  park: () => {},
  stands: (t, key, presence) => {
    if (key === undefined) return false;
    const record = records.get(t);
    const slot = (presence ? record?.presence : record?.slots)?.get(key);
    if (slot?.activeOwner()) return true;
    if (presence) return false;
    return descendantStands(t, key);
  }
};

export function createStaticOptimisticStore(first: any, second?: any, third?: any) {
  const derived = typeof first === "function";
  const store = createProjectionInternal(
    derived ? first : null,
    derived ? second : first,
    derived ? third : second,
    true
  );
  recordFor((store as any)[$TARGET]);
  return [
    store,
    (fn: (draft: any) => any) => withOptimisticSlotBatch(() => storeSetter(store, fn))
  ] as const;
}

function reconcileDraft(draft: any, incoming: any, keyFn: ((item: any) => any) | null): void {
  if (Array.isArray(incoming)) {
    const n = draft.length as number;
    const prev: any[] = new Array(n);
    for (let i = 0; i < n; i++) prev[i] = draft[i];
    let byKey: Map<any, any> | null = null;
    if (keyFn !== null) {
      byKey = new Map();
      for (let i = 0; i < n; i++) {
        const raw = unwrapValue(prev[i]);
        if (!isWrappable(raw)) continue;
        const k = keyFn(raw);
        if (k !== undefined && !byKey.has(k)) byKey.set(k, prev[i]);
      }
    }
    for (let i = 0; i < incoming.length; i++) {
      const nv = incoming[i];
      let match: any;
      if (isWrappable(nv)) {
        if (byKey !== null) {
          const k = keyFn!(nv);
          if (k !== undefined) match = byKey.get(k);
        } else if (i < n && isWrappable(unwrapValue(prev[i]))) match = prev[i];
      }
      if (match !== undefined) {
        if (unwrapValue(match) !== nv) reconcileDraft(match, nv, keyFn);
        if (draft[i] !== match) draft[i] = match;
      } else if (unwrapValue(draft[i]) !== nv) draft[i] = nv;
    }
    if (draft.length !== incoming.length) draft.length = incoming.length;
    return;
  }
  for (const k of Object.keys(incoming)) {
    const nv = incoming[k];
    const cur = draft[k];
    const curRaw = unwrapValue(cur);
    if (
      isWrappable(nv) &&
      isWrappable(curRaw) &&
      Array.isArray(nv) === Array.isArray(curRaw) &&
      (keyFn === null || Array.isArray(nv) || sameKey(keyFn(nv), keyFn(curRaw)))
    ) {
      if (curRaw !== nv) reconcileDraft(cur, nv, keyFn);
    } else if (curRaw !== nv) draft[k] = nv;
  }
  for (const k of Object.keys(draft)) if (!(k in incoming)) delete draft[k];
}
