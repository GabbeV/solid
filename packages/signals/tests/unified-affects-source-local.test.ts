import { expect, it } from "vitest";
import {
  action,
  affects,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  flush,
  isPending
} from "../src/index.js";

type Person = { id: number; name: string };

function fixture(optimistic: boolean) {
  return createRoot(dispose => {
    const [person] = createStore({ id: 1, name: "Alice" });
    const [second] = createStore({ id: 2, name: "Bob" });
    const [grow, setGrow] = createSignal(false);
    let producerRuns = 0;
    const produce = () => {
      producerRuns++;
      return { people: grow() ? [person, second] : [person] };
    };
    const initial = { people: [] as Person[] };
    const [list, guess] = optimistic
      ? createOptimisticStore(produce, initial)
      : createStore(produce, initial);
    const row = list.people[0];
    let valueRuns = 0;
    const names = createMemo(() => {
      valueRuns++;
      return [person.name, row.name];
    });
    const values: string[][] = [];
    const pending: boolean[][] = [];
    createRenderEffect(names, value => void values.push(value));
    createRenderEffect(
      () => [isPending(() => person.name), isPending(() => row.name)],
      value => void pending.push([...value])
    );
    return {
      person,
      second,
      list,
      row,
      guess,
      setGrow,
      pending,
      values,
      producerRuns: () => producerRuns,
      valueRuns: () => valueRuns,
      dispose
    };
  });
}

function mark(store: object) {
  const end = Promise.withResolvers<void>();
  const running = action(function* () {
    affects(store);
    yield end.promise;
  })();
  return {
    async release() {
      end.resolve();
      await running;
      flush();
    }
  };
}

for (const optimistic of [false, true]) {
  const kind = optimistic ? "optimistic derived" : "derived";

  it(`${kind} output marks captured children without marking their independent source`, async () => {
    const app = fixture(optimistic);
    flush();
    expect(app.row).not.toBe(app.person);
    expect(app.pending).toEqual([[false, false]]);
    const producerRuns = app.producerRuns();
    const valueRuns = app.valueRuns();
    const marked = mark(app.list);
    try {
      flush();
      expect(app.pending).toEqual([
        [false, false],
        [false, true]
      ]);
      expect(app.list.people[0]).toBe(app.row);
      expect(app.values).toEqual([["Alice", "Alice"]]);
      expect(app.producerRuns()).toBe(producerRuns);
      expect(app.valueRuns()).toBe(valueRuns);
      await marked.release();
      expect(app.pending).toEqual([
        [false, false],
        [false, true],
        [false, false]
      ]);
      expect(app.values).toEqual([["Alice", "Alice"]]);
      expect(app.producerRuns()).toBe(producerRuns);
      expect(app.valueRuns()).toBe(valueRuns);
    } finally {
      await marked.release();
      app.dispose();
      flush();
    }
  });

  it(`${kind} output marks are visible to late mounted memo captures`, async () => {
    const app = fixture(optimistic);
    flush();
    const marked = mark(app.list);
    let disposeLate: (() => void) | undefined;
    try {
      flush();
      const late = createRoot(dispose => {
        disposeLate = dispose;
        const pending = createMemo(() => {
          // Capture happens inside tracking while the declaration is already open.
          const row = app.list.people[0];
          return [isPending(() => app.person.name), isPending(() => row.name)];
        });
        const seen: boolean[][] = [];
        createRenderEffect(pending, value => void seen.push(value));
        return { pending, seen };
      });
      flush();
      expect(late.pending()).toEqual([false, true]);
      expect(late.seen).toEqual([[false, true]]);
      await marked.release();
      expect(late.pending()).toEqual([false, false]);
      expect(late.seen).toEqual([
        [false, true],
        [false, false]
      ]);
    } finally {
      await marked.release();
      disposeLate?.();
      app.dispose();
      flush();
    }
  });

  it(`${kind} output keeps newly introduced rows marked across producer rederivation`, async () => {
    const app = fixture(optimistic);
    flush();
    const marked = mark(app.list);
    let disposeLate: (() => void) | undefined;
    try {
      flush();
      // This is an independent synchronous update while the mark action stays open.
      app.setGrow(true);
      flush();
      expect(app.list.people.length).toBe(2);
      expect(app.list.people.map(person => person.name)).toEqual(["Alice", "Bob"]);
      const added = app.list.people[1];
      expect(added).not.toBe(app.second);
      const late = createRoot(dispose => {
        disposeLate = dispose;
        const pending = createMemo(() => [
          isPending(() => app.person.name),
          isPending(() => app.second.name),
          isPending(() => app.row.name),
          isPending(() => added.name)
        ]);
        const seen: boolean[][] = [];
        createRenderEffect(pending, value => void seen.push(value));
        return { pending, seen };
      });
      flush();
      expect(late.pending()).toEqual([false, false, true, true]);
      expect(app.person.name).toBe("Alice");
      expect(app.second.name).toBe("Bob");
      const producerRuns = app.producerRuns();
      await marked.release();
      expect(late.seen).toEqual([
        [false, false, true, true],
        [false, false, false, false]
      ]);
      expect(app.list.people[1]).toBe(added);
      expect(app.list.people.map(person => person.name)).toEqual(["Alice", "Bob"]);
      expect(app.producerRuns()).toBe(producerRuns);
    } finally {
      await marked.release();
      disposeLate?.();
      app.dispose();
      flush();
    }
  });
}

