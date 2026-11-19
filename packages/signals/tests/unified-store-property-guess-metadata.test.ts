import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
for (const guessed of [9, undefined])
  it(`a changed property selects presence and shape while input deletes it (${String(guessed)})`, async () => {
    const shown = {
      value: "",
      presence: false,
      own: false,
      keys: "",
      descriptor: false,
      descriptorValue: "absent"
    };
    let start!: () => Promise<unknown>,
      finish = () => {},
      sample!: () => void,
      remove!: () => void,
      dispose!: () => void;
    let running: Promise<unknown> | undefined;
    createRoot(d => {
      dispose = d;
      const [removed, setRemoved] = createSignal(false);
      remove = () => setRemoved(true);
      const [sampleTick, setSampleTick] = createSignal(0);
      sample = () => setSampleTick(n => n + 1);
      const [st, set] = createOptimisticStore(
        (d: any) => {
          if (removed()) delete d.x;
          else d.x = 1;
        },
        { x: 1 }
      );
      createRenderEffect(
        () => st.x,
        v => {
          shown.value = String(v);
        }
      );
      createRenderEffect(
        () => "x" in st,
        v => {
          shown.presence = v;
        }
      );
      createRenderEffect(
        () => Object.hasOwn(st, "x"),
        v => {
          shown.own = v;
        }
      );
      createRenderEffect(
        () => Object.keys(st).join(","),
        v => {
          shown.keys = v;
        }
      );
      createRenderEffect(
        () => !!Object.getOwnPropertyDescriptor(st, "x"),
        v => {
          shown.descriptor = v;
        }
      );
      createRenderEffect(
        () => {
          sampleTick();
          const descriptor = Object.getOwnPropertyDescriptor(st, "x");
          return descriptor ? String(descriptor.value) : "absent";
        },
        value => {
          shown.descriptorValue = value;
        }
      );
      start = action(function* () {
        set(d => {
          d.x = guessed;
        });
        yield new Promise<void>(r => (finish = r));
      });
    });
    try {
      flush();
      running = start();
      await tick();
      expect(shown.descriptorValue).toBe("1");
      sample();
      flush();
      const selected = {
        value: String(guessed),
        presence: true,
        own: true,
        keys: "x",
        descriptor: true,
        descriptorValue: String(guessed)
      };
      expect(shown).toEqual(selected);
      remove();
      flush();
      await tick();
      expect(shown).toEqual(selected);
      finish();
      await running;
      await tick();
      expect(shown).toEqual({
        value: "undefined",
        presence: false,
        own: false,
        keys: "",
        descriptor: false,
        descriptorValue: "absent"
      });
    } finally {
      finish();
      dispose();
      await Promise.allSettled([running]);
      flush();
    }
  });

it("descriptor values sample guesses and correction when another dependency reruns the reader", async () => {
  let begin!: () => Promise<unknown>,
    finish = () => {},
    sample!: () => void,
    update!: (v: number) => void,
    dispose!: () => void;
  let running: Promise<unknown> | undefined;
  let descriptorValue: unknown;
  const keys: string[] = [];
  let keyCalculations = 0;
  createRoot(cleanup => {
    dispose = cleanup;
    const [value, setValue] = createSignal(1);
    update = setValue;
    const [sampleTick, setSampleTick] = createSignal(0);
    sample = () => setSampleTick(n => n + 1);
    const [store, set] = createOptimisticStore(
      (draft: any) => {
        draft.x = value();
      },
      { x: 1 }
    );
    createRenderEffect(
      () => {
        sampleTick();
        return Object.getOwnPropertyDescriptor(store, "x")?.value;
      },
      next => {
        descriptorValue = next;
      }
    );
    createRenderEffect(
      () => {
        keyCalculations++;
        return Object.keys(store).join(",");
      },
      next => {
        keys.push(next);
      }
    );
    begin = action(function* () {
      set(draft => {
        draft.x = 9;
      });
      yield new Promise<void>(resolve => {
        finish = resolve;
      });
    });
  });
  try {
    flush();
    running = begin();
    await tick();
    expect(descriptorValue).toBe(1);
    sample();
    flush();
    expect(descriptorValue).toBe(9);
    const calculationsAfterDiscovery = keyCalculations;
    update(2);
    flush();
    await tick();
    expect(descriptorValue).toBe(9);
    expect(keyCalculations).toBe(calculationsAfterDiscovery);
    finish();
    await running;
    await tick();
    sample();
    flush();
    expect(descriptorValue).toBe(2);
    expect(keys.filter(value => value !== "x")).toEqual([]);
  } finally {
    finish();
    dispose();
    await Promise.allSettled([running]);
    flush();
  }
});

type Score = { score?: number; copy: number };
const observations = [
  ["descriptor value", (d: Score) => Object.getOwnPropertyDescriptor(d, "score")!.value],
  ["presence", (d: Score) => Number("score" in d)],
  ["key list", (d: Score) => Number(Object.keys(d).includes("score"))]
] as const;

for (const depth of [0, 2])
  for (const [name, sample] of observations)
    it.each([true, false])(
      `an optimistic setter reading ${name} through ${depth} wrappers joins only a change to metadata (key already present: %s)`,
      async existing => {
        const { state, guessScore, guessCopy, dispose } = createRoot(dispose => {
          const [source, guessScore] = createOptimisticStore<Score>(
            existing ? { score: 0, copy: 0 } : { copy: 0 }
          );
          let state = source,
            guessCopy = guessScore;
          for (let n = 0; n < depth; ++n) {
            const input = state;
            [state, guessCopy] = createOptimisticStore<Score>(() => input, { copy: 0 });
          }
          return { state, guessScore, guessCopy, dispose };
        });
        flush();
        const score = Promise.withResolvers<void>();
        const copy = Promise.withResolvers<void>();
        const first = action(function* () {
          guessScore(d => {
            d.score = 9;
          });
          yield score.promise;
        })();
        flush();
        const second = action(function* () {
          guessCopy(d => {
            d.copy = sample(d);
          });
          yield copy.promise;
        })();
        const copied = name === "descriptor value" ? 9 : 1;
        try {
          flush();
          expect([state.score, state.copy]).toEqual([9, copied]);
          score.resolve();
          await first;
          flush();
          expect([state.score, state.copy]).toEqual([existing ? 0 : 9, copied]);
          copy.resolve();
          await second;
          flush();
          expect([state.score, state.copy]).toEqual([existing ? 0 : undefined, 0]);
        } finally {
          score.resolve();
          copy.resolve();
          await Promise.all([first, second]);
          flush();
          dispose();
        }
      }
    );
