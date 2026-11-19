import { expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  flush,
  isPending
} from "../src/index.js";

const delay = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const initialError of [false, true])
  for (const held of [false, true])
    for (const memo of [false, true])
      it(`pending observes a store error through its boolean output (initial error=${initialError}, held=${held}, memo=${memo})`, async () => {
        const end = Promise.withResolvers<void>();
        const app = createRoot(dispose => {
          const [id, setId] = createSignal(initialError ? 1 : 0);
          const value = createMemo(() => {
            if (id() === 1) throw new Error("failed");
            return id();
          });
          const [store] = createStore<{ value: number }>(
            draft => {
              draft.value = value();
            },
            { value: 0 }
          );
          const frames: string[][] = [];
          for (const read of [value, () => store.value]) {
            const seen: string[] = [];
            frames.push(seen);
            const view = createErrorBoundary(
              () => {
                const probe = () => String(isPending(() => read()));
                return memo ? createMemo(probe)() : probe();
              },
              () => "error"
            );
            createRenderEffect(view, current => {
              seen.push(current);
            });
          }
          return { dispose, setId, frames };
        });
        let running: Promise<unknown> | undefined;
        try {
          flush();
          expect(app.frames).toEqual([["false"], ["false"]]);
          if (held)
            running = action(function* () {
              app.setId(initialError ? 0 : 1);
              yield end.promise;
            })();
          else app.setId(initialError ? 0 : 1);
          flush();
          expect(app.frames[1]).toEqual(app.frames[0]);
          expect(app.frames[1]).not.toContain("error");
          end.resolve();
          await running;
          await delay();
          flush();
          expect(app.frames[1]).toEqual(app.frames[0]);
          expect(app.frames[1]).not.toContain("error");
          expect(app.frames[1].at(-1)).toBe("false");
          app.setId(2);
          flush();
          expect(app.frames[1].at(-1)).toBe("false");
          expect(app.frames[1]).not.toContain("error");
        } finally {
          end.resolve();
          await running;
          app.dispose();
          flush();
        }
      });

for (const form of ["accessor", "callback", "store"] as const)
  it(`pending observes a held replacement error (${form})`, async () => {
    const end = Promise.withResolvers<void>();
    const app = createRoot(dispose => {
      const [id, setId] = createSignal(0);
      const source = createMemo<number>(() => {
        throw new Error(`error:${id()}`);
      });
      const [store] = createStore<{ value?: number }>(draft => {
        draft.value = source();
      }, {});
      const read =
        form === "accessor" ? source : form === "callback" ? () => source() : () => store.value;
      const output = createErrorBoundary(
        () => String(read()),
        error => (error() as Error).message
      );
      const values: string[] = [];
      const pending: boolean[] = [];
      createRenderEffect(output, v => void values.push(v));
      createRenderEffect(
        () => isPending(read),
        v => void pending.push(v)
      );
      return { dispose, setId, values, pending };
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      expect(app.values).toEqual(["error:0"]);
      running = action(function* () {
        app.setId(1);
        yield end.promise;
      })();
      flush();
      expect(app.values).toEqual(["error:0"]);
      expect(app.pending.at(-1)).toBe(true);
      end.resolve();
      await running;
      await delay();
      flush();
      expect(app.values).toEqual(["error:0", "error:1"]);
      expect(app.pending.at(-1)).toBe(false);
    } finally {
      end.resolve();
      await running;
      app.dispose();
      flush();
    }
  });
