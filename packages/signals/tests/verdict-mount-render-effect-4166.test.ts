/**
 * #4166: a latest-opened branch mounts from a complete committed lower frame.
 * An action holds x=1 over x=0. Both the outside binding and the new child
 * read 0 until the action completes, then publish 1 together. Next additionally
 * holds this mount; the shared model uses the accepted natural mount rule.
 * It must never show a proposed 1 inside beside a committed 0 outside.
 */
import { afterEach, describe, expect, it } from "vitest";
import {
  action,
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

async function mountUnderVerdict(contentInMemo: boolean) {
  const [x, setX] = createSignal(0);
  let screenX: unknown;
  let inner: unknown;
  let slot: unknown;
  createRoot(dispose => {
    disposals.push(dispose);
    // <i>{x()}</i>
    createRenderEffect(x, v => {
      screenX = v;
    });
    // <Show when={latest(x) > 0}>
    //   <Loading fallback="pending"><p>{x()}</p></Loading>
    // </Show>
    const p = () => {
      createRenderEffect(x, v => {
        inner = v;
      });
      return "p";
    };
    // A component that returns a memo: the render effect is created two
    // creation passes below the verdict pass that mounted the boundary.
    const content = contentInMemo ? () => createMemo(p)() : p;
    const when = createMemo(() => latest(x) > 0);
    const condition = createMemo(() => when());
    const children = createMemo(() =>
      condition() ? untrack(() => createLoadingBoundary(content, () => "pending")) : "closed"
    );
    createRenderEffect(
      () => {
        const c = children();
        return typeof c === "function" ? c() : c;
      },
      v => {
        slot = v;
      }
    );
  });
  flush();
  const screens: unknown[] = [[screenX, slot, inner]];

  let release!: () => void;
  const done = action(function* () {
    setX(1);
    yield new Promise<void>(r => (release = r));
  })();
  await settle();
  screens.push([screenX, slot, inner]);

  release();
  await done;
  await settle();
  screens.push([screenX, slot, inner]);
  return screens;
}

describe("#4166: a latest-mounted boundary uses the committed lower frame", () => {
  it("the boundary shows committed content while the action holds its replacement", async () => {
    expect(await mountUnderVerdict(false)).toEqual([
      [0, "closed", undefined],
      [0, "p", 0],
      [1, "p", 1]
    ]);
  });

  it("same with the render effect inside a memo the content creates", async () => {
    expect(await mountUnderVerdict(true)).toEqual([
      [0, "closed", undefined],
      [0, "p", 0],
      [1, "p", 1]
    ]);
  });
});
