import { expect, it } from "vitest";
import {
  action,
  createRenderEffect,
  createRoot,
  createStore,
  deep,
  flush,
  reconcile,
  snapshot
} from "../../src/index.js";

it.each(["root", "nested"] as const)(
  "a first read of a held reconciled row preserves its %s source",
  async source => {
    const [person] = createStore({ id: 1, name: "Alice" });
    const [directory] = createStore({ people: [{ id: 1, name: "Alice" }] });
    const input = () => (source === "root" ? person : directory.people[0]);
    const [view, edit] = createStore(() => ({ rows: [input()] }));
    flush();

    const hold = Promise.withResolvers<void>();
    const running = action(function* () {
      edit(draft => {
        reconcile([{ id: 1, name: "Bob" }])(draft.rows);
      });
      yield hold.promise;
    })();
    try {
      flush();
      expect(view.rows[0].name).toBe("Alice");
    } finally {
      hold.resolve();
      await running;
      flush();
    }

    expect([input().name, view.rows[0].name]).toEqual(["Alice", "Bob"]);
  }
);

it.each(["synchronous", "held"] as const)(
  "all readers agree through a %s foreign row edit",
  async mode => {
    const [person] = createStore({ id: 1, name: "Alice" });
    const [view, edit] = createStore(() => ({ rows: [person] }));
    const [holder] = createStore({ view });
    const reads = () => [
      view.rows[0].name,
      snapshot(view).rows[0].name,
      deep(view).rows[0].name,
      holder.view.rows[0].name,
      snapshot(holder).view.rows[0].name,
      deep(holder).view.rows[0].name,
      person.name
    ];
    const mutate = () =>
      edit(draft => {
        draft.rows[0].name = "Bob";
      });

    flush();
    const before = ["Alice", "Alice", "Alice", "Alice", "Alice", "Alice", "Alice"];
    expect(reads()).toEqual(before);
    if (mode === "held") {
      const hold = Promise.withResolvers<void>();
      const running = action(function* () {
        mutate();
        yield hold.promise;
      })();
      try {
        flush();
        expect(reads()).toEqual(before);
      } finally {
        hold.resolve();
        await running;
      }
    } else {
      mutate();
    }
    flush();
    expect(reads()).toEqual(["Bob", "Bob", "Bob", "Bob", "Bob", "Bob", "Alice"]);
  }
);

it.each(["unobserved", "observed"] as const)(
  "reconciling a plain holder keeps the %s derived row's source isolated",
  mode => {
    const [person] = createStore({ id: 1, name: "Alice" });
    const [view] = createStore(() => ({ row: person }));
    const row = view.row;
    const [card, setCard] = createStore({ row });
    const observed: string[] = [];
    const dispose = createRoot(dispose => {
      if (mode === "observed")
        createRenderEffect(
          () => row.name,
          name => void observed.push(name)
        );
      return dispose;
    });
    try {
      flush();
      expect(card.row).toBe(row);
      setCard(reconcile({ row: { id: 1, name: "Bob" } }, "id"));
      flush();
      expect(person.name).toBe("Alice");
      expect([card.row.name, snapshot(card).row.name, deep(card).row.name]).toEqual([
        "Bob",
        "Bob",
        "Bob"
      ]);
      expect([view.row.name, snapshot(view).row.name, deep(view).row.name]).toEqual([
        row.name,
        row.name,
        row.name
      ]);
      if (mode === "observed") expect(observed.at(-1)).toBe(row.name);
    } finally {
      dispose();
    }
  }
);

it.each(["plain", "derived"] as const)(
  "a %s setter copies the root slots of a returned store proxy",
  mode => {
    let getterReads = 0;
    const [person, rename] = createStore({
      name: "Alice",
      address: { city: "Oslo" },
      get label() {
        getterReads++;
        return this.name;
      }
    });
    const initial = { name: "", address: { city: "" }, label: "" };
    const [view, edit] = mode === "plain" ? createStore(initial) : createStore(() => initial);
    rename(draft => {
      draft.name = "Bea";
    });
    flush();
    edit(() => person);
    flush();
    rename(draft => {
      draft.name = "Carla";
    });
    flush();
    expect(getterReads).toBe(0);
    expect([view.name, view.label, person.name]).toEqual(["Bea", "Bea", "Carla"]);
    if (mode === "plain") expect(view.address).toBe(person.address);
    edit(draft => {
      draft.address.city = "Paris";
    });
    flush();
    expect([person.address.city, view.address.city]).toEqual([
      mode === "plain" ? "Paris" : "Oslo",
      "Paris"
    ]);
  }
);

it("plain stores pass through an explicit derived slot supplied by a setter", () => {
  const [person] = createStore({ name: "Alice" });
  const [view] = createStore(() => ({ row: person }));
  const [held, updateHeld] = createStore({ row: { name: "" } });
  const [returned, updateReturned] = createStore({ row: { name: "" } });
  const [same] = createStore(view.row);
  updateHeld(draft => {
    draft.row = view.row;
  });
  updateReturned(() => ({ row: view.row }));
  flush();
  expect(same).toBe(view.row);
  expect(held.row).toBe(view.row);
  expect(returned.row).toBe(view.row);
  updateHeld(draft => {
    draft.row.name = "Bob";
  });
  flush();
  expect([person.name, same.name, view.row.name, held.row.name, returned.row.name]).toEqual([
    "Alice",
    "Bob",
    "Bob",
    "Bob",
    "Bob"
  ]);
});
