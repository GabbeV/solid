import { afterEach, expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";
import { $REFRESH } from "../src/core/constants.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

for (const wrapped of [false, true]) {
  it(`a disabled guard alone reports pending work without holding its source (callback=${wrapped})`, async () => {
    const answer = Promise.withResolvers<number>();
    const shown = { source: 0, disabled: false };
    const disabled: boolean[] = [];
    let set!: (value: number) => number;
    createRoot(dispose => {
      disposals.push(dispose);
      const [source, write] = createSignal(0);
      set = write;
      const input = createMemo(() => source() === 0 ? 0 : answer.promise);
      createRenderEffect(source, value => { shown.source = value; }, { schedule: true });
      createRenderEffect(
        () => isPending(wrapped ? () => input() : input),
        value => { shown.disabled = value; disabled.push(value); },
        { schedule: true }
      );
    });
    flush();
    set(1);
    flush();
    expect(shown).toEqual({ source: 1, disabled: true });
    await turn();
    expect(shown).toEqual({ source: 1, disabled: true });
    answer.resolve(1);
    await turn();
    expect(shown).toEqual({ source: 1, disabled: false });
    expect(disabled).toEqual([false, true, false]);
  });

  it(`removing and reviving a pending guard preserves its reporting lifecycle (callback=${wrapped})`, async () => {
    const first = Promise.withResolvers<number>();
    const second = Promise.withResolvers<number>();
    const shown = { source: 0, disabled: false };
    let set!: (value: number) => number, show!: (value: boolean) => boolean;
    createRoot(dispose => {
      disposals.push(dispose);
      const [source, write] = createSignal(0);
      const [visible, setVisible] = createSignal(true);
      set = write;
      show = setVisible;
      const input = createMemo(() => {
        const value = source();
        return value === 0 ? 0 : value === 1 ? first.promise : second.promise;
      });
      createRenderEffect(source, value => { shown.source = value; }, { schedule: true });
      createRenderEffect(
        () => visible() && isPending(wrapped ? () => input() : input),
        value => { shown.disabled = value; },
        { schedule: true }
      );
    });
    flush();
    set(1);
    flush();
    expect(shown).toEqual({ source: 1, disabled: true });
    show(false);
    flush();
    expect(shown).toEqual({ source: 1, disabled: false });
    first.resolve(1);
    await turn();
    show(true);
    flush();
    set(2);
    flush();
    expect(shown).toEqual({ source: 2, disabled: true });
    second.resolve(2);
    await turn();
    expect(shown).toEqual({ source: 2, disabled: false });
  });
}

it("disposing repeated pending-only observers releases source subscriptions", async () => {
  const [source, setSource] = createSignal(0);
  for (let cycle = 0; cycle < 40; cycle++) {
    const answer = Promise.withResolvers<number>();
    const shown = { source: cycle, disabled: false };
    const dispose = createRoot(dispose => {
      const input = createMemo(() => source() === cycle ? cycle : answer.promise);
      createRenderEffect(source, value => { shown.source = value; }, { schedule: true });
      createRenderEffect(() => isPending(input), value => {
        shown.disabled = value;
      }, { schedule: true });
      return dispose;
    });
    disposals.push(dispose);
    flush();
    setSource(cycle + 1);
    flush();
    expect(shown).toEqual({ source: cycle + 1, disabled: true });
    dispose();
    disposals.pop();
    flush();
    expect(source()).toBe(cycle + 1);
    expect((source as any)[$REFRESH]._subs).toBeNull();
    answer.resolve(cycle + 1);
    await turn();
    expect((source as any)[$REFRESH]._subs).toBeNull();
  }
});

it("a pending-only guard follows the new request when an older answer arrives", async () => {
  const first = Promise.withResolvers<number>();
  const second = Promise.withResolvers<number>();
  const shown = { source: 0, disabled: false };
  let set!: (value: number) => number;
  createRoot(dispose => {
    disposals.push(dispose);
    const [source, write] = createSignal(0);
    set = write;
    const input = createMemo(() => {
      const value = source();
      return value === 0 ? 0 : value === 1 ? first.promise : second.promise;
    });
    createRenderEffect(source, value => { shown.source = value; }, { schedule: true });
    createRenderEffect(() => isPending(input), value => {
      shown.disabled = value;
    }, { schedule: true });
  });
  flush();
  set(1);
  flush();
  expect(shown).toEqual({ source: 1, disabled: true });
  set(2);
  flush();
  first.resolve(1);
  await turn();
  expect(shown).toEqual({ source: 2, disabled: true });
  second.resolve(2);
  await turn();
  expect(shown).toEqual({ source: 2, disabled: false });
});
