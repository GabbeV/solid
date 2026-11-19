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

const settle = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const asyncInput of [false, true])
  for (const heldReader of [false, true])
    it(`pending callback keeps the published branch (async=${asyncInput}, held reader=${heldReader})`, async () => {
      const answer = Promise.withResolvers<{ key: number }>();
      const lifetime = Promise.withResolvers<void>();
      const reads: [number, string][] = [];
      const shown: number[] = [];
      const expectReads = (key: number, branch: string) => {
        expect(reads.length).toBeGreaterThan(0);
        for (const value of reads) expect(value).toEqual([key, branch]);
      };
      const app = createRoot(dispose => {
        const [id, setId] = createSignal(0);
        const [revision, setRevision] = createSignal(0);
        const [left] = createSignal("left");
        const [right] = createSignal("right");
        const selected = createMemo(() =>
          id() === 0 ? { key: 0 } : asyncInput ? answer.promise : { key: 1 }
        );
        const sample = createMemo(() => {
          revision();
          if (heldReader) id();
          return untrack(() =>
            isPending(() => {
              const { key } = selected();
              reads.push([key, key === 0 ? left() : right()]);
            })
          );
        });
        createRenderEffect(selected, value => void shown.push(value.key));
        createRenderEffect(sample, () => {});
        const run = action(function* () {
          setId(1);
          yield lifetime.promise;
        });
        return { dispose, setRevision, run };
      });
      try {
        flush();
        expectReads(0, "left");
        const running = app.run();
        flush();
        reads.length = 0;
        app.setRevision(1);
        flush();
        expectReads(0, "left");
        expect(shown).toEqual([0]);

        answer.resolve({ key: 1 });
        await settle();
        reads.length = 0;
        app.setRevision(2);
        flush();
        expectReads(0, "left");
        expect(shown).toEqual([0]);

        lifetime.resolve();
        await running;
        await settle();
        expect(shown).toEqual([0, 1]);
        reads.length = 0;
        app.setRevision(3);
        flush();
        expectReads(1, "right");
      } finally {
        lifetime.resolve();
        answer.resolve({ key: 1 });
        app.dispose();
        flush();
      }
    });
