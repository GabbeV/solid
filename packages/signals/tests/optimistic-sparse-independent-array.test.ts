/**
 * Independent fixed-index outputs can compose a real sparse array: removing
 * an unguessed index does not fabricate a retained row or move another guess.
 * Every ordinary view must agree on presence, values and length. A push that
 * consumes another override's length still joins that owner's lifetime.
 */
import { afterEach, describe, expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  mapArray,
  resetErrorHalt
} from "../src/index.js";
const disposals: (() => void)[] = [];
const gates: ReturnType<typeof Promise.withResolvers<void>>[] = [];
const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
afterEach(async () => {
  for (const d of disposals.splice(0)) d();
  for (const gate of gates.splice(0)) gate.resolve();
  await tick();
  resetErrorHalt();
});
const gate = () => {
  const value = Promise.withResolvers<void>();
  gates.push(value);
  return value;
};

describe.each(
  ["index", "identity", "key"].flatMap(mode =>
    [false, true].map(wrapped => [mode, wrapped] as const)
  )
)("sparse outputs (%s, wrapped=%s)", (mode, wrapped) => {
  function observe(rows: string[]) {
    const frames: string[] = [];
    const serialize = () =>
      JSON.stringify({
        length: rows.length,
        keys: Object.keys(rows),
        own: Array.from({ length: rows.length }, (_, i) => Object.hasOwn(rows, i)),
        has: Array.from({ length: rows.length }, (_, i) => i in rows),
        indices: Array.from({ length: rows.length }, (_, i) => rows[i] ?? "<undefined>"),
        nativeMap: rows.map(value => value ?? "<undefined>"),
        iteration: Array.from(rows, value => value ?? "<undefined>")
      });
    const memo = createMemo(serialize);
    const source = wrapped ? createMemo(() => rows) : () => rows;
    const mapped =
      mode === "identity"
        ? mapArray(source, item => () => item ?? "<undefined>")
        : mode === "key"
          ? mapArray(source, item => () => item() ?? "<undefined>", { keyed: item => item })
          : mapArray(source, item => () => item() ?? "<undefined>", { keyed: false });
    const outputPairs: [string, string, string][] = [];
    createRenderEffect(
      () =>
        [
          serialize(),
          memo(),
          mapped()
            .map(value => value())
            .join("|")
        ] as [string, string, string],
      pair => {
        outputPairs.push(pair);
        frames.push(pair[0]);
      }
    );
    return { frames, outputPairs, last: () => JSON.parse(frames.at(-1)!) };
  }
  function expectDense(h: ReturnType<typeof observe>, values: string[]) {
    expect(h.last()).toEqual({
      length: values.length,
      keys: values.map((_, i) => String(i)),
      own: values.map(() => true),
      has: values.map(() => true),
      indices: values,
      nativeMap: values,
      iteration: values
    });
  }
  function expectSparse(h: ReturnType<typeof observe>) {
    expect(h.last()).toEqual({
      length: 2,
      keys: ["1"],
      own: [false, true],
      has: [false, true],
      indices: ["<undefined>", "M"],
      nativeMap: [null, "M"],
      iteration: ["<undefined>", "M"]
    });
  }
  function expectCoherent(h: ReturnType<typeof observe>) {
    for (const [direct, memo, mapped] of h.outputPairs) {
      expect(memo).toBe(direct);
      const frame = JSON.parse(direct);
      expect(mapped).toBe(frame.iteration.join("|"));
      expect(frame.keys).toEqual(
        frame.own.flatMap((own: boolean, i: number) => (own ? [String(i)] : []))
      );
      expect(frame.has).toEqual(frame.own);
    }
  }
  for (const edit of ["direct", "push", "returned"] as const)
    it(`independent source shrink removes an unguessed carried index (${edit})`, async () => {
      const done = gate();
      let setTruth!: (value: string[]) => void, run!: () => unknown, h!: ReturnType<typeof observe>;
      createRoot(dispose => {
        disposals.push(dispose);
        const [truth, set] = createSignal(["A"]);
        setTruth = set;
        const [rows, guess] = createOptimisticStore(() => truth(), []);
        h = observe(rows);
        run = action(function* () {
          guess(d => {
            if (edit === "direct") d[1] = "M";
            else if (edit === "push") d.push("M");
            else return ["A", "M"];
          });
          yield done.promise;
        });
      });
      await tick();
      expectDense(h, ["A"]);
      run();
      await tick();
      expectDense(h, ["A", "M"]);
      setTruth([]);
      await tick();
      expectSparse(h);
      expectCoherent(h);
      done.resolve();
      await tick();
      expectDense(h, []);
      expectCoherent(h);
    });
  for (const edit of ["direct", "push"] as const)
    it(`retiring another index override respects actual setter reads (${edit})`, async () => {
      const first = gate(),
        second = gate();
      let runFirst!: () => unknown, runSecond!: () => unknown, h!: ReturnType<typeof observe>;
      createRoot(dispose => {
        disposals.push(dispose);
        const [rows, set] = createOptimisticStore<string[]>([]);
        h = observe(rows);
        runFirst = action(function* () {
          set(d => void (d[0] = "A"));
          yield first.promise;
        });
        runSecond = action(function* () {
          set(d => {
            if (edit === "push") d.push("M");
            else d[1] = "M";
          });
          yield second.promise;
        });
      });
      await tick();
      runFirst();
      await tick();
      expectDense(h, ["A"]);
      runSecond();
      await tick();
      expectDense(h, ["A", "M"]);
      first.resolve();
      await tick();
      if (edit === "push") expectDense(h, ["A", "M"]);
      else expectSparse(h);
      expectCoherent(h);
      second.resolve();
      await tick();
      expectDense(h, []);
      expectCoherent(h);
    });
});
