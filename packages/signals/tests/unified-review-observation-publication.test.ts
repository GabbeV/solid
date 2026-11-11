import { expect, it } from "vitest";
import {
  comparatorObservation,
  heldComparatorObservation,
  observationQueries
} from "./fixtures/review-observation.js";

for (const query of observationQueries)
  for (const observed of query === "pending" || query === "latest" ? [false, true] : [false])
    it(`an equality comparator can query unrelated ${query} while an action waits (observed=${observed})`, async () => {
      await comparatorObservation(query, observed, (phase, state) => {
        if (phase === "initial") expect(state.screen).toEqual([[0, false]]);
        else if (phase === "held") {
          expect(state.source()).toBe(0);
          expect(state.screen).toEqual([
            [0, false],
            [0, true]
          ]);
          expect(state.calls).toBeGreaterThan(0);
          if (query !== "none")
            expect(
              state.answers.every(
                answer => answer === (query === "pending" || query === "memo" ? false : 0)
              )
            ).toBe(true);
        } else if (phase === "settled") {
          expect(state.source()).toBe(1);
          expect(state.screen).toEqual([
            [0, false],
            [0, true],
            [1, false]
          ]);
        }
      });
    });

it("latest registration keeps a comparator's held reads in its current context", async () => {
  await heldComparatorObservation((phase, state) => {
    if (phase === "held") {
      // Preserve the current engine's visibility in this maintenance context.
      // This control does not redefine comparator dependency tracking.
      expect(state.reads).toContain(0);
      expect(state.reads).toContain(1);
      expect(state.screen).toEqual([[0, false]]);
    } else if (phase === "settled") {
      expect(state.screen).toEqual([
        [0, false],
        [1, false]
      ]);
    }
  });
});
