import { afterEach, expect, expectTypeOf, it } from "vitest";
import {
  action,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  refresh
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
function gate() {
  let resolve!: () => void;
  const promise = new Promise<void>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

for (const refetch of [false, true])
  it(`input previous results remain separate from functional guesses (refresh=${refetch})`, async () => {
    const recalculate = gate(),
      guessAgain = gate(),
      recalculateAgain = gate(),
      end = gate();
    const previousInputs: (number | undefined)[] = [],
      previousGuesses: number[] = [];
    const answers: number[] = [],
      publications: number[] = [];
    let guess!: (value: number | ((previous: number) => number)) => number;
    let view!: () => number;
    const [step, setStep] = createSignal(refetch ? 1 : 0);
    createRoot(dispose => {
      disposals.push(dispose);
      [view, guess] = createOptimistic<number>(previous => {
        expectTypeOf(previous).toEqualTypeOf<number | undefined>();
        previousInputs.push(previous);
        return (previous ?? 0) + step();
      });
      createRenderEffect(
        view,
        value => {
          publications.push(value);
        },
        { schedule: true }
      );
    });
    flush();
    const initial = refetch ? 1 : 0;
    const running = action(function* () {
      guess(10);
      yield recalculate.promise;
      if (refetch) answers.push(yield refresh(view));
      else setStep(1);
      yield guessAgain.promise;
      guess(previous => {
        previousGuesses.push(previous);
        return previous + 1;
      });
      yield recalculateAgain.promise;
      if (refetch) answers.push(yield refresh(view));
      else setStep(2);
      yield end.promise;
    })();
    try {
      await turn();
      expect(publications).toEqual([initial, 10]);
      recalculate.resolve();
      await turn();
      expect(previousInputs).toEqual([undefined, initial]);
      expect(publications).toEqual([initial, 10]);
      guessAgain.resolve();
      await turn();
      expect(previousGuesses).toEqual([10]);
      expect(publications).toEqual([initial, 10, 11]);
      recalculateAgain.resolve();
      await turn();
      // The second input run is still staged. The next run uses that input
      // result, just as an ordinary held memo does, without feeding back 11.
      expect(previousInputs).toEqual([undefined, initial, initial + 1]);
      expect(publications).toEqual([initial, 10, 11]);
      if (refetch) expect(answers).toEqual([2, 3]);
      end.resolve();
      await running;
      await turn();
      expect(publications).toEqual([initial, 10, 11, 3]);
    } finally {
      recalculate.resolve();
      guessAgain.resolve();
      recalculateAgain.resolve();
      end.resolve();
      await running;
    }
  });
