import { expect, it } from "vitest";
import {
  createErrorBoundary,
  createLoadingBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  resetErrorHalt
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const observation of ["pending", "latest"] as const)
  for (const firstValue of [false, true])
    it(`an observed first error recovers without publishing undefined (${observation}, previous value=${firstValue})`, async () => {
      const requests: ReturnType<typeof Promise.withResolvers<string>>[] = [];
      const [version, setVersion] = createSignal(0);
      const frames: unknown[] = [];
      const dispose = createRoot(dispose => {
        const data = createMemo(() => {
          version();
          const request = Promise.withResolvers<string>();
          requests.push(request);
          return request.promise;
        });
        const view = createErrorBoundary(
          () =>
            createLoadingBoundary(
              () => (observation === "latest" ? latest(data) : [isPending(data), data()]),
              () => "loading"
            ),
          error => `error:${(error() as Error).message}`
        );
        createRenderEffect(
          () => {
            const value = view();
            return typeof value === "function" ? value() : value;
          },
          value => {
            frames.push(value);
          }
        );
        return dispose;
      });
      try {
        flush();
        expect(frames).toEqual(["loading"]);
        if (firstValue) {
          requests.at(-1)!.resolve("first");
          await turn();
          flush();
          expect(frames.at(-1)).toEqual(observation === "latest" ? "first" : [false, "first"]);
          setVersion(1);
          flush();
        }
        requests.at(-1)!.reject(new Error("boom"));
        await turn();
        flush();
        expect(frames.at(-1)).toBe("error:boom");
        setVersion(2);
        flush();
        expect(frames.at(-1)).toBe("error:boom");
        requests.at(-1)!.resolve("recovered");
        await turn();
        flush();
        expect(frames.at(-1)).toEqual(
          observation === "latest" ? "recovered" : [false, "recovered"]
        );
        expect(frames.flat()).not.toContain(undefined);
      } finally {
        dispose();
        flush();
        resetErrorHalt();
      }
    });
