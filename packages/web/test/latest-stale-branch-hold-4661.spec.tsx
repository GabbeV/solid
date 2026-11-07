/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */

// #4661: the shared-update experiment rejects #4663's stale-branch exception.
// Once the ordinary filter commits, count's ordinary branch selection commits
// with it. latest permits an independent list value, not an old filter branch.

import { expect, test } from "vitest";
import { Loading, createEffect, createMemo, createSignal, flush, latest } from "solid-js";
import { render } from "../src/index.js";

async function settle() {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
}

function app(reader: "effect" | "view", hold = false) {
  const blocker = Promise.withResolvers<number>();
  const asks = new Map<string, (v: number[]) => void>();
  const ask = (key: string) => new Promise<number[]>(res => asks.set(key, res));
  let seen: number | undefined;
  let setF!: (v: string) => void;
  const div = document.createElement("div");
  const dispose = render(() => {
    const [f, set] = createSignal("open");
    setF = set;
    const list = createMemo(() => ask(`list:${f()}`));
    const blocking = createMemo(() => (hold && f() === "closed" ? blocker.promise : 0));
    const count = createMemo(() => (f() === "open" ? latest(() => list().length) : -1));
    if (reader === "effect")
      createEffect(
        () => count(),
        v => {
          seen = v;
        }
      );
    return (
      <>
        <header>{f()}</header>
        {hold && <em>{blocking()}</em>}
        {reader === "view" ? <span>{`[${count()}]`}</span> : null}
        <Loading fallback={<i>first</i>}>
          <Loading on={f()} fallback={<i>loading {f()}</i>}>
            <b>{list().join(",")}</b>
          </Loading>
        </Loading>
      </>
    );
  }, div);
  return {
    div,
    dispose,
    unblock: () => blocker.resolve(1),
    seen: () => seen,
    setF: (v: string) => setF(v),
    land: (key: string, v: number[]) => asks.get(key)!(v)
  };
}

test("latest() in the branch taken before the switch, read by an effect (#4661)", async () => {
  const a = app("effect");
  flush();
  a.land("list:open", [1, 2, 3]);
  await settle();
  expect(a.div.innerHTML).toBe("<header>open</header><b>1,2,3</b>");
  expect(a.seen()).toBe(3);
  a.setF("closed");
  flush();
  await settle();
  expect(a.div.innerHTML).toBe("<header>closed</header><i>loading closed</i>");
  expect(a.seen()).toBe(-1);
  a.land("list:closed", [9]);
  await settle();
  expect(a.div.innerHTML).toBe("<header>closed</header><b>9</b>");
  expect(a.seen()).toBe(-1);
  a.dispose();
});

test("latest() in the branch taken before the switch, read by a view outside the boundary (#4661)", async () => {
  const a = app("view");
  flush();
  a.land("list:open", [1, 2, 3]);
  await settle();
  expect(a.div.innerHTML).toBe("<header>open</header><span>[3]</span><b>1,2,3</b>");
  a.setF("closed");
  flush();
  await settle();
  expect(a.div.innerHTML).toBe("<header>closed</header><span>[-1]</span><i>loading closed</i>");
  a.land("list:closed", [9]);
  await settle();
  expect(a.div.innerHTML).toBe("<header>closed</header><span>[-1]</span><b>9</b>");
  a.dispose();
});

// The converse matters: a separate ordinary observer can still hold the
// filter. Neither the branch nor Loading's on may publish that proposal early.
test("a separate ordinary flight holds the filter, branch and Loading on together", async () => {
  const a = app("view", true);
  try {
    flush();
    a.land("list:open", [1, 2, 3]);
    await settle();
    const initial = "<header>open</header><em>0</em><span>[3]</span><b>1,2,3</b>";
    expect(a.div.innerHTML).toBe(initial);
    a.setF("closed");
    flush();
    await settle();
    expect(a.div.innerHTML).toBe(initial);
    a.unblock();
    await settle();
    expect(a.div.innerHTML).toBe(
      "<header>closed</header><em>1</em><span>[-1]</span><i>loading closed</i>"
    );
    a.land("list:closed", [9]);
    await settle();
    expect(a.div.innerHTML).toBe("<header>closed</header><em>1</em><span>[-1]</span><b>9</b>");
  } finally {
    a.unblock();
    a.dispose();
  }
});
