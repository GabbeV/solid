/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 *
 * #4166: a `<Loading>` that `<Show when={latest(n) > 0}>` mounts during a
 * held action can initialize its binding from the complete committed lower
 * frame. Unlike next's extra mount hold, it displays 0 beside 0, then 1 beside
 * 1 when the action lands. A missing first value still requires fallback.
 */
import { afterEach, expect, test } from "vitest";
import { Loading, Show, action, createMemo, createSignal, flush, latest } from "solid-js";
import { render } from "../src/index.js";

const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

async function settle() {
  for (let i = 0; i < 3; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
}

test("a latest-mounted Loading initializes from the committed lower frame (#4166)", async () => {
  const root = document.createElement("div");
  const [n, setN] = createSignal(0);
  let release!: () => void;
  const save = action(function* () {
    setN(1);
    yield new Promise<void>(r => (release = r));
  });

  const dispose = render(
    () => (
      <>
        <i>{n()}</i>
        <Show when={latest(n) > 0}>
          <Loading fallback="pending">
            <p>{n()}</p>
          </Loading>
        </Show>
      </>
    ),
    root
  );
  disposals.push(dispose);
  flush();
  expect(root.innerHTML).toBe("<i>0</i>");

  const done = save();
  await settle();
  expect(root.innerHTML).toBe("<i>0</i><p>0</p>");

  release();
  await done;
  await settle();
  expect(root.innerHTML).toBe("<i>1</i><p>1</p>");
});

test("a mounted branch keeps the committed frame through another held proposal", async () => {
  const root = document.createElement("div");
  const [n, setN] = createSignal(0);
  const end = Promise.withResolvers<void>();
  disposals.push(
    render(
      () => (
        <>
          <i>{n()}</i>
          <Show when={latest(n) > 0}>
            <Loading fallback="pending">
              <p>{n()}</p>
            </Loading>
          </Show>
        </>
      ),
      root
    )
  );
  flush();
  const done = action(function* () {
    setN(1);
    yield end.promise;
  })();
  try {
    await settle();
    expect(root.innerHTML).toBe("<i>0</i><p>0</p>");
    setN(2);
    await settle();
    expect(root.innerHTML).toBe("<i>0</i><p>0</p>");
    end.resolve();
    await done;
    await settle();
    expect(root.innerHTML).toBe("<i>2</i><p>2</p>");
  } finally {
    end.resolve();
    await done;
  }
});

test("a latest-mounted branch still waits for a missing first value", async () => {
  const root = document.createElement("div");
  const [n, setN] = createSignal(0);
  const end = Promise.withResolvers<void>();
  const answer = Promise.withResolvers<string>();
  disposals.push(
    render(() => {
      const data = createMemo(() => answer.promise);
      return (
        <>
          <i>{n()}</i>
          <Show when={latest(n) > 0}>
            <Loading fallback="pending">
              <p>
                {n()}:{data()}
              </p>
            </Loading>
          </Show>
        </>
      );
    }, root)
  );
  flush();
  const done = action(function* () {
    setN(1);
    yield end.promise;
  })();
  try {
    await settle();
    expect(root.innerHTML).toBe("<i>0</i>pending");
    answer.resolve("ready");
    await settle();
    expect([...root.children].map(child => child.textContent)).toEqual(["0", "0:ready"]);
    end.resolve();
    await done;
    await settle();
    expect([...root.children].map(child => child.textContent)).toEqual(["1", "1:ready"]);
  } finally {
    answer.resolve("ready");
    end.resolve();
    await done;
  }
});
