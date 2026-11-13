import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("nested guess wakes its branch while unguessed descendants and peers retain producer pending", async () => {
  const requests: Array<
    PromiseWithResolvers<{ branch: { guessed: number; unguessed: number }; elsewhere: number }>
  > = [];
  const [epoch, setEpoch] = createSignal(0);
  const [probe, setProbe] = createSignal(0);
  const [store, guess] = createOptimisticStore(
    async () => {
      epoch();
      const request = Promise.withResolvers<{
        branch: { guessed: number; unguessed: number };
        elsewhere: number;
      }>();
      requests.push(request);
      return request.promise;
    },
    { branch: { guessed: 0, unguessed: 0 }, elsewhere: 0 }
  );
  const seen: number[] = [];
  const siblingSeen: number[] = [];
  const peerSeen: number[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => {
        probe();
        return store.branch.guessed;
      },
      value => void seen.push(value)
    );
    createRenderEffect(
      () => {
        probe();
        return store.branch.unguessed;
      },
      value => void siblingSeen.push(value)
    );
    createRenderEffect(
      () => {
        probe();
        return store.elsewhere;
      },
      value => void peerSeen.push(value)
    );
    return dispose;
  });
  try {
    flush();
    requests[0].resolve({ branch: { guessed: 1, unguessed: 1 }, elsewhere: 1 });
    await turn();
    flush();
    expect(seen.at(-1)).toBe(1);
    expect(siblingSeen.at(-1)).toBe(1);
    expect(peerSeen.at(-1)).toBe(1);
    setEpoch(1);
    flush();
    expect(isPending(() => store.branch.unguessed)).toBe(true);
    expect(isPending(() => store.branch)).toBe(true);
    expect(isPending(() => store.elsewhere)).toBe(true);
    guess(d => {
      d.branch.guessed = 999;
    });
    flush();
    expect(store.branch.guessed).toBe(999);
    expect(seen.at(-1)).toBe(999);
    expect(isPending(() => store.branch.unguessed)).toBe(true);
    expect(isPending(() => store.branch)).toBe(true); // The unresolved producer still owns the parent answer.
    expect(isPending(() => store.elsewhere)).toBe(true);
    expect(latest(() => store.branch.guessed)).toBe(999);
    setProbe(1);
    flush();
    expect(isPending(() => store.branch.unguessed)).toBe(true);
    expect(isPending(() => store.elsewhere)).toBe(true);
    expect(siblingSeen.at(-1)).toBe(1);
    expect(peerSeen.at(-1)).toBe(1);
    requests[1].resolve({ branch: { guessed: 2, unguessed: 2 }, elsewhere: 2 });
    await turn();
    flush();
    expect(store.branch.guessed).toBe(2);
    expect(store.branch.unguessed).toBe(2);
  } finally {
    dispose();
  }
});

it("independent nested sibling guesses keep independent action lifetimes", async () => {
  type State = { branch: { a: number; b: number } };
  const requests: Array<PromiseWithResolvers<State>> = [];
  const [epoch, setEpoch] = createSignal(0);
  const [store, guess] = createOptimisticStore(
    async () => {
      epoch();
      const request = Promise.withResolvers<State>();
      requests.push(request);
      return request.promise;
    },
    { branch: { a: 0, b: 0 } }
  );
  const seen: Array<[number, number]> = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => [store.branch.a, store.branch.b] as [number, number],
      pair => void seen.push(pair)
    );
    return dispose;
  });
  try {
    flush();
    requests[0].resolve({ branch: { a: 1, b: 1 } });
    await turn();
    flush();
    setEpoch(1);
    flush();
    const saveA = Promise.withResolvers<void>();
    const saveB = Promise.withResolvers<void>();
    const writeA = action(function* () {
      guess(d => {
        d.branch.a = 999;
      });
      yield saveA.promise;
    });
    const writeB = action(function* () {
      guess(d => {
        d.branch.b = 888;
      });
      yield saveB.promise;
    });
    writeA();
    await turn();
    writeB();
    await turn();
    flush();
    expect(seen.at(-1)).toEqual([999, 888]);
    saveA.resolve();
    await turn();
    flush();
    // A's own lower producer remains pending, so it retains its guess until
    // the producer answers even though the save promise has settled.
    expect(seen.at(-1)).toEqual([999, 888]);
    expect(isPending(() => store.branch.b)).toBe(true);
    requests[1].resolve({ branch: { a: 2, b: 2 } });
    await turn();
    flush();
    expect(seen.at(-1)).toEqual([2, 888]);
    saveB.resolve();
    await turn();
    flush();
    expect(seen.at(-1)).toEqual([2, 2]);
  } finally {
    dispose();
  }
});

