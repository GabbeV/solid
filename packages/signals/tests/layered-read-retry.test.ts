import { afterEach, expect, it } from "vitest";
import {
  action,
  createMemo,
  createRoot,
  createRenderEffect,
  createSignal,
  flush,
  isPending,
  latest,
  onCleanup
} from "../src/index.js";
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

for (const wrapped of [false, true])
  for (const observe of [latest, isPending])
    for (const asynchronous of [false, true, "iterator"] as const)
      for (const childDepth of [0, 1, 3]) {
        it(`stops at first ${observe.name} discovery before completing a conflicting body (async=${asynchronous}, children=${childDepth}, wrapped=${wrapped})`, async () => {
          const end = Promise.withResolvers<void>();
          const [source, write] = createSignal(0);
          const bodies: unknown[][] = [],
            owners: { cleanups: number }[] = [],
            iterators: { closed: number }[] = [];
          const running = action(function* () {
            write(1);
            yield end.promise;
          })();
          flush();
          let shown: unknown;
          let attempts = 0;
          let stop = () => {};
          const child = (depth: number): unknown => {
            if (!depth) return observe(wrapped ? () => source() : source);
            return createMemo(() => {
              const owner = { cleanups: 0 };
              owners.push(owner);
              onCleanup(() => owner.cleanups++);
              return child(depth - 1);
            })();
          };
          try {
            createRoot(dispose => {
              disposals.push(dispose);
              stop = dispose;
              const calculate = () => {
                // Bound a publication loop without allowing it to pass the test.
                if (++attempts > 32) {
                  stop();
                  return [];
                }
                const first = source();
                const observed = child(childDepth);
                const last = source();
                const result = [first, observed, last];
                bodies.push(result);
                return result;
              };
              const pair = createMemo(
                asynchronous === "iterator"
                  ? async function* () {
                      const iterator = { closed: 0 };
                      iterators.push(iterator);
                      try {
                        yield calculate();
                      } finally {
                        iterator.closed++;
                      }
                    }
                  : asynchronous
                    ? async () => calculate()
                    : calculate
              );
              createRenderEffect(
                pair,
                value => {
                  shown = value;
                },
                { schedule: true }
              );
            });
            await turn();
            flush();
            const expected = [0, observe === latest ? 1 : true, 0];
            expect(attempts, "calculation must converge").toBeLessThanOrEqual(32);
            expect(shown).toEqual(expected);
            expect(bodies.length).toBeGreaterThan(0);
            for (const body of bodies) expect(body).toEqual(expected);
          } finally {
            for (const dispose of disposals.splice(0)) dispose();
            end.resolve();
            await running;
            await turn();
            flush();
            expect(owners.every(owner => owner.cleanups === 1)).toBe(true);
            expect(iterators.every(iterator => iterator.closed === 1)).toBe(true);
          }
        });
      }
