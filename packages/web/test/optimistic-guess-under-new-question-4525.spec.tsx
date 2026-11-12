/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
/**
 * The optimistic store selects the indices explicitly written by the splice. The
 * producer does not replay that operation over its next answer. Those row
 * outputs retain their action lifetime. An independent question publishes
 * beside those rows once its ordinary input readers are ready; an `on`
 * boundary may reveal the ready selected content earlier. The final refresh
 * corrects the indices. Only complete, consistent DOM frames are allowed.
 */
import { expect, test } from "vitest";
import {
  For,
  Loading,
  action,
  createOptimisticStore,
  createSignal,
  flush,
  refresh
} from "solid-js";
import { render } from "../src/index.js";

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};

for (const on of [true, false])
  test(`#4525: a new question preserves selected indices until their correction (on=${on})`, async () => {
    const asks: { key: string; res: (v: any) => void }[] = [];
    const ask = (key: string) => new Promise<any>(res => asks.push({ key, res }));
    const settle = async (key: string, v: any) => {
      const i = asks.findIndex(a => a.key === key);
      asks.splice(i, 1)[0].res(v);
      await tick();
    };
    const container = document.body.appendChild(document.createElement("div"));
    // Every DOM state the screen passes through.
    const seen: string[] = [];
    const observer = new MutationObserver(() => seen.push(container.textContent!));
    observer.observe(container, { childList: true, subtree: true, characterData: true });
    let setFilter!: (f: string) => void;
    let closeOne!: (id: number) => any;
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
      const body = () => (
        <p>
          {filter()}: <For each={issues}>{(it: any) => <i>[#{it.id}]</i>}</For>
        </p>
      );
      return on ? (
        <Loading on={filter()} fallback={<p>loading</p>}>
          {body()}
        </Loading>
      ) : (
        <Loading fallback={<p>loading</p>}>{body()}</Loading>
      );
    }, container);
    try {
      await tick();
      await settle("issues:open", [{ id: 1 }, { id: 3 }, { id: 4 }]);
      expect(container.textContent).toBe("open: [#1][#3][#4]");
      setFilter("closed");
      await tick();
      expect(container.textContent).toBe(on ? "loading" : "open: [#1][#3][#4]");
      closeOne(1);
      await tick();
      const selected = on ? "closed: [#3][#4]" : "open: [#3][#4]";
      expect(container.textContent).toBe(selected);
      if (!on) expect(seen.filter(frame => frame.startsWith("closed:"))).toEqual([]);
      await settle("issues:closed", [{ id: 1 }, { id: 2 }]);
      expect(container.textContent).toBe("closed: [#3][#4]");
      await settle("close:1", {});
      expect(container.textContent).toBe("closed: [#3][#4]");
      await settle("issues:closed", [{ id: 2 }]);
      expect(container.textContent).toBe("closed: [#2]");
      expect(asks).toEqual([]);
      // The old complete selection may remain, but no partially corrected
      // question/list combination, duplicate row, or hole may publish.
      const allowed = new Set([
        "loading",
        "open: [#1][#3][#4]",
        "open: [#3][#4]",
        "closed: [#3][#4]",
        "closed: [#2]"
      ]);
      expect(seen.filter(frame => !allowed.has(frame))).toEqual([]);
    } finally {
      observer.disconnect();
      dispose();
      container.remove();
    }
  });
