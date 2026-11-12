import { expect, it } from "vitest";
import {
  action,
  createEffect,
  createMemo,
  createOptimisticStore,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

const settle = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(resolve => setTimeout(resolve, 0));
    flush();
  }
};

for (const objects of [false, true])
  for (const withLength of [false, true])
    for (const undefinedError of [false, true])
      it(`store retirement delivers one answer: objects=${objects}, length=${withLength}, undefined=${undefinedError}`, async () => {
        const values: unknown[] = [],
          existing: unknown[] = [];
        const failure = undefinedError ? undefined : new Error("failed");
        let start!: () => unknown,
          finish!: () => void,
          fail!: (bad: boolean) => void,
          reject!: () => void;
        createRoot(() => {
          const [bad, setBad] = createSignal(false);
          fail = setBad;
          let rejected: Promise<any> | undefined;
          const producer = createMemo(() =>
            bad()
              ? (rejected ??= new Promise((_resolve, fail) => {
                  reject = () => fail(failure);
                }))
              : Promise.resolve(objects ? [{ id: 1 }, { id: 3 }] : [1, 3])
          );
          const [store, propose] = createOptimisticStore(
            (draft: any[]) => {
              const answer = producer();
              draft.length = 0;
              draft.push(...answer);
            },
            [],
            objects ? { key: "id" } : undefined
          );
          let resolve!: () => void;
          start = action(function* () {
            propose(draft => {
              draft.push(objects ? { id: 9 } : 9);
            });
            yield new Promise<void>(r => {
              resolve = r;
            });
          });
          finish = () => resolve();
          const read = (index: number) => (objects ? store[index]?.id : store[index]);
          const watch = (fn: () => any, out: unknown[]) =>
            createEffect(fn, {
              effect: value => {
                out.push(value);
              },
              error: error => {
                out.push({ error });
              }
            });
          watch(() => read(2), values);
          watch(() => read(0), existing);
          if (withLength) watch(() => store.length, []);
        });
        await settle();
        start();
        await settle();
        fail(true);
        await settle();
        reject();
        await settle();
        expect(values).toEqual([undefined, 9]);
        expect(existing).toEqual([1, { error: failure }]);
        finish();
        await settle();
        expect(values).toEqual([undefined, 9, { error: failure }]);
        expect(existing).toEqual([1, { error: failure }]);
        fail(false);
        await settle();
        expect(values.at(-1)).toBe(undefined);
        expect(existing.at(-1)).toBe(1);
        fail(true);
        await settle();
        expect(values).toEqual([undefined, 9, { error: failure }, undefined, { error: failure }]);
        expect(existing).toEqual([1, { error: failure }, 1, { error: failure }]);
      });
