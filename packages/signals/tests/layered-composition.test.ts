import { afterEach, expect, it } from "vitest";
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

for (const asyncInput of [false, true]) {
  for (const callback of [false, true]) {
    for (const xFirst of [false, true]) {
      it(`combined pending keeps independent input publication (async input=${asyncInput}, callback=${callback}, x first=${xFirst})`, async () => {
        const xEnd = gate<number>(),
          yEnd = gate<number>();
        const pendingLabel = gate<string>(),
          settledLabel = gate<string>();
        const [x, setX] = createSignal(0),
          [y, setY] = createSignal(0);
        const visible = {
          x: 0,
          y: 0,
          xPending: false,
          yPending: false,
          pending: false,
          label: "initial"
        };
        let status!: () => boolean;
        const labelRuns: boolean[] = [];
        let late: boolean | undefined;
        root(() => {
          if (asyncInput) {
            const xResult = createMemo(() => (x() ? xEnd.promise : 0));
            const yResult = createMemo(() => (y() ? yEnd.promise : 0));
            createRenderEffect(xResult, () => {});
            createRenderEffect(yResult, () => {});
          }
          status = createMemo(() => {
            if (callback)
              return isPending(() => {
                x();
                y();
              });
            const a = isPending(x),
              b = isPending(y);
            return a || b;
          });
          const label = createMemo(() => {
            const pending = status();
            labelRuns.push(pending);
            return labelRuns.length === 1
              ? "initial"
              : pending
                ? pendingLabel.promise
                : settledLabel.promise;
          });
          createRenderEffect(x, v => {
            visible.x = v;
          });
          createRenderEffect(y, v => {
            visible.y = v;
          });
          createRenderEffect(
            () => isPending(x),
            v => {
              visible.xPending = v;
            }
          );
          createRenderEffect(
            () => isPending(y),
            v => {
              visible.yPending = v;
            }
          );
          createRenderEffect(status, v => {
            visible.pending = v;
          });
          createRenderEffect(label, v => {
            visible.label = v;
          });
        });
        flush();
        const first = asyncInput
          ? (setX(1), Promise.resolve())
          : action(function* () {
              setX(1);
              yield xEnd.promise;
            })();
        flush();
        const second = asyncInput
          ? (setY(2), Promise.resolve())
          : action(function* () {
              setY(2);
              yield yEnd.promise;
            })();
        flush();
        expect(visible).toEqual({
          x: 0,
          y: 0,
          xPending: false,
          yPending: false,
          pending: false,
          label: "initial"
        });
        pendingLabel.resolve("pending");
        await turn();
        expect(visible).toEqual({
          x: 0,
          y: 0,
          xPending: true,
          yPending: true,
          pending: true,
          label: "pending"
        });

        (xFirst ? xEnd : yEnd).resolve(xFirst ? 1 : 2);
        await (xFirst ? first : second);
        await turn();
        expect(visible).toEqual({
          x: xFirst ? 1 : 0,
          y: xFirst ? 0 : 2,
          xPending: !xFirst,
          yPending: xFirst,
          pending: true,
          label: "pending"
        });
        expect(labelRuns[0]).toBe(false);
        expect(labelRuns.slice(1).every(Boolean)).toBe(true);

        (xFirst ? yEnd : xEnd).resolve(xFirst ? 2 : 1);
        await (xFirst ? second : first);
        await turn();
        root(() =>
          createRenderEffect(
            () => isPending(xFirst ? y : x),
            value => {
              late = value;
            }
          )
        );
        flush();
        expect(visible).toEqual({
          x: xFirst ? 1 : 0,
          y: xFirst ? 0 : 2,
          xPending: !xFirst,
          yPending: xFirst,
          pending: true,
          label: "pending"
        });
        expect(late).toBe(true);
        settledLabel.resolve("settled");
        await turn();
        expect(visible).toEqual({
          x: 1,
          y: 2,
          xPending: false,
          yPending: false,
          pending: false,
          label: "settled"
        });
        expect(late).toBe(false);
        expect(labelRuns.at(-1)).toBe(false);
      });
    }
  }
}

