import { expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
function gate() {
  let resolve!: () => void;
  const promise = new Promise<void>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}

for (const producer of [false, true])
  it(`uses committed previous above a lower proposal (input producer=${producer})`, async () => {
    const lowerEnd = gate(),
      upperEnd = gate(),
      again = gate();
    const calls: number[] = [],
      shown = { base: -1, preview: -1, total: -1 };
    let setBase!: (n: number) => number, guess!: (n: number) => number, dispose!: () => void;
    createRoot(cleanup => {
      dispose = cleanup;
      const [base, write] = createSignal(0);
      const [preview, propose] = createOptimistic(() => 0);
      setBase = write;
      guess = propose;
      const calculate = (previous = 0) => {
        calls.push(previous);
        return previous + base() + preview();
      };
      const total = producer
        ? createOptimistic<number>(calculate)[0]
        : createMemo<number>(calculate);
      for (const [key, read] of Object.entries({ base, preview, total }))
        createRenderEffect(
          read,
          value => {
            shown[key as keyof typeof shown] = value;
          },
          { schedule: true }
        );
    });
    flush();
    const lower = action(function* () {
      setBase(1);
      yield lowerEnd.promise;
    })();
    await turn();
    expect(shown).toEqual({ base: 0, preview: 0, total: 0 });
    const upper = action(function* () {
      guess(10);
      yield again.promise;
      guess(20);
      yield upperEnd.promise;
    })();
    try {
      await turn();
      expect(shown).toEqual({ base: 0, preview: 10, total: 10 });
      expect(calls).toEqual([0, 0, 0]);
      again.resolve();
      await turn();
      expect(shown).toEqual({ base: 0, preview: 20, total: 30 });
      expect(calls.at(-1)).toBe(10);
    } finally {
      dispose();
      again.resolve();
      lowerEnd.resolve();
      upperEnd.resolve();
      await Promise.all([lower, upper]);
      flush();
    }
  });

for (const landed of [false, true])
  it(`async context replacement keeps only accepted answers (landed=${landed})`, async () => {
    const lowerEnd = gate(),
      upperEnd = gate(),
      again = gate(),
      answer = gate(),
      sibling = gate();
    const calls: number[] = [],
      shown: number[] = [];
    let setBase!: (n: number) => number, guess!: (n: number) => number, dispose!: () => void;
    createRoot(cleanup => {
      dispose = cleanup;
      const [base, write] = createSignal(0);
      const [preview, propose] = createOptimistic(() => 0);
      setBase = write;
      guess = propose;
      const total = createMemo<number>((previous = 0) => {
        const b = base(),
          p = preview();
        calls.push(previous);
        const result = previous + b + p;
        return p === 10 ? answer.promise.then(() => result) : result;
      });
      const other = createMemo(() =>
        preview() === 10 ? sibling.promise.then(() => 10) : preview()
      );
      createRenderEffect(
        total,
        value => {
          shown.push(value);
        },
        { schedule: true }
      );
      createRenderEffect(other, () => {}, { schedule: true });
    });
    flush();
    const lower = action(function* () {
      setBase(1);
      yield lowerEnd.promise;
    })();
    await turn();
    const upper = action(function* () {
      guess(10);
      yield again.promise;
      guess(20);
      yield upperEnd.promise;
    })();
    try {
      await turn();
      expect(shown).toEqual([0]);
      expect(calls.at(-1)).toBe(0);
      if (landed) {
        answer.resolve();
        await turn();
        expect(shown).toEqual([0]);
      }
      again.resolve();
      await turn();
      expect(calls.at(-1)).toBe(landed ? 10 : 0);
      expect(shown).toEqual([0, landed ? 30 : 20]);
      answer.resolve();
      await turn();
      expect(shown).toEqual([0, landed ? 30 : 20]);
    } finally {
      dispose();
      answer.resolve();
      sibling.resolve();
      again.resolve();
      lowerEnd.resolve();
      upperEnd.resolve();
      await Promise.all([lower, upper]);
      flush();
    }
  });

it("peer ordinary updates retain their shared staged history", async () => {
  const end = gate();
  const shown: number[] = [];
  let set!: (n: number) => number, dispose!: () => void;
  createRoot(cleanup => {
    dispose = cleanup;
    const [value, write] = createSignal(0);
    set = write;
    const sum = createMemo<number>((previous = 0) => previous + value());
    createRenderEffect(
      sum,
      value => {
        shown.push(value);
      },
      { schedule: true }
    );
  });
  flush();
  const first = action(function* () {
    set(1);
    yield end.promise;
  })();
  await turn();
  const second = action(function* () {
    set(2);
    yield end.promise;
  })();
  try {
    await turn();
    expect(shown).toEqual([0]);
    end.resolve();
    await Promise.all([first, second]);
    await turn();
    expect(shown).toEqual([0, 3]);
  } finally {
    dispose();
    end.resolve();
    await Promise.all([first, second]);
    flush();
  }
});

for (const failure of ["body", "comparator", "rejection", "async comparator"])
  it(`a ${failure} error cannot restore foreign previous history`, async () => {
    const lowerEnd = gate(),
      upperEnd = gate(),
      recover = gate();
    const calls: number[] = [],
      shown: number[] = [];
    const expected = new Error("expected");
    let reset!: () => void;
    let setBase!: (n: number) => number, guess!: (n: number) => number, dispose!: () => void;
    createRoot(cleanup => {
      dispose = cleanup;
      const [base, write] = createSignal(0);
      const [preview, propose] = createOptimistic(() => 0);
      setBase = write;
      guess = propose;
      const total = createMemo<number>(
        (previous = 0) => {
          calls.push(previous);
          const b = base(),
            p = preview();
          if (p === 10) {
            if (failure === "body") throw expected;
            if (failure === "rejection") return Promise.reject(expected);
            if (failure === "async comparator") return Promise.resolve(previous + b + p);
          }
          return previous + b + p;
        },
        {
          equals: (a, b) => {
            if (failure.endsWith("comparator") && b === 10) throw expected;
            return a === b;
          }
        }
      );
      const caught = createErrorBoundary(total, (error, retry) => {
        expect((error() as Error).message).toBe(expected.message);
        reset = retry;
        return -1;
      });
      createRenderEffect(
        caught,
        value => {
          shown.push(value);
        },
        { schedule: true }
      );
    });
    flush();
    const lower = action(function* () {
      setBase(1);
      yield lowerEnd.promise;
    })();
    await turn();
    const upper = action(function* () {
      guess(10);
      yield recover.promise;
      guess(20);
      yield upperEnd.promise;
    })();
    try {
      await turn();
      expect(calls.at(-1)).toBe(0);
      expect(shown.at(-1)).toBe(-1);
      recover.resolve();
      await turn();
      reset();
      flush();
      expect(calls.at(-1)).toBe(0);
      expect(shown.at(-1)).toBe(20);
    } finally {
      dispose();
      recover.resolve();
      lowerEnd.resolve();
      upperEnd.resolve();
      await Promise.all([lower, upper]);
      flush();
    }
  });
