import { expect, it } from "vitest";
import {
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
          return `${value}:${tracked ? pending() : untrack(pending)}`;
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
        expect(frames).toEqual([
          [0, 0, false, "0:false"],
          [0, 0, true, tracked ? "0:true" : "0:false"],
          [0, 0, true, tracked ? "0:true" : "0:false"],
          [1, 1, false, tracked ? "1:false" : "1:true"]
        ]);
      } finally {
        dispose();
        flush();
      }
    });
