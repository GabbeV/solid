import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  flush
} from "../src/index.js";

const settle = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

type SourceKind =
  | "signal"
  | "derived signal"
  | "ordinary property"
  | "nested array"
  | "chained input";

// All observations use ordinary readers. Separate render bindings must agree without
// a combined computation creating the coordination that this rule requires.
function fixture(kind: SourceKind, initial: string[], observeRows = true, indexOnly = false) {
  const source: string[][] = [];
  const shown: string[][] = [];
  const indices: Array<string | undefined> = [];
  const flags: boolean[][] = [];
  const [savedGuess, saveGuess] = createSignal(false);
  const [savedInput, saveInput] = createSignal(false);
  return createRoot(dispose => {
    const [input, setInput] = createSignal(initial);
    const property = kind === "ordinary property" ? createStore({ items: initial }) : undefined;
    const derived = kind === "derived signal" ? createMemo(() => input().slice()) : undefined;
    const read = property ? () => property[0].items : derived || input;
    const write = (value: string[]) => {
      if (property)
        property[1](draft => {
          draft.items = value;
        });
      else setInput(value);
    };
    const [rows, guess] = (() => {
      if (kind === "nested array") {
        const [nested, guessNested] = createOptimisticStore(() => ({ items: read() }), {
          items: initial
        });
        return [
          nested.items,
          (edit: (draft: string[]) => void) => guessNested(draft => edit(draft.items))
        ] as const;
      }
      if (kind === "chained input") {
        const [inner] = createOptimisticStore(read, initial);
        return createOptimisticStore(() => inner, initial);
      }
      return createOptimisticStore(read, initial);
    })();
    createRenderEffect(
      () => [...read()],
      value => {
        source.push(value);
      }
    );
    const mount = () =>
      createRoot(stop => {
        createRenderEffect(
          () => [...rows],
          value => {
            shown.push(value);
          }
        );
        return stop;
      });
    let stopRows = observeRows ? mount() : undefined;
    if (indexOnly)
      createRenderEffect(
        () => rows[1],
        value => {
          indices.push(value);
        }
      );
    createRenderEffect(
      () => [savedGuess(), savedInput()],
      value => {
        flags.push(value);
      }
    );
    return {
      rows,
      guess,
      write,
      saveGuess,
      saveInput,
      source,
      shown,
      indices,
      flags,
      mount() {
        stopRows = mount();
      },
      dispose() {
        stopRows?.();
        dispose();
      }
    };
  });
}

for (const kind of [
  "signal",
  "derived signal",
  "ordinary property",
  "nested array",
  "chained input"
] as const) {
  for (const first of ["guess", "input"] as const) {
    it(`${kind}: structural input shrink joins the whole push and input updates (${first} finishes first)`, async () => {
      const f = fixture(kind, ["A"]);
      const guessGate = Promise.withResolvers<void>();
      const inputGate = Promise.withResolvers<void>();
      let guess: Promise<unknown> | undefined;
      let input: Promise<unknown> | undefined;
      try {
        flush();
        guess = action(function* () {
          f.guess(draft => {
            draft.push("M");
          });
          f.saveGuess(true);
          yield guessGate.promise;
        })();
        flush();
        expect([f.source.at(-1), f.shown.at(-1), f.flags.at(-1)]).toEqual([
          ["A"],
          ["A", "M"],
          [false, false]
        ]);
        input = action(function* () {
          f.write([]);
          f.saveInput(true);
          yield inputGate.promise;
        })();
        flush();
        expect([f.source.at(-1), f.shown.at(-1), f.flags.at(-1)]).toEqual([
          ["A"],
          ["A", "M"],
          [false, false]
        ]);
        if (first === "guess") {
          guessGate.resolve();
          await guess;
        } else {
          inputGate.resolve();
          await input;
        }
        await settle();
        expect([f.source.at(-1), f.shown.at(-1), f.flags.at(-1)]).toEqual([
          ["A"],
          ["A", "M"],
          [false, false]
        ]);
        guessGate.resolve();
        inputGate.resolve();
        await Promise.all([guess, input]);
        await settle();
        expect([f.source.at(-1), f.shown.at(-1), f.flags.at(-1)]).toEqual([[], [], [true, true]]);
      } finally {
        guessGate.resolve();
        inputGate.resolve();
        await Promise.allSettled([guess, input]);
        f.dispose();
        flush();
      }
    });
  }
}

