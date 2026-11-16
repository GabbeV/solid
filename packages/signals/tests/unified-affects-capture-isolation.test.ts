import { it, expect } from "vitest";
import {
  action,
  affects,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  flush,
  isPending
} from "../src/index.js";

for (const derived of [false, true])
  it(`a mark alone allows tracked capture (derived=${derived})`, async () => {
    const end = Promise.withResolvers<void>();
    const app = createRoot(dispose => {
      const [person] = createStore({ id: 1, name: "Alice" });
      const [list] = derived
        ? createStore(() => ({ people: [person] }), { people: [] })
        : createStore({ people: [person] });
      return { person, list, dispose };
    });
    flush();
    const running = action(function* () {
      affects(app.list);
      yield end.promise;
    })();
    let reached = false;
    try {
      flush();
      const capture = createRoot(dispose => {
        const result = createMemo(() => {
          const row = app.list.people[0];
          reached = true;
          return isPending(() => row.name);
        });
        return { result, dispose };
      });
      try {
        expect(() => capture.result()).not.toThrow();
        expect(reached).toBe(true);
      } finally {
        capture.dispose();
      }
    } finally {
      end.resolve();
      await running;
      app.dispose();
      flush();
    }
  });

it("an actual unresolved derived store blocks a new tracked capture", async () => {
  const answer = Promise.withResolvers<{ people: { id: number; name: string }[] }>();
  let reached = false;
  const app = createRoot(dispose => {
    const [id, setId] = createSignal(0);
    const [list] = createStore(
      () => (id() === 0 ? { people: [{ id: 1, name: "Alice" }] } : answer.promise),
      { people: [] }
    );
    return { list, setId, dispose };
  });
  flush();
  app.setId(1);
  flush();
  const capture = createRoot(dispose => {
    const result = createMemo(() => {
      const row = app.list.people[0];
      reached = true;
      return isPending(() => row.name);
    });
    return { result, dispose };
  });
  try {
    expect(() => capture.result()).toThrow();
    expect(reached).toBe(false);
  } finally {
    capture.dispose();
    app.dispose();
    answer.resolve({ people: [{ id: 1, name: "Bob" }] });
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
});

for (const draft of [false, true])
  it(`rederivation does not mutate an incoming store (draft=${draft})`, () => {
    const app = createRoot(dispose => {
      const [person] = createStore({ id: 1, name: "Alice" });
      const [id, setId] = createSignal(0);
      const [list] = draft
        ? createStore(
            s => {
              if (id() === 0) s.people = [person];
              else s.people[0].name = "Bob";
            },
            { people: [] as { id: number; name: string }[] }
          )
        : createStore(() => ({ people: id() === 0 ? [person] : [{ id: 1, name: "Bob" }] }), {
            people: []
          });
      const frames: string[][] = [];
      createRenderEffect(
        () => [person.name, list.people[0].name],
        v => void frames.push(v)
      );
      return { person, list, setId, dispose, frames };
    });
    try {
      flush();
      expect(app.frames.at(-1)).toEqual(["Alice", "Alice"]);
      const row = app.list.people[0];
      expect(row).not.toBe(app.person);
      app.setId(1);
      flush();
      expect(app.person.name).toBe("Alice");
      expect(app.list.people[0].name).toBe("Bob");
      expect(app.frames.at(-1)).toEqual(["Alice", "Bob"]);
    } finally {
      app.dispose();
      flush();
    }
  });
