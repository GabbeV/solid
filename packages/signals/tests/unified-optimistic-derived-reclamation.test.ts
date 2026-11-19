import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
import { $TARGET } from "../src/store/types.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("derived nested slot inputs release their producer and discovery subscriptions across 24 flights", async () => {
  const requests: Array<PromiseWithResolvers<{ branch: { n: number } }>> = [];
  const [epoch, setEpoch] = createSignal(0);
  const [store, guess] = createOptimisticStore(
    async () => {
      epoch();
      const request = Promise.withResolvers<{ branch: { n: number } }>();
      requests.push(request);
      return request.promise;
    },
    { branch: { n: 0 } }
  );
  flush();
  requests[0].resolve({ branch: { n: 0 } });
  await turn();
  flush();
  for (let cycle = 0; cycle < 24; cycle++) {
    const shown: number[] = [];
    const dispose = createRoot(dispose => {
      createRenderEffect(
        () => store.branch.n,
        v => void shown.push(v)
      );
      return dispose;
    });
    flush();
    expect(shown.at(-1)).toBe(cycle);
    const root = (store as any)[$TARGET];
    const child = (store.branch as any)[$TARGET];
    const parentNode = root.n.branch;
    const leafNode = child.n.n;
    setEpoch(cycle + 1);
    flush();
    guess(d => {
      d.branch.n = cycle + 100;
    });
    flush();
    expect(shown.at(-1)).toBe(cycle + 100);
    dispose();
    flush();
    expect(store.branch.n).toBe(cycle + 100);
    requests[cycle + 1].resolve({ branch: { n: cycle + 1 } });
    await turn();
    flush();
    expect(store.branch.n).toBe(cycle + 1);
    flush();
    expect(parentNode._subs).toBeNull();
    expect(leafNode._subs).toBeNull();
    expect(root.nc).toBe(0);
    expect(child.nc).toBe(0);
    expect(child.k).toBeNull();
    expect(root._fam.node._subs).toBeNull();
    guess(d => {
      d.branch.n = cycle + 900;
    });
    flush();
    expect(store.branch.n).toBe(cycle + 1);
  }
});

it("a late reader retains the held correction after the first reader disposes", async () => {
  const requests: Array<PromiseWithResolvers<{ branch: { n: number } }>> = [];
  const [epoch, setEpoch] = createSignal(0);
  const [store, guess] = createOptimisticStore(
    async () => {
      epoch();
      const request = Promise.withResolvers<{ branch: { n: number } }>();
      requests.push(request);
      return request.promise;
    },
    { branch: { n: 0 } }
  );
  const shown: number[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.branch.n,
      n => void shown.push(n)
    );
    return dispose;
  });
  flush();
  requests[0].resolve({ branch: { n: 1 } });
  await turn();
  flush();
  setEpoch(1);
  flush();
  const gate = Promise.withResolvers<void>();
  const running = action(function* () {
    guess(d => {
      d.branch.n = 9;
    });
    yield gate.promise;
  })();
  await turn();
  flush();
  expect(shown.at(-1)).toBe(9);
  gate.resolve();
  await turn();
  flush();
  dispose();
  flush();
  const late: number[] = [];
  const disposeLate = createRoot(dispose => {
    createRenderEffect(
      () => store.branch.n,
      n => void late.push(n)
    );
    return dispose;
  });
  try {
    flush();
    expect(late.at(-1)).toBe(9);
    requests[1].resolve({ branch: { n: 2 } });
    await turn();
    flush();
    await running;
    expect(late.at(-1)).toBe(2);
  } finally {
    disposeLate();
    flush();
  }
});
