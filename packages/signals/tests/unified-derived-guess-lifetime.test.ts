import { describe, expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

// A derived write belongs to the update executing it, not implicitly to the
// longer lifetime of an optimistic input (user ruling, 2026-11-04). In input
// mode next publishes "guess" until the input answers; here the executing
// publication update is completing, so the derived guess never displays.
// This deliberately differs from next's persistent-lane parent inference;
// the original lane-contract assertion remains unchanged for comparison.
// Action mode is a control: next also never displays the derived guess there.
describe.each([false, true])("render scheduling: %s", schedule => {
  it.each(["input", "action"] as const)(
    "a derived guess belongs to its executing update, not the open %s lifetime",
    async mode => {
      const response = Promise.withResolvers<string>();
      const end = Promise.withResolvers<number>();
      const shown = { first: 0, details: "none", badge: "base" };
      const badgePublications: string[] = [];
      let start!: () => void | Promise<unknown>;
      const dispose = createRoot(dispose => {
        const [source, setSource] = createSignal(0);
        const input = createMemo(() => (mode === "action" ? 0 : source() ? end.promise : 0));
        const [first, guessFirst] = createOptimistic(input);
        const [badge, guessBadge] = createOptimistic("base", { ownedWrite: true });
        const details = createMemo(() => (first() ? response.promise : "none"));
        const combined = createMemo(() => {
          const detail = details();
          if (detail === "ready") guessBadge("guess");
          return detail;
        });
        createRenderEffect(
          first,
          value => {
            shown.first = value;
          },
          { schedule }
        );
        createRenderEffect(
          combined,
          value => {
            shown.details = value;
          },
          { schedule }
        );
        createRenderEffect(
          badge,
          value => {
            shown.badge = value;
            badgePublications.push(value);
          },
          { schedule }
        );
        createRenderEffect(input, () => {}, { schedule });
        start =
          mode === "action"
            ? action(function* () {
                guessFirst(1);
                yield end.promise;
              })
            : () => {
                setSource(1);
                guessFirst(1);
              };
        return dispose;
      });
      try {
        flush();
        const running = start();
        flush();
        expect(shown).toEqual({ first: 0, details: "none", badge: "base" });
        response.resolve("ready");
        await turn();
        expect(shown).toEqual({ first: 1, details: "ready", badge: "base" });
        end.resolve(1);
        await running;
        await turn();
        expect(shown).toEqual(
          mode === "input"
            ? { first: 1, details: "ready", badge: "base" }
            : { first: 0, details: "none", badge: "base" }
        );
        expect(badgePublications).toEqual(["base"]);
      } finally {
        response.resolve("ready");
        end.resolve(1);
        dispose();
        flush();
      }
    }
  );
});
