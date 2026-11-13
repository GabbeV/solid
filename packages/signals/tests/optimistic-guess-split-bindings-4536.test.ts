/**
 * #4536: a splice selects concrete row outputs without replaying a removal.
 * An incoming membership change joins the open splice action. Split bindings
 * and ordinary list readers agree through the hold and correction; explicit
 * Loading `on` boundaries retain their own reveal behavior.
 */
import { expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  refresh
} from "../src/index.js";

import { selectedListReaders } from "./harness/selected-list-readers.js";

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};

for (const split of [false, true])
  for (const on of [false, true])
    it(`#4536: selected row outputs keep independent bindings coherent (split=${split}, on=${on})`, async () => {
      const readerChecks: Array<ReturnType<typeof selectedListReaders>> = [];
      const checkReaders = () => readerChecks.forEach(check => check());
      const asks: { key: string; res: (v: any) => void }[] = [];
      const ask = (key: string) => new Promise<any>(res => asks.push({ key, res }));
      const settle = async (key: string, v: any) => {
        const i = asks.findIndex(a => a.key === key);
        expect(i, `missing request ${key}`).toBeGreaterThanOrEqual(0);
        asks.splice(i, 1)[0].res(v);
        await tick();
        checkReaders();
      };
      let f = "",
        l = "",
        shown: unknown;
      const screen = () => (shown === "content" ? (split ? `${f}: ${l}` : f) : shown);
      const seen: unknown[] = [];
      let rowsVisible: string | undefined;
      const sample = () => {
        readerChecks.forEach(check => check.capture());
        queueMicrotask(() => seen.push(screen()));
      };
      let setFilter!: (f: string) => void;
      let closeOne!: (id: number) => any;
      createRoot(() => {
        const [filter, sf] = createSignal("open");
        setFilter = sf;
        const [issues, set] = createOptimisticStore<any[]>(() => ask(`issues:${filter()}`), [], {
          key: "id"
        });
        closeOne = action(function* (id: number) {
          set(list => {
            const i = list.findIndex(t => t.id === id);
            if (i >= 0) list.splice(i, 1);
          });
          yield ask(`close:${id}`);
          refresh(issues);
        });
        const list = () => issues.map((it: any) => `[#${it.id}]`).join("");
        const out = createLoadingBoundary(
          () => {
            readerChecks.push(
              selectedListReaders(issues, () => (shown === "content" ? rowsVisible : undefined))
            );
            if (split) {
              createRenderEffect(filter, v => {
                f = v;
                sample();
              });
              createRenderEffect(list, v => {
                l = v;
                rowsVisible = v;
                sample();
              });
            } else
              createRenderEffect(
                () => `${filter()}: ${list()}`,
                v => {
                  f = v;
                  rowsVisible = v.slice(v.indexOf(": ") + 2);
                  sample();
                }
              );
            return "content";
          },
          () => "loading",
          on ? { on: filter } : undefined
        );
        createRenderEffect(out, v => {
          shown = v;
          sample();
        });
      });
      await tick();
      checkReaders();
      await settle("issues:open", [{ id: 1 }, { id: 3 }, { id: 4 }]);
      expect(screen()).toBe("open: [#1][#3][#4]");
      setFilter("closed");
      await tick();
      checkReaders();
      expect(screen()).toBe(on ? "loading" : "open: [#1][#3][#4]");
      const closing = closeOne(1);
      await tick();
      checkReaders();
      expect(screen()).toBe(on ? "closed: [#3][#4]" : "open: [#3][#4]");
      if (!on) expect(seen.filter(frame => String(frame).startsWith("closed:"))).toEqual([]);
      await settle("issues:closed", [{ id: 1 }, { id: 2 }]);
      // A changed membership joins the incoming question to the open splice action.
      expect(screen()).toBe(on ? "closed: [#3][#4]" : "open: [#3][#4]");
      if (!on) expect(seen.filter(frame => String(frame).startsWith("closed:"))).toEqual([]);
      await settle("close:1", {});
      expect(screen()).toBe(on ? "closed: [#3][#4]" : "open: [#3][#4]");
      await settle("issues:closed", [{ id: 2 }]);
      await closing;
      checkReaders();
      expect(screen()).toBe("closed: [#2]");
      expect(asks).toEqual([]);
      seen.push(screen());
      // An explicit Loading boundary may reveal its question early; the
      // authoritative correction must never appear with the old question.
      const allowed = [
        undefined,
        "loading",
        "open: [#1][#3][#4]",
        "open: [#3][#4]",
        "closed: [#3][#4]",
        "closed: [#2]"
      ];
      for (const published of seen) expect(allowed).toContain(published);
    });
