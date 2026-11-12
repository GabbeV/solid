import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
it("object-born companion consumes pending producer after becoming primitive", async () => {
  type State = { value: { n: number } | number };
  const requests: Array<PromiseWithResolvers<State>> = [];
  const [epoch, setEpoch] = createSignal(0);
  const [store, guess] = createOptimisticStore<State>(
    async () => {
      epoch();
      const r = Promise.withResolvers<State>();
      requests.push(r);
      return r.promise;
    },
    { value: { n: 0 } }
  );
  const shown: unknown[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.value,
      v => void shown.push(v)
    );
    return dispose;
  });
  try {
    flush();
    requests[0].resolve({ value: 1 });
    await turn();
    flush();
    expect(shown.at(-1)).toBe(1);
    setEpoch(1);
    flush();
    guess(d => {
      d.value = 9;
    });
    flush();
    expect(shown.at(-1)).toBe(9);
    await turn();
    flush();
    expect(shown.at(-1)).toBe(9);
    requests[1].resolve({ value: 2 });
    await turn();
    flush();
    expect(shown.at(-1)).toBe(2);
  } finally {
    dispose();
  }
});

it("object-born companion holds its correction for a producer started during the guess", async () => {
  type State = { value: { n: number } | number };
  const requests: Array<PromiseWithResolvers<State>> = [];
  const [epoch, setEpoch] = createSignal(0);
  const [store, guess] = createOptimisticStore<State>(
    async () => {
      epoch();
      const r = Promise.withResolvers<State>();
      requests.push(r);
      return r.promise;
    },
    { value: { n: 0 } }
  );
  const shown: unknown[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.value,
      v => void shown.push(v)
    );
    return dispose;
  });
  try {
    flush();
    requests[0].resolve({ value: 1 });
    await turn();
    flush();
    const save = Promise.withResolvers<void>();
    const run = action(function* () {
      guess(d => {
        d.value = 9;
      });
      yield save.promise;
    })();
    await turn();
    flush();
    expect(shown.at(-1)).toBe(9);
    setEpoch(1);
    flush();
    save.resolve();
    await turn();
    flush();
    expect(shown.at(-1)).toBe(9);
    requests[1].resolve({ value: 2 });
    await turn();
    flush();
    await run;
    expect(shown.at(-1)).toBe(2);
  } finally {
    dispose();
  }
});
