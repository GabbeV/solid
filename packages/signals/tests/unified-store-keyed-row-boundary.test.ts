import { expect, it } from "vitest";
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

const settle = async () => {
  await Promise.resolve();
  await Promise.resolve();
  await Promise.resolve();
  flush();
};
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const mode of ["push-true", "push-false-then-write", "push-true-then-equal-write"] as const) {
  it(mode, async () => {
    type Row = { id: number; pending: boolean };
    let server: Row[] = [];
    const fetches: Array<() => void> = [];
    const gate = Promise.withResolvers<void>();
    const frames: Array<Array<[number, boolean]>> = [];
    const [rows, setRows, dispose] = createRoot(dispose => {
      const [rows, setRows] = createOptimisticStore(
        () =>
          new Promise<Row[]>(resolve => {
            fetches.push(() => resolve(structuredClone(server)));
          }),
        [] as Row[],
        { key: "id" }
      );
      createRenderEffect(
        () => rows.map(row => [row.id, row.pending] as [number, boolean]),
        value => {
          frames.push(value);
        }
      );
      return [rows, setRows, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      fetches.shift()!();
      await settle();
      running = action(function* () {
        setRows(d => {
          d.push({ id: 1, pending: mode !== "push-false-then-write" });
          if (mode !== "push-true") d[0].pending = true;
        });
        yield gate.promise;
      })();
      flush();
      const ref = rows[0];
      const before = rows[0].pending;
      server = [{ id: 1, pending: false }];
      refresh(rows);
      flush();
      fetches.shift()!();
      await settle();
      await settle();
      const during = rows[0].pending;
      const same = rows[0] === ref;
      gate.resolve();
      await running;
      await settle();
      const after = rows[0].pending;
      expect([before, during, after, same]).toEqual([true, true, false, true]);
      expect(frames[0]).toEqual([]);
      for (const frame of frames.slice(1)) expect(frame).toHaveLength(1);
    } finally {
      gate.resolve();
      await running;
      dispose();
      flush();
    }
  });
}

it("holds incoming sibling membership with an active appended row", async () => {
  type Row = { id: number; pending: boolean };
  let server: Row[] = [];
  const fetches: Array<() => void> = [];
  const gate = Promise.withResolvers<void>();
  const shown: Array<Array<[number, boolean]>> = [];
  const [rows, setRows, dispose] = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore(
      () =>
        new Promise<Row[]>(resolve => {
          fetches.push(() => resolve(structuredClone(server)));
        }),
      [] as Row[],
      { key: "id" }
    );
    createRenderEffect(
      () => rows.map(row => [row.id, row.pending] as [number, boolean]),
      value => {
        shown.push(value);
      }
    );
    return [rows, setRows, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    fetches.shift()!();
    await settle();
    running = action(function* () {
      setRows(d => {
        d.push({ id: 1, pending: true });
      });
      yield gate.promise;
    })();
    flush();
    const ref = rows[0];
    server = [
      { id: 1, pending: false },
      { id: 2, pending: false }
    ];
    refresh(rows);
    flush();
    fetches.shift()!();
    await settle();
    // The incoming membership change joins the active append.
    expect(shown.at(-1)).toEqual([[1, true]]);
    expect(rows[0]).toBe(ref);
    gate.resolve();
    await running;
    await settle();
    expect(shown.at(-1)).toEqual([
      [1, false],
      [2, false]
    ]);
  } finally {
    gate.resolve();
    await running;
    dispose();
    flush();
  }
});

for (const [repeated, explicit] of [
  [false, false],
  [true, false],
  [false, true]
] as const) {
  it(`holds ${explicit ? "a pushed row with an explicit leaf" : repeated ? "a repeated" : "a single"} row proposal through an async correction and unrelated rerun`, async () => {
    type Row = { id: number; pending: boolean };
    let server: Row[] = [];
    const fetches: Array<() => void> = [];
    const gate = Promise.withResolvers<void>();
    const answer = Promise.withResolvers<number>();
    const [tick, setTick] = createSignal(0);
    const shown: Array<[boolean | undefined, number]> = [];
    const derivedShown: number[] = [];
    const late: Array<boolean | undefined> = [];
    let disposeLate: (() => void) | undefined;
    const [rows, setRows, dispose] = createRoot(dispose => {
      const [rows, setRows] = createOptimisticStore(
        () =>
          new Promise<Row[]>(resolve => {
            fetches.push(() => resolve(structuredClone(server)));
          }),
        [] as Row[],
        { key: "id" }
      );
      const derived = createMemo(() => (rows[0]?.pending === false ? answer.promise : 0));
      createRenderEffect(
        () => [rows[0]?.pending, tick()] as [boolean | undefined, number],
        value => {
          shown.push(value);
        }
      );
      createRenderEffect(derived, value => {
        derivedShown.push(value);
      });
      return [rows, setRows, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      fetches.shift()!();
      await settle();
      running = action(function* () {
        setRows(d => {
          d.push({ id: 1, pending: !explicit });
          if (explicit) d[0].pending = true;
        });
        if (repeated)
          setRows(d => {
            d[0] = { id: 1, pending: true };
          });
        yield gate.promise;
      })();
      flush();
      const ref = rows[0];
      expect(shown.at(-1)).toEqual([true, 0]);
      server = [{ id: 1, pending: false }];
      refresh(rows);
      flush();
      fetches.shift()!();
      await settle();
      expect([shown.at(-1), derivedShown.at(-1), rows[0] === ref]).toEqual([[true, 0], 0, true]);
      gate.resolve();
      await running;
      await turn();
      flush();
      expect([shown.at(-1), derivedShown.at(-1)]).toEqual([[true, 0], 0]);
      setTick(1);
      flush();
      expect(shown.at(-1)).toEqual([true, 1]);
      disposeLate = createRoot(dispose => {
        createRenderEffect(
          () => rows[0]?.pending,
          value => {
            late.push(value);
          }
        );
        return dispose;
      });
      flush();
      expect(late.at(-1)).toBe(true);
      answer.resolve(10);
      await turn();
      flush();
      expect([shown.at(-1), derivedShown.at(-1), late.at(-1)]).toEqual([[false, 1], 10, false]);
    } finally {
      gate.resolve();
      answer.resolve(10);
      await running;
      disposeLate?.();
      dispose();
      flush();
    }
  });
}

it("keeps the published row while the action is open and retires unpublished replacement work at its end", async () => {
  type Row = { id: number; pending: boolean; tag: string };
  let server: Row[] = [];
  const fetches: Array<() => void> = [];
  const next = Promise.withResolvers<void>();
  const end = Promise.withResolvers<void>();
  const secondAnswer = Promise.withResolvers<number>();
  const [tick, setTick] = createSignal(0);
  const shown: Array<[string | undefined, number]> = [];
  const derivedShown: number[] = [];
  const [rows, setRows, dispose] = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore(
      () =>
        new Promise<Row[]>(resolve => {
          fetches.push(() => resolve(structuredClone(server)));
        }),
      [] as Row[],
      { key: "id" }
    );
    const derived = createMemo(() => (rows[0]?.tag === "second" ? secondAnswer.promise : 0));
    createRenderEffect(
      () => [rows[0]?.tag, tick()] as [string | undefined, number],
      value => {
        shown.push(value);
      }
    );
    createRenderEffect(derived, value => {
      derivedShown.push(value);
    });
    return [rows, setRows, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    fetches.shift()!();
    await settle();
    running = action(function* () {
      setRows(d => {
        d.push({ id: 1, pending: true, tag: "first" });
      });
      yield next.promise;
      setRows(d => {
        d[0] = { id: 2, pending: true, tag: "second" };
      });
      yield end.promise;
    })();
    flush();
    expect([shown.at(-1), derivedShown.at(-1)]).toEqual([["first", 0], 0]);
    next.resolve();
    await turn();
    flush();
    expect([shown.at(-1), derivedShown.at(-1)]).toEqual([["first", 0], 0]);
    server = [{ id: 1, pending: false, tag: "server" }];
    refresh(rows);
    flush();
    fetches.shift()!();
    await settle();
    expect([shown.at(-1), derivedShown.at(-1)]).toEqual([["first", 0], 0]);
    end.resolve();
    await running;
    await turn();
    flush();
    // The unpublished replacement's async derivation does not extend the
    // action lifetime. The ready producer correction publishes at its end.
    expect([shown.at(-1), derivedShown.at(-1)]).toEqual([["server", 0], 0]);
    setTick(1);
    flush();
    expect([shown.at(-1), derivedShown.at(-1)]).toEqual([["server", 1], 0]);
    secondAnswer.resolve(20);
    await turn();
    flush();
    expect([shown.at(-1), derivedShown.at(-1)]).toEqual([["server", 1], 0]);
    expect(derivedShown).not.toContain(20);
  } finally {
    next.resolve();
    end.resolve();
    secondAnswer.resolve(20);
    await running;
    dispose();
    flush();
  }
});

it("keeps a child leaf guess while its setter-read parent row guess remains active", async () => {
  type Row = { id: number; title: string };
  let server: Row[] = [];
  const fetches: Array<() => void> = [];
  const parentGate = Promise.withResolvers<void>();
  const childGate = Promise.withResolvers<void>();
  const shown: string[] = [];
  const [rows, setRows, dispose] = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore(
      () => new Promise<Row[]>(resolve => fetches.push(() => resolve(structuredClone(server)))),
      [] as Row[],
      { key: "id" }
    );
    createRenderEffect(
      () => rows[0]?.title,
      value => {
        shown.push(value ?? "");
      }
    );
    return [rows, setRows, dispose] as const;
  });
  let parentRun: Promise<unknown> | undefined;
  let childRun: Promise<unknown> | undefined;
  try {
    flush();
    fetches.shift()!();
    await settle();
    parentRun = action(function* () {
      setRows(d => {
        d.push({ id: 1, title: "A" });
      });
      yield parentGate.promise;
    })();
    flush();
    expect(shown.at(-1)).toBe("A");
    childRun = action(function* () {
      setRows(d => {
        d[0].title = "B";
      });
      yield childGate.promise;
    })();
    flush();
    expect(shown.at(-1)).toBe("B");
    server = [{ id: 1, title: "S" }];
    refresh(rows);
    flush();
    fetches.shift()!();
    await settle();
    expect(shown.at(-1)).toBe("B");
    childGate.resolve();
    await childRun;
    await settle();
    expect(shown.at(-1)).toBe("B");
    parentGate.resolve();
    await parentRun;
    await settle();
    expect(shown.at(-1)).toBe("S");
  } finally {
    childGate.resolve();
    parentGate.resolve();
    await childRun;
    await parentRun;
    dispose();
    flush();
  }
});

it("keeps preobserved row leaves under a later index reorder guess", async () => {
  type Row = { id: number; title: string };
  let server: Row[] = [
    { id: 1, title: "one" },
    { id: 2, title: "two" }
  ];
  const fetches: Array<() => void> = [];
  const gate = Promise.withResolvers<void>();
  const shown: string[] = [];
  const [rows, setRows, dispose] = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore(
      () => new Promise<Row[]>(resolve => fetches.push(() => resolve(structuredClone(server)))),
      [] as Row[],
      { key: "id" }
    );
    createRenderEffect(
      () => rows.map(row => `${row.id}:${row.title}`).join(" "),
      value => {
        shown.push(value);
      }
    );
    return [rows, setRows, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    fetches.shift()!();
    await settle();
    expect(shown.at(-1)).toBe("1:one 2:two");
    const first = rows[0],
      second = rows[1];
    running = action(function* () {
      setRows(d => {
        d.reverse();
      });
      yield gate.promise;
    })();
    flush();
    expect(shown.at(-1)).toBe("2:two 1:one");
    expect([rows[0] === second, rows[1] === first]).toEqual([true, true]);
    server = [
      { id: 1, title: "saved-one" },
      { id: 2, title: "saved-two" }
    ];
    refresh(rows);
    flush();
    fetches.shift()!();
    await settle();
    expect(shown.at(-1)).toBe("2:two 1:one");
    gate.resolve();
    await running;
    await settle();
    expect(shown.at(-1)).toBe("1:saved-one 2:saved-two");
  } finally {
    gate.resolve();
    await running;
    dispose();
    flush();
  }
});
