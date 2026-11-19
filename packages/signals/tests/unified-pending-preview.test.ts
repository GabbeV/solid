import { expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";

it.each(["direct", "memo", "pending first", "render effect"])(
  "publishes a ready pending preview before correcting the input (%s)",
  async kind => {
    const [id, setId] = createSignal(0);
    const calls: [number, boolean][] = [];
    const requests: ((page: string) => void)[] = [];
    const screen = { id: -1, pending: false, page: "" };
    const dispose = createRoot(dispose => {
      const pendingId = kind === "memo" ? createMemo(() => isPending(id)) : () => isPending(id);
      const calculate = () => {
        const before = kind === "pending first" && pendingId();
        const key = id();
        const pending = kind === "pending first" ? before : pendingId();
        calls.push([key, pending]);
        if (pending) return "Loading";
        if (key === 0) return "Home";
        return new Promise<string>(resolve => requests.push(resolve));
      };
      const display = (value: string) => void (screen.page = value);
      if (kind === "render effect") createRenderEffect(calculate, display);
      else createRenderEffect(createMemo(calculate), display);
      createRenderEffect(id, value => void (screen.id = value));
      createRenderEffect(
        () => isPending(id),
        value => void (screen.pending = value)
      );
      return dispose;
    });
    try {
      flush();
      setId(1);
      flush();
      expect(screen).toEqual({ id: 0, pending: true, page: "Loading" });
      // A render effect can repeat its synchronous preview. Every calculation
      // must use one context, and only the two ordinary passes can fetch.
      expect(calls.filter(([key]) => key === 1)).toEqual([
        [1, false],
        [1, false]
      ]);
      expect(calls).toContainEqual([0, true]);
      expect(requests).toHaveLength(2);
      requests[0]("obsolete");
      await Promise.resolve();
      flush();
      expect(screen).toEqual({ id: 0, pending: true, page: "Loading" });
      requests[1]("Page 1");
      await Promise.resolve();
      flush();
      expect(screen).toEqual({ id: 1, pending: false, page: "Page 1" });
    } finally {
      dispose();
    }
  }
);
