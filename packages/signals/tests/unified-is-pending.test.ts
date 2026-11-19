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
import { $REFRESH } from "../src/core/constants.js";
import { isPending } from "../src/layers/pending.js";

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

function subscribers(input: () => unknown) {
  const source = (input as any)[$REFRESH];
  let count = 0;
  for (let edge = source._subs; edge; edge = edge._nextSub) count++;
  return count;
}

describe("source-owned pending output", () => {
  it("two calls share publication through the same lazily created output", async () => {
    const end = gate<void>(),
      labelResult = gate<string>();
    const [x, setX] = createSignal(0);
    let fast = false,
      slow = false,
      label = "idle";
    root(() => {
      const status = createMemo(() => isPending(x));
      createRenderEffect(status, value => {
        fast = value;
      });
    });
    root(() => {
      const status = createMemo(() => isPending(x));
      const text = createMemo(() => (status() ? labelResult.promise : "idle"));
      createRenderEffect(status, value => {
        slow = value;
      });
      createRenderEffect(text, value => {
        label = value;
      });
    });
    flush();
    expect(subscribers(x)).toBe(1);
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect([fast, slow, label, isPending(x)]).toEqual([false, false, "idle", false]);
    labelResult.resolve("pending");
    await turn();
    expect([fast, slow, label, isPending(x)]).toEqual([true, true, "pending", true]);
    end.resolve();
    await running;
    await turn();
    expect([fast, slow, label, isPending(x)]).toEqual([false, false, "idle", false]);
  });

  it("a callback observes pending reads even when its return value stays equal", async () => {
    const end = gate<void>();
    const [x, setX] = createSignal(0);
    let direct = false,
      callback = false;
    root(() => {
      createRenderEffect(
        () => isPending(x),
        value => {
          direct = value;
        }
      );
      createRenderEffect(
        () =>
          isPending(() => {
            x();
            return 0;
          }),
        value => {
          callback = value;
        }
      );
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect([direct, callback]).toEqual([true, true]);
    end.resolve();
    await running;
    await turn();
    expect([direct, callback]).toEqual([false, false]);
  });

  it("wrapping an accessor still reads the same pending output", async () => {
    const end = gate<void>(),
      result = gate<string>();
    const [x, setX] = createSignal(0);
    let direct = false,
      callback = false,
      text = "idle";
    root(() => {
      const a = createMemo(() => isPending(x));
      const b = createMemo(() => isPending(() => x()));
      const label = createMemo(() => (b() ? result.promise : "idle"));
      createRenderEffect(a, value => {
        direct = value;
      });
      createRenderEffect(b, value => {
        callback = value;
      });
      createRenderEffect(label, value => {
        text = value;
      });
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect([direct, callback, text]).toEqual([false, false, "idle"]);
    result.resolve("pending");
    await turn();
    expect([direct, callback, text]).toEqual([true, true, "pending"]);
    end.resolve();
    await running;
    await turn();
    expect([direct, callback, text]).toEqual([false, false, "idle"]);
  });

  it("callback probing does not change a lazy memo's own dependency reads", async () => {
    const result = gate<number>();
    const [x, setX] = createSignal(0);
    let source!: () => number,
      status = false,
      shown = 0;
    root(() => {
      source = createMemo(() => (x() ? result.promise : 0), { lazy: true });
      createRenderEffect(
        () => isPending(() => source()),
        value => {
          status = value;
        }
      );
      createRenderEffect(source, value => {
        shown = value;
      });
    });
    flush();
    setX(1);
    flush();
    expect([status, shown]).toEqual([true, 0]);
    result.resolve(1);
    await turn();
    expect([status, shown]).toEqual([false, 1]);
  });

  it("removing the first reader does not dispose another reader's pending output", async () => {
    const end = gate<void>();
    const [x, setX] = createSignal(0);
    let first = false,
      second = false;
    const removeFirst = root(() =>
      createRenderEffect(
        () => isPending(x),
        value => {
          first = value;
        }
      )
    );
    const removeSecond = root(() =>
      createRenderEffect(
        () => isPending(x),
        value => {
          second = value;
        }
      )
    );
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect([first, second]).toEqual([true, true]);
    removeFirst();
    flush();
    expect(subscribers(x)).toBe(1);
    end.resolve();
    await running;
    await turn();
    expect([first, second]).toEqual([true, false]);
    removeSecond();
    flush();
    expect(subscribers(x)).toBe(0);
  });

  it("a source memo can recompute without destroying its pending output", async () => {
    const result = gate<number>();
    const [id, setId] = createSignal(0);
    let shown = false;
    root(() => {
      const source = createMemo(() => (id() ? result.promise : 0));
      createRenderEffect(
        () => isPending(source),
        value => {
          shown = value;
        }
      );
    });
    flush();
    setId(1);
    flush();
    expect(shown).toBe(true);
    result.resolve(1);
    await turn();
    expect(shown).toBe(false);
  });

  it("an async input and the shared pending-false consequence publish together", async () => {
    const inputResult = gate<number>(),
      labelResult = gate<string>();
    const [id, setId] = createSignal(0);
    let shown = 0,
      status = false,
      text = "idle";
    root(() => {
      const source = createMemo(() => (id() ? inputResult.promise : 0));
      const label = createMemo(() => {
        const p = isPending(source),
          n = source();
        return p ? "pending" : n ? labelResult.promise : "idle";
      });
      createRenderEffect(source, value => {
        shown = value;
      });
      createRenderEffect(
        () => isPending(source),
        value => {
          status = value;
        }
      );
      createRenderEffect(label, value => {
        text = value;
      });
    });
    flush();
    setId(1);
    flush();
    expect([shown, status, text]).toEqual([0, true, "pending"]);
    inputResult.resolve(1);
    await turn();
    expect([shown, status, text]).toEqual([0, true, "pending"]);
    labelResult.resolve("settled");
    await turn();
    expect([shown, status, text]).toEqual([1, false, "settled"]);
  });

  it("callback control flow observes the sources it actually reads", async () => {
    const end = gate<void>();
    const [chooseX, setChooseX] = createSignal(false),
      [x, setX] = createSignal(0);
    let selected = false,
      direct = false;
    root(() => {
      createRenderEffect(
        () =>
          isPending(() => {
            if (chooseX()) x();
          }),
        value => {
          selected = value;
        }
      );
      createRenderEffect(
        () => isPending(x),
        value => {
          direct = value;
        }
      );
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect([selected, direct]).toEqual([false, true]);
    setChooseX(true);
    flush();
    expect([selected, direct]).toEqual([true, true]);
    setChooseX(false);
    flush();
    expect([selected, direct]).toEqual([false, true]);
    end.resolve();
    await running;
    await turn();
    expect([selected, direct]).toEqual([false, false]);
  });

  it("a dormant source-owned output revives after its old action has finished", async () => {
    const [x, setX] = createSignal(0);
    for (let cycle = 1; cycle <= 30; cycle++) {
      const end = gate<void>();
      let shown = false;
      const dispose = root(() =>
        createRenderEffect(
          () => isPending(x),
          value => {
            shown = value;
          }
        )
      );
      flush();
      expect(shown).toBe(false);
      const running = action(function* () {
        setX(cycle);
        yield end.promise;
      })();
      flush();
      expect(shown).toBe(true);
      dispose();
      flush();
      expect(subscribers(x)).toBe(0);
      end.resolve();
      await running;
      await turn();
    }
  });

  it("remounting during the same hold observes the shared pending state", async () => {
    const end = gate<void>();
    const [x, setX] = createSignal(0);
    let shown = false;
    const first = root(() =>
      createRenderEffect(
        () => isPending(x),
        value => {
          shown = value;
        }
      )
    );
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect(shown).toBe(true);
    first();
    flush();
    expect(subscribers(x)).toBe(0);
    shown = false;
    root(() =>
      createRenderEffect(
        () => isPending(x),
        value => {
          shown = value;
        }
      )
    );
    flush();
    expect(shown).toBe(true);
    end.resolve();
    await running;
    await turn();
    expect(shown).toBe(false);
  });

  it("reviving the pending output also revives a lazy input memo", async () => {
    const result = gate<number>();
    const [id, setId] = createSignal(0);
    let source!: () => number,
      runs = 0,
      cleaned = 0,
      shown = false;
    root(() => {
      source = createMemo(
        () => {
          runs++;
          onCleanup(() => {
            cleaned++;
          });
          return id() ? result.promise : 0;
        },
        { lazy: true }
      );
    });
    const first = root(() =>
      createRenderEffect(
        () => isPending(source),
        value => {
          shown = value;
        }
      )
    );
    flush();
    expect(runs).toBe(1);
    first();
    flush();
    expect(cleaned).toBe(1);
    setId(1);
    flush();
    expect(runs).toBe(1);
    root(() =>
      createRenderEffect(
        () => isPending(source),
        value => {
          shown = value;
        }
      )
    );
    flush();
    expect(runs).toBe(2);
    expect(shown).toBe(true);
    result.resolve(1);
    await turn();
    expect(shown).toBe(false);
  });

  for (const reverse of [false, true]) {
    it(`the shared output uses the committed separate input (reverse=${reverse})`, async () => {
      const xEnd = gate<void>(),
        yEnd = gate<void>();
      const [x, setX] = createSignal(0),
        [y, setY] = createSignal(0);
      let status = false,
        value = 0,
        label = "false:0";
      root(() => {
        const text = createMemo(() => {
          if (reverse) {
            const n = y();
            return `${isPending(x)}:${n}`;
          }
          return `${isPending(x)}:${y()}`;
        });
        createRenderEffect(
          () => isPending(x),
          v => {
            status = v;
          }
        );
        createRenderEffect(y, v => {
          value = v;
        });
        createRenderEffect(text, v => {
          label = v;
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
      expect([status, value, label]).toEqual([true, 0, "true:0"]);
      yEnd.resolve();
      await other;
      await turn();
      expect([status, value, label]).toEqual([true, 10, "true:10"]);
      xEnd.resolve();
      await changing;
      await turn();
      expect([status, value, label]).toEqual([false, 10, "false:10"]);
    });
  }
});
