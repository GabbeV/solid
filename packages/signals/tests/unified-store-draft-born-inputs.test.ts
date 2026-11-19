import { expect, it } from "vitest";
import { action, createOptimisticStore, createStore, flush } from "../src/index.js";
import { getHasNode, getNode } from "../src/store/store.js";
import { $TARGET } from "../src/store/types.js";

for (const optimistic of [false, true]) {
  it(`keeps nodes created inside a ${optimistic ? "proposal" : "truth"} draft on the correct input`, async () => {
    const [state, setState] = (optimistic ? createOptimisticStore : createStore)({
      n: 1,
      items: [1]
    } as { n: number; added?: number; items: number[] });
    const root = (state as any)[$TARGET];
    const items = (state.items as any)[$TARGET];
    const gate = Promise.withResolvers<void>();
    const running = action(function* () {
      setState(d => {
        d.n = 9;
        d.added = 9;
        d.items.push(2);
        // Companions can allocate their authoritative nodes while the setter
        // is still open; the draft's proposed backing is not their truth.
        getNode(root, "n");
        getHasNode(root, "added");
        getNode(items, "length");
      });
      yield gate.promise;
    })();
    try {
      flush();
      expect([state.n, "added" in state, state.items.length]).toEqual(
        optimistic ? [9, true, 2] : [1, false, 1]
      );
      gate.resolve();
      await running;
      flush();
      expect([state.n, "added" in state, state.items.length]).toEqual(
        optimistic ? [1, false, 1] : [9, true, 2]
      );
    } finally {
      gate.resolve();
      await running;
      flush();
    }
  });
}
