import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  onCleanup
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const observe of [false, true])
  for (const owned of [false, true, "split"] as const)
    it(`only accepted proposal reads merge their actions (observation=${observe}, owned=${owned})`, async () => {
      const aEnd = Promise.withResolvers<void>(),
        bEnd = Promise.withResolvers<void>();
      const [a, setA] = createSignal(0),
        [b, setB] = createSignal(0);
      const shown = [0, 0];
      const owners: { cleanups: number }[] = [];
      let disposeInputs = () => {},
        disposeReader = () => {};
      let pair: unknown;
      createRoot(dispose => {
        disposeInputs = dispose;
        [a, b].forEach((read, index) =>
          createRenderEffect(read, value => {
            shown[index] = value;
          })
        );
      });
      const aRunning = action(function* () {
        setA(1);
        yield aEnd.promise;
      })();
      flush();
      const bRunning = action(function* () {
        setB(2);
        yield bEnd.promise;
      })();
      flush();
      try {
        createRoot(dispose => {
          disposeReader = dispose;
          const value = createMemo(() => {
            const read = () => a() + b();
            const child = (read: () => number) =>
              createMemo(() => {
                const owner = { cleanups: 0 };
                owners.push(owner);
                onCleanup(() => owner.cleanups++);
                return read();
              });
            let sum: number;
            if (owned === "split") {
              const first = child(a),
                second = child(b);
              sum = first() + second();
            } else sum = owned ? child(read)() : read();
            return [sum, observe && isPending(a)];
          });
          createRenderEffect(
            value,
            result => {
              pair = result;
            },
            { schedule: true }
          );
        });
        flush();
        expect(pair).toEqual(observe ? [0, true] : undefined);
        disposeReader();
        flush();
        expect(owners.every(owner => owner.cleanups === 1)).toBe(true);

        // Removing the reader does not reverse a real peer merge. The aborted
        // lower-context attempts, however, must never have performed that merge.
        aEnd.resolve();
        await aRunning;
        await turn();
        flush();
        expect(shown).toEqual(observe ? [1, 0] : [0, 0]);
        bEnd.resolve();
        await bRunning;
        await turn();
        flush();
        expect(shown).toEqual([1, 2]);
      } finally {
        disposeReader();
        disposeInputs();
        aEnd.resolve();
        bEnd.resolve();
        await Promise.all([aRunning, bRunning]);
        await turn();
        flush();
      }
    });
