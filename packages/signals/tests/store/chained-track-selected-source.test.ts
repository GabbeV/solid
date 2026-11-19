/** Chained structural discovery follows the same source as ordinary reads.
 * Source replacement must not join otherwise independent inner actions. */
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
} from "../../src/index.js";
const turn = async () => {
  for (let i = 0; i < 3; i++) {
    await new Promise<void>(r => setTimeout(r, 0));
    flush();
  }
};
for (const mode of ["unheld", "action-held", "producer-held"] as const)
  for (const depth of mode === "producer-held" ? [1] : [1, 2])
    it(`structural chaining follows the selected source without joining its actions (${mode}, depth=${depth})`, async () => {
      const build = (mapped: boolean) => {
        const endA = Promise.withResolvers<void>(),
          endB = Promise.withResolvers<void>(),
          endSwap = Promise.withResolvers<void>();
        let producer = Promise.withResolvers<void>();
        producer.resolve();
        let beginA!: () => unknown,
          beginB!: () => unknown,
          swap!: () => unknown,
          shown = "",
          doneA = false;
        const frames: string[] = [];
        const dispose = createRoot(dispose => {
          const [a, writeA] = createOptimisticStore([{ id: 1 }]);
          const [b, writeB] = createOptimisticStore([{ id: 10 }]);
          const [source, setSource] = createSignal(a),
            [savedA, setSavedA] = createSignal(false);
          let read: () => { id: number }[];
          const input =
            mode === "producer-held"
              ? createMemo(() => {
                  const current = source();
                  return producer.promise.then(() => current);
                })
              : source;
          const fn = () => ({ items: input() });
          const [view] = createOptimisticStore(fn, { items: [] as { id: number }[] });
          read = () => view.items;
          for (let i = 1; i < depth; i++) {
            const previous = read;
            const [wrapper] = createOptimisticStore(() => ({ items: previous() }), {
              items: [] as { id: number }[]
            });
            read = () => wrapper.items;
          }
          if (mapped) {
            const list = mapArray(read, item => () => item.id);
            createRenderEffect(
              () =>
                list()
                  .map(item => item())
                  .join(","),
              value => {
                shown = value;
                frames.push(value);
              }
            );
          } else
            createRenderEffect(
              () =>
                read()
                  .map(item => item.id)
                  .join(","),
              value => {
                shown = value;
                frames.push(value);
              }
            );
          createRenderEffect(savedA, value => void (doneA = value));
          beginA = action(function* () {
            writeA(d => {
              d[0] = { id: 100 };
            });
            yield endA.promise;
            setSavedA(true);
          });
          beginB = action(function* () {
            writeB(d => {
              d[0] = { id: 200 };
            });
            yield endB.promise;
          });
          const replace = () => {
            if (mode === "producer-held") producer = Promise.withResolvers<void>();
            setSource(b);
          };
          swap =
            mode === "action-held"
              ? action(function* () {
                  replace();
                  yield endSwap.promise;
                })
              : replace;
          return dispose;
        });
        return {
          beginA,
          beginB,
          swap,
          endA,
          endB,
          endSwap,
          releaseProducer: () => producer.resolve(),
          dispose,
          frames,
          get shown() {
            return shown;
          },
          get doneA() {
            return doneA;
          }
        };
      };
      const direct = build(false),
        mapped = build(true);
      const both = [direct, mapped];
      const equal = () => expect(mapped.shown).toBe(direct.shown);
      try {
        await turn();
        equal();
        expect(direct.shown).toBe("1");
        both.forEach(app => app.beginA());
        await turn();
        equal();
        expect(direct.shown).toBe("100");
        both.forEach(app => app.beginB());
        await turn();
        equal();
        both.forEach(app => app.swap());
        await turn();
        equal();
        if (mode === "unheld") expect(direct.shown).toBe("200");
        both.forEach(app => {
          app.endSwap.resolve();
          app.releaseProducer();
        });
        await turn();
        equal();
        expect(direct.shown).toBe("200");
        both.forEach(app => app.endA.resolve());
        await turn();
        equal();
        expect(direct.shown).toBe("200");
        expect(direct.doneA).toBe(true);
        expect(mapped.doneA).toBe(true);
        both.forEach(app => app.endB.resolve());
        await turn();
        equal();
        expect(direct.shown).toBe("10");
        const distinct = (frames: string[]) =>
          frames.filter((value, index) => index === 0 || value !== frames[index - 1]);
        expect(distinct(mapped.frames)).toEqual(distinct(direct.frames));
      } finally {
        both.forEach(app => {
          app.dispose();
          app.endA.resolve();
          app.endB.resolve();
          app.endSwap.resolve();
          app.releaseProducer();
        });
        await turn();
      }
    });
