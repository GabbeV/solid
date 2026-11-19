import { afterEach, describe, expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending as publicPending,
  resetErrorHalt
} from "../src/index.js";
import { createLayer, pendingInput } from "../src/layers/layer.js";
import { $REFRESH } from "../src/core/constants.js";
import { isPending as sharedPending } from "../src/layers/pending.js";
function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
function root(fn: () => void) {
  let release!: () => void;
  createRoot(dispose => {
    release = dispose;
    disposals.push(dispose);
    fn();
  });
  return release;
}
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
  resetErrorHalt();
});

for (const implementation of ["public API", "explicit layer"] as const) {
  const optimistic = (input: () => number) =>
    implementation === "public API"
      ? createOptimistic<number>(input)
      : createLayer(input, { lifetime: "action" });
  const isPending = implementation === "public API" ? publicPending : sharedPending;
  describe(`${implementation}: pending on an optimistic output`, () => {
    for (const answer of [1, 2])
      for (const requestLater of [false, true]) {
        // Public and explicit boundaries must preserve the same consistency.
        it(
          `an unresolved input remains pending (answer=${answer}, later request=${requestLater})`,
          async () => {
            const result = gate<number>(),
              end = gate<void>(),
              start = gate<void>();
            const [id, setId] = createSignal(0);
            let inputShown = 0,
              viewShown = 0,
              status = false,
              doubled = 0,
              late = false;
            let view!: () => number;
            let guess!: (value: number) => number;
            root(() => {
              const input = createMemo(() => (id() ? result.promise : 0));
              [view, guess] = optimistic(input);
              const twice = createMemo(() => view() * 2);
              createRenderEffect(input, value => {
                inputShown = value;
              });
              createRenderEffect(view, value => {
                viewShown = value;
              });
              createRenderEffect(twice, value => {
                doubled = value;
              });
              createRenderEffect(
                () => isPending(view),
                value => {
                  status = value;
                }
              );
            });
            flush();
            const running = action(function* () {
              guess(1);
              if (requestLater) yield start.promise;
              setId(1);
              yield end.promise;
            })();
            flush();
            if (requestLater) {
              expect([viewShown, doubled, status]).toEqual([1, 2, false]);
              start.resolve();
              await turn();
            }
            root(() =>
              createRenderEffect(
                () => isPending(view),
                value => {
                  late = value;
                }
              )
            );
            flush();
            expect([inputShown, viewShown, doubled, status, late]).toEqual([0, 1, 2, true, true]);
            result.resolve(answer);
            await turn();
            expect([inputShown, viewShown, doubled, status, late]).toEqual([
              0,
              1,
              2,
              answer !== 1,
              answer !== 1
            ]);
            end.resolve();
            await running;
            await turn();
            expect([inputShown, viewShown, doubled, status, late]).toEqual([
              answer,
              answer,
              answer * 2,
              false,
              false
            ]);
          }
        );
      }

    it("nested overrides observe their own unresolved input calculations", async () => {
      const firstResult = gate<number>(),
        secondResult = gate<number>();
      const firstEnd = gate<void>(),
        secondEnd = gate<void>();
      const [id, setId] = createSignal(0);
      let firstGuess!: (value: number) => number, secondGuess!: (value: number) => number;
      let first = 0,
        second = 0,
        firstPending = false,
        secondPending = false;
      root(() => {
        const source = createMemo(() => (id() ? firstResult.promise : 0));
        const [a, ga] = optimistic(source);
        const middle = createMemo(() => (a() ? secondResult.promise : 0));
        const [b, gb] = optimistic(middle);
        firstGuess = ga;
        secondGuess = gb;
        createRenderEffect(a, value => {
          first = value;
        });
        createRenderEffect(b, value => {
          second = value;
        });
        createRenderEffect(
          () => isPending(a),
          value => {
            firstPending = value;
          }
        );
        createRenderEffect(
          () => isPending(b),
          value => {
            secondPending = value;
          }
        );
      });
      flush();
      const firstAction = action(function* () {
        setId(1);
        firstGuess(1);
        yield firstEnd.promise;
      })();
      flush();
      const secondAction = action(function* () {
        secondGuess(3);
        yield secondEnd.promise;
      })();
      flush();
      // The displayed child cuts demand for the unresolved middle input.
      expect([first, second, firstPending, secondPending]).toEqual([
        1,
        3,
        true,
        true
      ]);
      firstResult.resolve(1);
      await turn();
      expect([first, second, firstPending, secondPending]).toEqual([
        1,
        3,
        false,
        true
      ]);
      secondResult.resolve(3);
      await turn();
      // The ready middle input joins the child lifetime, but the lower
      // proposal has already published through the optimistic boundary.
      expect([first, second, firstPending, secondPending]).toEqual([
        1,
        3,
        false,
        false
      ]);
      firstEnd.resolve();
      secondEnd.resolve();
      await Promise.all([firstAction, secondAction]);
      await turn();
      expect([first, second, firstPending, secondPending]).toEqual([1, 3, false, false]);
    });

    it("a new guess against an already held differing answer stays pending", async () => {
      const result = gate<number>(),
        changeGuess = gate<void>(),
        end = gate<void>();
      const [id, setId] = createSignal(0);
      let shown = 0,
        status = false,
        guess!: (value: number) => number;
      root(() => {
        const input = createMemo(() => (id() ? result.promise : 0));
        const [view, write] = optimistic(input);
        guess = write;
        createRenderEffect(view, value => {
          shown = value;
        });
        createRenderEffect(
          () => isPending(view),
          value => {
            status = value;
          }
        );
      });
      flush();
      const running = action(function* () {
        setId(1);
        guess(1);
        yield changeGuess.promise;
        guess(3);
        yield end.promise;
      })();
      flush();
      expect([shown, status]).toEqual([1, true]);
      result.resolve(2);
      await turn();
      expect([shown, status]).toEqual([1, true]);
      changeGuess.resolve();
      await turn();
      expect([shown, status]).toEqual([3, true]);
      end.resolve();
      await running;
      await turn();
      expect([shown, status]).toEqual([2, false]);
    });
  });
}

