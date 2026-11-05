import { afterEach, describe, expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup,
  resetErrorHalt
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  let reject!: (error: unknown) => void;
  const promise = new Promise<T>((yes, no) => {
    resolve = yes;
    reject = no;
  });
  return { promise, resolve, reject };
}
// Let promise settlement and the engine's scheduled flush finish. Gates,
// rather than elapsed time, decide which calculation may finish.
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
function root(fn: () => void) {
  createRoot(dispose => {
    disposals.push(dispose);
    fn();
  });
}
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  resetErrorHalt();
});

describe("shared scalar update experiment", () => {
  it("a boundary whose input and output share an update cannot exempt that update", () => {
    const [source, setSource] = createSignal(0);
    let guess!: (value: number) => number, clear!: () => void;
    let shown = 0;
    let pair: readonly number[] = [0, 0, 0];
    root(() => {
      const [a, write] = createLayer(source);
      guess = write;
      const [b, , release] = createLayer(() => a() * 2);
      clear = release;
      const derived = createMemo(() => (b() ? new Promise<number>(() => {}) : 0));
      createRenderEffect(a, value => {
        shown = value;
      });
      createRenderEffect(
        () => [a(), b(), derived()],
        value => {
          pair = value;
        }
      );
    });
    guess(3);
    flush();
    setSource(3);
    flush();
    clear();
    flush();
    expect([shown, pair]).toEqual([0, [0, 0, 0]]);
  });

  for (const optimistic of [false, true]) {
    it(`${optimistic ? "layer" : "ordinary"}: repeated proposal, unrelated rerun and late mount`, async () => {
      const flights = new Map<number, ReturnType<typeof gate<number>>>();
      const [tick, setTick] = createSignal(0);
      let value!: () => number, write!: (v: number) => number;
      let a: readonly number[] = [],
        b: readonly number[] = [],
        late: number[] = [];
      root(() => {
        [value, write] = optimistic ? createLayer(() => 0) : createSignal(0);
        const derived = createMemo(() => {
          const n = value();
          if (!n) return n;
          const flight = gate<number>();
          flights.set(n, flight);
          return flight.promise;
        });
        createRenderEffect(
          () => [tick(), value()],
          v => {
            a = v;
          }
        );
        createRenderEffect(
          () => [value(), derived()],
          v => {
            b = v;
          }
        );
      });
      flush();
      expect([a, b]).toEqual([
        [0, 0],
        [0, 0]
      ]);
      write(1);
      flush();
      expect([a, b]).toEqual([
        [0, 0],
        [0, 0]
      ]);
      flights.get(1)!.resolve(1);
      await turn();
      expect([a, b]).toEqual([
        [0, 1],
        [1, 1]
      ]);
      write(2);
      flush();
      setTick(1);
      flush();
      root(() =>
        createRenderEffect(value, v => {
          late.push(v);
        })
      );
      flush();
      expect([a, b, late]).toEqual([[1, 1], [1, 1], [1]]);
      flights.get(2)!.resolve(2);
      await turn();
      expect([a, b, late]).toEqual([
        [1, 2],
        [2, 2],
        [1, 2]
      ]);
    });
  }

  it("an override publishes while its input action stays open", async () => {
    const wait = gate<void>();
    const [source, setSource] = createSignal(0);
    let propose!: (value: number) => number, clear!: () => void;
    let shown: readonly number[] = [];
    root(() => {
      const [view, guess, release] = createLayer(source);
      propose = guess;
      clear = release;
      const combined = createMemo(() => [source(), view()]);
      createRenderEffect(combined, v => {
        shown = v;
      });
    });
    const running = action(function* () {
      setSource(10);
      yield wait.promise;
    })();
    flush();
    propose(1);
    flush();
    expect(shown).toEqual([0, 1]);
    wait.resolve();
    await running;
    await turn();
    expect(shown).toEqual([10, 1]);
    clear();
    flush();
    expect(shown).toEqual([10, 10]);
  });

  it("three nested boundaries have independent overrides", async () => {
    const [source, setSource] = createSignal(0);
    let first!: (v: number) => number,
      second!: (v: number) => number,
      third!: (v: number) => number,
      release!: () => void;
    let shown: readonly number[] = [];
    root(() => {
      const [a, ga] = createLayer(source);
      const doubled = createMemo(() => a() * 2);
      const [b, gb] = createLayer(doubled);
      const [c, gc, clear] = createLayer(() => b() * 2);
      first = ga;
      second = gb;
      third = gc;
      release = clear;
      createRenderEffect(
        () => [a(), b(), c()],
        v => {
          shown = v;
        }
      );
    });
    first(1);
    flush();
    expect(shown).toEqual([1, 2, 4]);
    second(5);
    flush();
    expect(shown).toEqual([1, 5, 10]);
    third(20);
    flush();
    expect(shown).toEqual([1, 5, 20]);
    setSource(9);
    flush();
    expect(shown).toEqual([1, 5, 20]);
    release();
    flush();
    expect(shown).toEqual([1, 5, 10]);
  });

  it("a sibling join waits for its async result", async () => {
    const wait = gate<number>();
    let left!: (v: number) => number, right!: (v: number) => number;
    let shown: readonly number[] = [];
    root(() => {
      const [a, ga] = createLayer(() => 0),
        [b, gb] = createLayer(() => 0);
      left = ga;
      right = gb;
      const sum = createMemo(() => (a() + b() ? wait.promise : 0));
      createRenderEffect(
        () => [a(), b(), sum()],
        v => {
          shown = v;
        }
      );
    });
    left(1);
    right(2);
    flush();
    expect(shown).toEqual([0, 0, 0]);
    wait.resolve(3);
    await turn();
    expect(shown).toEqual([1, 2, 3]);
  });

  it("superseded async results never publish", async () => {
    const flights = new Map<number, ReturnType<typeof gate<number>>>();
    let guess!: (v: number) => number;
    const frames: (readonly number[])[] = [];
    root(() => {
      const [view, propose] = createLayer(() => 0);
      guess = propose;
      const derived = createMemo(() => {
        const n = view();
        if (!n) return n;
        const g = gate<number>();
        flights.set(n, g);
        return g.promise;
      });
      createRenderEffect(
        () => [view(), derived()],
        v => {
          frames.push(v);
        }
      );
    });
    guess(1);
    flush();
    guess(2);
    flush();
    flights.get(1)!.resolve(1);
    await turn();
    expect(frames).toEqual([[0, 0]]);
    flights.get(2)!.resolve(2);
    await turn();
    expect(frames).toEqual([
      [0, 0],
      [2, 2]
    ]);
  });

  it("an equal-valued replacement retires children at publication", async () => {
    const wait = gate<void>();
    let guess!: (v: number) => number;
    const cleanup: number[] = [],
      frames: (readonly number[])[] = [];
    root(() => {
      const [view, propose] = createLayer(() => 0);
      guess = propose;
      const owned = createMemo(() => {
        const n = view();
        onCleanup(() => cleanup.push(n));
        return 7;
      });
      const delayed = createMemo(() => (view() ? wait.promise.then(() => 1) : 0));
      createRenderEffect(
        () => [view(), owned(), delayed()],
        v => {
          frames.push(v);
        }
      );
    });
    guess(1);
    flush();
    expect(cleanup).toEqual([]);
    expect(frames).toEqual([[0, 7, 0]]);
    wait.resolve();
    await turn();
    expect(cleanup).toEqual([0]);
    expect(frames).toEqual([
      [0, 7, 0],
      [1, 7, 1]
    ]);
  });

  it("expiration supersedes a suspended override with a coherent input frame", async () => {
    const wait = gate<number>();
    let guess!: (v: number) => number, clear!: () => void;
    const frames: (readonly number[])[] = [];
    root(() => {
      const [view, propose, release] = createLayer(() => 0);
      guess = propose;
      clear = release;
      const derived = createMemo(() => (view() === 2 ? wait.promise : view()));
      createRenderEffect(
        () => [view(), derived()],
        v => {
          frames.push(v);
        }
      );
    });
    guess(1);
    flush();
    guess(2);
    flush();
    expect(frames).toEqual([
      [0, 0],
      [1, 1]
    ]);
    clear();
    flush();
    expect(frames).toEqual([
      [0, 0],
      [1, 1],
      [0, 0]
    ]);
    wait.resolve(2);
    await turn();
    expect(frames).toEqual([
      [0, 0],
      [1, 1],
      [0, 0]
    ]);
  });

  it("a lower update completing during an upper hold preserves the upper display", async () => {
    const lower = gate<void>(),
      upper = gate<number>();
    const [source, setSource] = createSignal(0);
    let guess!: (v: number) => number;
    let sourceShown = 0;
    const frames: (readonly number[])[] = [];
    root(() => {
      const [view, propose] = createLayer(source);
      guess = propose;
      const derived = createMemo(() => (view() === 2 ? upper.promise : view()));
      createRenderEffect(source, v => {
        sourceShown = v;
      });
      createRenderEffect(
        () => [view(), derived()],
        v => {
          frames.push(v);
        }
      );
    });
    const running = action(function* () {
      setSource(10);
      yield lower.promise;
    })();
    flush();
    guess(1);
    flush();
    guess(2);
    flush();
    lower.resolve();
    await running;
    await turn();
    expect(sourceShown).toBe(10);
    expect(frames).toEqual([
      [0, 0],
      [1, 1]
    ]);
    upper.resolve(2);
    await turn();
    expect(frames).toEqual([
      [0, 0],
      [1, 1],
      [2, 2]
    ]);
  });

  it("a nested override can publish while its parent's proposal is suspended", async () => {
    const wait = gate<number>();
    let first!: (v: number) => number, second!: (v: number) => number;
    let aShown = 0,
      bShown = 0;
    root(() => {
      const [a, ga] = createLayer(() => 0);
      first = ga;
      const slow = createMemo(() => (a() ? wait.promise : 0));
      const [b, gb] = createLayer(slow);
      second = gb;
      createRenderEffect(
        () => [a(), slow()],
        v => {
          aShown = v[0];
        }
      );
      createRenderEffect(b, v => {
        bShown = v;
      });
    });
    first(1);
    flush();
    second(9);
    flush();
    expect([aShown, bShown]).toEqual([0, 9]);
    wait.resolve(1);
    await turn();
    expect([aShown, bShown]).toEqual([1, 9]);
  });

  it("errors and recovery use the ordinary boundary path", async () => {
    const wait = gate<number>();
    let guess!: (v: number) => number, reset!: () => void;
    const frames: (readonly number[] | string)[] = [];
    root(() => {
      const [view, propose] = createLayer(() => 0);
      guess = propose;
      const derived = createMemo(() => (view() === 1 ? wait.promise : view()));
      const boundary = createErrorBoundary(
        () => {
          createRenderEffect(
            () => [view(), derived()],
            v => {
              frames.push(v);
            }
          );
        },
        (_, retry) => {
          reset = retry;
          return "error";
        }
      );
      createRenderEffect(boundary, v => {
        if (v) frames.push(v);
      });
    });
    guess(1);
    flush();
    wait.reject(new Error("failed"));
    await turn();
    expect(frames.at(-1)).toBe("error");
    guess(2);
    flush();
    reset();
    flush();
    expect(frames.at(-1)).toEqual([2, 2]);
  });

  it("100 repeated nested updates dispose every replaced child", () => {
    let guess!: (v: number) => number;
    let created = 0,
      cleaned = 0;
    root(() => {
      const [a, ga] = createLayer(() => 0);
      guess = ga;
      const [b] = createLayer(() => a() * 2);
      const owned = createMemo(() => {
        const value = b();
        created++;
        onCleanup(() => {
          cleaned++;
        });
        createMemo(() => value);
        return value;
      });
      createRenderEffect(owned, () => {});
    });
    for (let i = 1; i <= 100; i++) {
      guess(i);
      flush();
    }
    expect(created).toBe(101);
    expect(cleaned).toBe(100);
    disposals.pop()!();
    expect(cleaned).toBe(created);
  });

  for (const reverse of [false, true]) {
    it(`sibling overrides exclude both pending input updates (order ${reverse})`, async () => {
      const aGate = gate<void>(),
        bGate = gate<void>();
      const [a, setA] = createSignal(0),
        [b, setB] = createSignal(0);
      let guessA!: (v: number) => number, guessB!: (v: number) => number;
      let shown: readonly number[] = [];
      root(() => {
        const [av, ga] = createLayer(a),
          [bv, gb] = createLayer(b);
        guessA = ga;
        guessB = gb;
        const combined = createMemo(() => [a(), b(), av(), bv()]);
        createRenderEffect(combined, v => {
          shown = v;
        });
      });
      const first = action(function* () {
        setA(10);
        yield aGate.promise;
      })();
      flush();
      const second = action(function* () {
        setB(20);
        yield bGate.promise;
      })();
      flush();
      if (reverse) {
        guessB(2);
        guessA(1);
      } else {
        guessA(1);
        guessB(2);
      }
      flush();
      expect(shown).toEqual([0, 0, 1, 2]);
      aGate.resolve();
      bGate.resolve();
      await Promise.all([first, second]);
      await turn();
      expect(shown).toEqual([10, 20, 1, 2]);
    });
  }

  it("a pending parent does not lend its read posture to a separately shared memo", async () => {
    const wait = gate<void>();
    const [source, setSource] = createSignal(0);
    let guess!: (v: number) => number;
    let sharedShown = 0,
      layerShown: readonly number[] = [];
    root(() => {
      const shared = createMemo(() => source() * 10);
      const [view, propose] = createLayer(source);
      guess = propose;
      const combined = createMemo(() => [view(), shared()]);
      createRenderEffect(shared, v => {
        sharedShown = v;
      });
      createRenderEffect(combined, v => {
        layerShown = v;
      });
    });
    const running = action(function* () {
      setSource(1);
      yield wait.promise;
    })();
    flush();
    guess(9);
    flush();
    expect([sharedShown, layerShown]).toEqual([0, [9, 0]]);
    wait.resolve();
    await running;
    await turn();
    expect([sharedShown, layerShown]).toEqual([10, [9, 10]]);
  });

  it("sibling proposals preserve exclusions when two independent parents merge", async () => {
    const aGate = gate<void>(),
      bGate = gate<void>();
    const [a, setA] = createSignal(0),
      [b, setB] = createSignal(0);
    let ga!: (v: number) => number, gb!: (v: number) => number;
    let shown: readonly number[] = [];
    root(() => {
      const [av, guessA] = createLayer(a),
        [bv, guessB] = createLayer(b);
      ga = guessA;
      gb = guessB;
      const combined = createMemo(() =>
        av() === 2 && bv() === 2 ? [av(), bv(), a(), b()] : [av(), bv()]
      );
      createRenderEffect(combined, v => {
        shown = v;
      });
    });
    ga(1);
    gb(1);
    flush();
    const first = action(function* () {
      setA(10);
      yield aGate.promise;
    })();
    flush();
    const second = action(function* () {
      setB(20);
      yield bGate.promise;
    })();
    flush();
    ga(2);
    gb(2);
    flush();
    expect(shown).toEqual([2, 2, 0, 0]);
    aGate.resolve();
    bGate.resolve();
    await Promise.all([first, second]);
    await turn();
    expect(shown).toEqual([2, 2, 10, 20]);
  });

  it("seeded publication timelines stay coherent through supersession and nested expiration", async () => {
    const replay = process.env.LAYER_REPLAY?.split(" ").map(op => op.split(":").map(Number));
    for (let seed = 1; seed <= (replay ? 1 : Number(process.env.LAYER_SEEDS || 30)); seed++) {
      let state = seed;
      const random = () => (state = (Math.imul(state, 1664525) + 1013904223) >>> 0);
      const flights: { resolve: (v: number) => void; value: number }[] = [];
      const [source, setSource] = createSignal(0),
        [tick, setTick] = createSignal(0);
      let ga!: (v: number) => number, gb!: (v: number) => number, ca!: () => void, cb!: () => void;
      let aShown = 0,
        bShown = 0,
        coupled: readonly number[] = [0, 0, 0];
      const late: number[] = [];
      let av!: () => number, bv!: () => number;
      root(() => {
        [av, ga, ca] = createLayer(source);
        [bv, gb, cb] = createLayer(() => av() * 2);
        const derived = createMemo(() => {
          const value = bv();
          if (!value) return value;
          return new Promise<number>(resolve => flights.push({ resolve, value: value * 10 }));
        });
        createRenderEffect(
          () => [tick(), av()],
          v => {
            aShown = v[1];
          }
        );
        createRenderEffect(
          () => [tick(), bv()],
          v => {
            bShown = v[1];
          }
        );
        createRenderEffect(
          () => [av(), bv(), derived()],
          v => {
            coupled = v;
          }
        );
      });
      const operations: string[] = [];
      for (let step = 0; step < (replay?.length ?? 60); step++) {
        const [op, value] = replay?.[step] ?? [(random() >>> 16) % 8, (random() >>> 16) % 5];
        operations.push(`${op}:${value}`);
        switch (op) {
          case 0:
            ga(value);
            break;
          case 1:
            gb(value);
            break;
          case 2:
            ca();
            break;
          case 3:
            cb();
            break;
          case 4:
            setSource(value);
            break;
          case 5:
            setTick(step);
            break;
          case 6: {
            const flight = flights.splice(value % Math.max(1, flights.length), 1)[0];
            flight?.resolve(flight.value);
            break;
          }
          case 7:
            root(() =>
              createRenderEffect(bv, v => {
                late[0] = v;
              })
            );
            break;
        }
        flush();
        await turn();
        const why = `seed=${seed}, step=${step}, ops=${operations.join(" ")}`;
        expect(coupled, why).toEqual([aShown, bShown, bShown * 10]);
        if (late.length) expect(late[0], why).toBe(bShown);
      }
      // Close the finite timeline and release all roots, even when obsolete
      // promises remain unresolved. Their late answers must have no observer.
      for (const dispose of disposals.splice(0)) dispose();
      for (const flight of flights) flight.resolve(flight.value);
      await turn();
    }
  });

  it("moving an equal proposal keeps the render work it still owes", async () => {
    const flight = gate<number>();
    let guess!: (v: number) => number, clear!: () => void;
    let plain = 0,
      coupled: readonly number[] = [0, 0];
    root(() => {
      const [a, ga] = createLayer(() => 0);
      guess = ga;
      const [b, , cb] = createLayer(() => a() * 2);
      clear = cb;
      const derived = createMemo(() => (b() ? flight.promise : 0));
      createRenderEffect(b, v => {
        plain = v;
      });
      createRenderEffect(
        () => [b(), derived()],
        v => {
          coupled = v;
        }
      );
    });
    guess(2);
    flush();
    clear();
    flush();
    flight.resolve(40);
    await turn();
    expect([plain, coupled]).toEqual([4, [4, 40]]);
  });

  it("taking over a pending input's consequences does not publish a suspended guess", () => {
    const [source, setSource] = createSignal(0);
    let guess!: (v: number) => number;
    let plain = 0,
      coupled: readonly number[] = [0, 0, 0];
    root(() => {
      const [a] = createLayer(source);
      const [b, gb] = createLayer(() => a() * 2);
      guess = gb;
      const derived = createMemo(() => (b() ? new Promise<number>(() => {}) : 0));
      createRenderEffect(b, v => {
        plain = v;
      });
      createRenderEffect(
        () => [a(), b(), derived()],
        v => {
          coupled = v;
        }
      );
    });
    setSource(3);
    flush();
    expect([plain, coupled]).toEqual([0, [0, 0, 0]]);
    guess(2);
    flush();
    expect([plain, coupled]).toEqual([0, [3, 0, 0]]);
  });

  for (const rerun of [false, true])
    it(`an equal override takes its own update after input joined a child (rerun ${rerun})`, () => {
      const [source, setSource] = createSignal(0);
      const [tick, setTick] = createSignal(0);
      let ga!: (v: number) => number, gb!: (v: number) => number;
      let plain = 0,
        coupled: readonly number[] = [0, 0, 0];
      root(() => {
        const [a, first] = createLayer(source);
        ga = first;
        const [b, second] = createLayer(() => a() * 2);
        gb = second;
        const derived = createMemo(() => (b() ? new Promise<number>(() => {}) : 0));
        createRenderEffect(
          () => [tick(), a()],
          v => {
            plain = v[1];
          }
        );
        createRenderEffect(
          () => [a(), b(), derived()],
          v => {
            coupled = v;
          }
        );
      });
      gb(2);
      flush();
      setSource(4);
      flush();
      if (rerun) {
        setTick(1);
        flush();
      }
      ga(4);
      flush();
      expect([plain, coupled]).toEqual([4, [4, 0, 0]]);
    });
});
