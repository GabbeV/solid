import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  deep,
  flush
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("deep observes disjoint guesses without joining their action lifetimes or ordinary writes", async () => {
  const endA = Promise.withResolvers<void>();
  const endB = Promise.withResolvers<void>();
  const [store, guess] = createOptimisticStore({ a: 0, b: 0 });
  const [savedA, setSavedA] = createSignal(false);
  const [savedB, setSavedB] = createSignal(false);
  const shown = { a: -1, b: -1, savedA: false, savedB: false };
  const snapshots: { a: number; b: number }[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.a,
      value => {
        shown.a = value;
      }
    );
    createRenderEffect(
      () => store.b,
      value => {
        shown.b = value;
      }
    );
    createRenderEffect(savedA, value => {
      shown.savedA = value;
    });
    createRenderEffect(savedB, value => {
      shown.savedB = value;
    });
    createRenderEffect(
      () => deep(store),
      value => {
        snapshots.push(value);
      }
    );
    return dispose;
  });
  let a: Promise<unknown> | undefined;
  let b: Promise<unknown> | undefined;
  try {
    flush();
    a = action(function* () {
      setSavedA(true);
      guess(draft => {
        draft.a = 1;
      });
      yield endA.promise;
    })();
    flush();
    b = action(function* () {
      setSavedB(true);
      guess(draft => {
        draft.b = 2;
      });
      yield endB.promise;
    })();
    flush();
    expect(shown).toEqual({ a: 1, b: 2, savedA: false, savedB: false });
    expect(snapshots.at(-1)).toEqual({ a: 1, b: 2 });

    endA.resolve();
    await a;
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 2, savedA: true, savedB: false });
    expect(snapshots.at(-1)).toEqual({ a: 0, b: 2 });

    endB.resolve();
    await b;
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, savedA: true, savedB: true });
    expect(snapshots).toEqual([
      { a: 0, b: 0 },
      { a: 1, b: 0 },
      { a: 1, b: 2 },
      { a: 0, b: 2 },
      { a: 0, b: 0 }
    ]);
  } finally {
    endA.resolve();
    endB.resolve();
    await Promise.all([a, b]);
    dispose();
    flush();
  }
});

it("deep snapshots stay coherent with held setter outputs during unrelated reruns and late mounts", async () => {
  const end = Promise.withResolvers<void>();
  const answer = Promise.withResolvers<number>();
  const [store, guess] = createOptimisticStore({ a: 0, b: 0 });
  const [tick, setTick] = createSignal(0);
  const snapshots: { a: number; b: number }[] = [];
  const late: { a: number; b: number }[] = [];
  const shown = { a: -1, b: -1, derived: -1 };
  const dispose = createRoot(dispose => {
    const derived = createMemo(() => (store.a === 2 ? answer.promise : store.a * 10));
    createRenderEffect(
      () => store.a,
      value => {
        shown.a = value;
      }
    );
    createRenderEffect(
      () => store.b,
      value => {
        shown.b = value;
      }
    );
    createRenderEffect(derived, value => {
      shown.derived = value;
    });
    createRenderEffect(
      () => {
        tick();
        return deep(store);
      },
      value => {
        snapshots.push(value);
      }
    );
    return dispose;
  });
  let lateDispose: (() => void) | undefined;
  let running: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      guess(draft => {
        draft.a = 1;
        draft.b = 1;
      });
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual({ a: 1, b: 1, derived: 10 });
    guess(draft => {
      draft.a = 2;
      draft.b = 2;
    });
    flush();
    setTick(1);
    flush();
    lateDispose = createRoot(dispose => {
      createRenderEffect(
        () => deep(store),
        value => {
          late.push(value);
        }
      );
      return dispose;
    });
    flush();
    expect(shown).toEqual({ a: 1, b: 1, derived: 10 });
    expect(snapshots.at(-1)).toEqual({ a: 1, b: 1 });
    expect(late.every(value => value.a === 1 && value.b === 1)).toBe(true);

    answer.resolve(20);
    await turn();
    flush();
    expect(shown).toEqual({ a: 2, b: 2, derived: 20 });
    expect(snapshots.at(-1)).toEqual({ a: 2, b: 2 });
    expect(late.at(-1)).toEqual({ a: 2, b: 2 });
    end.resolve();
    await running;
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, derived: 0 });
    expect(snapshots.at(-1)).toEqual({ a: 0, b: 0 });
  } finally {
    end.resolve();
    answer.resolve(20);
    await running;
    lateDispose?.();
    dispose();
    flush();
  }
});
