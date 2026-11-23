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
} from "../../src/index.js";

type Row = { id: string; count: number };
const tick = () => new Promise(resolve => setTimeout(resolve, 0));

async function withMovedRow(
  producer: "returned" | "draft",
  select: (draft: Row[], initial: Row[]) => Row,
  inspect: (original: Row, moved: Row, saved: boolean, renderedCount: number) => void
) {
  const initial = [
    { id: "a", count: 0 },
    { id: "b", count: 0 }
  ];
  const countGate = Promise.withResolvers<void>();
  const moveGate = Promise.withResolvers<void>();
  let answer!: (rows: Row[]) => void;
  let screen!: { saved: boolean; rows: Row[] };

  const { rows, change, move, dispose } = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore(
      async draft => {
        const incoming = await new Promise<Row[]>(resolve => {
          answer = resolve;
        });
        if (producer === "returned") return incoming;
        for (let i = 0; i < incoming.length; i++) draft[i] = incoming[i];
        draft.length = incoming.length;
      },
      [] as Row[],
      { key: "id" }
    );
    const [saved, setSaved] = createSignal(false);
    createRenderEffect(
      () => ({ saved: saved(), rows: rows.map(({ id, count }) => ({ id, count })) }),
      value => {
        screen = value;
      }
    );

    const change = action(function* () {
      setRows(draft => {
        draft[0].count = 1;
      });
      yield countGate.promise;
      refresh(rows);
      setSaved(true);
    });
    const move = action(function* () {
      setRows(draft => {
        const a = select(draft, initial);
        draft.splice(0, 2, draft[1], a);
      });
      yield moveGate.promise;
    });
    return { rows, change, move, dispose };
  });
  try {
    flush();
    answer(initial);
    await tick();
    const original = rows[0];
    const changed = change();
    await tick();
    countGate.resolve();
    await tick();
    const moved = move();
    await tick();
    const selected = rows[1];
    answer([
      { id: "a", count: 2 },
      { id: "b", count: 0 }
    ]);
    await tick();
    expect(screen.rows.map(r => r.id)).toEqual(["b", "a"]);
    expect(rows[1]).toBe(selected);
    inspect(original, selected, screen.saved, screen.rows[1].count);
    moveGate.resolve();
    await Promise.all([changed, moved]);
    await tick();
    expect(rows[0]).toBe(original);
    expect(original.count).toBe(2);
    expect(screen.rows).toEqual([
      { id: "a", count: 2 },
      { id: "b", count: 0 }
    ]);
  } finally {
    moveGate.resolve();
    countGate.resolve();
    dispose();
  }
}

for (const producer of ["returned", "draft"] as const) {
  it(`restores the original keyed proxy after a whole-row guess and a ${producer} answer`, () =>
    withMovedRow(
      producer,
      () => ({ id: "a", count: 9 }),
      (original, moved, saved, count) => {
        expect(moved).not.toBe(original);
        expect([saved, count]).toEqual([true, 9]);
      }
    ));

  for (const from of ["draft", "raw"] as const) {
    it(`preserves a ${from} row's proxy across a move and a ${producer} answer`, () =>
      withMovedRow(
        producer,
        (draft, initial) => (from === "draft" ? draft : initial)[0],
        (original, moved) => {
          expect(moved).toBe(original);
        }
      ));
  }
}

it.each(["returned", "draft"] as const)(
  "%s answer publishes the corrected count together with saved while the moved row stays selected",
  producer =>
    withMovedRow(
      producer,
      draft => draft[0],
      (_original, _moved, saved, count) => {
        expect([saved, count]).toEqual([true, 2]);
      }
    )
);

