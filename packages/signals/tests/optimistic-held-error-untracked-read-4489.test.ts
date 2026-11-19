/**
 * #4489 control under independent input/override lifetimes (stage 120):
 * a whole-list read consumes unguessed inputs and can show their error while
 * a selected guessed row remains readable. At correction the guessed output
 * consumes its input error as well. This deliberately differs from next's
 * family-wide D-34 hold.
 */
import { expect, it } from "vitest";
import {
  action,
  createEffect,
  createErrorBoundary,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  refresh,
  untrack
} from "../src/index.js";

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};

it("#4489: a guessed row remains readable while an independent input error reaches the whole list", async () => {
  const asks: { key: string; res: (v: any) => void; rej: (e: any) => void }[] = [];
  const ask = (key: string) => new Promise<any>((res, rej) => asks.push({ key, res, rej }));
  const settle = async (key: string, f: (a: (typeof asks)[number]) => void) => {
    for (const a of asks.filter(a => a.key === key)) {
      asks.splice(asks.indexOf(a), 1);
      f(a);
    }
    await tick();
  };
  const frames: string[] = [];
  const screen: string[] = [];
  let setFilter!: (f: string) => void;
  let issues!: any[];
  let close!: (id: number) => any;
  const dispose = createRoot(d => {
    const [filter, sf] = createSignal("open");
    setFilter = sf;
    const [store, setStore] = createOptimisticStore(
      async () => await ask(`f:${filter()}`),
      [] as any[],
      { key: "id" }
    );
    issues = store;
    close = action(function* (id: number) {
      setStore((d: any[]) => {
        const i = d.findIndex(x => x.id === id);
        if (i >= 0) d.splice(i, 1);
      });
      yield ask(`close:${id}`);
      refresh(store);
    });
    const rows = () => (store as any[]).map(i => `#${i.id}`).join(" ");
    createEffect(rows, {
      effect: (v: string) => void frames.push(v),
      error: (e: any) => void frames.push(`ERR ${e?.message ?? e}`)
    });
    // The screen: an `<Errored>` over the rows.
    createRenderEffect(
      createErrorBoundary(rows, (e: () => any) => `ERR ${e()?.message}`),
      v => void screen.push(v)
    );
    return d;
  });
  try {
    await tick();
    await settle("f:open", a => a.res([{ id: 1 }, { id: 3 }, { id: 4 }]));
    close(3);
    await tick();
    expect(frames).toEqual(["#1 #3 #4", "#1 #4"]);
    setFilter("closed");
    flush();
    await tick();
    await settle("f:closed", a => a.rej(new Error("declined")));
    // The unguessed rows consume the independent producer error, so the
    // whole-list view shows its fallback. The guessed index still selects
    // its own output; a handler can read it until the action retires.
    expect(frames).toEqual(["#1 #3 #4", "#1 #4", "ERR declined"]);
    expect(screen.at(-1)).toBe("ERR declined");
    expect(untrack(() => issues[1].id)).toBe(4);
    expect(untrack(() => issues.length)).toBe(2);
    // The close is accepted; its refresh re-asks the input. The shown error
    // remains until the replacement answer; retirement then exposes that
    // error through the formerly guessed index too.
    await settle("close:3", a => a.res({}));
    expect(frames.at(-1)).toBe("ERR declined");
    await settle("f:closed", a => a.rej(new Error("declined again")));
    expect(frames.at(-1)).toBe("ERR declined again");
    expect(screen.at(-1)).toBe("ERR declined again");
    expect(() => untrack(() => issues[1])).toThrow("declined again");
  } finally {
    dispose();
    flush();
  }
});
