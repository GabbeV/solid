import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  flush,
  refresh
} from "../src/index.js";

const settle = async () => {
  await Promise.resolve();
  await Promise.resolve();
  await Promise.resolve();
  flush();
};

for (const mode of ["push-true", "push-false-then-write", "push-true-then-equal-write"] as const) {
  it(mode, async () => {
    type Row = { id: number; pending: boolean };
    let server: Row[] = [];
    const fetches: Array<() => void> = [];
    const gate = Promise.withResolvers<void>();
    const frames: Array<Array<[number, boolean]>> = [];
    const [rows, setRows, dispose] = createRoot(dispose => {
      const [rows, setRows] = createOptimisticStore(
        () =>
          new Promise<Row[]>(resolve => {
            fetches.push(() => resolve(structuredClone(server)));
          }),
        [] as Row[],
        { key: "id" }
      );
      createRenderEffect(
        () => rows.map(row => [row.id, row.pending] as [number, boolean]),
        value => {
          frames.push(value);
        }
      );
      return [rows, setRows, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      fetches.shift()!();
      await settle();
      running = action(function* () {
        setRows(d => {
          d.push({ id: 1, pending: mode !== "push-false-then-write" });
          if (mode !== "push-true") d[0].pending = true;
        });
        yield gate.promise;
      })();
      flush();
      const ref = rows[0];
      const before = rows[0].pending;
      server = [{ id: 1, pending: false }];
      refresh(rows);
      flush();
      fetches.shift()!();
      await settle();
      await settle();
      const during = rows[0].pending;
      const same = rows[0] === ref;
      gate.resolve();
      await running;
      await settle();
      const after = rows[0].pending;
      expect([before, during, after, same]).toEqual([true, true, false, true]);
      expect(frames[0]).toEqual([]);
      for (const frame of frames.slice(1)) expect(frame).toHaveLength(1);
    } finally {
      gate.resolve();
      await running;
      dispose();
      flush();
    }
  });
}
