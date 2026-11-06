import { afterEach, expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending as publicPending,
  refresh,
  resetErrorHalt,
  type SourceAccessor
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";
import { isPending } from "../src/layers/pending.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
  resetErrorHalt();
});

it("layer: a repeated functional guess composes on the retained override", async () => {
  const repeat = gate<void>(),
    end = gate<void>();
  const [input, setInput] = createSignal(0);
  let guess!: (value: number | ((previous: number) => number)) => number;
  let shown = 0;
  const previousValues: number[] = [];
  createRoot(dispose => {
    disposals.push(dispose);
    const [view, write] = createLayer(input, { lifetime: "action" });
    guess = write;
    createRenderEffect(view, next => {
      shown = next;
    });
  });
  const running = action(function* () {
    guess(1);
    yield repeat.promise;
    guess(previous => {
      previousValues.push(previous);
      return previous + 1;
    });
    yield end.promise;
  })();
  flush();
  setInput(10);
  flush();
  expect(shown).toBe(1);
  repeat.resolve();
  await turn();
  expect(previousValues).toEqual([1]);
  expect(shown).toBe(2);
  end.resolve();
  await running;
  await turn();
  expect(shown).toBe(10);
  expect(previousValues).toEqual([1]);
});

// Both implementations entangle actions that guess the same output. The
// shared prototype keeps the selector overridden until that joint lifetime
// ends, so an intermediate input answer cannot start downstream correction.
for (const implementation of ["public API", "explicit layer"] as const) {
  const optimistic = (input: () => number) =>
    implementation === "public API"
      ? createOptimistic(input)
      : createLayer(input, { lifetime: "action" });

  for (const equal of [false, true])
    for (const newerEndsFirst of [false, true]) {
      it(`${implementation}: guesses share their lifetime (equal=${equal}, newerEndsFirst=${newerEndsFirst})`, async () => {
        const olderEnd = gate<void>(),
          newerEnd = gate<void>();
        let guess!: (value: number) => number;
        let shown = 0;
        createRoot(dispose => {
          disposals.push(dispose);
          const [value, write] = optimistic(() => 0);
          guess = write;
          createRenderEffect(value, next => {
            shown = next;
          });
        });
        const start = action(function* (value: number, end: Promise<void>) {
          guess(value);
          yield end;
        });
        const older = start(equal ? 2 : 1, olderEnd.promise);
        flush();
        expect(shown).toBe(equal ? 2 : 1);
        const newer = start(2, newerEnd.promise);
        flush();
        expect(shown).toBe(2);
        (newerEndsFirst ? newerEnd : olderEnd).resolve();
        await (newerEndsFirst ? newer : older);
        await turn();
        expect(shown).toBe(2);
        (newerEndsFirst ? olderEnd : newerEnd).resolve();
        await (newerEndsFirst ? older : newer);
        await turn();
        expect(shown).toBe(0);
      });
    }

  it(`${implementation}: an input correction begins downstream at its chosen release point`, async () => {
    const end = gate<void>(),
      detailsAnswer = gate<number>();
    const [input, setInput] = createSignal(0);
    let guess!: (value: number) => number;
    let startedCorrection = false;
    const shown = { value: 0, details: 0 };
    createRoot(dispose => {
      disposals.push(dispose);
      const [value, write] = optimistic(input);
      guess = write;
      const details = createMemo(() => {
        const next = value();
        if (next !== 2) return next * 10;
        startedCorrection = true;
        return detailsAnswer.promise;
      });
      createRenderEffect(value, next => {
        shown.value = next;
      });
      createRenderEffect(details, next => {
        shown.details = next;
      });
    });
    const running = action(function* () {
      guess(1);
      yield end.promise;
    })();
    flush();
    setInput(2);
    flush();
    expect(shown).toEqual({ value: 1, details: 10 });
    // Accepted change: the common selector delays even a relevant correction
    // until the action ends. Upstream starts that work beneath its override.
    expect(startedCorrection).toBe(false);
    end.resolve();
    await running;
    await turn();
    expect(startedCorrection).toBe(true);
    expect(shown).toEqual({ value: 1, details: 10 });
    detailsAnswer.resolve(20);
    await turn();
    expect(shown).toEqual({ value: 2, details: 20 });
  });

  it(`${implementation}: an older action answers beneath a guess whose shared lifetime remains open`, async () => {
    const oldSaved = gate<void>(),
      newSaved = gate<void>();
    const oldAnswer = gate<number>(),
      oldDetails = gate<number>();
    let inputResult: number | Promise<number> = 0;
    let source!: SourceAccessor<number>;
    let guess!: (value: number) => number;
    const shown = { value: 0, details: 0, pending: false };
    const started: number[] = [];
    createRoot(dispose => {
      disposals.push(dispose);
      source = createMemo(() => inputResult);
      const [value, write] =
        implementation === "public API"
          ? createOptimistic(source)
          : createLayer(source, { lifetime: "action" });
      guess = write;
      const details = createMemo(() => {
        const next = value();
        started.push(next);
        return next === 10 ? oldDetails.promise : next * 10;
      });
      createRenderEffect(value, next => {
        shown.value = next;
      });
      createRenderEffect(details, next => {
        shown.details = next;
      });
      createRenderEffect(
        () => (implementation === "public API" ? publicPending : isPending)(details),
        next => {
          shown.pending = next;
        }
      );
    });
    flush();
    const save = action(function* (
      value: number,
      saved: Promise<void>,
      answer: number | Promise<number>
    ) {
      guess(value);
      yield saved;
      inputResult = answer;
      refresh(source);
    });
    const first = save(1, oldSaved.promise, oldAnswer.promise);
    flush();
    expect(shown).toEqual({ value: 1, details: 10, pending: false });
    const second = save(2, newSaved.promise, 20);
    flush();
    expect(shown).toEqual({ value: 2, details: 20, pending: false });
    oldSaved.resolve();
    await first;
    await turn();
    oldAnswer.resolve(10);
    await turn();
    expect(shown).toEqual({ value: 2, details: 20, pending: false });
    expect(started.includes(10)).toBe(false);
    newSaved.resolve();
    await second;
    await turn();
    expect(shown).toEqual({ value: 20, details: 200, pending: false });
    oldDetails.resolve(100);
    await turn();
    expect(shown).toEqual({ value: 20, details: 200, pending: false });
  });
}
