/** Publication lifecycle shared by source-owned observation outputs. */
import { carryStagedError } from "../core/async.js";
import {
  CONFIG_AUTO_DISPOSE,
  CONFIG_HELD,
  NOT_PENDING,
  REACTIVE_DISPOSED,
  STATUS_PENDING,
  STATUS_UNINITIALIZED
} from "../core/constants.js";
import {
  blocked,
  inEffectCallback,
  liveTx,
  setEffectCallback,
  setStagedError,
  txOf,
  type Transaction
} from "../core/scheduler.js";
import { runWithOwner } from "../core/core.js";
import type { Computed } from "../core/types.js";
import {
  inputTime,
  createLayerBoundary,
  setObservationLifecycle,
  resumeInput,
  readOverride,
  stageLayer,
  wakeLayers,
  type Layer
} from "./coordination.js";

export type Observation<T> = Layer<T> & {
  _parent: Transaction | null;
  _retiring: boolean;
  _time: number;
  _observation: ObservationKind<T>;
};
export type ObservationKind<T> = {
  /** Include unheld staged values, before the input has a pending verdict. */
  _prepareValue?: true;
  _fallback: (layer: Layer<T>) => T;
  _sample: (record: Observation<T>) => T;
  _active: (record: Observation<T>, value: T) => boolean;
  _observe?: (record: Observation<T>) => void;
  _parent?: (record: Observation<T>) => Transaction | null;
};
const dirty = new Set<Observation<any>>();
const watching = new Set<Observation<any>>();
function prepareObservations(): boolean {
  let changed = false;
  // Prepare both observations of a held synchronous proposal in the same
  // round. Waiting for settle would publish latest before pending. Latest
  // also samples unheld proposals; those are not pending merely by staging.
  for (const record of dirty) {
    // A new input question supersedes a prepared restoration before its
    // readers run again, not only after the publication sweep.
    if (record._retiring && record._time !== inputTime(record._input)) record._retiring = false;
    // A first answer can be staged beneath a replacement flight before it
    // initializes the input. Its observations still have a value to select.
    // A ready first answer initializes normally; opening a child update for
    // it here would compete with the initialization that is already landing.
    if (
      record._retiring ||
      record._output._flags & REACTIVE_DISPOSED ||
      (!(record._input._statusFlags & STATUS_PENDING) &&
        (!(record._observation._prepareValue || record._input._config & CONFIG_HELD) ||
          record._input._pendingValue === NOT_PENDING)) ||
      (record._input._statusFlags & STATUS_UNINITIALIZED &&
        (!(record._input._statusFlags & STATUS_PENDING) ||
          record._input._pendingValue === NOT_PENDING))
    )
      continue;
    const next = record._observation._sample(record);
    if (!Object.is(record._override, next)) {
      stageLayer(record, next);
      changed = true;
    }
  }
  // New observation proposals must propagate before readiness is judged.
  // Their readers can discover additional holds (including sibling inputs).
  if (changed) return true;
  for (const record of watching) {
    if (record._output._flags & REACTIVE_DISPOSED) {
      watching.delete(record);
      dirty.delete(record);
      continue;
    }
    // Restore with the update that still owns this observation's question.
    // Pending can follow a lower input through a ready optimistic output;
    // otherwise the newly staged output owns its restoration.
    const owner = record._observation._parent
      ? record._observation._parent(record)
      : record._input._config & CONFIG_HELD
        ? txOf(record._input)
        : record._parent;
    const parent = owner && liveTx(owner);
    if (record._retiring) {
      // A ready, unheld input can acquire a hold from this restoration's
      // ordinary consequences. Keep the restoration in that newly discovered
      // update instead of mistaking it for a fresh pending question.
      record._parent ??= parent;
      continue;
    }
    if (
      parent
        ? blocked(parent)
        : record._observation._active(record, record._observation._sample(record))
    )
      continue;
    // Rejoin before publication so new ordinary consequences can hold the
    // input and the observation's restoration together.
    record._retiring = true;
    record._parent = parent;
    record._time = inputTime(record._input);
    // Preparation can be triggered by a different, lower update's flush.
    // Restore within the selected input update, without joining that flush.
    record._parent = resumeInput(record, parent, true);
    changed = true;
  }
  return changed;
}