for (const asyncDepth of [0, 1, 8]) {
  for (const persistent of [false, true]) {
    for (const lowerFirst of [false, true]) {
      it(`a suspended guess remains independent of later lower work (async depth=${asyncDepth}, persistent=${persistent}, lower first=${lowerFirst})`, async () => {
        const guessEnd = gate<void>(),
          lowerEnd = gate<number>();
        const firstLabel = gate<string>(),
          finalLabel = gate<string>();
        const [y, setY] = createSignal(0);
        let guess!: (value: number) => number;
        let clear!: () => void;
        const visible = { view: 0, y: 0, label: "0:0" };
        const runs: string[] = [];
        const children = new Map<object, string>();
        let viewRead!: () => number;
        root(() => {
          const [view, propose, reset] = createLayer(
            () => 0,
            persistent ? undefined : { lifetime: "action" }
          );
          clear = reset;
          guess = propose;
          viewRead = view;
          if (asyncDepth) {
            let dependency = y;
            for (let i = 1; i < asyncDepth; i++) {
              const source = dependency;
              dependency = createMemo(() => source());
            }
            const result = createMemo(() => (dependency() ? lowerEnd.promise : 0));
            createRenderEffect(result, () => {});
          }
          const combined = createMemo(() => {
            const value = `${view()}:${y()}`;
            const identity = {};
            const child = createMemo(() => value);
            createRenderEffect(child, result => {
              children.set(identity, result);
            });
            onCleanup(() => {
              children.delete(identity);
            });
            return value;
          });
          const label = createMemo(() => {
            const value = combined();
            runs.push(value);
            return value === "1:0"
              ? firstLabel.promise
              : value === "1:10"
                ? finalLabel.promise
                : value;
          });
          createRenderEffect(view, value => {
            visible.view = value;
          });
          createRenderEffect(y, value => {
            visible.y = value;
          });
          createRenderEffect(label, value => {
            visible.label = value;
          });
        });
        flush();
        const guessing = action(function* () {
          guess(1);
          yield guessEnd.promise;
        })();
        flush();
        const lower = asyncDepth
          ? (setY(10), Promise.resolve())
          : action(function* () {
              setY(10);
              yield lowerEnd.promise;
            })();
        flush();
        expect(visible).toEqual({ view: 0, y: 0, label: "0:0" });
        expect([...children.values()]).toEqual(["0:0"]);
        let late: number | undefined;
        root(() =>
          createRenderEffect(viewRead, value => {
            late = value;
          })
        );
        flush();
        expect(late).toBe(0);
        if (lowerFirst) {
          lowerEnd.resolve(10);
          await lower;
          await turn();
          expect(runs).toContain("1:10");
          firstLabel.resolve("1:0");
          await turn();
          expect(visible).toEqual({ view: 0, y: 0, label: "0:0" });
          expect([...children.values()]).toEqual(["0:0"]);
          expect(late).toBe(0);
        } else {
          firstLabel.resolve("1:0");
          await turn();
          expect(visible).toEqual({ view: 1, y: 0, label: "1:0" });
          expect([...children.values()]).toEqual(["1:0"]);
          expect(late).toBe(1);
          lowerEnd.resolve(10);
          await lower;
          await turn();
          expect(visible).toEqual({ view: 1, y: 0, label: "1:0" });
        }
        finalLabel.resolve("1:10");
        await turn();
        expect(visible).toEqual({ view: 1, y: 10, label: "1:10" });
        expect([...children.values()]).toEqual(["1:10"]);
        expect(late).toBe(1);
        if (persistent) clear();
        guessEnd.resolve();
        await guessing;
        await turn();
        expect(visible).toEqual({ view: 0, y: 10, label: "0:10" });
        expect([...children.values()]).toEqual(["0:10"]);
        expect(late).toBe(0);
      });
    }
  }
}

for (const persistent of [false, true]) {
  for (const asyncResult of [false, true]) {
    it(`ordinary peer updates still merge beneath a published override (persistent=${persistent}, async=${asyncResult})`, async () => {
      const scopeEnd = gate<void>(),
        aEnd = gate<void>(),
        bEnd = gate<void>();
      const oldResult = gate<number>(),
        result = gate<number>();
      const [a, setA] = createSignal(0),
        [b, setB] = createSignal(0);
      let guess!: (value: number) => number;
      let clear!: () => void;
      const runs: number[] = [];
      const visible = [0, 0, 0];
      root(() => {
        const [view, propose, reset] = createLayer(
          () => 0,
          persistent ? undefined : { lifetime: "action" }
        );
        guess = propose;
        clear = reset;
        const sum = createMemo(() => {
          view();
          return a() + b();
        });
        const label = createMemo(() => {
          const value = sum();
          runs.push(value);
          return !asyncResult || value === 0
            ? value
            : value === 1
              ? oldResult.promise
              : result.promise;
        });
        [a, b, label].forEach((read, index) =>
          createRenderEffect(read, value => {
            visible[index] = value;
          })
        );
      });
      flush();
      const guessing = action(function* () {
        guess(9);
        yield scopeEnd.promise;
      })();
      flush();
      const first = action(function* () {
        setA(1);
        yield aEnd.promise;
      })();
      flush();
      const second = action(function* () {
        setB(1);
        yield bEnd.promise;
      })();
      flush();
      expect(runs.slice(-2)).toEqual([1, 2]);
      expect(visible).toEqual([0, 0, 0]);
      aEnd.resolve();
      await first;
      oldResult.resolve(1);
      result.resolve(2);
      await turn();
      expect(visible).toEqual([0, 0, 0]);
      bEnd.resolve();
      await second;
      await turn();
      expect(visible).toEqual([1, 1, 2]);
      if (persistent) clear();
      scopeEnd.resolve();
      await guessing;
      await turn();
    });
  }
}

