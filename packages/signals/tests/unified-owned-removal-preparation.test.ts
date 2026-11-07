import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

for (const roots of [0, 2])
  for (const asyncChild of [false, true])
    for (const supersede of [false, true])
      it(`preparation does not execute a child its update removes (roots=${roots}, async=${asyncChild}, supersede=${supersede})`, async () => {
        const guessEnd = Promise.withResolvers<void>();
        const ownerEnd = Promise.withResolvers<void>();
        const answer = Promise.withResolvers<number>();
        const bodies: number[][] = [];
        const frames: { text?: string; cleaned: number }[] = [];
        let shown: (typeof frames)[number] | undefined;
        let detailShown = 0;
        const app = createRoot(dispose => {
          const [generation, setGeneration] = createSignal(1);
          const [view, guess] = createOptimistic(() => 0);
          const detail = createMemo(() => (view() ? answer.promise : 0));
          const page = createMemo(() => {
            const captured = generation();
            const frame: (typeof frames)[number] = { cleaned: 0 };
            frames.push(frame);
            onCleanup(() => frame.cleaned++);
            const build = (depth: number): void => {
              if (depth) return createRoot(() => build(depth - 1));
              const child = createMemo(() => {
                const values = [captured, generation(), view()];
                // This represents arguments used to start a request too: it
                // must not run with mixed inputs even if never published.
                bodies.push(values);
                return asyncChild ? Promise.resolve(values.join(":")) : values.join(":");
              });
              createRenderEffect(
                child,
                text => {
                  frame.text = text;
                },
                { schedule: true }
              );
            };
            build(roots);
            return frame;
          });
          createRenderEffect(
            page,
            frame => {
              shown = frame;
            },
            { schedule: true }
          );
          createRenderEffect(
            detail,
            value => {
              detailShown = value;
            },
            { schedule: true }
          );
          return { dispose, guess, setGeneration };
        });
        flush();
        await turn();
        expect(shown?.text).toBe("1:1:0");
        const guessing = action(function* () {
          app.guess(1);
          yield guessEnd.promise;
        })();
        await turn();
        const changing = action(function* () {
          app.setGeneration(2);
          yield ownerEnd.promise;
        })();
        await turn();
        try {
          expect([detailShown, shown?.text]).toEqual([0, "1:1:0"]);
          answer.resolve(1);
          await turn();
          expect([detailShown, shown?.text]).toEqual([1, "1:1:1"]);
          if (supersede) {
            app.setGeneration(3);
            await turn();
            expect(shown?.text).toBe("1:1:1");
          }
          ownerEnd.resolve();
          await changing;
          await turn();
          expect(shown?.text).toBe(supersede ? "3:3:1" : "2:2:1");
          expect(bodies.filter(([captured, current]) => captured !== current)).toEqual([]);
          guessEnd.resolve();
          await guessing;
          await turn();
          expect(shown?.text).toBe(supersede ? "3:3:0" : "2:2:0");
          expect(bodies.filter(([captured, current]) => captured !== current)).toEqual([]);
        } finally {
          app.dispose();
          answer.resolve(1);
          ownerEnd.resolve();
          guessEnd.resolve();
          await Promise.all([changing, guessing]);
          await turn();
          expect(frames.every(frame => frame.cleaned === 1)).toBe(true);
        }
      });
