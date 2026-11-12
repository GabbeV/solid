import { expect, it } from "vitest";
import {
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("a guessed derived key displays during refetch while its sibling keeps the producer pending", async () => {
  const requests: Array<PromiseWithResolvers<{ chosen: number; sibling: number }>> = [];
  const [id, setId] = createSignal(0);
  const [store, guess] = createOptimisticStore(
    async () => {
      id();
      const request = Promise.withResolvers<{ chosen: number; sibling: number }>();
      requests.push(request);
      return request.promise;
    },
    { chosen: 0, sibling: 0 }
  );
  const chosen: number[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.chosen,
      value => void chosen.push(value)
    );
    return dispose;
  });
  try {
    flush();
    requests[0].resolve({ chosen: 1, sibling: 1 });
    await turn();
    flush();
    expect(chosen.at(-1)).toBe(1);

    setId(1);
    flush();
    expect(isPending(() => store.sibling)).toBe(true);
    guess(draft => {
      draft.chosen = 999;
    });
    flush();
    expect(store.chosen).toBe(999);
    expect(chosen.at(-1)).toBe(999);
    expect(latest(() => store.chosen)).toBe(999);
    expect(isPending(() => store.chosen)).toBe(true);
    expect(isPending(() => store.sibling)).toBe(true);

    const late: number[] = [];
    const disposeLate = createRoot(dispose => {
      createRenderEffect(
        () => store.sibling,
        value => void late.push(value)
      );
      return dispose;
    });
    flush();
    expect(late).not.toContain(2);

    requests[1].resolve({ chosen: 2, sibling: 2 });
    await turn();
    flush();
    expect(store.chosen).toBe(2);
    expect(store.sibling).toBe(2);
    expect(isPending(() => store.sibling)).toBe(false);
    disposeLate();
  } finally {
    dispose();
  }
});
