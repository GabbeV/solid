/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
/**
 * An independent producer error reaches unguessed row fields even while an
 * assignee output is selected by an action. The DOM consumes those other
 * fields and may show its error fallback; the explicit assignee guess remains
 * independently readable until its action ends. Neither path may wedge.
 */
import { expect, test } from "vitest";
import {
  Loading,
  Errored,
  For,
  action,
  createOptimisticStore,
  createSignal,
  createMemo,
  createEffect,
  flush,
  untrack
} from "solid-js";
// The primitive behind `Errored` (ReactiveScript lowers `e catch (x) => alt`
// to it): typed for renderers through `solid-js/internal`.
import { createErrorBoundary } from "solid-js/internal";
import { render } from "../src/index.js";

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};

test("#4480: a re-ask failing under a pending guess, read through createErrorBoundary, settles", async () => {
  const asks: { key: string; res: (v: any) => void; rej: (e: any) => void }[] = [];
  const ask = (key: string) => new Promise<any>((res, rej) => asks.push({ key, res, rej }));
  const settle = async (key: string, f: (a: (typeof asks)[number]) => void) => {
    const i = asks.findIndex(a => a.key === key);
    f(asks.splice(i, 1)[0]);
    await tick();
  };
  const container = document.body.appendChild(document.createElement("div"));
  const seen: string[] = [];
  const observer = new MutationObserver(() => seen.push(container.textContent!));
  observer.observe(container, { childList: true, subtree: true, characterData: true });
  let setFilter!: (f: string) => void;
  let rowAssign!: (id: number, who: string) => any;
  let selectedAssignee!: () => unknown;
  const dispose = render(() => {
    const [filter, sf] = createSignal("open");
    setFilter = sf;
    const list = createMemo(() => ask(`issues:${filter()}`));
    const [issues, set] = createOptimisticStore(
      async (d: any[]) => {
        const r = (list() as any[]).map(t => ({ ...t, open: filter() === "open" }));
        d.length = r.length;
        r.forEach((x, i) => {
          d[i] = x;
        });
      },
      [] as any[],
      { key: "id" }
    );
    selectedAssignee = () => issues[0].assignee;
    rowAssign = action(function* (id: number, who: string) {
      const i = untrack(() => issues.findIndex((t: any) => t.id === id));
      set((d: any) => {
        d[i].assignee = who;
      });
      yield ask(`assign:${id}`);
    });
    createEffect(
      () => [
        filter(),
        untrack(() =>
          createErrorBoundary(
            () => issues,
            () => null
          )
        )()
      ],
      { effect: () => {}, error: () => {} }
    );
    return (
      <Loading fallback={<p>loading</p>}>
        <Errored fallback={() => <p>err</p>}>
          <For each={issues}>
            {(it: any) => (
              <i>
                [#{it.id} {it.assignee}]
              </i>
            )}
          </For>
        </Errored>
      </Loading>
    );
  }, container);
  try {
    await tick();
    await settle("issues:open", a =>
      a.res([
        { id: 1, assignee: null },
        { id: 3, assignee: null }
      ])
    );
    expect(container.textContent).toBe("[#1 ][#3 ]");
    rowAssign(1, "guest");
    await tick();
    expect(container.textContent).toBe("[#1 guest][#3 ]");
    setFilter("closed");
    await tick();
    expect(container.textContent).toBe("[#1 guest][#3 ]");
    // Hung here: Potential Infinite Loop Detected.
    await settle("issues:closed", a => a.rej(new Error("declined")));
    expect(container.textContent).toBe("err");
    expect(selectedAssignee()).toBe("guest");
    await settle("assign:1", a => a.res({}));
    expect(container.textContent).toBe("err");
    const allowed = new Set(["loading", "[#1 ][#3 ]", "[#1 guest][#3 ]", "err"]);
    expect(seen.filter(frame => !allowed.has(frame))).toEqual([]);
  } finally {
    observer.disconnect();
    dispose();
    container.remove();
  }
});
