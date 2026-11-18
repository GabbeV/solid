import { expect, it, vi } from "vitest";
import {
  action,
  affects,
  createMemo,
  createRenderEffect,
  createRoot,
  createStore,
  flush,
  isPending,
  reconcile,
  deep,
  snapshot
} from "../../src/index.js";

it.each(["plain", "derived"] as const)("a plain list shares a %s source and its writes", kind => {
  const [input] = createStore({ name: "Alice" });
  const [person, rename] = kind === "plain" ? createStore(input) : createStore(() => input);
  const [list, edit] = createStore({ people: [person] });
  const [second] = createStore({ people: [person] });
  flush();
  expect(list.people[0]).toBe(person);
  expect(second.people[0]).toBe(person);
  edit(draft => {
    draft.people[0].name = "Bob";
  });
  flush();
  expect([person.name, list.people[0].name, second.people[0].name]).toEqual(["Bob", "Bob", "Bob"]);
  expect(snapshot(list).people[0].name).toBe("Bob");
  expect(deep(list).people[0].name).toBe("Bob");
  rename(draft => {
    draft.name = "Carol";
  });
  flush();
  expect([person.name, list.people[0].name, second.people[0].name]).toEqual([
    "Carol",
    "Carol",
    "Carol"
  ]);
  expect(input.name).toBe(kind === "plain" ? "Carol" : "Alice");
});

it("a derived list follows its source until editing its own view", () => {
  const [person, rename] = createStore({ name: "Alice" });
  const [list, edit] = createStore(() => ({ people: [person] }));
  const [second] = createStore({ people: [person] });
  const row = list.people[0];
  expect(row).not.toBe(person);
  rename(p => {
    p.name = "Bea";
  });
  flush();
  expect(row.name).toBe("Bea");
  edit(d => {
    d.people[0].name = "Bob";
  });
  flush();
  expect([person.name, row.name, list.people[0].name, second.people[0].name]).toEqual([
    "Bea",
    "Bob",
    "Bob",
    "Bea"
  ]);
  expect(list.people[0]).toBe(row);
  expect(snapshot(list).people[0].name).toBe("Bob");
  rename(d => {
    d.name = "Carla";
  });
  flush();
  expect([person.name, row.name, second.people[0].name]).toEqual(["Carla", "Bob", "Carla"]);
});

it("independent stores still share a raw child", () => {
  const input = { name: "Alice" };
  const [first, edit] = createStore({ input });
  const [second] = createStore({ input });
  const child = first.input;
  expect(second.input).toBe(child);
  edit(draft => {
    draft.input.name = "Bob";
  });
  flush();
  expect(second.input).toBe(child);
  expect(second.input.name).toBe("Bob");
  expect(input.name).toBe("Alice");
});

it.each(["plain", "derived"] as const)("a setter inserts a store into a %s list", kind => {
  const [person, rename] = createStore({ name: "Alice" });
  const seed = { people: [] as (typeof person)[] };
  const [list, edit] = kind === "plain" ? createStore(seed) : createStore(() => seed);
  edit(d => {
    d.people.push(person);
    d.people[1] = person;
  });
  flush();
  const row = list.people[0];
  expect(list.people[1]).toBe(row);
  if (kind === "plain") expect(row).toBe(person);
  else expect(row).not.toBe(person);
  rename(d => {
    d.name = "Bea";
  });
  flush();
  expect([row.name, list.people[1].name]).toEqual(["Bea", "Bea"]);
  edit(d => {
    d.people[0].name = "Bob";
  });
  flush();
  expect(list.people[0]).toBe(row);
  expect([person.name, row.name, list.people[1].name]).toEqual([
    kind === "plain" ? "Bob" : "Bea",
    "Bob",
    "Bob"
  ]);
});

