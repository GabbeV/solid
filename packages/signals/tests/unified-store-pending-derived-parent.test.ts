import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  deep,
  flush,
  isPending
} from "../src/index.js";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const mode of ["ambient", "action"] as const)
  it(`a ${mode} leaf guess preserves an unresolved producer's parent and deep pending`, async () => {
    type Frame = { object: { guessed: number; unguessed: number }; scalar: number };
    let answer = Promise.withResolvers<void>();
    const end = Promise.withResolvers<void>();
    const [question, setQuestion] = createSignal(0);
    const references: boolean[] = [],
      contents: boolean[] = [],
      values: number[] = [];
    const [state, write, dispose] = createRoot(dispose => {
      const [state, write] = createOptimisticStore(
        async (): Promise<Frame> => {
          const n = question();
          await answer.promise;
          return { object: { guessed: 10 + n, unguessed: 20 + n }, scalar: 30 + n };
        },
        { object: { guessed: 0, unguessed: 0 }, scalar: 0 },
        { seedLoadingValue: true }
      );
      // Keep the reference query independent of both deep traversal and display.
      createRenderEffect(
        () => isPending(() => state.object),
        value => {
          references.push(value);
        }
      );
      createRenderEffect(
        () => isPending(() => deep(state.object)),
        value => {
          contents.push(value);
        }
      );
      createRenderEffect(
        () => state.object.guessed,
        value => {
          values.push(value);
        }
      );
      return [state, write, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      answer.resolve();
      await turn();
      expect(values.at(-1)).toBe(10);
      expect(references.at(-1)).toBe(false);
      expect(contents.at(-1)).toBe(false);

      answer = Promise.withResolvers<void>();
      setQuestion(1);
      flush();
      expect(references.at(-1)).toBe(true);
      expect(contents.at(-1)).toBe(true);
      const guess = () =>
        write(draft => {
          draft.object.guessed = 99;
        });
      if (mode === "action")
        running = action(function* () {
          guess();
          yield end.promise;
        })();
      else guess();
      flush();
      await turn();
      expect(values.at(-1)).toBe(99);
      expect(references.at(-1)).toBe(true);
      expect(contents.at(-1)).toBe(true);

      answer.resolve();
      await turn();
      expect(references.at(-1)).toBe(false);
      expect(contents.at(-1)).toBe(false);
      expect(state.object.unguessed).toBe(21);
      end.resolve();
      await running;
      await turn();
      expect(values.at(-1)).toBe(11);
      expect(references.at(-1)).toBe(false);
      expect(contents.at(-1)).toBe(false);
    } finally {
      answer.resolve();
      end.resolve();
      await running;
      dispose();
      flush();
    }
  });

it("a known plain-store leaf write leaves its unchanged parent reference available", async () => {
  const end = Promise.withResolvers<void>();
  const references: boolean[] = [],
    contents: boolean[] = [],
    values: number[] = [];
  const [source, setSource] = createStore({ object: { guessed: 10, unguessed: 20 } });
  const [state, write, dispose] = createRoot(dispose => {
    const [state, write] = createOptimisticStore(source);
    createRenderEffect(
      () => isPending(() => state.object),
      value => {
        references.push(value);
      }
    );
    createRenderEffect(
      () => isPending(() => deep(state.object)),
      value => {
        contents.push(value);
      }
    );
    createRenderEffect(
      () => state.object.guessed,
      value => {
        values.push(value);
      }
    );
    return [state, write, dispose] as const;
  });
  let running: Promise<unknown> | undefined, selecting: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      setSource(draft => {
        draft.object.unguessed = 21;
      });
      yield end.promise;
    })();
    flush();
    selecting = action(function* () {
      write(draft => {
        draft.object.guessed = 99;
      });
      yield end.promise;
    })();
    flush();
    expect(values.at(-1)).toBe(99);
    expect(references.at(-1)).toBe(false);
    expect(contents.at(-1)).toBe(true);
    end.resolve();
    await running;
    await selecting;
    await turn();
    expect(state.object.unguessed).toBe(21);
    expect(references.at(-1)).toBe(false);
    expect(contents.at(-1)).toBe(false);
  } finally {
    end.resolve();
    await running;
    await selecting;
    dispose();
    flush();
  }
});
