import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createStore,
  flush
} from "../src/index.js";

for (const retired of [false, true])
  for (const initial of [[1, 2], [1], []])
    it(`publishes chained growth after an earlier resize to ${JSON.stringify(initial)} (retired=${retired})`, async () => {
      const endA = Promise.withResolvers<void>();
      const endB = Promise.withResolvers<void>();
      const frames: string[] = [];
      const [view, set, setBase, dispose] = createRoot(dispose => {
        const [base, setBase] = createStore([1, 2]);
        const [view, set] = createOptimisticStore(base);
        const text = createMemo(() => view.join(","));
        createRenderEffect(text, value => {
          frames.push(value);
        });
        return [view, set, setBase, dispose] as const;
      });
      let a, b;
      try {
        flush();
        a = action(function* () {
          set(d => {
            d.length = initial.length;
          });
          yield endA.promise;
        })();
        flush();
        if (retired) {
          setBase(d => {
            d.length = initial.length;
          });
          flush();
          endA.resolve();
          await a;
          flush();
        }
        b = action(function* () {
          set(d => {
            d.push(3);
          });
          yield endB.promise;
        })();
        flush();
        expect(frames.at(-1)).toBe([...initial, 3].join(","));
        expect(view.join(",")).toBe([...initial, 3].join(","));
      } finally {
        endA.resolve();
        endB.resolve();
        await Promise.all([a, b]);
        flush();
        dispose();
        flush();
      }
    });
