import { afterEach, describe, expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup,
  resetErrorHalt
} from "../src/index.js";
import { createPending as createPendingBoundary, isPending } from "../src/layers/pending.js";
const createPending =
  process.env.PENDING_API === "shared"
    ? <T>(input: () => T) => createMemo(() => isPending(input))
    : createPendingBoundary;

function gate<T>() {
  let resolve!: (value: T) => void;
  let reject!: (error: unknown) => void;
  const promise = new Promise<T>((r, fail) => {
    resolve = r;
    reject = fail;
  });
  return { promise, resolve, reject };
}
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
  flush();
  resetErrorHalt();
});

describe("pending observations use ordinary output publication", () => {
  it("a transitive observation dependency can disappear without reusing a stale cached exemption", async () => {
    const end = gate<void>();
    const [x, setX] = createSignal(0),
      [observe, setObserve] = createSignal(true),
      [tick, setTick] = createSignal(0);
    let shown: readonly [boolean, number] = [false, 0];
    root(() => {
      const pending = createPending(x);
      const status = createMemo(() => (observe() ? pending() : false));
      const pair = createMemo(() => {
        tick();
        return [status(), x()] as const;
      });
      createRenderEffect(pair, value => {
        shown = value;
      });
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual([true, 0]);
    for (let i = 1; i <= 4; i++) {
      setTick(i);
      flush();
      expect(shown).toEqual([true, 0]);
    }
    setObserve(false);
    flush();
    expect(shown).toEqual([true, 0]);
    end.resolve();
    await running;
    await turn();
    expect(shown).toEqual([false, 1]);
  });

  it("direct observation preserves the input memo's own disposal and revival behavior", () => {
    const [x, setX] = createSignal(0);
    let cleaned = 0,
      runs = 0,
      input!: () => number,
      release!: () => void;
    root(() => {
      input = createMemo(
        () => {
          runs++;
          onCleanup(() => {
            cleaned++;
          });
          return x();
        },
        { lazy: true }
      );
      createRoot(dispose => {
        release = dispose;
        const pending = createPending(input);
        createRenderEffect(pending, () => {});
      });
    });
    flush();
    expect(runs).toBe(1);
    release();
    flush();
    expect(cleaned).toBe(1);
    setX(2);
    flush();
    expect(runs).toBe(1);
    expect(input()).toBe(2);
    expect(runs).toBe(2);
  });

  it("leaving a suspended observation cannot let its input publish ahead of new async work", async () => {
    const end = gate<void>(),
      pendingLabel = gate<string>(),
      oldLabel = gate<string>(),
      newLabel = gate<string>();
    const [x, setX] = createSignal(0),
      [observe, setObserve] = createSignal(true);
    let value = 0,
      observing = true,
      status = false,
      shown = "false:0";
    root(() => {
      const pending = createPending(x);
      const text = createMemo(() => {
        const watches = observe(),
          n = x();
        if (watches) return pending() ? pendingLabel.promise : `false:${n}`;
        return n ? newLabel.promise : oldLabel.promise;
      });
      createRenderEffect(x, v => {
        value = v;
      });
      createRenderEffect(observe, v => {
        observing = v;
      });
      createRenderEffect(pending, v => {
        status = v;
      });
      createRenderEffect(text, v => {
        shown = v;
      });
    });
    const consistent = () =>
      expect(shown).toBe(observing ? `${status}:${value}` : `plain:${value}`);
    flush();
    const running = action(function* () {
      setX(3);
      yield end.promise;
    })();
    flush();
    setObserve(false);
    flush();
    consistent();
    oldLabel.resolve("plain:0");
    await turn();
    consistent();
    end.resolve();
    await running;
    await turn();
    expect(value).toBe(0);
    consistent();
    pendingLabel.resolve("true:0");
    await turn();
    expect(value).toBe(0);
    consistent();
    newLabel.resolve("plain:3");
    await turn();
    expect([value, observing, status, shown]).toEqual([3, false, false, "plain:3"]);
  });

  it("branch switches preserve observable coherence across pending observations and superseded async", async () => {
    for (let seed = 1; seed <= Number(process.env.BRANCH_SEEDS || 20); seed++) {
      let randomState = seed;
      const random = () =>
        (randomState = (Math.imul(randomState, 1664525) + 1013904223) >>> 0) >>> 16;
      const [x, setX] = createSignal(0),
        [observe, setObserve] = createSignal(true),
        [tick, setTick] = createSignal(0);
      let xShown = 0,
        observing = true,
        status = false,
        shown = "false:0",
        lastX = 0,
        lastObserve = true;
      const actions: { end: ReturnType<typeof gate<void>>; running: Promise<void> }[] = [];
      const flights: { resolve: (value: string) => void; value: string }[] = [];
      root(() => {
        const pending = createPending(x);
        const text = createMemo(() => {
          const watches = observe(),
            value = x();
          const label = watches ? `${pending()}:${value}` : `plain:${value}`;
          if (label === "false:0") return label;
          return new Promise<string>(resolve => {
            flights.push({ resolve, value: label });
          });
        });
        createRenderEffect(
          () => [tick(), x()] as const,
          value => {
            xShown = value[1];
          }
        );
        createRenderEffect(observe, value => {
          observing = value;
        });
        createRenderEffect(pending, value => {
          status = value;
        });
        createRenderEffect(text, value => {
          shown = value;
        });
      });
      flush();
      const ops: string[] = [];
      const replay = process.env.BRANCH_REPLAY?.split(" ").map(op => op.split(":").map(Number));
      for (let step = 0; step < (replay?.length ?? 40); step++) {
        const [op, value] = replay?.[step] ?? [random() % 5, random() % 4];
        ops.push(`${op}:${value}`);
        if (op === 0) {
          const end = gate<void>();
          const running = action(function* () {
            setX(value);
            yield end.promise;
          })();
          lastX = value;
          actions.push({ end, running });
        } else if (op === 1) {
          lastObserve = !!(value % 2);
          setObserve(lastObserve);
        } else if (op === 2 && actions.length) {
          const entry = actions.splice(value % actions.length, 1)[0];
          entry.end.resolve();
          await entry.running;
        } else if (op === 3 && flights.length) {
          const flight = flights.splice(value % flights.length, 1)[0];
          flight.resolve(flight.value);
        } else if (op === 4) setTick(step);
        flush();
        await turn();
        expect(shown, `seed=${seed}, ops=${ops.join(" ")}`).toBe(
          observing ? `${status}:${xShown}` : `plain:${xShown}`
        );
      }
      for (const entry of actions) entry.end.resolve();
      await Promise.all(actions.map(entry => entry.running));
      for (let round = 0; round < 6; round++) {
        for (const flight of flights.splice(0)) flight.resolve(flight.value);
        await turn();
      }
      expect([xShown, observing, status, shown], `seed=${seed}, ops=${ops.join(" ")}`).toEqual([
        lastX,
        lastObserve,
        false,
        lastObserve ? `false:${lastX}` : `plain:${lastX}`
      ]);
      for (const dispose of disposals.splice(0)) dispose();
      if (replay) break;
    }
  });

  for (const inputFirst of [false, true]) {
    it(`a late composite reader sees the published observation and input (input first ${inputFirst})`, async () => {
      const end = gate<void>();
      const [x, setX] = createSignal(0);
      let pending!: () => boolean;
      let shown: readonly [boolean, number] | undefined;
      root(() => {
        pending = createPending(x);
        createRenderEffect(pending, () => {});
      });
      flush();
      const running = action(function* () {
        setX(1);
        yield end.promise;
      })();
      flush();
      expect(pending()).toBe(true);
      root(() => {
        const pair = createMemo(() => {
          if (inputFirst) {
            const value = x();
            return [pending(), value] as const;
          }
          return [pending(), x()] as const;
        });
        createRenderEffect(pair, value => {
          shown = value;
        });
      });
      flush();
      expect(shown).toEqual([true, 0]);
      end.resolve();
      await running;
      await turn();
      expect(shown).toEqual([false, 1]);
    });
  }

  it("removing an observation dependency stops its published-input exemption", async () => {
    const end = gate<void>();
    const [x, setX] = createSignal(0),
      [observe, setObserve] = createSignal(true);
    let shown = "";
    root(() => {
      const pending = createPending(x);
      const pair = createMemo(() => (observe() ? `${pending()}:${x()}` : `plain:${x()}`));
      createRenderEffect(pair, value => {
        shown = value;
      });
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect(shown).toBe("true:0");
    setObserve(false);
    flush();
    expect(shown).toBe("true:0");
    end.resolve();
    await running;
    await turn();
    expect(shown).toBe("plain:1");
  });

  for (const parentReadsFirst of [false, true]) {
    it(`late owned computations inherit their parent observation context (parent reads first ${parentReadsFirst})`, async () => {
      const end = gate<void>();
      const [x, setX] = createSignal(0);
      let pending!: () => boolean;
      let shown: readonly [boolean, number, number] | undefined;
      root(() => {
        pending = createPending(x);
        createRenderEffect(pending, () => {});
      });
      flush();
      const running = action(function* () {
        setX(1);
        yield end.promise;
      })();
      flush();
      root(() => {
        const pair = createMemo(() => {
          const value = parentReadsFirst ? x() : undefined;
          const child = createMemo(() => x() * 2);
          const doubled = child();
          return [pending(), value ?? x(), doubled] as const;
        });
        createRenderEffect(pair, value => {
          shown = value;
        });
      });
      flush();
      expect(shown).toEqual([true, 0, 0]);
      end.resolve();
      await running;
      await turn();
      expect(shown).toEqual([false, 1, 2]);
    });
  }

  for (const discarded of ["value", "rejection", "throw"] as const) {
    it(`a branch leaving the observation holds its flag, children and async result (${discarded})`, async () => {
      const end = gate<void>();
      const [x, setX] = createSignal(0),
        [observe, setObserve] = createSignal(true);
      const obsolete = gate<string>(),
        answer = gate<string>();
      const started: number[] = [],
        cleaned: string[] = [],
        childPublications: string[] = [];
      let shown = "",
        flag = true,
        childShown = "";
      root(() => {
        const pending = createPending(x);
        const text = createMemo(() => {
          const label = observe() ? `${pending()}:${x()}` : `plain:${x()}`;
          onCleanup(() => {
            cleaned.push(label);
          });
          createRenderEffect(
            () => label,
            value => {
              childShown = value;
              childPublications.push(value);
            }
          );
          if (observe()) return label;
          const value = x();
          started.push(value);
          if (!value && discarded === "throw") throw new Error("discarded frame");
          return value ? answer.promise : obsolete.promise;
        });
        createRenderEffect(text, value => {
          shown = value;
        });
        createRenderEffect(observe, value => {
          flag = value;
        });
      });
      flush();
      const running = action(function* () {
        setX(1);
        yield end.promise;
      })();
      flush();
      expect([shown, childShown, flag]).toEqual(["true:0", "true:0", true]);
      const oldCleanups = cleaned.length;
      setObserve(false);
      flush();
      expect([shown, childShown, flag]).toEqual(["true:0", "true:0", true]);
      expect(cleaned.slice(oldCleanups)).not.toContain("true:0");
      if (discarded === "rejection") {
        // Early retry may prevent this request from being returned at all.
        // Only catch a fixture-owned promise; consumed flights must still have
        // their rejection handled by the runtime.
        if (!started.includes(0)) obsolete.promise.catch(() => {});
        obsolete.reject(new Error("discarded answer"));
      } else if (discarded === "value") obsolete.resolve("obsolete");
      await turn();
      expect([shown, childShown, flag]).toEqual(["true:0", "true:0", true]);
      end.resolve();
      await running;
      await turn();
      expect([shown, childShown, flag]).toEqual(["true:0", "true:0", true]);
      answer.resolve("plain:1");
      await turn();
      expect([shown, childShown, flag]).toEqual(["plain:1", "plain:1", false]);
      expect(cleaned.slice(oldCleanups)).toContain("true:0");
      expect(started).toContain(1);
      expect(started).not.toContain(0);
      expect(childPublications).not.toContain("plain:0");
    });
  }

  for (const observeY of [false, true])
    it(`seeded observation publications stay coherent (observe second input=${observeY})`, async () => {
      for (let seed = 1; seed <= Number(process.env.PENDING_SEEDS || 20); seed++) {
        let randomState = seed;
        const random = () =>
          (randomState = (Math.imul(randomState, 1664525) + 1013904223) >>> 0) >>> 16;
        const [x, setX] = createSignal(0),
          [y, setY] = createSignal(0),
          [tick, setTick] = createSignal(0);
        type Frame = readonly [boolean, boolean, number, number];
        const actions: { end: ReturnType<typeof gate<void>>; running: Promise<void> }[] = [];
        const flights: { resolve: (value: Frame) => void; value: Frame }[] = [];
        let aShown = false,
          bShown = false,
          xShown = 0,
          yShown = 0,
          lastX = 1,
          lastY = 0;
        let pair: Frame = [false, false, 0, 0];
        let combined!: () => Frame;
        const late: Frame[] = [];
        root(() => {
          const a = createPending(x),
            b = observeY ? createPending(y) : () => false;
          combined = createMemo(() => {
            const frame = [a(), b(), x(), y()] as const;
            if (!frame.some(Boolean)) return frame;
            return new Promise<Frame>(resolve => {
              flights.push({ resolve, value: frame });
            });
          });
          createRenderEffect(
            () => [tick(), a()] as const,
            v => {
              aShown = v[1];
            }
          );
          createRenderEffect(
            () => [tick(), b()] as const,
            v => {
              bShown = v[1];
            }
          );
          createRenderEffect(x, v => {
            xShown = v;
          });
          createRenderEffect(y, v => {
            yShown = v;
          });
          createRenderEffect(combined, v => {
            pair = v;
          });
        });
        flush();
        const operations: string[] = [];
        const replay = process.env.PENDING_REPLAY?.split(" ").map(op => op.split(":").map(Number));
        {
          const end = gate<void>();
          const running = action(function* () {
            setX(1);
            yield end.promise;
          })();
          actions.push({ end, running });
          flush();
          const flight = flights.pop()!;
          flight.resolve(flight.value);
          await turn();
          expect(pair).toEqual([true, false, 0, 0]);
        }
        for (let step = 0; step < (replay?.length ?? 40); step++) {
          const [op, value] = replay?.[step] ?? [random() % 6, random() % 5];
          operations.push(`${op}:${value}`);
          if (op < 2) {
            const end = gate<void>();
            const running = action(function* () {
              (op === 0 ? setX : setY)(value);
              yield end.promise;
            })();
            if (op === 0) lastX = value;
            else lastY = value;
            actions.push({ end, running });
          } else if (op === 2 && actions.length) {
            const entry = actions.splice(value % actions.length, 1)[0];
            entry.end.resolve();
            await entry.running;
          } else if (op === 3 && flights.length) {
            const flight = flights.splice(value % flights.length, 1)[0];
            flight.resolve(flight.value);
          } else if (op === 4) setTick(step);
          else if (op === 5)
            root(() =>
              createRenderEffect(combined, v => {
                late[0] = v;
              })
            );
          flush();
          await turn();
          const why = `seed=${seed}, step=${step}, ops=${operations.join(" ")}`;
          expect(pair, why).toEqual([aShown, bShown, xShown, yShown]);
          if (late.length) expect(late[0], why).toEqual(pair);
        }
        for (const entry of actions) entry.end.resolve();
        await Promise.all(actions.map(entry => entry.running));
        for (let round = 0; round < 4; round++) {
          for (const flight of flights.splice(0)) flight.resolve(flight.value);
          await turn();
        }
        expect([aShown, bShown, xShown, yShown, pair]).toEqual([
          false,
          false,
          lastX,
          lastY,
          [false, false, lastX, lastY]
        ]);
        for (const dispose of disposals.splice(0)) dispose();
        if (replay) break;
      }
    });

  it("an initial load has no published false verdict", async () => {
    const result = gate<number>();
    const shown: boolean[] = [];
    root(() => {
      const input = createMemo(() => result.promise);
      const pending = createPending(input);
      createRenderEffect(pending, value => {
        shown.push(value);
      });
    });
    flush();
    expect(shown).toEqual([]);
    result.resolve(1);
    await turn();
    expect(shown).toEqual([false]);
  });

  for (const readInputFirst of [false, true]) {
    it(`a pending-state update reads its parent's published input (input first ${readInputFirst})`, async () => {
      const end = gate<void>();
      const [x, setX] = createSignal(0);
      let value = 0,
        status = false;
      let pair: readonly [boolean, number] = [false, 0];
      let pending!: () => boolean;
      root(() => {
        pending = createPending(x);
        const statusMemo = createMemo(pending);
        const combined = createMemo(() => {
          if (readInputFirst) {
            const value = x();
            return [statusMemo(), value] as const;
          }
          return [statusMemo(), x()] as const;
        });
        createRenderEffect(x, v => {
          value = v;
        });
        createRenderEffect(statusMemo, v => {
          status = v;
        });
        createRenderEffect(combined, v => {
          pair = v;
        });
      });
      flush();
      expect([value, status, pair, pending()]).toEqual([0, false, [false, 0], false]);
      const running = action(function* () {
        setX(1);
        yield end.promise;
      })();
      flush();
      expect([value, status, pair, pending()]).toEqual([0, true, [true, 0], true]);
      end.resolve();
      await running;
      await turn();
      expect([value, status, pair, pending()]).toEqual([1, false, [false, 1], false]);
    });
  }

  it("async derived from the pending update holds that output, including late and imperative readers", async () => {
    const end = gate<void>(),
      result = gate<string>();
    const [x, setX] = createSignal(0),
      [tick, setTick] = createSignal(0);
    let status = false,
      late = false;
    let pending!: () => boolean;
    let pair: readonly [boolean, string] = [false, "false:0"];
    root(() => {
      pending = createPending(x);
      const derived = createMemo(() => (pending() ? result.promise : `false:${x()}`));
      createRenderEffect(
        () => [tick(), pending()],
        v => {
          status = v[1] as boolean;
        }
      );
      createRenderEffect(
        () => [pending(), derived()] as const,
        v => {
          pair = v;
        }
      );
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    setTick(1);
    flush();
    root(() =>
      createRenderEffect(pending, v => {
        late = v;
      })
    );
    flush();
    expect([status, pair, late, pending()]).toEqual([false, [false, "false:0"], false, false]);
    result.resolve("true:0");
    await turn();
    expect([status, pair, late, pending()]).toEqual([true, [true, "true:0"], true, true]);
    end.resolve();
    await running;
    await turn();
    expect([status, pair, late, pending()]).toEqual([false, [false, "false:1"], false, false]);
  });

  it("completion supersedes pending-state async and holds the input for a new ordinary consequence", async () => {
    const end = gate<void>(),
      obsolete = gate<string>(),
      settled = gate<string>();
    const [x, setX] = createSignal(0);
    let value = 0,
      status = false;
    let pair: readonly [boolean, number, string] = [false, 0, "initial"];
    root(() => {
      const pending = createPending(x);
      const derived = createMemo(() =>
        pending() ? obsolete.promise : x() ? settled.promise : "initial"
      );
      createRenderEffect(x, v => {
        value = v;
      });
      createRenderEffect(pending, v => {
        status = v;
      });
      createRenderEffect(
        () => [pending(), x(), derived()] as const,
        v => {
          pair = v;
        }
      );
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    end.resolve();
    await running;
    await turn();
    expect([value, status, pair]).toEqual([0, false, [false, 0, "initial"]]);
    obsolete.resolve("obsolete");
    await turn();
    expect([value, status, pair]).toEqual([0, false, [false, 0, "initial"]]);
    settled.resolve("settled");
    await turn();
    expect([value, status, pair]).toEqual([1, false, [false, 1, "settled"]]);
  });

  it("ordinary async holding also produces a separate pending update", async () => {
    const result = gate<number>();
    const [x, setX] = createSignal(0);
    let value = 0,
      status = false,
      data = 0;
    let pair: readonly [boolean, number] = [false, 0];
    root(() => {
      const derived = createMemo(() => (x() ? result.promise : 0));
      const pending = createPending(x);
      createRenderEffect(x, v => {
        value = v;
      });
      createRenderEffect(derived, v => {
        data = v;
      });
      createRenderEffect(pending, v => {
        status = v;
      });
      createRenderEffect(
        () => [pending(), x()] as const,
        v => {
          pair = v;
        }
      );
    });
    flush();
    setX(1);
    flush();
    expect([value, data, status, pair]).toEqual([0, 0, true, [true, 0]]);
    result.resolve(1);
    await turn();
    expect([value, data, status, pair]).toEqual([1, 1, false, [false, 1]]);
  });

  it("pending-true uses a separate held input without linking their completion", async () => {
    const xEnd = gate<void>(),
      yEnd = gate<void>();
    const [x, setX] = createSignal(0),
      [y, setY] = createSignal(0);
    let status = false,
      value = 0;
    let pair: readonly [boolean, number] = [false, 0];
    root(() => {
      const pending = createPending(x);
      const combined = createMemo(() => [pending(), y()] as const);
      createRenderEffect(y, v => {
        value = v;
      });
      createRenderEffect(pending, v => {
        status = v;
      });
      createRenderEffect(combined, v => {
        pair = v;
      });
    });
    flush();
    const other = action(function* () {
      setY(10);
      yield yEnd.promise;
    })();
    flush();
    const changing = action(function* () {
      setX(1);
      yield xEnd.promise;
    })();
    flush();
    expect([status, value, pair]).toEqual([true, 0, [true, 0]]);
    yEnd.resolve();
    await other;
    await turn();
    expect([status, value, pair]).toEqual([true, 10, [true, 10]]);
    xEnd.resolve();
    await changing;
    await turn();
    expect([status, value, pair]).toEqual([false, 10, [false, 10]]);
  });

  it("two observations of one parent publish together through a shared async derivation", async () => {
    const end = gate<void>(),
      result = gate<string>();
    const [x, setX] = createSignal(0);
    let first = false,
      second = false,
      text = "idle";
    root(() => {
      const a = createPending(x),
        b = createPending(x);
      const combined = createMemo(() => (a() || b() ? result.promise : `idle:${x()}`));
      createRenderEffect(a, v => {
        first = v;
      });
      createRenderEffect(b, v => {
        second = v;
      });
      createRenderEffect(combined, v => {
        text = v;
      });
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect([first, second, text]).toEqual([false, false, "idle:0"]);
    result.resolve("pending");
    await turn();
    expect([first, second, text]).toEqual([true, true, "pending"]);
    end.resolve();
    await running;
    await turn();
    expect([first, second, text]).toEqual([false, false, "idle:1"]);
  });

  it("a new action during the false proposal supersedes that proposal", async () => {
    const firstEnd = gate<void>(),
      secondEnd = gate<void>(),
      stale = gate<string>();
    const [x, setX] = createSignal(0);
    let status = false,
      value = 0;
    let pair: readonly [boolean, string] = [false, "idle:0"];
    root(() => {
      const pending = createPending(x);
      const derived = createMemo(() =>
        pending() ? "pending" : x() === 1 ? stale.promise : `idle:${x()}`
      );
      createRenderEffect(pending, v => {
        status = v;
      });
      createRenderEffect(x, v => {
        value = v;
      });
      createRenderEffect(
        () => [pending(), derived()] as const,
        v => {
          pair = v;
        }
      );
    });
    flush();
    const first = action(function* () {
      setX(1);
      yield firstEnd.promise;
    })();
    flush();
    expect([value, status, pair]).toEqual([0, true, [true, "pending"]]);
    firstEnd.resolve();
    await first;
    await turn();
    expect([value, status, pair]).toEqual([0, true, [true, "pending"]]);
    const second = action(function* () {
      setX(2);
      yield secondEnd.promise;
    })();
    flush();
    expect([value, status, pair]).toEqual([0, true, [true, "pending"]]);
    stale.resolve("stale");
    await turn();
    expect([value, status, pair]).toEqual([0, true, [true, "pending"]]);
    secondEnd.resolve();
    await second;
    await turn();
    expect([value, status, pair]).toEqual([2, false, [false, "idle:2"]]);
  });

  it("sibling pending updates read both parents' published values", async () => {
    const xEnd = gate<void>(),
      yEnd = gate<void>();
    const [x, setX] = createSignal(0),
      [y, setY] = createSignal(0);
    let first = false,
      second = false;
    let pair: readonly [boolean, boolean, number, number] = [false, false, 0, 0];
    root(() => {
      const a = createPending(x),
        b = createPending(y);
      const aMemo = createMemo(a),
        bMemo = createMemo(b);
      const combined = createMemo(() => [aMemo(), bMemo(), x(), y()] as const);
      createRenderEffect(aMemo, v => {
        first = v;
      });
      createRenderEffect(bMemo, v => {
        second = v;
      });
      createRenderEffect(combined, v => {
        pair = v;
      });
    });
    flush();
    const a = action(function* () {
      setX(1);
      yield xEnd.promise;
    })();
    flush();
    expect([first, second, pair]).toEqual([true, false, [true, false, 0, 0]]);
    const b = action(function* () {
      setY(2);
      yield yEnd.promise;
    })();
    flush();
    expect([first, second, pair]).toEqual([true, true, [true, true, 0, 0]]);
    xEnd.resolve();
    await a;
    await turn();
    expect([first, second, pair]).toEqual([false, true, [false, true, 1, 0]]);
    yEnd.resolve();
    await b;
    await turn();
    expect([first, second, pair]).toEqual([false, false, [false, false, 1, 2]]);
  });
});
