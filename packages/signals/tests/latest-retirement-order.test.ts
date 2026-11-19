import { afterEach, expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

for (const schedule of [false, true]) {
  for (const previewFirst of [false, true]) {
    it(`a ready shipping preview publishes while the ordinary total waits (scheduled=${schedule}, previewFirst=${previewFirst})`, async () => {
      const configAnswer = Promise.withResolvers<{ shipping: number; tax: number }>();
      const shippingAnswer = Promise.withResolvers<number>();
      const taxAnswer = Promise.withResolvers<number>();
      const end = Promise.withResolvers<void>();
      const previews: number[] = [], totals: number[] = [], pending: boolean[] = [];
      let run!: () => Promise<void>;
      createRoot(dispose => {
        disposals.push(dispose);
        const [country, guessCountry] = createOptimistic(0);
        const config = createMemo(() => country() ? configAnswer.promise : { shipping: 0, tax: 0 });
        const [courier, guessCourier] = createOptimistic(() => config().shipping);
        const [taxScheme, guessTaxScheme] = createOptimistic(() => config().tax);
        const shipping = createMemo(() => courier() ? shippingAnswer.promise : 15);
        const tax = createMemo(() => taxScheme() ? taxAnswer.promise : 8);
        const total = createMemo(() => 100 + shipping() + tax());
        const preview = () => createRenderEffect(
          () => latest(shipping), value => { previews.push(value); }, { schedule }
        );
        if (previewFirst) preview();
        createRenderEffect(total, value => { totals.push(value); }, { schedule });
        if (!previewFirst) preview();
        createRenderEffect(() => isPending(shipping), value => { pending.push(value); }, { schedule });
        run = action(function* () {
          guessCountry(1);
          guessCourier(1);
          guessTaxScheme(1);
          yield end.promise;
        });
      });
      flush();
      const running = run();
      flush();
      configAnswer.resolve({ shipping: 1, tax: 2 });
      await turn();
      shippingAnswer.resolve(25);
      await turn();
      expect(previews).toEqual([15, 25]);
      expect(totals).toEqual([123]);
      expect(pending.at(-1)).toBe(true);
      taxAnswer.resolve(20);
      await turn();
      expect(totals).toEqual([123, 145]);
      expect(pending.at(-1)).toBe(false);
      end.resolve();
      await running;
      await turn();
    });
  }

  it(`a notification cannot take an unpublished binding out of its mount (scheduled=${schedule})`, async () => {
    const end = Promise.withResolvers<void>();
    const [source, setSource] = createSignal(0);
    const [mounted, setMounted] = createSignal(false);
    const answers = new Map<number, ReturnType<typeof Promise.withResolvers<number>>>();
    const controls: boolean[] = [], children: number[] = [];
    createRoot(dispose => {
      disposals.push(dispose);
      const input = createMemo(() => Promise.resolve(latest(source)));
      const details = createMemo(() => {
        const value = input();
        const answer = Promise.withResolvers<number>();
        answers.set(value, answer);
        return answer.promise;
      });
      createRenderEffect(mounted, value => { controls.push(value); }, { schedule });
      createRenderEffect(() => {
        if (mounted()) {
          createRenderEffect(details, value => { children.push(value); }, { schedule });
        }
      }, () => {}, { schedule });
    });
    await turn();
    answers.get(0)!.resolve(0);
    await turn();
    const running = action(function* () {
      setSource(1);
      yield end.promise;
      setSource(0);
    })();
    await turn();
    setMounted(true);
    await turn();
    expect(controls).toEqual([false]);
    expect(children).toEqual([]);
    end.resolve();
    await running;
    await turn();
    expect(controls).toEqual([false]);
    expect(children).toEqual([]);
    answers.get(0)!.resolve(0);
    await turn();
    expect(controls).toEqual([false, true]);
    expect(children).toEqual([0]);
    answers.get(1)!.resolve(1);
    await turn();
    expect(children).toEqual([0]);
  });

  it(`restoration supersedes an unfinished latest consequence without waiting (scheduled=${schedule})`, async () => {
    const end = Promise.withResolvers<void>();
    const obsolete = Promise.withResolvers<number>();
    const [source, setSource] = createSignal(0);
    const calculations: number[] = [], shown: number[] = [], inputs: number[] = [];
    createRoot(dispose => {
      disposals.push(dispose);
      const details = createMemo(() => {
        const value = latest(source);
        calculations.push(value);
        return value === 1 ? obsolete.promise : value;
      });
      createRenderEffect(source, value => { inputs.push(value); }, { schedule });
      createRenderEffect(details, value => { shown.push(value); }, { schedule });
    });
    flush();
    const running = action(function* () {
      setSource(1);
      yield end.promise;
      setSource(2);
    })();
    flush();
    expect(calculations).toEqual([0, 1]);
    expect(shown).toEqual([0]);
    end.resolve();
    await running;
    await turn();
    expect(inputs).toEqual([0, 2]);
    expect(shown).toEqual([0, 2]);
    // The stale flight has not answered; it must not hold the correction.
    obsolete.resolve(1);
    await turn();
    expect(shown).toEqual([0, 2]);
  });
}
