/**
 * #3147 — deep()/snapshot readers and per-key readers must agree while a
 * transaction holds store landings.
 *
 * deep()/snapshot compose from store backings; per-key reads answer through
 * node/backing visibility. A truth landing on unguessed indices must agree
 * across those reader families while an action retains a different index.
 *
 * Ruling pinned here: deep()/snapshot and per-key readers compose the same
 * selected outputs. An independent truth write can publish at indices 0-2
 * while an action still owns an index-3 guess; deep itself does not merge
 * those otherwise independent lifetimes.
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

describe("#3147: reader families agree across independent index lifetimes", () => {
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

    // Truth for indices 0-2 lands independently while the index-3 guess
    // stays selected. Every reader family observes the same mixed frame.
    resolveTruth();
    await settle();
    expect(keyLog.at(-1)).toBe("[3,2,1,1111]");
    expect(deepLog.at(-1)).toBe("[3,2,1,1111]");

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
