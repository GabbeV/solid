import { expect, it } from "vitest";
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

it("a list follows a foreign person until editing its own view", () => {
  const [person, rename] = createStore({ name: "Alice" });
  const [list, edit] = createStore({ people: [person] });
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

it("a foreign proxy inserted by a setter keeps the same isolation", () => {
  const [person] = createStore({ name: "Alice" });
  const [list, edit] = createStore({ people: [] as (typeof person)[] });
  edit(d => {
    d.people.push(person);
  });
  flush();
  edit(d => {
    d.people[0].name = "Bob";
  });
  flush();
  expect([person.name, list.people[0].name]).toEqual(["Alice", "Bob"]);
});

it("a mark belongs to the capturing list", async () => {
  const [person] = createStore({ name: "Alice" });
  const [list] = createStore({ people: [person] });
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

it("reconciling a list leaves its input store alone", () => {
  const [person] = createStore({ id: 1, name: "Alice" });
  const [list, edit] = createStore({ people: [person] });
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

it("aliased rows agree through property reads, deep and snapshot", () => {
  const [person] = createStore({ name: "Alice" });
  const [list, edit] = createStore([person, person]);
  edit(d => {
    d[0].name = "Bob";
  });
  flush();
  expect(list[1]).toBe(list[0]);
  expect(snapshot(list).map(row => row.name)).toEqual(["Bob", "Bob"]);
  expect(deep(list).map(row => row.name)).toEqual(["Bob", "Bob"]);
});

it("isolates writes through a nested object", () => {
  const [person] = createStore({ address: { city: "Oslo" } });
  const [list, edit] = createStore([person]);
  edit(d => {
    d[0].address.city = "Paris";
  });
  flush();
  expect([person.address.city, list[0].address.city]).toEqual(["Oslo", "Paris"]);
});

it("a shallow store isolates an explicitly supplied store", () => {
  const [person] = createStore({ name: "Alice" });
  const [list, edit] = createStore({ first: person, second: person }, { shallow: true });
  edit(d => {
    d.first.name = "Bob";
  });
  flush();
  expect([person.name, list.first.name, list.second.name]).toEqual(["Alice", "Bob", "Bob"]);
});

it("a store created or replaced from a read proxy owns its writes", () => {
  const [person] = createStore({ name: "Alice" });
  const [first, renameFirst] = createStore(person);
  const [second, renameSecond] = createStore({ name: "" });
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

it("keeps nested store writes local when a row has an accessor", () => {
  const [person] = createStore({
    name: "Alice",
    get label() {
      return this.name;
    },
    address: { city: "Oslo" }
  });
  const [list, edit] = createStore([person]);
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

it("reconciles a read proxy at the root without acquiring its backing", () => {
  const [person, setPerson] = createStore({ name: "Alice", address: { city: "Oslo" } });
  const [view, setView] = createStore({ name: "", address: { city: "" } });
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

it("marking a captured row isolates its nested fields", async () => {
  const [person] = createStore({ address: { city: "Oslo" } });
  const [list] = createStore([person]);
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

it("marks a nested row first captured during the window without marking its input or sibling", async () => {
  const [person] = createStore({ address: { city: "Oslo" } });
  const [list] = createStore([person]);
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
