/** Source-owned pending output using the common layer publication path.
 * Callback queries read those same outputs. No verdict lane or reader flag. */
import {
  computed,
  context,
  read,
  prepareComputed,
  verdict,
  setVerdict,
  setStrictRead
} from "../core/core.js";
import { link } from "../core/graph.js";
import { NotReadyError } from "../core/error.js";
import { quietPending } from "../core/async.js";
import { cleanup } from "../core/owner.js";
import { GlobalQueue, txOf, setPendingMark } from "../core/scheduler.js";
import {
  $REFRESH,
  CONFIG_HELD,
  NOT_PENDING,
  STATUS_PENDING,
  STATUS_UNINITIALIZED
} from "../core/constants.js";
import {
  createLayerBoundary,
  initialObservation,
  pendingInput,
  type Layer
} from "./coordination.js";
import { observesSnapshot, withReadWindow } from "./window.js";
import type { Computed, Signal } from "../core/types.js";

import {
  initializeObservation,
  createSourceObservation,
  markObservation,
  selectObservation,
  releaseObservation,
  type Observation as SharedObservation,
  type ObservationKind
} from "./observation.js";

type Observation = SharedObservation<boolean> & { _incoming: Computed<any> | undefined };

// A displayed error is an answer too. Recovering to the last good value
// still differs from that display until the recovery publishes.
function pendingAnswer(
  input: Computed<any>,
  incoming: Computed<any>,
  value = input._value
): boolean {
  return !!(
    (incoming._statusFlags & STATUS_PENDING && !quietPending(incoming)) ||
    (!incoming._x?._reask &&
      incoming._pendingValue !== NOT_PENDING &&
      (!!input._x?._shownError || !input._equals || !input._equals(value, incoming._pendingValue)))
  );
}

function proposedPending(input: Computed<any>, incoming?: Computed<any>): boolean {
  if (GlobalQueue._marked?.(input) === true) return true;
  if (
    input._statusFlags & STATUS_UNINITIALIZED &&
    (!(input._statusFlags & STATUS_PENDING) || input._pendingValue === NOT_PENDING)
  )
    return false;
  if (
    (input._statusFlags & STATUS_PENDING && !quietPending(input)) ||
    (input._config & CONFIG_HELD &&
      !input._x?._reask &&
      input._pendingValue !== NOT_PENDING &&
      (!!input._x?._shownError ||
        !input._equals ||
        !input._equals(input._value, input._pendingValue)))
  )
    return true;
  // Observation outputs retain their input question. Follow only those
  // explicit boundaries, including latest around an optimistic output;
  // ordinary memo dependencies are not traversed or given new metadata.
  for (; incoming; incoming = pendingInput(incoming)) {
    if (pendingAnswer(input, incoming)) return true;
  }
  return false;
}

function observeInput(record: Observation): void {
  const output = record._output;
  for (let incoming = record._incoming; incoming; incoming = pendingInput(incoming)) {
    link(incoming, output);
    if (incoming._height >= output._height) output._height = incoming._height + 1;
  }
}

const kind: ObservationKind<boolean> = {
  _fallback: pendingFallback,
  _sample: record => proposedPending(record._input, (record as Observation)._incoming),
  _active: (_record, value) => value,
  _observe: record => observeInput(record as Observation),
  _parent: record => {
    const input = record._input;
    // A declared question (deferred/affects) can outlive a ready value's
    // transaction. That transaction finishing does not restore pending=false.
    if (GlobalQueue._marked?.(input)) return null;
    const value = input._pendingValue !== NOT_PENDING ? input._pendingValue : input._value;
    let incoming = (record as Observation)._incoming;
    // A ready optimistic/latest output does not finish the pending input
    // question. Its publication cannot retire that question's pending=true.
    for (; incoming; incoming = pendingInput(incoming))
      if (incoming._config & CONFIG_HELD && pendingAnswer(input, incoming, value))
        return txOf(incoming);
    return record._input._config & CONFIG_HELD ? txOf(record._input) : null;
  }
};

// The input identity is fixed for an observation's lifetime. Shared selector
// code avoids retaining another closure per observed source.
function pendingFallback(layer: Layer<boolean>): boolean {
  const source = layer._input;
  if (typeof source._fn === "function") prepareComputed(source, false);
  if (
    source._statusFlags & STATUS_UNINITIALIZED &&
    (!(source._statusFlags & STATUS_PENDING) || source._pendingValue === NOT_PENDING)
  )
    read(source);
  const output = context as Computed<any>;
  link(source, output);
  if (source._height >= output._height) output._height = source._height + 1;
  if (output._statusFlags & STATUS_UNINITIALIZED)
    return initialObservation(layer, proposedPending(source, pendingInput(source)));
  return false;
}

