import { expect, it } from "vitest";
import {
  action, createMemo, createOptimistic, createRenderEffect, createRoot,
  createSignal, flush, onCleanup
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const schedule of [false, true]) for (const callback of [false, true]) {
  it(`a settled-input correction still waits for async consequences (scheduled=${schedule}, callback=${callback})`, async () => {
    const end = Promise.withResolvers<void>();
    const requests: Array<{ value: number; resolve: (value: number) => void }> = [];
    const fetchDetails = (value: number) => new Promise<number>(resolve => {
      requests.push({ value, resolve });
    });
    const cleaned: number[] = [];
    let view!: () => number, guess!: (value: number) => number;
    let tick!: () => number, setTick!: (value: number) => number;
    let shown: readonly number[] = [], sibling: readonly number[] = [], late: readonly number[] = [];
    let disposeLate = () => {};
    const dispose = createRoot(dispose => {
      [view, guess] = callback ? createOptimistic(() => 0) : createOptimistic(0);
      [tick, setTick] = createSignal(0);
      const details = createMemo(() => fetchDetails(view()));
      const owned = createMemo(() => {
        const value = view();
        onCleanup(() => cleaned.push(value));
        return value;
      });
      createRenderEffect(() => [view(), details(), owned()], value => { shown = value; }, { schedule });
      createRenderEffect(() => [view(), tick()], value => { sibling = value; }, { schedule });
      return dispose;
    });
    flush();
    requests[0].resolve(0);
    await turn();
    expect(shown).toEqual([0, 0, 0]);
    const running = action(function* () { guess(1); yield end.promise; })();
    try {
      flush();
      expect(requests.map(request => request.value)).toEqual([0, 1]);
      requests[1].resolve(10);
      await turn();
      expect(shown).toEqual([1, 10, 1]);
      expect(cleaned).not.toContain(1);
      end.resolve();
      await running;
      flush();
      expect(requests.map(request => request.value)).toEqual([0, 1, 0]);
      expect(shown).toEqual([1, 10, 1]);
      setTick(1);
      flush();
      disposeLate = createRoot(dispose => {
        createRenderEffect(() => [view(), tick()], value => { late = value; }, { schedule });
        return dispose;
      });
      flush();
      expect(sibling).toEqual([1, 1]);
      expect(late).toEqual([1, 1]);
      expect(cleaned).not.toContain(1);
      requests[2].resolve(0);
      await turn();
      expect(shown).toEqual([0, 0, 0]);
      expect(sibling).toEqual([0, 1]);
      expect(late).toEqual([0, 1]);
      expect(cleaned).toContain(1);
    } finally {
      end.resolve();
      await running;
      disposeLate();
      dispose();
      for (const request of requests) request.resolve(request.value * 10);
      flush();
    }
  });
}
