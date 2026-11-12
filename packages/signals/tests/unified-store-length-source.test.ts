import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  flush,
  NotReadyError
} from "../src/index.js";
const turn = async () => {
  await new Promise(r => setTimeout(r, 0));
  flush();
};

for (const resize of [false, true])
  it(`${resize ? "a resize replaces" : "a growth floor consumes"} an unanswered length input`, async () => {
    const input = Promise.withResolvers<number[]>();
    const finish = Promise.withResolvers<void>();
    const [list, set] = createOptimisticStore(() => input.promise, [] as number[]);
    flush();
    const running = action(function* () {
      set(d => {
        if (resize) d.length = 3;
        else d.push(9);
      });
      yield finish.promise;
    })();
    flush();
    const shown: number[] = [];
    const dispose = createRoot(dispose => {
      createRenderEffect(
        () => list.length,
        n => void shown.push(n)
      );
      return dispose;
    });
    try {
      flush();
      expect(shown).toEqual(resize ? [3] : []);
      if (resize) expect(list.length).toBe(3);
      else expect(() => list.length).toThrow(NotReadyError);
      input.resolve([1, 2]);
      await turn();
      expect(shown.at(-1)).toBe(resize ? 3 : 2);
      finish.resolve();
      await running;
      await turn();
      expect(shown.at(-1)).toBe(2);
    } finally {
      input.resolve([1, 2]);
      finish.resolve();
      await running;
      dispose();
      await turn();
    }
  });
