/** @vitest-environment jsdom */
import { afterEach, expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup,
  untrack
} from "../src/index.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  document.body.replaceChildren();
  flush();
});

for (const depth of [2, 5])
  for (const reverse of [false, true]) {
    it(`publishes nested overrides above suspended input in one action (depth=${depth}, reverse=${reverse})`, async () => {
      const end = gate<void>(),
        answer = gate<number>();
      const guesses: ((n: number) => number)[] = [],
        shown = Array<number>(depth).fill(-1);
      createRoot(dispose => {
        disposals.push(dispose);
        let input = createSignal(0)[0];
        for (let i = 0; i < depth; i++) {
          const [output, guess] = createOptimistic(input);
          guesses.push(guess);
          createRenderEffect(
            output,
            value => {
              shown[i] = value;
            },
            { schedule: true }
          );
          if (!i) {
            const slow = createMemo(() => (output() === 1 ? answer.promise : output()));
            createRenderEffect(slow, () => {}, { schedule: true });
          }
          input = createMemo(() => output() * 2);
        }
      });
      flush();
      const running = action(function* () {
        const indices = guesses.map((_, i) => i);
        if (reverse) indices.reverse();
        for (const i of indices) guesses[i](i + 1);
        yield end.promise;
      })();
      try {
        flush();
        expect(shown[0]).toBe(0);
        expect(shown.at(-1)).toBe(depth);
      } finally {
        answer.resolve(1);
        end.resolve();
        await running;
        await turn();
        flush();
      }
    });
  }

for (const reverse of [false, true])
  for (const asynchronous of [false, true])
    for (const tracked of [true, false]) {
      it(`restarts before a completed body sees mixed input versions (reverse=${reverse}, async=${asynchronous})${tracked ? "" : " (untracked override)"}`, async () => {
        const end = gate<void>(),
          requests: { key: string; resolve(value: string): void }[] = [];
        const bodies: number[][] = [],
          owners: { cleaned: number }[] = [];
        let setX!: (n: number) => number, guess!: (n: number) => number, rerun!: () => void;
        const display = document.createElement("span");
        document.body.append(display);
        createRoot(dispose => {
          disposals.push(dispose);
          const [x, writeX] = createSignal(0),
            [view, writeView] = createOptimistic(() => 0);
          const [revision, setRevision] = createSignal(0);
          rerun = () => setRevision(n => n + 1);
          setX = writeX;
          guess = writeView;
          const calculate = () => {
            revision();
            const owner = { cleaned: 0 };
            owners.push(owner);
            onCleanup(() => owner.cleaned++);
            let a: number, b: number;
            if (reverse) {
              b = tracked ? view() : untrack(view);
              a = x();
            } else {
              a = x();
              b = tracked ? view() : untrack(view);
            }
            bodies.push([a, b, x()]);
            if (!a && !b) return "0:0";
            const request = gate<string>();
            requests.push({ key: `${a}:${b}`, resolve: request.resolve });
            return request.promise;
          };
          const result = createMemo(asynchronous ? async () => calculate() : calculate);
          createRenderEffect(
            result,
            value => {
              display.textContent = value;
            },
            { schedule: true }
          );
        });
        await turn();
        flush();
        const running = action(function* () {
          setX(1);
          guess(10);
          yield end.promise;
        })();
        flush();
        // An untracked snapshot is not notified by the guess. Ask again
        // after the output has published, while the lower input stays held.
        if (!tracked) {
          rerun();
          flush();
        }
        try {
          for (const request of requests) request.resolve(request.key);
          await turn();
          flush();
          expect(display.textContent).toBe("0:10");
          expect(bodies.every(([a, , again]) => a === again)).toBe(true);
          expect(requests.some(request => request.key === "1:10")).toBe(false);
        } finally {
          end.resolve();
          await running;
          for (let i = 0; i < 4; i++) {
            for (const request of requests) request.resolve(request.key);
            await turn();
            flush();
          }
          for (const dispose of disposals.splice(0)) dispose();
          flush();
        }
        expect(owners.every(owner => owner.cleaned === 1)).toBe(true);
      });
    }

