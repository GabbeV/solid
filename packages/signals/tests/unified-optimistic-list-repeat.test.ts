import { it, expect } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  flush,
  refresh
} from "../src/index.js";
const turn = async () => {
  await new Promise(r => setTimeout(r, 0));
  flush();
};
type Row = { id: number; title: string };
it("adding after a filtered list input lands keeps the complete new row", async () => {
  let truth: Row[] = [
    { id: 1, title: "milk" },
    { id: 2, title: "eggs" }
  ];
  const fetches: ((value: Row[]) => void)[] = [];
  const gates: ReturnType<typeof Promise.withResolvers<void>>[] = [];
  const frames: string[] = [];
  const [rows, set, dispose] = createRoot(d => {
    const [rows, set] = createOptimisticStore(
      () => new Promise<Row[]>(r => fetches.push(r)),
      [] as Row[]
    );
    createRenderEffect(
      () => rows.map(r => r?.title ?? "HOLE").join(","),
      v => {
        frames.push(v);
      }
    );
    return [rows, set, d] as const;
  });
  const land = async () => {
    fetches.shift()!(structuredClone(truth));
    await turn();
  };
  const hold = (fn: (d: Row[]) => any, refreshAtEnd = false) => {
    const gate = Promise.withResolvers<void>();
    gates.push(gate);
    return action(function* () {
      set(fn);
      yield gate.promise;
      if (refreshAtEnd) refresh(rows);
    })();
  };
  try {
    flush();
    await land();
    hold(d => {
      d.push({ id: 3, title: "jam" });
    }, true);
    flush();
    truth.push({ id: 3, title: "jam" });
    gates[0].resolve();
    await turn();
    hold(d => d.filter(r => r.id !== 1));
    flush();
    hold(d => {
      d.push({ id: 4, title: "tea" });
    });
    flush();
    await land();
    hold(d => {
      d.push({ id: 5, title: "oats" });
    });
    flush();
    expect(frames.at(-1)).toBe("eggs,jam,tea,oats");
  } finally {
    for (const gate of gates) gate.resolve();
    while (fetches.length) fetches.shift()!(structuredClone(truth));
    await turn();
    dispose();
    flush();
  }
});
