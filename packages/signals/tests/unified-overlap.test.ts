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
import { createLayer } from "../src/layers/layer.js";
import { isPending } from "../src/layers/pending.js";

import { LEGACY_LANES } from "../src/core/constants.js";
import { resolveTx, transactions } from "../src/core/scheduler.js";
import type { Signal } from "../src/core/types.js";

// In addition to visible consistency, verify that transfers and merges keep
// exactly one membership per node, including during long overlapping actions.
function checkOwnership() {
  if (LEGACY_LANES) return;
  const members = new Set<Signal<any>>();
  for (const update of transactions) {
    let previous: Signal<any> | null = null;
    for (let node = update._firstHeld; node; node = node._x!._nextHeld) {
      if (members.has(node)) throw new Error("Duplicate or cyclic held membership");
      members.add(node);
      const extension = node._x!;
      if (extension._previousHeld !== previous || extension._transaction === null ||
          resolveTx(extension._transaction) !== update)
        throw new Error("Held membership does not match its current owner");
      previous = node;
    }
    if (update._lastHeld !== previous) throw new Error("Held membership tail is detached");
  }
}

function gate<T>() {
  let resolve!: (value: T) => void;
  let reject!: (error: unknown) => void;
  const promise = new Promise<T>((yes, no) => {
    resolve = yes;
    reject = no;
  });
  return { promise, resolve, reject };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
function root(fn: () => void) {
  let release!: () => void;
  createRoot(dispose => {
    release = dispose;
    disposals.push(dispose);
    fn();
  });
  return release;
}
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
  resetErrorHalt();
});