function settleObservations(): void {
  for (const record of watching) dirty.add(record);
  for (const record of dirty) {
    if (
      record._output._flags & REACTIVE_DISPOSED ||
      (record._input._statusFlags & STATUS_UNINITIALIZED &&
        (!(record._input._statusFlags & STATUS_PENDING) ||
          record._input._pendingValue === NOT_PENDING))
    ) {
      // A staged first answer can be ready but not initialized until the
      // commit below. Keep an existing watch so its pending override retires
      // after that commit, even when the landing compares equal.
      if (record._output._flags & REACTIVE_DISPOSED || record._input._pendingValue === NOT_PENDING)
        watching.delete(record);
      continue;
    }
    if (record._retiring) {
      const live = record._parent && liveTx(record._parent);
      if (live && record._time === inputTime(record._input)) continue;
      record._retiring = false;
    }
    record._parent = record._observation._parent
      ? record._observation._parent(record)
      : record._input._config & CONFIG_HELD
        ? txOf(record._input)
        : null;
    const next = record._observation._sample(record);
    if (record._observation._active(record, next)) watching.add(record);
    else watching.delete(record);
    if (!Object.is(record._override, next)) stageLayer(record, next);
  }
  dirty.clear();
}

setObservationLifecycle({
  _prepare: prepareObservations,
  _settle: settleObservations,
  _active: () => !!(dirty.size || watching.size)
});

export function initializeObservation<T>(
  layer: Layer<T>,
  kind: ObservationKind<T>
): Observation<T> {
  const record = layer as Observation<T>;
  record._parent = null;
  record._retiring = false;
  record._time = inputTime(record._input);
  record._observation = kind;
  return record;
}

/** The source's lazy companion is internal allocation, even when its first
 * read occurs in an effect callback. No producer runs inside this window:
 * normal reads after allocation retain the user-facing creation diagnostic. */
export function createSourceObservation<T>(
  source: Computed<any>,
  kind: ObservationKind<T>
): Observation<T> {
  const callback = __DEV__ && inEffectCallback;
  if (__DEV__) setEffectCallback(false);
  try {
    return runWithOwner(null, () =>
      initializeObservation(
        createLayerBoundary(
          source,
          selectObservation,
          false,
          true,
          __OBSERVE__ ? { name: source._name } : undefined
        ),
        kind
      )
    );
  } finally {
    if (__DEV__) setEffectCallback(callback);
  }
}

export function releaseObservation(record: Observation<any>): void {
  dirty.delete(record);
  watching.delete(record);
  record._parent = null;
  record._retiring = false;
  record._override = NOT_PENDING;
  // Dormant observation outputs have no remaining published consumers.
  // Their next use initializes a fresh frame from the current input state,
  // rather than manufacturing a stale frame before starting current work.
  if (record._output._config & CONFIG_AUTO_DISPOSE) {
    // A discarded first proposal must not satisfy revival's equality check
    // before this output has ever published a value.
    record._output._pendingValue = NOT_PENDING;
    record._output._statusFlags |= STATUS_UNINITIALIZED;
  }
}

export function markObservation(layer: Layer<any>): void {
  const record = layer as Observation<any>;
  record._observation._observe?.(record);
  dirty.add(record);
  record._output._cleanup ??= releaseObservation.bind(null, record);
  wakeLayers();
}

export function selectObservation<T>(layer: Layer<T>): T {
  markObservation(layer);
  return layer._override === NOT_PENDING
    ? (layer as Observation<T>)._observation._fallback(layer)
    : readOverride(layer);
}

setStagedError(carryStagedError);
