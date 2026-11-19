import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRoot,
  createRenderEffect,
  flush,
  refresh
} from "../src/index.js";
const turn = async () => {
  await new Promise(r => setTimeout(r, 0));
  flush();
};
it("a selected row accessor keeps its proxy receiver after an input landing", async () => {
  const row = (value: number) => ({
    value,
    get doubled() {
      return this.value * 2;
    }
  });
  const requests: ReturnType<typeof Promise.withResolvers<{ row: ReturnType<typeof row> }>>[] = [];
  const aEnd = Promise.withResolvers<void>(),
    bEnd = Promise.withResolvers<void>();
  const shown: number[] = [];
  const [store, set, dispose] = createRoot(dispose => {
    const [store, set] = createOptimisticStore(
      () => {
        const r = Promise.withResolvers<{ row: ReturnType<typeof row> }>();
        requests.push(r);
        return r.promise;
      },
      { row: row(0) }
    );
    createRenderEffect(
      () => store.row.doubled,
      v => void shown.push(v)
    );
    return [store, set, dispose] as const;
  });
  let a: Promise<unknown> | undefined, b: Promise<unknown> | undefined;
  try {
    flush();
    requests[0].resolve({ row: row(0) });
    await turn();
    a = action(function* () {
      set(d => {
        d.row = row(1);
      });
      yield aEnd.promise;
    })();
    flush();
    expect(shown.at(-1)).toBe(2);
    refresh(store);
    flush();
    requests[1].resolve({ row: row(9) });
    await turn();
    expect(shown.at(-1)).toBe(2);
    b = action(function* () {
      set(d => {
        d.row.value = 3;
      });
      yield bEnd.promise;
    })();
    flush();
    expect(shown.at(-1)).toBe(6);
    expect(store.row.doubled).toBe(6);
  } finally {
    for (const r of requests) r.resolve({ row: row(9) });
    aEnd.resolve();
    bEnd.resolve();
    await Promise.all([a, b]);
    await turn();
    dispose();
    flush();
  }
});
