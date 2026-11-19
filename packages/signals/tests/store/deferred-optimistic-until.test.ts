import { expect, it } from "vitest";
import {
  action,
  createEffect,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  flush,
  until
} from "../../src/index.js";

// `until` is deferred in the shared engine. The active controlled-gate twins
// live in createOptimisticStore.test.ts; these retain the automatic wakeup
// contract for when `until` is integrated.
const settle = async () => {
  await Promise.resolve();
  await Promise.resolve();
  await Promise.resolve();
  flush();
};

it.skip("until automatically finishes overlapping keyed adds from their producer echoes", async () => {
  type Row = { id: number };
  let answer = Promise.withResolvers<Row>();
  const confirm = (row: Row) => {
    const current = answer;
    answer = Promise.withResolvers<Row>();
    current.resolve(row);
  };
  const [items, setItems, dispose] = createRoot(dispose => {
    const [items, setItems] = createOptimisticStore(async function* (draft) {
      yield [] as Row[];
      while (true) {
        const row = await answer.promise;
        yield;
        draft.push(row);
      }
    }, [] as Row[]);
    createRenderEffect(
      () => items.map(row => row.id),
      () => {}
    );
    return [items, setItems, dispose] as const;
  });
  try {
    flush();
    await settle();
    const add = action(function* (row: Row) {
      setItems(d => {
        d.push(row);
      });
      yield until(() => items.some(item => item.id === row.id));
    });
    const a = add({ id: 0 });
    const b = add({ id: 1 });
    flush();
    expect(items.map(row => row.id)).toEqual([0, 1]);
    confirm({ id: 0 });
    await settle();
    confirm({ id: 1 });
    await Promise.all([a, b]);
    await settle();
    expect(items.map(row => row.id)).toEqual([0, 1]);
  } finally {
    dispose();
    flush();
  }
});

it.skip("until wakes on a keyed echo while a later gate retains optimistic pending flags", async () => {
  type Row = { id: number; pending: boolean };
  let answer = Promise.withResolvers<Row>();
  const confirm = (row: Row) => {
    const current = answer;
    answer = Promise.withResolvers<Row>();
    current.resolve(row);
  };
  const [items, setItems, dispose] = createRoot(dispose => {
    const [items, setItems] = createOptimisticStore(async function* (draft) {
      yield [] as Row[];
      while (true) {
        const row = await answer.promise;
        yield;
        draft.push({ ...row, pending: false });
      }
    }, [] as Row[]);
    createRenderEffect(
      () => items.map(row => row.pending),
      () => {}
    );
    return [items, setItems, dispose] as const;
  });
  const hold = Promise.withResolvers<void>();
  try {
    flush();
    await settle();
    const add = action(function* () {
      setItems(d => {
        d.push({ id: 0, pending: true });
      });
      yield until(() => items.some(item => item.id === 0));
      yield hold.promise;
    })();
    flush();
    confirm({ id: 0, pending: false });
    await settle();
    expect(items.map(row => row.pending)).toEqual([true]);
    hold.resolve();
    await add;
    await settle();
    expect(items.map(row => row.pending)).toEqual([false]);
  } finally {
    hold.resolve();
    dispose();
    flush();
  }
});

it.skip("until acknowledges a draft-mutating producer without a torn array frame", async () => {
  const gate = Promise.withResolvers<void>();
  const views: unknown[][] = [];
  const [items, setItems, dispose] = createRoot(dispose => {
    const [items, setItems] = createOptimisticStore<{ id: number }[]>(async function* (draft) {
      yield [];
      await gate.promise;
      yield;
      draft.push({ id: 1 });
    }, []);
    createEffect(
      () => items.map(item => item.id),
      value => {
        views.push(value);
      }
    );
    return [items, setItems, dispose] as const;
  });
  try {
    flush();
    await settle();
    const done = action(function* () {
      setItems(d => {
        d.push({ id: 1 });
      });
      gate.resolve();
      yield until(() => items.some(item => item.id === 1));
    })();
    await done;
    await settle();
    expect(items.map(item => item.id)).toEqual([1]);
    for (const frame of views) {
      expect(frame).not.toContain(undefined);
      expect(frame).not.toContain(null);
    }
  } finally {
    gate.resolve();
    dispose();
    flush();
  }
});
