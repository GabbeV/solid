import type { Computed, Signal } from "../core/types.js";
import type { Layer } from "./coordination.js";

// A context change stops the current calculation before any later reads.
// Observation windows must not interpret this control signal as a user error.
export const RETRY = /* @__PURE__ */ Symbol("retry layer calculation");

// The registry is separate from coordination so refreshing an ordinary memo
// does not require the optimistic engine in the application bundle.
export const boundaries = new WeakMap<Signal<any>, Layer<any>>();

/** Refresh crosses exactly one optimistic boundary to its input callback. */
export function refreshInput(source: Computed<any>): Computed<any> {
  const boundary = boundaries.get(source);
  boundary?._refreshInput?.(boundary);
  return boundary?._inputStatus ? boundary._input : source;
}
