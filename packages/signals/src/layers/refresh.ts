import { computed, markRefresh, read } from "../core/core.js";
import { NotReadyError, unwrapStatusError } from "../core/error.js";
import { emitDiagnostic } from "../core/dev.js";
import { enqueueSub } from "../core/heap.js";
import { createRoot, getOwner } from "../core/owner.js";
import {
  $REFRESH,
  CONFIG_FRESH_READ,
  CONFIG_HELD,
  CONFIG_REDERIVE,
  REACTIVE_CHECK,
  REACTIVE_DIRTY,
  REACTIVE_DISPOSED,
  STATUS_PENDING
} from "../core/constants.js";
import { flushTransaction, resolveTx, schedule, staleReader, txOf } from "../core/scheduler.js";
import type { Refreshable } from "../core/constants.js";
import type { Computed } from "../core/types.js";
import { refreshInput } from "./boundary.js";

/** Re-ask this computation, or an optimistic boundary's immediate input.
 * A caller may receive its own action's staged answer before DOM publication.
 */
export function refresh<T>(target: Refreshable<T>): Promise<T extends (...args: any) => infer V ? V : T> {
  const output = (target as any)?.[$REFRESH] as Computed<any> | undefined;
  if (!output) {
    if (__DEV__) {
      const message =
        "[INVALID_REFRESH_TARGET] refresh() expects a Solid source accessor or refreshable store. " +
        "Pass the original source target, not a wrapper function or derived property read.";
      emitDiagnostic({ code: "INVALID_REFRESH_TARGET", kind: "write", severity: "error", message });
      throw new Error(message);
    }
    return Promise.resolve(undefined as any);
  }
  const source = refreshInput(output);
  markRefresh(source);
  const own = flushTransaction;
  const promise = new Promise<any>((resolve, reject) => {
    // Coalesce same-tick invalidations before the waiter first pulls its source.
    queueMicrotask(() => {
      createRoot(dispose => {
        let generation = 0;
        computed(
          () => {
            const current = ++generation;
            const waiter = getOwner() as Computed<any>;
            let value: T | undefined,
              error: unknown,
              failed = false;
            try {
              value = read(source);
            } catch (caught) {
              if (caught instanceof NotReadyError) throw caught;
              failed = true;
              error = unwrapStatusError(caught);
            }
            queueMicrotask(() => {
              if (current !== generation) return;
              if (!(source._flags & REACTIVE_DISPOSED) && source._flags & (REACTIVE_DIRTY | REACTIVE_CHECK)) {
                // An equal synchronous replacement may not notify readers.
                // Explicitly retry when invalidated between read and delivery.
                enqueueSub(waiter);
                schedule();
                return;
              }
              if (!(source._flags & REACTIVE_DISPOSED) && source._statusFlags & STATUS_PENDING) return;
              // Check after the compute pass has accepted its dependencies
              // and joined their updates. Registering inside the pass would
              // repeatedly requeue this waiter during pre-publication replay.
              if (waiter._config & CONFIG_HELD) {
                const holder = txOf(waiter);
                if (!own || resolveTx(own) !== holder) {
                  staleReader(waiter, holder);
                  return;
                }
              }
              dispose();
              if (failed) reject(error);
              else resolve(typeof target === "function" ? value : target);
            });
          },
          { _extraConfig: CONFIG_FRESH_READ }
        )._config |= CONFIG_REDERIVE;
      });
    });
  });
  promise.catch(() => {});
  return promise;
}
