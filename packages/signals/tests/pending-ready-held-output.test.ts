import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";

// A ready answer equal to the displayed value clears pending at every layer.
// A differing unpublished answer stays pending in the shared model. Next
// also clears that case for optimistic derivations (solidjs/solid#4685).
for (const leftAnswer of [0, 10])
  for (const optimistic of [false, true]) {
    it(`pending of a ready output held by a sibling (optimistic=${optimistic}, answer=${leftAnswer})`, async () => {
      const leftDone = Promise.withResolvers<number>();
      const rightDone = Promise.withResolvers<number>();
      const actionDone = Promise.withResolvers<void>();
      const [a, setA] = optimistic ? createOptimistic(0) : createSignal(0);
      const [b, setB] = optimistic ? createOptimistic(0) : createSignal(0);
      const shown = { left: 0, total: 0, leftPending: false };
      const dispose = createRoot(dispose => {
        const left = createMemo(() => (a() === 0 ? 0 : leftDone.promise));
        const right = createMemo(() => (b() === 0 ? 0 : rightDone.promise));
        const total = createMemo(() => left() + right());
        createRenderEffect(left, value => {
          shown.left = value;
        });
        createRenderEffect(total, value => {
          shown.total = value;
        });
        createRenderEffect(
          () => isPending(left),
          value => {
            shown.leftPending = value;
          }
        );
        return dispose;
      });
      flush();
      const running = action(function* () {
        setA(1);
        setB(1);
        yield actionDone.promise;
      })();
      try {
        flush();
        expect({ ...shown }).toEqual({ left: 0, total: 0, leftPending: true });
        leftDone.resolve(leftAnswer);
        await new Promise(resolve => setTimeout(resolve, 0));
        expect({ ...shown }).toEqual({ left: 0, total: 0, leftPending: leftAnswer !== 0 });
        rightDone.resolve(20);
        await new Promise(resolve => setTimeout(resolve, 0));
        // The optimistic output can publish while the action is still open.
        // Its ordinary counterpart waits for that action's lifetime as well.
        expect({ ...shown }).toEqual({
          left: optimistic ? leftAnswer : 0,
          total: optimistic ? leftAnswer + 20 : 0,
          leftPending: !optimistic && leftAnswer !== 0
        });
      } finally {
        rightDone.resolve(20);
        leftDone.resolve(leftAnswer);
        actionDone.resolve();
        await running;
        await new Promise(resolve => setTimeout(resolve, 0));
        flush();
        dispose();
      }
      expect({ ...shown }).toEqual({
        left: optimistic ? 0 : leftAnswer,
        total: optimistic ? 0 : leftAnswer + 20,
        leftPending: false
      });
    });
  }