for (const obsolete of [false, true]) {
  it(`scoped async errors recover without publishing an obsolete frame (obsolete=${obsolete})`, async () => {
    const lowerEnd = gate<void>(),
      first = gate<string>(),
      final = gate<string>();
    const [y, setY] = createSignal(0);
    let guess!: (value: number) => number;
    let reset!: () => void;
    const visible = { view: 0, y: 0, frame: "0:0" };
    root(() => {
      const [view, propose] = createLayer(() => 0);
      guess = propose;
      const pair = createMemo(() => `${view()}:${y()}`);
      const label = createMemo(() =>
        pair() === "1:0" ? first.promise : pair() === "1:10" ? final.promise : pair()
      );
      createRenderEffect(view, value => {
        visible.view = value;
      });
      createRenderEffect(y, value => {
        visible.y = value;
      });
      const boundary = createErrorBoundary(
        () => {
          createRenderEffect(label, value => {
            visible.frame = value;
          });
        },
        (_, retry) => {
          reset = retry;
          return "error";
        }
      );
      createRenderEffect(boundary, value => {
        if (value) visible.frame = value;
      });
    });
    flush();
    guess(1);
    flush();
    const lower = action(function* () {
      setY(10);
      yield lowerEnd.promise;
    })();
    flush();
    if (obsolete) {
      lowerEnd.resolve();
      await lower;
      await turn();
    }
    first.reject(new Error("first result failed"));
    await turn();
    if (obsolete) {
      expect(visible).toEqual({ view: 0, y: 0, frame: "0:0" });
      final.resolve("1:10");
      await turn();
      expect(visible).toEqual({ view: 1, y: 10, frame: "1:10" });
    } else {
      expect(visible).toEqual({ view: 1, y: 0, frame: "error" });
      guess(2);
      flush();
      reset();
      flush();
      expect(visible).toEqual({ view: 2, y: 0, frame: "2:0" });
      lowerEnd.resolve();
      await lower;
      await turn();
      expect(visible).toEqual({ view: 2, y: 10, frame: "2:10" });
    }
  });
}

it("a ready synchronous input supersedes the optimistic flight immediately", async () => {
  const first = gate<string>(),
    final = gate<string>();
  const [y, setY] = createSignal(0);
  let guess!: (value: number) => number;
  const runs: string[] = [];
  const visible = { view: 0, y: 0, label: "0:0" };
  root(() => {
    const [view, propose] = createLayer(() => 0);
    guess = propose;
    const pair = createMemo(() => `${view()}:${y()}`);
    const label = createMemo(() => {
      const value = pair();
      runs.push(value);
      return value === "1:0" ? first.promise : value === "1:10" ? final.promise : value;
    });
    createRenderEffect(view, value => {
      visible.view = value;
    });
    createRenderEffect(y, value => {
      visible.y = value;
    });
    createRenderEffect(label, value => {
      visible.label = value;
    });
  });
  flush();
  guess(1);
  flush();
  setY(10);
  flush();
  expect(runs.at(-1)).toBe("1:10");
  first.resolve("1:0");
  await turn();
  expect(visible).toEqual({ view: 0, y: 0, label: "0:0" });
  final.resolve("1:10");
  await turn();
  expect(visible).toEqual({ view: 1, y: 10, label: "1:10" });
});

for (const direct of [false, true]) {
  it(`a fresh guess over a pending input gets its own output update (direct input=${direct})`, async () => {
    const next = gate<void>(),
      guessEnd = gate<void>(),
      answerEnd = gate<void>();
    const first = gate<number>(),
      correction = gate<number>(),
      last = gate<number>();
    const [source, setSource] = createSignal(0);
    let guess!: (value: number | ((previous: number) => number)) => number;
    const visible = { source: 0, view: 0, label: 0 };
    root(() => {
      const [view, propose] = createLayer(direct ? source : () => source(), { lifetime: "action" });
      guess = propose;
      const label = createMemo(() => {
        const value = view();
        return value === 1
          ? first.promise
          : value === 2
            ? correction.promise
            : value === 3
              ? last.promise
              : value;
      });
      createRenderEffect(source, value => {
        visible.source = value;
      });
      createRenderEffect(view, value => {
        visible.view = value;
      });
      createRenderEffect(label, value => {
        visible.label = value;
      });
    });
    flush();
    const guessing = action(function* () {
      guess(1);
      yield next.promise;
      // Explicit proposal: an active override now remains the functional
      // updater's base, rather than the correction staged underneath it.
      guess(3);
      yield guessEnd.promise;
    })();
    flush();
    const answering = action(function* () {
      setSource(2);
      yield answerEnd.promise;
    })();
    flush();
    expect(visible).toEqual({ source: 0, view: 0, label: 0 });
    next.resolve();
    await turn();
    first.resolve(1);
    last.resolve(3);
    await turn();
    expect(visible).toEqual({ source: 0, view: 3, label: 3 });
    answerEnd.resolve();
    guessEnd.resolve();
    await Promise.all([answering, guessing]);
    await turn();
    expect(visible).toEqual({ source: 0, view: 3, label: 3 });
    correction.resolve(2);
    await turn();
    expect(visible).toEqual({ source: 2, view: 2, label: 2 });
  });
}
