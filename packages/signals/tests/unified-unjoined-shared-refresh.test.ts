import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  flush,
  refresh
} from "../src/index.js";
const tick = () => new Promise<void>(resolve => setTimeout(resolve, 0));
for (const form of ["scalar", "direct"] as const)
  it.each([false, true])(
    `a shared refresh does not merge two independent guessing actions (${form}, async=%s)`,
    async asyncInput => {
      const aEnd = Promise.withResolvers<void>(),
        bEnd = Promise.withResolvers<void>();
      let refreshInputs!: () => void;
      const answer = Promise.withResolvers<{ a: number; b: number }>();
      let guessA!: (v: number) => void, guessB!: (v: number) => void;
      let shown: unknown;
      let incoming: { a: number; b: number } | Promise<{ a: number; b: number }> = { a: 0, b: 0 };
      const dispose = createRoot(dispose => {
        let a: () => number, b: () => number;
        if (form === "scalar") {
          const data = createMemo(() => incoming);
          const [left, ga] = createOptimistic(() => data().a);
          const [right, gb] = createOptimistic(() => data().b);
          a = left;
          b = right;
          guessA = ga;
          guessB = gb;
          refreshInputs = () => {
            void refresh(data);
          };
        } else {
          const [left, ga] = createOptimistic(() =>
            incoming instanceof Promise ? incoming.then(v => v.a) : incoming.a
          );
          const [right, gb] = createOptimistic(() =>
            incoming instanceof Promise ? incoming.then(v => v.b) : incoming.b
          );
          a = left;
          b = right;
          guessA = ga;
          guessB = gb;
          refreshInputs = () => {
            void refresh(left);
            void refresh(right);
          };
        }
        createRenderEffect(
          () => [a(), b()],
          v => {
            shown = v;
          }
        );
        return dispose;
      });
      flush();
      const a = action(function* () {
        guessA(10);
        yield aEnd.promise;
      })();
      flush();
      const b = action(function* () {
        guessB(20);
        yield bEnd.promise;
      })();
      flush();
      try {
        expect(shown).toEqual([10, 20]);
        incoming = asyncInput ? answer.promise : { a: 1, b: 2 };
        refreshInputs();
        flush();
        answer.resolve({ a: 1, b: 2 });
        await tick();
        flush();
        expect(shown).toEqual([10, 20]);
        aEnd.resolve();
        await tick();
        flush();
        expect(shown).toEqual([1, 20]);
        bEnd.resolve();
        await Promise.all([a, b]);
        await tick();
        flush();
        expect(shown).toEqual([1, 2]);
      } finally {
        answer.resolve({ a: 1, b: 2 });
        aEnd.resolve();
        bEnd.resolve();
        await Promise.all([a, b]);
        dispose();
        flush();
      }
    }
  );
