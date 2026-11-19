import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  mapArray
} from "../src/index.js";
const turn = async () => {
  for (let i = 0; i < 3; i++) {
    await new Promise(resolve => setTimeout(resolve, 0));
    flush();
  }
};
for (const producerKind of ["async-store", "async-memo"] as const)
  it(`two wrappers follow a held ${producerKind} replacement without joining its inner actions`, async () => {
    const endA = Promise.withResolvers<void>(),
      endB = Promise.withResolvers<void>();
    let producer = Promise.withResolvers<void>();
    producer.resolve();
    const direct: string[] = [],
      mapped: string[] = [],
      saved: boolean[] = [];
    const app = createRoot(dispose => {
      const [a, writeA] = createOptimisticStore([{ id: 1 }]);
      const [b, writeB] = createOptimisticStore([{ id: 10 }]);
      const [source, setSource] = createSignal(a);
      const [doneA, setDoneA] = createSignal(false);
      const input =
        producerKind === "async-memo"
          ? createMemo(() => {
              const current = source();
              return producer.promise.then(() => current);
            })
          : source;
      const fn =
        producerKind === "async-store"
          ? async () => {
              const current = source();
              await producer.promise;
              return { items: current };
            }
          : () => ({ items: input() });
      const [view] = createOptimisticStore(fn, { items: [] as { id: number }[] });
      const [outer] = createOptimisticStore(() => ({ items: view.items }), {
        items: [] as { id: number }[]
      });
      createRenderEffect(
        () => outer.items.map(row => row.id).join(","),
        value => void direct.push(value)
      );
      const rows = mapArray(
        () => outer.items,
        row => () => row.id
      );
      createRenderEffect(
        () =>
          rows()
            .map(row => row())
            .join(","),
        value => void mapped.push(value)
      );
      createRenderEffect(doneA, value => void saved.push(value));
      const startA = action(function* () {
        writeA(draft => {
          draft[0] = { id: 100 };
        });
        yield endA.promise;
        setDoneA(true);
      });
      const startB = action(function* () {
        writeB(draft => {
          draft[0] = { id: 200 };
        });
        yield endB.promise;
      });
      return {
        dispose,
        startA,
        startB,
        replace: () => {
          producer = Promise.withResolvers<void>();
          setSource(b);
        }
      };
    });
    let runningA: Promise<unknown> | undefined, runningB: Promise<unknown> | undefined;
    const shown = (value: string) => {
      expect(direct.at(-1)).toBe(value);
      expect(mapped.at(-1)).toBe(value);
    };
    try {
      await turn();
      shown("1");
      runningA = app.startA();
      await turn();
      shown("100");
      runningB = app.startB();
      await turn();
      shown("100");
      app.replace();
      await turn();
      shown("100");
      producer.resolve();
      await turn();
      shown("200");
      endA.resolve();
      await runningA;
      await turn();
      shown("200");
      expect(saved.at(-1)).toBe(true);
      endB.resolve();
      await runningB;
      await turn();
      shown("10");
      const distinct = (frames: string[]) =>
        frames.filter((value, index) => !index || value !== frames[index - 1]);
      expect(distinct(mapped)).toEqual(distinct(direct));
    } finally {
      app.dispose();
      producer.resolve();
      endA.resolve();
      endB.resolve();
      await Promise.all([runningA, runningB]);
      await turn();
    }
  });