for (const confirmBeforeLabel of [false, true])
  it(`pending consequences remain coherent when a guess is confirmed (early=${confirmBeforeLabel})`, async () => {
    const inputResult = gate<number>(),
      labelResult = gate<string>(),
      end = gate<void>();
    const [id, setId] = createSignal(0);
    let guess!: (value: number) => number;
    let shown = 0,
      status = false,
      label = "settled";
    root(() => {
      const input = createMemo(() => (id() ? inputResult.promise : 0));
      const [view, write] = createLayer(input, { lifetime: "action" });
      guess = write;
      const text = createMemo(() => (sharedPending(view) ? labelResult.promise : "settled"));
      createRenderEffect(view, value => {
        shown = value;
      });
      createRenderEffect(
        () => sharedPending(view),
        value => {
          status = value;
        }
      );
      createRenderEffect(text, value => {
        label = value;
      });
    });
    flush();
    const running = action(function* () {
      setId(1);
      guess(1);
      yield end.promise;
    })();
    flush();
    expect([shown, status, label]).toEqual([1, false, "settled"]);
    if (!confirmBeforeLabel) {
      labelResult.resolve("pending");
      await turn();
      expect([shown, status, label]).toEqual([1, true, "pending"]);
    }
    inputResult.resolve(1);
    await turn();
    expect([shown, status, label]).toEqual([1, false, "settled"]);
    if (confirmBeforeLabel) {
      labelResult.resolve("obsolete");
      await turn();
      expect([shown, status, label]).toEqual([1, false, "settled"]);
    }
    end.resolve();
    await running;
    await turn();
    expect([shown, status, label]).toEqual([1, false, "settled"]);
  });

