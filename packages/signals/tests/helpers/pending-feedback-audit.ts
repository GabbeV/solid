// Experimental diagnostic predicate, NOT a runtime error policy.
// Follow current value dependencies, treating explicit layer outputs as cuts.
// Deliberately conservative: do not infer passage through inactive boundaries.
import type { Computed, Signal } from "../../src/core/types.js";
import { boundaries } from "../../src/layers/boundary.js";

export function ordinaryValuePath(
  reader: Signal<any>,
  input: Signal<any>,
  seen = new Set<Signal<any>>()
): boolean {
  if (reader === input) return true;
  if (seen.has(reader) || boundaries.get(reader)) return false;
  seen.add(reader);
  const node = reader as Computed<any>;
  for (let edge = node._deps; edge; edge = edge._nextDep) {
    if (edge._gen === node._depGen && ordinaryValuePath(edge._dep, input, seen)) return true;
  }
  return false;
}
