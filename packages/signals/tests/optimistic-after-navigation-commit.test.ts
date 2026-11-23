import { expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const writer of ["bare setter", "synchronous action", "awaited save"] as const) {
  for (const suspended of [false, true]) {
    it(`a ${writer} previews ${suspended ? "suspended" : "ready"} comments after navigation committed`, async () => {
      const load = Promise.withResolvers<string[]>(),
        save = Promise.withResolvers<void>(),
        format = Promise.withResolvers<string>();
      const frames: string[] = [];
      let heading: string | undefined;
      let formatCalls = 0;
      const { choose, guess, dispose } = createRoot(dispose => {
        const [issue, choose] = createSignal("A");
        const [comments] = createSignal(() => (issue() === "A" ? ["from A"] : load.promise));
        const [shown, guess] = createOptimistic(() => comments());
        const formatted = createMemo(() => {
          const rows = shown();
          if (suspended && rows.includes("ping")) {
            formatCalls++;
            return format.promise;
          }
          return rows.join(", ");
        });
        createRenderEffect(issue, id => {
          heading = id;
        });
        const panel = createLoadingBoundary(formatted, () => "Loading", { on: issue });
        createRenderEffect(panel, text => {
          frames.push(text);
        });
        return { choose, guess, dispose };
      });
      try {
        flush();
        choose("B");
        flush();
        expect(heading).toBe("B");
        expect(frames).toEqual(["from A", "Loading"]);
        const append = () => guess(previous => [...previous, "ping"]);
        const posted =
          writer === "bare setter"
            ? append()
            : action(function* () {
                append();
                if (writer === "awaited save") yield save.promise;
              })();
        flush();
        await turn();
        const fallback = ["from A", "Loading"];
        const preview = [...fallback, "from A, ping"];
        expect(frames).toEqual(suspended ? fallback : preview);
        if (suspended) {
          expect(formatCalls).toBeGreaterThan(0);
          format.resolve("from A, ping");
          await turn();
          expect(frames).toEqual(writer === "awaited save" ? preview : fallback);
        }
        load.resolve(["from B"]);
        await turn();
        if (writer === "awaited save") expect(frames).toEqual(preview);
        save.resolve();
        await posted;
        await turn();
        expect(frames.at(-1)).toBe("from B");
      } finally {
        dispose();
        load.resolve([]);
        save.resolve();
        format.resolve("");
      }
    });
  }
}
