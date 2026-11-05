import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const owned of [false, true])
  for (const reads of ["new", "old", "always"] as const)
    it(`a lower update respects the displayed dependencies during an optimistic replacement (owned=${owned}, reads=${reads})`, async () => {
      const end = Promise.withResolvers<void>(),
        answer = Promise.withResolvers<number>();
      const cleanups: number[] = [];
      let generation = 0,
        start!: () => Promise<unknown>,
        drag!: () => unknown;
      const shown = { branch: false, outside: "false/false", details: 0 };
      const dispose = createRoot(dispose => {
        const [view, guess] = createOptimistic(() => false, { name: "view" });
        const [moving, setMoving] = createSignal(false, { name: "moving" });
        drag = () => setMoving(true);
        const condition = createMemo(
          () => {
            const frame = ++generation;
            onCleanup(() => {
              cleanups.push(frame);
            });
            const child = owned ? createMemo(() => !!view(), { name: "child" }) : view;
            return reads === "new"
              ? child()
                ? !moving()
                : view()
              : reads === "old"
                ? child()
                  ? true
                  : moving()
                : child() !== moving();
          },
          { name: "condition" }
        );
        const details = createMemo(() => (view() ? answer.promise : 0), { name: "details" });
        createRenderEffect(
          condition,
          value => {
            shown.branch = value;
          },
          { schedule: true, name: "branch binding" }
        );
        createRenderEffect(
          details,
          value => {
            shown.details = value;
          },
          { schedule: true, name: "details binding" }
        );
        createRenderEffect(
          () => `${moving()}/${view()}`,
          value => {
            shown.outside = value;
          },
          { schedule: true, name: "outside" }
        );
        start = action(function* () {
          guess(true);
          yield end.promise;
        });
        return dispose;
      });
      try {
        flush();
        const running = start();
        flush();
        await turn();
        expect(shown).toEqual({ branch: false, outside: "false/false", details: 0 });
        expect(cleanups).not.toContain(1);
        drag();
        flush();
        await turn();
        // Only the new branch reads moving in the first variant. In the other
        // variants the displayed condition still depends on it; publishing moving
        // alone would tear. Next does publish it alone in those two variants.
        expect(shown).toEqual({
          branch: false,
          outside: reads === "new" ? "true/false" : "false/false",
          details: 0
        });
        expect(cleanups).not.toContain(1);
        answer.resolve(1);
        await turn();
        expect(shown).toEqual({ branch: reads === "old", outside: "true/true", details: 1 });
        expect(cleanups).toContain(1);
        end.resolve();
        await running;
        await turn();
        expect(shown).toEqual({ branch: reads !== "new", outside: "true/false", details: 0 });
      } finally {
        end.resolve();
        answer.resolve(1);
        dispose();
        flush();
        expect(cleanups.toSorted((a, b) => a - b)).toEqual(
          Array.from({ length: generation }, (_, i) => i + 1)
        );
      }
    });

for (const memo of [false, true])
  for (const indirect of [false, true])
    it(`dropped displayed dependencies remain coherent through late readers and repeated writes (memo=${memo}, indirect=${indirect})`, async () => {
      const end = Promise.withResolvers<void>();
      const answer = Promise.withResolvers<number>();
      const shown = { view: false, moving: 0, condition: 0, details: 0 };
      let late: number | undefined;
      let setMoving!: (value: number) => number;
      let start!: () => Promise<unknown>;
      let mount!: () => void;
      const dispose = createRoot(dispose => {
        const [view, guess] = createOptimistic(() => false);
        const [moving, write] = createSignal(0);
        setMoving = write;
        const input = indirect ? createMemo(() => moving() * 2) : moving;
        const compute = () => (view() ? 10 : input());
        const condition = memo ? createMemo(compute) : compute;
        const details = createMemo(() => (view() ? answer.promise : 0));
        createRenderEffect(
          view,
          value => {
            shown.view = value;
          },
          { schedule: true }
        );
        createRenderEffect(
          moving,
          value => {
            shown.moving = value;
          },
          { schedule: true }
        );
        createRenderEffect(
          condition,
          value => {
            shown.condition = value;
          },
          { schedule: true }
        );
        createRenderEffect(
          details,
          value => {
            shown.details = value;
          },
          { schedule: true }
        );
        // Create the late reader in its own root below, so a callback never
        // manufactures reactive ownership or changes the dependency graph.
        mount = () => {
          createRenderEffect(
            condition,
            value => {
              late = value;
            },
            { schedule: true }
          );
        };
        start = action(function* () {
          guess(true);
          yield end.promise;
        });
        return dispose;
      });
      let disposeLate = () => {};
      const check = () => {
        expect(shown.condition).toBe(shown.view ? 10 : shown.moving * (indirect ? 2 : 1));
        expect(shown.details).toBe(shown.view ? 1 : 0);
        if (late !== undefined) expect(late).toBe(shown.condition);
      };
      try {
        flush();
        const running = start();
        flush();
        check();
        setMoving(1);
        flush();
        check();
        disposeLate = createRoot(dispose => {
          mount();
          return dispose;
        });
        flush();
        check();
        setMoving(2);
        flush();
        check();
        answer.resolve(1);
        await turn();
        check();
        expect(shown).toEqual({ view: true, moving: 2, condition: 10, details: 1 });
        expect(late).toBe(10);
        end.resolve();
        await running;
        await turn();
        check();
        expect(shown.view).toBe(false);
        expect(shown.moving).toBe(2);
      } finally {
        answer.resolve(1);
        end.resolve();
        disposeLate();
        dispose();
        flush();
      }
    });
