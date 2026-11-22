import { expect, it } from "vitest";
import {
  action,
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

// The save publishes while its count still reads 0 through the moved row.
it.fails(
  "publishes the corrected count together with saved for an existing row moved by reference",
  async () => {
    let landing: unknown;
    await withMovedRow(
      "returned",
      draft => draft[0],
      (_original, _moved, saved, count) => {
        landing = [saved, count];
      }
    );
    expect(landing).toEqual([true, 2]);
  }
);