export function createPending<T>(input: () => T): () => boolean {
  let record: Observation | undefined;
  const mark = () => {
    if (record) {
      markObservation(record);
    }
  };
  const source = (input as any)[$REFRESH] as Computed<any> | undefined;
  const producer =
    source ||
    computed(() => {
      try {
        return input();
      } finally {
        mark();
      }
    });
  const layer = createLayerBoundary<boolean>(producer, selectObservation, !source, true);
  record = observation(layer);
  markObservation(record);
  cleanup(() => releaseObservation(record!));
  return () => read(layer._output);
}

// The input owns the identity of its pending output. A weak key adds no
// ordinary-node fields; the output uses the normal observation lifecycle.
const observations = new WeakMap<Signal<any>, Observation>();

/** A declared change can alter pending without changing a source's value.
 * Only affects() calls this; ordinary notification keeps its existing path. */
export function markPending(source: Signal<any>): void {
  const record = observations.get(source);
  if (record) markObservation(record);
}

function observation(layer: Layer<boolean>): Observation {
  const record = initializeObservation(layer, kind) as Observation;
  if (__OBSERVE__) (record._output as any)._devWindows = 1;
  record._incoming = pendingInput(layer._input);
  return record;
}

function pendingOutput(source: Computed<any>): Computed<boolean> {
  const existing = observations.get(source);
  if (existing) return existing._output;
  const record = createSourceObservation(source, kind) as Observation;
  if (__OBSERVE__) (record._output as any)._devWindows = 1;
  record._incoming = pendingInput(source);
  observations.set(source, record);
  return record._output;
}

function readPending(source: Computed<any>): boolean {
  if (observesSnapshot(source)) {
    read(source);
    return false;
  }
  // Probing pending is allowed in component bodies. An uninitialized input
  // still throws NotReady, rather than the strict ordinary-read diagnostic.
  const initializing = !!(source._statusFlags & STATUS_UNINITIALIZED);
  const strict = __DEV__ && initializing ? setStrictRead(false) : false;
  try {
    return read(pendingOutput(source));
  } finally {
    if (__DEV__ && initializing) setStrictRead(strict);
  }
}

// A callback window observes each source's existing pending output. Its
// return value is irrelevant, so an equal callback result cannot hide a
// pending read. Nested computations still perform their ordinary reads.
function probe(source: Signal<any>, window: { found: boolean }): unknown {
  if (observesSnapshot(source)) return read(source);
  // The output is an ordinary read, so an outer observation sees this
  // pending boolean. The callback's control flow still reads the source.
  window.found = readPending(source as Computed<any>) || window.found;
  // A callback needs the last value for control flow, not a value read that
  // joins the request it is probing. The pending output already subscribes
  // to this request and wakes the callback when its answer becomes available.
  const status = (source as Computed<any>)._statusFlags;
  // The pending output can describe a staged first answer's replacement.
  // Its callback may use that answer too, without rejoining the input hold.
  if (
    status & STATUS_PENDING &&
    (!(status & STATUS_UNINITIALIZED) || source._pendingValue !== NOT_PENDING)
  )
    return status & STATUS_UNINITIALIZED ? source._pendingValue : source._value;
  const previous = verdict;
  // The observation above is the user's read. This second read only drives
  // callback control flow; reporting it too duplicates the same diagnostic.
  const strict = __DEV__ ? setStrictRead(false) : false;
  setVerdict(null);
  try {
    return read(source);
  } catch (error) {
    if (
      error instanceof NotReadyError &&
      !((source as Computed<any>)._statusFlags & STATUS_UNINITIALIZED)
    )
      return source._value;
    throw error;
  } finally {
    setVerdict(previous);
    if (__DEV__) setStrictRead(strict);
  }
}

/** The input owns its pending output; calling computations only read it. */
export function isPending<T>(input: () => T): boolean {
  const source = (input as any)[$REFRESH] as Computed<any> | undefined;
  if (!source) return withReadWindow(input, probe, true);
  try {
    return readPending(source);
  } catch (error) {
    // Match the callback window: a first load participates in an owned
    // boundary, while an imperative probe has no loading frame to suspend.
    if (error instanceof NotReadyError && context === null) return false;
    throw error;
  }
}

setPendingMark(markPending);