it("a plain setter retains both a derived source and a row from that source", () => {
  const [input] = createStore({ name: "Alice", tags: ["a"] });
  const [source, editSource] = createStore(() => ({ people: [input] }));
  const row = source.people[0];
  const [holder, edit] = createStore<{ source?: typeof source; rows: (typeof row)[] }>({
    rows: []
  });
  edit(draft => {
    draft.source = source;
    draft.rows.push(row);
  });
  flush();
  expect(holder.source).toBe(source);
  expect(holder.rows[0]).toBe(row);
  expect(holder.source!.people[0]).toBe(row);

  const seen: string[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => `${holder.source!.people[0].name}/${holder.rows[0].tags.length}`,
      value => void seen.push(value)
    );
    return dispose;
  });
  try {
    flush();
    editSource(draft => {
      draft.people[0].name = "Bob";
      draft.people[0].tags.push("b");
    });
    flush();
    expect(seen).toEqual(["Alice/1", "Bob/2"]);
    expect(snapshot(holder)).toEqual({
      source: { people: [{ name: "Bob", tags: ["a", "b"] }] },
      rows: [{ name: "Bob", tags: ["a", "b"] }]
    });
    edit(draft => {
      draft.rows[0].name = "Carol";
    });
    flush();
    expect(seen).toEqual(["Alice/1", "Bob/2", "Carol/2"]);
    expect(source.people[0]).toBe(row);
    expect(snapshot(input)).toEqual({ name: "Alice", tags: ["a"] });
  } finally {
    dispose();
  }
});

it.each(["plain", "derived"] as const)(
  "a %s setter uses its own write scope for a captured plain store",
  kind => {
    const [person] = createStore({ name: "Alice" });
    const initial = { edited: false };
    const [holder, edit] = kind === "plain" ? createStore(initial) : createStore(() => initial);
    const warn = vi.spyOn(console, "warn").mockImplementation(() => {});
    try {
      edit(draft => {
        person.name = "Bob";
        draft.edited = true;
      });
      flush();
      expect([person.name, holder.edited]).toEqual([kind === "plain" ? "Bob" : "Alice", true]);
    } finally {
      warn.mockRestore();
    }
  }
);

it("a derived list marks its own view of a row", async () => {
  const [person] = createStore({ name: "Alice" });
  const [list] = createStore(() => ({ people: [person] }));
  const [other] = createStore({ people: [person] });
  const row = list.people[0];
  const sibling = other.people[0];
  let observed: readonly boolean[] = [];
  const dispose = createRoot(d => {
    createRenderEffect(
      () => [
        isPending(() => person.name),
        isPending(() => row.name),
        isPending(() => sibling.name)
      ],
      v => {
        observed = v;
      }
    );
    return d;
  });
  flush();
  const hold = Promise.withResolvers<void>();
  const running = action(function* () {
    affects(list);
    yield hold.promise;
  })();
  try {
    flush();
    expect(observed).toEqual([false, true, false]);
  } finally {
    hold.resolve();
    await running;
    flush();
    dispose();
  }
});

it("reconciling a derived list leaves its input store alone", () => {
  const [person] = createStore({ id: 1, name: "Alice" });
  const [list, edit] = createStore(() => ({ people: [person] }));
  const row = list.people[0];
  const values: string[] = [];
  const dispose = createRoot(d => {
    createRenderEffect(
      () => person.name + "/" + row.name,
      v => {
        values.push(v);
      }
    );
    return d;
  });
  flush();
  edit(reconcile({ people: [{ id: 1, name: "Bob" }] }, "id"));
  flush();
  expect([person.name, list.people[0].name, row.name]).toEqual(["Alice", "Bob", "Bob"]);
  expect(values).toEqual(["Alice/Alice", "Alice/Bob"]);
  dispose();
});

it.each(["plain", "derived"] as const)(
  "aliased rows in a %s list agree through property reads, deep and snapshot",
  kind => {
    const [person] = createStore({ name: "Alice" });
    const initial = [person, person];
    const [list, edit] =
      kind === "plain" ? createStore(initial) : createStore(() => initial, [] as typeof initial);
    expect(list[1]).toBe(list[0]);
    edit(d => {
      d[0].name = "Bob";
    });
    flush();
    expect(list[1]).toBe(list[0]);
    expect(list[1].name).toBe("Bob");
    expect(person.name).toBe(kind === "plain" ? "Bob" : "Alice");
    expect(snapshot(list).map(row => row.name)).toEqual(["Bob", "Bob"]);
    expect(deep(list).map(row => row.name)).toEqual(["Bob", "Bob"]);
  }
);

it("a derived list isolates writes through a nested object", () => {
  const [person] = createStore({ address: { city: "Oslo" } });
  const [list, edit] = createStore(() => [person], [] as (typeof person)[]);
  edit(d => {
    d[0].address.city = "Paris";
  });
  flush();
  expect([person.address.city, list[0].address.city]).toEqual(["Oslo", "Paris"]);
});

it("a shallow derived store isolates an explicitly supplied store", () => {
  const [person] = createStore({ name: "Alice" });
  const [list, edit] = createStore(() => ({ first: person, second: person }), undefined, {
    shallow: true
  });
  edit(d => {
    d.first.name = "Bob";
  });
  flush();
  expect([person.name, list.first.name, list.second.name]).toEqual(["Alice", "Bob", "Bob"]);
});

