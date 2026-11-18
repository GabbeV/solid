/**
 * `mapArray` over a shallow store diffs the store's backing (types.ts
 * `shallowView`) for raw rows and serves explicit store proxies directly.
 * These cases compare mapArray with direct indexing across writes, structure
 * changes, refetches, held writes and a shallow projection's derive.
 */
import { afterEach, describe, expect, it } from "vitest";
import {
  action,
  createMemo,
  createProjection,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  flush,
  mapArray,
  reconcile
} from "../../src/index.js";

afterEach(() => flush());

type Row = { id: number; label: string };
const rows = (n: number, tag = "") =>
  Array.from({ length: n }, (_, i): Row => ({ id: i, label: `r${i}${tag}` }));

function mount(list: () => Row[]) {
  let mounts = 0;
  let screen: string[] = [];
  const { dispose, mapped } = createRoot(dispose => {
    const mapped = createMemo(
      mapArray(
        list,
        (row: () => Row) => {
          mounts++;
          return row;
        },
        { keyed: (r: Row) => r.id }
      )
    );
    createRenderEffect(
      () => mapped().map(read => read().label),
      v => {
        screen = v;
      }
    );
    return { dispose, mapped };
  });
  flush();
  return { screen: () => screen, mounts: () => mounts, row: (i: number) => mapped()[i](), dispose };
}

