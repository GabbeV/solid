import { expect, it } from "vitest";
import {
  createDeferred,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  onCleanup
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("an unheld pending reversal discovers its async consequence before publication", async () => {
  const answer = Promise.withResolvers<number>();
  const details = Promise.withResolvers<string>();
  const [id, setId] = createSignal(0);
  const shown = { value: 0, pending: false, status: "idle" };
  let detailRuns = 0;
  const dispose = createRoot(dispose => {
    const value = createDeferred(() => (id() ? answer.promise : 0));
    const status = createMemo(() => {
      if (isPending(value)) return "loading";
      if (!value()) return "idle";
      detailRuns++;
      return details.promise;
    });
    createRenderEffect(value, value => {
      shown.value = value;
    });
    createRenderEffect(
      () => isPending(value),
      value => {
        shown.pending = value;
      }
    );
    createRenderEffect(status, value => {
      shown.status = value;
    });
    return dispose;
  });
  try {
    flush();
    expect(shown).toEqual({ value: 0, pending: false, status: "idle" });
    setId(1);
    flush();
    expect(shown).toEqual({ value: 0, pending: true, status: "loading" });
    answer.resolve(1);
    await turn();
    flush();
    expect(detailRuns).toBe(1);
    expect(shown).toEqual({ value: 0, pending: true, status: "loading" });
    details.resolve("ready");
    await turn();
    flush();
    expect(shown).toEqual({ value: 1, pending: false, status: "ready" });
    expect(detailRuns).toBe(1);
  } finally {
    answer.resolve(1);
    details.resolve("ready");
    dispose();
    flush();
  }
});

it("a newer deferred question supersedes work started by pending's reversal", async () => {
  const answers = [Promise.withResolvers<number>(), Promise.withResolvers<number>()];
  const details = [Promise.withResolvers<string>(), Promise.withResolvers<string>()];
  const [id, setId] = createSignal(0);
  const started: number[] = [];
  const cleaned: number[] = [];
  const shown = { value: 0, pending: false, status: "idle" };
  const dispose = createRoot(dispose => {
    const value = createDeferred(() => (id() ? answers[id() - 1].promise : 0));
    const status = createMemo(() => {
      if (isPending(value)) return "loading";
      const current = value();
      if (!current) return "idle";
      started.push(current);
      onCleanup(() => {
        cleaned.push(current);
      });
      return details[current - 1].promise;
    });
    createRenderEffect(value, value => {
      shown.value = value;
    });
    createRenderEffect(
      () => isPending(value),
      value => {
        shown.pending = value;
      }
    );
    createRenderEffect(status, value => {
      shown.status = value;
    });
    return dispose;
  });
  try {
    flush();
    setId(1);
    flush();
    answers[0].resolve(1);
    await turn();
    flush();
    expect(started).toEqual([1]);
    expect(shown).toEqual({ value: 0, pending: true, status: "loading" });
    setId(2);
    flush();
    expect(started).toEqual([1]);
    expect(cleaned).toEqual([1]);
    expect(shown).toEqual({ value: 1, pending: true, status: "loading" });
    details[0].resolve("obsolete");
    await turn();
    flush();
    // Deferred keeps a ready landing when a newer question starts. The
    // pending=true branch no longer consumes that answer, so 1 can now
    // publish as the stale display while question 2 runs.
    expect(shown).toEqual({ value: 1, pending: true, status: "loading" });
    answers[1].resolve(2);
    await turn();
    flush();
    expect(started).toEqual([1, 2]);
    expect(cleaned).toEqual([1]);
    expect(shown).toEqual({ value: 1, pending: true, status: "loading" });
    details[1].resolve("ready 2");
    await turn();
    flush();
    expect(shown).toEqual({ value: 2, pending: false, status: "ready 2" });
    expect(started).toEqual([1, 2]);
    expect(cleaned).toEqual([1]);
  } finally {
    answers.forEach((answer, index) => answer.resolve(index + 1));
    details.forEach(detail => detail.resolve("done"));
    dispose();
    flush();
  }
  expect(cleaned).toEqual([1, 2]);
});
