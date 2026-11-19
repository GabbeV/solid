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

for (const latestDepth of [1, 2, 3])
  for (const incoming of [20, 999]) {
    it(`pending through ${latestDepth} latest outputs retains the optimistic input question (answer=${incoming})`, async () => {
      const answer = Promise.withResolvers<number>();
      const end = Promise.withResolvers<void>();
      const [id, setId] = createSignal(0);
      let guess!: (value: number) => number;
      const shown = { value: 10, pending: false };
      const dispose = createRoot(dispose => {
        const input = createMemo(() => (id() ? answer.promise : 10));
        const [value, setValue] = createOptimistic(input);
        guess = setValue;
        let ahead = value;
        for (let i = 0; i < latestDepth; i++) {
          const previous = ahead;
          ahead = () => latest(previous);
        }
        createRenderEffect(ahead, value => {
          shown.value = value;
        });
        createRenderEffect(
          () => isPending(ahead),
          value => {
            shown.pending = value;
          }
        );
        return dispose;
      });
      flush();
      const running = action(function* () {
        guess(999);
        setId(1);
        yield end.promise;
      })();
      try {
        flush();
        expect({ ...shown }).toEqual({ value: 999, pending: true });
        answer.resolve(incoming);
        await new Promise(resolve => setTimeout(resolve, 0));
        expect({ ...shown }).toEqual({ value: 999, pending: incoming !== 999 });
      } finally {
        answer.resolve(incoming);
        end.resolve();
        await running;
        await new Promise(resolve => setTimeout(resolve, 0));
        flush();
        dispose();
      }
      expect({ ...shown }).toEqual({ value: incoming, pending: false });
    });
  }