it("a reference computed does not join independent sibling actions", async () => {
  const [store, guess] = createOptimisticStore({ branch: { a: 1, b: 1 } });
  const seen: Array<[number, number]> = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => [store.branch.a, store.branch.b] as [number, number],
      pair => void seen.push(pair)
    );
    return dispose;
  });
  try {
    flush();
    const saveA = Promise.withResolvers<void>();
    const saveB = Promise.withResolvers<void>();
    action(function* () {
      guess(d => {
        d.branch.a = 999;
      });
      yield saveA.promise;
    })();
    await turn();
    action(function* () {
      guess(d => {
        d.branch.b = 888;
      });
      yield saveB.promise;
    })();
    await turn();
    flush();
    expect(seen.at(-1)).toEqual([999, 888]);
    saveA.resolve();
    await turn();
    flush();
    expect(seen.at(-1)).toEqual([1, 888]);
    saveB.resolve();
    await turn();
    flush();
    expect(seen.at(-1)).toEqual([1, 1]);
  } finally {
    dispose();
  }
});

it("a third-level existing-key guess wakes its branch without revealing sibling truth", async () => {
  type State = {
    branch: { deep: { guessed: number; sibling: number }; nearby: number };
    elsewhere: number;
  };
  const requests: Array<PromiseWithResolvers<State>> = [];
  const [epoch, setEpoch] = createSignal(0);
  const [probe, setProbe] = createSignal(0);
  const [store, guess] = createOptimisticStore(
    async () => {
      epoch();
      const request = Promise.withResolvers<State>();
      requests.push(request);
      return request.promise;
    },
    { branch: { deep: { guessed: 0, sibling: 0 }, nearby: 0 }, elsewhere: 0 }
  );
  const shown: number[] = [];
  const siblingShown: number[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => {
        probe();
        return store.branch.deep.guessed;
      },
      x => void shown.push(x)
    );
    createRenderEffect(
      () => {
        probe();
        return store.branch.deep.sibling;
      },
      x => void siblingShown.push(x)
    );
    return dispose;
  });
  try {
    flush();
    requests[0].resolve({ branch: { deep: { guessed: 1, sibling: 1 }, nearby: 1 }, elsewhere: 1 });
    await turn();
    flush();
    expect(shown.at(-1)).toBe(1);
    setEpoch(1);
    flush();
    guess(d => {
      d.branch.deep.guessed = 999;
    });
    flush();
    expect(shown.at(-1)).toBe(999);
    expect(isPending(() => store.branch.deep.sibling)).toBe(true);
    expect(isPending(() => store.branch.nearby)).toBe(true);
    expect(isPending(() => store.elsewhere)).toBe(true);
    setProbe(1);
    flush();
    expect(shown.at(-1)).toBe(999);
    expect(siblingShown.at(-1)).toBe(1);
    requests[1].resolve({ branch: { deep: { guessed: 2, sibling: 2 }, nearby: 2 }, elsewhere: 2 });
    await turn();
    flush();
    expect(store.branch.deep.guessed).toBe(2);
  } finally {
    dispose();
  }
});

