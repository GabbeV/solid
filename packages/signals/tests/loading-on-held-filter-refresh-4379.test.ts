/** Stage 120 keeps an independent filter update separate from the guessing
 * action. With `on`, its fallback can publish immediately; without `on`,
 * the content holds until that input answers. Selected property overrides
 * retain their own action lifetimes and do not rebase onto a new question.
 * The action's later refresh still publishes a coherent content frame.
 */
import { describe, expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  mapArray,
  refresh,
  untrack
} from "../src/index.js";

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
type Issue = { id: number; assignee: string | null };
const OPEN: Issue[] = [
  { id: 1, assignee: null },
  { id: 3, assignee: null }
];
const ASSIGNED: Issue[] = [
  { id: 1, assignee: null },
  { id: 3, assignee: "ann" }
];

function page(on: boolean) {
  const asks: { key: string; res: (v: any) => void }[] = [];
  const ask = (key: string) => new Promise<any>(res => asks.push({ key, res }));
  const land = async (key: string, v: any) => {
    const i = asks.findIndex(a => a.key === key);
    if (i < 0) throw new Error(`not asked: ${key}; asked: ${asks.map(a => a.key)}`);
    // A fresh answer each time, as a fetch gives.
    asks.splice(i, 1)[0].res(structuredClone(v));
    await tick();
  };
  const frames: string[] = [];
  let setFilter!: (f: string) => void;
  let assign!: (id: number, who: string) => void;
  createRoot(() => {
    const [filter, sf] = createSignal("open");
    setFilter = sf;
    const [issues, setIssues] = createOptimisticStore<Issue[]>(
      async (d: Issue[]) => {
        const r: Issue[] = await ask(`fetchIssues:${filter()}`);
        d.length = r.length;
        r.forEach((x, i) => ((d as any)[i] = x));
      },
      [],
      { key: "id" } as any
    );
    assign = action(function* (id: number, who: string) {
      const i = issues.findIndex(t => t.id === id);
      setIssues((d: Issue[]) => {
        d[i].assignee = who;
      });
      yield ask(`assign:${id},${who}`);
      refresh(issues);
    }) as any;
    const list = untrack(() =>
      createLoadingBoundary(
        () => {
          const m = mapArray(
            () => issues,
            (i: any) => {
              // Frame readers per row, under the boundary (`<For>`'s text
              // holes). The `id` read is not served by the guess: over the
              // new question it is an ordinary pending read (#4336
              // `stands`), recorded by the boundary and settled by the input answer.
              createRenderEffect(
                () => i.id,
                () => {}
              );
              createRenderEffect(
                () => i.assignee,
                () => {}
              );
              return () => `#${i.id}(${i.assignee ?? "-"})`;
            }
          );
          return () =>
            m()
              .map(f => f())
              .join(" ");
        },
        () => "loading",
        on ? { on: () => filter() } : undefined
      )
    );
    createRenderEffect(
      () => {
        const v: any = list();
        return typeof v === "function" ? v() : v;
      },
      v => {
        if (frames.at(-1) !== v) frames.push(v);
      }
    );
  });
  return {
    land,
    asks,
    frames,
    screen: () => frames.at(-1),
    setFilter: async (f: string) => {
      setFilter(f);
      flush();
      await tick();
    },
    assign: async (id: number, who: string) => {
      assign(id, who);
      flush();
      await tick();
    }
  };
}

const MOUNT = ["loading", "#1(-) #3(-)"];

describe("#4379 an independent `on` change during an optimistic action", () => {
  for (const on of [true, false]) {
    it(`toggled back during an action: its later refresh stays quiet (on=${on})`, async () => {
      const p = page(on);
      await tick();
      await p.land("fetchIssues:open", OPEN);
      await p.assign(3, "ann");
      await p.setFilter("closed");
      await p.setFilter("open");
      expect(p.screen()).toBe(on ? "loading" : "#1(-) #3(ann)");
      await p.land("fetchIssues:closed", []);
      await p.land("fetchIssues:open", OPEN);
      expect(p.screen()).toBe("#1(-) #3(ann)");
      await p.land("assign:3,ann", undefined);
      expect(p.screen()).toBe("#1(-) #3(ann)");
      await p.land("fetchIssues:open", ASSIGNED);
      expect(p.frames).toEqual([
        ...MOUNT,
        "#1(-) #3(ann)",
        ...(on ? ["loading", "#1(-) #3(ann)"] : [])
      ]);
      expect(p.asks).toEqual([]);
    });

    // The input answer keeps the keys and the selected assignee override.
    it(`a new question keeps the rows and selected assignee (on=${on})`, async () => {
      const p = page(on);
      await tick();
      await p.land("fetchIssues:open", OPEN);
      await p.assign(3, "ann");
      await p.setFilter("closed");
      expect(p.screen()).toBe(on ? "loading" : "#1(-) #3(ann)");
      await p.land("fetchIssues:closed", OPEN);
      expect(p.screen()).toBe("#1(-) #3(ann)");
      await p.land("assign:3,ann", undefined);
      expect(p.screen()).toBe("#1(-) #3(ann)");
      await p.land("fetchIssues:closed", ASSIGNED);
      expect(p.frames).toEqual([
        ...MOUNT,
        "#1(-) #3(ann)",
        ...(on ? ["loading", "#1(-) #3(ann)"] : [])
      ]);
      expect(p.asks).toEqual([]);
    });
  }

  // An independent answer may drop rows before the guessing action ends.
  it("control: an independent answer drops the rows before refresh", async () => {
    const p = page(true);
    await tick();
    await p.land("fetchIssues:open", OPEN);
    await p.assign(3, "ann");
    await p.setFilter("closed");
    await p.land("fetchIssues:closed", []);
    await p.land("assign:3,ann", undefined);
    expect(p.screen()).toBe("");
    await p.land("fetchIssues:closed", []);
    expect(p.frames).toEqual([...MOUNT, "#1(-) #3(ann)", "loading", ""]);
  });

  // Control: nothing holds the change — the fallback shows with it (D-15).
  it("control: no hold — the fallback shows with the change and clears at its answer", async () => {
    const p = page(true);
    await tick();
    await p.land("fetchIssues:open", OPEN);
    await p.setFilter("closed");
    expect(p.screen()).toBe("loading");
    await p.land("fetchIssues:closed", OPEN);
    expect(p.frames).toEqual([...MOUNT, "loading", "#1(-) #3(-)"]);
  });
});
