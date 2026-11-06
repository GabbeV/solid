import { expect, it } from "vitest";
import { $REFRESH } from "../src/core/constants.js";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  type SourceAccessor
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const callback of [false, true])
  it(`imperative observations revive after an unobserved first answer (callback=${callback})`, async () => {
    const [version, setVersion] = createSignal(0);
    let answer = Promise.withResolvers<number>();
    let data!: SourceAccessor<number>;
    const screen: number[] = [];
    const dispose = createRoot(dispose => {
      data = createMemo(() => {
        version();
        return answer.promise;
      });
      createRenderEffect(data, value => void screen.push(value));
      return dispose;
    });
    const query = () => isPending(callback ? () => data() : data);
    const subscribers = () => {
      let count = 0;
      for (let s = data[$REFRESH]._subs; s; s = s._nextSub) count++;
      return count;
    };
    try {
      expect(query()).toBe(false);
      answer.resolve(0);
      await turn();
      expect(query()).toBe(false);
      expect(latest(data)).toBe(0);
      flush();
      const settledSubscribers = subscribers();
      for (let value = 1; value <= 10; value++) {
        answer = Promise.withResolvers<number>();
        setVersion(value);
        flush();
        expect(query()).toBe(true);
        expect(latest(data)).toBe(value - 1);
        expect(screen.at(-1)).toBe(value - 1);
        answer.resolve(value);
        await turn();
        expect(query()).toBe(false);
        expect(latest(data)).toBe(value);
        expect(screen.at(-1)).toBe(value);
        flush();
        expect(subscribers()).toBe(settledSubscribers);
      }
      expect(screen).toEqual(Array.from({ length: 11 }, (_, i) => i));
    } finally {
      dispose();
      flush();
    }
  });
