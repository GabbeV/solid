import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  flush
} from "../src/index.js";
const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
for (const mode of ["replace-before-answer", "mutate-after-answer"] as const)
  it(`nested foreign store: ${mode}`, async () => {
    const input = Promise.withResolvers<void>(),
      end = Promise.withResolvers<void>();
    const frames: string[] = [];
    let dispose!: () => void, write!: (fn: (d: any) => void) => void, read!: () => any;
    let running: Promise<unknown> | undefined,
      getterCalls = 0;
    createRoot(d => {
      dispose = d;
      const [inner] = createOptimisticStore(
        async (d: any) => {
          await input.promise;
          d.x = 2;
          d.untouched = 3;
          Object.defineProperty(d, "doubled", {
            get() {
              getterCalls++;
              return this.x * 2;
            },
            configurable: true,
            enumerable: true
          });
        },
        { x: -111, untouched: -333 }
      );
      const [outer, set] = createOptimisticStore(() => ({ child: inner }), {
        child: { x: -222, untouched: -444 }
      });
      write = set;
      read = () => outer.child;
      createRenderEffect(
        () => {
          const child = outer.child;
          return `${child.x}/${String(child.untouched)}/${Object.keys(child).join(",")}`;
        },
        v => {
          frames.push(v);
        }
      );
    });
    try {
      flush();
      expect(frames).toEqual([]);
      if (mode === "mutate-after-answer") {
        input.resolve();
        await tick();
        expect(frames.at(-1)).toBe("2/3/x,untouched,doubled");
      }
      const before = getterCalls;
      running = action(function* () {
        write(d => {
          if (mode === "replace-before-answer") d.child = { x: 9 };
          else d.child.x = 9;
        });
        yield end.promise;
      })();
      running.catch(() => {});
      await tick();
      expect(getterCalls).toBe(before);
      expect(frames.at(-1)).toBe(
        mode === "replace-before-answer" ? "9/undefined/x" : "9/3/x,untouched,doubled"
      );
      if (mode === "mutate-after-answer") expect(read().doubled).toBe(18);
      input.resolve();
      await tick();
      expect(frames.at(-1)).toBe(
        mode === "replace-before-answer" ? "9/undefined/x" : "9/3/x,untouched,doubled"
      );
      end.resolve();
      await running;
      await tick();
      expect(frames.at(-1)).toBe("2/3/x,untouched,doubled");
      expect(frames.some(v => /-111|-222|-333|-444/.test(v))).toBe(false);
    } finally {
      input.resolve();
      end.resolve();
      dispose();
      await Promise.allSettled([running]);
      flush();
    }
  });
