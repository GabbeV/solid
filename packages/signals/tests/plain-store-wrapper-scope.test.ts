import { describe, expect, it } from "vitest";
import {
  action,
  affects,
  createRenderEffect,
  createRoot,
  createStore,
  flush,
  isPending
} from "../src/index.js";

function gate() {
  let resolve!: () => void;
  const promise = new Promise<void>(r => (resolve = r));
  return { promise, resolve };
}

function fixture(derived: boolean) {
  const disposers: (() => void)[] = [];
  const stores = createRoot(dispose => {
    disposers.push(dispose);
    const [person, setPerson] = createStore({ name: "Ada", detail: { city: "London" } });
    const [list, setList] = derived ? createStore(() => ({ person })) : createStore({ person });
    return { person, setPerson, list, setList };
  });
  function watch(read: () => unknown) {
    const values: boolean[] = [];
    createRoot(dispose => {
      disposers.push(dispose);
      createRenderEffect(
        () => isPending(read),
        value => {
          values.push(value);
        }
      );
    });
    return values;
  }
  return { ...stores, watch, dispose: () => disposers.reverse().forEach(dispose => dispose()) };
}

for (const derived of [false, true]) {
  describe(`${derived ? "derived" : "plain"} store wrapper scope`, () => {
    it("caches a distinct nested wrapper and follows upstream writes", () => {
      const f = fixture(derived);
      const names: string[] = [];
      let dispose!: () => void;
      try {
        const row = f.list.person;
        expect(row).not.toBe(f.person);
        expect(f.list.person).toBe(row);
        createRoot(d => {
          dispose = d;
          createRenderEffect(
            () => row.name,
            value => {
              names.push(value);
            }
          );
        });
        flush();
        expect(names).toEqual(["Ada"]);
        f.setPerson(person => {
          person.name = "Grace";
        });
        flush();
        expect(names).toEqual(["Ada", "Grace"]);
        expect(f.list.person).toBe(row);
        expect(f.person.name).toBe("Grace");
      } finally {
        dispose?.();
        f.dispose();
      }
    });

    it("isolates nested draft writes from the upstream store", () => {
      const f = fixture(derived);
      try {
        f.setList(list => {
          list.person.name = "Grace";
        });
        flush();
        expect(f.list.person.name).toBe("Grace");
        expect(f.person.name).toBe("Ada");
      } finally {
        f.dispose();
      }
    });

    it("replaces its nested person without changing the upstream store", () => {
      const f = fixture(derived);
      try {
        f.setList(list => {
          list.person = { name: "Grace", detail: { city: "New York" } };
        });
        flush();
        expect(f.list.person.name).toBe("Grace");
        expect(f.list.person.detail.city).toBe("New York");
        expect(f.person.name).toBe("Ada");
        expect(f.person.detail.city).toBe("London");
      } finally {
        f.dispose();
      }
    });

    it("marks nested, captured, and late readers without marking the upstream store", async () => {
      const f = fixture(derived);
      const hold = gate();
      const row = f.list.person;
      const nested = f.watch(() => f.list.person.name);
      const captured = f.watch(() => row.name);
      const original = f.watch(() => f.person.name);
      flush();
      expect([nested.at(-1), captured.at(-1), original.at(-1)]).toEqual([false, false, false]);
      const done = action(function* () {
        affects(f.list);
        yield hold.promise;
      })();
      try {
        flush();
        expect([nested.at(-1), captured.at(-1), original.at(-1)]).toEqual([true, true, false]);
        // The city leaf and its reader are first materialized during the mark.
        const late = f.watch(() => f.list.person.detail.city);
        const lateOriginal = f.watch(() => f.person.detail.city);
        flush();
        expect([late.at(-1), lateOriginal.at(-1)]).toEqual([true, false]);
        hold.resolve();
        await done;
        flush();
        expect([
          nested.at(-1),
          captured.at(-1),
          late.at(-1),
          original.at(-1),
          lateOriginal.at(-1)
        ]).toEqual([false, false, false, false, false]);
      } finally {
        hold.resolve();
        await done;
        flush();
        f.dispose();
      }
    });

    it("marks a captured second-level wrapper without marking its upstream source", async () => {
      const f = fixture(derived);
      const hold = gate();
      const detail = f.list.person.detail;
      const captured = f.watch(() => detail.city);
      const upstream = f.watch(() => f.person.detail.city);
      flush();
      expect([captured.at(-1), upstream.at(-1)]).toEqual([false, false]);
      const done = action(function* () {
        affects(f.list);
        yield hold.promise;
      })();
      try {
        flush();
        expect.soft([captured.at(-1), upstream.at(-1)]).toEqual([true, false]);
        expect.soft(isPending(() => detail.city)).toBe(true);
        const late = f.watch(() => detail.city);
        flush();
        expect.soft(late.at(-1)).toBe(true);
        hold.resolve();
        await done;
        flush();
        expect([captured.at(-1), late.at(-1), upstream.at(-1)]).toEqual([false, false, false]);
      } finally {
        hold.resolve();
        await done;
        flush();
        f.dispose();
      }
    });

    for (const releaseFirst of ["list", "person"] as const) {
      it(`keeps overlapping list/source marks independent when ${releaseFirst} releases first`, async () => {
        const f = fixture(derived);
        const listHold = gate();
        const personHold = gate();
        const row = f.list.person;
        const downstream = f.watch(() => row.name);
        const upstream = f.watch(() => f.person.name);
        flush();
        const listDone = action(function* () {
          affects(f.list);
          yield listHold.promise;
        })();
        flush();
        const personDone = action(function* () {
          affects(f.person);
          yield personHold.promise;
        })();
        try {
          flush();
          expect([downstream.at(-1), upstream.at(-1)]).toEqual([true, true]);
          if (releaseFirst === "list") {
            listHold.resolve();
            await listDone;
          } else {
            personHold.resolve();
            await personDone;
          }
          flush();
          expect([downstream.at(-1), upstream.at(-1)]).toEqual([true, releaseFirst === "list"]);
          listHold.resolve();
          personHold.resolve();
          await Promise.all([listDone, personDone]);
          flush();
          expect([downstream.at(-1), upstream.at(-1)]).toEqual([false, false]);
        } finally {
          listHold.resolve();
          personHold.resolve();
          await Promise.all([listDone, personDone]);
          flush();
          f.dispose();
        }
      });
    }
  });
}

