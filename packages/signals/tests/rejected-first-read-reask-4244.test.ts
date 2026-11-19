// #4244: rejecting the first answer must not manufacture an undefined value
// when the source is asked again. D-42 makes reactive-read try/catch an
// unsupported error channel, so use Error/Loading boundaries for publication.
// These pending/latest controls were first introduced during the shared-update
// audit; keep them with the original issue's ordinary boundary control.
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

const tick = (ms = 0) => new Promise(r => setTimeout(r, ms));
it("an error boundary keeps showing the first-read error while it is re-asked", async () => {
  const [n, setN] = createSignal(0);
  const log: unknown[] = [];
  const dispose = createRoot(dispose => {
    const m = createMemo(() =>
      n() === 0
        ? Promise.reject(new Error("boom"))
        : new Promise<string>(r => setTimeout(() => r("ok"), 20))
    );
    const view = createErrorBoundary(
      () =>
        createLoadingBoundary(
          () => `value:${m()}`,
          () => "loading"
        ),
      (e: () => unknown) => `caught:${(e() as Error)?.message}`
    );
    createRenderEffect(
      () => {
        const v = view();
        return typeof v === "function" ? (v as () => unknown)() : v;
      },
      v => {
        log.push(v);
      }
    );
    return dispose;
  });
  flush();
  await tick();
  flush();
  setN(1);
  flush();
  await tick();
  flush();
  expect(log).toEqual(["loading", "caught:boom"]);
  await tick(40);
  flush();
  expect(log).toEqual(["loading", "caught:boom", "value:ok"]);
  dispose();
});
