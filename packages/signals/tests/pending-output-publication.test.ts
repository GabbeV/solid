import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const depth of [0, 1, 3])
  for (const answer of [5, 7])
    it(`publishing an optimistic output does not retire its unresolved input question (latest depth=${depth}, answer=${answer})`, async () => {
      const inputAnswer = Promise.withResolvers<number>();
      const detailAnswer = Promise.withResolvers<number>();
      const end = Promise.withResolvers<void>();
      const values: number[] = [], pending: boolean[] = [], details: number[] = [];
      let run!: () => Promise<void>;
      const dispose = createRoot(dispose => {
        const [id, setId] = createSignal(0);
        const input = createMemo(() => id() ? inputAnswer.promise : 0);
        const [value, guess] = createOptimistic(input);
        const detail = createMemo(() => value() === 5 ? detailAnswer.promise : value() * 10);
        let preview = value;
        for (let i = 0; i < depth; i++) {
          const previous = preview;
          preview = () => latest(previous);
        }
        createRenderEffect(preview, value => { values.push(value); });
        createRenderEffect(detail, value => { details.push(value); });
        const waiting = createMemo(() => isPending(preview));
        createRenderEffect(waiting, value => { pending.push(value); });
        run = action(function* () {
          setId(1);
          guess(5);
          yield end.promise;
        });
        return dispose;
      });
      flush();
      const running = run();
      try {
        flush();
        expect(pending).toEqual([false, true]);
        detailAnswer.resolve(50);
        await turn();
        expect(values).toEqual([0, 5]);
        expect(details).toEqual([0, 50]);
        // Publishing the guess must not produce a false/true flicker while
        // the input request remains unresolved.
        expect(pending).toEqual([false, true]);
        inputAnswer.resolve(answer);
        await turn();
        expect(pending).toEqual(answer === 5 ? [false, true, false] : [false, true]);
        expect(values).toEqual([0, 5]);
        end.resolve();
        await running;
        await turn();
        expect(values).toEqual(answer === 5 ? [0, 5] : [0, 5, 7]);
        expect(details).toEqual(answer === 5 ? [0, 50] : [0, 50, 70]);
        expect(pending).toEqual([false, true, false]);
      } finally {
        inputAnswer.resolve(answer);
        detailAnswer.resolve(50);
        end.resolve();
        await running;
        dispose();
        flush();
      }
    });
