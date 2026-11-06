import { expect, it } from "vitest";
import {
  action,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  refresh
} from "../src/index.js";
const tick = () => new Promise<void>(resolve => setTimeout(resolve, 0));
for (const asyncInput of [false, true])
  it(`a save followed by refresh, without joining the incoming update (async=${asyncInput})`, async () => {
    const saved = Promise.withResolvers<void>();
    const requests: ReturnType<typeof Promise.withResolvers<string>>[] = [];
    const [id, setId] = createSignal(0);
    let view!: () => string, guess!: (v: string) => void;
    let shown: unknown;
    const dispose = createRoot(dispose => {
      [view, guess] = createOptimistic(() => {
        if (id() === 0) return "A";
        if (!asyncInput) return "B";
        const request = Promise.withResolvers<string>();
        requests.push(request);
        return request.promise;
      });
      createRenderEffect(
        () => [id(), view()],
        v => {
          shown = v;
        }
      );
      return dispose;
    });
    flush();
    const saving = action(function* () {
      guess("A + mine");
      yield saved.promise;
      yield refresh(view);
    })();
    try {
      flush();
      expect(shown).toEqual([0, "A + mine"]);
      setId(1);
      flush();
      expect(shown).toEqual([1, "A + mine"]);
      requests.at(-1)?.resolve("B");
      await tick();
      flush();
      expect(shown).toEqual([1, "A + mine"]);
      saved.resolve();
      await tick();
      flush();
      if (asyncInput) {
        expect(requests).toHaveLength(2);
        expect(shown).toEqual([1, "A + mine"]);
        requests.at(-1)!.resolve("B");
      }
      await saving;
      await tick();
      flush();
      expect(shown).toEqual([1, "B"]);
    } finally {
      saved.resolve();
      for (const r of requests) r.resolve("B");
      dispose();
      flush();
    }
  });
