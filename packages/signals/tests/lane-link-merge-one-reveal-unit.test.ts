// #3335, #4757: coordinate outstanding proposals that meet in a reader.
import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

const tick = async () => {
  for (let i = 0; i < 8; i++) await Promise.resolve();
  flush();
};


it.each(["A", "C"] as const)("a new guess on %s while D is held", async which => {
  const end = Promise.withResolvers<void>();
  const actions: Promise<unknown>[] = [];
  const g = [0, 1, 2, 3].map(() => createOptimistic(0));
  const [open, setOpen] = createSignal(false);
  const seen: string[] = [];
  let resolveD: (v: number) => void = () => {};
  const dispose = createRoot(dispose => {
    const X = createMemo(() => g[0][0]() + g[1][0]());
    const Y = createMemo(() => g[2][0]() + g[3][0]());
    // D's own derivation in flight blocks lane D (lane rule 3).
    const dd = createMemo(async () => {
      const v = g[3][0]();
      return v === 0 ? v : new Promise<number>(r => (resolveD = r));
    });
    createRenderEffect(
      () => `X ${X()}`,
      v => void seen.push(v)
    );
    createRenderEffect(
      () => `Y ${Y()} dd ${dd()}`,
      v => void seen.push(v)
    );
    const Z = createMemo(() => (open() ? g[1][0]() + g[2][0]() : -1));
    createRenderEffect(
      () => `Z ${Z()}`,
      v => void seen.push(v)
    );
    return dispose;
  });
  try {
    flush();
    const acts = [0, 1, 2, 3].map(i =>
      action(function* (v: number) {
        g[i][1](v);
        yield end.promise;
      })
    );
    // A, B and C each publish while their actions remain open.
    for (let i = 0; i < 3; i++) {
      actions.push(acts[i](i + 1));
      flush();
      await tick();
    }
    actions.push(acts[3](4));
    flush();
    await tick();
    expect(seen).toEqual(["X 0", "Z -1", "X 1", "Y 0 dd 0", "X 3", "Y 3 dd 0"]);
    // Z reads the already published B and C. D still has no answer.
    setOpen(true);
    flush();
    await tick();
    expect(seen.slice(6)).toEqual(["Z 5"]);
    // Only C shares a memo with the outstanding proposal on D.
    actions.push(acts[which === "A" ? 0 : 2](10));
    flush();
    await tick();
    expect(seen.slice(7)).toEqual(which === "A" ? ["X 12"] : []);
    resolveD(4);
    await tick();
    await tick();
    expect(seen.slice(7).sort()).toEqual(
      which === "A" ? ["X 12", "Y 7 dd 4"] : ["Y 14 dd 4", "Z 12"]
    );
  } finally {
    dispose();
    end.resolve();
    await Promise.all(actions);
  }
});
