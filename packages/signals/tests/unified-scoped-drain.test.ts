import { expect, it } from "vitest";
import {
  action, createMemo, createOptimistic, createRenderEffect, createRoot, createSignal,
  flush, onCleanup
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const owned of [false, true]) {
  it(`a chain keeps publication and cleanup coherent across superseded holds (computed owner=${owned})`, async () => {
    const end = Promise.withResolvers<void>();
    const obsolete = Promise.withResolvers<void>();
    const answer = Promise.withResolvers<void>();
    let guess!: (value: number) => number;
    let tick!: (value: number) => number;
    let shown: readonly number[] = [], sibling: readonly number[] = [];
    const cleaned: number[] = [];
    const dispose = createRoot(dispose => {
      const build = () => {
        const [view, write] = createOptimistic(0);
        const [other, setOther] = createSignal(0);
        guess = write;
        tick = setOther;
        const first = createMemo(() => {
          const value = view();
          onCleanup(() => cleaned.push(value));
          return value;
        });
        const second = createMemo(() => first() + 1);
        const third = createMemo(() => second() + 1);
        const data = createMemo(() => {
          const value = third() - 2;
          if (value === 2) return obsolete.promise.then(() => value * 10);
          if (value === 3) return answer.promise.then(() => value * 10);
          return value * 10;
        });
        createRenderEffect(() => [view(), data(), other()], value => { shown = value; }, { schedule: true });
        createRenderEffect(() => [view(), other()], value => { sibling = value; }, { schedule: true });
      };
      if (owned) createMemo(() => { build(); return null; });
      else build();
      return dispose;
    });
    flush();
    const running = action(function* () { guess(1); yield end.promise; })();
    try {
      flush();
      expect(shown).toEqual([1, 10, 0]);
      expect(cleaned).toEqual([0]);
      guess(2);
      flush();
      tick(1);
      flush();
      expect(shown).toEqual([1, 10, 1]);
      expect(sibling).toEqual([1, 1]);
      expect(cleaned).not.toContain(1);
      guess(3);
      flush();
      expect(cleaned).toContain(2);
      expect(cleaned).not.toContain(1);
      obsolete.resolve();
      await turn();
      flush();
      expect(shown).toEqual([1, 10, 1]);
      expect(sibling).toEqual([1, 1]);
      answer.resolve();
      await turn();
      flush();
      expect(shown).toEqual([3, 30, 1]);
      expect(sibling).toEqual([3, 1]);
      expect(cleaned).toContain(1);
      end.resolve();
      await running;
      flush();
      expect(shown).toEqual([0, 0, 1]);
      expect(sibling).toEqual([0, 1]);
    } finally {
      obsolete.resolve();
      answer.resolve();
      end.resolve();
      await running;
      dispose();
      flush();
    }
  });
}
