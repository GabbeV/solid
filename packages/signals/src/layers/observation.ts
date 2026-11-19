/** Publication lifecycle shared by source-owned observation outputs. */
import { boundaries } from "./boundary.js";
import { enqueueSub } from "../core/heap.js";
import { carryStagedError } from "../core/async.js";
import {
  CONFIG_AUTO_DISPOSE,
  CONFIG_HELD,
  CONFIG_STAGED,
  CONFIG_STAGED_ERROR,
  NOT_PENDING,
  REACTIVE_DISPOSED,
  STATUS_PENDING,
  STATUS_UNINITIALIZED
} from "../core/constants.js";
import {
  blocked,
  readyToPublish,
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
  stageRestoration,
  calculateCorrection,
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
  _fallback: (layer: Layer<T>) => T;
  _restoresInputValue?: boolean;
  _sample: (record: Observation<T>) => T;
  _active: (record: Observation<T>, value: T) => boolean;
  _observe?: (record: Observation<T>) => void;
  _parent?: (record: Observation<T>) => Transaction | null;
};
const dirty = new Set<Observation<any>>();
const watching = new Set<Observation<any>>();
// Selection during a pull is the same propagation work as selection in the
// preparation loop. Give its consumers a round before retiring the override.
let selected = false;
// Hold lower publication and replay only for this sweep. The child may land
// while its input is still held, then the next round prepares the revert.
let previews: Map<Transaction, Observation<any>> | undefined;

function awaitingPreview(update: Transaction): boolean {
  return !!previews?.has(update);
}

export function stageObservation(record: Observation<any>, value: unknown): void {
  stageLayer(record, value);
  selected = true;
}

function deadObservation(record: Observation<any>): boolean {
  return !!(
    (record._output._flags & REACTIVE_DISPOSED &&
      !(record._output._config & CONFIG_AUTO_DISPOSE)) ||
    (record._input._flags & REACTIVE_DISPOSED &&
      (!(record._input._config & CONFIG_AUTO_DISPOSE) ||
        (record._input._parent as Computed<any> | null)?._flags! & REACTIVE_DISPOSED))
  );
}

function readsOutput(
  node: Computed<any>,
  output: Computed<any>,
  update: Transaction,
  seen: Set<Computed<any>>
): boolean {
  if (seen.has(node)) return false;
  seen.add(node);
  for (let edge = node._deps; edge; edge = edge._nextDep) {
    if (edge._gen !== node._depGen) continue;
    const dep = edge._dep as Computed<any>;
    if (dep === output) return true;
    if (!(dep._config & CONFIG_HELD) || txOf(dep) !== update || !dep._fn) continue;
    const layer = boundaries.get(dep);
    if ((!layer || layer._override === NOT_PENDING) && readsOutput(dep, output, update, seen))
      return true;
  }
  return false;
}

/**
 * A higher pass can supersede the last request holding its input. Before
 * replaying that reader in the input update, restore the pending outputs it
 * consumed. A ready preview can publish first; an unfinished one expires.
 */
function prepareObservationPreview(record: Observation<any>): void {
  if (
    record._input._pendingValue === NOT_PENDING ||
    record._override === NOT_PENDING ||
    !record._observation._active(record, record._override) ||
    !(record._output._config & CONFIG_HELD)
  )
    return;
  const parent = record._observation._parent
    ? record._observation._parent(record)
    : record._input._config & CONFIG_HELD
      ? txOf(record._input)
      : null;
  if (!parent?._reruns?.size) return;
  const output = txOf(record._output);
  if (parent === output) return;
  // A held callback alone has no staged calculation to replace. Follow
  // current dependencies so a peer sharing the transaction cannot trigger
  // publication on behalf of a reader that never consumed this observation.
  for (const reader of parent._reruns) {
    if (
      !(reader._config & CONFIG_STAGED) ||
      !(reader._config & CONFIG_HELD) ||
      txOf(reader) !== output ||
      (record._observation._restoresInputValue &&
        (reader._x?._supersededGen !== reader._depGen ||
          reader._x?._inFlight ||
          reader._statusFlags & STATUS_PENDING)) ||
      !readsOutput(reader, record._output, output, new Set())
    )
      continue;
    if (record._observation._restoresInputValue && (reader._x?._supersededGen !== reader._depGen || reader._x?._inFlight || reader._statusFlags & STATUS_PENDING)) continue;
    if (blocked(parent)) return;
    const ready = readyToPublish(output);
    if (!ready && record._observation._restoresInputValue) return;
    watching.add(record);
    if (ready) (previews ??= new Map()).set(parent, record);
    break;
  }
}

