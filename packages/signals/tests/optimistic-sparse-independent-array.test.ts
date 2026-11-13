/**
 * Array growth, shrink and index presence share a structural lifetime. Direct
 * growth and push both retain the complete selected array until their joined
 * updates settle. Every ordinary reader must agree on presence, values and
 * length; value-only writes to existing indices remain independent.
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
)("array structural outputs (%s, wrapped=%s)", (mode, wrapped) => {
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
  it("value-only writes to existing indices settle independently", async () => {
    const first = gate(),
      second = gate();
    const saved: [boolean, boolean][] = [];
    let runFirst!: () => unknown, runSecond!: () => unknown, h!: ReturnType<typeof observe>;
    createRoot(dispose => {
      disposals.push(dispose);
      const [rows, set] = createOptimisticStore<string[]>(["A", "B"]);
      h = observe(rows);
      const [firstSaved, setFirstSaved] = createSignal(false);
      const [secondSaved, setSecondSaved] = createSignal(false);
      createRenderEffect(
        () => [firstSaved(), secondSaved()] as [boolean, boolean],
        value => void saved.push(value)
      );
      runFirst = action(function* () {
        setFirstSaved(true);
        set(d => void (d[0] = "X"));
        yield first.promise;
      });
      runSecond = action(function* () {
        setSecondSaved(true);
        set(d => void (d[1] = "Y"));
        yield second.promise;
      });
    });
    await tick();
    runFirst();
    await tick();
    runSecond();
    await tick();
    expectDense(h, ["X", "Y"]);
    expect(saved.at(-1)).toEqual([false, false]);
    first.resolve();
    await tick();
    expectDense(h, ["A", "Y"]);
    expect(saved.at(-1)).toEqual([true, false]);
    second.resolve();
    await tick();
    expectDense(h, ["A", "B"]);
    expect(saved.at(-1)).toEqual([true, true]);
    expectCoherent(h);
  });
  for (const edit of ["direct", "push", "returned"] as const)
    it(`source shrink waits for an active structural edit (${edit})`, async () => {
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
      expectDense(h, ["A", "M"]);
      expectCoherent(h);
      done.resolve();
      await tick();
      expectDense(h, []);
      expectCoherent(h);
    });
  for (const edit of ["direct", "push"] as const)
    it(`direct growth and push join earlier structural edits (${edit})`, async () => {
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
      expectDense(h, ["A", "M"]);
      expectCoherent(h);
      second.resolve();
      await tick();
      expectDense(h, []);
      expectCoherent(h);
    });
});
