// Stage 79: active overrides cut input demand; only their own action input
// flights and ordinary correction consequences hold. This revises stage 49.
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
  onCleanup
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

for (const childFirst of [false, true]) {
  it(`same-action nested proposals can publish while their inputs are pending (child first=${childFirst})`, async () => {
    const answer = Promise.withResolvers<number>(),
      end = Promise.withResolvers<void>();
    const shown = { first: 0, second: 0, pending: false };
    let guessFirst!: (value: number) => number, guessSecond!: (value: number) => number;
    createRoot(dispose => {
      disposals.push(dispose);
      const [first, g1] = createOptimistic(() => 0);
      const middle = createMemo(() => (first() === 1 ? answer.promise : 0));
      const [second, g2] = createOptimistic(middle);
      guessFirst = g1;
      guessSecond = g2;
      createRenderEffect(first, value => {
        shown.first = value;
      });
      createRenderEffect(second, value => {
        shown.second = value;
      });
      createRenderEffect(
        () => isPending(second),
        value => {
          shown.pending = value;
        }
      );
    });
    const running = action(function* () {
      if (childFirst) {
        guessSecond(2);
        guessFirst(1);
      } else {
        guessFirst(1);
        guessSecond(2);
      }
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual({ first: 1, second: 2, pending: true });
    end.resolve();
    await running;
    await turn();
    expect(shown).toEqual({ first: 1, second: 2, pending: true });
    answer.resolve(10);
    await turn();
    expect(shown).toEqual({ first: 0, second: 0, pending: false });
  });
}

it("a displayed child override releases the lower publication without consuming its input", async () => {
  const answer = Promise.withResolvers<number>();
  const endParent = Promise.withResolvers<void>(),
    endChild = Promise.withResolvers<void>();
  const shown = { first: 0, second: 0 };
  let guessFirst!: (value: number) => number, guessSecond!: (value: number) => number;
  createRoot(dispose => {
    disposals.push(dispose);
    const [first, writeFirst] = createOptimistic(() => 0);
    const middle = createMemo(() => (first() === 0 ? 0 : answer.promise));
    const [second, writeSecond] = createOptimistic(middle);
    guessFirst = writeFirst;
    guessSecond = writeSecond;
    createRenderEffect(first, value => {
      shown.first = value;
    });
    createRenderEffect(second, value => {
      shown.second = value;
    });
  });
  const parent = action(function* () {
    guessFirst(1);
    yield endParent.promise;
  })();
  flush();
  expect(shown).toEqual({ first: 0, second: 0 });
  const child = action(function* () {
    guessSecond(3);
    yield endChild.promise;
  })();
  flush();
  expect(shown).toEqual({ first: 1, second: 3 });
  answer.resolve(2);
  await turn();
  expect(shown).toEqual({ first: 1, second: 3 });
  endChild.resolve();
  await child;
  await turn();
  expect(shown).toEqual({ first: 1, second: 2 });
  endParent.resolve();
  await parent;
  await turn();
  expect(shown).toEqual({ first: 0, second: 0 });
});

for (const removal of ["dispose", "conditional", "owned"] as const) {
  it(`an override cuts input demand before its observer is removed (${removal})`, async () => {
    const answer = Promise.withResolvers<number>();
    const shown = { source: 0, view: "0" };
    let setSource!: (value: number) => number, hide!: () => void, guess!: (value: number) => number;
    let cleaned = 0;
    createRoot(dispose => {
      disposals.push(dispose);
      const [source, write] = createSignal(0),
        [visible, setVisible] = createSignal(true);
      const input = createMemo(() => (source() === 0 ? 0 : answer.promise));
      const [view, propose] = createLayer(input);
      setSource = write;
      guess = propose;
      createRenderEffect(source, value => {
        shown.source = value;
      });
      if (removal === "dispose") {
        createRoot(disposeObserver => {
          disposals.push(disposeObserver);
          hide = disposeObserver;
          createRenderEffect(view, value => {
            shown.view = String(value);
          });
        });
      } else if (removal === "conditional") {
        hide = () => {
          setVisible(false);
        };
        const label = createMemo(() => (visible() ? String(view()) : "hidden"));
        createRenderEffect(label, value => {
          shown.view = value;
        });
      } else {
        hide = () => {
          setVisible(false);
        };
        const owner = createMemo(() => {
          if (visible()) {
            onCleanup(() => {
              cleaned++;
            });
            createRenderEffect(view, value => {
              shown.view = String(value);
            });
          }
          return 0;
        });
        createRenderEffect(owner, () => {});
      }
    });
    guess(10);
    flush();
    setSource(1);
    flush();
    expect(shown).toEqual({ source: 1, view: "10" });
    hide();
    flush();
    expect(shown.source).toBe(1);
    if (removal === "conditional") expect(shown.view).toBe("hidden");
    if (removal === "owned") expect(cleaned).toBe(1);
    answer.resolve(1);
    await turn();
    expect(shown.source).toBe(1);
  });
}

it("a held removal preserves the displayed override without holding its input", async () => {
  const answer = Promise.withResolvers<number>(),
    hidden = Promise.withResolvers<string>();
  const shown = { source: 0, view: "0", blocker: "visible" };
  let setSource!: (value: number) => number, hide!: () => void, guess!: (value: number) => number;
  createRoot(dispose => {
    disposals.push(dispose);
    const [source, write] = createSignal(0),
      [visible, setVisible] = createSignal(true);
    const input = createMemo(() => (source() === 0 ? 0 : answer.promise));
    const [view, propose] = createLayer(input);
    setSource = write;
    guess = propose;
    hide = () => {
      setVisible(false);
    };
    const label = createMemo(() => (visible() ? String(view()) : "hidden"));
    const blocker = createMemo(() => (visible() ? "visible" : hidden.promise));
    createRenderEffect(source, value => {
      shown.source = value;
    });
    createRenderEffect(label, value => {
      shown.view = value;
    });
    createRenderEffect(blocker, value => {
      shown.blocker = value;
    });
  });
  guess(10);
  flush();
  setSource(1);
  flush();
  hide();
  flush();
  expect(shown).toEqual({ source: 1, view: "10", blocker: "visible" });
  hidden.resolve("hidden");
  await turn();
  expect(shown).toEqual({ source: 1, view: "hidden", blocker: "hidden" });
  answer.resolve(1);
  await turn();
});

it("a pending-only output publishes true without retaining its input hold", async () => {
  const answer = Promise.withResolvers<number>();
  const shown = { source: 0, pending: false };
  let setSource!: (value: number) => number;
  createRoot(dispose => {
    disposals.push(dispose);
    const [source, write] = createSignal(0);
    setSource = write;
    const input = createMemo(() => (source() === 0 ? 0 : answer.promise));
    createRenderEffect(source, value => {
      shown.source = value;
    });
    createRenderEffect(
      () => isPending(input),
      value => {
        shown.pending = value;
      }
    );
  });
  setSource(1);
  flush();
  expect(shown).toEqual({ source: 1, pending: true });
  answer.resolve(1);
  await turn();
  expect(shown).toEqual({ source: 1, pending: false });
});

it("a closed action stops waiting when its last override observer is disposed", async () => {
  const answer = Promise.withResolvers<number>(),
    end = Promise.withResolvers<void>();
  const shown = { source: 0, view: 0 };
  let setSource!: (value: number) => number, guess!: (value: number) => number, hide!: () => void;
  createRoot(dispose => {
    disposals.push(dispose);
    const [source, write] = createSignal(0);
    setSource = write;
    const input = createMemo(() => (source() === 0 ? 0 : answer.promise));
    const [view, propose] = createOptimistic(input);
    guess = propose;
    createRenderEffect(source, value => {
      shown.source = value;
    });
    createRoot(disposeObserver => {
      disposals.push(disposeObserver);
      hide = disposeObserver;
      createRenderEffect(view, value => {
        shown.view = value;
      });
    });
  });
  const running = action(function* () {
    setSource(1);
    guess(3);
    yield end.promise;
  })();
  flush();
  expect(shown).toEqual({ source: 0, view: 3 });
  end.resolve();
  await running;
  await turn();
  expect(shown.source).toBe(0);
  hide();
  flush();
  expect(shown.source).toBe(1);
  answer.resolve(1);
  await turn();
});
