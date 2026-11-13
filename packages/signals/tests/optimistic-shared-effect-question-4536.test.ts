/**
 * #4536: shared bindings read the filter and selected row outputs coherently.
 * An incoming membership change joins the open splice action, retaining the
 * question and concrete rows until the action's refreshed correction lands.
 */
import { expect, test } from "vitest";
import {
  action,
  createMemo,
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

for (const order of ["question first", "list first"] as const)
  for (const mode of ["inline", "memo"] as const)
    test(`a shared effect keeps the question and its guessed rows consistent (${order}, ${mode})`, async () => {
      type Issue = { id: number };
      const readerChecks: Array<ReturnType<typeof selectedListReaders>> = [];
      const checkReaders = () => readerChecks.forEach(check => check());
      const asks: { key: string; resolve: (value: any) => void }[] = [];
      const ask = (key: string) => new Promise<any>(resolve => asks.push({ key, resolve }));
      const settle = async (key: string, value: any) => {
        const i = asks.findIndex(a => a.key === key);
        expect(i).toBeGreaterThanOrEqual(0);
        asks.splice(i, 1)[0].resolve(value);
        await tick();
        checkReaders();
      };
      const frames: string[] = [];
      let rowsVisible: string | undefined;
      const sampleReaders = () => readerChecks.forEach(check => check.capture());
      let setFilter!: (value: string) => void;
      let closeOne!: (id: number) => unknown;
      let dispose!: () => void;
      createRoot(d => {
        dispose = d;
        const [filter, setFilterValue] = createSignal("open");
        setFilter = setFilterValue;
        const [issues, set] = createOptimisticStore<Issue[]>(() => ask(`issues:${filter()}`), [], {
          key: "id"
        });
        // For-like coherence readers also demand container structure. That
        // ordinary input holder keeps the independent question open until its
        // answer; the native-map-only DOM fixture has no such extra holder.
        readerChecks.push(selectedListReaders(issues, () => rowsVisible));
        closeOne = action(function* (id: number) {
          set(list => {
            const i = list.findIndex(row => row.id === id);
            if (i >= 0) list.splice(i, 1);
          });
          yield ask(`close:${id}`);
          refresh(issues);
        });
        const screen = () => {
          let question: string;
          let rows: string;
          if (order === "question first") {
            question = filter();
            rows = issues.map(row => `[#${row.id}]`).join("");
          } else {
            rows = issues.map(row => `[#${row.id}]`).join("");
            question = filter();
          }
          return `${question}: ${rows}`;
        };
        createRenderEffect(mode === "memo" ? createMemo(screen) : screen, value => {
          rowsVisible = value.slice(value.indexOf(": ") + 2);
          frames.push(value);
          sampleReaders();
        });
      });
      try {
        await tick();
        checkReaders();
        await settle("issues:open", [{ id: 1 }, { id: 3 }, { id: 4 }]);
        expect(frames.at(-1)).toBe("open: [#1][#3][#4]");
        setFilter("closed");
        await tick();
        checkReaders();
        expect(frames.at(-1)).toBe("open: [#1][#3][#4]");
        const closing = closeOne(1);
        await tick();
        checkReaders();
        // A splice selects its resulting row outputs; it is not replayed
        // as a removal on the producer's next answer.
        expect(frames.at(-1)).toBe("open: [#3][#4]");
        expect(frames.filter(frame => frame.startsWith("closed:"))).toEqual([]);
        await settle("issues:closed", [{ id: 1 }, { id: 2 }]);
        // Changed membership joins the answered input to the retained splice action.
        expect(frames.at(-1)).toBe("open: [#3][#4]");
        expect(frames.filter(frame => frame.startsWith("closed:"))).toEqual([]);
        await settle("close:1", {});
        expect(frames.at(-1)).toBe("open: [#3][#4]");
        await settle("issues:closed", [{ id: 2 }]);
        await closing;
        checkReaders();
        expect(frames.at(-1)).toBe("closed: [#2]");
        // The structural correction and its question publish together.
        expect(asks).toEqual([]);
        const allowed = ["open: [#1][#3][#4]", "open: [#3][#4]", "closed: [#2]"];
        for (const frame of frames.filter(value => !value.startsWith("other")))
          expect(allowed).toContain(frame);
      } finally {
        dispose();
      }
    });