it("a replaced or null branch discovers its current child before a late guess", async () => {
  type State = { branch: { deep: { n: number } } | null };
  const requests: Array<PromiseWithResolvers<State>> = [];
  const [epoch, setEpoch] = createSignal(0);
  const [store, guess] = createOptimisticStore<State>(
    async () => {
      epoch();
      const request = Promise.withResolvers<State>();
      requests.push(request);
      return request.promise;
    },
    { branch: { deep: { n: 0 } } }
  );
  const shown: Array<number | null> = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.branch?.deep.n ?? null,
      n => void shown.push(n)
    );
    return dispose;
  });
  try {
    flush();
    requests[0].resolve({ branch: { deep: { n: 1 } } });
    await turn();
    flush();
    expect(shown.at(-1)).toBe(1);
    setEpoch(1);
    flush();
    requests[1].resolve({ branch: null });
    await turn();
    flush();
    expect(shown.at(-1)).toBeNull();
    setEpoch(2);
    flush();
    requests[2].resolve({ branch: { deep: { n: 2 } } });
    await turn();
    flush();
    expect(shown.at(-1)).toBe(2);
    setEpoch(3);
    flush();
    guess(d => {
      if (d.branch) d.branch.deep.n = 9;
    });
    flush();
    expect(shown.at(-1)).toBe(9);
    requests[3].resolve({ branch: { deep: { n: 3 } } });
    await turn();
    flush();
    expect(shown.at(-1)).toBe(3);
  } finally {
    dispose();
  }
});

it("the same long-lived reader publishes a second late guess after the first retires", async () => {
  type State = { branch: { n: number } };
  const requests: Array<PromiseWithResolvers<State>> = [];
  const [epoch, setEpoch] = createSignal(0);
  const [store, guess] = createOptimisticStore<State>(
    async () => {
      epoch();
      const request = Promise.withResolvers<State>();
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
  try {
    flush();
    requests[0].resolve({ branch: { n: 0 } });
    await turn();
    flush();
    for (let cycle = 1; cycle <= 2; cycle++) {
      setEpoch(cycle);
      flush();
      guess(d => {
        d.branch.n = cycle + 10;
      });
      flush();
      expect(shown.at(-1)).toBe(cycle + 10);
      requests[cycle].resolve({ branch: { n: cycle } });
      await turn();
      flush();
      expect(shown.at(-1)).toBe(cycle);
    }
  } finally {
    dispose();
  }
});

it("a late reference reader sees the selected child through held correction", async () => {
  type State = { branch: { n: number; other: number } };
  const requests: Array<PromiseWithResolvers<State>> = [];
  const [epoch, setEpoch] = createSignal(0);
  const [store, guess] = createOptimisticStore<State>(
    async () => {
      epoch();
      const request = Promise.withResolvers<State>();
      requests.push(request);
      return request.promise;
    },
    { branch: { n: 0, other: 0 } }
  );
  const shown: number[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.branch.n,
      n => void shown.push(n)
    );
    return dispose;
  });
  let disposeLate: (() => void) | undefined;
  try {
    flush();
    requests[0].resolve({ branch: { n: 1, other: 1 } });
    await turn();
    flush();
    setEpoch(1);
    flush();
    const save = Promise.withResolvers<void>();
    action(function* () {
      guess(d => {
        d.branch.n = 9;
      });
      yield save.promise;
    })();
    await turn();
    flush();
    expect(shown.at(-1)).toBe(9);
    save.resolve();
    await turn();
    flush();
    expect(shown.at(-1)).toBe(9);
    const late: number[] = [];
    disposeLate = createRoot(dispose => {
      createRenderEffect(
        () => store.branch.n,
        n => void late.push(n)
      );
      return dispose;
    });
    flush();
    expect(late.at(-1)).toBe(9);
    expect(isPending(() => store.branch.other)).toBe(true);
    requests[1].resolve({ branch: { n: 2, other: 2 } });
    await turn();
    flush();
    expect(shown.at(-1)).toBe(2);
    expect(late.at(-1)).toBe(2);
  } finally {
    disposeLate?.();
    dispose();
  }
});
