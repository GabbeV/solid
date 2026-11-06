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
it.each([false, true])(
  "latest of one input cannot publish a separate manual store write held by an action (new key=%s)",
  async newKey => {
    const answer = Promise.withResolvers<number>();
    const end = Promise.withResolvers<void>();
    const frames: string[] = [];
    const app = createRoot(dispose => {
      const [control, setControl] = createSignal(0);
      const input = createMemo(() => answer.promise);
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
      return { dispose, setControl, setStore, control };
    });
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
      end.resolve();
      await running;
      await settle();
      expect(frames.at(-1)).toBe("1:true:true");
    } finally {
      end.resolve();
      await running;
      app.dispose();
    }
  }
);
