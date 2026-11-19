import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  refresh
} from "../src/index.js";
const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};
function setup() {
  const requests: ReturnType<typeof Promise.withResolvers<{ row: { data: number } }>>[] = [];
  const [question, setQuestion] = createSignal(0);
  const [ordinary, setOrdinary] = createSignal(0);
  const [branch, setBranch] = createSignal(true);
  const shown: number[] = [],
    verdicts: boolean[] = [];
  const [state, write, combined, dispose] = createRoot(dispose => {
    const [state, write] = createOptimisticStore(
      async draft => {
        question();
        const request = Promise.withResolvers<{ row: { data: number } }>();
        requests.push(request);
        draft.row = (await request.promise).row;
      },
      { row: { data: 0 } }
    );
    const combined = createMemo(() => state.row.data + ordinary());
    createRenderEffect(combined, value => {
      shown.push(value);
    });
    createRenderEffect(
      () => isPending(() => (branch() ? state.row.data : ordinary())),
      value => {
        verdicts.push(value);
      }
    );
    return [state, write, combined, dispose] as const;
  });
  return {
    state,
    write,
    combined,
    ordinary,
    setOrdinary,
    setQuestion,
    setBranch,
    requests,
    shown,
    verdicts,
    dispose
  };
}
it("a quiet producer preserves an independent held write and its consumed combined answer", async () => {
  const h = setup(),
    end = Promise.withResolvers<void>();
  let running: Promise<unknown> | undefined;
  try {
    flush();
    h.requests[0].resolve({ row: { data: 10 } });
    await turn();
    expect(h.combined()).toBe(10);
    void refresh(h.state);
    flush();
    expect(h.requests).toHaveLength(2);
    expect(isPending(() => h.state.row.data)).toBe(false);
    running = action(function* () {
      h.setOrdinary(1);
      yield end.promise;
    })();
    flush();
    expect(isPending(h.ordinary)).toBe(true);
    expect(isPending(() => h.state.row.data + h.ordinary())).toBe(true);
    // This pass suspends before consuming ordinary(); its old dependency is not a new answer.
    expect(isPending(h.combined)).toBe(false);
    h.requests[1].resolve({ row: { data: 10 } });
    await turn();
    expect(isPending(h.combined)).toBe(true);
    end.resolve();
    await running;
    await turn();
    expect(h.shown.at(-1)).toBe(11);
    expect(isPending(h.combined)).toBe(false);
    expect(h.requests).toHaveLength(2);
  } finally {
    for (const request of h.requests) request.resolve({ row: { data: 10 } });
    end.resolve();
    await running;
    h.dispose();
    flush();
  }
});
it("a branch switch drops a quiet input before observing an ordinary held write", async () => {
  const h = setup(),
    end = Promise.withResolvers<void>();
  let running: Promise<unknown> | undefined;
  try {
    flush();
    h.requests[0].resolve({ row: { data: 10 } });
    await turn();
    void refresh(h.state);
    flush();
    expect(h.verdicts.at(-1)).toBe(false);
    running = action(function* () {
      h.setOrdinary(1);
      yield end.promise;
    })();
    h.setBranch(false);
    flush();
    expect(h.verdicts.at(-1)).toBe(true);
    h.requests[1].resolve({ row: { data: 10 } });
    await turn();
    expect(h.verdicts.at(-1)).toBe(true);
    end.resolve();
    await running;
    await turn();
    expect(h.verdicts.at(-1)).toBe(false);
    expect(h.requests).toHaveLength(2);
  } finally {
    for (const request of h.requests) request.resolve({ row: { data: 10 } });
    end.resolve();
    await running;
    h.dispose();
    flush();
  }
});

