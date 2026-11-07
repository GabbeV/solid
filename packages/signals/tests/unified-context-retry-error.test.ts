import { expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flatten,
  flush,
  isPending,
  latest,
  NotReadyError
} from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

for (const kind of ["latest", "pending", "guess"] as const)
  for (const shape of ["local", "child", "async child"] as const)
    for (const swallow of [false, true])
      it(`a caught context suspension still retries (${kind}, ${shape}, swallow=${swallow})`, async () => {
        const end = Promise.withResolvers<void>();
        const caught: unknown[] = [];
        const errors: unknown[] = [];
        const applied: number[][] = [];
        let shown: { value?: number[] } | string | undefined;
        const app = createRoot(dispose => {
          const [id, setId] = createSignal(0);
          const [visible, setVisible] = createSignal(false);
          const [guessValue, guess] = createOptimistic(() => 0);
          const observe =
            kind === "latest"
              ? () => latest(id)
              : kind === "pending"
                ? () => Number(isPending(id))
                : guessValue;
          // Keep the selected output alive before mounting the catching reader.
          createRenderEffect(observe, () => {});
          const page = createMemo(() => {
            if (!visible()) return;
            const captured = shape === "local" ? undefined : id();
            const frame: { value?: number[] } = {};
            const calculate = () => {
              const before = id();
              try {
                const selected = observe();
                return [captured ?? before, before, id(), selected];
              } catch (error) {
                caught.push(error);
                if (!(error instanceof NotReadyError) || !swallow) throw error;
                // This is the abandoned attempt's answer, not a publishable
                // substitute for completing in the selected update context.
                return [-99];
              }
            };
            if (shape === "local") frame.value = calculate();
            else {
              const child = createMemo(
                shape === "async child" ? async () => calculate() : calculate
              );
              createRenderEffect(child, value => {
                applied.push(value);
                frame.value = value;
              });
            }
            return frame;
          });
          const guarded = createErrorBoundary(page, error => {
            errors.push(error());
            return "error";
          });
          createRenderEffect(
            guarded,
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
          await turn();
          expect(caught.length).toBeGreaterThan(0);
          expect(caught.every(error => error instanceof NotReadyError)).toBe(true);
          expect(errors).toEqual([]);
          expect(typeof shown).toBe("object");
          expect((shown as { value?: number[] }).value).toEqual([0, 0, 0, 1]);
          expect(applied).not.toContainEqual([-99]);
          end.resolve();
          await running;
          await turn();
          expect((shown as { value?: number[] }).value).toEqual([
            1,
            1,
            1,
            kind === "latest" ? 1 : 0
          ]);
          expect(errors).toEqual([]);
          expect(applied).not.toContainEqual([-99]);
        } finally {
          end.resolve();
          await running;
          app.dispose();
          flush();
        }
      });

for (const observe of [latest, isPending])
  it(`flatten stops visiting children at a context suspension (${observe.name})`, async () => {
    const end = Promise.withResolvers<void>();
    const [id, setId] = createSignal(0);
    const tails: number[][] = [];
    let shown: unknown;
    let dispose = () => {};
    const running = action(function* () {
      setId(1);
      yield end.promise;
    })();
    flush();
    try {
      createRoot(stop => {
        dispose = stop;
        const value = createMemo(() => {
          const before = id();
          return flatten([
            () => observe(id),
            () => {
              tails.push([before, id()]);
              return id();
            }
          ]);
        });
        createRenderEffect(value, value => {
          shown = value;
        });
      });
      await turn();
      expect(tails.length).toBeGreaterThan(0);
      expect(tails.every(([before, after]) => before === 0 && after === 0)).toBe(true);
      expect(shown).toEqual([observe === latest ? 1 : true, 0]);
    } finally {
      dispose();
      end.resolve();
      await running;
      flush();
    }
  });