it("a plain wrapper scopes marks through another nested object", async () => {
  let dispose!: () => void;
  const hold = gate();
  const pending: boolean[][] = [[], []];
  const { list, person } = createRoot(d => {
    dispose = d;
    const [person] = createStore({ name: "Ada" });
    const [list] = createStore({ group: { person } });
    const row = list.group.person;
    createRenderEffect(
      () => isPending(() => row.name),
      value => {
        pending[0].push(value);
      }
    );
    createRenderEffect(
      () => isPending(() => person.name),
      value => {
        pending[1].push(value);
      }
    );
    return { list, person };
  });
  flush();
  expect(pending.map(values => values.at(-1))).toEqual([false, false]);
  const done = action(function* () {
    affects(list);
    yield hold.promise;
  })();
  try {
    flush();
    expect(pending.map(values => values.at(-1))).toEqual([true, false]);
    expect(person.name).toBe("Ada");
    hold.resolve();
    await done;
    flush();
    expect(pending.map(values => values.at(-1))).toEqual([false, false]);
  } finally {
    hold.resolve();
    await done;
    flush();
    dispose();
  }
});

it("wraps the same raw object separately in two plain stores and isolates their writes", () => {
  const raw = { person: { name: "Ada" } };
  const [first, setFirst] = createStore(raw);
  const [second, setSecond] = createStore(raw);
  expect(first).not.toBe(second);
  expect(first.person).not.toBe(second.person);
  expect(first.person).toBe(first.person);
  expect(second.person).toBe(second.person);
  setFirst(draft => {
    draft.person.name = "Grace";
  });
  flush();
  expect(first.person.name).toBe("Grace");
  expect(second.person.name).toBe("Ada");
  setSecond(draft => {
    draft.person.name = "Katherine";
  });
  flush();
  expect(first.person.name).toBe("Grace");
  expect(second.person.name).toBe("Katherine");
  expect(raw.person.name).toBe("Ada");
});

it("keeps repeated and cyclic raw objects in one plain store on the same wrapper", () => {
  type Row = { name: string; self: Row };
  const raw = { name: "Ada" } as Row;
  raw.self = raw;
  const [store, setStore] = createStore({ first: raw, second: raw });
  const row = store.first;
  expect(row).not.toBe(raw);
  expect(store.second).toBe(row);
  expect(row.self).toBe(row);
  expect(store.second.self.self).toBe(row);
  setStore(draft => {
    draft.second.self.name = "Grace";
  });
  flush();
  expect(store.first).toBe(row);
  expect(store.second).toBe(row);
  expect(row.self).toBe(row);
  expect(row.name).toBe("Grace");
  expect(raw.name).toBe("Ada");
});

for (const derived of [false, true]) {
  for (const markList of [true, false]) {
    it(`${derived ? "derived" : "plain"} list distinguishes separate source stores sharing raw when marking ${markList ? "the list" : "one child"}`, async () => {
      const hold = gate();
      const pending: boolean[][] = [[], [], [], []];
      let dispose!: () => void;
      const { list, firstRow } = createRoot(d => {
        dispose = d;
        const raw = { name: "Ada" };
        const [first] = createStore(raw);
        const [second] = createStore(raw);
        const [list] = derived
          ? createStore(() => ({ first, second }))
          : createStore({ first, second });
        const firstRow = list.first;
        const secondRow = list.second;
        expect(first).not.toBe(second);
        expect(firstRow).not.toBe(first);
        expect(secondRow).not.toBe(second);
        expect(firstRow).not.toBe(secondRow);
        const readers = [
          () => firstRow.name,
          () => secondRow.name,
          () => first.name,
          () => second.name
        ];
        readers.forEach((read, index) => {
          createRenderEffect(
            () => isPending(read),
            value => {
              pending[index].push(value);
            }
          );
        });
        return { list, firstRow };
      });
      flush();
      expect(pending.map(values => values.at(-1))).toEqual([false, false, false, false]);
      const done = action(function* () {
        affects(markList ? list : firstRow);
        yield hold.promise;
      })();
      try {
        flush();
        expect(pending.map(values => values.at(-1))).toEqual([true, markList, false, false]);
        hold.resolve();
        await done;
        flush();
        expect(pending.map(values => values.at(-1))).toEqual([false, false, false, false]);
      } finally {
        hold.resolve();
        await done;
        flush();
        dispose();
      }
    });
  }
}
