import { afterEach, describe, expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  resetErrorHalt
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(r => {
    resolve = r;
  });
  return { promise, resolve };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
  resetErrorHalt();
});

// Plain accessor reads, not the deferred replacement latest/isPending APIs.
// Event callbacks run outside a tracked computation and must see the same
// published output as the rendered bindings, even after a proposal flushed.
describe("imperative reads observe committed scalar publication", () => {
  for (const optimistic of [false, true]) {
    it(`${optimistic ? "layer" : "ordinary"}: outside reads match the displayed frame throughout a hold`, async () => {
      const next = gate<void>(),
        end = gate<void>(),
        result = gate<number>();
      const [tick, setTick] = createSignal(0);
      let value!: () => number, derived!: () => number, doubled!: () => number;
      let write!: (value: number) => number;
      let valueShown = 0,
        resultShown = 0,
        doubledShown = 0;
      let pair: readonly number[] = [0, 0, 0];
      createRoot(dispose => {
        disposals.push(dispose);
        [value, write] = optimistic
          ? createLayer(() => 0, { lifetime: "action" })
          : createSignal(0);
        derived = createMemo(() => (value() === 2 ? result.promise : value()));
        doubled = createMemo(() => value() * 2);
        createRenderEffect(
          () => [tick(), value()],
          values => {
            valueShown = values[1];
          }
        );
        createRenderEffect(derived, value => {
          resultShown = value;
        });
        createRenderEffect(doubled, value => {
          doubledShown = value;
        });
        createRenderEffect(
          () => [value(), derived(), doubled()],
          values => {
            pair = values;
          }
        );
      });
      // This function is invoked imperatively, never as a reactive compute.
      const readFromEvent = () => [value(), derived(), doubled()];
      const check = (expected: number) => {
        const frame = [expected, expected, expected * 2];
        expect([valueShown, resultShown, doubledShown]).toEqual(frame);
        expect(pair).toEqual(frame);
        expect(readFromEvent()).toEqual(frame);
      };
      check(0);
      const running = action(function* () {
        write(1);
        yield next.promise;
        write(2);
        yield end.promise;
      })();
      flush();
      check(optimistic ? 1 : 0);
      next.resolve();
      await turn();
      check(optimistic ? 1 : 0);
      setTick(1);
      flush();
      check(optimistic ? 1 : 0);
      result.resolve(2);
      await turn();
      check(optimistic ? 2 : 0);
      end.resolve();
      await running;
      await turn();
      check(optimistic ? 0 : 2);
    });
  }
});