it("a derived store created or replaced from a read proxy owns its writes", () => {
  const [person] = createStore({ name: "Alice" });
  const [first, renameFirst] = createStore(() => person);
  const [second, renameSecond] = createStore(() => ({ name: "" }));
  renameSecond(() => person);
  flush();
  renameFirst(d => {
    d.name = "Bea";
  });
  renameSecond(d => {
    d.name = "Bob";
  });
  flush();
  expect([person.name, first.name, second.name]).toEqual(["Alice", "Bea", "Bob"]);
});

it.each(["plain", "derived"] as const)(
  "a setter return shallowly replaces slots in a %s store",
  kind => {
    const initial = { rows: [{ id: 1, name: "Alice" }] };
    const [list, edit] = kind === "plain" ? createStore(initial) : createStore(() => initial);
    const captured = list.rows[0];
    edit(() => ({ rows: [{ id: 1, name: "Bob" }] }));
    flush();
    expect(list.rows[0]).not.toBe(captured);
    expect(list.rows[0].name).toBe("Bob");
    expect(captured.name).toBe("Alice");
  }
);

it("a derived list keeps nested store writes local when a row has an accessor", () => {
  const [person] = createStore({
    name: "Alice",
    get label() {
      return this.name;
    },
    address: { city: "Oslo" }
  });
  const [list, edit] = createStore(() => [person], [] as (typeof person)[]);
  edit(d => {
    d[0].name = "Bob";
  });
  flush();
  edit(d => {
    d[0].address.city = "Paris";
  });
  flush();
  expect([person.address.city, list[0].address.city]).toEqual(["Oslo", "Paris"]);
});

it("a derived store reconciles a read proxy at the root without acquiring its backing", () => {
  const [person, setPerson] = createStore({ name: "Alice", address: { city: "Oslo" } });
  const [view, setView] = createStore(() => ({ name: "", address: { city: "" } }));
  setPerson(draft => {
    draft.name = "Bea";
  });
  flush();
  setView(reconcile(person, null));
  flush();
  setView(draft => {
    draft.address.city = "Paris";
  });
  flush();
  expect([person.address.city, view.address.city]).toEqual(["Oslo", "Paris"]);
});

it("marking a captured derived row isolates its nested fields", async () => {
  const [person] = createStore({ address: { city: "Oslo" } });
  const [list] = createStore(() => [person], [] as (typeof person)[]);
  const address = list[0].address;
  const hold = Promise.withResolvers<void>();
  const done = action(function* () {
    affects(list[0]);
    yield hold.promise;
  })();
  try {
    flush();
    expect([isPending(() => address.city), isPending(() => person.address.city)]).toEqual([
      true,
      false
    ]);
  } finally {
    hold.resolve();
    await done;
    flush();
  }
});

it("a derived list marks a row first captured during the window without marking its input or sibling", async () => {
  const [person] = createStore({ address: { city: "Oslo" } });
  const [list] = createStore(() => [person], [] as (typeof person)[]);
  const [other] = createStore([person]);
  const hold = Promise.withResolvers<void>();
  const done = action(function* () {
    affects(list);
    yield hold.promise;
  })();
  try {
    flush();
    const address = list[0].address;
    const sibling = other[0].address;
    expect([
      isPending(() => address.city),
      isPending(() => person.address.city),
      isPending(() => sibling.city)
    ]).toEqual([true, false, false]);
  } finally {
    hold.resolve();
    await done;
    flush();
  }
});

it("a shared raw child captured during a mark retains it after a write", async () => {
  const input = { name: "Alice", late: true };
  const [first] = createStore({ input });
  const [second, edit] = createStore({ input });
  const finish = Promise.withResolvers<void>();
  const done = action(function* () {
    affects(first);
    yield finish.promise;
  })();
  const child = second.input;
  let dispose!: () => void;
  try {
    const pending = createRoot(d => {
      dispose = d;
      return createMemo(() => isPending(() => child.name));
    });
    flush();
    expect(pending()).toBe(true);
    edit(draft => {
      draft.input.name = "Bob";
    });
    flush();
    expect(first.input).toBe(child);
    expect(second.input).toBe(child);
    expect(isPending(() => child.late)).toBe(true);
  } finally {
    finish.resolve();
    await done;
    dispose?.();
    flush();
  }
});
