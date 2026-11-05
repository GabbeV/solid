import { expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

for (const withProbe of [false, true])
  for (const stream of [false, true])
    for (const held of [false, true])
      it(`latest forwards an error and recovers (probe=${withProbe}, stream=${stream}, held=${held})`, async () => {
        let start!: (value: boolean) => boolean,
          fail!: (error: Error) => void,
          dispose!: () => void;
        let data!: () => unknown[],
          screen: unknown,
          calls = 0,
          reset!: () => void;
        const end = Promise.withResolvers<void>();
        let running: Promise<unknown> | undefined;
        createRoot(cleanup => {
          dispose = cleanup;
          const [running, setRunning] = createSignal(false);
          start = setRunning;
          data = createMemo<unknown[]>(() => {
            calls++;
            if (!running()) return [];
            if (!stream)
              return new Promise<unknown[]>((_, reject) => {
                fail = reject;
              });
            return {
              [Symbol.asyncIterator]() {
                return {
                  next: () =>
                    new Promise<IteratorResult<unknown[]>>((_, reject) => {
                      fail = reject;
                    }),
                  return: async () => ({ done: true as const, value: undefined })
                };
              }
            };
          });
          const output = createErrorBoundary(
            () => {
              createRenderEffect(
                () => latest(data).length,
                () => {},
                { schedule: true }
              );
              if (withProbe)
                createRenderEffect(
                  () => isPending(data),
                  () => {},
                  { schedule: true }
                );
              return "content";
            },
            (error, retry) => {
              reset = retry;
              return (error() as Error).message;
            }
          );
          createRenderEffect(
            output,
            value => {
              screen = value;
            },
            { schedule: true }
          );
        });
        flush();
        try {
          if (held)
            running = action(function* () {
              start(true);
              yield end.promise;
            })();
          else start(true);
          flush();
          fail(new Error("failed"));
          await new Promise(resolve => setTimeout(resolve, 0));
          flush();
          expect(screen).toBe("failed");
          expect(calls).toBe(2);
          end.resolve();
          await running;
          start(false);
          flush();
          reset();
          flush();
          expect(screen).toBe("content");
        } finally {
          dispose();
          end.resolve();
          await running;
          flush();
        }
      });
