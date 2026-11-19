import { expect, it } from "vitest";
import {
  action,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
import { computed, read } from "../src/core/core.js";
import { insertSubs, txOf } from "../src/core/scheduler.js";
import { createOptimisticSlot } from "../src/layers/optimistic.js";
const turn = async () => {
  await new Promise(r => setTimeout(r, 0));
  flush();
};

for (const existing of [false, true])
  it(`discovery preserves a selected output beside its lower input (existing=${existing})`, async () => {
    const answer = Promise.withResolvers<number>(),
      finish = Promise.withResolvers<void>();
    const [round, setRound] = createSignal(0);
    const producer = computed(() => (round() ? answer.promise : 2));
    let slot: ReturnType<typeof createOptimisticSlot<number>> | undefined;
    const shown: number[] = [];
    let dispose = () => {};
    if (existing)
      dispose = createRoot(dispose => {
        createRenderEffect(
          () => (slot ? read(slot.output) : read(producer)),
          n => void shown.push(n)
        );
        return dispose;
      });
    flush();
    setRound(1);
    flush();
    const running = action(function* () {
      slot = createOptimisticSlot(
        computed(() => read(producer)),
        undefined,
        () => insertSubs(producer)
      );
      slot.propose(1);
      yield finish.promise;
    })();
    if (!existing)
      dispose = createRoot(dispose => {
        createRenderEffect(
          () => read(slot!.output),
          n => void shown.push(n)
        );
        return dispose;
      });
    try {
      flush();
      expect(shown.at(-1)).toBe(1);
      answer.resolve(3);
      await turn();
      expect(shown.at(-1)).toBe(1);
      finish.resolve();
      await running;
      await turn();
      expect(shown.at(-1)).toBe(3);
    } finally {
      answer.resolve(3);
      finish.resolve();
      await running;
      dispose();
      await turn();
    }
  });

for (const depth of [1, 2])
  it(`a held ordinary memo adopts its changed optimistic dependency at depth ${depth}`, async () => {
    const answer = Promise.withResolvers<number>(),
      finish = Promise.withResolvers<void>();
    const first = createOptimistic(1);
    const second = depth === 2 ? createOptimistic(() => first[0]() + 1) : first;
    const seen: number[] = [];
    const ordinary = computed(() => {
      seen.push(second[0]());
      return answer.promise;
    });
    const dispose = createRoot(dispose => {
      createRenderEffect(
        () => read(ordinary),
        () => {}
      );
      return dispose;
    });
    flush();
    const running = action(function* () {
      first[1](9);
      if (depth === 2) second[1](20);
      yield finish.promise;
    })();
    try {
      flush();
      expect(seen.at(-1)).toBe(depth === 2 ? 20 : 9);
      expect(txOf(ordinary)._level).toBe(depth);
    } finally {
      answer.resolve(30);
      finish.resolve();
      await running;
      await turn();
      dispose();
      flush();
    }
  });
