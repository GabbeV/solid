import { expect, it } from "vitest";
import {
  createLoadingBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  refresh
} from "../src/index.js";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const reader of ["value", "pair", "split"] as const)
  for (const reask of [false, true])
    it(`an independently held latest answer publishes (${reader}, refresh=${reask})`, async () => {
      const stop = Promise.withResolvers<number>();
      const requests: { name: string; value: number; resolve: (v: number) => void }[] = [];
      const shown: number[] = [];
      const show = (value: number) => {
        if (shown.at(-1) !== value) shown.push(value);
      };
      const ask = (name: string, value: number) =>
        new Promise<number>(resolve => requests.push({ name, value, resolve }));
      const app = createRoot(dispose => {
        const [id, setId] = createSignal(1);
        const preview = createMemo(() => ask("preview", 1 + latest(id) + id()));
        const result = createMemo(() => ask("result", 100 + preview()));
        const hold = createMemo(() => (id() === 1 ? 1 : stop.promise));
        // This observer remains in the input update when the preview's
        // consumers move into their higher context.
        createRenderEffect(hold, () => {});
        createLoadingBoundary(
          () => {
            if (reader === "pair")
              createRenderEffect(
                () => (hold(), [isPending(result), result()] as const),
                ([, value]) => show(value)
              );
            else {
              if (reader === "split")
                createRenderEffect(
                  () => (hold(), isPending(result)),
                  () => {}
                );
              createRenderEffect(() => (hold(), result()), show);
            }
            return null;
          },
          () => null
        );
        return { dispose, setId, preview };
      });
      let answered = 0;
      const land = async (rounds = 8) => {
        for (let i = 0; i < rounds; i++) {
          const end = requests.length;
          while (answered < end) {
            const request = requests[answered++];
            request.resolve(request.value);
          }
          await turn();
        }
      };
      try {
        flush();
        await land();
        expect(shown).toEqual([103]);
        app.setId(2);
        flush();
        await land(1);
        expect(requests.some(r => r.name === "result" && r.value === 104)).toBe(true);
        if (reask) {
          refresh(app.preview);
          flush();
        }
        await land();
        expect(shown).toEqual([103, 104]);
        stop.resolve(1);
        await land();
        expect(shown).toEqual([103, 104, 105]);
      } finally {
        stop.resolve(1);
        app.dispose();
        flush();
      }
    });
