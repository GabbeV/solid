import { afterEach, expect, it } from "vitest";
import {
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending as publicPending,
  resetErrorHalt
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";
import { isPending } from "../src/layers/pending.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
function root(fn: () => void) {
  let release!: () => void;
  createRoot(dispose => {
    release = dispose;
    disposals.push(dispose);
    fn();
  });
  return release;
}
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
  resetErrorHalt();
});

for (const implementation of ["public API", "explicit layer"] as const) {
  const pending = implementation === "public API" ? publicPending : isPending;
  for (const optimistic of [false, true]) {
    it(`${implementation}: escaped readers retain one frozen publication after source-owner disposal (optimistic=${optimistic})`, async () => {
      const answer = gate<number>();
      const [id, setId] = createSignal(0);
      let view!: () => number;
      const disposeSource = root(() => {
        const input = createMemo(() => (id() ? answer.promise : 0));
        view = optimistic
          ? (implementation === "public API"
              ? createOptimistic(input)
              : createLayer(input, { lifetime: "action" }))[0]
          : input;
      });
      let shown = -1,
        status = false,
        late = true;
      root(() => {
        createRenderEffect(view, value => {
          shown = value;
        });
        createRenderEffect(
          () => pending(view),
          value => {
            status = value;
          }
        );
      });
      flush();
      setId(1);
      flush();
      expect([shown, status]).toEqual([0, true]);
      disposeSource();
      flush();
      const afterDispose = [shown, status, view(), pending(view)];
      root(() =>
        createRenderEffect(
          () => pending(view),
          value => {
            late = value;
          }
        )
      );
      flush();
      answer.resolve(1);
      await turn();
      // Owner death freezes the source, including its pending state, in both
      // implementations. Do not invent a pending-false transition here.
      expect(afterDispose).toEqual([0, true, 0, true]);
      expect([shown, status, late, view(), pending(view)]).toEqual([0, true, true, 0, true]);
    });
  }
}
