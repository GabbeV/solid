import { expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createOptimistic,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  getOwner,
  runWithOwner
} from "../src/index.js";
const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
function fixture(
  kind: "scalar" | "store",
  newProperty: boolean,
  initialError: boolean,
  error: unknown
) {
  const frames: string[] = [];
  let fail!: () => void,
    recover!: () => void,
    mount!: () => void,
    start!: () => Promise<unknown>,
    finish = () => {},
    dispose!: () => void;
  createRoot(d => {
    dispose = d;
    const owner = getOwner();
    const [bad, setBad] = createSignal(initialError);
    fail = () => setBad(true);
    recover = () => setBad(false);
    const input = createMemo(() => {
      if (bad()) throw error;
      return 1;
    });
    let selected: () => any, truth: () => any, propose: () => void;
    if (kind === "scalar") {
      const [v, sv] = createOptimistic(() => {
        const value = input();
        return newProperty ? undefined : value;
      });
      selected = v;
      truth = input;
      propose = () => {
        sv(9);
      };
    } else {
      const [st, set] = createOptimisticStore(
        (d: any) => {
          d.v = input();
          d.sibling = 1;
        },
        { v: 0, sibling: 0 }
      );
      selected = () => (newProperty ? st.extra : st.v);
      truth = () => st.sibling;
      propose = () =>
        set(d => {
          if (newProperty) d.extra = 9;
          else d.v = 9;
        });
    }
    createErrorBoundary(
      () => {
        createRenderEffect(truth, () => {});
        return "source";
      },
      () => "ERR source"
    );
    mount = () =>
      runWithOwner(owner, () => {
        const boundary = createErrorBoundary(
          () => {
            createRenderEffect(selected, v => {
              frames.push(String(v));
            });
            return "ready";
          },
          () => "ERR"
        );
        createRenderEffect(boundary, v => {
          if (v === "ERR") frames.push(v);
        });
      });
    start = action(function* () {
      propose();
      yield new Promise<void>(r => (finish = r));
    });
  });
  return { frames, fail, recover, mount, start, finish: () => finish(), dispose };
}
for (const initialError of [false, true])
  for (const newProperty of [false, true])
    for (const error of [new Error("bad"), undefined])
      it(`first store proposal replaces ${initialError ? "initial error" : "error after a value"} (${newProperty ? "new property" : "untouched leaf"}, ${String(error)})`, async () => {
        const store = fixture("store", newProperty, initialError, error),
          scalar = fixture("scalar", newProperty, initialError, error);
        let storeAction: Promise<unknown> | undefined, scalarAction: Promise<unknown> | undefined;
        try {
          flush();
          if (!initialError) {
            store.fail();
            scalar.fail();
            await tick();
          }
          store.mount();
          scalar.mount();
          flush();
          expect(store.frames).toEqual(["ERR"]);
          expect(scalar.frames).toEqual(["ERR"]);
          storeAction = store.start();
          scalarAction = scalar.start();
          await tick();
          expect(store.frames).toEqual(["ERR", "9"]);
          expect(store.frames).toEqual(scalar.frames);
          store.finish();
          scalar.finish();
          await Promise.all([storeAction, scalarAction]);
          await tick();
          expect(store.frames).toEqual(["ERR", "9", "ERR"]);
          expect(store.frames).toEqual(scalar.frames);
          store.recover();
          scalar.recover();
          await tick();
          expect(store.frames).toEqual(["ERR", "9", "ERR", newProperty ? "undefined" : "1"]);
          expect(store.frames).toEqual(scalar.frames);
        } finally {
          store.finish();
          scalar.finish();
          store.dispose();
          scalar.dispose();
          await Promise.allSettled([storeAction, scalarAction]);
          flush();
        }
      });
