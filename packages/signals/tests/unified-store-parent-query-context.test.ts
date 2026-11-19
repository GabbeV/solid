import { expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  NotReadyError
} from "../src/index.js";
const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};
for (const initialized of [false, true])
  it(`parent and captured child queries share the selected context (initialized=${initialized})`, async () => {
    type Frame = { row: { data: number } };
    const initial = Promise.withResolvers<Frame>();
    const selectedEnd = Promise.withResolvers<void>(),
      inputEnd = Promise.withResolvers<void>(),
      firstEnd = Promise.withResolvers<void>();
    const [source, setSource] = createSignal<Frame | Promise<Frame>>(
      initialized ? { row: { data: 0 } } : initial.promise
    );
    const frames: (number | string)[] = [];
    const [state, write, dispose] = createRoot(dispose => {
      const [state, write] = createOptimisticStore(
        () => source(),
        { row: { data: 0 } },
        { key: null }
      );
      const view = createLoadingBoundary(
        () => state.row.data,
        () => "loading"
      );
      createRenderEffect(view, value => {
        frames.push(value);
      });
      return [state, write, dispose] as const;
    });
    let selected: Promise<unknown> | undefined,
      input: Promise<unknown> | undefined,
      first: Promise<unknown> | undefined;
    try {
      flush();
      expect(frames.at(-1)).toBe(initialized ? 0 : "loading");
      if (!initialized) {
        first = action(function* () {
          write(draft => {
            draft.row = { data: 9 };
          });
          yield firstEnd.promise;
        })();
        flush();
        expect(frames.at(-1)).toBe("loading");
        expect(() => state.row).toThrow(NotReadyError);
        expect(() => latest(() => state.row.data)).toThrow(NotReadyError);
        expect(isPending(() => state.row)).toBe(false);
        initial.resolve({ row: { data: 0 } });
        await turn();
        expect(frames.at(-1)).toBe("loading");
        expect(() => state.row).toThrow(NotReadyError);
        firstEnd.resolve();
        await first;
        await turn();
        expect(frames.at(-1)).toBe(0);
        expect(latest(() => state.row.data)).toBe(0);
      }
      selected = action(function* () {
        write(draft => {
          draft.row = { data: 9 };
        });
        yield selectedEnd.promise;
      })();
      flush();
      const row = state.row;
      expect(frames.at(-1)).toBe(9);
      expect(latest(() => state.row.data)).toBe(9);
      expect(latest(() => row.data)).toBe(9);
      expect(isPending(() => row.data)).toBe(false);
      initial.resolve({ row: { data: 0 } });
      await turn();
      input = action(function* () {
        setSource({ row: { data: 2 } });
        yield inputEnd.promise;
      })();
      flush();
      expect(frames.at(-1)).toBe(9);
      expect(latest(() => state.row.data)).toBe(9);
      expect(latest(() => row.data)).toBe(9);
      expect(isPending(() => state.row)).toBe(true);
      expect(isPending(() => row.data)).toBe(false);
      selectedEnd.resolve();
      await selected;
      await turn();
      expect(frames.at(-1)).toBe(9);
      expect(state.row.data).toBe(9);
      expect(latest(() => state.row.data)).toBe(2);
      expect(latest(() => row.data)).toBe(2);
      expect(isPending(() => state.row)).toBe(true);
      expect(isPending(() => row.data)).toBe(true);
      inputEnd.resolve();
      await input;
      await turn();
      expect(frames.at(-1)).toBe(2);
      expect(latest(() => state.row.data)).toBe(2);
      expect(latest(() => row.data)).toBe(2);
      expect(isPending(() => state.row)).toBe(false);
      expect(isPending(() => row.data)).toBe(false);
    } finally {
      initial.resolve({ row: { data: 0 } });
      selectedEnd.resolve();
      inputEnd.resolve();
      firstEnd.resolve();
      await Promise.all([selected, input, first]);
      dispose();
      flush();
    }
  });
