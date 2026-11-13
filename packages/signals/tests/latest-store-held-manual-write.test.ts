import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  flush,
  latest
} from "../src/index.js";
const settle = () => new Promise<void>(r => setTimeout(r, 0));
it.each([
  [false, false],
  [true, false],
  [false, true],
  [true, true]
])(
  "latest keeps manual store writes coordinated (new key=%s, initialized=%s)",
  async (newKey, initialized) => {
    const answer = Promise.withResolvers<number>();
    const end = Promise.withResolvers<void>();
    const frames: string[] = [];
    const app = createRoot(dispose => {
      const [control, setControl] = createSignal(0);
      const [source, setSource] = createSignal<number | Promise<number>>(
        initialized ? 0 : answer.promise
      );
      const input = createMemo(source);
      const [store, setStore] = createStore<{ count: number; manual?: boolean }>(
        draft => {
          draft.count = latest(input);
        },
        newKey ? { count: -1 } : { count: -1, manual: false }
      );
      createRenderEffect(
        () => `${store.count}:${"manual" in store}:${store.manual}`,
        value => void frames.push(value)
      );
      createRenderEffect(control, () => {});
      return { dispose, setControl, setStore, control, setSource };
    });
    flush();
    if (initialized) {
      expect(frames.at(-1)).toBe(newKey ? "0:false:undefined" : "0:true:false");
      app.setSource(answer.promise);
      flush();
    } else expect(frames).toEqual([]);
    const running = action(function* () {
      app.setControl(1);
      app.setStore(draft => {
        draft.manual = true;
      });
      yield end.promise;
    })();
    try {
      flush();
      answer.resolve(1);
      await settle();
      expect(app.control()).toBe(0);
      expect(frames).not.toContain("1:true:true");
      if (!initialized) expect(frames).toEqual([]);
      end.resolve();
      await running;
      await settle();
      // A setter before commit zero is discarded but its action still owns
      // the first answer. Once initialized, an ordinary manual write survives.
      expect(frames.at(-1)).toBe(
        initialized ? "1:true:true" : newKey ? "1:false:undefined" : "1:true:false"
      );
    } finally {
      end.resolve();
      await running;
      app.dispose();
    }
  }
);
