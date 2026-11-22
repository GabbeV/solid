import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

for (const observation of ["latest", "isPending"] as const)
  for (const replacement of [
    "cached",
    "slow",
    "cached after suspended preview",
    "unrelated action",
    "action held"
  ] as const)
    it(`${observation} replacing a pending page with a ${replacement} page`, async () => {
      const [id, setId] = createSignal(0);
      const [saved, setSaved] = createSignal(false);
      const actionEnd = Promise.withResolvers<void>();
      const requests: { id: number; answer: PromiseWithResolvers<string> }[] = [];
      const runs: number[] = [];
      const shown: string[] = [];
      const dispose = createRoot(dispose => {
        const page = createMemo(() => {
          const key = id();
          const next = observation === "latest" ? latest(id) : isPending(id);
          runs.push(key);
          if (key === 0) {
            if (next && replacement === "cached after suspended preview") {
              const answer = Promise.withResolvers<string>();
              requests.push({ id: 0, answer });
              return answer.promise;
            }
            return next ? "Loading " + next : "Home";
          }
          if (key === 2 && replacement !== "slow") return "Page 2";
          const answer = Promise.withResolvers<string>();
          requests.push({ id: key, answer });
          return answer.promise;
        });
        createRenderEffect(saved, () => {});
        createRenderEffect(page, value => void shown.push(value));
        return dispose;
      });
      try {
        flush();
        if (replacement === "action held") {
          action(function* () {
            setId(1);
            yield actionEnd.promise;
          })();
        } else setId(1);
        flush();
        expect(shown.at(-1)).toBe(
          replacement === "cached after suspended preview"
            ? "Home"
            : observation === "latest"
              ? "Loading 1"
              : "Loading true"
        );
        if (replacement === "unrelated action") {
          action(function* () {
            setSaved(true);
            yield actionEnd.promise;
          })();
          flush();
        }
        runs.length = 0;
        shown.length = 0;
        setId(2);
        flush();
        if (
          replacement === "cached" ||
          replacement === "unrelated action" ||
          replacement === "cached after suspended preview"
        ) {
          expect(runs).toEqual([2]);
          expect(shown).toEqual(["Page 2"]);
        } else if (replacement === "slow") {
          expect(runs[0]).toBe(2);
          expect(shown).not.toContain("Page 2");
          const last = requests.at(-1)!;
          expect(last.id).toBe(2);
          last.answer.resolve("Page 2");
        } else {
          expect(shown).not.toContain("Page 2");
          if (observation === "latest") expect(shown.at(-1)).toBe("Loading 2");
          actionEnd.resolve();
        }
        for (const request of requests) request.answer.resolve("Obsolete");
        await new Promise(resolve => setTimeout(resolve, 0));
        flush();
        expect(shown.at(-1)).toBe("Page 2");
        expect(shown).not.toContain("Obsolete");
      } finally {
        actionEnd.resolve();
        dispose();
      }
    });
