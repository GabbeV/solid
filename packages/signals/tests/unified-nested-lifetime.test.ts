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

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

// Public nesting: both guesses are made by event/action code. This does not
// replace lane-contract's separate coverage of a setter called in a derivation.
it("a nested override publishes and expires while its input override remains active", async () => {
  const inputAnswer = Promise.withResolvers<number>();
  const childAnswer = Promise.withResolvers<number>();
  const childEnd = Promise.withResolvers<void>();
  const shown = { input: 0, first: 0, second: 0, result: 0 };
  let startParent!: () => void;
  let startChild!: () => Promise<unknown>;
  const dispose = createRoot(dispose => {
    const [id, setId] = createSignal(0);
    const input = createMemo(() => (id() ? inputAnswer.promise : 0));
    const [first, guessFirst] = createOptimistic(input);
    const [second, guessSecond] = createOptimistic(() => first() * 2);
    const result = createMemo(() => (second() === 4 ? childAnswer.promise : second()));
    createRenderEffect(
      input,
      value => {
        shown.input = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      first,
      value => {
        shown.first = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      second,
      value => {
        shown.second = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      result,
      value => {
        shown.result = value;
      },
      { schedule: true }
    );
    startParent = () => {
      setId(1);
      guessFirst(1);
    };
    startChild = action(function* () {
      guessSecond(4);
      yield childEnd.promise;
    });
    return dispose;
  });
  try {
    flush();
    expect(shown).toEqual({ input: 0, first: 0, second: 0, result: 0 });
    startParent();
    flush();
    expect(shown).toEqual({ input: 0, first: 1, second: 2, result: 2 });
    const running = startChild();
    flush();
    expect(shown).toEqual({ input: 0, first: 1, second: 2, result: 2 });
    childAnswer.resolve(4);
    await turn();
    expect(shown).toEqual({ input: 0, first: 1, second: 4, result: 4 });
    childEnd.resolve();
    await running;
    await turn();
    expect(shown).toEqual({ input: 0, first: 1, second: 2, result: 2 });
    inputAnswer.resolve(3);
    await turn();
    expect(shown).toEqual({ input: 3, first: 3, second: 6, result: 6 });
  } finally {
    childEnd.resolve();
    childAnswer.resolve(4);
    inputAnswer.resolve(3);
    dispose();
    flush();
  }
});
