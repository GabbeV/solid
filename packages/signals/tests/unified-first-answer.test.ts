import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  flush,
  latest
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it.each([1, 3].flatMap(depth => [true, false].map(sameAction => ({ depth, sameAction }))))(
  "first-answer delivery at depth $depth (action flush before delivery: $sameAction)",
  async ({ depth, sameAction }) => {
    const lifetime = Promise.withResolvers<void>();
    const again = Promise.withResolvers<void>();
    const requests: { key: number; answer: ReturnType<typeof Promise.withResolvers<number>> }[] =
      [];
    const guesses: ((value: number) => unknown)[] = [];
    const shown: number[] = [];
    const dispose = createRoot(dispose => {
      let value = () => 0;
      for (let i = 0; i < depth; i++) {
        const input = value;
        const [output, guess] = createOptimistic(() => input());
        guesses.push(guess);
        value = createMemo(() => output());
      }
      const data = createMemo(() => {
        const key = value();
        const answer = Promise.withResolvers<number>();
        requests.push({ key, answer });
        return answer.promise;
      });
      const doubled = createMemo(() => data() * 2);
      createRenderEffect(
        () => latest(doubled),
        value => void shown.push(value)
      );
      return dispose;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      await turn();
      running = action(function* () {
        guesses.forEach((guess, i) => guess(i + 1));
        if (sameAction) {
          yield again.promise;
          requests.at(-1)!.answer.resolve(10);
          guesses.at(-1)!(depth + 1);
        }
        yield lifetime.promise;
      })();
      flush();
      await turn();
      expect(requests.at(-1)?.key).toBe(depth);
      if (sameAction) again.resolve();
      else {
        requests.at(-1)!.answer.resolve(10);
        guesses.at(-1)!(depth + 1);
      }
      await turn();
      flush();
      // An action flushes synchronously when its generator yields. In that
      // case the replacement supersedes the request before its reaction runs,
      // as in next. An ordinary setter leaves delivery ahead of the flush.
      const delivered = sameAction ? [] : [20];
      expect(shown).toEqual(delivered);
      expect(requests.at(-1)?.key).toBe(depth + 1);

      // The abandoned initial request cannot overwrite the accepted answer.
      requests[0].answer.resolve(-1);
      await turn();
      expect(shown).toEqual(delivered);
      requests.at(-1)!.answer.resolve(30);
      await turn();
      flush();
      expect(shown).toEqual([...delivered, 60]);
    } finally {
      dispose();
      again.resolve();
      lifetime.resolve();
      await running;
      flush();
    }
  }
);
