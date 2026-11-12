import { expect, it } from "vitest";
import {
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  mapArray
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("late keyed row leaf guess reaches cached map readers while sibling remains pending", async () => {
  type Row = { id: number; n: number };
  const requests: Array<PromiseWithResolvers<Row[]>> = [];
  const [epoch, setEpoch] = createSignal(0);
  const [probe, setProbe] = createSignal(0);
  const [rows, guess] = createOptimisticStore(
    () => {
      epoch();
      const request = Promise.withResolvers<Row[]>();
      requests.push(request);
      return request.promise;
    },
    [] as Row[],
    { key: "id" }
  );
  const mapped: number[][] = [];
  const direct: number[] = [];
  const sibling: number[] = [];
  const dispose = createRoot(dispose => {
    const rowViews = mapArray(
      () => rows,
      row => () => row.n
    );
    createRenderEffect(
      () => rowViews().map(read => read()),
      v => void mapped.push(v)
    );
    createRenderEffect(
      () => {
        probe();
        return rows[0]?.n;
      },
      v => void direct.push(v)
    );
    createRenderEffect(
      () => {
        probe();
        return rows[1]?.n;
      },
      v => void sibling.push(v)
    );
    return dispose;
  });
  try {
    flush();
    requests[0].resolve([
      { id: 1, n: 1 },
      { id: 2, n: 1 }
    ]);
    await turn();
    flush();
    expect(mapped.at(-1)).toEqual([1, 1]);
    expect(direct.at(-1)).toBe(1);
    expect(sibling.at(-1)).toBe(1);
    setEpoch(1);
    flush();
    guess(d => {
      d[0].n = 9;
    });
    flush();
    expect(mapped.at(-1)).toEqual([9, 1]);
    expect(direct.at(-1)).toBe(9);
    expect(rows[0].n).toBe(9);
    expect(isPending(() => rows[1].n)).toBe(true);
    setProbe(1);
    flush();
    expect(direct.at(-1)).toBe(9);
    expect(sibling.at(-1)).toBe(1);
    const late: number[] = [];
    const disposeLate = createRoot(dispose => {
      createRenderEffect(
        () => rows[0].n,
        v => void late.push(v)
      );
      return dispose;
    });
    flush();
    expect(late.at(-1)).toBe(9);
    requests[1].resolve([
      { id: 1, n: 2 },
      { id: 2, n: 2 }
    ]);
    await turn();
    flush();
    expect(mapped.at(-1)).toEqual([2, 2]);
    disposeLate();
  } finally {
    dispose();
  }
});
