import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

type Row = { id: string; value: number };
type Mode = "direct" | "nested" | "chained";
const settle = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};
const label = (rows: Row[]) => Array.from(rows, row => `${row.id}:${row.value}`);

function fixture(mode: Mode) {
  const initial = [
    { id: "a", value: 0 },
    { id: "b", value: 0 }
  ];
  const [input, setInput] = createSignal(initial);
  const [savedGuess, saveGuess] = createSignal(false);
  const [savedInput, saveInput] = createSignal(false);
  const source: string[][] = [],
    flags: boolean[][] = [];
  return createRoot(dispose => {
    const [rows, guess] = (() => {
      if (mode === "nested") {
        const [state, write] = createOptimisticStore(
          () => ({ rows: input() }),
          { rows: initial },
          { key: "id" }
        );
        return [
          state.rows,
          (edit: (draft: Row[]) => void) => write(draft => edit(draft.rows))
        ] as const;
      }
      if (mode === "chained") {
        const [inner] = createOptimisticStore(input, initial, { key: "id" });
        return createOptimisticStore(() => inner, initial, { key: "id" });
      }
      return createOptimisticStore(input, initial, { key: "id" });
    })();
    createRenderEffect(
      () => label(input()),
      value => {
        source.push(value);
      }
    );
    createRenderEffect(
      () => [savedGuess(), savedInput()],
      value => {
        flags.push(value);
      }
    );
    const mount = (shown: string[][]) =>
      createRoot(stop => {
        createRenderEffect(
          () => label(rows),
          value => {
            shown.push(value);
          }
        );
        return stop;
      });
    return { setInput, guess, saveGuess, saveInput, source, flags, mount, dispose };
  });
}

for (const mode of ["direct", "nested", "chained"] as const) {
  for (const incomingFirst of [false, true]) {
    for (const first of ["guess", "input"] as const) {
      it(`${mode}: a same-length keyed identity change joins both updates (incoming first=${incomingFirst}, finish ${first} first)`, async () => {
        const f = fixture(mode);
        const shown: string[][] = [];
        const stop = f.mount(shown);
        const guessGate = Promise.withResolvers<void>(),
          inputGate = Promise.withResolvers<void>();
        let guessing: Promise<unknown> | undefined, incoming: Promise<unknown> | undefined;
        const startGuess = () => {
          guessing = action(function* () {
            f.guess(draft => {
              draft[1] = { id: "b", value: 9 };
            });
            f.saveGuess(true);
            yield guessGate.promise;
          })();
          flush();
        };
        const startInput = () => {
          incoming = action(function* () {
            f.setInput([
              { id: "c", value: 1 },
              { id: "b", value: 0 }
            ]);
            f.saveInput(true);
            yield inputGate.promise;
          })();
          flush();
        };
        try {
          flush();
          if (incomingFirst) {
            startInput();
            startGuess();
          } else {
            startGuess();
            startInput();
          }
          expect([f.source.at(-1), shown.at(-1), f.flags.at(-1)]).toEqual([
            ["a:0", "b:0"],
            ["a:0", "b:9"],
            [false, false]
          ]);
          if (first === "guess") {
            guessGate.resolve();
            await guessing;
          } else {
            inputGate.resolve();
            await incoming;
          }
          await settle();
          expect([f.source.at(-1), shown.at(-1), f.flags.at(-1)]).toEqual([
            ["a:0", "b:0"],
            ["a:0", "b:9"],
            [false, false]
          ]);
          guessGate.resolve();
          inputGate.resolve();
          await Promise.all([guessing, incoming]);
          await settle();
          expect([f.source.at(-1), shown.at(-1), f.flags.at(-1)]).toEqual([
            ["c:1", "b:0"],
            ["c:1", "b:0"],
            [true, true]
          ]);
        } finally {
          guessGate.resolve();
          inputGate.resolve();
          await Promise.allSettled([guessing, incoming]);
          stop();
          f.dispose();
          flush();
        }
      });
    }
  }

  it(`${mode}: repeated keyed structural joins retire their readers and preserve later value-only independence`, async () => {
    const f = fixture(mode);
    try {
      for (let cycle = 0; cycle < 12; cycle++) {
        const id = `row-${cycle}`;
        f.setInput([
          { id, value: 0 },
          { id: "b", value: 0 }
        ]);
        f.saveGuess(false);
        f.saveInput(false);
        flush();
        const shown: string[][] = [],
          late: string[][] = [];
        const stop = f.mount(shown);
        let stopLate: (() => void) | undefined;
        const gate = Promise.withResolvers<void>();
        let running: Promise<unknown> | undefined;
        try {
          flush();
          running = action(function* () {
            f.guess(draft => {
              draft[1] = { id: "b", value: 9 };
            });
            f.saveGuess(true);
            yield gate.promise;
          })();
          flush();
          f.setInput([
            { id: `${id}-next`, value: 0 },
            { id: "b", value: 0 }
          ]);
          flush();
          expect([f.source.at(-1), shown.at(-1)]).toEqual([
            [`${id}:0`, "b:0"],
            [`${id}:0`, "b:9"]
          ]);
          stop();
          const stoppedCount = shown.length;
          stopLate = f.mount(late);
          flush();
          expect(late.at(-1)).toEqual([`${id}:0`, "b:9"]);
          gate.resolve();
          await running;
          await settle();
          expect([f.source.at(-1), late.at(-1), f.flags.at(-1)]).toEqual([
            [`${id}-next:0`, "b:0"],
            [`${id}-next:0`, "b:0"],
            [true, false]
          ]);
          expect(shown).toHaveLength(stoppedCount);
          // A later same-key replacement changes only a value. A fresh live
          // guess must not inherit the preceding structural action's lifetime.
          const nextGate = Promise.withResolvers<void>();
          let next: Promise<unknown> | undefined;
          try {
            f.saveGuess(false);
            flush();
            next = action(function* () {
              f.guess(draft => {
                draft[1] = { id: "b", value: 8 };
              });
              f.saveGuess(true);
              yield nextGate.promise;
            })();
            flush();
            f.setInput([
              { id: `${id}-next`, value: 2 },
              { id: "b", value: 0 }
            ]);
            flush();
            expect([f.source.at(-1), late.at(-1), f.flags.at(-1)]).toEqual([
              [`${id}-next:2`, "b:0"],
              [`${id}-next:2`, "b:8"],
              [false, false]
            ]);
            nextGate.resolve();
            await next;
            await settle();
            expect(late.at(-1)).toEqual([`${id}-next:2`, "b:0"]);
            expect(f.flags.at(-1)).toEqual([true, false]);
            expect(shown).toHaveLength(stoppedCount);
          } finally {
            nextGate.resolve();
            await Promise.allSettled([next]);
          }
        } finally {
          gate.resolve();
          await Promise.allSettled([running]);
          stop();
          stopLate?.();
          flush();
        }
      }
    } finally {
      f.dispose();
      flush();
    }
  });
}
