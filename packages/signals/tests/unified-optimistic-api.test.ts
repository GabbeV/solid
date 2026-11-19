import { expect, it } from "vitest";
import {
  action, createMemo, createOptimistic, createRenderEffect, createRoot,
  createSignal, flush, isPending, latest
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("a plain optimistic value reverts after its action, including an undefined input", async () => {
  const end = Promise.withResolvers<void>();
  const shown: unknown[][] = [];
  let run!: () => Promise<unknown>;
  const dispose = createRoot(dispose => {
    const [number, guessNumber] = createOptimistic(2);
    const [empty, guessEmpty] = createOptimistic<string>();
    createRenderEffect(() => [number(), empty()], value => { shown.push(value); });
    run = action(function* () {
      guessNumber(value => value + 3);
      guessEmpty("ready");
      yield end.promise;
    });
    return dispose;
  });
  try {
    flush();
    const running = run();
    flush();
    expect(shown).toEqual([[2, undefined], [5, "ready"]]);
    end.resolve();
    await running;
    await turn();
    expect(shown).toEqual([[2, undefined], [5, "ready"], [2, undefined]]);
  } finally { end.resolve(); dispose(); flush(); }
});

it("an ambient guess without a pending update never flashes", () => {
  const shown: number[] = [];
  let guess!: (value: number) => number;
  const dispose = createRoot(dispose => {
    const [view, write] = createOptimistic(0);
    guess = write;
    createRenderEffect(view, value => { shown.push(value); });
    return dispose;
  });
  try {
    flush(); guess(1); flush();
    expect(shown).toEqual([0]);
  } finally { dispose(); flush(); }
});

it("a returned action retains its guess while its ordinary observed work is pending", async () => {
  const answer = Promise.withResolvers<number>();
  const shown = { source: 0, data: 0, optimistic: 0 };
  let run!: () => Promise<unknown>;
  const dispose = createRoot(dispose => {
    const [source, setSource] = createSignal(0);
    const [optimistic, guess] = createOptimistic(0);
    const data = createMemo(() => source() ? answer.promise : 0);
    createRenderEffect(source, value => { shown.source = value; });
    createRenderEffect(data, value => { shown.data = value; });
    createRenderEffect(optimistic, value => { shown.optimistic = value; });
    run = action(function* () { guess(5); setSource(1); });
    return dispose;
  });
  try {
    flush(); const running = run(); await turn();
    expect(shown).toEqual({ source: 0, data: 0, optimistic: 5 });
    answer.resolve(10); await running; await turn();
    expect(shown).toEqual({ source: 1, data: 10, optimistic: 0 });
  } finally { answer.resolve(10); dispose(); flush(); }
});

it("an ambient guess follows an async callback input and publishes correction coherently", async () => {
  const answer = Promise.withResolvers<number>();
  const [id, setId] = createSignal(0);
  const shown: number[][] = [];
  let guess!: (value: number) => number;
  const dispose = createRoot(dispose => {
    const [view, write] = createOptimistic(() => id() ? answer.promise : 0);
    guess = write;
    const doubled = createMemo(() => view() * 2);
    createRenderEffect(() => [view(), doubled()], value => { shown.push(value); });
    return dispose;
  });
  try {
    flush(); setId(1); guess(5); flush();
    expect(shown).toEqual([[0, 0], [5, 10]]);
    answer.resolve(7);
    await turn();
    expect(shown).toEqual([[0, 0], [5, 10], [7, 14]]);
  } finally { answer.resolve(7); dispose(); flush(); }
});

it("a literal promise input stays a value rather than becoming an async producer", () => {
  const promise = Promise.resolve(1);
  const dispose = createRoot(dispose => {
    const [view] = createOptimistic(promise);
    expect(view()).toBe(promise);
    return dispose;
  });
  dispose(); flush();
});

it("an async callback can start from loadingValue", async () => {
  const answer = Promise.withResolvers<number>();
  const shown: number[] = [];
  const dispose = createRoot(dispose => {
    const [view] = createOptimistic(() => answer.promise, { loadingValue: 3 });
    createRenderEffect(view, value => { shown.push(value); });
    return dispose;
  });
  try {
    flush(); expect(shown).toEqual([3]);
    answer.resolve(4); await turn(); expect(shown).toEqual([3, 4]);
  } finally { answer.resolve(4); dispose(); flush(); }
});

it("owned condition children publish both bindings without requiring sibling callback order", async () => {
  const end = Promise.withResolvers<void>();
  const child: (string | undefined)[] = [], status: string[] = [];
  let run!: () => Promise<unknown>, setDrag!: (value: boolean) => boolean;
  const dispose = createRoot(dispose => {
    const [view, guess] = createOptimistic(false);
    const [drag, write] = createSignal(false);
    setDrag = write;
    const condition = createMemo(() => {
      const visible = createMemo(() => !!view());
      return visible() ? !drag() : view();
    });
    const value = createMemo(() => condition() ? "child" : undefined, { sync: true });
    createRenderEffect(value, value => { child.push(value); });
    createRenderEffect(
      () => `${drag()}/${latest(drag)}/${isPending(drag)}`,
      value => { status.push(value); }
    );
    run = action(function* () { guess(true); yield end.promise; });
    return dispose;
  });
  try {
    flush(); const running = run(); await turn();
    expect(child).toEqual([undefined, "child"]);
    setDrag(true); await turn();
    expect(child).toEqual([undefined, "child", undefined]);
    expect(status).toEqual(["false/false/false", "true/true/false"]);
    end.resolve(); await running; await turn();
    expect(child).toEqual([undefined, "child", undefined]);
    expect(status).toEqual(["false/false/false", "true/true/false"]);
  } finally { end.resolve(); dispose(); flush(); }
});
