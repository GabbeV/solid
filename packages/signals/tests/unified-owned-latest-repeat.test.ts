import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest
} from "../src/index.js";

for (const wrapped of [false, true])
  for (const observationFirst of [false, true])
    for (const depth of [0, 2])
      it(`a repeated write keeps latest current in new owned bindings (wrapped=${wrapped}, observation first=${observationFirst}, depth=${depth})`, async () => {
        const end = Promise.withResolvers<void>();
        const next = Promise.withResolvers<void>();
        const calculations: number[][] = [];
        let shown: { text?: string } | undefined;
        const app = createRoot(dispose => {
          const [id, setId] = createSignal(0);
          const observed = wrapped ? createMemo(() => latest(id)) : () => latest(id);
          const page = createMemo(() => {
            const captured = id();
            const element: { text?: string } = {};
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
            yield next.promise;
            app.setId(2);
            yield end.promise;
          })();
          flush();
          expect(shown).toBe(initial);
          expect(shown?.text).toBe("0:0");
          // Old-frame bindings may observe latest independently. A binding
          // created from the ordinary proposal belongs to its new frame.
          expect(
            calculations.filter(([captured]) => captured === 1).every(([, id]) => id === 1)
          ).toBe(true);
          // Check the observation too: preserving the captured input alone
          // must not allow latest to return an older version than id().
          expect(calculations.every(([, ordinary, ahead]) => ahead >= ordinary)).toBe(true);
          next.resolve();
          await new Promise(resolve => setTimeout(resolve, 0));
          flush();
          expect(calculations.every(([, ordinary, ahead]) => ahead >= ordinary)).toBe(true);
          expect(calculations.every(([captured, ordinary]) => captured === ordinary)).toBe(true);
          end.resolve();
          await running;
          flush();
          expect(shown).not.toBe(initial);
          expect(shown?.text).toBe("2:2");
          expect(calculations).toContainEqual([2, 2, 2]);
          expect(calculations.every(([, ordinary, ahead]) => ahead >= ordinary)).toBe(true);
        } finally {
          next.resolve();
          end.resolve();
          await running;
          app.dispose();
          flush();
        }
      });
