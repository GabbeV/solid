/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 *
 * S-46: latest can open a new branch whose ordinary bindings all read the
 * complete committed lower frame. This follows the accepted natural mount
 * rule; next instead holds the mount or shows Loading. The explicit latest
 * binding still sees the proposal. Neither form may expose an empty slot or
 * let ordinary readers disagree about id.
 */
import { afterEach, beforeEach, describe, expect, test, vi } from "vitest";
import { Loading, Show, createMemo, createSignal, flush, latest } from "solid-js";
import { render } from "../src/index.js";

beforeEach(() => vi.useFakeTimers());
afterEach(() => vi.useRealTimers());

const tick = async () => {
  await vi.advanceTimersByTimeAsync(0);
  flush();
};

type Content = "plain" | "latest" | "loading";

async function run(content: Content) {
  const div = document.createElement("div");
  const gates: (() => void)[] = [];
  const fetchDetail = (v: number) => new Promise<string>(r => gates.push(() => r(`d${v}`)));
  let setId!: (v: number) => void;
  const dispose = render(() => {
    const [id, _set] = createSignal(0);
    setId = _set;
    const detail = createMemo(() => fetchDetail(id()));
    const inner = () =>
      content === "latest" ? <p>selected: {latest(id)}</p> : <p>selected: {id()}</p>;
    return (
      <>
        <b>{id()}</b>
        <i>{detail()}</i>
        <Show when={latest(id) > 0} fallback={<u>none</u>}>
          {content === "loading" ? <Loading fallback={<u>loading</u>}>{inner()}</Loading> : inner()}
        </Show>
      </>
    );
  }, div);
  const screen = () => div.textContent;
  flush();
  gates.shift()!();
  await tick();
  const screens = [screen()];

  setId(1);
  flush();
  screens.push(screen());
  await tick();
  await tick();
  screens.push(screen());

  gates.shift()!();
  await tick();
  await tick();
  screens.push(screen());
  dispose();
  return screens;
}

describe("S-46 (web): the content a display-ahead Show opens reads the screen", () => {
  // primed | after the write's flush | a task later, still in flight | landed
  test("plain `id()` inside: mount the complete committed frame", async () => {
    expect(await run("plain")).toEqual([
      "0d0none",
      "0d0selected: 0",
      "0d0selected: 0",
      "1d1selected: 1"
    ]);
  });

  test("`latest(id)` inside: the held value now (D-27: the read that asks sees ahead, at its own site)", async () => {
    expect(await run("latest")).toEqual([
      "0d0none",
      "0d0selected: 1",
      "0d0selected: 1",
      "1d1selected: 1"
    ]);
  });

  test("a `Loading` inside: complete committed content needs no fallback", async () => {
    expect(await run("loading")).toEqual([
      "0d0none",
      "0d0selected: 0",
      "0d0selected: 0",
      "1d1selected: 1"
    ]);
  });
});
