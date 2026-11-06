import { expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  untrack
} from "../src/index.js";

for (const inside of [false, true])
  for (const pending of ["none", "before", "after"] as const)
    for (const shared of [false, true])
      it(`a fresh Loading waits for its first binding (memo inside=${inside}, pending=${pending}, shared=${shared})`, async () => {
        const lifetime = Promise.withResolvers<void>();
        const [x, setX] = createSignal(0);
        const [open, setOpen] = createSignal(false);
        let shown = "",
          binding: unknown;
        const dispose = createRoot(dispose => {
          const branch = createMemo(() => {
            if (!open()) return "closed";
            const outer = inside ? undefined : createMemo(() => x());
            return createLoadingBoundary(
              () =>
                untrack(() => {
                  const data = outer ?? createMemo(() => x());
                  createRenderEffect(
                    () => {
                      if (pending === "before") return [isPending(data), data()];
                      const value = data();
                      return [pending === "after" ? isPending(data) : false, value];
                    },
                    value => {
                      binding = value;
                    },
                    { sync: true }
                  );
                  return "content";
                }),
              () => "fallback"
            );
          });
          createRenderEffect(
            () => {
              const value = branch();
              return typeof value === "function" ? value() : value;
            },
            value => {
              shown = value;
            }
          );
          return dispose;
        });
        let running: Promise<unknown> | undefined;
        try {
          flush();
          running = action(function* () {
            setX(1);
            if (shared) setOpen(true);
            yield lifetime.promise;
          })();
          flush();
          if (!shared) setOpen(true);
          flush();
          expect(shown).toBe(shared ? "closed" : "fallback");
          // A held creator can prepare its hidden subtree before attachment.
          // The independently mounted boundary must wait for its binding.
          if (!shared) expect(binding).toBeUndefined();
          lifetime.resolve();
          await running;
          await new Promise(resolve => setTimeout(resolve, 0));
          expect({ shown, binding }).toEqual({ shown: "content", binding: [false, 1] });
        } finally {
          lifetime.resolve();
          await running;
          dispose();
          flush();
        }
      });
