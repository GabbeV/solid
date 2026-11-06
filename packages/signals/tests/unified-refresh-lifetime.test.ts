import { afterEach, expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending as publicPending,
  refresh,
  resetErrorHalt,
  type SourceAccessor
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";
import { isPending } from "../src/layers/pending.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  let reject!: (error: unknown) => void;
  const promise = new Promise<T>((yes, no) => {
    resolve = yes;
    reject = no;
  });
  return { promise, resolve, reject };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
  resetErrorHalt();
});

for (const implementation of ["public API", "explicit layer"] as const)
  for (const bodyEndsFirst of [false, true]) {
    it(`${implementation}: an input error releases with the override lifetime (bodyEndsFirst=${bodyEndsFirst})`, async () => {
      const end = gate<void>(),
        answer = gate<number>();
      const [revision, setRevision] = createSignal(0);
      let guess!: (value: number) => number;
      let shown: number | string = 0;
      createRoot(dispose => {
        disposals.push(dispose);
        const input = createMemo(() =>
          revision() === 0 ? 0 : revision() === 1 ? answer.promise : 2
        );
        const boundary = createErrorBoundary(
          () => {
            const [view, write] =
              implementation === "public API"
                ? createOptimistic(input)
                : createLayer(input, { lifetime: "action" });
            guess = write;
            return view;
          },
          error => (error() as Error).message
        );
        createRenderEffect(boundary, value => {
          shown = value as number | string;
        });
      });
      flush();
      const running = action(function* () {
        setRevision(1);
        guess(1);
        yield end.promise;
      })();
      flush();
      expect(shown).toBe(1);
      if (bodyEndsFirst) {
        end.resolve();
        await running;
        await turn();
      }
      answer.reject(new Error("failed"));
      await turn();
      // Upstream forwards an input error immediately, just as it forwards
      // an early input answer. The prototype retains the selected override
      // until the accepted shared action lifetime ends.
      expect(shown).toBe(bodyEndsFirst ? "failed" : 1);
      end.resolve();
      await running;
      await turn();
      expect(shown).toBe("failed");
      setRevision(2);
      flush();
      expect(shown).toBe(2);
    });
  }

