/**
 * #4613 under independent input/override lifetimes (stage 120): a keyed
 * region may show Loading when it consumes the new producer flight, while
 * a guessed index stays selected. Disposed regions must never map again.
 * Track real region cleanup rather than assuming the old family-wide hold.
 */
import { afterEach, expect, it, vi } from "vitest";
import {
  action,
  createEffect,
  createErrorBoundary,
  createLoadingBoundary,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  mapArray,
  onCleanup,
  refresh
} from "../src/index.js";

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};

afterEach(() => vi.restoreAllMocks());

it("#4613: a region disposed while its list is lane work does not run again (F-3, D-11)", async () => {
  const warn = vi.spyOn(console, "warn").mockImplementation(() => {});
  const asks: { key: string; res: (v: any) => void }[] = [];
  const ask = (key: string) => new Promise<any>(res => asks.push({ key, res }));
  const settle = async (key: string, v: any) => {
    const i = asks.findIndex(a => a.key === key);
    expect(i).not.toBe(-1);
    asks.splice(i, 1)[0].res(v);
    await tick();
  };
  let shown = "";
  const rows: string[] = [];
  const regionsCreated: { filter: string; disposed: number }[] = [];
  const mappedAfterDisposal: string[] = [];
  const selected: unknown[] = [];
  let setFilter!: (f: string) => void;
  let close!: (id: number) => any;
  const dispose = createRoot(d => {
    const [filter, sf] = createSignal("open");
    setFilter = sf;
    const [store, setStore] = createOptimisticStore(
      () => ask(`issues:${filter()}`),
      [] as { id: number }[],
      { key: "id" }
    );
    close = action(function* (id: number) {
      setStore(list => {
        const i = list.findIndex(t => t.id === id);
        if (i >= 0) list.splice(i, 1);
      });
      yield ask(`close:${id}`);
      refresh(store);
    });
    createEffect(() => store[1]?.id, {
      effect: value => {
        selected.push(value);
      },
      error: error => {
        selected.push(error);
      }
    });
    const regions = mapArray(
      () => [filter()],
      (f: string) => {
        const region = { filter: f, disposed: 0 };
        regionsCreated.push(region);
        onCleanup(() => {
          region.disposed++;
        });
        return createLoadingBoundary(
          () =>
            createErrorBoundary(
              () => {
                const list = mapArray(
                  () => store,
                  (it: { id: number }) => {
                    if (region.disposed) mappedAfterDisposal.push(f);
                    rows.push(`${f}:${it.id}`);
                    return `[#${it.id}]`;
                  }
                );
                return () => list().join("");
              },
              e => () => `error ${(e() as Error).message}`
            ),
          () => () => "loading"
        );
      }
    );
    createRenderEffect(
      () =>
        regions()
          .map(r => {
            // Boundaries resolve function children; unwrap whatever is left.
            let v: any = r();
            while (typeof v === "function") v = v();
            return v;
          })
          .join(""),
      v => void (shown = v)
    );
    return d;
  });
  try {
    await tick();
    await settle("issues:open", [{ id: 1 }, { id: 3 }, { id: 4 }]);
    expect(shown).toBe("[#1][#3][#4]");
    close(3);
    await tick();
    expect(shown).toBe("[#1][#4]");
    expect(selected).toEqual([3, 4]);
    setFilter("closed");
    await tick();
    // The newly keyed region consumes the independent producer flight and
    // can show Loading. The selected guessed index remains 4.
    expect(shown).toBe("loading");
    expect(selected).toEqual([3, 4]);
    await settle("issues:closed", [{ id: 2 }]);
    await settle("close:3", {});
    rows.length = 0;
    await settle("issues:closed", [{ id: 2 }, { id: 3 }]);
    expect(shown).toBe("[#2][#3]");
    expect(regionsCreated[0]).toEqual({ filter: "open", disposed: 1 });
    expect(mappedAfterDisposal).toEqual([]);
    setFilter("open");
    await tick();
    await settle("issues:open", [{ id: 1 }, { id: 4 }]);
    expect(shown).toBe("[#1][#4]");
    // The initial open region was actually disposed before these updates.
    // Only the newly mounted open region may map the final rows.
    expect(rows.slice(-2)).toEqual(["open:1", "open:4"]);
    expect(regionsCreated.map(region => region.disposed)).toEqual([1, 1, 0]);
    expect(mappedAfterDisposal).toEqual([]);
    expect(warn.mock.calls.map(c => String(c[0])).filter(m => m.includes("DISPOSED"))).toEqual([]);
  } finally {
    dispose();
    flush();
  }
  expect(regionsCreated.map(region => region.disposed)).toEqual([1, 1, 1]);
});
