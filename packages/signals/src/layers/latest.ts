/** One lazily created latest output per source, published by ordinary machinery. */
import { context, prepareComputed, read, unflushedValue } from "../core/core.js";
import {
  $REFRESH,
  CONFIG_HELD,
  CONFIG_STAGED_ERROR,
  NOT_PENDING,
  STATUS_ERROR,
  STATUS_PENDING,
  STATUS_UNINITIALIZED
} from "../core/constants.js";
import { link } from "../core/graph.js";
import type { Computed, Signal } from "../core/types.js";
import { initialObservation, type Layer } from "./coordination.js";
import { withReadWindow } from "./window.js";
import { createSourceObservation, type Observation, type ObservationKind } from "./observation.js";

const kind: ObservationKind<any> = {
  _prepareValue: true,
  _fallback: fallback,
  _sample: record => {
    const source = record._input;
    if (source._statusFlags & STATUS_ERROR || source._config & CONFIG_STAGED_ERROR) return NOT_PENDING;
    if (
      !(source._config & CONFIG_HELD) &&
      !(source._statusFlags & STATUS_PENDING) &&
      source._pendingValue === NOT_PENDING
    ) {
      const output = record._output;
      const value = output._pendingValue !== NOT_PENDING ? output._pendingValue : output._value;
      // A held input may have committed after this output read its old
      // value. Finish that publication before returning to ordinary reads.
      return Object.is(value, source._value) ? NOT_PENDING : source._value;
    }
    return source._pendingValue !== NOT_PENDING ? source._pendingValue : source._value;
  },
  _active: record =>
    !!(record._input._config & CONFIG_HELD || record._input._statusFlags & STATUS_PENDING)
};

function fallback(layer: Layer<any>): unknown {
  const source = layer._input;
  if (typeof source._fn === "function") prepareComputed(source, false);
  // A staged value is already a proposal, before parking marks it held.
  // Reading it ordinarily here can join downstream work to the input update
  // before latest gets the chance to establish its explicit boundary.
  if (
    (layer as Observation<any>)._retiring ||
    source._statusFlags & (STATUS_ERROR | STATUS_UNINITIALIZED) ||
    source._config & CONFIG_STAGED_ERROR ||
    (!(source._config & CONFIG_HELD) &&
      !(source._statusFlags & STATUS_PENDING) &&
      source._pendingValue === NOT_PENDING)
  ) {
    // An error is the latest settled proposal. Pulling it through read() can
    // retry the producer in the next tick and replace that error with a new
    // pending request before the observation's consumers ever receive it.
    if (source._statusFlags & STATUS_ERROR || source._config & CONFIG_STAGED_ERROR) {
      const output = context as Computed<any>;
      link(source, output);
      if (source._height >= output._height) output._height = source._height + 1;
      throw source._config & CONFIG_STAGED_ERROR ? source._pendingValue : source._x!._error;
    }
    return read(source);
  }
  const output = context as Computed<any>;
  link(source, output);
  if (source._height >= output._height) output._height = source._height + 1;
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
  return source._value;
}

const observations = new WeakMap<Signal<any>, Observation<any>>();
function latestOutput(source: Computed<any>): Computed<any> {
  const existing = observations.get(source);
  if (existing) return existing._output;
  const record = createSourceObservation(source, kind);
  // Preserve distinctions a source can publish, including signed zero.
  record._output._equals = Object.is;
  if (__OBSERVE__) (record._output as any)._devWindows = 2;
  record._statusInput = source;
  observations.set(source, record);
  return record._output;
}

function windowRead(source: Signal<any>): unknown {
  return read(latestOutput(source as Computed<any>));
}

export function latest<T>(input: () => T): T {
  const source = (input as any)[$REFRESH] as Computed<any> | undefined;
  return source ? read(latestOutput(source)) : withReadWindow(input, windowRead);
}