type Command = { finish: boolean; value: number };
for (const regression of [false, true])
  it(
    regression
      ? "rederiving a layer reader can merge its holder without losing remaining readers"
      : "overlapping action proposals preserve publications through nesting, sibling joins and branch changes",
    async () => {
      // Reduced seed 221: ending overlapping parent/child/sibling actions moves
      // the remaining pre-publication readers to another transaction mid-walk.
      const replay = (regression ? "0:0 1:5 0:1 4:5 2:6 0:5" : process.env.OVERLAP_REPLAY)
        ?.split(" ")
        .map(op => op.split(":").map(Number));
      for (let seed = 1; seed <= (replay ? 1 : Number(process.env.OVERLAP_SEEDS || 20)); seed++) {
        let randomState = seed;
        const random = () => (randomState = (Math.imul(randomState, 1664525) + 1013904223) >>> 0);
        const [x, setX] = createSignal(0),
          [y, setY] = createSignal(0);
        const [branch, setBranch] = createSignal(false),
          [tick, setTick] = createSignal(0);
        let first!: () => number, second!: () => number, sibling!: () => number;
        let guessFirst!: (value: number) => number, guessSecond!: (value: number) => number;
        let guessSibling!: (value: number) => number;
        const direct: (number | boolean)[] = [0, 0, 0, 0, false];
        let shownLabel = "0/0/0/0/false",
          shownTick = 0;
        const pending = [false, false, false];
        const flights: { resolve: (value: string) => void; value: string }[] = [];
        let currentLabel!: () => string;
        root(() => {
          [first, guessFirst] = createLayer(x, { lifetime: "action" });
          [second, guessSecond] = createLayer(() => first() * 2, { lifetime: "action" });
          [sibling, guessSibling] = createLayer(y, { lifetime: "action" });
          const selected = createMemo(() => (branch() ? second() : sibling()));
          currentLabel = createMemo(() => {
            const value = [first(), second(), sibling(), selected(), branch()].join("/");
            if (value === "0/0/0/0/false") return value;
            return new Promise<string>(resolve => {
              flights.push({ resolve, value });
            });
          });
          [first, second, sibling, selected, branch].forEach((read, index) => {
            createRenderEffect(
              () => {
                tick();
                return read();
              },
              value => {
                direct[index] = value;
              }
            );
          });
          [first, second, sibling].forEach((read, index) => {
            createRenderEffect(
              () => isPending(read),
              value => {
                pending[index] = value;
              }
            );
          });
          createRenderEffect(currentLabel, value => {
            shownLabel = value;
          });
          createRenderEffect(tick, value => {
            shownTick = value;
          });
        });
        flush();
        const actions: {
          next: ReturnType<typeof gate<Command>>;
          running?: Promise<void>;
          ended: boolean;
        }[] = [];
        const actionErrors: unknown[] = [];
        function start(which: number, value: number) {
          const guess = [guessFirst, guessSecond, guessSibling][which];
          // The middle layer's input is first(), so its answer changes x.
          const answer = which === 2 ? setY : setX;
          const record = { next: gate<Command>(), ended: false } as (typeof actions)[number];
          record.running = action(function* (): Generator<Promise<Command>, void, Command> {
            guess(value);
            for (;;) {
              const command = yield record.next.promise;
              if (command.finish) {
                answer(command.value);
                return;
              }
              record.next = gate<Command>();
              guess(command.value);
            }
          })().catch(error => {
            actionErrors.push(error);
          });
          actions.push(record);
        }
        // Exercise updates of an already revealed layer, not just an initial
        // frame that stays blocked throughout a random timeline.
        start(0, 1);
        flush();
        for (const flight of flights.splice(0)) flight.resolve(flight.value);
        await turn();
        expect(direct).toEqual([1, 2, 0, 0, false]);
        expect(shownLabel).toBe("1/2/0/0/false");
        const late: { value: number; dispose: () => void }[] = [];
        const operations: string[] = [];
        function check() {
          checkOwnership();
          const why = `seed=${seed}, ops=${operations.join(" ")}`;
          expect(actionErrors, why).toEqual([]);
          expect(shownLabel, why).toBe(direct.join("/"));
          expect([first(), second(), sibling()], why).toEqual(direct.slice(0, 3));
          expect([isPending(first), isPending(second), isPending(sibling)], why).toEqual(pending);
          for (const reader of late) expect(reader.value, why).toBe(direct[1]);
        }
        for (let step = 0; step < (replay?.length ?? 50); step++) {
          const [op, value] = replay?.[step] ?? [(random() >>> 16) % 8, (random() >>> 16) % 7];
          operations.push(`${op}:${value}`);
          const open = actions.filter(record => !record.ended);
          switch (op) {
            case 0:
              start(value % 3, value);
              break;
            case 1:
            case 2: {
              const record = open[value % Math.max(1, open.length)];
              if (record) {
                record.ended = op === 2;
                record.next.resolve({ finish: record.ended, value });
              }
              break;
            }
            case 3: {
              const index = value % 2 ? flights.length - 1 : value % Math.max(1, flights.length);
              const flight = flights.splice(index, 1)[0];
              flight?.resolve(flight.value);
              break;
            }
            case 4:
              setBranch(!!(value % 2));
              break;
            case 5:
              setTick(step);
              break;
            case 6: {
              const reader = { value: -1, dispose: () => {} };
              reader.dispose = root(() =>
                createRenderEffect(second, value => {
                  reader.value = value;
                })
              );
              late.push(reader);
              break;
            }
            case 7:
              late.shift()?.dispose();
              break;
          }
          flush();
          await turn();
          if (op === 5) expect(shownTick).toBe(step);
          check();
        }
        for (const record of actions)
          if (!record.ended) record.next.resolve({ finish: true, value: 0 });
        await Promise.all(actions.map(record => record.running));
        await turn();
        for (let round = 0; flights.length && round < 20; round++) {
          for (const flight of flights.splice(0)) flight.resolve(flight.value);
          await turn();
        }
        expect(flights).toHaveLength(0);
        check();
        for (const dispose of disposals.splice(0)) dispose();
        flush();
      }
    }
  );