function prepareObservations(): boolean {
  previews = undefined;
  let changed = selected;
  selected = false;
  // Prepare both observations of a held synchronous proposal in the same
  // round. Waiting for settle would publish latest before pending. Unheld
  // proposals propagate through inactive latest outputs ordinarily.
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
        (!(record._input._config & CONFIG_HELD) || record._input._pendingValue === NOT_PENDING)) ||
      (record._input._statusFlags & STATUS_UNINITIALIZED &&
        (!(record._input._statusFlags & STATUS_PENDING) ||
          record._input._pendingValue === NOT_PENDING))
    )
      continue;
    const next = record._observation._sample(record);
    prepareObservationPreview(record);
    if (!Object.is(record._override, next)) {
      stageLayer(record, next);
      changed = true;
    }
  }
  // New observation proposals must propagate before readiness is judged.
  // Their readers can discover additional holds (including sibling inputs).
  if (changed) return true;
  let restoring: Observation<any>[] | undefined;
  for (const record of watching) {
    if (record._retiring && record._time !== inputTime(record._input)) record._retiring = false;
    if (deadObservation(record)) {
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
    if (parent && awaitingPreview(parent)) continue;
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
    record._parent = stageRestoration(record, parent);
    (restoring ??= []).push(record);
    changed = true;
  }
  if (restoring)
    for (const record of restoring) calculateCorrection(record._output, record._parent);
  return changed;
}

// After lower readers have replayed, a transferred flight may be the only
// outstanding work. Restore its observation before publishing the input.
function preparePublication(): boolean {
  let changed = false;
  for (const record of dirty) {
    if (
      !watching.has(record) &&
      record._input._pendingValue !== NOT_PENDING &&
      record._override !== NOT_PENDING &&
      record._input._config & CONFIG_HELD &&
      record._output._config & CONFIG_HELD &&
      txOf(record._output) !== txOf(record._input) &&
      blocked(txOf(record._output), true) &&
      !blocked(txOf(record._input))
    ) {
      watching.add(record);
      changed = true;
    }
  }
  return changed;
}

function settleObservations(): void {
  if (previews) {
    for (const record of previews.values()) enqueueSub(record._output);
    previews = undefined;
  }
  for (const record of watching) dirty.add(record);
  for (const record of dirty) {
    if (deadObservation(record)) {
      watching.delete(record);
      continue;
    }
    if (
      record._output._flags & REACTIVE_DISPOSED ||
      (record._input._statusFlags & STATUS_UNINITIALIZED &&
        (!(record._input._statusFlags & STATUS_PENDING) ||
          record._input._pendingValue === NOT_PENDING))
    ) {
      // A staged first answer can be ready but not initialized until the
      // commit below. Keep an existing watch so its pending override retires
      // after that commit, even when the landing compares equal.
      if (
        !(record._output._flags & REACTIVE_DISPOSED) &&
        record._input._pendingValue === NOT_PENDING
      )
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
  _preparePublication: preparePublication,
  _awaitingPreview: awaitingPreview,
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
  kind: ObservationKind<T>,
  select = selectObservation<T>
): Observation<T> {
  const callback = __DEV__ && inEffectCallback;
  if (__DEV__) setEffectCallback(false);
  try {
    return runWithOwner(null, () =>
      initializeObservation(
        createLayerBoundary(
          source,
          select,
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
  // A dormant output can still have untracked consumers of its selected
  // context. Keep its input question until normal retirement restores them;
  // dormancy removes graph demand, not the question's publication obligation.
  if (!(record._output._config & CONFIG_AUTO_DISPOSE) || deadObservation(record))
    watching.delete(record);
  if (!watching.has(record)) {
    record._parent = null;
    record._retiring = false;
  }
  record._override = NOT_PENDING;
  // Drop the cached output frame once ordinary subscriptions disappear.
  // A retained input question above still retires through its original update;
  // other revival initializes a fresh frame from the current input state.
  if (record._output._config & CONFIG_AUTO_DISPOSE) {
    // A discarded first proposal must not satisfy revival's equality check
    // before this output has ever published a value.
    record._output._config &= ~CONFIG_STAGED_ERROR;
    record._output._pendingValue = NOT_PENDING;
    record._output._statusFlags |= STATUS_UNINITIALIZED;
  }
}

export function markObservation(layer: Layer<any>): void {
  const record = layer as Observation<any>;
  if (record._retiring && record._time !== inputTime(record._input)) record._retiring = false;
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
