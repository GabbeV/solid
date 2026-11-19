import { expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("a higher proposal waits when a lower input has no published value to read", async () => {
  const initial = Promise.withResolvers<number>();
  const lowerEnd = Promise.withResolvers<void>();
  const upperEnd = Promise.withResolvers<void>();
  const [id, setId] = createSignal(0);
  let guess!: (value: number) => void;
  const shown = { input: "", view: 0, label: "" };
  const dispose = createRoot(dispose => {
    const input = createMemo(() => (id() ? 42 : initial.promise));
    const loading = createLoadingBoundary(
      () => String(input()),
      () => "loading"
    );
    const [view, write] = createOptimistic(() => 0);
    guess = write;
    const label = createMemo(() => (view() ? String(input()) : "idle"));
    createRenderEffect(loading, value => {
      shown.input = value;
    });
    createRenderEffect(view, value => {
      shown.view = value;
    });
    createRenderEffect(label, value => {
      shown.label = value;
    });
    return dispose;
  });
  flush();
  const lower = action(function* () {
    setId(1);
    yield lowerEnd.promise;
  })();
  flush();
  const upper = action(function* () {
    guess(1);
    yield upperEnd.promise;
  })();
  try {
    flush();
    expect(shown).toEqual({ input: "loading", view: 0, label: "idle" });
    lowerEnd.resolve();
    await lower;
    await turn();
    flush();
    expect(shown).toEqual({ input: "42", view: 1, label: "42" });
    upperEnd.resolve();
    await upper;
    await turn();
    flush();
    expect(shown).toEqual({ input: "42", view: 0, label: "idle" });
  } finally {
    initial.resolve(0);
    lowerEnd.resolve();
    upperEnd.resolve();
    await Promise.all([lower, upper]);
    dispose();
    flush();
  }
});
