import { expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";

const settle = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it.each([false, true])(
  "a known pending callback answer survives a first load, then recovers (first load finishes first=%s)",
  async firstLoadFirst => {
    const update = Promise.withResolvers<number>();
    const first = Promise.withResolvers<string>();
    const shown: boolean[] = [];
    const app = createRoot(dispose => {
      const [id, setId] = createSignal(0);
      const [show, setShow] = createSignal(false);
      const existing = createMemo(() => (id() ? update.promise : 0));
      const initial = createMemo(() => first.promise);
      createRenderEffect(
        () => isPending(() => (existing(), show() && initial())),
        value => void shown.push(value)
      );
      return { dispose, setId, setShow };
    });
    try {
      flush();
      expect(shown).toEqual([false]);
      app.setId(1);
      app.setShow(true);
      flush();
      await settle();
      expect(shown.at(-1)).toBe(true);
      if (firstLoadFirst) first.resolve("ready");
      else update.resolve(1);
      await settle();
      expect(shown.at(-1)).toBe(true);
      first.resolve("ready");
      update.resolve(1);
      await settle();
      expect(shown.at(-1)).toBe(false);
    } finally {
      app.dispose();
    }
  }
);