it("an unrevealed guess and its pending-dependent combination remain one coherent frame", async () => {
  const inputResult = gate<number>(),
    labelResult = gate<string>(),
    valueResult = gate<number>(),
    end = gate<void>();
  const [id, setId] = createSignal(0);
  let guess!: (value: number) => number;
  let inputShown = 0,
    viewShown = 0,
    status = false;
  let pair: readonly [boolean, number, number] = [false, 0, 0];
  root(() => {
    const input = createMemo(() => (id() ? inputResult.promise : 0));
    const [view, write] = createLayer(input, { lifetime: "action" });
    guess = write;
    const derived = createMemo(() => (view() ? valueResult.promise : 0));
    createRenderEffect(derived, () => {});
    const label = createMemo(() => (sharedPending(view) ? labelResult.promise : "settled"));
    const combined = createMemo(() => [sharedPending(view), input(), view()] as const);
    createRenderEffect(input, value => {
      inputShown = value;
    });
    createRenderEffect(view, value => {
      viewShown = value;
    });
    createRenderEffect(
      () => sharedPending(view),
      value => {
        status = value;
      }
    );
    createRenderEffect(combined, value => {
      pair = value;
    });
    createRenderEffect(label, () => {});
  });
  flush();
  const check = () => expect(pair).toEqual([status, inputShown, viewShown]);
  const running = action(function* () {
    setId(1);
    guess(1);
    yield end.promise;
  })();
  flush();
  check();
  // The value's own ordinary async derivation holds this guess.
  // Confirmation is not confirmation of an already visible 1.
  expect(viewShown).toBe(0);
  inputResult.resolve(1);
  await turn();
  check();
  labelResult.resolve("pending");
  await turn();
  check();
  valueResult.resolve(1);
  await turn();
  check();
  end.resolve();
  await running;
  await turn();
  check();
  expect(pair).toEqual([false, 1, 1]);
});

it("an obsolete input answer cannot clear the newer request's pending output", async () => {
  const oldResult = gate<number>(),
    nextResult = gate<number>();
  const advance = gate<void>(),
    end = gate<void>();
  const [id, setId] = createSignal(0);
  let view!: () => number, guess!: (value: number) => number;
  let shown = 0,
    status = false;
  root(() => {
    const input = createMemo(() =>
      id() === 0 ? 0 : id() === 1 ? oldResult.promise : nextResult.promise
    );
    [view, guess] = createLayer(input, { lifetime: "action" });
    createRenderEffect(view, value => {
      shown = value;
    });
    createRenderEffect(
      () => sharedPending(view),
      value => {
        status = value;
      }
    );
  });
  flush();
  const running = action(function* () {
    setId(1);
    guess(1);
    yield advance.promise;
    setId(2);
    guess(2);
    yield end.promise;
  })();
  flush();
  expect([shown, status]).toEqual([1, true]);
  advance.resolve();
  await turn();
  expect([shown, status]).toEqual([2, true]);
  oldResult.resolve(2);
  await turn();
  expect([shown, status]).toEqual([2, true]);
  nextResult.resolve(2);
  await turn();
  expect([shown, status]).toEqual([2, false]);
  end.resolve();
  await running;
  await turn();
  expect([shown, status]).toEqual([2, false]);
});

it("repeatedly removing and reviving status readers releases both boundary subscriptions", async () => {
  const result = gate<number>(),
    end = gate<void>();
  const [id, setId] = createSignal(0);
  let view!: () => number, guess!: (value: number) => number;
  root(() => {
    const input = createMemo(() => (id() ? result.promise : 0));
    [view, guess] = createLayer(input, { lifetime: "action" });
    createRenderEffect(view, () => {});
  });
  flush();
  const output = (view as any)[$REFRESH];
  const input = pendingInput(output)!;
  const subscribers = (node: any) => {
    let count = 0;
    for (let link = node._subs; link; link = link._nextSub) count++;
    return count;
  };
  const before = [subscribers(input), subscribers(output)];
  const running = action(function* () {
    setId(1);
    guess(1);
    yield end.promise;
  })();
  flush();
  for (let cycle = 0; cycle < 30; cycle++) {
    let shown = false;
    const dispose = root(() =>
      createRenderEffect(
        () => sharedPending(view),
        value => {
          shown = value;
        }
      )
    );
    flush();
    expect(shown).toBe(true);
    expect([subscribers(input), subscribers(output)]).toEqual(before.map(count => count + 1));
    dispose();
    flush();
    expect([subscribers(input), subscribers(output)]).toEqual(before);
  }
  result.resolve(1);
  end.resolve();
  await running;
  await turn();
  let settled = true;
  root(() =>
    createRenderEffect(
      () => sharedPending(view),
      value => {
        settled = value;
      }
    )
  );
  flush();
  expect(settled).toBe(false);
});
