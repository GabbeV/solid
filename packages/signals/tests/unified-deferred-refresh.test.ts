import { expect, it } from "vitest";
import {
  createDeferred,
  createMemo,
  createRenderEffect,
  createRoot,
  flush,
  refresh,
  type SourceAccessor
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const indirect of [false, true])
  for (const answer of [0, 2])
    it(`refresh waits for a superseding deferred answer (indirect=${indirect}, answer=${answer})`, async () => {
      const first = Promise.withResolvers<number>();
      const second = Promise.withResolvers<number>();
      let proposed: number | Promise<number> = 0;
      let rows!: SourceAccessor<number>, doubled!: SourceAccessor<number>;
      const frames: number[][] = [];
      const delivered: number[] = [];
      const dispose = createRoot(dispose => {
        rows = createDeferred(() => proposed);
        doubled = createMemo(() => rows() * 2);
        createRenderEffect(
          () => [rows(), doubled()],
          value => void frames.push(value)
        );
        return dispose;
      });
      try {
        flush();
        expect(frames).toEqual([[0, 0]]);
        proposed = first.promise;
        const original = refresh(rows);
        const waiting = (indirect ? refresh(doubled) : original).then(value =>
          delivered.push(value)
        );
        await turn();
        expect(delivered).toEqual([]);
        expect(frames).toEqual([[0, 0]]);

        proposed = second.promise;
        const replacement = refresh(rows);
        await turn();
        first.resolve(99);
        await turn();
        expect(delivered).toEqual([]);
        expect(frames).toEqual([[0, 0]]);

        second.resolve(answer);
        await turn();
        expect(delivered).toEqual([indirect ? answer * 2 : answer]);
        expect(frames).toEqual(
          answer === 0
            ? [[0, 0]]
            : [
                [0, 0],
                [2, 4]
              ]
        );
        expect(await original).toBe(answer);
        expect(await replacement).toBe(answer);
        await waiting;
      } finally {
        dispose();
        flush();
      }
    });
