import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  deep,
  flush
} from "../src/index.js";
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
for (const kind of ["presence", "keys", "descriptor", "deep"] as const) {
  it(`derived ${kind} correction waits for its producer`, async () => {
    type State = { value: number; added?: number };
    const requests: Array<PromiseWithResolvers<State>> = [];
    const [epoch, setEpoch] = createSignal(0);
    const [store, guess] = createOptimisticStore<State>(
      async () => {
        epoch();
        const request = Promise.withResolvers<State>();
        requests.push(request);
        return request.promise;
      },
      { value: 0 }
    );
    const shown: unknown[] = [];
    const read = () =>
      kind === "presence"
        ? "added" in store
        : kind === "keys"
          ? Object.keys(store).join(",")
          : kind === "descriptor"
            ? Object.getOwnPropertyDescriptor(store, "added")?.value
            : JSON.stringify(deep(store));
    const dispose = createRoot(dispose => {
      createRenderEffect(read, value => void shown.push(value));
      return dispose;
    });
    try {
      flush();
      requests[0].resolve({ value: 1 });
      await turn();
      flush();
      setEpoch(1);
      flush();
      const save = Promise.withResolvers<void>();
      const running = action(function* () {
        guess(d => {
          d.added = 9;
        });
        yield save.promise;
      })();
      await turn();
      flush();
      const selected =
        kind === "presence"
          ? true
          : kind === "keys"
            ? "value,added"
            : kind === "descriptor"
              ? 9
              : '{"value":1,"added":9}';
      expect(shown.at(-1)).toEqual(selected);
      save.resolve();
      await turn();
      flush();
      expect(shown.at(-1)).toEqual(selected);
      requests[1].resolve({ value: 2 });
      await turn();
      flush();
      await running;
      expect(shown.at(-1)).toEqual(
        kind === "presence"
          ? false
          : kind === "keys"
            ? "value"
            : kind === "descriptor"
              ? undefined
              : '{"value":2}'
      );
    } finally {
      dispose();
    }
  });
}
it("derived explicit length correction waits for its producer", async () => {
  const requests: Array<PromiseWithResolvers<number[]>> = [];
  const [epoch, setEpoch] = createSignal(0);
  const [store, guess] = createOptimisticStore(async () => {
    epoch();
    const request = Promise.withResolvers<number[]>();
    requests.push(request);
    return request.promise;
  }, [0, 0]);
  const shown: number[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.length,
      value => void shown.push(value)
    );
    return dispose;
  });
  try {
    flush();
    requests[0].resolve([1, 1]);
    await turn();
    flush();
    setEpoch(1);
    flush();
    const save = Promise.withResolvers<void>();
    const running = action(function* () {
      guess(d => {
        d.length = 1;
      });
      yield save.promise;
    })();
    await turn();
    flush();
    expect(shown.at(-1)).toBe(1);
    save.resolve();
    await turn();
    flush();
    expect(shown.at(-1)).toBe(1);
    requests[1].resolve([2, 2, 2]);
    await turn();
    flush();
    await running;
    expect(shown.at(-1)).toBe(3);
  } finally {
    dispose();
  }
});
