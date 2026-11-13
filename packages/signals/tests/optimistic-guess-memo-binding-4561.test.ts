/**
 * #4561: a splice selects concrete row outputs without replaying a removal.
 * An incoming membership change joins the open splice action. Memo, mapArray
 * and For consumers agree through the hold and the eventual correction.
 * An explicit Loading `on` boundary retains its own reveal behavior.
 */
import { expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  mapArray,
  refresh
} from "../src/index.js";

import { selectedListReaders } from "./harness/selected-list-readers.js";

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};

for (const shape of ["memo", "mapArray", "for"] as const)
  for (const on of [false, true])
    it(`#4561: selected row outputs stay coherent through a ${shape} binding (on=${on})`, async () => {
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
      const screen = () => (shown === "content" ? `${f}: ${l}` : shown);
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
        const out = createLoadingBoundary(
          () => {
            readerChecks.push(
              selectedListReaders(issues, () => (shown === "content" ? rowsVisible : undefined))
            );
            const list =
              shape === "memo"
                ? createMemo(() => issues.map((it: any) => `[#${it.id}]`).join(""))
                : (() => {
                    const rows = mapArray(
                      () => issues,
                      (it: any) => `[#${it.id}]`
                    );
                    return () => rows().join("");
                  })();
            if (shape === "for") {
              // <For>'s shape: the rows' own bindings read each row's leaves.
              const cells: Record<number, string> = {};
              const rows = mapArray(
                () => issues,
                (it: any) => {
                  const id = it.id;
                  createRenderEffect(
                    () => `[#${it.id}]`,
                    v => void (cells[id] = v)
                  );
                  return id;
                }
              );
              createRenderEffect(filter, v => {
                f = v;
                sample();
              });
              createRenderEffect(
                () => rows(),
                ids => {
                  l = ids.map((i: number) => cells[i] ?? `[#${i}]`).join("");
                  rowsVisible = l;
                  sample();
                }
              );
              return "content";
            }
            createRenderEffect(filter, v => {
              f = v;
              sample();
            });
            createRenderEffect(list, v => {
              l = v;
              rowsVisible = v;
              sample();
            });
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
      // Complete selected rows can reveal through the re-armed boundary.
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

// Every derivation hop preserves the same selected array and correction.
for (const chain of ["memo-memo", "memo-memo-memo", "mapArray-memo"] as const)
  it(`#4561: selected row outputs stay coherent through a ${chain} binding`, async () => {
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
    const screen = () => (shown === "content" ? `${f}: ${l}` : shown);
    const seen: unknown[] = [];
    let rowsVisible: string | undefined;
    const sample = () => {
      readerChecks.forEach(check => check.capture());
      queueMicrotask(() => seen.push(screen()));
    };
    let setFilter!: (f: string) => void, closeOne!: (id: number) => any;
    createRoot(() => {
      const [filter, sf] = createSignal("open");
      setFilter = sf;
      const [issues, set] = createOptimisticStore<any[]>(() => ask(`issues:${filter()}`), [], {
        key: "id"
      });
      closeOne = action(function* (id: number) {
        set(
          list =>
            void list.splice(
              list.findIndex(t => t.id === id),
              1
            )
        );
        yield ask(`close:${id}`);
        refresh(issues);
      });
      const out = createLoadingBoundary(
        () => {
          readerChecks.push(
            selectedListReaders(issues, () => (shown === "content" ? rowsVisible : undefined))
          );
          let b: () => string;
          if (chain === "mapArray-memo") {
            const rows = mapArray(
              () => issues,
              (it: any) => `[#${it.id}]`
            );
            b = createMemo(() => rows().join(""));
          } else {
            const a = createMemo(() => issues.map((it: any) => `[#${it.id}]`).join(""));
            b = createMemo(() => a());
            if (chain === "memo-memo-memo") {
              const b0 = b;
              b = createMemo(() => b0());
            }
          }
          createRenderEffect(filter, v => {
            f = v;
            sample();
          });
          createRenderEffect(b, v => {
            l = v;
            rowsVisible = v;
            sample();
          });
          return "content";
        },
        () => "loading"
      );
      createRenderEffect(out, v => {
        shown = v;
        sample();
      });
    });
    await tick();
    checkReaders();
    await settle("issues:open", [{ id: 1 }, { id: 3 }, { id: 4 }]);
    setFilter("closed");
    await tick();
    checkReaders();
    expect(screen()).toBe("open: [#1][#3][#4]");
    const closing = closeOne(1);
    await tick();
    checkReaders();
    // The explicit row outputs retain #3/#4; no keyed removal is replayed.
    expect(screen()).toBe("open: [#3][#4]");
    expect(seen.filter(frame => String(frame).startsWith("closed:"))).toEqual([]);
    await settle("issues:closed", [{ id: 1 }, { id: 2 }]);
    // Structural membership holds the question through the action refresh.
    expect(screen()).toBe("open: [#3][#4]");
    expect(seen.filter(frame => String(frame).startsWith("closed:"))).toEqual([]);
    await settle("close:1", {});
    expect(screen()).toBe("open: [#3][#4]");
    await settle("issues:closed", [{ id: 2 }]);
    await closing;
    checkReaders();
    expect(screen()).toBe("closed: [#2]");
    expect(asks).toEqual([]);
    seen.push(screen());
    const allowed = [undefined, "loading", "open: [#1][#3][#4]", "open: [#3][#4]", "closed: [#2]"];
    for (const published of seen) expect(allowed).toContain(published);
  });
