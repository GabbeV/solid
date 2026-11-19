import { expect, it } from "vitest";
import {
  action,
  createEffect,
  createMemo,
  createOptimistic,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

for (const errorKind of ["same", "fresh", "undefined"] as const)
  it(`${errorKind} producer error is delivered once per distinct answer across an unrelated optimistic correction`, async () => {
    const a: string[] = [],
      b: string[] = [];
    const failure = new Error("failed");
    const errorText = errorKind === "undefined" ? "undefined" : "Error: failed";
    let sourceRuns = 0;
    let fail!: () => void, recover!: () => void, finish!: () => void, start!: () => any;
    createRoot(() => {
      const [bad, setBad] = createSignal(false);
      fail = () => setBad(true);
      recover = () => setBad(false);
      const producer = createMemo(() => {
        sourceRuns++;
        if (bad())
          throw errorKind === "undefined"
            ? undefined
            : errorKind === "fresh"
              ? new Error("failed")
              : failure;
        return undefined;
      });
      const [truthA] = createSignal(1),
        [truthB] = createSignal(2);
      const [viewA, proposeA] = createOptimistic(() => {
        producer();
        return truthA();
      });
      const [viewB] = createOptimistic(() => {
        producer();
        return truthB();
      });
      let resolve!: () => void;
      start = action(function* () {
        proposeA(9);
        yield new Promise<void>(r => {
          resolve = r;
        });
      });
      finish = () => resolve();
      createEffect(viewA, {
        effect: v => {
          a.push(String(v));
        },
        error: e => {
          a.push(String(e));
        }
      });
      createEffect(viewB, {
        effect: v => {
          b.push(String(v));
        },
        error: e => {
          b.push(String(e));
        }
      });
    });
    flush();
    start();
    flush();
    fail();
    flush();
    expect(a).toEqual(["1", "9"]);
    expect(b).toEqual(["2", errorText]);
    const runsAtError = sourceRuns;
    finish();
    await Promise.resolve();
    flush();
    expect(sourceRuns).toBeGreaterThan(runsAtError);
    expect(a).toEqual(["1", "9", errorText]);
    expect(b).toEqual(errorKind === "fresh" ? ["2", errorText, errorText] : ["2", errorText]);
    recover();
    flush();
    expect(a.at(-1)).toBe("1");
    expect(b.at(-1)).toBe("2");
  });
