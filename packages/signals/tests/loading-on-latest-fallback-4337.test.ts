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
  createMemo,
  createOptimistic,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest,
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
    asks.splice(i, 1)[0].res(v);
    await tick();
  };
  const frames: string[] = [];
  let setFilter!: (f: string) => void;
  let assign!: (id: number, who: string) => Promise<void>;
  createRoot(() => {
    const [filter, sf] = createSignal("open");
    setFilter = sf;
    const [issues, setIssues] = createOptimisticStore<Issue[]>(
      async (draft: Issue[]) => {
        const r: Issue[] = await ask(`fetchIssues:${filter()}`);
        draft.length = 0;
        draft.push(...r.map(x => ({ ...x })));
      },
      [],
      { key: "id" } as any
    );
    const [err, setErr] = createOptimistic("");
    assign = action(function* (id: number, who: string) {
      setErr("");
      setIssues((d: Issue[]) => {
        const i = d.findIndex(x => x.id === id);
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
            (i: any) => () => `#${i.id}(${i.assignee ?? "-"})`
          );
          return () =>
            m()
              .map(f => f())
              .join(" ") + err();
        },
        () => `loading ${latest(filter)}`,
        on ? { on: () => filter() } : undefined
      )
    );
    createRenderEffect(
      () => {
        const v = list();
        return `${filter()} | ${typeof v === "function" ? v() : v}`;
      },
      v => {
        if (frames.at(-1) !== v) frames.push(v);
      }
    );
  });
  return {
    asks,
    land,
    frames,
    screen: () => frames.at(-1),
    setFilter: (f: string) => {
      setFilter(f);
      flush();
    },
    assign: (id: number, w: string) => {
      assign(id, w);
      flush();
    }
  };
}

const MOUNT = ["open | loading open", "open | #1(-) #3(-)"];

describe("#4337 a fallback reading latest() during an independent input change", () => {
  for (const on of [true, false]) {
    it(`the swap follows the independent filter change (on=${on})`, async () => {
      const p = page(on);
      await p.land("fetchIssues:open", OPEN);
      p.assign(3, "ann");
      await tick();
      expect(p.screen()).toBe("open | #1(-) #3(ann)");

      // The filter is independent of the assignment lifetime.
      p.setFilter("closed");
      await tick();
      expect(p.screen()).toBe(on ? "closed | loading closed" : "open | #1(-) #3(ann)");
      await p.land("fetchIssues:closed", []);
      expect(p.screen()).toBe("closed | ");
      await p.land("assign:3,ann", undefined);
      expect(p.screen()).toBe("closed | ");
      // The independent input already landed; the action's refresh stays quiet.
      await p.land("fetchIssues:closed", []);
      expect(p.frames).toEqual([
        ...MOUNT,
        "open | #1(-) #3(ann)",
        ...(on ? ["closed | loading closed"] : []),
        "closed | "
      ]);
      expect(p.asks).toEqual([]);
    });

    it(`toggled back during an action, the newest input determines content (on=${on})`, async () => {
      const p = page(on);
      await p.land("fetchIssues:open", OPEN);
      p.assign(3, "ann");
      await tick();
      p.setFilter("closed");
      await tick();
      p.setFilter("open");
      await tick();
      expect(p.screen()).toBe(on ? "open | loading open" : "open | #1(-) #3(ann)");
      await p.land("fetchIssues:closed", []);
      expect(p.screen()).toBe(on ? "open | loading open" : "open | #1(-) #3(ann)");
      await p.land("fetchIssues:open", OPEN);
      expect(p.screen()).toBe("open | #1(-) #3(ann)");
      await p.land("assign:3,ann", undefined);
      expect(p.screen()).toBe("open | #1(-) #3(ann)");
      await p.land("fetchIssues:open", ASSIGNED);
      expect(p.frames).toEqual([
        ...MOUNT,
        "open | #1(-) #3(ann)",
        ...(on ? ["closed | loading closed", "open | loading open", "open | #1(-) #3(ann)"] : [])
      ]);
      expect(p.asks).toEqual([]);
    });
  }

  // Controls: nothing holds the change. The swap shows with it (`on`) and the
  // fallback clears when its content's answer lands; without `on` the content
  // stays until the answer (F-2).
  it("control: no hold — the fallback shows with the change and clears at its answer", async () => {
    const p = page(true);
    await p.land("fetchIssues:open", OPEN);
    p.setFilter("closed");
    await tick();
    expect(p.screen()).toBe("closed | loading closed");
    await p.land("fetchIssues:closed", []);
    expect(p.frames).toEqual([...MOUNT, "closed | loading closed", "closed | "]);
  });
  it("control: no hold, toggled back — the fallback clears at the newest answer", async () => {
    const p = page(true);
    await p.land("fetchIssues:open", OPEN);
    p.setFilter("closed");
    await tick();
    p.setFilter("open");
    await tick();
    expect(p.screen()).toBe("open | loading open");
    await p.land("fetchIssues:closed", []);
    expect(p.screen()).toBe("open | loading open");
    await p.land("fetchIssues:open", OPEN);
    expect(p.frames).toEqual([
      ...MOUNT,
      "closed | loading closed",
      "open | loading open",
      "open | #1(-) #3(-)"
    ]);
  });
  it("control: no hold, no `on` — the content stays until the answer", async () => {
    const p = page(false);
    await p.land("fetchIssues:open", OPEN);
    p.setFilter("closed");
    await tick();
    expect(p.screen()).toBe("open | #1(-) #3(-)");
    await p.land("fetchIssues:closed", []);
    expect(p.frames).toEqual([...MOUNT, "closed | "]);
  });

  // The boundary's half alone, no optimism (as on `next`): an input written
  // inside an action is held with it; the swap its `on` asks for is that
  // frame's, whatever the fallback reads.
  for (const viaLatest of [true, false])
    it(`an action-held input: the swap waits for the action (fallback reads ${viaLatest ? "latest()" : "the input"})`, async () => {
      const asks: { key: string; res: (v: any) => void }[] = [];
      const ask = (key: string) => new Promise<any>(res => asks.push({ key, res }));
      const land = async (key: string, v: any) => {
        asks
          .splice(
            asks.findIndex(a => a.key === key),
            1
          )[0]
          .res(v);
        await tick();
      };
      const frames: string[] = [];
      let go!: () => void;
      createRoot(() => {
        const [filter, setFilter] = createSignal("open");
        const list = createMemo(async () => ask(`list:${filter()}`));
        go = action(function* () {
          setFilter("closed");
          yield ask("act");
        }) as any;
        const b = untrack(() =>
          createLoadingBoundary(
            () => () => (list() as string[]).join(","),
            () => `loading ${viaLatest ? latest(filter) : filter()}`,
            { on: () => filter() }
          )
        );
        createRenderEffect(
          () => {
            const v = b();
            return `${filter()} | ${typeof v === "function" ? v() : v}`;
          },
          v => void frames.push(v)
        );
      });
      await tick();
      await land("list:open", ["a"]);
      go();
      await tick();
      expect(frames.at(-1)).toBe("open | a");
      await land("list:closed", ["b"]);
      expect(frames.at(-1)).toBe("open | a");
      await land("act", 1);
      expect(frames).toEqual(["open | loading open", "open | a", "closed | b"]);
    });
});