it("an active optimistic override does not mask a derived output mark", async () => {
  const app = fixture(true);
  flush();
  const save = Promise.withResolvers<void>();
  const saving = action(function* () {
    app.guess(draft => {
      draft.people[0].name = "Optimistic Alice";
    });
    yield save.promise;
  })();
  let marked: ReturnType<typeof mark> | undefined;
  try {
    flush();
    expect(app.list.people[0].name).toBe("Optimistic Alice");
    expect(app.person.name).toBe("Alice");
    marked = mark(app.list);
    flush();
    expect(app.pending.at(-1)).toEqual([false, true]);
    expect(app.list.people[0].name).toBe("Optimistic Alice");
    await marked.release();
    expect(app.pending.at(-1)).toEqual([false, false]);
    expect(app.list.people[0].name).toBe("Optimistic Alice");
    save.resolve();
    await saving;
    flush();
    expect(app.list.people[0].name).toBe("Alice");
    expect(app.pending.at(-1)).toEqual([false, false]);
  } finally {
    await marked?.release();
    save.resolve();
    await saving;
    app.dispose();
    flush();
  }
});

it("independent overlapping output marks release separately without marking the source", async () => {
  const app = fixture(false);
  flush();
  const first = mark(app.list);
  flush();
  const second = mark(app.list);
  try {
    flush();
    expect(app.pending.at(-1)).toEqual([false, true]);
    await first.release();
    expect(app.pending.at(-1)).toEqual([false, true]);
    expect(isPending(() => app.person.name)).toBe(false);
    await second.release();
    expect(app.pending).toEqual([
      [false, false],
      [false, true],
      [false, false]
    ]);
    expect(app.values).toEqual([["Alice", "Alice"]]);
  } finally {
    await first.release();
    await second.release();
    app.dispose();
    flush();
  }
});

it("a keyed derived child mark leaves the source and the sibling key unmarked", async () => {
  const app = fixture(false);
  flush();
  const end = Promise.withResolvers<void>();
  const running = action(function* () {
    affects(app.row, "name");
    yield end.promise;
  })();
  const sample = () => [
    isPending(() => app.person.name),
    isPending(() => app.person.id),
    isPending(() => app.row.name),
    isPending(() => app.row.id)
  ];
  try {
    flush();
    expect(sample()).toEqual([false, false, true, false]);
    expect(app.values).toEqual([["Alice", "Alice"]]);
    end.resolve();
    await running;
    flush();
    expect(sample()).toEqual([false, false, false, false]);
  } finally {
    end.resolve();
    await running;
    app.dispose();
    flush();
  }
});

it("a nested derived row mark leaves sibling rows and their sources unmarked", async () => {
  const app = fixture(false);
  app.setGrow(true);
  flush();
  const sibling = app.list.people[1];
  const marked = mark(app.row);
  const sample = () => [
    isPending(() => app.person.name),
    isPending(() => app.second.name),
    isPending(() => app.row.name),
    isPending(() => app.row.id),
    isPending(() => sibling.name),
    isPending(() => sibling.id)
  ];
  try {
    flush();
    expect(sample()).toEqual([false, false, true, true, false, false]);
    expect(app.list.people.map(person => person.name)).toEqual(["Alice", "Bob"]);
    await marked.release();
    expect(sample()).toEqual([false, false, false, false, false, false]);
    expect(app.list.people[0]).toBe(app.row);
    expect(app.list.people[1]).toBe(sibling);
  } finally {
    await marked.release();
    app.dispose();
    flush();
  }
});

