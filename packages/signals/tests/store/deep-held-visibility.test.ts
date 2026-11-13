/**
 * #3147 — deep()/snapshot readers and per-key readers must agree while a
 * transaction holds store landings. An optimistic append owns structure;
 * the incoming array landing joins its lifetime and reveals as one frame.
 * Reader choice itself does not add coordination.
 */
import { describe, expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  deep,
  flush,
  snapshot
} from "../../src/index.js";

const settle = async (n = 3) => {
  for (let i = 0; i < n; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};

describe("#3147: reader families agree across a structural array lifetime", () => {
  it("deep() composes the same view as per-key reads through the hold and the reveal", async () => {
    let resolveTruth!: () => void;
    const truth = new Promise<void>(r => (resolveTruth = r));
    let resolveGate!: () => void;
    const gate = new Promise<void>(r => (resolveGate = r));

    const keyLog: string[] = [];
    const deepLog: string[] = [];
    const snapLog: string[] = [];
    let state!: { list: number[] };
    let setState!: (fn: (s: { list: number[] }) => void) => void;
    let run!: () => Promise<unknown>;
    let dispose!: () => void;

    createRoot(d => {
      dispose = d;
      [state, setState] = createOptimisticStore<{ list: number[] }>(
        async function* () {
          yield { list: [1, 2, 3] };
          await truth;
          yield { list: [3, 2, 1] };
        },
        { list: [] }
      );
      run = action(function* () {
        // The optimistic edit retains the transaction on the family: the
        // truth landing below folds into it instead of revealing.
        setState(s => {
          s.list.push(1111);
        });
        yield gate;
      });
      createRenderEffect(
        () => JSON.stringify(state.list),
        v => {
          keyLog.push(v);
        }
      );
      createRenderEffect(
        () => JSON.stringify(deep(state).list),
        v => {
          deepLog.push(v);
        }
      );
      // snapshot() from the same tracked scope must agree with deep().
      createRenderEffect(
        () => `${JSON.stringify(deep(state).list)}|${JSON.stringify(snapshot(state).list)}`,
        v => {
          snapLog.push(v);
        }
      );
    });
    flush();
    await settle();
    expect(keyLog.at(-1)).toBe("[1,2,3]");
    expect(deepLog.at(-1)).toBe("[1,2,3]");

    const done = run();
    flush();
    await settle();
    // Optimistic frame in both reader families.
    expect(keyLog.at(-1)).toBe("[1,2,3,1111]");
    expect(deepLog.at(-1)).toBe("[1,2,3,1111]");

    // The append owns array structure, so the incoming landing waits.
    // Every reader family retains the complete selected optimistic frame.
    resolveTruth();
    await settle();
    expect(keyLog.at(-1)).toBe("[1,2,3,1111]");
    expect(deepLog.at(-1)).toBe("[1,2,3,1111]");

    // Settle: atomic reveal, override reverts, landed truth shows — in both.
    resolveGate();
    await done;
    await settle();
    expect(keyLog.at(-1)).toBe("[3,2,1]");
    expect(deepLog.at(-1)).toBe("[3,2,1]");

    // At no point may the families disagree (dedupe: the deep observer may
    // legitimately fire more often).
    const dedupe = (log: string[]) => log.filter((v, i) => v !== log[i - 1]);
    expect(dedupe(deepLog)).toEqual(dedupe(keyLog));
    // deep() and snapshot() from the same scope always agree with each other.
    for (const frame of snapLog) {
      const [d, s] = frame.split("|");
      expect(d).toBe(s);
    }
    dispose();
    flush();
  });
});
