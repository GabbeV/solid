import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  deep,
  flush,
  snapshot
} from "../src/index.js";
import { $TARGET } from "../src/store/types.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("inactive reads and unchanged setters leave all companion inputs unallocated", () => {
  const [store, set] = createOptimisticStore({ n: 0, spare: 1 });
  const target = (store as any)[$TARGET];
  expect(store.n).toBe(0);
  expect("n" in store).toBe(true);
  expect(Object.keys(store)).toEqual(["n", "spare"]);
  expect(Object.getOwnPropertyDescriptor(store, "n")?.value).toBe(0);
  expect(snapshot(store)).toEqual({ n: 0, spare: 1 });
  set(() => {});
  flush();
  expect(target.nc).toBe(0);
  expect(target.k).toBeNull();
  expect(Reflect.ownKeys(target.h ?? {})).toEqual([]);
});

it("reclaims value, presence and container companions across repeated creator/reader disposal and later writes", async () => {
  const [store, set, destroyCreator] = createRoot(dispose => {
    const [store, set] = createOptimisticStore<Record<string, number>>({ n: 0 });
    return [store, set, dispose] as const;
  });
  destroyCreator();
  const target = (store as any)[$TARGET];
  for (let cycle = 0; cycle < 20; cycle++) {
    const end = Promise.withResolvers<void>();
    const key = `extra${cycle}`;
    let shown: unknown;
    let dispose = createRoot(dispose => {
      createRenderEffect(
        () => [store.n, key in store, Object.keys(store)],
        value => {
          shown = value;
        }
      );
      return dispose;
    });
    flush();
    const running = action(function* () {
      set(draft => {
        draft.n = cycle + 1;
        draft[key] = 7;
      });
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual([cycle + 1, true, ["n", key]]);
    const input = target.n.n;
    dispose();
    flush();
    // Neither the creator nor any reader remains, but the action owns guesses.
    expect([store.n, store[key], key in store, Object.keys(store)]).toEqual([
      cycle + 1,
      7,
      true,
      ["n", key]
    ]);
    dispose = createRoot(dispose => {
      createRenderEffect(
        () => store.n,
        value => {
          shown = value;
        }
      );
      return dispose;
    });
    flush();
    expect(shown).toBe(cycle + 1);
    dispose();
    end.resolve();
    await running;
    await turn();
    flush();
    expect([store.n, store[key], key in store, Object.keys(store)]).toEqual([
      0,
      undefined,
      false,
      ["n"]
    ]);
    expect(target.nc).toBe(0);
    expect(target.k).toBeNull();
    expect(Reflect.ownKeys(target.h ?? {})).toEqual([]);
    expect(input._subs).toBeNull();
  }
});

it("setter before any reader preserves a live unobserved guess and a late deep reader", async () => {
  const [store, set] = createOptimisticStore({ n: 0, unchanged: 1 });
  const end = Promise.withResolvers<void>();
  const running = action(function* () {
    set(draft => {
      draft.n = 5;
    });
    yield end.promise;
  })();
  flush();
  expect(store.n).toBe(5);
  let shown: unknown;
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => deep(store),
      value => {
        shown = value;
      }
    );
    return dispose;
  });
  flush();
  expect(shown).toEqual({ n: 5, unchanged: 1 });
  end.resolve();
  await running;
  await turn();
  expect(shown).toEqual({ n: 0, unchanged: 1 });
  dispose();
  flush();
  expect((store as any)[$TARGET].nc).toBe(0);
});

it("a deep-only reader mounted before any guesses observes repeated value changes and new keys", async () => {
  const [store, set] = createOptimisticStore<Record<string, number>>({ n: 0 });
  const shown: Record<string, number>[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => deep(store),
      value => {
        shown.push(value);
      }
    );
    return dispose;
  });
  flush();
  expect(shown).toEqual([{ n: 0 }]);
  for (let cycle = 0; cycle < 10; cycle++) {
    const end = Promise.withResolvers<void>();
    const key = `new${cycle}`;
    const running = action(function* () {
      set(draft => {
        draft.n = cycle + 1;
        draft[key] = cycle + 10;
      });
      yield end.promise;
    })();
    flush();
    expect(shown.at(-1)).toEqual({ n: cycle + 1, [key]: cycle + 10 });
    end.resolve();
    await running;
    await turn();
    flush();
    expect(shown.at(-1)).toEqual({ n: 0 });
  }
  dispose();
  flush();
  const target = (store as any)[$TARGET];
  expect(target.nc).toBe(0);
  expect(target.k).toBeNull();
  expect(Reflect.ownKeys(target.h ?? {})).toEqual([]);
});

it("keeps a held correction until its dependent answer lands, then releases after reader disposal", async () => {
  const [store, set] = createOptimisticStore({ n: 0 });
  const end = Promise.withResolvers<void>(),
    answer = Promise.withResolvers<number>();
  let correcting = false,
    shown = -1;
  const dispose = createRoot(dispose => {
    const derived = createMemo(() => (correcting && store.n === 0 ? answer.promise : store.n));
    createRenderEffect(derived, value => {
      shown = value;
    });
    return dispose;
  });
  const running = action(function* () {
    set(draft => {
      draft.n = 5;
    });
    yield end.promise;
  })();
  flush();
  expect(shown).toBe(5);
  correcting = true;
  end.resolve();
  await running;
  await turn();
  expect(shown).toBe(5);
  let late = -1;
  const disposeLate = createRoot(dispose => {
    createRenderEffect(
      () => store.n,
      value => {
        late = value;
      }
    );
    return dispose;
  });
  flush();
  expect(late).toBe(5);
  answer.resolve(0);
  await turn();
  expect([shown, late]).toEqual([0, 0]);
  disposeLate();
  dispose();
  flush();
  expect((store as any)[$TARGET].n?.n).toBeUndefined();
});