for (const observation of ["index only", "late mount"] as const) {
  it(`${observation}: structural input retains unguessed prefix without an initial full output subscriber`, async () => {
    const f = fixture("signal", ["A", "B"], false, observation === "index only");
    const gate = Promise.withResolvers<void>();
    let running: Promise<unknown> | undefined;
    try {
      flush();
      running = action(function* () {
        f.guess(draft => {
          draft[1] = "M";
        });
        f.saveGuess(true);
        yield gate.promise;
      })();
      flush();
      f.write([]);
      flush();
      expect(f.source.at(-1)).toEqual(["A", "B"]);
      if (observation === "index only") expect(f.indices.at(-1)).toBe("M");
      f.mount();
      flush();
      expect(f.shown.at(-1)).toEqual(["A", "M"]);
      expect(f.flags.at(-1)).toEqual([false, false]);
      gate.resolve();
      await running;
      await settle();
      expect([f.source.at(-1), f.shown.at(-1), f.flags.at(-1)]).toEqual([[], [], [true, false]]);
      if (observation === "index only") expect(f.indices.at(-1)).toBeUndefined();
    } finally {
      gate.resolve();
      await Promise.allSettled([running]);
      f.dispose();
      flush();
    }
  });
}

for (const first of [0, 1] as const) {
  it(`two live overrides retain their supporting prefix through input shrink (index ${first} finishes first)`, async () => {
    const f = fixture("signal", ["A", "B"]);
    const gates = [Promise.withResolvers<void>(), Promise.withResolvers<void>()];
    const promises: Array<Promise<unknown>> = [];
    const [savedOther, saveOther] = createSignal(false);
    const otherFlags: boolean[] = [];
    const stop = createRoot(dispose => {
      createRenderEffect(savedOther, value => {
        otherFlags.push(value);
      });
      return dispose;
    });
    try {
      flush();
      // Index 1 is guessed first, so index 0 supports its prefix without a user read.
      promises[1] = action(function* () {
        f.guess(draft => {
          draft[1] = "M";
        });
        f.saveGuess(true);
        yield gates[1].promise;
      })();
      flush();
      promises[0] = action(function* () {
        f.guess(draft => {
          draft[0] = "N";
        });
        saveOther(true);
        yield gates[0].promise;
      })();
      flush();
      f.write([]);
      flush();
      expect([f.source.at(-1), f.shown.at(-1)]).toEqual([
        ["A", "B"],
        ["N", "M"]
      ]);
      gates[first].resolve();
      await promises[first];
      await settle();
      expect([f.source.at(-1), f.shown.at(-1), f.flags.at(-1), otherFlags.at(-1)]).toEqual([
        ["A", "B"],
        ["N", "M"],
        [false, false],
        false
      ]);
      gates[1 - first].resolve();
      await Promise.all(promises);
      await settle();
      expect([f.source.at(-1), f.shown.at(-1), f.flags.at(-1), otherFlags.at(-1)]).toEqual([
        [],
        [],
        [true, false],
        true
      ]);
    } finally {
      gates.forEach(gate => gate.resolve());
      await Promise.allSettled(promises);
      stop();
      f.dispose();
      flush();
    }
  });
}

it("value-only input edits remain independent from a live disjoint index override", async () => {
  const f = fixture("signal", ["A", "B"]);
  const guessGate = Promise.withResolvers<void>();
  const inputGate = Promise.withResolvers<void>();
  let guess: Promise<unknown> | undefined;
  let input: Promise<unknown> | undefined;
  try {
    flush();
    guess = action(function* () {
      f.guess(draft => {
        draft[1] = "M";
      });
      f.saveGuess(true);
      yield guessGate.promise;
    })();
    flush();
    input = action(function* () {
      f.write(["X", "B"]);
      f.saveInput(true);
      yield inputGate.promise;
    })();
    flush();
    expect([f.source.at(-1), f.shown.at(-1), f.flags.at(-1)]).toEqual([
      ["A", "B"],
      ["A", "M"],
      [false, false]
    ]);
    inputGate.resolve();
    await input;
    await settle();
    expect([f.source.at(-1), f.shown.at(-1), f.flags.at(-1)]).toEqual([
      ["X", "B"],
      ["X", "M"],
      [false, true]
    ]);
    guessGate.resolve();
    await guess;
    await settle();
    expect([f.source.at(-1), f.shown.at(-1), f.flags.at(-1)]).toEqual([
      ["X", "B"],
      ["X", "B"],
      [true, true]
    ]);
  } finally {
    guessGate.resolve();
    inputGate.resolve();
    await Promise.allSettled([guess, input]);
    f.dispose();
    flush();
  }
});
