import { expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const depth of [1, 3])
  it(`a correction error supersedes an unfinished override consequence at depth ${depth}`, async () => {
    const lifetime = Promise.withResolvers<void>();
    const obsolete = Promise.withResolvers<number>();
    const [fail, setFail] = createSignal(false);
    const frames: (number | string)[] = [];
    let guess!: (value: number) => unknown;
    let requests = 0;
    const dispose = createRoot(dispose => {
      let value = createMemo(() => {
        if (fail()) throw new Error("failed");
        return 0;
      });
      for (let level = 0; level < depth; level++) {
        const input = value;
        [value, guess] = createOptimistic(() => input());
      }
      const details = createMemo(() => {
        const n = value();
        if (n !== 10) return n;
        requests++;
        return obsolete.promise;
      });
      const view = createErrorBoundary(details, error => (error() as Error).message);
      createRenderEffect(view, value => void frames.push(value));
      return dispose;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      expect(frames).toEqual([0]);
      running = action(function* () {
        guess(10);
        yield lifetime.promise;
      })();
      flush();
      expect(requests).toBe(1);
      setFail(true);
      flush();
      expect(frames).toEqual([0]);
      expect(requests).toBe(1);

      lifetime.resolve();
      await running;
      await turn();
      expect(frames).toEqual([0, "failed"]);
      obsolete.resolve(10);
      await turn();
      expect(frames).toEqual([0, "failed"]);
      setFail(false);
      flush();
      expect(frames).toEqual([0, "failed", 0]);
    } finally {
      lifetime.resolve();
      await running;
      dispose();
      flush();
    }
  });
