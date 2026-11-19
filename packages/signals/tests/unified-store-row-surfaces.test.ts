import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

for (const sameSetter of [true, false])
  it(`composes nested guessed array length, indexes, iteration and descriptors (same setter=${sameSetter})`, async () => {
    const [server, setServer] = createSignal<number[][]>([]);
    const gate = Promise.withResolvers<void>();
    const frames: unknown[] = [];
    const [rows, setRows, dispose] = createRoot(dispose => {
      const [rows, setRows] = createOptimisticStore(() => server(), [], { key: null });
      createRenderEffect(
        () =>
          rows[0] && [
            rows[0].length,
            rows[0][1],
            rows[0].map(v => v),
            Object.getOwnPropertyDescriptor(rows[0], "0")?.value
          ],
        v => {
          frames.push(v);
        }
      );
      return [rows, setRows, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    const snapshot = () => [
      rows[0].length,
      rows[0][1],
      rows[0].map(v => v),
      Object.getOwnPropertyDescriptor(rows[0], "0")?.value
    ];
    try {
      flush();
      running = action(function* () {
        setRows(d => {
          d.push([1]);
          if (sameSetter) d[0].push(2);
        });
        if (!sameSetter)
          setRows(d => {
            d[0].push(2);
          });
        yield gate.promise;
      })();
      flush();
      expect(snapshot()).toEqual([2, 2, [1, 2], 1]);
      expect(frames.at(-1)).toEqual(snapshot());
      setServer([[9]]);
      flush();
      expect(snapshot()).toEqual([2, 2, [1, 2], 1]);
      expect(frames.at(-1)).toEqual(snapshot());
      gate.resolve();
      await running;
      flush();
      expect(snapshot()).toEqual([1, undefined, [9], 9]);
      expect(frames.at(-1)).toEqual(snapshot());
    } finally {
      gate.resolve();
      await running;
      dispose();
      flush();
    }
  });

it("keeps descriptors and presence at the selected row boundary", async () => {
  type Row = { id: number; shown?: string; truth?: string };
  const [server, setServer] = createSignal<Row[]>([]);
  const gate = Promise.withResolvers<void>();
  const frames: unknown[] = [];
  const [rows, setRows, dispose] = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore(() => server(), [], { key: "id" });
    createRenderEffect(
      () =>
        rows[0] && [
          Object.getOwnPropertyDescriptor(rows[0], "shown")?.value,
          "shown" in rows[0],
          "truth" in rows[0],
          Object.keys(rows[0])
        ],
      v => {
        frames.push(v);
      }
    );
    return [rows, setRows, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  const snapshot = () => [
    Object.getOwnPropertyDescriptor(rows[0], "shown")?.value,
    "shown" in rows[0],
    "truth" in rows[0],
    Object.keys(rows[0])
  ];
  try {
    flush();
    running = action(function* () {
      setRows(d => {
        d.push({ id: 1, shown: "guess" });
      });
      yield gate.promise;
    })();
    flush();
    setServer([{ id: 1, truth: "answer" }]);
    flush();
    expect(snapshot()).toEqual(["guess", true, false, ["id", "shown"]]);
    expect(frames.at(-1)).toEqual(snapshot());
    gate.resolve();
    await running;
    flush();
    expect(snapshot()).toEqual([undefined, false, true, ["id", "truth"]]);
    expect(frames.at(-1)).toEqual(snapshot());
  } finally {
    gate.resolve();
    await running;
    dispose();
    flush();
  }
});

it("keeps a nested object body at its guessed row publication boundary", async () => {
  type Row = { id: number; nested: { title: string } };
  const [server, setServer] = createSignal<Row[]>([]);
  const gate = Promise.withResolvers<void>();
  const frames: string[] = [];
  const [rows, setRows, dispose] = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore(() => server(), [], { key: "id" });
    createRenderEffect(
      () => rows[0]?.nested.title,
      v => {
        frames.push(v ?? "");
      }
    );
    return [rows, setRows, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      setRows(d => {
        d.push({ id: 1, nested: { title: "guess" } });
      });
      yield gate.promise;
    })();
    flush();
    setServer([{ id: 1, nested: { title: "answer" } }]);
    flush();
    expect([rows[0].nested.title, frames.at(-1)]).toEqual(["guess", "guess"]);
    gate.resolve();
    await running;
    flush();
    expect([rows[0].nested.title, frames.at(-1)]).toEqual(["answer", "answer"]);
  } finally {
    gate.resolve();
    await running;
    dispose();
    flush();
  }
});

for (const derived of [false, true])
  it(`keeps a whole property override and nested descendants coherent (derived=${derived})`, async () => {
    type State = { obj: { nested: { inner: { v: number } } } };
    const [server, setServer] = createSignal<State>({ obj: { nested: { inner: { v: 0 } } } });
    const gate = Promise.withResolvers<void>();
    const frames: number[] = [];
    const [state, setState, dispose] = createRoot(dispose => {
      const [state, setState] = derived
        ? createOptimisticStore(() => server(), server())
        : createOptimisticStore(server());
      createRenderEffect(
        () => state.obj.nested.inner.v,
        v => {
          frames.push(v);
        }
      );
      return [state, setState, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      running = action(function* () {
        setState(d => {
          d.obj = { nested: { inner: { v: 1 } } };
        });
        yield gate.promise;
      })();
      flush();
      expect([state.obj.nested.inner.v, frames.at(-1)]).toEqual([1, 1]);
      if (derived) {
        setServer({ obj: { nested: { inner: { v: 2 } } } });
        flush();
      }
      expect([state.obj.nested.inner.v, frames.at(-1)]).toEqual([1, 1]);
      gate.resolve();
      await running;
      flush();
      expect([state.obj.nested.inner.v, frames.at(-1)]).toEqual(derived ? [2, 2] : [0, 0]);
    } finally {
      gate.resolve();
      await running;
      dispose();
      flush();
    }
  });

it("serves late untracked row descriptors before leaf companions exist", async () => {
  type Row = { id: number; label: string };
  const [server, setServer] = createSignal<Row[]>([]);
  const gate = Promise.withResolvers<void>();
  const [rows, setRows, dispose] = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore(() => server(), [], { key: "id" });
    return [rows, setRows, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      setRows(d => {
        d.push({ id: 1, label: "guess" });
      });
      yield gate.promise;
    })();
    flush();
    const ref = rows[0];
    setServer([{ id: 1, label: "answer" }]);
    flush();
    expect(Object.getOwnPropertyDescriptor(ref, "label")?.value).toBe("guess");
    gate.resolve();
    await running;
    flush();
    expect(Object.getOwnPropertyDescriptor(rows[0], "label")?.value).toBe("answer");
  } finally {
    gate.resolve();
    await running;
    dispose();
    flush();
  }
});
