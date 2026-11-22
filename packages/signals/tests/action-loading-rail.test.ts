/**
 * A first request made against committed inputs may reveal during an action
 * (#2937). A request made against an action's proposal publishes with it.
 */
import {
  action,
  createEffect,
  createLoadingBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest,
  onCleanup
} from "../src/index.js";

const wait = (ms: number) => new Promise(r => setTimeout(r, ms));

function harness(log: string[]) {
  const [src, setSrc] = createSignal(1);
  const [isL, setIsL] = createSignal(false, { ownedWrite: 1 } as any);
  const [opt, setOpt] = createOptimistic(false);
  let resolveData!: (v: number) => void;
  let view: any;

  const dispose = createRoot(dispose => {
    const data = createMemo(() => {
      const s = src();
      return new Promise<number>(r => (resolveData = v => r(v + s)));
    });
    const b = createLoadingBoundary(
      () => "content:" + data(),
      () => {
        setIsL(true);
        onCleanup(() => {
          log.push("fallback-cleanup");
          setIsL(false);
        });
        return "fallback";
      }
    );
    createRenderEffect(b, value => {
      view = value;
    });
    return dispose;
  });
  flush();
  return {
    dispose,
    setSrc,
    setOpt,
    opt,
    isL,
    resolve: (v: number) => resolveData(v),
    view: () => view
  };
}

async function drive(mode: "in-step" | "adopted", preFlush: boolean) {
  const log: string[] = [];
  const h = harness(log);
  expect(h.view()).toBe("fallback"); // initial load: loading regime

  const p = (Promise as any).withResolvers();

  // Track fallback cleanup independently of the ordinary selection binding.
  const stop = createRoot(dispose => {
    createEffect(
      () => latest(h.isL),
      loading => {
        if (!loading) p.resolve();
      }
    );
    return dispose;
  });

  if (mode === "adopted") h.setSrc(2); // same tick, before the action call
  if (preFlush) flush();

  const run = action(function* () {
    h.setOpt(true);
    if (mode === "in-step") h.setSrc(2);
    yield p.promise;
    log.push("action:end");
  });
  const done = run();
  try {
    await wait(0);
    flush();
    h.resolve(100);
    await wait(0);
    flush();
    const alreadyCommitted = mode === "adopted" && preFlush;
    if (alreadyCommitted) {
      expect(h.view()).toBe("content:102");
      expect(log).toEqual(["fallback-cleanup", "action:end"]);
    } else {
      expect(h.view()).toBe("fallback");
      expect(log).toEqual([]);
      // The action cannot wait for its own reveal. Complete its external work.
      p.resolve();
    }
    await done;
    flush();
    expect(h.view()).toBe("content:102");
    expect(log).toEqual(
      alreadyCommitted ? ["fallback-cleanup", "action:end"] : ["action:end", "fallback-cleanup"]
    );
  } finally {
    p.resolve();
    stop();
    h.dispose();
  }
}

for (const mode of ["in-step", "adopted"] as const) {
  for (const preFlush of [false, true]) {
    it(`first reveal follows the input used by its request (${mode}, preFlush=${preFlush})`, () =>
      drive(mode, preFlush));
  }
}

it("same-tick writes before the action are still adopted into the transaction", async () => {
  // The optimistic-before-action idiom (covered in depth by the
  // createOptimistic suites) — a bare optimistic write in the same tick must
  // revert when the action settles, proving it joined the transaction.
  const [opt, setOpt] = createOptimistic(0);
  const p = (Promise as any).withResolvers();

  setOpt(1); // before the action call, same tick
  const run = action(function* () {
    yield p.promise;
  });
  const done = run();
  flush();
  expect(opt()).toBe(1); // held by the action's transaction

  p.resolve();
  await done;
  await Promise.resolve();
  flush();
  expect(opt()).toBe(0); // reverted at settle: it was the transaction's write
});
