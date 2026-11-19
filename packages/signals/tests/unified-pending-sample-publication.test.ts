import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  untrack
} from "../src/index.js";

for (const form of ["direct", "callback", "memo"] as const)
  for (const tracked of form === "memo" ? [false, true] : [true])
    it(`pending sample ${form}, tracked=${tracked}`, async () => {
      const answer = Promise.withResolvers<number>();
      const [id, setId] = createSignal(0);
      const [revision, setRevision] = createSignal(0);
      const frames: unknown[] = [];
      const samples: string[] = [];
      let shownId: unknown, shownData: unknown, shownPending: unknown, shownSample: unknown;
      const dispose = createRoot(dispose => {
        const data = createMemo(() => (id() === 0 ? 0 : answer.promise));
        const pending =
          form === "memo"
            ? createMemo(() => isPending(id))
            : form === "callback"
              ? () => isPending(() => id())
              : () => isPending(id);
        const sample = createMemo(() => {
          revision();
          const value = id();
          const label = `${value}:${tracked ? pending() : untrack(pending)}`;
          samples.push(label);
          return label;
        });
        createRenderEffect(id, value => {
          shownId = value;
        });
        createRenderEffect(data, value => {
          shownData = value;
        });
        createRenderEffect(
          () => isPending(id),
          value => {
            shownPending = value;
          }
        );
        createRenderEffect(sample, value => {
          shownSample = value;
        });
        return dispose;
      });
      const frame = () => frames.push([shownId, shownData, shownPending, shownSample]);
      try {
        flush();
        frame();
        setId(1);
        flush();
        frame();
        setRevision(1);
        flush();
        frame();
        answer.resolve(1);
        await new Promise(resolve => setTimeout(resolve, 0));
        flush();
        frame();
        expect([shownId, shownData, shownPending]).toEqual([1, 1, false]);
        // An untracked memo is sampled in the calculating update. Its answer
        // depends on whether the correction has calculated when id is read.
        const landing = samples.at(-1);
        expect(["1:true", "1:false"]).toContain(landing);
        expect(frames).toEqual([
          [0, 0, false, "0:false"],
          [0, 0, true, tracked ? "0:true" : "0:false"],
          [0, 0, true, "0:true"],
          [1, 1, false, tracked ? "1:false" : landing]
        ]);
      } finally {
        dispose();
        flush();
      }
    });

it("publishes the untracked sample taken by the label's own update", async () => {
  const gate = Promise.withResolvers<void>();
  const [source, setSource] = createSignal(0);
  const [id, setId] = createSignal(0);
  const labels: string[] = [];
  const statuses: boolean[] = [];
  const dispose = createRoot(dispose => {
    const pending = createMemo(() => isPending(source));
    const label = createMemo(() => id() + ":" + untrack(pending));
    createRenderEffect(pending, value => {
      statuses.push(value);
    });
    createRenderEffect(label, value => {
      labels.push(value);
    });
    return dispose;
  });
  try {
    flush();
    const running = action(function* () {
      setSource(1);
      yield gate.promise;
    })();
    flush();
    setId(1);
    flush();
    expect(labels).toEqual(["0:false", "1:true"]);
    gate.resolve();
    await running;
    flush();
    expect(statuses).toEqual([false, true, false]);
    expect(labels).toEqual(["0:false", "1:true"]);
  } finally {
    gate.resolve();
    dispose();
  }
});
