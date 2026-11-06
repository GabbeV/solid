import { afterEach, expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createLoadingBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  onCleanup
} from "../src/index.js";
import { latest } from "../src/layers/latest.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  let reject!: (error: unknown) => void;
  const promise = new Promise<T>((yes, no) => {
    resolve = yes;
    reject = no;
  });
  return { promise, resolve, reject };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

it("a first latest preview mounts its Loading fallback from the flushed proposal", async () => {
  const end = gate<void>(),
    answer = gate<string>();
  const [count, setCount] = createSignal(0);
  const running = action(function* () {
    setCount(1);
    yield end.promise;
  })();
  flush();
  const calculated: number[] = [],
    frames: string[] = [];
  createRoot(dispose => {
    disposals.push(dispose);
    const details = createMemo(() => {
      const n = latest(count);
      calculated.push(n);
      return n === 0 ? "cached 0" : answer.promise;
    });
    const content = createLoadingBoundary(details, () => "loading");
    createRenderEffect(
      content,
      value => {
        frames.push(value);
      },
      { schedule: true }
    );
  });
  flush();
  expect(count()).toBe(0);
  expect(frames).toEqual(["loading"]);
  // Initial derivation and registration of the independent update may both
  // calculate. Neither may manufacture an old-value frame for a new preview.
  expect(calculated.length).toBeGreaterThan(0);
  expect(calculated.every(value => value === 1)).toBe(true);
  answer.resolve("loaded 1");
  await turn();
  expect(count()).toBe(0);
  expect(frames).toEqual(["loading", "loaded 1"]);
  end.resolve();
  await running;
  await turn();
  expect(count()).toBe(1);
  expect(frames).toEqual(["loading", "loaded 1"]);
});

it("first latest initialization uses the last flushed proposal before a rewrite flushes", async () => {
  const end = gate<void>();
  const [source, setSource] = createSignal(10);
  const running = action(function* () {
    setSource(20);
    yield end.promise;
  })();
  flush();
  setSource(30);
  let preview!: () => number;
  const calculated: number[] = [];
  const shown: number[] = [];
  createRoot(dispose => {
    disposals.push(dispose);
    preview = createMemo(() => {
      const value = latest(source);
      calculated.push(value);
      return value;
    });
    createRenderEffect(
      preview,
      value => {
        shown.push(value);
      },
      { schedule: true }
    );
  });
  expect(calculated).toEqual([20]);
  flush();
  expect(preview()).toBe(30);
  expect(shown).toEqual([30]);
  expect(source()).toBe(10);
  end.resolve();
  await running;
  await turn();
  expect(source()).toBe(30);
  expect(shown).toEqual([30]);
});

for (const sourceFirst of [false, true])
  it(`first latest mount combines with the published input in either read order (sourceFirst=${sourceFirst})`, async () => {
    const end = gate<void>();
    const [source, setSource] = createSignal(0);
    const running = action(function* () {
      setSource(1);
      yield end.promise;
    })();
    flush();
    const frames: (readonly number[])[] = [];
    createRoot(dispose => {
      disposals.push(dispose);
      const pair = createMemo(() => {
        if (sourceFirst) {
          const value = source();
          return [value, latest(source)];
        }
        const ahead = latest(source);
        return [source(), ahead];
      });
      createRenderEffect(
        pair,
        value => {
          frames.push(value);
        },
        { schedule: true }
      );
    });
    flush();
    expect(frames).toEqual([[0, 1]]);
    end.resolve();
    await running;
    await turn();
    expect(frames).toEqual([
      [0, 1],
      [1, 1]
    ]);
  });

