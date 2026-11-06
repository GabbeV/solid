import { expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";
import { $REFRESH } from "../src/core/constants.js";
import { context } from "../src/core/core.js";
import type { Computed } from "../src/core/types.js";
import { ordinaryValuePath } from "./helpers/pending-feedback-audit.js";

for (const callback of [false, true]) {
  it(`audits value-path attribution inside a pending-only callback=${callback}`, async () => {
    const answer = Promise.withResolvers<number>(),
      hide = Promise.withResolvers<boolean>();
    const paths: boolean[] = [];
    let dispose!: () => void, write!: (value: number) => number;
    try {
      createRoot(cleanup => {
        dispose = cleanup;
        const [id, setId] = createSignal(0);
        write = setId;
        const data = createMemo(() => (id() === 0 ? 0 : answer.promise));
        const indicator = createMemo<boolean>(previous => {
          if (isPending(callback ? () => data() : data)) return true;
          if (!previous) return false;
          // User code never reads data's value outside isPending. The callback
          // implementation nevertheless links a settled control-flow read.
          paths.push(ordinaryValuePath(context as Computed<any>, (data as any)[$REFRESH]));
          return hide.promise;
        });
        createRenderEffect(data, () => {}, { schedule: true });
        createRenderEffect(indicator, () => {}, { schedule: true });
      });
      flush();
      write(1);
      flush();
      await new Promise(resolve => setTimeout(resolve, 0));
      answer.resolve(10);
      await new Promise(resolve => setTimeout(resolve, 0));
      expect(paths.length).toBeGreaterThan(0);
      expect(paths.every(path => path === callback)).toBe(true);
      hide.resolve(false);
      await new Promise(resolve => setTimeout(resolve, 0));
    } finally {
      dispose?.();
      flush();
    }
  });
}
