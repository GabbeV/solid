import { afterEach, expect, it } from "vitest";
import { $REFRESH } from "../src/core/constants.js";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  refresh,
  createErrorBoundary,
  onCleanup
} from "../src/index.js";

function gate<T>() {
  let resolve!: (value: T) => void, reject!: (error: unknown) => void;
  const promise = new Promise<T>((yes, no) => {
    resolve = yes;
    reject = no;
  });
  return { promise, resolve, reject };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
function root(fn: () => void) {
  createRoot(dispose => {
    disposals.push(dispose);
    fn();
  });
}
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

for (const direct of [false, true])
  it(`refresh re-reads only the optimistic input (direct=${direct})`, async () => {
    let view!: () => number,
      inputRuns = 0,
      doubledRuns = 0,
      shown = -1;
    root(() => {
      const [first] = createSignal(1);
      const doubled = createMemo(
        () => {
          doubledRuns++;
          return first() * 2;
        },
        { equals: false }
      );
      [view] = createOptimistic(
        direct
          ? doubled
          : () => {
              inputRuns++;
              return doubled();
            }
      );
      createRenderEffect(
        view,
        value => {
          shown = value;
        },
        { schedule: true }
      );
    });
    flush();
    expect(await refresh(view)).toBe(2);
    expect([shown, doubledRuns, inputRuns]).toEqual([2, 1, direct ? 0 : 2]);
  });

it("coalesces same-tick refreshes, including equal answers", async () => {
  let source!: () => number,
    runs = 0;
  root(() => {
    source = createMemo(() => {
      runs++;
      return 1;
    });
  });
  source();
  const first = refresh(source),
    second = refresh(source),
    third = refresh(source);
  expect(await Promise.all([first, second, third])).toEqual([1, 1, 1]);
  expect(runs).toBe(2);
});

it("a second equal synchronous refresh before delivery cannot strand the first waiter", async () => {
  let source!: () => number;
  root(() => {
    source = createMemo(() => 1);
  });
  source();
  const delivered: number[] = [];
  const first = refresh(source).then(v => {
    delivered.push(v);
  });
  await Promise.resolve(); // Supersede after the first waiter's read, before its delivery.
  const second = refresh(source).then(v => {
    delivered.push(v);
  });
  await turn();
  expect(delivered).toEqual([1, 1]);
  await Promise.all([first, second]);
});

it("a plain signal refresh is a no-op", async () => {
  const [source] = createSignal(3);
  expect(await refresh(source)).toBe(3);
});

it("an async refresh is quiet and publishes its ordinary consequences together", async () => {
  const answer = gate<number>(),
    detail = gate<number>();
  let source!: () => number,
    result: number | Promise<number> = 0;
  const shown = { source: -1, detail: -1, pending: true };
  root(() => {
    source = createMemo(() => result);
    const doubled = createMemo(() => (source() ? detail.promise : 0));
    createRenderEffect(
      source,
      value => {
        shown.source = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      doubled,
      value => {
        shown.detail = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      () => isPending(source),
      value => {
        shown.pending = value;
      },
      { schedule: true }
    );
  });
  flush();
  result = answer.promise;
  let resolved = false;
  const promise = refresh(source).then(value => {
    resolved = true;
    return value;
  });
  await turn();
  expect(shown).toEqual({ source: 0, detail: 0, pending: false });
  answer.resolve(1);
  await turn();
  expect([shown.source, shown.detail, resolved]).toEqual([0, 0, false]);
  detail.resolve(2);
  expect(await promise).toBe(1);
  await turn();
  expect(shown).toEqual({ source: 1, detail: 2, pending: false });
});

for (const optimistic of [false, true])
  it(`an action receives its staged answer without publishing it (optimistic=${optimistic})`, async () => {
    const answer = gate<number>(),
      end = gate<void>();
    let result: number | Promise<number> = 0,
      source!: () => number,
      view!: () => number;
    let guess!: (value: number) => number,
      shown = -1,
      delivered = -1;
    root(() => {
      source = createMemo(() => result);
      if (optimistic) [view, guess] = createOptimistic(source);
      else view = source;
      createRenderEffect(
        view,
        value => {
          shown = value;
        },
        { schedule: true }
      );
    });
    flush();
    const running = action(function* () {
      if (optimistic) guess(1);
      result = answer.promise;
      // Refresh the actual async producer; refreshing its accessor wrapper
      // alone does not invalidate that producer.
      delivered = yield refresh(source);
      yield end.promise;
    })();
    await turn();
    answer.resolve(2);
    await turn();
    expect([delivered, shown]).toEqual([2, optimistic ? 1 : 0]);
    end.resolve();
    await running;
    await turn();
    expect(shown).toBe(2);
  });

it("refreshing an overridden callback delivers its input and retains the override until release", async () => {
  const begin = gate<void>(),
    end = gate<void>();
  let result = 0,
    view!: () => number,
    guess!: (v: number) => number,
    shown = -1,
    delivered = -1;
  root(() => {
    [view, guess] = createOptimistic(() => result);
    createRenderEffect(
      view,
      value => {
        shown = value;
      },
      { schedule: true }
    );
  });
  const running = action(function* () {
    guess(1);
    yield begin.promise;
    result = 2;
    delivered = yield refresh(view);
    yield end.promise;
  })();
  flush();
  expect(shown).toBe(1);
  begin.resolve();
  await turn();
  expect([delivered, shown]).toEqual([2, 1]);
  end.resolve();
  await running;
  await turn();
  expect(shown).toBe(2);
});

it("superseded answers cannot settle either refresh promise", async () => {
  const oldAnswer = gate<number>(),
    newAnswer = gate<number>();
  let result: number | Promise<number> = 0,
    source!: () => number,
    shown = -1;
  root(() => {
    source = createMemo(() => result);
    createRenderEffect(
      source,
      value => {
        shown = value;
      },
      { schedule: true }
    );
  });
  flush();
  result = oldAnswer.promise;
  let settled = 0;
  const first = refresh(source).then(v => {
    settled++;
    return v;
  });
  await turn();
  result = newAnswer.promise;
  const second = refresh(source).then(v => {
    settled++;
    return v;
  });
  await turn();
  oldAnswer.resolve(1);
  await turn();
  expect([settled, shown]).toEqual([0, 0]);
  newAnswer.resolve(2);
  expect(await Promise.all([first, second])).toEqual([2, 2]);
  await turn();
  expect(shown).toBe(2);
});

it("refresh rejects with the input error and a later refresh recovers", async () => {
  const answer = gate<number>();
  let result: number | Promise<number> = 0,
    source!: () => number,
    shown: number | string = -1;
  root(() => {
    source = createMemo(() => result);
    const boundary = createErrorBoundary(source, error => (error() as Error).message);
    createRenderEffect(
      boundary,
      value => {
        shown = value;
      },
      { schedule: true }
    );
  });
  flush();
  result = answer.promise;
  const promise = refresh(source);
  const failed = expect(promise).rejects.toThrow("failed");
  await turn();
  answer.reject(new Error("failed"));
  await failed;
  await turn();
  expect(shown).toBe("failed");
  result = 2;
  expect(await refresh(source)).toBe(2);
  await turn();
  expect(shown).toBe(2);
});

it("equal refreshed values retain owned children until the action publishes", async () => {
  const end = gate<void>();
  let source!: () => number,
    generation = 0,
    child = -1,
    delivered = -1;
  const cleaned: number[] = [];
  root(() => {
    source = createMemo(() => {
      const value = generation;
      onCleanup(() => {
        cleaned.push(value);
      });
      createRenderEffect(
        () => value,
        value => {
          child = value;
        },
        { schedule: true }
      );
      return 0;
    });
    createRenderEffect(source, () => {}, { schedule: true });
  });
  flush();
  const running = action(function* () {
    generation = 1;
    delivered = yield refresh(source);
    yield end.promise;
  })();
  await turn();
  expect([delivered, child, cleaned]).toEqual([0, 0, []]);
  end.resolve();
  await running;
  await turn();
  expect([child, cleaned]).toEqual([1, [0]]);
});

it("an outside refresh waits for a foreign action to publish", async () => {
  const end = gate<void>();
  let source!: () => number,
    set!: (value: number) => number,
    shown = -1;
  root(() => {
    const [input, write] = createSignal(0);
    set = write;
    source = createMemo(() => input() * 2);
    createRenderEffect(
      source,
      value => {
        shown = value;
      },
      { schedule: true }
    );
  });
  flush();
  const running = action(function* () {
    set(1);
    yield end.promise;
  })();
  await turn(); // A later event, outside the action's initial write batch.
  let delivered = -1;
  const promise = refresh(source).then(value => {
    delivered = value;
    return value;
  });
  await turn();
  expect([delivered, shown]).toEqual([-1, 0]);
  end.resolve();
  await running;
  expect(await promise).toBe(2);
  await turn();
  expect(shown).toBe(2);
});

for (const direct of [false, true])
  for (const depth of [2, 5])
    it(`refresh crosses only its target boundary (depth=${depth}, direct=${direct})`, async () => {
      const begin = gate<void>(),
        end = gate<void>();
      const guesses: ((value: number) => number)[] = [],
        sources: (() => number)[] = [];
      const shown: number[] = [],
        runs: number[] = [];
      let delivered = -1;
      root(() => {
        let previous: () => number = createSignal(0)[0];
        for (let i = 0; i < depth; i++) {
          const input = previous;
          runs.push(0);
          const doubled = createMemo(() => {
            runs[i]++;
            return input() * 2;
          });
          const [view, guess] = createOptimistic(direct ? doubled : () => doubled());
          sources.push(view);
          guesses.push(guess);
          createRenderEffect(
            view,
            value => {
              shown[i] = value;
            },
            { schedule: true }
          );
          previous = view;
        }
      });
      flush();
      const lowerActions: Promise<unknown>[] = [];
      for (let i = 0; i < depth - 1; i++) {
        lowerActions.push(
          action(function* () {
            guesses[i](i + 1);
            yield end.promise;
          })()
        );
        await turn();
      }
      const running = action(function* () {
        guesses[depth - 1](depth);
        yield begin.promise;
        delivered = yield refresh(sources[depth - 1]);
        yield end.promise;
      })();
      flush();
      const before = [...runs];
      expect(shown).toEqual(Array.from({ length: depth }, (_, i) => i + 1));
      begin.resolve();
      await turn();
      expect(delivered).toBe((depth - 1) * 2);
      expect(shown).toEqual(Array.from({ length: depth }, (_, i) => i + 1));
      expect(runs).toEqual(before);
      end.resolve();
      await running;
      await Promise.all(lowerActions);
      await turn();
      expect(shown).toEqual(Array(depth).fill(0));
    });

it("a quiet refresh does not hide a genuinely new pending question", async () => {
  const answer = gate<number>();
  let source!: () => number,
    set!: (value: number) => number,
    pending = false;
  root(() => {
    const [input, write] = createSignal(0);
    set = write;
    source = createMemo(() => (input() ? answer.promise : 0));
    createRenderEffect(source, () => {}, { schedule: true });
    createRenderEffect(
      () => isPending(source),
      value => {
        pending = value;
      },
      { schedule: true }
    );
  });
  flush();
  set(1);
  flush();
  expect(pending).toBe(true);
  const promise = refresh(source);
  await turn();
  expect(pending).toBe(true);
  answer.resolve(1);
  expect(await promise).toBe(1);
  await turn();
  expect(pending).toBe(false);
});

it("a refreshed answer stays quiet while its caller keeps the action open", async () => {
  const answer = gate<number>(),
    end = gate<void>();
  let result: number | Promise<number> = 0,
    source!: () => number,
    delivered = -1;
  const shown = { value: -1, pending: true };
  root(() => {
    source = createMemo(() => result);
    createRenderEffect(
      source,
      value => {
        shown.value = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      () => isPending(source),
      value => {
        shown.pending = value;
      },
      { schedule: true }
    );
  });
  flush();
  const running = action(function* () {
    result = answer.promise;
    delivered = yield refresh(source);
    yield end.promise;
  })();
  await turn();
  expect(shown).toEqual({ value: 0, pending: false });
  answer.resolve(1);
  await turn();
  expect(delivered).toBe(1);
  expect(shown).toEqual({ value: 0, pending: false });
  end.resolve();
  await running;
  await turn();
  expect(shown).toEqual({ value: 1, pending: false });
});

it("an action can catch a refreshed error before its held update publishes", async () => {
  const answer = gate<number>(),
    end = gate<void>();
  let result: number | Promise<number> = 0,
    source!: () => number,
    caught = "";
  let shown: number | string = -1;
  root(() => {
    source = createMemo(() => result);
    const output = createErrorBoundary(source, error => (error() as Error).message);
    createRenderEffect(
      output,
      value => {
        shown = value;
      },
      { schedule: true }
    );
  });
  flush();
  const running = action(function* () {
    result = answer.promise;
    try {
      yield refresh(source);
    } catch (error) {
      caught = (error as Error).message;
    }
    yield end.promise;
  })();
  await turn();
  answer.reject(new Error("rejected"));
  await turn();
  expect([caught, shown]).toEqual(["rejected", 0]);
  end.resolve();
  await running;
  await turn();
  expect(shown).toBe("rejected");
});

it("a disposed source refresh returns its last value without running it", async () => {
  let source!: () => number,
    runs = 0,
    dispose!: () => void;
  createRoot(d => {
    dispose = d;
    source = createMemo(() => ++runs);
  });
  expect(source()).toBe(1);
  dispose();
  expect(await refresh(source)).toBe(1);
  expect(runs).toBe(1);
});

it("refreshing an async iterable resolves on its first yield and later yields still publish", async () => {
  const first = gate<number>(),
    second = gate<number>();
  let reload = false,
    source!: () => number,
    shown = -1;
  async function* stream() {
    yield await first.promise;
    yield await second.promise;
  }
  root(() => {
    source = createMemo(() => (reload ? stream() : 0));
    createRenderEffect(
      source,
      value => {
        shown = value;
      },
      { schedule: true }
    );
  });
  flush();
  reload = true;
  const promise = refresh(source);
  await turn();
  expect(shown).toBe(0);
  first.resolve(1);
  expect(await promise).toBe(1);
  await turn();
  expect(shown).toBe(1);
  second.resolve(2);
  await turn();
  expect(shown).toBe(2);
});

it("an optimistic refresh reports its input error while retaining the displayed override", async () => {
  const begin = gate<void>(),
    end = gate<void>();
  let failure = false,
    result = 0,
    view!: () => number,
    guess!: (v: number) => number;
  let shown: number | string = -1,
    caught = "";
  root(() => {
    [view, guess] = createOptimistic(() => {
      if (failure) throw new Error("input failed");
      return result;
    });
    const output = createErrorBoundary(view, error => (error() as Error).message);
    createRenderEffect(
      output,
      value => {
        shown = value;
      },
      { schedule: true }
    );
  });
  flush();
  const running = action(function* () {
    guess(1);
    yield begin.promise;
    failure = true;
    try {
      yield refresh(view);
    } catch (error) {
      caught = (error as Error).message;
    }
    yield end.promise;
  })();
  flush();
  begin.resolve();
  await turn();
  expect([shown, caught]).toEqual([1, "input failed"]);
  end.resolve();
  await running;
  await turn();
  expect(shown).toBe("input failed");
  failure = false;
  result = 2;
  expect(await refresh(view)).toBe(2);
  await turn();
  expect(shown).toBe(2);
});

it("repeated refresh cycles release their waiters and replaced owned children", async () => {
  let source!: () => number,
    value = 0,
    shown = -1,
    cleaned = 0;
  root(() => {
    source = createMemo(() => {
      onCleanup(() => {
        cleaned++;
      });
      return value;
    });
    createRenderEffect(
      source,
      next => {
        shown = next;
      },
      { schedule: true }
    );
  });
  flush();
  const node = (source as any)[$REFRESH];
  const subscribers = () => {
    let count = 0;
    for (let edge = node._subs; edge; edge = edge._nextSub) count++;
    return count;
  };
  const before = subscribers();
  for (value = 1; value <= 100; value++) {
    expect(await refresh(source)).toBe(value);
    expect(shown).toBe(value);
    expect(subscribers()).toBe(before);
    expect(cleaned).toBe(value);
  }
});
