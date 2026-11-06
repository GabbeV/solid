import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  flush
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const slowUpper of [false, true])
  for (const observeInput of [false, true])
    it(`inactive boundaries preserve demand through an active override (slow upper=${slowUpper}, input observed=${observeInput})`, async () => {
      async function timeline(boundaries: boolean) {
        const inputAnswer = Promise.withResolvers<number>();
        const upperAnswer = Promise.withResolvers<number>();
        const lowerEnd = Promise.withResolvers<void>();
        const upperEnd = Promise.withResolvers<void>();
        let guessLower!: (value: number) => void, guessUpper!: (value: number) => void;
        let pair: number[] = [],
          direct = -1;
        const snapshots: number[][] = [];
        const snapshot = () => {
          expect(direct).toBe(pair[0]);
          expect(pair[1]).toBe(pair[2]);
          snapshots.push([...pair]);
        };
        const dispose = createRoot(dispose => {
          const [lower, writeLower] = createOptimistic(() => 0);
          guessLower = writeLower;
          let input = createMemo(() => (lower() ? inputAnswer.promise : 0));
          for (let i = 0; i < 2; i++) {
            const previous = input;
            input = boundaries
              ? createOptimistic(() => previous() * 2)[0]
              : createMemo(() => previous() * 2);
          }
          const [upper, writeUpper] = createOptimistic(input);
          guessUpper = writeUpper;
          const detail = createMemo(() =>
            upper() === 100 && slowUpper ? upperAnswer.promise : upper()
          );
          if (observeInput) createRenderEffect(input, () => {});
          createRenderEffect(lower, value => {
            direct = value;
          });
          createRenderEffect(
            () => [lower(), upper(), detail()],
            value => {
              pair = value;
            }
          );
          return dispose;
        });
        flush();
        snapshot();
        const lowerAction = action(function* () {
          guessLower(1);
          yield lowerEnd.promise;
        })();
        flush();
        snapshot();
        const upperAction = action(function* () {
          guessUpper(100);
          yield upperEnd.promise;
        })();
        try {
          flush();
          snapshot();
          upperAnswer.resolve(100);
          await turn();
          flush();
          snapshot();
          inputAnswer.resolve(2);
          await turn();
          flush();
          snapshot();
          expect(pair).toEqual([1, 100, 100]);
          lowerEnd.resolve();
          await lowerAction;
          await turn();
          flush();
          snapshot();
          expect(pair).toEqual([0, 100, 100]);
          upperEnd.resolve();
          await upperAction;
          await turn();
          flush();
          snapshot();
          expect(pair).toEqual([0, 0, 0]);
          return snapshots;
        } finally {
          inputAnswer.resolve(2);
          upperAnswer.resolve(100);
          lowerEnd.resolve();
          upperEnd.resolve();
          await Promise.all([lowerAction, upperAction]);
          dispose();
          flush();
        }
      }
      expect(await timeline(true)).toEqual(await timeline(false));
    });
