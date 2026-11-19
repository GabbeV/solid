import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const keyed of [false, true])
  for (const first of [0, 1])
    it(`reversing ${keyed ? "keyed rows" : "primitive values"} joins the untouched middle index, ending ${first} first`, async () => {
      const initial: any[] = keyed
        ? [
            { id: "a", n: 0 },
            { id: "b", n: 0 },
            { id: "c", n: 0 }
          ]
        : ["a", "b", "c"];
      const ends = [Promise.withResolvers<void>(), Promise.withResolvers<void>()];
      const shown: any[][] = [],
        flags: boolean[][] = [];
      const [a, setA] = createSignal(false),
        [b, setB] = createSignal(false);
      const [guess, dispose] = createRoot(dispose => {
        const [rows, guess] = createOptimisticStore(initial, keyed ? { key: "id" } : undefined);
        createRenderEffect(
          () => Array.from(rows, row => (keyed ? `${row.id}:${row.n}` : row)),
          value => {
            shown.push(value);
          }
        );
        createRenderEffect(
          () => [a(), b()],
          value => {
            flags.push(value);
          }
        );
        return [guess, dispose] as const;
      });
      const running: Promise<unknown>[] = [];
      try {
        flush();
        running.push(
          action(function* () {
            guess(draft => {
              draft[1] = keyed ? { id: "b", n: 9 } : "M";
            });
            setA(true);
            yield ends[0].promise;
          })()
        );
        flush();
        running.push(
          action(function* () {
            // reverse reads/writes the ends, but does not visit the middle slot.
            guess(draft => {
              draft.reverse();
            });
            setB(true);
            yield ends[1].promise;
          })()
        );
        flush();
        expect(shown.at(-1)).toEqual(keyed ? ["c:0", "b:9", "a:0"] : ["c", "M", "a"]);
        ends[first].resolve();
        await running[first];
        await turn();
        expect(flags.at(-1)).toEqual([false, false]);
        expect(shown.at(-1)).toEqual(keyed ? ["c:0", "b:9", "a:0"] : ["c", "M", "a"]);
        ends[1 - first].resolve();
        await Promise.all(running);
        await turn();
        expect(flags.at(-1)).toEqual([true, true]);
        expect(shown.at(-1)).toEqual(keyed ? ["a:0", "b:0", "c:0"] : ["a", "b", "c"]);
      } finally {
        for (const end of ends) end.resolve();
        await Promise.allSettled(running);
        dispose();
        flush();
      }
    });
