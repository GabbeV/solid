/**
 * S-46: a latest-opened branch uses the same committed ordinary values as
 * existing readers. With id=1 held over id=0, both ordinary bindings show 0;
 * explicit latest(id) can show 1. A complete committed frame can mount now,
 * with or without Loading, under the accepted natural mount rule. Next's
 * additional mount hold is intentionally not retained. No empty value or
 * proposed ordinary value may appear in the new branch.
 */
import { afterEach, describe, expect, it } from "vitest";
import {
  createLoadingBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest,
  untrack
} from "../src/index.js";

const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

const settle = async () => {
  for (let i = 0; i < 3; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};

type Content = "plain" | "latest" | "loading";

async function run(content: Content) {
  const [id, setId] = createSignal(0);
  const gates: ((v: string) => void)[] = [];
  const fetchDetail = (v: number) => new Promise<string>(r => gates.push(() => r(`d${v}`)));
  let screenId: unknown;
  let slot: unknown;
  let screenDetail: unknown;
  createRoot(dispose => {
    disposals.push(dispose);
    // <p>{id()}</p>
    createRenderEffect(id, v => {
      screenId = v;
    });
    // <p>{detail()}</p> — the async over `id` that holds a write to it
    const detail = createMemo(() => fetchDetail(id()));
    createRenderEffect(detail, v => {
      screenDetail = v;
    });
    // <Show when={latest(id)} fallback="none">…</Show> — the branch is a
    // mount: a render effect created under the display-ahead reader, as
    // `Show` + `insert` create one for the child.
    const when = createMemo(() => latest(id) > 0);
    const children = createMemo(() =>
      when()
        ? untrack(() => {
            if (content === "loading")
              return createLoadingBoundary(
                () => `selected: ${id()}`,
                () => "fallback"
              );
            createRenderEffect(
              () => `selected: ${content === "latest" ? latest(id) : id()}`,
              v => {
                slot = v;
              }
            );
            return "opened";
          })
        : "none"
    );
    createRenderEffect(
      () => {
        const c = children();
        return typeof c === "function" ? c() : c;
      },
      v => {
        // the mounted leaf writes the slot itself; "opened" is the branch
        // existing with its leaf not yet attached
        if (v !== "opened") slot = v;
      }
    );
  });
  flush();
  gates.shift()!("d0");
  await settle();
  const screens: unknown[] = [[screenId, slot, screenDetail]];

  setId(1);
  flush();
  await settle();
  screens.push([screenId, slot, screenDetail]);

  gates.shift()!("d1");
  await settle();
  screens.push([screenId, slot, screenDetail]);
  return screens;
}

describe("S-46: the content a display-ahead Show opens reads the screen (plain-write hold)", () => {
  it("plain `id()` inside: the branch mounts with the committed value", async () => {
    expect(await run("plain")).toEqual([
      [0, "none", "d0"],
      [0, "selected: 0", "d0"],
      [1, "selected: 1", "d1"]
    ]);
  });

  it("`latest(id)` inside: the branch shows the held value now", async () => {
    expect(await run("latest")).toEqual([
      [0, "none", "d0"],
      [0, "selected: 1", "d0"],
      [1, "selected: 1", "d1"]
    ]);
  });

  it("a `Loading` inside: complete committed content mounts without fallback", async () => {
    expect(await run("loading")).toEqual([
      [0, "none", "d0"],
      [0, "selected: 0", "d0"],
      [1, "selected: 1", "d1"]
    ]);
  });
});
