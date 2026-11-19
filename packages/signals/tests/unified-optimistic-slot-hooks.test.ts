import { expect, it } from "vitest";
import { action, createMemo, createRenderEffect, createRoot, flush } from "../src/index.js";
import { read, signal } from "../src/core/core.js";
import {
  createOptimisticSlot,
  entangleOptimisticSlotRead,
  withOptimisticSlotBatch
} from "../src/layers/optimistic.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("a setter read joins the selected guess's action owner", async () => {
  const endA = Promise.withResolvers<void>();
  const endB = Promise.withResolvers<void>();
  const selected: number[] = [];
  const a = createOptimisticSlot(signal(0), undefined, () => selected.push(a.writerValue()));
  const b = createOptimisticSlot(signal(0));
  let queuedOwner: ReturnType<typeof a.activeOwner>;
  const runningA = action(function* () {
    a.propose(1);
    queuedOwner = a.activeOwner();
    yield endA.promise;
  })();
  try {
    expect(queuedOwner).not.toBeNull();
    expect(a.isIdle()).toBe(false);
    expect(selected).toEqual([]);
    flush();
    await turn();
    expect(selected).toEqual([1]);
    expect(a.activeOwner()).toBe(queuedOwner);
    const runningB = action(function* () {
      entangleOptimisticSlotRead(a);
      withOptimisticSlotBatch(() => b.propose(2));
      yield endB.promise;
    })();
    try {
      expect(b.activeOwner()).toBe(a.activeOwner());
    } finally {
      endB.resolve();
      await runningB;
    }
  } finally {
    endA.resolve();
    await runningA;
    flush();
  }
  expect(a.activeOwner()).toBeNull();
  expect(b.activeOwner()).toBeNull();
  expect(a.isIdle()).toBe(true);
  expect(b.isIdle()).toBe(true);
  expect(selected).toEqual([1]);
});

it("a nested setter's changed slots join the outer output group", async () => {
  const end = Promise.withResolvers<void>();
  const answer = Promise.withResolvers<number>();
  const a = createOptimisticSlot(signal(0));
  const b = createOptimisticSlot(signal(0));
  const c = createOptimisticSlot(signal(0));
  const shown = { a: -1, b: -1, c: -1, pending: -1 };
  const dispose = createRoot(dispose => {
    const pending = createMemo(() => (read(b.output) ? answer.promise : 0));
    createRenderEffect(
      () => read(a.output),
      value => {
        shown.a = value;
      }
    );
    createRenderEffect(
      () => read(b.output),
      value => {
        shown.b = value;
      }
    );
    createRenderEffect(
      () => read(c.output),
      value => {
        shown.c = value;
      }
    );
    createRenderEffect(pending, value => {
      shown.pending = value;
    });
    return dispose;
  });
  let running: Promise<void> | undefined;
  try {
    flush();
    running = action(function* () {
      withOptimisticSlotBatch(() => {
        a.propose(1);
        withOptimisticSlotBatch(() => b.propose(1));
        c.propose(1);
      });
      yield end.promise;
    })();
    flush();
    await turn();
    expect(shown).toEqual({ a: 0, b: 0, c: 0, pending: 0 });
    answer.resolve(1);
    await turn();
    flush();
    expect(shown).toEqual({ a: 1, b: 1, c: 1, pending: 1 });
  } finally {
    end.resolve();
    answer.resolve(1);
    if (running) await running;
    dispose();
    flush();
  }
});
