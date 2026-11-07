/** One lazily created latest output per source, published by ordinary machinery. */
import { context, prepareComputed, read, unflushedValue } from "../core/core.js";
import {
  $REFRESH,
  CONFIG_HELD,
  CONFIG_STAGED_ERROR,
  NOT_PENDING,
  REACTIVE_DISPOSED,
  STATUS_ERROR,
  STATUS_PENDING,
  STATUS_UNINITIALIZED
} from "../core/constants.js";
import { flushTransaction, holdQueuedProposals, resolveTx } from "../core/scheduler.js";
import { link } from "../core/graph.js";
import type { Computed, Signal } from "../core/types.js";
import { initialObservation, stageLayer, type Layer } from "./coordination.js";
import { observesSnapshot, withReadWindow } from "./window.js";
import {
  createSourceObservation,
  selectObservation,
  type Observation,
  type ObservationKind
} from "./observation.js";

// A selected throw is distinct from returning an Error as a value.
class LatestError {
  constructor(readonly _error: unknown) {}
}

function selectedError(record: Observation<any>, error: unknown): LatestError {
  const previous = record._override;
  return previous instanceof LatestError && previous._error === error
    ? previous
    : new LatestError(error);
}

function selectLatest(layer: Layer<any>): unknown {
  const value = selectObservation(layer);
  if (value instanceof LatestError) throw value._error;
  return value;
}

const kind: ObservationKind<any> = {
  _prepareValue: true,
  _fallback: fallback,
  _sample: record => {
    const source = record._input;
    if (source._config & CONFIG_STAGED_ERROR) return selectedError(record, source._pendingValue);
    if (source._pendingValue !== NOT_PENDING) return source._pendingValue;
    // A re-ask has no replacement answer yet. Keep the selected error,
    // just as the input retains a staged successful value during a re-ask.
    if (source._statusFlags & STATUS_PENDING) {
      if (record._override instanceof LatestError) return record._override;
      if (source._x?._shownError) return selectedError(record, source._x._shownError);
    }
    if (source._statusFlags & STATUS_ERROR) return NOT_PENDING;
    if (
      !(source._config & CONFIG_HELD) &&
      !(source._statusFlags & STATUS_PENDING) &&
      source._pendingValue === NOT_PENDING
    ) {
      const output = record._output;
      const value = output._pendingValue !== NOT_PENDING ? output._pendingValue : output._value;
      // A held input may have committed after this output read its old
      // value. Finish that publication before returning to ordinary reads.
      return !(output._statusFlags & STATUS_ERROR || output._x?._shownError) &&
        Object.is(value, source._value)
        ? NOT_PENDING
        : source._value;
    }
    return source._pendingValue !== NOT_PENDING ? source._pendingValue : source._value;
  },
  _active: record =>
    !!(record._input._config & CONFIG_HELD || record._input._statusFlags & STATUS_PENDING)
};

function fallback(layer: Layer<any>): unknown {
  const source = layer._input;
  const output = context as Computed<any>;
  if (typeof source._fn === "function") prepareComputed(source, false);
  // A staged value is already a proposal, before parking marks it held.
  // Reading it ordinarily here can join downstream work to the input update
  // before latest gets the chance to establish its explicit boundary.
  // This includes a first answer whose replacement is already pending:
  // UNINITIALIZED describes publication, not the absence of that proposal.
  if (
    (layer as Observation<any>)._retiring ||
    source._statusFlags & STATUS_ERROR ||
    (source._statusFlags & STATUS_UNINITIALIZED &&
      (!(source._statusFlags & STATUS_PENDING) || source._pendingValue === NOT_PENDING)) ||
    source._config & CONFIG_STAGED_ERROR ||
    (!(source._config & CONFIG_HELD) &&
      !(source._statusFlags & STATUS_PENDING) &&
      source._pendingValue === NOT_PENDING &&
      !(output._statusFlags & STATUS_ERROR || output._x?._shownError))
  ) {
    // An error is the latest settled proposal. Pulling it through read() can
    // retry the producer in the next tick and replace that error with a new
    // pending request before the observation's consumers ever receive it.
    if (source._statusFlags & STATUS_ERROR || source._config & CONFIG_STAGED_ERROR) {
      link(source, output);
      if (source._height >= output._height) output._height = source._height + 1;
      if (
        source._config & CONFIG_STAGED_ERROR &&
        !(output._statusFlags & STATUS_UNINITIALIZED) &&
        !(layer as Observation<any>)._retiring
      )
        return output._value;
      throw source._config & CONFIG_STAGED_ERROR ? source._pendingValue : source._x!._error;
    }
    return read(source);
  }
  link(source, output);
  if (source._height >= output._height) output._height = source._height + 1;
  if (source._x?._shownError && source._pendingValue === NOT_PENDING) throw source._x._shownError;
  // A new output has no published frame to preserve. Initialize it from the
  // latest flushed proposal; ordinary creation and Loading then own any
  // initial async consequence. Existing outputs retain their published value.
  if (output._statusFlags & STATUS_UNINITIALIZED) {
    const flushed = unflushedValue(source);
    return initialObservation(
      layer,
      flushed !== NOT_PENDING
        ? flushed
        : source._pendingValue !== NOT_PENDING
          ? source._pendingValue
          : source._value
    );
  }
  if (output._statusFlags & STATUS_ERROR) throw output._x!._error;
  if (output._x?._shownError) throw output._x._shownError;
  return source._value;
}

const observations = new WeakMap<Signal<any>, Observation<any>>();
function latestOutput(source: Computed<any>): Computed<any> {
  const existing = observations.get(source);
  if (existing) {
    // A known hold needs its output selected before this reader continues.
    // Otherwise a previously initialized latest output can supply its old
    // value beside the input's proposal during the same calculation.
    // Leave first answers, retirement and not-yet-flushed writes to their
    // existing initialization and publication paths.
    if (
      !existing._retiring &&
      !(existing._output._flags & REACTIVE_DISPOSED) &&
      !(source._statusFlags & STATUS_UNINITIALIZED) &&
      source._pendingValue !== NOT_PENDING &&
      unflushedValue(source) === NOT_PENDING
    ) {
      const update = flushTransaction && resolveTx(flushTransaction);
      if (source._config & CONFIG_HELD || update?._open) {
        if (update) holdQueuedProposals(update);
        const next = kind._sample(existing);
        if (!Object.is(existing._override, next)) stageLayer(existing, next);
      }
    }
    return existing._output;
  }
  const record = createSourceObservation(source, kind, selectLatest);
  // Preserve distinctions a source can publish, including signed zero.
  record._output._equals = Object.is;
  if (__OBSERVE__) (record._output as any)._devWindows = 2;
  record._statusInput = source;
  observations.set(source, record);
  return record._output;
}

function windowRead(source: Signal<any>): unknown {
  return read(observesSnapshot(source) ? source : latestOutput(source as Computed<any>));
}

export function latest<T>(input: () => T): T {
  const source = (input as any)[$REFRESH] as Computed<any> | undefined;
  return source ? (windowRead(source) as T) : withReadWindow(input, windowRead);
}
