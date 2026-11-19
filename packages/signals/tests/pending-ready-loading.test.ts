import { expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  flush,
  isPending
} from "../src/index.js";

it("a ready optimistic request keeps pending and Loading until its shared publication", async () => {
  const contentDone = Promise.withResolvers<string>();
  const shellDone = Promise.withResolvers<string>();
  const actionDone = Promise.withResolvers<void>();
  let guess!: (value: number) => number;
  const shown = { id: 0, shell: "shell0", content: "content0", pending: false };
  const dispose = createRoot(dispose => {
    const [id, setId] = createOptimistic(0);
    guess = setId;
    const shell = createMemo(() => (id() ? shellDone.promise : "shell0"));
    const content = createMemo(() => (id() ? contentDone.promise : "content0"));
    const loading = createLoadingBoundary(content, () => "loading", {
      on: () => isPending(content)
    });
    createRenderEffect(id, value => {
      shown.id = value;
    });
    createRenderEffect(shell, value => {
      shown.shell = value;
    });
    createRenderEffect(loading, value => {
      shown.content = value;
    });
    createRenderEffect(
      () => isPending(content),
      value => {
        shown.pending = value;
      }
    );
    return dispose;
  });
  flush();
  const running = action(function* () {
    guess(1);
    yield actionDone.promise;
  })();
  try {
    flush();
    expect({ ...shown }).toEqual({ id: 0, shell: "shell0", content: "loading", pending: true });
    contentDone.resolve("content1");
    await new Promise(resolve => setTimeout(resolve, 0));
    expect({ ...shown }).toEqual({ id: 0, shell: "shell0", content: "loading", pending: true });
    shellDone.resolve("shell1");
    await new Promise(resolve => setTimeout(resolve, 0));
    expect({ ...shown }).toEqual({ id: 1, shell: "shell1", content: "content1", pending: false });
  } finally {
    contentDone.resolve("content1");
    shellDone.resolve("shell1");
    actionDone.resolve();
    await running;
    await new Promise(resolve => setTimeout(resolve, 0));
    flush();
    dispose();
  }
});
