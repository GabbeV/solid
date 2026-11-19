import { afterEach, expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest
} from "../src/index.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  let reject!: (error: unknown) => void;
  const promise = new Promise<T>((yes, no) => {
    resolve = yes;
    reject = no;
  });
  return { promise, resolve, reject };
}

// A controlled subscription: return closes the subscription immediately,
// but an already requested next result may still arrive afterwards.
function subscription<T>() {
  const iterators: { requests: ReturnType<typeof gate<IteratorResult<T>>>[]; closed: number }[] =
    [];
  const stream: AsyncIterable<T> = {
    [Symbol.asyncIterator]() {
      const record = { requests: [] as ReturnType<typeof gate<IteratorResult<T>>>[], closed: 0 };
      iterators.push(record);
      return {
        next() {
          const result = gate<IteratorResult<T>>();
          record.requests.push(result);
          return result.promise;
        },
        async return() {
          record.closed++;
          return { done: true, value: undefined };
        }
      };
    }
  };
  return { stream, iterators };
}

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

for (const mode of ["ordinary", "optimistic", "latest"] as const)
  it(`successive stream values retain one coherent publication (${mode})`, async () => {
    const end = gate<void>(),
      labelAnswer = gate<number>();
    const feed = subscription<number>();
    const [source, setSource] = createSignal(0),
      [tick, setTick] = createSignal(0);
    let start!: () => unknown, values!: () => number;
    const shown = { value: 0, label: 0, late: -1 };
    createRoot(dispose => {
      disposals.push(dispose);
      let input: () => number = source;
      start = () => setSource(1);
      if (mode === "optimistic") {
        const [optimistic, guess] = createOptimistic(source);
        input = optimistic;
        start = () => guess(1);
      } else if (mode === "latest") input = () => latest(source);
      values = createMemo(() => (input() ? feed.stream : 0));
      const label = createMemo(() => (values() === 2 ? labelAnswer.promise : values() * 10));
      createRenderEffect(
        () => {
          tick();
          return values();
        },
        value => {
          shown.value = value;
        }
      );
      createRenderEffect(label, value => {
        shown.label = value;
      });
    });
    flush();
    const running =
      mode === "ordinary"
        ? (start(), undefined)
        : action(function* () {
            start();
            yield end.promise;
          })();
    flush();
    // Registration may replace an initial calculation; only the last
    // subscription can remain active, and every superseded one is closed.
    expect(feed.iterators.filter(record => !record.closed)).toHaveLength(1);
    const current = feed.iterators.at(-1)!;
    for (const obsolete of feed.iterators.slice(0, -1)) {
      expect(obsolete.closed).toBe(1);
      obsolete.requests[0].resolve({ done: false, value: 99 });
    }
    await turn();
    expect(shown).toEqual({ value: 0, label: 0, late: -1 });
    current.requests[0].resolve({ done: false, value: 1 });
    await turn();
    expect(shown).toEqual({ value: 1, label: 10, late: -1 });
    current.requests[1].resolve({ done: false, value: 2 });
    await turn();
    setTick(1);
    flush();
    createRoot(dispose => {
      disposals.push(dispose);
      createRenderEffect(values, value => {
        shown.late = value;
      });
    });
    flush();
    expect(shown).toEqual({ value: 1, label: 10, late: 1 });
    expect(values()).toBe(1);
    current.requests[2].resolve({ done: false, value: 3 });
    await turn();
    expect(shown).toEqual({ value: 3, label: 30, late: 3 });
    labelAnswer.resolve(20);
    await turn();
    expect(shown).toEqual({ value: 3, label: 30, late: 3 });
    if (mode === "ordinary") {
      setSource(0);
      flush();
    } else {
      end.resolve();
      await running;
      await turn();
      if (mode === "latest") {
        setSource(0);
        flush();
      }
    }
    expect(shown).toEqual({ value: 0, label: 0, late: 0 });
    expect(current.closed).toBe(1);
    current.requests[3].resolve({ done: false, value: 99 });
    await turn();
    expect(shown).toEqual({ value: 0, label: 0, late: 0 });
    expect(current.closed).toBe(1);
  });

for (const answer of ["value", "error"] as const)
  it(`a closed iterator cannot replace the next iterator's ${answer} when the iterable is reused`, async () => {
    const feed = subscription<number>();
    const [revision, setRevision] = createSignal(0);
    let shown = 0;
    createRoot(dispose => {
      disposals.push(dispose);
      const value = createMemo(() => (revision() ? feed.stream : 0));
      const content = createErrorBoundary(value, () => -1);
      createRenderEffect(content, value => {
        shown = value;
      });
    });
    flush();
    setRevision(1);
    flush();
    setRevision(2);
    flush();
    expect(feed.iterators).toHaveLength(2);
    expect(feed.iterators[0].closed).toBe(1);
    feed.iterators[1].requests[0].resolve({ done: false, value: 20 });
    await turn();
    expect(shown).toBe(20);
    const obsolete = feed.iterators[0].requests[0];
    if (answer === "value") obsolete.resolve({ done: false, value: 10 });
    else obsolete.reject(new Error("closed subscription"));
    await turn();
    expect(shown).toBe(20);
    expect(feed.iterators[0].requests).toHaveLength(1);
  });
