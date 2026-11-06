import { afterEach, expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

it("sibling callbacks publish once together without a sibling-order constraint", async () => {
  const sourceAnswer = gate<number>(),
    aAnswer = gate<number>(),
    bAnswer = gate<number>();
  const events: string[] = [];
  createRoot(dispose => {
    disposals.push(dispose);
    const source = createMemo(() => sourceAnswer.promise);
    const a = createMemo(() => aAnswer.promise);
    const b = createMemo(() => bAnswer.promise);
    const pending = createMemo(() => isPending(source));
    createRenderEffect(
      () => `${pending()}:${a()}`,
      value => {
        events.push(`A=${value}`);
      },
      { schedule: true }
    );
    createRenderEffect(
      () => `${pending()}:${b()}`,
      value => {
        events.push(`B=${value}`);
      },
      { schedule: true }
    );
  });
  flush();
  sourceAnswer.resolve(0);
  await turn();
  expect(events).toEqual([]);
  aAnswer.resolve(1);
  await turn();
  expect(events).toEqual([]);
  bAnswer.resolve(2);
  await turn();
  // The contract requires both correct callbacks, once, at the shared release.
  // Their relative order is unspecified (write-coalescing ruling 3).
  expect([...events].sort()).toEqual(["A=false:1", "B=false:2"]);
});

for (const kind of ["latest", "pending"] as const)
  for (const revived of [false, true])
    for (const wrapped of [false, true])
      it(`${kind} initializes a new observer from its current proposal (revived=${revived}, wrapped=${wrapped})`, async () => {
        const end = gate<void>(),
          work = gate<string>();
        const [source, setSource] = createSignal(0);
        const input = wrapped ? () => source() : source;
        const read = () => (kind === "latest" ? latest(input) : isPending(input));
        if (revived) {
          const dispose = createRoot(dispose => {
            createRenderEffect(read, () => {});
            return dispose;
          });
          flush();
          dispose();
          flush();
        }
        const running = action(function* () {
          setSource(1);
          yield end.promise;
        })();
        flush();
        const frames: string[] = [],
          calculated: (number | boolean)[] = [];
        createRoot(dispose => {
          disposals.push(dispose);
          const details = createMemo(() => {
            const value = read();
            calculated.push(value);
            return value ? work.promise : "idle";
          });
          const content = createLoadingBoundary(details, () => "loading");
          createRenderEffect(
            content,
            value => {
              frames.push(value);
            },
            { schedule: true }
          );
        });
        flush();
        expect(frames).toEqual(["loading"]);
        expect(calculated.length).toBeGreaterThan(0);
        expect(calculated.every(Boolean)).toBe(true);
        work.resolve("ready");
        await turn();
        expect(source()).toBe(0);
        expect(frames).toEqual(["loading", "ready"]);
        end.resolve();
        await running;
        await turn();
        expect(frames).toEqual(
          kind === "pending" ? ["loading", "ready", "idle"] : ["loading", "ready"]
        );
      });
