import { afterEach, expect, it } from "vitest";
import {
  action,
  createOptimistic,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  flush,
  NotReadyError
} from "../src/index.js";
const cleanup: (() => void)[] = [];
const gate = <T>() => Promise.withResolvers<T>();
const turn = async () => {
  await new Promise(r => setTimeout(r, 0));
  flush();
};
afterEach(async () => {
  for (const f of cleanup.splice(0)) f();
  await turn();
});
for (const order of ["input-first", "action-first"] as const) {
  it(`scalar first guess: ${order}`, async () => {
    const input = gate<number>(),
      finish = gate<void>();
    const shown: number[] = [];
    const [value, set] = createOptimistic(() => input.promise);
    const dispose = createRoot(d => {
      createRenderEffect(value, v => void shown.push(v));
      return d;
    });
    cleanup.push(() => {
      input.resolve(7);
      finish.resolve();
      dispose();
    });
    flush();
    const done = action(function* () {
      set(1);
      yield finish.promise;
    })();
    flush();
    expect(shown).toEqual([1]);
    if (order === "input-first") {
      input.resolve(7);
      await turn();
      expect(shown).toEqual([1]);
      finish.resolve();
      await done;
    } else {
      finish.resolve();
      await done;
      await turn();
      expect(shown).toEqual([1]);
      input.resolve(7);
    }
    await turn();
    expect(shown).toEqual([1, 7]);
    dispose();
    flush();
  });
  it(`store first guess: ${order}`, async () => {
    const input = gate<{ a: number }>(),
      finish = gate<void>();
    const shown: number[] = [];
    const [value, set] = createOptimisticStore(() => input.promise, { a: 0 });
    const dispose = createRoot(d => {
      createRenderEffect(
        () => value.a,
        v => void shown.push(v)
      );
      return d;
    });
    cleanup.push(() => {
      input.resolve({ a: 7 });
      finish.resolve();
      dispose();
    });
    flush();
    const done = action(function* () {
      set(d => {
        d.a = 1;
      });
      yield finish.promise;
    })();
    flush();
    expect(shown).toEqual([1]);
    if (order === "input-first") {
      input.resolve({ a: 7 });
      await turn();
      expect(shown).toEqual([1]);
      finish.resolve();
      await done;
    } else {
      finish.resolve();
      await done;
      await turn();
      expect(shown).toEqual([1]);
      input.resolve({ a: 7 });
    }
    await turn();
    expect(shown).toEqual([1, 7]);
    dispose();
    flush();
  });
}
it("first-key guess does not expose an untouched seed key", async () => {
  const input = gate<{ a: number; b: number }>(),
    finish = gate<void>();
  const a: number[] = [];
  const [value, set] = createOptimisticStore(() => input.promise, { a: 0, b: 0 });
  const dispose = createRoot(d => {
    createRenderEffect(
      () => value.a,
      v => void a.push(v)
    );
    return d;
  });
  cleanup.push(() => {
    input.resolve({ a: 7, b: 8 });
    finish.resolve();
    dispose();
  });
  flush();
  const done = action(function* () {
    set(d => {
      d.a = 1;
    });
    yield finish.promise;
  })();
  flush();
  expect(a).toEqual([1]);
  expect(() => value.b).toThrow(NotReadyError);
  input.resolve({ a: 7, b: 8 });
  finish.resolve();
  await done;
  await turn();
  dispose();
  flush();
});
for (const order of ["input-first", "action-first"] as const)
  it(`mapped guesses wait for the first list length: ${order}`, async () => {
    type Row = { id: number; title: string };
    const input = gate<Row[]>(),
      finish = gate<void>();
    const shown: string[] = [];
    const [value, set] = createOptimisticStore(() => input.promise, [] as Row[]);
    const dispose = createRoot(d => {
      createRenderEffect(
        () => value.map(r => r.title).join(","),
        v => void shown.push(v)
      );
      return d;
    });
    cleanup.push(() => {
      input.resolve([
        { id: 1, title: "milk" },
        { id: 2, title: "eggs" }
      ]);
      finish.resolve();
      dispose();
    });
    flush();
    const done = action(function* () {
      set(d => {
        d.push({ id: 3, title: "jam" });
      });
      yield finish.promise;
    })();
    flush();
    expect(shown).toEqual([]);
    if (order === "input-first") {
      input.resolve([
        { id: 1, title: "milk" },
        { id: 2, title: "eggs" }
      ]);
      await turn();
      finish.resolve();
      await done;
    } else {
      finish.resolve();
      await done;
      await turn();
      expect(shown).toEqual([]);
      input.resolve([
        { id: 1, title: "milk" },
        { id: 2, title: "eggs" }
      ]);
    }
    await turn();
    expect(shown.at(-1)).toBe("milk,eggs");
    dispose();
    flush();
  });
