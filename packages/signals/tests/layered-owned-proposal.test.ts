import { afterEach, expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup,
  resetErrorHalt
} from "../src/index.js";

function gate() {
  let resolve!: () => void;
  const promise = new Promise<void>(yes => {
    resolve = yes;
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

for (const equal of [false, true])
  it(`a new child inherits its creator's proposed input before the first park (equal=${equal})`, async () => {
    const end = gate();
    const [generation, setGeneration] = createSignal(0);
    let inputShown = 0,
      childShown = 0,
      ownerShown = 0;
    const cleaned: number[] = [];
    createRoot(dispose => {
      disposals.push(dispose);
      const owner = createMemo(() => {
        const value = generation();
        onCleanup(() => {
          cleaned.push(value);
        });
        createRenderEffect(
          () => value,
          next => {
            childShown = next;
          }
        );
        return equal ? 0 : value;
      });
      createRenderEffect(generation, value => {
        inputShown = value;
      });
      createRenderEffect(owner, value => {
        ownerShown = value;
      });
    });
    flush();
    const running = action(function* () {
      setGeneration(1);
      yield end.promise;
    })();
    flush();
    expect([inputShown, childShown, ownerShown, cleaned]).toEqual([0, 0, 0, []]);
    end.resolve();
    await running;
    await turn();
    expect([inputShown, childShown, ownerShown, cleaned]).toEqual([1, 1, equal ? 0 : 1, [0]]);
  });

it("scheduled children wait for async discovered after their creation", async () => {
  const answer = gate();
  const [generation, setGeneration] = createSignal(0);
  let inputShown = 0,
    childShown = 0,
    ownerShown = 0;
  const cleaned: number[] = [];
  createRoot(dispose => {
    disposals.push(dispose);
    const owner = createMemo(() => {
      const value = generation();
      onCleanup(() => {
        cleaned.push(value);
      });
      createRenderEffect(
        () => value,
        next => {
          childShown = next;
        },
        { schedule: true }
      );
      return value ? answer.promise.then(() => value) : 0;
    });
    createRenderEffect(generation, value => {
      inputShown = value;
    });
    createRenderEffect(owner, value => {
      ownerShown = value;
    });
  });
  flush();
  setGeneration(1);
  flush();
  expect([inputShown, childShown, ownerShown, cleaned]).toEqual([0, 0, 0, []]);
  answer.resolve();
  await turn();
  expect([inputShown, childShown, ownerShown, cleaned]).toEqual([1, 1, 1, [0]]);
});
