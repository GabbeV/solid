import { afterEach, expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";

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
});

for (const implementation of ["public API", "explicit layer"] as const)
  for (const bodyOpen of [false, true])
    it(`${implementation}: correction avoids waiting for an obsolete guess flight (bodyOpen=${bodyOpen})`, async () => {
      const answer = gate<number>(),
        end = gate<void>();
      const guessedDetails = gate<number>(),
        correctedDetails = gate<number>();
      const [revision, setRevision] = createSignal(0);
      const calculations: number[] = [];
      const shown = { value: 0, details: 0 };
      let guess!: (value: number) => number;
      createRoot(dispose => {
        disposals.push(dispose);
        const input = createMemo(() => (revision() ? answer.promise : 0));
        const [view, write] =
          implementation === "public API"
            ? createOptimistic(input)
            : createLayer(input, { lifetime: "action" });
        guess = write;
        const details = createMemo(() => {
          const value = view();
          calculations.push(value);
          return value === 3 ? guessedDetails.promise : value === 2 ? correctedDetails.promise : 0;
        });
        createRenderEffect(view, value => {
          shown.value = value;
        });
        createRenderEffect(details, value => {
          shown.details = value;
        });
      });
      const running = action(function* () {
        setRevision(1);
        guess(3);
        yield end.promise;
      })();
      flush();
      expect(calculations).toEqual([0, 3]);
      expect(shown).toEqual({ value: 0, details: 0 });
      if (!bodyOpen) {
        end.resolve();
        await running;
        await turn();
      }
      answer.resolve(2);
      await turn();
      expect(calculations).toEqual(bodyOpen ? [0, 3] : [0, 3, 2]);
      expect(shown).toEqual({ value: 0, details: 0 });
      end.resolve();
      await running;
      await turn();
      expect(calculations).toEqual([0, 3, 2]);
      // The correction can finish before the wrong guess's work answers.
      correctedDetails.resolve(20);
      await turn();
      expect(shown).toEqual({ value: 2, details: 20 });
      guessedDetails.resolve(30);
      await turn();
      expect(shown).toEqual({ value: 2, details: 20 });
    });
