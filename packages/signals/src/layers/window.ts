/** Callback observations compose by reading outputs through the outer window. */
import {
  context,
  prepareComputed,
  read,
  setVerdict,
  snapshotCaptureActive,
  verdict
} from "../core/core.js";
import { CONFIG_IN_SNAPSHOT_SCOPE, STATUS_ERROR } from "../core/constants.js";
import { NotReadyError } from "../core/error.js";
import { forgetThrownRead } from "../core/dev.js";
import { GlobalQueue } from "../core/scheduler.js";
import { RETRY } from "./boundary.js";
import type { Computed, Root, Signal } from "../core/types.js";

type WindowRead = (source: Signal<any>, window: ReadWindow) => unknown;
type ReadWindow = {
  owner: Computed<any> | null;
  parent: ReadWindow | null;
  previous: typeof verdict;
  read: WindowRead;
  found: boolean;
  collect: boolean;
};
let current: ReadWindow | null = null;

/** A hydration claim observes the captured frame, including its readiness.
 * Keep this choice on observation reads: the source-owned output is shared
 * with live readers outside the claim and must not inherit its snapshot. */
export function observesSnapshot(source: Signal<any>): boolean {
  if (!snapshotCaptureActive) return false;
  const reader = (context as Root)?._root
    ? (context as Root)._parentComputed
    : (context as Computed<any> | null);
  if (!reader || !(reader._config & CONFIG_IN_SNAPSHOT_SCOPE)) return false;
  const input = source as Computed<any>;
  if (typeof input._fn === "function") prepareComputed(input, false);
  return source._x?._snapshotValue !== undefined && !(input._statusFlags & STATUS_ERROR);
}

// An untracked store probe may encounter a declared change before that
// property has a subscription node. The active pending window owns it.
GlobalQueue._witnessMark = () => {
  if (current?.collect) current.found = true;
};

function dispatch(source: Signal<any>, reader: Computed<any> | null): unknown {
  const window = current!;
  current = window.parent;
  setVerdict(reader === window.owner ? window.previous : null);
  try {
    // A computation created or pulled inside a window still owns its reads.
    return reader === window.owner ? window.read(source, window) : read(source);
  } finally {
    current = window;
    setVerdict(dispatch);
  }
}

export function withReadWindow<T>(fn: () => T, observe: WindowRead): T;
export function withReadWindow(fn: () => unknown, observe: WindowRead, collect: true): boolean;
export function withReadWindow<T>(fn: () => T, observe: WindowRead, collect = false): T | boolean {
  const window: ReadWindow = {
    owner: (context as Root)?._root
      ? (context as Root)._parentComputed
      : (context as Computed<any> | null),
    parent: current,
    previous: verdict,
    read: observe,
    found: false,
    collect
  };
  current = window;
  setVerdict(dispatch);
  try {
    const value = fn();
    return collect ? window.found : value;
  } catch (error) {
    if (
      error === RETRY ||
      !collect ||
      (error instanceof NotReadyError && !window.found && context !== null)
    )
      throw error;
    if (__DEV__) forgetThrownRead();
    return window.found;
  } finally {
    current = window.parent;
    setVerdict(window.previous);
  }
}