it("keeps value, presence and keys together while a moved row's corrected count suspends", async () => {
  type Item = Row & { flag?: boolean };
  const ack = Promise.withResolvers<void>();
  const moveGate = Promise.withResolvers<void>();
  const calculated = Promise.withResolvers<number>();
  let answer!: (rows: Item[]) => void;
  let detail: number[] | undefined, saved: boolean | undefined;
  let rendered: unknown, late: unknown;
  const { change, move, mount, dispose } = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore(
      () =>
        new Promise<Item[]>(resolve => {
          answer = resolve;
        }),
      [] as Item[],
      { key: "id" }
    );
    const [isSaved, setSaved] = createSignal(false);
    const [visible, mount] = createSignal(false);
    const row = () => rows.find(row => row.id === "a")!;
    const summary = () => [row().count, "flag" in row(), Object.keys(row()).includes("flag")];
    const result = createMemo(() => {
      const count = row().count;
      return count === 2 ? calculated.promise : count;
    });
    createRenderEffect(isSaved, value => {
      saved = value;
    });
    createRenderEffect(
      () => [row().count, result()],
      value => {
        detail = value;
      }
    );
    createRenderEffect(
      () => {
        visible();
        return summary();
      },
      value => {
        rendered = value;
      }
    );
    createRenderEffect(
      () => (visible() ? summary() : null),
      value => {
        late = value;
      }
    );
    const change = action(function* () {
      setRows(draft => {
        draft[0].count = 1;
      });
      yield ack.promise;
      refresh(rows);
      setSaved(true);
    });
    const move = action(function* () {
      setRows(draft => {
        draft.reverse();
      });
      yield moveGate.promise;
    });
    return { change, move, mount, dispose };
  });
  try {
    flush();
    answer([
      { id: "a", count: 0 },
      { id: "b", count: 0 }
    ]);
    await tick();
    const changed = change();
    await tick();
    ack.resolve();
    await tick();
    const moved = move();
    await tick();
    answer([
      { id: "a", count: 2, flag: true },
      { id: "b", count: 0 }
    ]);
    await tick();
    mount(true);
    await tick();
    expect([saved, detail, rendered]).toEqual([false, [1, 1], [1, false, false]]);
    if (late !== null) expect(late).toEqual([1, false, false]);
    calculated.resolve(2);
    await tick();
    expect([saved, detail, rendered, late]).toEqual([
      true,
      [2, 2],
      [2, true, true],
      [2, true, true]
    ]);
    moveGate.resolve();
    await Promise.all([changed, moved]);
  } finally {
    ack.resolve();
    moveGate.resolve();
    calculated.resolve(2);
    dispose();
  }
});

it("a later refresh reaches a nested field when only the destination index is observed", async () => {
  type Item = { id: string; details: { count: number } };
  const gate = Promise.withResolvers<void>();
  let answer!: (rows: Item[]) => void;
  let shown: number | undefined;
  const { rows, move, dispose } = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore(
      () =>
        new Promise<Item[]>(resolve => {
          answer = resolve;
        }),
      [] as Item[],
      { key: "id" }
    );
    createRenderEffect(
      () => rows[1].details.count,
      count => {
        shown = count;
      }
    );
    const move = action(function* () {
      setRows(draft => {
        draft.reverse();
      });
      yield gate.promise;
    });
    return { rows, move, dispose };
  });
  const payload = (count: number) => [
    { id: "a", details: { count } },
    { id: "b", details: { count: 0 } }
  ];
  try {
    flush();
    answer(payload(0));
    await tick();
    const moved = move();
    await tick();
    refresh(rows);
    await tick();
    answer(payload(2));
    await tick();
    expect(shown).toBe(2);
    expect(rows[1].details.count).toBe(2);
    gate.resolve();
    await moved;
    await tick();
    expect(shown).toBe(0);
    expect(rows[0].details.count).toBe(2);
  } finally {
    gate.resolve();
    dispose();
  }
});

it("keeps a captured row live while a guess hides it from the keyed list", async () => {
  const release = Promise.withResolvers<void>();
  const { dispose, hide, receive, rows } = createRoot(dispose => {
    const [answer, receive] = createSignal([{ id: "a", count: 0 }]);
    const [rows, guess] = createOptimisticStore(() => answer(), [] as Row[], { key: "id" });
    const hide = action(function* () {
      guess(draft => {
        draft.length = 0;
      });
      yield release.promise;
    });
    return { dispose, hide, receive, rows };
  });
  const original = rows[0];
  const hiding = hide();
  try {
    await tick();
    receive([{ id: "a", count: 2 }]);
    await tick();
    expect(rows.length).toBe(0);
    expect(original.count).toBe(2);
    release.resolve();
    await hiding;
    expect(rows[0]).toBe(original);
  } finally {
    release.resolve();
    dispose();
  }
});
