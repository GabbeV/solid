// #4485: writes that net to a signal's committed value in the tick an action
// opens a hold made no proposal (D-8), so a verdict reader of the signal
// shows `isPending(s)` false and is not re-run at the landing. It showed
// `true` for the whole hold and re-ran at the landing: its plain read took
// the `stagedScreen` arm before any netted check, which listed it as a stale
// reader of the flush's hold, and its probe was the seam's verdict
// (`provisionalVerdict`), not final (D-23 Status, #4469's family).
//
// Shared outputs: a netted write never publishes pending=true. Reading the
// unchanged false output does not change the reader's ordinary scheduling.
// The source's queued pass may still belong to the action's flush, as it
// does for an ordinary reader in next; its unchanged frame lands there.
import { describe, expect, it } from "vitest";
import {
  action,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";

const tick = async () => {
  await new Promise(r => setTimeout(r, 0));
  flush();
};

describe("#4485: a verdict reader of a signal whose writes net", () => {
  const net = async (where: "in-action" | "before-action" | "later-tick", pending = true) => {
    const [s, setS] = createSignal(1);
    const [x, setX] = createSignal(0);
    const runs: unknown[] = [];
    const dispose = createRoot(d => {
      createRenderEffect(x, () => {});
      createRenderEffect(
        () => [s(), pending ? isPending(s) : false],
        v => void runs.push(v)
      );
      return d;
    });
    flush();
    runs.length = 0;
    if (where === "before-action") (setS(2), setS(1));
    let release!: () => void;
    action(function* () {
      setX(1);
      if (where === "in-action") (setS(2), setS(1));
      yield new Promise<void>(r => (release = r));
    })();
    if (where === "later-tick") {
      await tick();
      setS(2);
      setS(1);
    }
    await tick();
    const held = runs.slice();
    release();
    await tick();
    await tick();
    dispose();
    return { held, runs };
  };

  it.each(["in-action", "before-action"] as const)(
    "pends nothing and follows the ordinary reader's publication (%s)",
    async where => {
      const { held, runs } = await net(where);
      // No pending proposal lifts this pass out of the ordinary flush.
      expect(held).toEqual([]);
      expect(runs).toEqual([[1, false]]);
      expect(await net(where, false)).toEqual({ held, runs });
    }
  );

  it("pends nothing in a later tick of the hold", async () => {
    const result = await net("later-tick");
    const { runs } = result;
    expect(runs).toEqual([[1, false]]);
    expect(await net("later-tick", false)).toEqual(result);
  });
});