it("a scalar boundary pends an ordinary proposal once its quiet input is consumed", async () => {
  const requests: ReturnType<typeof Promise.withResolvers<number>>[] = [];
  const [ordinary, setOrdinary] = createSignal(0);
  const end = Promise.withResolvers<void>();
  const shown: number[] = [];
  const [quiet, value, dispose] = createRoot(dispose => {
    const quiet = createMemo(() => {
      const request = Promise.withResolvers<number>();
      requests.push(request);
      return request.promise;
    });
    const [value] = createOptimistic(() => quiet() + ordinary());
    createRenderEffect(value, result => {
      shown.push(result);
    });
    return [quiet, value, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    requests[0].resolve(10);
    await turn();
    expect(shown.at(-1)).toBe(10);
    void refresh(quiet);
    flush();
    expect(isPending(value)).toBe(false);
    running = action(function* () {
      setOrdinary(1);
      yield end.promise;
    })();
    flush();
    expect(isPending(ordinary)).toBe(true);
    // The first read suspends before ordinary() is consumed again.
    expect(isPending(value)).toBe(false);
    requests[1].resolve(10);
    await turn();
    expect(isPending(value)).toBe(true);
    end.resolve();
    await running;
    await turn();
    expect(shown.at(-1)).toBe(11);
    expect(isPending(value)).toBe(false);
    expect(requests).toHaveLength(2);
  } finally {
    for (const request of requests) request.resolve(10);
    end.resolve();
    await running;
    dispose();
    flush();
  }
});

it("a selected scalar proposal stays pending during a simultaneous quiet refresh", async () => {
  const requests: ReturnType<typeof Promise.withResolvers<number>>[] = [];
  const digestion: ReturnType<typeof Promise.withResolvers<number>>[] = [];
  const end = Promise.withResolvers<void>();
  const shown: number[] = [];
  const [quiet, value, propose, dispose] = createRoot(dispose => {
    const quiet = createMemo(() => {
      const p = Promise.withResolvers<number>();
      requests.push(p);
      return p.promise;
    });
    const [value, propose] = createOptimistic(quiet);
    const derived = createMemo(() => {
      const n = value();
      const p = Promise.withResolvers<number>();
      digestion.push(p);
      return p.promise.then(() => n * 2);
    });
    createRenderEffect(derived, n => {
      shown.push(n);
    });
    return [quiet, value, propose, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    requests[0].resolve(10);
    await turn();
    digestion[0].resolve(0);
    await turn();
    expect(shown).toEqual([20]);
    void refresh(quiet);
    flush();
    running = action(function* () {
      propose(15);
      yield end.promise;
    })();
    flush();
    expect(isPending(value)).toBe(true);
    requests[1].resolve(10);
    await turn();
    expect(isPending(value)).toBe(true);
    for (const p of digestion) p.resolve(0);
    await turn();
    expect(shown.at(-1)).toBe(30);
    expect(isPending(value)).toBe(false);
  } finally {
    end.resolve();
    for (const p of requests) p.resolve(10);
    for (const p of digestion) p.resolve(0);
    await running;
    dispose();
    flush();
  }
});

it("a manual boundary keeps a fresh async question pending beside a quiet input", async () => {
  const [question, setQuestion] = createSignal(0);
  const quietRequests: ReturnType<typeof Promise.withResolvers<number>>[] = [];
  const freshRequests: ReturnType<typeof Promise.withResolvers<number>>[] = [];
  const shown: number[] = [];
  const [quiet, value, dispose] = createRoot(dispose => {
    const quiet = createMemo(() => {
      const p = Promise.withResolvers<number>();
      quietRequests.push(p);
      return p.promise;
    });
    const fresh = createMemo(() => {
      question();
      const p = Promise.withResolvers<number>();
      freshRequests.push(p);
      return p.promise;
    });
    const [value] = createOptimistic(() => quiet() + fresh());
    createRenderEffect(value, n => {
      shown.push(n);
    });
    return [quiet, value, dispose] as const;
  });
  try {
    flush();
    quietRequests[0].resolve(10);
    await turn();
    freshRequests[0].resolve(1);
    await turn();
    expect(shown.at(-1)).toBe(11);
    void refresh(quiet);
    flush();
    setQuestion(1);
    flush();
    // The boundary has not consumed fresh's new question while its first read suspends.
    quietRequests[1].resolve(10);
    await turn();
    expect(isPending(value)).toBe(true);
    freshRequests[1].resolve(2);
    await turn();
    expect(shown.at(-1)).toBe(12);
    expect(isPending(value)).toBe(false);
    expect(quietRequests).toHaveLength(2);
    expect(freshRequests).toHaveLength(2);
  } finally {
    for (const p of quietRequests) p.resolve(10);
    for (const p of freshRequests) p.resolve(2);
    dispose();
    flush();
  }
});

it("a held store proposal is visible to pending while fresh metadata waits on a quiet producer", async () => {
  const sourceRequests: ReturnType<typeof Promise.withResolvers<number>>[] = [];
  const derivedRequests: ReturnType<typeof Promise.withResolvers<number>>[] = [];
  const end = Promise.withResolvers<void>();
  const shown: number[] = [];
  const [state, write, dispose] = createRoot(dispose => {
    const [state, write] = createOptimisticStore(
      async draft => {
        const request = Promise.withResolvers<number>();
        sourceRequests.push(request);
        draft.data = await request.promise;
      },
      { data: 0 }
    );
    const derived = createMemo(() => {
      const data = state.data;
      const request = Promise.withResolvers<number>();
      derivedRequests.push(request);
      return request.promise.then(() => data * 2);
    });
    createRenderEffect(derived, result => {
      shown.push(result);
    });
    return [state, write, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    sourceRequests[0].resolve(10);
    await turn();
    derivedRequests[0].resolve(0);
    await turn();
    expect(shown).toEqual([20]);
    void refresh(state);
    flush();
    expect(isPending(() => state.data)).toBe(false);
    running = action(function* () {
      write(draft => {
        draft.data = 15;
      });
      yield end.promise;
    })();
    flush();
    expect(state.data).toBe(10);
    expect(isPending(() => state.data)).toBe(true);
    expect(shown).toEqual([20]);
    sourceRequests[1].resolve(10);
    await turn();
    expect(state.data).toBe(10);
    expect(isPending(() => state.data)).toBe(true);
    derivedRequests[1].resolve(0);
    await turn();
    expect(state.data).toBe(15);
    expect(shown.at(-1)).toBe(30);
    expect(isPending(() => state.data)).toBe(false);
    expect(sourceRequests).toHaveLength(2);
    expect(derivedRequests).toHaveLength(2);
    end.resolve();
    await running;
    await turn();
    expect(isPending(() => state.data)).toBe(true);
    derivedRequests[2].resolve(0);
    await turn();
    expect(state.data).toBe(10);
    expect(shown.at(-1)).toBe(20);
    expect(isPending(() => state.data)).toBe(false);
  } finally {
    end.resolve();
    for (const request of sourceRequests) request.resolve(10);
    for (const request of derivedRequests) request.resolve(0);
    await running;
    dispose();
    flush();
  }
});
