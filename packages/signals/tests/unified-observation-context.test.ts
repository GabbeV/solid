import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  untrack
} from "../src/index.js";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const kind of [
  "pending",
  "pending callback",
  "pending memo",
  "latest",
  "latest callback",
  "latest memo",
  "optimistic",
  "optimistic memo"
] as const)
  for (const tracked of [false, true])
    for (const before of [false, true])
      for (const asynchronous of [false, true])
        it(`${kind} selects the whole reader context (tracked=${tracked}, observation first=${before}, async=${asynchronous})`, async () => {
          const end = Promise.withResolvers<void>();
          const shown: string[] = [];
          const calculations: string[] = [];
          const app = createRoot(dispose => {
            const [id, setId] = createSignal(0);
            const [revision, setRevision] = createSignal(0);
            const [optimistic, guess] = createOptimistic(id);
            const pending = createMemo(() => isPending(id));
            const latestMemo = createMemo(() => latest(id));
            const optimisticMemo = createMemo(() => optimistic());
            const observe =
              kind === "pending"
                ? () => isPending(id)
                : kind === "pending callback"
                  ? () => isPending(() => id())
                  : kind === "pending memo"
                    ? pending
                    : kind === "latest"
                      ? () => latest(id)
                      : kind === "latest callback"
                        ? () => latest(() => id())
                        : kind === "latest memo"
                          ? latestMemo
                          : kind === "optimistic memo"
                            ? optimisticMemo
                            : optimistic;
            const calculate = () => {
              revision();
              let observed: boolean | number | undefined;
              const sample = () => (observed = tracked ? observe() : untrack(observe));
              if (before) sample();
              const first = id();
              if (!before) sample();
              const second = id();
              const result = `${first}/${observed}/${second}`;
              calculations.push(result);
              return result;
            };
            const reader = createMemo(asynchronous ? async () => calculate() : calculate, {
              name: "context-reader"
            });
            createRenderEffect(id, () => {}, { schedule: true });
            createRenderEffect(reader, value => void shown.push(value), { schedule: true });
            const run = action(function* () {
              setId(1);
              if (kind.startsWith("optimistic")) guess(1);
              yield end.promise;
            });
            return { dispose, run, setRevision };
          });
          try {
            flush();
            await turn();
            const running = app.run();
            flush();
            await turn();
            calculations.length = 0;
            app.setRevision(1);
            flush();
            await turn();
            const expected = `0/${kind.startsWith("pending") ? true : 1}/0`;
            expect(calculations.length).toBeGreaterThan(0);
            for (const value of calculations) expect(value).toBe(expected);
            expect(shown.at(-1)).toBe(expected);
            end.resolve();
            await running;
            await turn();
            // untrack takes a snapshot; it does not pull a dirty wrapper or
            // subscribe to the wrapper's subsequent correction. Both ordinary
            // reads still belong to the same context. A later explicit rerun
            // samples the now-published false value.
            const snapshot = kind === "pending memo" && !tracked;
            expect(shown.at(-1)).toBe(`1/${kind.startsWith("pending") ? snapshot : 1}/1`);
            app.setRevision(2);
            flush();
            await turn();
            expect(shown.at(-1)).toBe(`1/${kind.startsWith("pending") ? false : 1}/1`);
          } finally {
            end.resolve();
            app.dispose();
            flush();
          }
        });