describe("mapArray over a shallow store", () => {
  it("a derived list's mapped and indexed rows both edit the derived view", () => {
    const [person] = createStore({ id: 1, label: "Alice" });
    const [list, edit] = createStore(() => [person], [] as Row[], { shallow: true });
    const view = mount(() => list);
    try {
      expect(view.row(0)).toBe(list[0]);
      expect(view.row(0)).not.toBe(person);
      edit(rows => {
        rows[0].label = "Bob";
      });
      flush();
      expect([list[0].label, ...view.screen(), person.label]).toEqual(["Bob", "Bob", "Alice"]);
    } finally {
      view.dispose();
    }
  });

  it("reads the same store proxy as direct indexing before and after an edit", () => {
    const [person, rename] = createStore({ id: 1, label: "Alice" });
    const [list, edit] = createStore([person], { shallow: true });
    const view = mount(() => list);
    try {
      expect(list[0]).toBe(person);
      expect(view.row(0)).toBe(person);
      expect(view.screen()).toEqual(["Alice"]);
      rename(draft => {
        draft.label = "Bea";
      });
      flush();
      expect(list[0]).toBe(person);
      expect(view.screen()).toEqual(["Bea"]);
      edit(draft => {
        draft[0].label = "Bob";
      });
      flush();
      expect(list[0]).toBe(person);
      expect(view.row(0)).toBe(person);
      expect(view.screen()).toEqual(["Bob"]);
      expect(person.label).toBe("Bob");
      rename(draft => {
        draft.label = "Carla";
      });
      flush();
      expect(list[0]).toBe(person);
      expect(view.screen()).toEqual(["Carla"]);
      expect(view.mounts()).toBe(1);
    } finally {
      view.dispose();
    }
  });

  it.each(["set", "defineProperty", "replace", "reconcile"] as const)(
    "a raw list shares an explicit store row inserted by %s",
    method => {
      const [person] = createStore({ id: 2, label: "Alice" });
      const [list, edit] = createStore(rows(1), { shallow: true });
      const view = mount(() => list);
      try {
        edit(d => {
          d[0] = { id: 1, label: "raw" };
        });
        flush();
        expect(view.screen()).toEqual(["raw"]);

        if (method === "replace") edit(() => [person]);
        else if (method === "reconcile") edit(reconcile([person], null));
        else
          edit(d => {
            if (method === "set") d[0] = person;
            else
              Object.defineProperty(d, 0, {
                value: person,
                writable: true,
                configurable: true,
                enumerable: true
              });
          });
        flush();
        expect(view.screen()).toEqual(["Alice"]);
        expect(list[0]).toBe(person);
        expect(view.row(0)).toBe(person);
        edit(d => {
          d[0].label = "Bob";
        });
        flush();
        expect([list[0].label, ...view.screen(), person.label]).toEqual(["Bob", "Bob", "Bob"]);
      } finally {
        view.dispose();
      }
    }
  );

  it("preserves a store row's identity when it moves and the list shrinks", () => {
    const [person] = createStore({ id: 2, label: "Alice" });
    const [list, edit] = createStore([rows(1)[0], person, { id: 3, label: "last" }], {
      shallow: true
    });
    const view = mount(() => list);
    try {
      edit(d => {
        d[0] = { id: 1, label: "raw" };
      });
      flush();
      edit(d => {
        d.shift();
        d.pop();
      });
      flush();
      expect(view.screen()).toEqual(["Alice"]);
      expect(list[0]).toBe(person);
      expect(view.row(0)).toBe(person);
      edit(d => {
        d[0].label = "Bob";
      });
      flush();
      expect(view.screen()).toEqual(["Bob"]);
      expect(person.label).toBe("Bob");
    } finally {
      view.dispose();
    }
  });

  it("follows slot writes, structure changes and refetches by key", () => {
    const [s, set] = createStore(rows(3), { shallow: true });
    const view = mount(() => s);
    expect(view.screen()).toEqual(["r0", "r1", "r2"]);

    set(d => {
      d[1] = { ...d[1], label: "edited" };
    });
    flush();
    expect(view.screen()).toEqual(["r0", "edited", "r2"]);
    expect(view.mounts()).toBe(3);

    set(d => {
      d.push({ id: 3, label: "r3" });
    });
    flush();
    expect(view.screen()).toEqual(["r0", "edited", "r2", "r3"]);
    expect(view.mounts()).toBe(4);

    set(d => d.filter(r => r.id !== 0));
    flush();
    expect(view.screen()).toEqual(["edited", "r2", "r3"]);

    set(reconcile(rows(4, "!").slice(1), null));
    flush();
    expect(view.screen()).toEqual(["r1!", "r2!", "r3!"]);
    expect(view.mounts()).toBe(4);
    view.dispose();
  });

  it("shows the committed rows while an action holds the write", async () => {
    const [s, set] = createStore(rows(2), { shallow: true });
    const view = mount(() => s);
    let finish!: () => void;
    const run = action(function* () {
      set(d => {
        d[0] = { id: 0, label: "held" };
        d.push({ id: 2, label: "new" });
      });
      yield new Promise<void>(r => (finish = r));
    });
    const done = run();
    flush();
    expect(view.screen()).toEqual(["r0", "r1"]);
    finish();
    await done;
    flush();
    expect(view.screen()).toEqual(["held", "r1", "new"]);
    view.dispose();
  });

  it("publishes a held foreign row with the list frame", async () => {
    const [person] = createStore({ id: 1, label: "Alice" });
    const [list, edit] = createStore(rows(1), { shallow: true });
    const view = mount(() => list);
    const finish = Promise.withResolvers<void>();
    const done = action(function* () {
      edit(draft => {
        draft[0] = person;
      });
      yield finish.promise;
    })();
    try {
      flush();
      expect(view.screen()).toEqual(["r0"]);
      expect(list[0].label).toBe("r0");
      finish.resolve();
      await done;
      flush();
      expect(view.screen()).toEqual(["Alice"]);
      expect(list[0]).toBe(person);
      expect(view.row(0)).toBe(person);
      edit(draft => {
        draft[0].label = "Bob";
      });
      flush();
      expect(list[0]).toBe(person);
      expect(view.screen()).toEqual(["Bob"]);
      expect(person.label).toBe("Bob");
    } finally {
      finish.resolve();
      await done;
      view.dispose();
    }
  });

  it("reads a shallow projection's derived rows", () => {
    const [n, setN] = createSignal(2);
    let view!: ReturnType<typeof mount>;
    const dispose = createRoot(d => {
      const p = createProjection<Row[]>(
        draft => {
          draft.length = 0;
          for (const r of rows(n(), `@${n()}`)) draft.push(r);
        },
        [],
        { shallow: true }
      );
      view = mount(() => p);
      return d;
    });
    expect(view.screen()).toEqual(["r0@2", "r1@2"]);
    setN(3);
    flush();
    expect(view.screen()).toEqual(["r0@3", "r1@3", "r2@3"]);
    view.dispose();
    dispose();
  });
});
