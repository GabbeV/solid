import { expect, it } from "vitest";
import {
  createEffect,
  createLoadingBoundary,
  createRenderEffect,
  createMemo,
  createRoot,
  createSignal,
  createStore,
  flush,
  isPending
} from "../src/index.js";

const settle = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const form of ["memo", "async memo", "async store"] as const)
  for (const pending of [false, true])
    it(`an effect keeps its shown error through retry (${form}, pending=${pending})`, async () => {
      const answers = Array.from({ length: 5 }, () => Promise.withResolvers<number>());
      const first = new Error("first");
      const second = new Error("second");
      const app = createRoot(dispose => {
        const [id, setId] = createSignal(0);
        const source = createMemo(() => answers[id()].promise);
        let read = source;
        if (form === "async memo") read = createMemo(async () => source());
        if (form === "async store") {
          const [store] = createStore(
            async draft => {
              draft.value = source();
            },
            { value: -1 }
          );
          read = () => store.value;
        }
        const values: number[] = [];
        const errors: unknown[] = [];
        createEffect(
          () => {
            const value = read();
            if (pending) isPending(read);
            return value;
          },
          { effect: value => void values.push(value), error: error => void errors.push(error) }
        );
        return { dispose, setId, values, errors };
      });
      try {
        answers[0].resolve(0);
        await settle();
        expect(app.values.at(-1)).toBe(0);
        app.setId(1);
        flush();
        answers[1].reject(first);
        await settle();
        expect(app.errors).toEqual([first]);

        app.setId(2);
        flush();
        await settle();
        expect(app.errors).toEqual([first]);
        answers[2].reject(second);
        await settle();
        expect(app.errors).toEqual([first, second]);

        app.setId(3);
        flush();
        await settle();
        expect(app.errors).toEqual([first, second]);
        answers[3].resolve(3);
        await settle();
        expect(app.values.at(-1)).toBe(3);

        // Reusing an error object after successful recovery is a new failure.
        app.setId(4);
        flush();
        answers[4].reject(second);
        await settle();
        expect(app.errors).toEqual([first, second, second]);
      } finally {
        for (const answer of answers) answer.resolve(0);
        app.dispose();
        flush();
      }
    });

for (const pending of [false, true])
  it(`an error queued behind Loading is delivered when revealed (pending=${pending})`, async () => {
    const gate = Promise.withResolvers<void>();
    const answers = [Promise.withResolvers<number>(), Promise.withResolvers<number>()];
    const first = new Error("first");
    const second = new Error("second");
    const errors: unknown[] = [];
    const screens: string[] = [];
    const app = createRoot(dispose => {
      const [id, setId] = createSignal(0);
      const source = createMemo(() => answers[id()].promise);
      const ready = createMemo(() => gate.promise);
      const output = createLoadingBoundary(
        () => {
          createRenderEffect(ready, () => {});
          createEffect(
            () => {
              const value = source();
              if (pending) isPending(source);
              return value;
            },
            { effect: () => {}, error: error => void errors.push(error) }
          );
          return "content";
        },
        () => "loading"
      );
      createRenderEffect(output, value => void screens.push(value));
      return { dispose, setId };
    });
    try {
      flush();
      expect(screens).toEqual(["loading"]);
      answers[0].reject(first);
      await settle();
      expect(errors).toEqual([]);
      app.setId(1);
      flush();
      answers[1].reject(second);
      await settle();
      expect(errors).toEqual([]);
      gate.resolve();
      await settle();
      expect(screens).toEqual(["loading", "content"]);
      expect(errors).toEqual([second]);
    } finally {
      gate.resolve();
      for (const answer of answers) answer.resolve(0);
      app.dispose();
      flush();
    }
  });
