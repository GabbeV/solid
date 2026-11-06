import { afterEach, expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  isPending as publicPending,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup,
  resetErrorHalt
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";
import { isPending } from "../src/layers/pending.js";
import { refresh } from "../src/layers/refresh.js";

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

for (const refreshed of [false, true])
it(`using a lazy memo as input preserves its independent owner and other subscribers (refreshed=${refreshed})`, async () => {
  const [source, setSource] = createSignal(0);
  let input!: () => number,
    a = 0,
    b = 0,
    runs = 0,
    cleaned = 0;
  root(() => {
    input = createMemo(
      () => {
        runs++;
        onCleanup(() => {
          cleaned++;
        });
        return source();
      },
      { lazy: true, sync: refreshed }
    );
  });
  let firstView!: () => number;
  const first = root(() => {
    const [view] = createLayer(input);
    firstView = view;
    createRenderEffect(view, value => {
      a = value;
    });
  });
  const second = root(() => {
    const [view] = createLayer(input);
    createRenderEffect(view, value => {
      b = value;
    });
  });
  flush();
  expect([a, b, runs, cleaned]).toEqual([0, 0, 1, 0]);
  if (refreshed) {
    expect(await refresh(firstView)).toBe(0);
    expect([a, b, runs, cleaned]).toEqual([0, 0, 1, 0]);
  }
  first();
  flush();
  expect(cleaned).toBe(0);
  setSource(1);
  flush();
  expect([a, b, runs, cleaned]).toEqual([0, 1, 2, 1]);
  second();
  flush();
  expect(cleaned).toBe(2);
  setSource(2);
  flush();
  expect(runs).toBe(2);
  root(() => {
    const [view] = createLayer(input);
    createRenderEffect(view, value => {
      b = value;
    });
  });
  flush();
  expect([b, runs, cleaned]).toEqual([2, 3, 2]);
});

// Accepted provisional upstream rule: an equal input answer clears pending
// before action completion. Preserve independent output-consistency assertions.
for (const implementation of ["public API", "explicit layer"] as const)
  for (const wrapped of [false, true])
    for (const alwaysNotify of [false, true])
      it(`${implementation}: an equal input answer follows its notification policy (wrapped=${wrapped}, alwaysNotify=${alwaysNotify})`, async () => {
        const optimistic = (input: () => number) =>
          implementation === "public API"
            ? createOptimistic<number>(input)
            : createLayer(input, { lifetime: "action" });
        const pending = implementation === "public API" ? publicPending : isPending;
        const answer = gate<number>(),
          end = gate<void>();
        const [id, setId] = createSignal(0);
        let guess!: (value: number) => number;
        let shown = 0,
          status = false,
          doubled = 0,
          late = false;
        const calculations: number[] = [];
        let view!: () => number;
        root(() => {
          const input = createMemo(
            () => (id() ? answer.promise : 0),
            alwaysNotify ? { equals: false } : undefined
          );
          [view, guess] = optimistic(wrapped ? () => input() : input);
          const twice = createMemo(() => {
            const value = view();
            calculations.push(value);
            return value * 2;
          });
          createRenderEffect(twice, value => {
            doubled = value;
          });
          createRenderEffect(view, value => {
            shown = value;
          });
          createRenderEffect(
            () => pending(view),
            value => {
              status = value;
            }
          );
        });
        flush();
        const running = action(function* () {
          setId(1);
          guess(1);
          yield end.promise;
        })();
        flush();
        expect([shown, status]).toEqual([1, true]);
        answer.resolve(0);
        await turn();
        root(() =>
          createRenderEffect(
            () => pending(view),
            value => {
              late = value;
            }
          )
        );
        flush();
        expect([shown, doubled, status, late]).toEqual([1, 2, alwaysNotify, alwaysNotify]);
        // The shared selector retains its override until release, even when
        // the input explicitly notifies an equal answer. Upstream may begin
        // that correction immediately beneath the displayed override.
        expect(calculations).toEqual(
          [0, 1]
        );
        end.resolve();
        await running;
        await turn();
        expect([shown, doubled, status, late]).toEqual([0, 0, false, false]);
        expect(calculations).toEqual([0, 1, 0]);
      });

it("early pending-false and its async consequence publish together", async () => {
  const answer = gate<number>(),
    end = gate<void>(),
    labelResult = gate<string>();
  const [id, setId] = createSignal(0);
  let view!: () => number, guess!: (value: number) => number;
  let shown = 0,
    status = false,
    late = false,
    label = "";
  root(() => {
    const input = createMemo(() => (id() ? answer.promise : 0));
    [view, guess] = createLayer(input, { lifetime: "action" });
    const text = createMemo<string>(previous => {
      if (isPending(view)) return "pending";
      return previous === undefined ? "idle" : labelResult.promise;
    });
    createRenderEffect(view, value => {
      shown = value;
    });
    createRenderEffect(
      () => isPending(view),
      value => {
        status = value;
      }
    );
    createRenderEffect(text, value => {
      label = value;
    });
  });
  flush();
  expect([shown, status, label]).toEqual([0, false, "idle"]);
  const running = action(function* () {
    setId(1);
    guess(1);
    yield end.promise;
  })();
  flush();
  expect([shown, status, label]).toEqual([1, true, "pending"]);
  answer.resolve(0);
  await turn();
  root(() =>
    createRenderEffect(
      () => isPending(view),
      value => {
        late = value;
      }
    )
  );
  flush();
  expect([shown, status, late, label]).toEqual([1, true, true, "pending"]);
  labelResult.resolve("settled");
  await turn();
  expect([shown, status, late, label]).toEqual([1, false, false, "settled"]);
  end.resolve();
  await running;
  await turn();
  expect([shown, status, late, label]).toEqual([0, false, false, "settled"]);
});

for (const wrapped of [false, true])
  it(`an equal input replacement retains its owned children until publication (wrapped=${wrapped})`, async () => {
    const end = gate<void>();
    const [generation, setGeneration] = createSignal(0);
    const cleaned: number[] = [];
    let guess!: (value: number) => number;
    let shown = 0,
      childShown = 0;
    const dispose = root(() => {
      const input = createMemo(() => {
        const version = generation();
        onCleanup(() => {
          cleaned.push(version);
        });
        createRenderEffect(
          () => version,
          value => {
            childShown = value;
          }
        );
        return 0;
      });
      const [view, write] = createLayer(wrapped ? () => input() : input, { lifetime: "action" });
      guess = write;
      createRenderEffect(view, value => {
        shown = value;
      });
    });
    flush();
    const running = action(function* () {
      setGeneration(1);
      guess(1);
      yield end.promise;
    })();
    flush();
    expect([shown, childShown, cleaned]).toEqual([1, 0, []]);
    end.resolve();
    await running;
    await turn();
    expect([shown, childShown, cleaned]).toEqual([0, 1, [0]]);
    dispose();
    expect(cleaned).toEqual([0, 1]);
  });

for (const wrapped of [false, true])
  it(`starting a later request does not retire the guess before an answer exists (wrapped=${wrapped})`, async () => {
    const start = gate<void>(),
      answer = gate<number>(),
      end = gate<void>();
    const [id, setId] = createSignal(0);
    let guess!: (value: number) => number;
    let shown = 0,
      status = false;
    root(() => {
      const input = createMemo(() => (id() ? answer.promise : 0));
      const [view, write] = createLayer(wrapped ? () => input() : input, { lifetime: "action" });
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
      guess(1);
      yield start.promise;
      setId(1);
      yield end.promise;
    })();
    flush();
    expect([shown, status]).toEqual([1, false]);
    start.resolve();
    await turn();
    expect([shown, status]).toEqual([1, true]);
    answer.resolve(0);
    await turn();
    expect([shown, status]).toEqual([1, false]);
    end.resolve();
    await running;
    await turn();
    expect([shown, status]).toEqual([0, false]);
  });
