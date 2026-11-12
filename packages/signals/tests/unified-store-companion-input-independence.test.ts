import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};
for (const shape of ["flat", "nested", "array"] as const)
  for (const consume of [false, true])
    for (const order of ["a first", "b first"] as const)
      it(`cold companion inputs preserve setter ownership (${shape}, consume=${consume}, ${order})`, async () => {
        const asks: ReturnType<typeof Promise.withResolvers<any>>[] = [];
        const saveA = Promise.withResolvers<void>(),
          saveB = Promise.withResolvers<void>();
        const seen: [number, number][] = [];
        let setEpoch!: (value: number) => void, writeA!: () => unknown, writeB!: () => unknown;
        const value = (a: number, b: number) =>
          shape === "array" ? [a, b] : shape === "nested" ? { branch: { a, b } } : { a, b };
        const keyA = shape === "array" ? 0 : "a",
          keyB = shape === "array" ? 1 : "b";
        const branch = (state: any) => (shape === "nested" ? state.branch : state);
        const dispose = createRoot(dispose => {
          const [epoch, set] = createSignal(0);
          setEpoch = set;
          const [store, guess] = createOptimisticStore<any>(
            async () => {
              epoch();
              const answer = Promise.withResolvers<any>();
              asks.push(answer);
              return answer.promise;
            },
            value(0, 0)
          );
          createRenderEffect(
            () => {
              const current = branch(store);
              if (order === "b first") {
                const b = current[keyB];
                return [current[keyA], b] as [number, number];
              }
              return [current[keyA], current[keyB]] as [number, number];
            },
            pair => void seen.push(pair)
          );
          writeA = action(function* () {
            guess(d => {
              branch(d)[keyA] = 999;
            });
            yield saveA.promise;
          });
          writeB = action(function* () {
            guess(d => {
              const current = branch(d);
              // An actual read consumes A; internal draft copying does not.
              if (consume) void current[keyA];
              current[keyB] = 888;
            });
            yield saveB.promise;
          });
          return dispose;
        });
        try {
          flush();
          asks[0].resolve(value(1, 1));
          await turn();
          expect(seen.at(-1)).toEqual([1, 1]);
          setEpoch(1);
          flush();
          writeA();
          await turn();
          writeB();
          await turn();
          expect(seen.at(-1)).toEqual([999, 888]);
          saveA.resolve();
          await turn();
          // The unanswered own input retains A until its answer exists.
          expect(seen.at(-1)).toEqual([999, 888]);
          asks[1].resolve(value(2, 2));
          await turn();
          expect(seen.at(-1)).toEqual(consume ? [999, 888] : [2, 888]);
          saveB.resolve();
          await turn();
          expect(seen.at(-1)).toEqual([2, 2]);
        } finally {
          dispose();
          saveA.resolve();
          saveB.resolve();
          for (const answer of asks) answer.resolve(value(2, 2));
          await turn();
        }
      });
