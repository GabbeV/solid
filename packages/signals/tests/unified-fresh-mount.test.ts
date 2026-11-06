import { expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const placement of ["inside", "outside"] as const)
  for (const peers of [false, true])
    for (const closeEarly of [false, true])
      it(`a fresh Loading catches held children without holding its mount (producer=${placement}, peers=${peers}, closeEarly=${closeEarly})`, async () => {
        const firstEnd = Promise.withResolvers<void>();
        const secondEnd = Promise.withResolvers<void>();
        const shown = { first: 0, second: 0, open: false, view: "closed" };
        const children: number[] = [];
        const lifetimes: { cleanups: number }[] = [];
        let startFirst!: () => Promise<unknown>;
        let startSecond!: () => Promise<unknown>;
        let open!: (value: boolean) => boolean;
        const dispose = createRoot(dispose => {
          const [first, setFirst] = createSignal(0);
          const [second, setSecond] = createSignal(0);
          const [visible, setVisible] = createSignal(false);
          open = setVisible;
          const branch = createMemo(() => {
            if (!visible()) return () => "closed";
            const lifetime = { cleanups: 0 };
            lifetimes.push(lifetime);
            onCleanup(() => {
              lifetime.cleanups++;
            });
            const produce = () => createMemo(() => first() + (peers ? second() : 0));
            const input = placement === "outside" ? produce() : undefined;
            return createLoadingBoundary(
              () => {
                const value = input ?? produce();
                createRenderEffect(
                  value,
                  value => {
                    children.push(value);
                  },
                  { schedule: true }
                );
                return "content";
              },
              () => "fallback"
            );
          });
          createRenderEffect(
            first,
            value => {
              shown.first = value;
            },
            { schedule: true }
          );
          createRenderEffect(
            second,
            value => {
              shown.second = value;
            },
            { schedule: true }
          );
          createRenderEffect(
            visible,
            value => {
              shown.open = value;
            },
            { schedule: true }
          );
          createRenderEffect(
            () => branch()(),
            value => {
              shown.view = value;
            },
            { schedule: true }
          );
          startFirst = action(function* () {
            setFirst(1);
            yield firstEnd.promise;
          });
          startSecond = action(function* () {
            setSecond(2);
            yield secondEnd.promise;
          });
          return dispose;
        });
        try {
          flush();
          const first = startFirst();
          flush();
          const second = peers ? startSecond() : undefined;
          flush();
          open(true);
          flush();
          expect(shown).toEqual({ first: 0, second: 0, open: true, view: "fallback" });
          expect(children).toEqual([]);
          if (closeEarly) {
            open(false);
            flush();
            expect(shown.view).toBe("closed");
            expect(lifetimes.every(lifetime => lifetime.cleanups === 1)).toBe(true);
          } else expect(lifetimes.every(lifetime => lifetime.cleanups === 0)).toBe(true);
          firstEnd.resolve();
          await first;
          await turn();
          if (peers) {
            // The producer really consumed both peer proposals. Loading catches
            // its publication; it does not undo that producer's peer merge.
            expect(shown.first).toBe(0);
            expect(shown.second).toBe(0);
          }
          secondEnd.resolve();
          await second;
          await turn();
          expect(shown).toEqual({
            first: 1,
            second: peers ? 2 : 0,
            open: !closeEarly,
            view: closeEarly ? "closed" : "content"
          });
          expect(children).toEqual(closeEarly ? [] : [peers ? 3 : 1]);
        } finally {
          firstEnd.resolve();
          secondEnd.resolve();
          dispose();
          flush();
          expect(lifetimes.every(lifetime => lifetime.cleanups === 1)).toBe(true);
        }
      });
