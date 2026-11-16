import { expect, it } from "vitest";
import {
  action,
  affects,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  flush,
  isPending
} from "../src/index.js";

for (const chained of [false, true])
  it(`marks reach an already-observed property memo (chained=${chained})`, async () => {
    const gate = Promise.withResolvers<void>();
    const app = createRoot(dispose => {
      const [source] = createOptimisticStore({ value: 1 });
      const [alias] = createOptimisticStore(source);
      const value = createMemo(() => (chained ? alias : source).value);
      const seen: boolean[] = [];
      createRenderEffect(
        () => isPending(value),
        pending => {
          seen.push(pending);
        }
      );
      return { dispose, source, seen };
    });
    flush();
    const running = action(function* () {
      affects(app.source, "value");
      yield gate.promise;
    })();
    try {
      flush();
      expect(app.seen.at(-1)).toBe(true);
      gate.resolve();
      await running;
      flush();
      expect(app.seen.at(-1)).toBe(false);
    } finally {
      gate.resolve();
      await running;
      app.dispose();
      flush();
    }
  });

for (const read of ["value", "keys", "presence"] as const)
  it(`a selected child inherits its source mark and retains it after a child mark ends (${read})`, async () => {
    const parentGate = Promise.withResolvers<void>();
    const childGate = Promise.withResolvers<void>();
    const app = createRoot(dispose => {
      const [rows, guess] = createOptimisticStore<{ value: number }[]>([]);
      return { rows, guess, dispose };
    });
    const parent = action(function* () {
      affects(app.rows);
      app.guess(rows => {
        rows.push({ value: 1 });
      });
      yield parentGate.promise;
    })();
    flush();
    const row = app.rows[0];
    const seen: boolean[] = [];
    const disposeReader = createRoot(dispose => {
      const value = createMemo(() =>
        read === "value"
          ? row.value
          : read === "keys"
            ? Object.keys(row).join()
            : Object.hasOwn(row, "value")
      );
      createRenderEffect(
        () => isPending(value),
        pending => {
          seen.push(pending);
        }
      );
      return dispose;
    });
    let child: Promise<unknown> | undefined;
    try {
      flush();
      expect(seen).toEqual([true]);
      child = action(function* () {
        affects(row);
        yield childGate.promise;
      })();
      flush();
      expect(seen).toEqual([true]);
      childGate.resolve();
      await child;
      flush();
      expect(seen).toEqual([true]);
      parentGate.resolve();
      await parent;
      flush();
      expect(seen).toEqual([true, false]);
    } finally {
      childGate.resolve();
      await child;
      disposeReader();
      parentGate.resolve();
      await parent;
      app.dispose();
      flush();
    }
  });
