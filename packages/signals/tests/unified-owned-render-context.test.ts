import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest,
  onCleanup
} from "../src/index.js";

for (const wrapped of [false, true])
  for (const observationFirst of [false, true])
    for (const depth of [0, 2])
      it(`a new binding retries its creator into a coherent context (wrapped=${wrapped}, observation first=${observationFirst}, depth=${depth})`, async () => {
        const end = Promise.withResolvers<void>();
        const calculations: number[][] = [];
        const frames: { text?: string; cleaned: number }[] = [];
        let shown: { text?: string; cleaned: number } | undefined;
        const app = createRoot(dispose => {
          const [id, setId] = createSignal(0);
          const observed = wrapped ? createMemo(() => latest(id)) : () => latest(id);
          const page = createMemo(() => {
            const captured = id();
            const element = { text: undefined as string | undefined, cleaned: 0 };
            frames.push(element);
            onCleanup(() => element.cleaned++);
            const bind = (remaining: number): void => {
              if (remaining) {
                createMemo(() => bind(remaining - 1));
                return;
              }
              createRenderEffect(
                () => {
                  let ahead: number;
                  if (observationFirst) ahead = observed();
                  const ordinary = id();
                  if (!observationFirst) ahead = observed();
                  calculations.push([captured, ordinary, ahead!]);
                  return `${captured}:${ordinary}`;
                },
                text => {
                  element.text = text;
                }
              );
            };
            bind(depth);
            return element;
          });
          createRenderEffect(page, element => {
            shown = element;
          });
          return { dispose, setId };
        });
        let running: Promise<unknown> | undefined;
        try {
          flush();
          expect(shown?.text).toBe("0:0");
          const initial = shown;
          running = action(function* () {
            app.setId(1);
            yield end.promise;
          })();
          flush();
          // Discovering latest retries the creator on committed id. Its
          // coherent replacement may publish while the lower action is open.
          expect(shown).not.toBe(initial);
          expect(initial?.cleaned).toBe(1);
          expect(shown?.text).toBe("0:0");
          // A completed child must agree with its creator, including when
          // the creator retried after the child discovered optimism.
          expect(
            calculations.filter(([captured]) => captured === 1).every(([, id]) => id === 1)
          ).toBe(true);
          // Check the observation too: preserving the captured input alone
          // must not allow latest to return an older version than id().
          expect(calculations.every(([, ordinary, ahead]) => ahead >= ordinary)).toBe(true);
          end.resolve();
          await running;
          flush();
          expect(shown).not.toBe(initial);
          expect(shown?.text).toBe("1:1");
          expect(calculations).toContainEqual([1, 1, 1]);
          expect(calculations.every(([, ordinary, ahead]) => ahead >= ordinary)).toBe(true);
        } finally {
          end.resolve();
          await running;
          app.dispose();
          flush();
          expect(frames.every(frame => frame.cleaned === 1)).toBe(true);
        }
      });
