/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 *
 * #4613 under independent input and override lifetimes: a new keyed region
 * may show Loading while it consumes the producer's flight. The selected
 * index still owns its guess. A disposed region must never map another row,
 * even when an action or a later producer answer finishes.
 */
import { render } from "@solidjs/web";
import {
  action,
  createOptimisticStore,
  createSignal,
  Errored,
  flush,
  For,
  Loading,
  onCleanup,
  refresh
} from "solid-js";
import { afterEach, expect, it, vi } from "vitest";

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};

afterEach(() => vi.restoreAllMocks());

it("a disposed keyed region does not map again after its input settles (#4613)", async () => {
  const warn = vi.spyOn(console, "warn").mockImplementation(() => {});
  const asks: { key: string; res: (v: any) => void }[] = [];
  const ask = (key: string) => new Promise<any>(res => asks.push({ key, res }));
  const settle = async (key: string, v: any) => {
    const i = asks.findIndex(a => a.key === key);
    expect(i).not.toBe(-1);
    asks.splice(i, 1)[0].res(v);
    await tick();
  };
  const container = document.createElement("div");
  let setFilter!: (f: string) => void;
  let closeOne!: (id: number) => any;
  const rows: string[] = [];
  const regions: { filter: string; disposed: number }[] = [];
  const mappedAfterDisposal: string[] = [];
  const dispose = render(() => {
    const [filter, sf] = createSignal("open");
    setFilter = sf;
    const [issues, set] = createOptimisticStore<any[]>(() => ask(`issues:${filter()}`), [], {
      key: "id"
    });
    closeOne = action(function* (id: number) {
      set(list => {
        const i = list.findIndex(t => t.id === id);
        if (i >= 0) list.splice(i, 1);
      });
      yield ask(`close:${id}`);
      refresh(issues);
    });
    return (
      <For each={[filter()]}>
        {(f: string) => {
          const region = { filter: f, disposed: 0 };
          regions.push(region);
          onCleanup(() => {
            region.disposed++;
          });
          return (
            <Loading fallback={<p>loading {f}</p>}>
              <Errored fallback={(e: any) => <p>error {e().message}</p>}>
                <For each={issues}>
                  {(it: any) => {
                    if (region.disposed) mappedAfterDisposal.push(f);
                    rows.push(`${f}:${it.id}`);
                    return <i>[#{it.id}]</i>;
                  }}
                </For>
              </Errored>
            </Loading>
          );
        }}
      </For>
    );
  }, container);
  await tick();
  await settle("issues:open", [{ id: 1 }, { id: 3 }, { id: 4 }]);
  expect(container.textContent).toBe("[#1][#3][#4]");
  closeOne(3);
  await tick();
  expect(container.textContent).toBe("[#1][#4]");
  setFilter("closed");
  await tick();
  // The new region consumes the independent input; it does not extend the action.
  expect(container.textContent).toBe("loading closed");
  await settle("issues:closed", [{ id: 2 }]);
  expect(container.textContent).toBe("[#2][#4]");
  await settle("close:3", {});
  expect(container.textContent).toBe("[#2][#4]");
  rows.length = 0;
  await settle("issues:closed", [{ id: 2 }, { id: 3 }]);
  expect(container.textContent).toBe("[#2][#3]");
  expect(regions[0]).toEqual({ filter: "open", disposed: 1 });
  expect(mappedAfterDisposal).toEqual([]);
  setFilter("open");
  await tick();
  expect(container.textContent).toBe("loading open");
  await settle("issues:open", [{ id: 1 }, { id: 4 }]);
  expect(container.textContent).toBe("[#1][#4]");
  // The intermediate closed answer may mount rows. The final open region
  // alone owns the final pair; cleanup tracking rules out disposed mappers.
  expect(rows.slice(-2)).toEqual(["open:1", "open:4"]);
  expect(regions.map(region => region.disposed)).toEqual([1, 1, 0]);
  expect(mappedAfterDisposal).toEqual([]);
  expect(warn.mock.calls.map(c => String(c[0])).filter(m => m.includes("DISPOSED"))).toEqual([]);
  dispose();
  expect(regions.map(region => region.disposed)).toEqual([1, 1, 1]);
});