it("latest of a memo wrapping pending observes the published true result", async () => {
  const end = gate<void>();
  const [source, setSource] = createSignal(0);
  let pending!: () => boolean;
  const shown = { pending: false, latest: false };
  createRoot(dispose => {
    disposals.push(dispose);
    pending = createMemo(() => isPending(source));
    createRenderEffect(pending, value => {
      shown.pending = value;
    });
    createRenderEffect(
      () => latest(pending),
      value => {
        shown.latest = value;
      }
    );
  });
  flush();
  const running = action(function* () {
    setSource(1);
    yield end.promise;
  })();
  flush();
  expect(shown).toEqual({ pending: true, latest: true });
  end.resolve();
  await running;
  await turn();
});

for (const depth of [1, 3])
  it(`discovering latest in a new owned child revalidates its parent's input reads (depth=${depth})`, async () => {
    const end = gate<void>();
    const [source, setSource] = createSignal(0);
    const running = action(function* () {
      setSource(1);
      yield end.promise;
    })();
    flush();
    const frames: (readonly number[])[] = [];
    const children: { disposed: boolean }[] = [];
    const child = (remaining: number): (() => number) =>
      createMemo(() => {
        const frame = { disposed: false };
        children.push(frame);
        onCleanup(() => {
          frame.disposed = true;
        });
        return remaining ? child(remaining - 1)() : latest(source);
      });
    createRoot(dispose => {
      disposals.push(dispose);
      const pair = createMemo(() => {
        const value = source();
        return [value, child(depth - 1)()];
      });
      createRenderEffect(
        pair,
        value => {
          frames.push(value);
        },
        { schedule: true }
      );
    });
    flush();
    expect(frames).toEqual([[0, 1]]);
    expect(children.filter(frame => !frame.disposed)).toHaveLength(depth);
    end.resolve();
    await running;
    await turn();
    expect(frames).toEqual([
      [0, 1],
      [1, 1]
    ]);
    expect(children.filter(frame => !frame.disposed)).toHaveLength(depth);
  });

it("discovering latest through a lazy sibling revalidates the pulling reader", async () => {
  const end = gate<void>();
  const [source, setSource] = createSignal(0);
  let ahead!: () => number;
  const frames: (readonly number[])[] = [];
  createRoot(dispose => {
    disposals.push(dispose);
    ahead = createMemo(() => latest(source), { lazy: true });
  });
  const running = action(function* () {
    setSource(1);
    yield end.promise;
  })();
  flush();
  createRoot(dispose => {
    disposals.push(dispose);
    const pair = createMemo(() => [source(), ahead()]);
    createRenderEffect(
      pair,
      value => {
        frames.push(value);
      },
      { schedule: true }
    );
  });
  flush();
  expect(frames).toEqual([[0, 1]]);
  end.resolve();
  await running;
  await turn();
  expect(frames).toEqual([
    [0, 1],
    [1, 1]
  ]);
});

