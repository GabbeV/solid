import { afterEach, expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
import { createOptimistic } from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

for (const guess of [2, 10]) {
  it(`an already-proposed conditional input can publish during the child action (guess=${guess})`, async () => {
    const endA = Promise.withResolvers<void>(),
      endB = Promise.withResolvers<void>(),
      endC = Promise.withResolvers<void>();
    const hold = Promise.withResolvers<number>();
    const shown = { branch: false, a: 0, b: 0, input: 0, c: 0, doubled: 0, pair: 0, holdB: 0 };
    let guessA!: (v: number) => number,
      guessB!: (v: number) => number,
      guessC!: (v: number) => number;
    let setBranch!: (v: boolean) => boolean;
    createRoot(dispose => {
      disposals.push(dispose);
      const [source] = createSignal(0),
        [branch, writeBranch] = createSignal(false);
      const [a, writeA] = createOptimistic(source),
        [b, writeB] = createOptimistic(a);
      const input = createMemo(() => (branch() ? b() : 0));
      const [c, writeC] = createOptimistic(input);
      const doubled = createMemo(() => c() * 2),
        pair = createMemo(() => c() + b());
      const holdB = createMemo(() => (b() === 2 ? hold.promise : b()));
      [guessA, guessB, guessC, setBranch] = [writeA, writeB, writeC, writeBranch];
      for (const [name, read] of Object.entries({ branch, a, b, input, c, doubled, pair, holdB }))
        createRenderEffect(read as () => number | boolean, value => {
          (shown as any)[name] = value;
        });
    });
    const a = action(function* () {
      guessA(1);
      yield endA.promise;
    })();
    flush();
    const b = action(function* () {
      guessB(2);
      yield endB.promise;
    })();
    flush();
    setBranch(true);
    flush();
    const c = action(function* () {
      guessC(guess);
      yield endC.promise;
    })();
    flush();
    expect(shown).toEqual({
      branch: false,
      a: 1,
      b: 1,
      input: 0,
      c: guess,
      doubled: guess * 2,
      pair: guess + 1,
      holdB: 1
    });
    hold.resolve(2);
    await turn();
    flush();
    expect(shown).toEqual({
      branch: true,
      a: 1,
      b: 2,
      input: 2,
      c: guess,
      doubled: guess * 2,
      pair: guess + 2,
      holdB: 2
    });
    endC.resolve();
    await c;
    await turn();
    flush();
    expect(shown).toEqual({
      branch: true,
      a: 1,
      b: 2,
      input: 2,
      c: 2,
      doubled: 4,
      pair: 4,
      holdB: 2
    });
    endA.resolve();
    endB.resolve();
    await Promise.all([a, b]);
    await turn();
    flush();
    expect(shown).toEqual({
      branch: true,
      a: 0,
      b: 0,
      input: 0,
      c: 0,
      doubled: 0,
      pair: 0,
      holdB: 0
    });
  });
}