it("a retained nested derived record keeps its mark for late property and memo readers after a draft update", async () => {
  type Row = Person & { nickname?: string };
  const app = createRoot(dispose => {
    const [person] = createStore<Row>({ id: 1, name: "Alice" });
    const [version, setVersion] = createSignal(0);
    const [list] = createStore(
      draft => {
        if (version() === 0) draft.people = [person];
        else draft.people[0].nickname = "Al";
      },
      { people: [] as Row[] }
    );
    const row = list.people[0];
    return { person, list, row, setVersion, dispose };
  });
  flush();
  expect(app.row).not.toBe(app.person);
  const marked = mark(app.row);
  let disposeLate: (() => void) | undefined;
  try {
    flush();
    expect(isPending(() => app.row.name)).toBe(true);
    app.setVersion(1);
    flush();
    // This case is about retaining one record, not replacing a marked record.
    expect(app.list.people[0]).toBe(app.row);
    const late = createRoot(dispose => {
      disposeLate = dispose;
      const nickname = createMemo(() => app.row.nickname);
      const pending = createMemo(() => [
        isPending(() => app.person.name),
        isPending(() => app.person.nickname),
        isPending(() => app.row.name),
        isPending(nickname)
      ]);
      const seen: boolean[][] = [];
      createRenderEffect(pending, value => void seen.push(value));
      return { nickname, pending, seen };
    });
    flush();
    expect(late.nickname()).toBe("Al");
    expect(app.person.nickname).toBeUndefined();
    expect(late.pending()).toEqual([false, false, true, true]);
    await marked.release();
    expect(late.seen).toEqual([
      [false, false, true, true],
      [false, false, false, false]
    ]);
    expect(app.list.people[0]).toBe(app.row);
    expect(late.nickname()).toBe("Al");
  } finally {
    await marked.release();
    disposeLate?.();
    app.dispose();
    flush();
  }
});

it("question: should a plain list mark exclude its shared child source?", async () => {
  const app = createRoot(dispose => {
    const [person] = createStore({ id: 1, name: "Alice" });
    const [list] = createStore({ people: [person] });
    const row = list.people[0];
    const pending: boolean[][] = [];
    createRenderEffect(
      () => [isPending(() => person.name), isPending(() => list.people[0].name)],
      value => void pending.push([...value])
    );
    return { person, list, row, pending, dispose };
  });
  flush();
  expect(app.row).toBe(app.person);
  expect(app.pending).toEqual([[false, false]]);
  const marked = mark(app.list);
  try {
    flush();
    expect(app.pending).toEqual([
      [false, false],
      [false, true]
    ]);
    expect(app.list.people[0]).toBe(app.row);
    expect(app.list.people[0]).toBe(app.person);
    expect(app.person.name).toBe("Alice");
    expect(app.list.people[0].name).toBe("Alice");
    await marked.release();
    expect(app.pending).toEqual([
      [false, false],
      [false, true],
      [false, false]
    ]);
    expect(app.list.people[0]).toBe(app.person);
  } finally {
    await marked.release();
    app.dispose();
    flush();
  }
});

it("a property memo born under independent root and nested row marks stays pending until both release", async () => {
  const app = createRoot(dispose => {
    const [person] = createStore({ id: 1, name: "Alice", nickname: "Al" });
    const [list] = createStore(() => ({ people: [person] }), { people: [] });
    const row = list.people[0];
    return { person, list, row, dispose };
  });
  flush();
  const rootMark = mark(app.list);
  flush();
  const rowMark = mark(app.row);
  let disposeLate: (() => void) | undefined;
  try {
    flush();
    const late = createRoot(dispose => {
      disposeLate = dispose;
      // This property node and its memo are first read with both marks open.
      const nickname = createMemo(() => app.row.nickname);
      const pending = createMemo(() => [isPending(() => app.person.nickname), isPending(nickname)]);
      const seen: boolean[][] = [];
      createRenderEffect(pending, value => void seen.push(value));
      return { nickname, pending, seen };
    });
    flush();
    expect(late.nickname()).toBe("Al");
    expect(late.pending()).toEqual([false, true]);
    await rootMark.release();
    expect(late.pending()).toEqual([false, true]);
    expect(late.nickname()).toBe("Al");
    await rowMark.release();
    expect(late.pending()).toEqual([false, false]);
    expect(late.seen).toEqual([
      [false, true],
      [false, false]
    ]);
    expect(app.list.people[0]).toBe(app.row);
  } finally {
    await rootMark.release();
    await rowMark.release();
    disposeLate?.();
    app.dispose();
    flush();
  }
});
