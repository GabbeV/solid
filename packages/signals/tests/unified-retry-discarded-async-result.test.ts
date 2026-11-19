import { expect, it } from "vitest";
import { runInNewContext } from "node:vm";
import {
  action,
  createErrorBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  getOwner,
  latest,
  NotReadyError
} from "../src/index.js";
import { getObserver } from "../src/core/owner.js";
const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const protocol of ["native", "cross-realm", "custom", "suspending-probe"] as const)
  for (const shape of ["local", "child"] as const)
    it(`discarded ${protocol} results are cleaned up during a ${shape} context retry`, async () => {
      const finish = Promise.withResolvers<void>();
      const error = new Error("abandoned result");
      const probes: unknown[] = [];
      let reject!: (reason: unknown) => void;
      let abandoned: any;
      if (protocol === "native") {
        const deferred = Promise.withResolvers<never>();
        abandoned = deferred.promise;
        reject = deferred.reject;
      } else if (protocol === "cross-realm") {
        const deferred = runInNewContext(
          "(() => { let reject; const promise = new Promise((_, r) => reject = r); return { promise, reject }; })()"
        );
        abandoned = deferred.promise;
        reject = deferred.reject;
      } else if (protocol === "suspending-probe") {
        abandoned = {
          get then() {
            probes.push([getOwner() === null, getObserver() === null]);
            throw new NotReadyError(null);
          }
        };
        reject = () => {};
      } else {
        const handlers: ((reason: unknown) => unknown)[] = [];
        abandoned = {
          get then() {
            probes.push([getOwner() === null, getObserver() === null]);
            return (_resolve: unknown, rejected: (reason: unknown) => unknown) =>
              handlers.push(rejected);
          }
        };
        reject = reason => handlers.forEach(handler => handler(reason));
      }
      let caught = 0,
        shown: unknown;
      const errors: unknown[] = [];
      const app = createRoot(dispose => {
        const [id, setId] = createSignal(0);
        const [visible, setVisible] = createSignal(false);
        createRenderEffect(
          () => latest(id),
          () => {}
        );
        const page = createMemo(() => {
          if (!visible()) return -1;
          const captured = id();
          const calculate = () => {
            id();
            try {
              latest(id);
              return captured;
            } catch (suspension) {
              if (!(suspension instanceof NotReadyError)) throw suspension;
              caught++;
              return abandoned;
            }
          };
          return shape === "local" ? calculate() : createMemo(calculate);
        });
        const guarded = createErrorBoundary(
          () => {
            const value = page();
            return typeof value === "function" ? value() : value;
          },
          problem => {
            errors.push(problem());
            return "error";
          }
        );
        createRenderEffect(guarded, value => {
          shown = value;
        });
        return { dispose, setId, setVisible };
      });
      flush();
      const running = action(function* () {
        app.setId(1);
        yield finish.promise;
      })();
      try {
        await turn();
        app.setVisible(true);
        await turn();
        expect(caught).toBeGreaterThan(0);
        expect(errors).toEqual([]);
        expect(shown).toBe(0);
        if (protocol === "custom" || protocol === "suspending-probe") {
          expect(probes.length).toBeGreaterThan(0);
          expect(probes).toEqual(probes.map(() => [true, true]));
        }
        reject(error);
        await turn();
        expect(errors).toEqual([]);
        expect(shown).toBe(0);
        finish.resolve();
        await running;
        await turn();
        expect(errors).toEqual([]);
        expect(shown).toBe(1);
      } finally {
        finish.resolve();
        await running;
        app.dispose();
        await turn();
      }
    });

it("a live thenable protocol error still reaches its error boundary", () => {
  const original = new Error("live protocol");
  const seen: unknown[] = [];
  const dispose = createRoot(dispose => {
    const value = createMemo(() => ({
      get then(): unknown {
        throw original;
      }
    }));
    const guarded = createErrorBoundary(value, error => {
      seen.push(error());
      return "error";
    });
    createRenderEffect(guarded, () => {});
    return dispose;
  });
  try {
    flush();
    expect(seen.map(error => (error as any)?.cause ?? error)).toEqual([original]);
  } finally {
    dispose();
    flush();
  }
});
