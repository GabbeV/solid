/** Dependency structure for the next layer coordinator, independent of values.
 *
 * The ordinary graph retains old links until publication. A pass only reuses
 * them in order or inserts new links; it never moves an old link. Consequently
 * a dropping/reusing pass already retains its exact committed dependencies.
 * Insertions enter a reusable link journal. Only a park materializes a retained
 * snapshot, which repeated proposals keep until publication. No fields are
 * added to ordinary nodes or links.
 */
import { REACTIVE_SAVED_DEPENDENCIES, NOT_PENDING, STATUS_ERROR, STATUS_UNINITIALIZED } from "../core/constants.js";
import { setDependencyFrameHook } from "../core/graph.js";
import type { Computed, Link, Signal } from "../core/types.js";
import { boundaries } from "./boundary.js";

const saved = new WeakMap<Computed<any>, readonly Signal<any>[]>();
// Reuse the journal's storage across synchronous flushes. Entries are existing
// graph links, not fresh records; removing an entry clears its strong reference.
const inserted: (Link | null)[] = [];
let count = 0;
/** No insertion anywhere means parking cannot create a dependency snapshot. */
export { count as insertedDependencyCount };
function isInserted(edge: Link): boolean {
  for (let i = 0; i < count; i++) if (inserted[i] === edge) return true;
  return false;
}

function forgetInserted(node: Computed<any>): boolean {
  let found = false;
  for (let i = count - 1; i >= 0; i--) {
    if (inserted[i]!._sub !== node) continue;
    inserted[i] = inserted[--count];
    inserted[count] = null;
    found = true;
  }
  return found;
}

function dependencies(node: Computed<any>, prefix = false): Signal<any>[] {
  const result: Signal<any>[] = [];
  if (prefix && node._depsTail === null) return result;
  for (let edge = node._deps; edge; edge = edge._nextDep) {
    if (prefix || !isInserted(edge)) result.push(edge._dep);
    if (prefix && edge === node._depsTail) break;
  }
  return result;
}

// Installed by the optional feature module, before application computations
// run. Installing only on the first guess would miss earlier held branch
// changes. Ordinary-only imports can discard this entire module.
setDependencyFrameHook((node, phase) => {
  if (phase === "park") {
    // Stable dependencies need no insertion scan or journal removal. A
    // previously saved frame still lasts until this node actually publishes.
    let retained = !!(node._flags & REACTIVE_SAVED_DEPENDENCIES), changed = false;
    if (count) {
      if (!retained && !(node._statusFlags & STATUS_UNINITIALIZED)) {
        for (let i = 0; i < count; i++) {
          if (inserted[i]!._sub !== node) continue;
          saved.set(node, dependencies(node));
          node._flags |= REACTIVE_SAVED_DEPENDENCIES;
          retained = true;
          break;
        }
      }
      changed = forgetInserted(node);
    }
    return changed || retained || !!(node._depsTail ? node._depsTail._nextDep : node._deps);
  } else if (phase === "insert") {
    inserted[count++] = node._depsTail;
  } else {
    if (count) forgetInserted(node);
    // Parking and errors allocate the extension and never remove it. A node
    // without one cannot have a saved frame, even if this synchronous pass
    // inserted dependency links that needed removing from the journal above.
    if (!node._x) return;
    if (phase === "commit" && node._statusFlags & STATUS_ERROR) {
      // Recovery subscriptions are not reads of the published error frame.
      saved.set(node, dependencies(node, true));
      node._flags |= REACTIVE_SAVED_DEPENDENCIES;
    } else if (node._flags & REACTIVE_SAVED_DEPENDENCIES) {
      saved.delete(node);
      node._flags &= ~REACTIVE_SAVED_DEPENDENCIES;
    }
  }
});

/** Values and dependencies advance at the same publication boundary. The
 * caller handles never-published computations separately (there is no frame).
 * No copy of a settled dependency list is retained. */
export function* committedDependencies(node: Computed<any>): Iterable<Signal<any>> {
  if (node._statusFlags & STATUS_UNINITIALIZED) return;
  const snapshot = node._flags & REACTIVE_SAVED_DEPENDENCIES ? saved.get(node) : undefined;
  if (snapshot) yield* snapshot;
  else
    for (let edge = node._deps; edge; edge = edge._nextDep) if (!isInserted(edge)) yield edge._dep;
}

/** Cold-path context calculation for pending optimistic origins. Inactive
 * boundaries are transparent; speculative branch reads cannot choose their
 * own context. The recursion stack is per path, so a shared ancestor reached
 * by a longer path still contributes its complete depth. */
export function layerPosition(source: Signal<any>, path?: Set<Signal<any>>): number {
  if (typeof (source as Computed<any>)._fn !== "function") return 0;
  const boundary = boundaries.get(source);
  const node = source as Computed<any>;
  // A plain producer with no published dependencies cannot contribute a
  // layer. Check before allocating a recursion stack, including for leaves
  // reached by an existing walk. Saved frames and lazy boundaries are not
  // necessarily represented by the producer's current dependency list.
  if (!boundary && (node._statusFlags & STATUS_UNINITIALIZED ||
      (node._deps === null && !(node._flags & REACTIVE_SAVED_DEPENDENCIES)))) return 0;
  path ??= new Set<Signal<any>>();
  if (path.has(source)) return 0;
  path.add(source);
  try {
    if (boundary)
      return boundary._override === NOT_PENDING
        ? layerPosition(boundary._input, path)
        : (boundary._position ?? 1 + layerPosition(boundary._input, path));
    let position = 0;
    const snapshot = node._flags & REACTIVE_SAVED_DEPENDENCIES ? saved.get(node) : undefined;
    if (snapshot) {
      for (const dependency of snapshot)
        position = Math.max(position, layerPosition(dependency, path));
    } else {
      for (let edge = node._deps; edge; edge = edge._nextDep)
        if (!isInserted(edge)) position = Math.max(position, layerPosition(edge._dep, path));
    }
    return position;
  } finally {
    path.delete(source);
  }
}