it("sibling latest outputs preserve observable publications through supersession and late mounts", async () => {
  for (let seed = 1; seed <= Number(process.env.LATEST_SEEDS || 30); seed++) {
    let randomState = seed;
    const random = () => (randomState = (Math.imul(randomState, 1664525) + 1013904223) >>> 0);
    const end = gate<void>();
    const [x, setX] = createSignal(0),
      [y, setY] = createSignal(0),
      [tick, setTick] = createSignal(0);
    const shown = { x: 0, y: 0, label: "0/0" };
    const flights: { value: string; answer: ReturnType<typeof gate<string>> }[] = [];
    const late: { value: number; dispose: () => void }[] = [];
    createRoot(dispose => {
      disposals.push(dispose);
      const label = createMemo(() => {
        const value = `${latest(x)}/${latest(y)}`;
        if (value === "0/0") return value;
        const answer = gate<string>();
        flights.push({ value, answer });
        return answer.promise;
      });
      createRenderEffect(
        () => {
          tick();
          return latest(x);
        },
        value => {
          shown.x = value;
        }
      );
      createRenderEffect(
        () => latest(y),
        value => {
          shown.y = value;
        }
      );
      createRenderEffect(label, value => {
        shown.label = value;
      });
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    for (const flight of flights.splice(0)) flight.answer.resolve(flight.value);
    await turn();
    const operations: string[] = [];
    const check = () => {
      const why = `seed=${seed}, operations=${operations.join(" ")}`;
      expect(shown.label, why).toBe(`${shown.x}/${shown.y}`);
      expect([latest(x), latest(y)], why).toEqual([shown.x, shown.y]);
      for (const reader of late) expect(reader.value, why).toBe(shown.x);
    };
    for (let step = 0; step < 40; step++) {
      const op = (random() >>> 16) % 6,
        value = (random() >>> 16) % 5;
      operations.push(`${op}:${value}`);
      if (op === 0) setX(value);
      else if (op === 1) setY(value);
      else if (op === 2) {
        const flight = flights.splice(value % Math.max(1, flights.length), 1)[0];
        flight?.answer.resolve(flight.value);
      } else if (op === 3) setTick(step);
      else if (op === 4) {
        const reader = { value: -1, dispose: () => {} };
        createRoot(dispose => {
          reader.dispose = dispose;
          disposals.push(dispose);
          createRenderEffect(
            () => latest(x),
            value => {
              reader.value = value;
            }
          );
        });
        late.push(reader);
      } else late.shift()?.dispose();
      flush();
      await turn();
      check();
    }
    end.resolve();
    await running;
    await turn();
    for (let round = 0; flights.length && round < 10; round++) {
      for (const flight of flights.splice(0)) flight.answer.resolve(flight.value);
      await turn();
    }
    expect(flights).toHaveLength(0);
    check();
    for (const dispose of disposals.splice(0)) dispose();
    flush();
  }
});

it("latest observes the selected optimistic output while its input answer is held", async () => {
  const answer = gate<void>(),
    end = gate<void>();
  const [source, setSource] = createSignal(0);
  let guess!: (value: number) => number;
  const shown = {
    source: 0,
    view: 0,
    doubled: 0,
    latestSource: 0,
    latestView: 0,
    latestDoubled: 0
  };
  createRoot(dispose => {
    disposals.push(dispose);
    const [view, write] = createOptimistic(source);
    guess = write;
    const doubled = createMemo(() => view() * 2);
    const reads = {
      source,
      view,
      doubled,
      latestSource: () => latest(source),
      latestView: () => latest(view),
      latestDoubled: () => latest(doubled)
    };
    for (const [key, read] of Object.entries(reads))
      createRenderEffect(read, value => {
        shown[key as keyof typeof shown] = value;
      });
  });
  flush();
  const running = action(function* () {
    guess(1);
    yield answer.promise;
    setSource(10);
    yield end.promise;
  })();
  flush();
  expect(shown).toEqual({
    source: 0,
    view: 1,
    doubled: 2,
    latestSource: 0,
    latestView: 1,
    latestDoubled: 2
  });
  answer.resolve();
  await turn();
  expect(shown).toEqual({
    source: 0,
    view: 1,
    doubled: 2,
    latestSource: 10,
    latestView: 1,
    latestDoubled: 2
  });
  end.resolve();
  await running;
  await turn();
  expect(shown).toEqual({
    source: 10,
    view: 10,
    doubled: 20,
    latestSource: 10,
    latestView: 10,
    latestDoubled: 20
  });
});

for (const wrapped of [false, true])
  it(`pending on latest distinguishes an input flight from a held ready answer (wrapped=${wrapped})`, async () => {
    const answer = gate<number>(),
      end = gate<void>();
    const [revision, setRevision] = createSignal(0);
    const shown = { value: 0, pending: false };
    createRoot(dispose => {
      disposals.push(dispose);
      const input = createMemo(() => (revision() ? answer.promise : 0));
      const ahead = () => (wrapped ? latest(() => input()) : latest(input));
      createRenderEffect(ahead, value => {
        shown.value = value;
      });
      createRenderEffect(
        () => isPending(ahead),
        value => {
          shown.pending = value;
        }
      );
    });
    flush();
    const running = action(function* () {
      setRevision(1);
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual({ value: 0, pending: true });
    answer.resolve(1);
    await turn();
    expect(shown).toEqual({ value: 1, pending: false });
    end.resolve();
    await running;
    await turn();
    expect(shown).toEqual({ value: 1, pending: false });
  });

it("latest waits for an initial value, forwards errors and recovers", async () => {
  const initial = gate<number>(),
    failure = gate<number>();
  const [revision, setRevision] = createSignal(0);
  let shown: number | string = "initial";
  createRoot(dispose => {
    disposals.push(dispose);
    const input = createMemo(() =>
      revision() === 0 ? initial.promise : revision() === 1 ? failure.promise : 2
    );
    const content = createErrorBoundary(
      () => latest(input),
      error => (error() as Error).message
    );
    createRenderEffect(content, value => {
      shown = value;
    });
  });
  flush();
  expect(shown).toBe("initial");
  initial.resolve(0);
  await turn();
  expect(shown).toBe(0);
  setRevision(1);
  flush();
  expect(shown).toBe(0);
  failure.reject(new Error("failed"));
  await turn();
  expect(shown).toBe("failed");
  setRevision(2);
  flush();
  expect(shown).toBe(2);
});

it("an equal-valued latest consequence preserves owned children until publication", async () => {
  const answer = gate<number>(),
    end = gate<void>();
  const [source, setSource] = createSignal(0);
  let shown = 0;
  const frames: { value: number; disposed: boolean }[] = [];
  createRoot(dispose => {
    disposals.push(dispose);
    const result = createMemo(() => {
      const value = latest(source);
      const frame = { value, disposed: false };
      frames.push(frame);
      onCleanup(() => {
        frame.disposed = true;
      });
      createRenderEffect(
        () => value,
        value => {
          shown = value;
        },
        { schedule: true }
      );
      return value ? answer.promise : 0;
    });
    createRenderEffect(result, () => {});
  });
  flush();
  const running = action(function* () {
    setSource(1);
    yield end.promise;
  })();
  flush();
  expect(shown).toBe(0);
  expect(frames[0].disposed).toBe(false);
  answer.resolve(0);
  await turn();
  expect(shown).toBe(1);
  expect(frames[0].disposed).toBe(true);
  expect(frames.at(-1)!.disposed).toBe(false);
  end.resolve();
  await running;
  await turn();
});

for (const wrapped of [false, true])
  it(`latest readers share held publication through a repeated proposal (wrapped=${wrapped})`, async () => {
    const again = gate<void>(),
      end = gate<void>(),
      result = gate<number>();
    const [source, setSource] = createSignal(0),
      [tick, setTick] = createSignal(0);
    const ahead = () => (wrapped ? latest(() => source()) : latest(source));
    const shown = { source: 0, latest: 0, details: 0, late: -1 };
    createRoot(dispose => {
      disposals.push(dispose);
      const details = createMemo(() => (ahead() === 2 ? result.promise : ahead() * 10));
      createRenderEffect(source, value => {
        shown.source = value;
      });
      createRenderEffect(
        () => {
          tick();
          return ahead();
        },
        value => {
          shown.latest = value;
        }
      );
      createRenderEffect(details, value => {
        shown.details = value;
      });
    });
    flush();
    const running = action(function* () {
      setSource(1);
      yield again.promise;
      setSource(2);
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual({ source: 0, latest: 1, details: 10, late: -1 });
    again.resolve();
    await turn();
    setTick(1);
    flush();
    createRoot(dispose => {
      disposals.push(dispose);
      createRenderEffect(ahead, value => {
        shown.late = value;
      });
    });
    flush();
    expect(shown).toEqual({ source: 0, latest: 1, details: 10, late: 1 });
    expect(ahead()).toBe(1);
    result.resolve(20);
    await turn();
    expect(shown).toEqual({ source: 0, latest: 2, details: 20, late: 2 });
    end.resolve();
    await running;
    await turn();
    expect(shown).toEqual({ source: 2, latest: 2, details: 20, late: 2 });
  });