for (const failure of ["none", "throw", "reject"] as const)
  for (const childDepth of [0, 1, 3]) {
    it(`an expiring layer waits for a sibling's second proposal and its consequence (child depth=${childDepth}, failure=${failure})`, async () => {
      const firstEnd = gate<void>(),
        secondGuess = gate<void>(),
        secondEnd = gate<void>();
      const answers = new Map<string, ReturnType<typeof gate<string>>>();
      let guessFirst!: (value: number) => number, guessSecond!: (value: number) => number;
      let first = 4,
        second = 0,
        label = "4/0";
      const frames: { key: string; cleaned: number }[] = [];
      let child: (typeof frames)[number] | undefined;
      let readFirst!: () => number, readSecond!: () => number;
      const disposeOwner = root(() => {
        const [a, ga] = createLayer(() => 4, { lifetime: "action" });
        const [b, gb] = createLayer(() => 0, { lifetime: "action" });
        guessFirst = ga;
        guessSecond = gb;
        readFirst = a;
        readSecond = b;
        const text = createMemo(() => {
          const key = `${a()}/${b()}`;
          if (childDepth) {
            const frame = { key, cleaned: 0 };
            frames.push(frame);
            onCleanup(() => {
              frame.cleaned++;
            });
            function descendants(depth: number): string {
              if (depth === 1)
                createRenderEffect(
                  () => frame,
                  value => {
                    child = value;
                  },
                  { schedule: true }
                );
              else {
                const nested = createMemo(() => descendants(depth - 1));
                return nested();
              }
              return key;
            }
            descendants(childDepth);
          }
          if (key === "4/0") return key;
          const answer = gate<string>();
          answers.set(key, answer);
          return answer.promise;
        });
        createRenderEffect(a, value => {
          first = value;
        });
        createRenderEffect(b, value => {
          second = value;
        });
        createRenderEffect(text, value => {
          label = value;
        });
      });
      function expectFrame(a: number, b: number, text: string) {
        checkOwnership();
        expect([first, second, label]).toEqual([a, b, text]);
        if (childDepth) expect(child).toEqual({ key: text, cleaned: 0 });
      }
      flush();
      const failureReason = new Error("first action failed");
      const a = action(function* () {
        guessFirst(6);
        yield firstEnd.promise;
        if (failure === "throw") throw failureReason;
      })().then(
        () => undefined,
        error => error
      );
      flush();
      const b = action(function* () {
        guessSecond(2);
        yield secondGuess.promise;
        guessSecond(1);
        yield secondEnd.promise;
      })();
      flush();
      answers.get("6/2")!.resolve("6/2");
      await turn();
      expectFrame(6, 2, "6/2");
      secondGuess.resolve();
      await turn();
      expectFrame(6, 2, "6/2");
      if (failure === "reject") firstEnd.reject(failureReason);
      else firstEnd.resolve();
      expect(await a).toBe(failure === "none" ? undefined : failureReason);
      await turn();
      expectFrame(6, 2, "6/2");
      // This obsolete result must neither replace the frame nor surface an error.
      answers.get("6/1")!.reject(new Error("obsolete proposal failed"));
      await turn();
      expectFrame(6, 2, "6/2");
      let lateFirst = -1,
        lateSecond = -1;
      root(() => {
        createRenderEffect(readFirst, value => {
          lateFirst = value;
        });
        createRenderEffect(readSecond, value => {
          lateSecond = value;
        });
      });
      flush();
      expect([lateFirst, lateSecond]).toEqual([6, 2]);
      expect(answers.has("4/1")).toBe(true);
      answers.get("4/1")!.resolve("4/1");
      await turn();
      expectFrame(4, 1, "4/1");
      expect([lateFirst, lateSecond]).toEqual([4, 1]);
      secondEnd.resolve();
      await b;
      await turn();
      expectFrame(4, 0, "4/0");
      disposeOwner();
      expect(frames.every(frame => frame.cleaned === 1)).toBe(true);
    });
  }