it("hidden input discovery preserves the already selected peer request", async () => {
  const enabledGate = gate<boolean>(),
    deepGate = gate<number>(),
    peerGate = gate<number>(),
    end = gate<void>();
  const inputs: { value: number; resolve(value: number): void }[] = [];
  const requests: { key: string; resolve(value: string): void }[] = [];
  const actions: Promise<unknown>[] = [];
  const shown = { view: 0, peer: 0, pair: "0:0", label: "0:0" };
  let guessFirst!: (n: number) => number,
    guessDeep!: (n: number) => number,
    guessPeer!: (n: number) => number,
    guessView!: (n: number) => number,
    setTrigger!: (n: boolean) => boolean;
  createRoot(dispose => {
    disposals.push(dispose);
    const [base] = createSignal(0),
      [trigger, changeTrigger] = createSignal(false);
    const [first, writeFirst] = createOptimistic(base),
      [deep, writeDeep] = createOptimistic(first);
    const [peer, writePeer] = createOptimistic(base);
    const enabled = createMemo(() => (trigger() ? enabledGate.promise : false));
    const input = createMemo(() => {
      const value = enabled() ? deep() : 0;
      const request = gate<number>();
      inputs.push({ value, resolve: request.resolve });
      return request.promise;
    });
    const [view, writeView] = createOptimistic(input);
    const holdDeep = createMemo(() => (deep() === 2 ? deepGate.promise : deep()));
    const holdPeer = createMemo(() => (peer() === 20 ? peerGate.promise : peer()));
    const pair = createMemo(() => [view(), peer()]);
    const label = createMemo(() => {
      const key = pair().join(":");
      if (key === "0:0") return key;
      const request = gate<string>();
      requests.push({ key, resolve: request.resolve });
      return request.promise;
    });
    for (const read of [first, deep, peer, input, view, holdDeep, holdPeer, pair, label])
      createRenderEffect<unknown>(read, () => {}, { schedule: true });
    createRenderEffect(
      view,
      value => {
        shown.view = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      peer,
      value => {
        shown.peer = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      pair,
      value => {
        shown.pair = value.join(":");
      },
      { schedule: true }
    );
    createRenderEffect(
      label,
      value => {
        shown.label = value;
      },
      { schedule: true }
    );
    [guessFirst, guessDeep, guessPeer, guessView, setTrigger] = [
      writeFirst,
      writeDeep,
      writePeer,
      writeView,
      changeTrigger
    ];
  });
  inputs[0].resolve(0);
  await turn();
  flush();
  const start = <T>(write: (value: T) => unknown, value: T) => {
    actions.push(
      action(function* () {
        write(value);
        yield end.promise;
      })()
    );
    flush();
  };
  try {
    start(guessFirst, 1);
    start(guessDeep, 2);
    start(guessPeer, 20);
    start(setTrigger, true);
    start(guessView, 10);
    const before = requests.map(request => request.key);
    expect(before.at(-1)).toBe("10:20");
    enabledGate.resolve(true);
    await turn();
    flush();
    expect(requests.slice(before.length).every(request => request.key === "10:20")).toBe(true);
    expect(shown).toEqual({ view: 0, peer: 0, pair: "0:0", label: "0:0" });
    for (const request of requests) request.resolve(request.key);
    peerGate.resolve(20);
    await turn();
    flush();
    expect(shown).toEqual({ view: 10, peer: 20, pair: "10:20", label: "10:20" });
  } finally {
    for (const dispose of disposals.splice(0)) dispose();
    end.resolve();
    await Promise.all(actions);
    await turn();
    flush();
  }
});

it("mounting an ordinary reader during unrelated optimism does not start a stale request", async () => {
  const end = gate<void>();
  const [x, setX] = createSignal(0);
  const requests: number[] = [];
  let guess!: (value: number) => number;
  createRoot(dispose => {
    disposals.push(dispose);
    const [view, write] = createOptimistic(() => 0);
    guess = write;
    createRenderEffect(view, () => {}, { schedule: true });
  });
  const running = action(function* () {
    guess(10);
    setX(1);
    yield end.promise;
  })();
  flush();
  try {
    createRoot(dispose => {
      disposals.push(dispose);
      const result = createMemo(() => {
        const value = x();
        requests.push(value);
        return Promise.resolve(value);
      });
      createRenderEffect(result, () => {}, { schedule: true });
    });
    flush();
    expect(requests).toEqual([1]);
  } finally {
    for (const dispose of disposals.splice(0)) dispose();
    end.resolve();
    await running;
    await turn();
    flush();
  }
});

for (const late of [false, true])
  it(`a new reader does not lower an existing optimistic update's context (late=${late})`, async () => {
    const answer = gate<number>(),
      guessEnd = gate<void>(),
      ordinaryEnd = gate<void>();
    const [ordinary, setOrdinary] = createSignal(0);
    let view!: () => number, guess!: (value: number) => unknown;
    const shown = { view: 0, detail: 0, pair: "0:0", late: null as number | null };
    createRoot(dispose => {
      disposals.push(dispose);
      [view, guess] = createOptimistic(() => 0);
      const detail = createMemo(() => (view() ? answer.promise : 0));
      const pair = createMemo(() => `${view()}:${ordinary()}`);
      for (const [key, read] of Object.entries({ view, detail, pair }))
        createRenderEffect<unknown>(
          read,
          value => {
            (shown as any)[key] = value;
          },
          { schedule: true }
        );
    });
    flush();
    const guessing = action(function* () {
      guess(1);
      yield guessEnd.promise;
    })();
    flush();
    if (late) {
      createRoot(dispose => {
        disposals.push(dispose);
        const reader = createMemo(() => view());
        createRenderEffect(
          reader,
          value => {
            shown.late = value;
          },
          { schedule: true }
        );
      });
      flush();
    }
    const changing = action(function* () {
      setOrdinary(1);
      yield ordinaryEnd.promise;
    })();
    flush();
    answer.resolve(1);
    await turn();
    flush();
    expect([shown.view, shown.detail, shown.pair]).toEqual([1, 1, "1:0"]);
    if (late) expect(shown.late).toBe(1);
    ordinaryEnd.resolve();
    await changing;
    await turn();
    flush();
    expect(shown.pair).toBe("1:1");
    for (const dispose of disposals.splice(0)) dispose();
    guessEnd.resolve();
    await guessing;
    await turn();
    flush();
  });

for (const depth of [0, 2])
  for (const reverse of [false, true])
    for (const late of [false, true])
      it(`late readers preserve distinct pending depths (reverse=${reverse}, late=${late}, depth=${depth})`, async () => {
        const lowerWork = gate<number>(),
          upperWork = gate<number>();
        const lowerEnd = gate<void>(),
          upperEnd = gate<void>();
        let first!: () => number, second!: () => number;
        let guessFirst!: (value: number) => unknown, guessSecond!: (value: number) => unknown;
        const shown = { first: 0, second: 0, detail: 0, late: "" };
        createRoot(dispose => {
          disposals.push(dispose);
          [first, guessFirst] = createOptimistic(() => 0);
          const input = createMemo(() => (first() ? lowerWork.promise : 0));
          [second, guessSecond] = createOptimistic(input);
          const detail = createMemo(() => (second() ? upperWork.promise : 0));
          for (const [key, read] of Object.entries({ first, second, detail }))
            createRenderEffect<unknown>(
              read,
              value => {
                (shown as any)[key] = value;
              },
              { schedule: true }
            );
        });
        flush();
        const lower = action(function* () {
          guessFirst(1);
          yield lowerEnd.promise;
        })();
        flush();
        const upper = action(function* () {
          guessSecond(10);
          yield upperEnd.promise;
        })();
        flush();
        if (late) {
          createRoot(dispose => {
            disposals.push(dispose);
            const nested = (read: () => number, remaining: number): number =>
              remaining ? createMemo(() => nested(read, remaining - 1))() : read();
            const pair = createMemo(() => {
              if (reverse) {
                const b = nested(second, depth);
                return `${nested(first, depth)}:${b}`;
              }
              const a = nested(first, depth);
              return `${a}:${nested(second, depth)}`;
            });
            createRenderEffect(
              pair,
              value => {
                shown.late = value;
              },
              { schedule: true }
            );
          });
          flush();
        }
        upperWork.resolve(10);
        await turn();
        flush();
        // The selected upper override releases the lower input hold.
        expect([shown.first, shown.second, shown.detail]).toEqual([1, 10, 10]);
        if (late) expect(shown.late).toBe("1:10");
        for (const dispose of disposals.splice(0)) dispose();
        lowerWork.resolve(1);
        lowerEnd.resolve();
        upperEnd.resolve();
        await Promise.all([lower, upper]);
        await turn();
        flush();
      });
