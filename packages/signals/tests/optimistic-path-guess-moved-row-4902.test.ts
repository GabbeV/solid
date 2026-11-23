// A move borrows a row until its destination answers. Passing the reference
// reads no count in the move setter. Spreading the row does read the toggle's
// pending count there, so the move and toggle must publish together (F-11).
import { test, expect } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  mapArray,
  refresh
} from "../src/index.js";

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
type Row = { id: number; done: number; total: number };
// Keyed landing: rows matched by key, leaves merged.
function landDraft(draft: any[], v: any[]) {
  const had = new Map<unknown, any>();
  for (const row of draft) had.set(row.id, row);
  v.forEach((x, i) => {
    const row = had.get(x.id);
    if (row) {
      for (const k of Object.keys(x)) if (row[k] !== x[k]) row[k] = x[k];
      if (draft[i] !== row) draft[i] = row;
    } else draft[i] = x;
  });
  draft.length = v.length;
}

for (const copy of [false, true])
  test(`publishes the move with the writes its setter consumed (copy: ${copy})`, async () => {
    const fl: Record<string, ((v: any) => void)[]> = {};
    const ask = (k: string) => new Promise<any>(r => (fl[k] ??= []).push(r));
    const land = (k: string, v: any) => {
      const rs = fl[k] ?? [];
      if (!rs.length) throw new Error("no ask " + k);
      fl[k] = [];
      rs.forEach(r => r(structuredClone(v)));
    };
    const out: Record<string, string> = {};
    const [moved, setMoved] = createSignal(false);
    let movePublished = false;
    let todo: any, setTodo: any, done: any, setDone: any, todoAns: any, doneAns: any;
    const dispose = createRoot(d => {
      createRenderEffect(moved, value => {
        movePublished = value;
      });
      [todoAns] = createSignal<any>(() => ask("todo"), { loadingValue: null } as any);
      [doneAns] = createSignal<any>(() => ask("done"), { loadingValue: null } as any);
      [todo, setTodo] = createOptimisticStore<Row[]>(
        (d: any) => {
          landDraft(d, todoAns() ?? []);
        },
        [],
        { key: "id" } as any
      );
      [done, setDone] = createOptimisticStore<Row[]>(
        (d: any) => {
          landDraft(d, doneAns() ?? []);
        },
        [],
        { key: "id" } as any
      );
      // As `<For>` renders it: one mapped row, each read on its own.
      for (const [k, s] of [
        ["todo", () => todo],
        ["done", () => done]
      ] as const) {
        const rows = mapArray(s, (r: any) => () => `${r.id}:${r.done}/${r.total}`);
        createRenderEffect(
          () =>
            rows()
              .map(f => f())
              .join(","),
          v => {
            out[k] = v;
          }
        );
      }
      return d;
    });
    const state = () => `${out.todo} | ${out.done}`;
    const toggle = action(function* (i: number) {
      setTodo((d: any) => {
        d[i].done += 1;
      });
      yield ask("toggle");
    });
    const move = action(function* (id: number) {
      const row = todo.find((r: Row) => r.id === id)!;
      setTodo((rs: Row[]) => rs.filter(r => r.id !== id));
      setDone((rs: Row[]) => [...rs, copy ? { ...row } : row]);
      yield ask("move");
      refresh(todoAns);
      refresh(doneAns);
      setMoved(true);
    });

    land("todo", [{ id: 1, done: 0, total: 2 }]);
    land("done", [{ id: 5, done: 3, total: 3 }]);
    await tick();
    toggle(0);
    await tick();
    expect(state()).toBe("1:1/2 | 5:3/3");
    move(1);
    await tick();
    expect(state()).toBe(" | 5:3/3,1:1/2");
    land("move", {});
    await tick();
    land("todo", []);
    await tick();
    expect(state()).toBe(" | 5:3/3,1:1/2");
    land("done", [
      { id: 5, done: 3, total: 3 },
      { id: 1, done: 0, total: 2 }
    ]);
    await tick();
    expect(state()).toBe(copy ? " | 5:3/3,1:1/2" : " | 5:3/3,1:0/2");
    expect(movePublished).toBe(!copy);
    land("toggle", {});
    await tick();
    expect(state()).toBe(" | 5:3/3,1:0/2");
    expect(movePublished).toBe(true);
    dispose();
  });
