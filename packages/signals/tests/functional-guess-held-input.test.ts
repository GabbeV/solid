import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

it("a functional guess starts from its published output while another update holds its input", async () => {
  const inputDone = Promise.withResolvers<void>();
  const guessDone = Promise.withResolvers<void>();
  const [source, setSource] = createSignal(0);
  let guess!: (value: (previous: number) => number) => number;
  let sourceShown = -1;
  let viewShown = -1;
  const previousValues: number[] = [];
  const dispose = createRoot(dispose => {
    const [view, setView] = createOptimistic(source);
    guess = setView;
    createRenderEffect(source, value => {
      sourceShown = value;
    });
    createRenderEffect(view, value => {
      viewShown = value;
    });
    return dispose;
  });
  flush();
  const changingInput = action(function* () {
    setSource(10);
    yield inputDone.promise;
  })();
  flush();
  expect([sourceShown, viewShown]).toEqual([0, 0]);
  const guessing = action(function* () {
    guess(previous => {
      previousValues.push(previous);
      return previous + 1;
    });
    yield guessDone.promise;
  })();
  flush();
  try {
    expect({ previousValues, sourceShown, viewShown }).toEqual({
      previousValues: [0],
      sourceShown: 0,
      viewShown: 1
    });
  } finally {
    inputDone.resolve();
    guessDone.resolve();
    await Promise.all([changingInput, guessing]);
    flush();
    dispose();
  }
});

it("subsequent functional guesses compose before flush and while their output is held", async () => {
  const inputDone = Promise.withResolvers<void>();
  const guessAgain = Promise.withResolvers<void>();
  const guessDone = Promise.withResolvers<void>();
  const detailsDone = Promise.withResolvers<void>();
  const [source, setSource] = createSignal(0);
  const previousValues: number[] = [];
  let guess!: (value: (previous: number) => number) => number;
  let shown: number[] = [];
  const dispose = createRoot(dispose => {
    const [view, setView] = createOptimistic(source);
    guess = setView;
    const details = createMemo(() => {
      const value = view();
      return value === 0 ? 0 : detailsDone.promise.then(() => value * 2);
    });
    createRenderEffect(
      () => [source(), view(), details()],
      value => {
        shown = value;
      }
    );
    return dispose;
  });
  const increment = (previous: number) => {
    previousValues.push(previous);
    return previous + 1;
  };
  flush();
  const changingInput = action(function* () {
    setSource(10);
    yield inputDone.promise;
  })();
  flush();
  const guessing = action(function* () {
    guess(increment);
    guess(increment);
    yield guessAgain.promise;
    guess(increment);
    yield guessDone.promise;
  })();
  try {
    flush();
    expect(previousValues).toEqual([0, 1]);
    expect(shown).toEqual([0, 0, 0]);

    guessAgain.resolve();
    await new Promise(resolve => setTimeout(resolve, 0));
    expect(previousValues).toEqual([0, 1, 2]);
    expect(shown).toEqual([0, 0, 0]);

    detailsDone.resolve();
    await new Promise(resolve => setTimeout(resolve, 0));
    expect(shown).toEqual([0, 3, 6]);
  } finally {
    guessAgain.resolve();
    detailsDone.resolve();
    inputDone.resolve();
    guessDone.resolve();
    await Promise.all([changingInput, guessing]);
    await new Promise(resolve => setTimeout(resolve, 0));
    flush();
    dispose();
  }
  expect(shown).toEqual([10, 10, 20]);
});
