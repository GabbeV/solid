import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest,
  onCleanup,
  untrack
} from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

// The oracle concerns complete calculations, not the order of sibling effects.
// A private child reading its creator's proposal must never pair it with an
// older latest value, even before that creator accepts its tentative joins.
for (const wrapped of [false, true])
  for (const observationFirst of [false, true])
    for (const roots of [0, 2])
      for (const untracked of [false, true])
        it(`a private frame inherits tentative peer inputs coherently (memo=${wrapped}, latest first=${observationFirst}, roots=${roots}, untracked=${untracked})`, async () => {
          const aEnd = Promise.withResolvers<void>();
          const bEnd = Promise.withResolvers<void>();
          const answer = Promise.withResolvers<void>();
          const calculations: number[][] = [];
          const frames: { value: number; cleaned: number; text?: string }[] = [];
          let shown: (typeof frames)[number] | undefined;
          let latestShown = 0;
          const app = createRoot(dispose => {
            const [a, setA] = createSignal(0);
            const [b, setB] = createSignal(0);
            const [open, setOpen] = createSignal(false);
            const ahead = wrapped ? createMemo(() => latest(a)) : () => latest(a);
            // This observation has a ready proposal, but its output is held by
            // an ordinary async consequence. It still publishes 0 at the mount.
            const slow = createMemo(() => {
              const value = ahead();
              return value ? answer.promise.then(() => value) : 0;
            });
            createRenderEffect(ahead, value => {
              latestShown = value;
            });
            createRenderEffect(slow, () => {});
            const page = createMemo(() => {
              if (!open()) return undefined;
              const sample = () => a() + b();
              const value = untracked ? untrack(sample) : sample();
              const frame = { value, cleaned: 0, text: undefined as string | undefined };
              frames.push(frame);
              onCleanup(() => {
                frame.cleaned++;
              });
              const mount = (depth: number): void => {
                if (depth) {
                  createRoot(() => mount(depth - 1));
                  return;
                }
                createRenderEffect(
                  () => {
                    let proposed: number;
                    if (observationFirst) proposed = ahead();
                    const first = a(),
                      second = b();
                    if (!observationFirst) proposed = ahead();
                    calculations.push([value, first, second, proposed!]);
                    return `${first}:${second}`;
                  },
                  text => {
                    frame.text = text;
                  }
                );
              };
              mount(roots);
              return frame;
            });
            createRenderEffect(
              page,
              value => {
                shown = value;
              },
              { schedule: true }
            );
            return { dispose, setA, setB, setOpen };
          });
          const aRunning = action(function* () {
            app.setA(1);
            yield aEnd.promise;
          })();
          flush();
          const bRunning = action(function* () {
            app.setB(2);
            yield bEnd.promise;
          })();
          flush();
          try {
            expect(latestShown).toBe(0);
            app.setOpen(true);
            flush();
            expect(shown).toBeUndefined();
            expect(calculations.length).toBeGreaterThan(0);
            expect(calculations.filter(([sum, a, b, ahead]) => sum !== a + b || ahead < a)).toEqual(
              []
            );
            expect(calculations).toContainEqual([3, 1, 2, 1]);
            answer.resolve();
            await turn();
            aEnd.resolve();
            await aRunning;
            await turn();
            expect(shown).toBeUndefined();
            bEnd.resolve();
            await bRunning;
            await turn();
            expect(shown?.text).toBe("1:2");
            expect(calculations.filter(([sum, a, b, ahead]) => sum !== a + b || ahead < a)).toEqual(
              []
            );
          } finally {
            app.dispose();
            aEnd.resolve();
            bEnd.resolve();
            answer.resolve();
            await Promise.all([aRunning, bRunning]);
            await turn();
            expect(frames.every(frame => frame.cleaned === 1)).toBe(true);
          }
        });
