import { afterEach, describe, expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  resetErrorHalt
} from "../src/index.js";

const disposals: (() => void)[] = [];
const gates: ReturnType<typeof Promise.withResolvers<void>>[] = [];
const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(resolve => setTimeout(resolve, 0));
    flush();
  }
};
afterEach(async () => {
  for (const dispose of disposals.splice(0)) dispose();
  for (const gate of gates.splice(0)) gate.resolve();
  await tick();
  resetErrorHalt();
});

const cases = [
  {
    name: "distinct existing indices",
    initial: ["A", "B"],
    edit: (d: any[]) => {
      d[1] = "Y";
    },
    joined: false
  },
  {
    name: "growth",
    initial: ["A", "B"],
    edit: (d: any[]) => {
      d[2] = "Y";
    },
    joined: true
  },
  {
    name: "hole filling",
    initial: ["A", , "B"],
    edit: (d: any[]) => {
      d[1] = "Y";
    },
    joined: true
  },
  {
    name: "deletion",
    initial: ["A", "B"],
    edit: (d: any[]) => {
      delete d[1];
    },
    joined: true
  },
  {
    name: "explicit resize",
    initial: ["A", "B"],
    edit: (d: any[]) => {
      d.length = 1;
    },
    joined: true
  },
  {
    name: "same-value assignment",
    initial: ["A", "B"],
    edit: (d: any[]) => {
      d[1] = "B";
    },
    joined: false
  },
  {
    name: "transient growth",
    initial: ["A", "B"],
    edit: (d: any[]) => {
      d[2] = "Y";
      d.length = 2;
    },
    joined: false
  },
  {
    name: "transient deletion",
    initial: ["A", "B"],
    edit: (d: any[]) => {
      delete d[1];
      d[1] = "B";
    },
    joined: false
  }
];

describe.each([false, true])("array setter coordination (second finishes first=%s)", reverse => {
  for (const scenario of cases)
    it(scenario.name, async () => {
      const done = [Promise.withResolvers<void>(), Promise.withResolvers<void>()];
      gates.push(...done);
      const runs: (() => unknown)[] = [];
      let last!: { rows: any[]; saved: boolean[] };
      createRoot(dispose => {
        disposals.push(dispose);
        const [rows, setRows] = createOptimisticStore<any[]>(scenario.initial);
        const [savedA, setSavedA] = createSignal(false);
        const [savedB, setSavedB] = createSignal(false);
        createRenderEffect(
          () => ({ rows: Array.from(rows), saved: [savedA(), savedB()] }),
          value => {
            last = value;
          }
        );
        for (const [i, edit] of [
          (d: any[]) => {
            d[0] = "X";
          },
          scenario.edit
        ].entries())
          runs.push(
            action(function* () {
              setRows(edit);
              yield done[i].promise;
              (i ? setSavedB : setSavedA)(true);
            })
          );
      });
      await tick();
      runs[0]();
      await tick();
      runs[1]();
      await tick();
      const optimistic = last.rows;
      const first = reverse ? 1 : 0;
      done[first].resolve();
      await tick();
      expect(last.saved).toEqual(scenario.joined ? [false, false] : [first === 0, first === 1]);
      if (scenario.joined) expect(last.rows).toEqual(optimistic);
      done[1 - first].resolve();
      await tick();
      expect(last.saved).toEqual([true, true]);
      expect(last.rows).toEqual(Array.from(scenario.initial));
    });

  it("future existing-index writes join an active structural edit", async () => {
    const done = [Promise.withResolvers<void>(), Promise.withResolvers<void>()];
    gates.push(...done);
    const runs: (() => unknown)[] = [];
    let saved!: boolean[];
    createRoot(dispose => {
      disposals.push(dispose);
      const [, setRows] = createOptimisticStore(["A", "B"]);
      const [a, sa] = createSignal(false),
        [b, sb] = createSignal(false);
      createRenderEffect(
        () => [a(), b()],
        value => {
          saved = value;
        }
      );
      for (const [i, edit] of [
        (d: string[]) => {
          d[2] = "Z";
        },
        (d: string[]) => {
          d[0] = "X";
        }
      ].entries())
        runs.push(
          action(function* () {
            setRows(edit);
            yield done[i].promise;
            (i ? sb : sa)(true);
          })
        );
    });
    await tick();
    runs[0]();
    await tick();
    runs[1]();
    await tick();
    const first = reverse ? 1 : 0;
    done[first].resolve();
    await tick();
    expect(saved).toEqual([false, false]);
    done[1 - first].resolve();
    await tick();
    expect(saved).toEqual([true, true]);
  });
  it("nested row fields remain independent of the array structure", async () => {
    const done = [Promise.withResolvers<void>(), Promise.withResolvers<void>()];
    gates.push(...done);
    const runs: (() => unknown)[] = [];
    let saved!: boolean[];
    createRoot(dispose => {
      disposals.push(dispose);
      const [rows, setRows] = createOptimisticStore([{ name: "A" }]);
      const [a, sa] = createSignal(false),
        [b, sb] = createSignal(false);
      createRenderEffect(
        () => [rows[0].name, rows.length, a(), b()],
        value => {
          saved = [value[2] as boolean, value[3] as boolean];
        }
      );
      runs.push(
        action(function* () {
          setRows(d => {
            d[0].name = "X";
          });
          yield done[0].promise;
          sa(true);
        })
      );
      runs.push(
        action(function* () {
          setRows(d => {
            d[1] = { name: "B" };
          });
          yield done[1].promise;
          sb(true);
        })
      );
    });
    await tick();
    runs[0]();
    await tick();
    runs[1]();
    await tick();
    const first = reverse ? 1 : 0;
    done[first].resolve();
    await tick();
    expect(saved).toEqual([first === 0, first === 1]);
    done[1 - first].resolve();
    await tick();
    expect(saved).toEqual([true, true]);
  });
});
