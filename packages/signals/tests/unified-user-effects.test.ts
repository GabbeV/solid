/** @vitest-environment jsdom */
import { afterEach, expect, it } from "vitest";
import {
  createEffect,
  createLoadingBoundary,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  document.body.replaceChildren();
  flush();
});

for (const optimistic of [false, true])
  for (const supersede of [false, true]) {
    it(`owned user callbacks wait for DOM attachment (optimistic=${optimistic}, supersede=${supersede})`, async () => {
      const answer = gate<void>();
      const host = document.createElement("main");
      document.body.append(host);
      const runs: { value: number; dom: string | null; connected: boolean }[] = [];
      const effectCleanups: number[] = [],
        frameCleanups: number[] = [];
      let set!: (value: number) => unknown, dispose!: () => void;
      createRoot(d => {
        dispose = d;
        disposals.push(d);
        const [view, write] = optimistic ? createLayer(() => 0) : createSignal(0);
        set = write;
        const content = createLoadingBoundary(
          () => {
            const current = view();
            const element = document.createElement("span");
            element.textContent = String(current);
            onCleanup(() => {
              frameCleanups.push(current);
            });
            createEffect(
              () => current,
              value => {
                runs.push({ value, dom: host.textContent, connected: element.isConnected });
                return () => {
                  effectCleanups.push(value);
                };
              }
            );
            return current === 1 ? answer.promise.then(() => element) : element;
          },
          () => {
            const fallback = document.createElement("em");
            fallback.textContent = "loading";
            return fallback;
          },
          { on: view }
        );
        createRenderEffect(
          content,
          element => {
            host.replaceChildren(element as HTMLElement);
          },
          { schedule: true }
        );
      });
      flush();
      expect(runs).toEqual([{ value: 0, dom: "0", connected: true }]);
      set(1);
      flush();
      expect(host.textContent).toBe("loading");
      expect(runs).toHaveLength(1);
      if (supersede) {
        set(2);
        flush();
        expect(host.textContent).toBe("2");
      }
      answer.resolve();
      await new Promise(resolve => setTimeout(resolve, 0));
      const final = supersede ? 2 : 1;
      expect(runs).toEqual([
        { value: 0, dom: "0", connected: true },
        { value: final, dom: String(final), connected: true }
      ]);
      expect(effectCleanups).toEqual([0]);
      dispose();
      expect(effectCleanups).toEqual([0, final]);
      expect(frameCleanups.sort()).toEqual(supersede ? [0, 1, 2] : [0, 1]);
    });
  }
