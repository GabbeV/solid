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
  onCleanup
} from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

for (const kind of ["latest", "pending", "guess"] as const)
  for (const wrapped of [false, true])
    for (const roots of [0, 2])
      for (const delayed of [false, true])
        for (const render of [false, true, "async"] as const)
          it(`retries the creator when its child discovers another context (${kind}, memo=${wrapped}, roots=${roots}, delayed=${delayed}, render=${render})`, async () => {
            const end = Promise.withResolvers<void>();
            const answer = Promise.withResolvers<void>();
            const inputAnswer = Promise.withResolvers<void>();
            const captures: number[] = [];
            const completed: number[][] = [];
            const frames: { cleaned: number }[] = [];
            let shown: { value?: number[] } | undefined;
            const app = createRoot(dispose => {
              const [id, setId] = createSignal(0);
              const [visible, setVisible] = createSignal(false);
              const resource = delayed
                ? createMemo(() => (id() ? inputAnswer.promise.then(() => 1) : 0))
                : undefined;
              const [guessValue, guess] = createOptimistic(() => 0);
              const select =
                kind === "latest"
                  ? () => latest(id)
                  : kind === "pending"
                    ? () => Number(isPending(id))
                    : guessValue;
              const read = wrapped ? createMemo(select) : select;
              const slow = createMemo(() => {
                const value = read();
                return value ? answer.promise.then(() => value) : 0;
              });
              createRenderEffect(slow, () => {});
              const page = createMemo(() => {
                if (!visible()) return undefined;
                const captured = id();
                captures.push(captured);
                const frame: { cleaned: number; value?: number[] } = { cleaned: 0 };
                frames.push(frame);
                onCleanup(() => {
                  frame.cleaned++;
                });
                const build = (depth: number): void => {
                  if (depth) return createRoot(() => build(depth - 1));
                  const calculate = () => {
                    resource?.();
                    const before = id();
                    const observed = read();
                    const after = id();
                    const value = [captured, before, after, observed];
                    completed.push(value);
                    return value;
                  };
                  if (render === true)
                    createRenderEffect(calculate, value => {
                      frame.value = value;
                    });
                  else if (render === "async") {
                    const child = createMemo(async () => calculate());
                    createRenderEffect(child, value => {
                      frame.value = value;
                    });
                  } else frame.value = createMemo(calculate)();
                };
                build(roots);
                return frame;
              });
              createRenderEffect(
                page,
                value => {
                  shown = value;
                },
                { schedule: true }
              );
              return { dispose, setId, setVisible, guess };
            });
            flush();
            const running = action(function* () {
              app.setId(1);
              if (kind === "guess") app.guess(1);
              yield end.promise;
            })();
            await turn();
            try {
              app.setVisible(true);
              flush();
              expect(captures).toContain(1);
              if (delayed) {
                inputAnswer.resolve();
                await turn();
              }
              expect(
                completed.filter(
                  ([captured, before, after]) => captured !== before || before !== after
                )
              ).toEqual([]);
              expect(
                completed.filter(
                  ([captured, , , observed]) =>
                    captured === 1 && observed !== (kind === "pending" ? 0 : 1)
                )
              ).toEqual([]);
              answer.resolve();
              await turn();
              if (delayed) {
                // Suspension accepted the initial ordinary dependency set
                // before discovery. Its already-merged action stays open.
                expect(shown).toBeUndefined();
              } else {
                expect(shown?.value).toEqual([0, 0, 0, 1]);
                expect(captures).toContain(0);
              }
              end.resolve();
              await running;
              await turn();
              expect(shown?.value).toEqual([1, 1, 1, kind === "latest" ? 1 : 0]);
            } finally {
              end.resolve();
              inputAnswer.resolve();
              answer.resolve();
              await running;
              app.dispose();
              flush();
              expect(frames.every(frame => frame.cleaned === 1)).toBe(true);
            }
          });
