import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
import { $TARGET } from "../src/store/types.js";
import type { StoreTarget } from "../src/store/target.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
for (const keyed of [false, true])
  it(`reclaims nested parent companions after creator disposal and an async correction (keyed=${keyed})`, async () => {
    const references: WeakRef<StoreTarget>[] = [];
    const runCycle = async () => {
      const answer = Promise.withResolvers<any>();
      const gate = Promise.withResolvers<void>();
      const tracked: StoreTarget[] = [];
      let land!: () => void;
      let suspend!: () => void;
      const [state, setState, dispose] = createRoot(dispose => {
        const initial: any = keyed ? [] : { obj: { nested: { v: 0 } } };
        const [source, setSource] = createSignal<any>(initial);
        const [state, setState] = createOptimisticStore(() => source(), initial, {
          key: keyed ? "id" : null
        });
        suspend = () => setSource(answer.promise);
        land = () =>
          answer.resolve(keyed ? [{ id: 1, nested: { v: 2 } }] : { obj: { nested: { v: 2 } } });
        createRenderEffect(
          () => {
            const child = keyed ? state[0] : state.obj;
            if (child) {
              tracked.push(child[$TARGET], child.nested[$TARGET]);
              return child.nested.v;
            }
          },
          () => {}
        );
        return [state, setState, dispose] as const;
      });
      flush();
      const running = action(function* () {
        setState((d: any) => {
          if (keyed) d.push({ id: 1, nested: { v: 1 } });
          else d.obj = { nested: { v: 1 } };
        });
        yield gate.promise;
      })();
      try {
        flush();
        expect(tracked.length).toBeGreaterThan(0);
        suspend();
        flush();
        dispose();
        flush();
        gate.resolve();
        await running;
        land();
        await turn();
        flush();
        await turn();
        flush();
        const root: StoreTarget = state[$TARGET];
        for (const target of new Set([root, ...tracked])) {
          references.push(new WeakRef(target));
          expect(target.nc).toBe(0);
          expect(target.k?._subs ?? null).toBe(null);
          for (const node of Object.values(target.n ?? {})) expect(node._subs).toBe(null);
        }
      } finally {
        gate.resolve();
        land();
        await running;
        dispose();
        flush();
      }
    };
    for (let cycle = 0; cycle < 24; cycle++) await runCycle();
    // Replace the runtime's latest diagnostic frame before probing collection.
    createRoot(dispose => {
      createRenderEffect(
        () => 0,
        () => {}
      );
      dispose();
    });
    flush();
    if (typeof (globalThis as any).gc === "function") {
      for (let attempt = 0; attempt < 5; attempt++) {
        await turn();
        (globalThis as any).gc();
      }
      // The test/runtime may retain its most recent completed async frame.
      // Every earlier cycle must collect, rather than accumulating targets.
      const perCycle = keyed ? 3 : 5;
      expect(references.slice(0, -perCycle).filter(reference => reference.deref()).length).toBe(0);
    }
  });

for (const keyed of [false, true])
  it(`keeps late publications coherent after only the first reader disposes during a pending input (keyed=${keyed})`, async () => {
    const answer = Promise.withResolvers<any>();
    const gate = Promise.withResolvers<void>();
    const initial: any = keyed ? [] : { obj: { nested: { v: 0 } } };
    const [source, setSource] = createSignal<any>(initial);
    const [state, setState, disposeCreator] = createRoot(dispose => {
      const [state, setState] = createOptimisticStore(() => source(), initial, {
        key: keyed ? "id" : null
      });
      return [state, setState, dispose] as const;
    });
    const value = () => (keyed ? state[0] : state.obj)?.nested.v;
    const first: unknown[] = [],
      late: unknown[] = [];
    const disposeReader = createRoot(dispose => {
      createRenderEffect(value, v => {
        first.push(v);
      });
      return dispose;
    });
    flush();
    const running = action(function* () {
      setState((d: any) => {
        if (keyed) d.push({ id: 1, nested: { v: 1 } });
        else d.obj = { nested: { v: 1 } };
      });
      yield gate.promise;
    })();
    let disposeLate: (() => void) | undefined;
    try {
      flush();
      expect(first.at(-1)).toBe(1);
      setSource(answer.promise);
      flush();
      disposeReader();
      flush();
      gate.resolve();
      await running;
      flush();
      disposeLate = createRoot(dispose => {
        createRenderEffect(value, v => {
          late.push(v);
        });
        return dispose;
      });
      flush();
      if (late.length) expect(late.at(-1)).toBe(1);
      answer.resolve(keyed ? [{ id: 1, nested: { v: 2 } }] : { obj: { nested: { v: 2 } } });
      await turn();
      flush();
      expect(late.at(-1)).toBe(2);
    } finally {
      gate.resolve();
      answer.resolve(initial);
      await running;
      disposeReader();
      disposeLate?.();
      disposeCreator();
      flush();
    }
  });

for (const keyed of [false, true])
  it(`retains a published parent correction held by a consumer after display-reader disposal (keyed=${keyed})`, async () => {
    const consequence = Promise.withResolvers<number>();
    const gate = Promise.withResolvers<void>();
    const initial: any = keyed ? [] : { obj: { nested: { v: 0 } } };
    const [source, setSource] = createSignal<any>(initial);
    let value!: () => number | undefined;
    const [setState, disposeCreator] = createRoot(dispose => {
      const [state, setState] = createOptimisticStore(() => source(), initial, {
        key: keyed ? "id" : null
      });
      value = () => (keyed ? state[0] : state.obj)?.nested.v;
      const derived = createMemo(() => (value() === 2 ? consequence.promise : 0));
      createRenderEffect(derived, () => {});
      return [setState, dispose] as const;
    });
    const first: unknown[] = [],
      late: unknown[] = [];
    const disposeReader = createRoot(dispose => {
      createRenderEffect(value, v => {
        first.push(v);
      });
      return dispose;
    });
    flush();
    const running = action(function* () {
      setState((d: any) => {
        if (keyed) d.push({ id: 1, nested: { v: 1 } });
        else d.obj = { nested: { v: 1 } };
      });
      yield gate.promise;
    })();
    let disposeLate: (() => void) | undefined;
    try {
      flush();
      expect(first.at(-1)).toBe(1);
      setSource(keyed ? [{ id: 1, nested: { v: 2 } }] : { obj: { nested: { v: 2 } } });
      flush();
      gate.resolve();
      await running;
      await turn();
      flush();
      expect(first.at(-1)).toBe(1);
      disposeReader();
      flush();
      disposeLate = createRoot(dispose => {
        createRenderEffect(value, v => {
          late.push(v);
        });
        return dispose;
      });
      flush();
      expect(late.at(-1)).toBe(1);
      consequence.resolve(2);
      await turn();
      flush();
      expect(late.at(-1)).toBe(2);
    } finally {
      gate.resolve();
      consequence.resolve(2);
      await running;
      disposeReader();
      disposeLate?.();
      disposeCreator();
      flush();
    }
  });