for (const implementation of ["public API", "explicit layer"] as const) {
  it(`${implementation}: a new action can guess while an ended action's input is still pending`, async () => {
    const answer = gate<number>(),
      secondEnd = gate<void>();
    const [revision, setRevision] = createSignal(0);
    let guess!: (value: number) => number;
    const shown = { view: 0, details: 0 };
    createRoot(dispose => {
      disposals.push(dispose);
      const input = createMemo(() => (revision() ? answer.promise : 0));
      const [view, write] =
        implementation === "public API"
          ? createOptimistic(input)
          : createLayer(input, { lifetime: "action" });
      guess = write;
      const details = createMemo(() => view() * 10);
      createRenderEffect(view, value => {
        shown.view = value;
      });
      createRenderEffect(details, value => {
        shown.details = value;
      });
    });
    await action(function* () {
      setRevision(1);
      guess(1);
      yield Promise.resolve();
    })();
    await turn();
    expect(shown).toEqual({ view: 1, details: 10 });
    const second = action(function* () {
      guess(2);
      yield secondEnd.promise;
    })();
    flush();
    expect(shown).toEqual({ view: 2, details: 20 });
    answer.resolve(10);
    await turn();
    expect(shown).toEqual({ view: 2, details: 20 });
    secondEnd.resolve();
    await second;
    await turn();
    expect(shown).toEqual({ view: 10, details: 100 });
  });

  it(`${implementation}: nested guesses wait together for input work caused by the parent guess`, async () => {
    const end = gate<void>(),
      answer = gate<number>();
    let guessFirst!: (value: number) => number, guessSecond!: (value: number) => number;
    const shown = { first: 0, second: 0, pending: false };
    createRoot(dispose => {
      disposals.push(dispose);
      const optimistic = (input: () => number) =>
        implementation === "public API"
          ? createOptimistic(input)
          : createLayer(input, { lifetime: "action" });
      const [first, g1] = optimistic(() => 0);
      const input = createMemo(() => (first() === 1 ? answer.promise : 0));
      const [second, g2] = optimistic(input);
      guessFirst = g1;
      guessSecond = g2;
      createRenderEffect(first, value => {
        shown.first = value;
      });
      createRenderEffect(second, value => {
        shown.second = value;
      });
      createRenderEffect(
        () => (implementation === "public API" ? publicPending : isPending)(second),
        value => {
          shown.pending = value;
        }
      );
    });
    const running = action(function* () {
      guessFirst(1);
      guessSecond(2);
      yield end.promise;
    })();
    flush();
    // Both implementations cut observation through the child override.
    expect(shown).toEqual({
      first: 1,
      second: 2,
      pending: true
    });
    end.resolve();
    await running;
    await turn();
    // Both implementations cut observation through the child override.
    expect(shown).toEqual({
      first: 1,
      second: 2,
      pending: true
    });
    answer.resolve(10);
    await turn();
    expect(shown).toEqual({ first: 0, second: 0, pending: false });
  });

  it(`${implementation}: guesses made by one action release together while one input is pending`, async () => {
    const end = gate<void>(),
      answer = gate<number>();
    const [revision, setRevision] = createSignal(0);
    let guessA!: (value: number) => number, guessB!: (value: number) => number;
    let shown: readonly number[] = [];
    createRoot(dispose => {
      disposals.push(dispose);
      const inputA = createMemo(() => (revision() ? answer.promise : 0));
      const optimistic = (input: () => number) =>
        implementation === "public API"
          ? createOptimistic(input)
          : createLayer(input, { lifetime: "action" });
      const [a, ga] = optimistic(inputA),
        [b, gb] = optimistic(() => 0);
      guessA = ga;
      guessB = gb;
      createRenderEffect(
        () => [a(), b()],
        value => {
          shown = value;
        }
      );
    });
    const running = action(function* () {
      setRevision(1);
      guessA(1);
      guessB(2);
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual([1, 2]);
    end.resolve();
    await running;
    await turn();
    expect(shown).toEqual([1, 2]);
    answer.resolve(10);
    await turn();
    expect(shown).toEqual([10, 0]);
  });
}

it("layer: a pending input with no separate reader releases its override when it lands", async () => {
  const answer = gate<number>();
  const [id, setId] = createSignal(0);
  const shown = { view: 0, details: 0 };
  let guess!: (value: number) => number;
  createRoot(dispose => {
    disposals.push(dispose);
    const input = createMemo(() => (id() ? answer.promise : 0));
    const [view, write] = createLayer(input, { lifetime: "action" });
    guess = write;
    const details = createMemo(() => view() * 10);
    createRenderEffect(view, value => {
      shown.view = value;
    });
    createRenderEffect(details, value => {
      shown.details = value;
    });
  });
  await action(function* () {
    setId(1);
    guess(1);
    yield Promise.resolve();
  })();
  await turn();
  expect(shown).toEqual({ view: 1, details: 10 });
  answer.resolve(2);
  await turn();
  expect(shown).toEqual({ view: 2, details: 20 });
});

for (const implementation of ["public API", "explicit layer"] as const)
  for (const oldAnswersFirst of [false, true]) {
    it(`${implementation}: a superseding refresh after both bodies end keeps obsolete answers out (oldAnswersFirst=${oldAnswersFirst})`, async () => {
      const oldSaved = gate<void>(),
        newSaved = gate<void>();
      const oldAnswer = gate<number>(),
        newAnswer = gate<number>();
      let result: number | Promise<number> = 0;
      let input!: SourceAccessor<number>, guess!: (value: number) => number;
      const shown = { view: 0, details: 0, pending: false };
      const calculations: number[] = [];
      createRoot(dispose => {
        disposals.push(dispose);
        input = createMemo(() => result);
        const [view, write] =
          implementation === "public API"
            ? createOptimistic(input)
            : createLayer(input, { lifetime: "action" });
        guess = write;
        const details = createMemo(() => {
          const value = view();
          calculations.push(value);
          return value * 10;
        });
        createRenderEffect(view, value => {
          shown.view = value;
        });
        createRenderEffect(details, value => {
          shown.details = value;
        });
        createRenderEffect(
          () => (implementation === "public API" ? publicPending : isPending)(details),
          value => {
            shown.pending = value;
          }
        );
      });
      const save = action(function* (value: number, saved: Promise<void>, answer: Promise<number>) {
        guess(value);
        yield saved;
        result = answer;
        refresh(input);
      });
      const first = save(1, oldSaved.promise, oldAnswer.promise);
      flush();
      const second = save(2, newSaved.promise, newAnswer.promise);
      flush();
      expect(shown).toEqual({ view: 2, details: 20, pending: false });
      oldSaved.resolve();
      await first;
      await turn();
      newSaved.resolve();
      await second;
      await turn();
      expect(shown).toEqual({ view: 2, details: 20, pending: false });
      if (oldAnswersFirst) {
        oldAnswer.resolve(10);
        await turn();
        expect(shown).toEqual({ view: 2, details: 20, pending: false });
      }
      newAnswer.resolve(20);
      await turn();
      expect(shown).toEqual({ view: 20, details: 200, pending: false });
      oldAnswer.resolve(10);
      await turn();
      expect(shown).toEqual({ view: 20, details: 200, pending: false });
      expect(calculations).toEqual([0, 1, 2, 20]);
    });
  }
