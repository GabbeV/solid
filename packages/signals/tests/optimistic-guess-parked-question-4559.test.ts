/**
 * #4559: a second async reader keeps the filter input parked independently
 * of the selected row outputs. A draft splice retains rows #3/#4 rather than
 * replaying a removal over the next answer. The authoritative row #2 must
 * never publish with the old open question.
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
  for (const mode of ["inline", "memo", "split"] as const)
    test(`selected row outputs stay coherent while a sibling question is parked (${order}, ${mode})`, async () => {
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
      const last = () => frames.filter(f => !f.startsWith("other")).at(-1);
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
        readerChecks.push(selectedListReaders(issues, () => rowsVisible));
        const other = createMemo(async () => {
          const f = filter();
          await ask(`other:${f}`);
          return f.length;
        });
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
        if (mode === "split") {
          // One binding per read, as a template's holes are: the screen is
          // what both show after each flush.
          let question = "",
            rows = "";
          const show = () => frames.push(`${question}: ${rows}`);
          const bindQuestion = () =>
            createRenderEffect(filter, v => {
              question = v;
              sampleReaders();
              queueMicrotask(show);
            });
          const bindRows = () =>
            createRenderEffect(
              () => issues.map(row => `[#${row.id}]`).join(""),
              v => {
                rows = v;
                rowsVisible = v;
                sampleReaders();
                queueMicrotask(show);
              }
            );
          if (order === "question first") {
            bindQuestion();
            bindRows();
          } else {
            bindRows();
            bindQuestion();
          }
        } else
          createRenderEffect(mode === "memo" ? createMemo(screen) : screen, value => {
            rowsVisible = value.slice(value.indexOf(": ") + 2);
            frames.push(value);
            sampleReaders();
          });
        createRenderEffect(other, value => void frames.push(`other ${value}`));
      });
      try {
        await tick();
        checkReaders();
        await settle("other:open", {});
        await settle("issues:open", [{ id: 1 }, { id: 3 }, { id: 4 }]);
        expect(last()).toBe("open: [#1][#3][#4]");
        setFilter("closed");
        await tick();
        checkReaders();
        const closing = closeOne(1);
        await tick();
        checkReaders();
        expect(last()).toBe("open: [#3][#4]");
        await settle("issues:closed", [{ id: 1 }, { id: 2 }]);
        // The sibling question remains parked; selected row outputs retain
        // their concrete #3/#4 values independently of the new answer.
        expect(last()).toBe("open: [#3][#4]");
        await settle("other:closed", {});
        expect(last()).toBe("open: [#3][#4]");
        await settle("close:1", {});
        expect(last()).toBe("open: [#3][#4]");
        await settle("issues:closed", [{ id: 2 }]);
        await closing;
        checkReaders();
        expect(last()).toBe("closed: [#2]");
        expect(asks).toEqual([]);
        const allowed = [
          "open: [#1][#3][#4]",
          "open: [#3][#4]",
          "closed: [#3][#4]",
          "closed: [#2]"
        ];
        let rowsAnswered = false;
        for (const frame of frames.filter(value => !value.startsWith("other"))) {
          // Split bindings may show the initial question before any list
          // answer exists. An empty correction after rows appeared is invalid.
          if (frame === "open: ") {
            expect(mode).toBe("split");
            expect(rowsAnswered).toBe(false);
          } else {
            expect(allowed).toContain(frame);
            rowsAnswered = true;
          }
        }
      } finally {
        dispose();
      }
    });
