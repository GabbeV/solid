/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test, vi } from "vitest";
import { createMemo, createSignal, flush } from "solid-js";
import { render } from "@solidjs/web";

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

test("a superseded panel reveal keeps its visible label held until the replacement answer", async () => {
  vi.useFakeTimers();
  const host = document.createElement("div");
  document.body.append(host);
  let clicks = 0;
  const dispose = render(() => {
    const [visible, setVisible] = createSignal(true);
    const [id, setId] = createSignal(0);
    const data = createMemo(async () => {
      const value = id();
      await delay(1500);
      return value;
    });
    const copy = createMemo(() => data());

    async function run() {
      clicks++;
      setVisible(false);
      setId(1);
      await delay(500);
      setVisible(true);
      await delay(500);
      setId(0);
    }

    return <>
      <button onClick={run}>Run</button>
      <p>Visible: {String(visible())}</p>
      <p>{visible() ? `${id()} / ${copy()}` : "hidden"}</p>
    </>;
  }, host);
  const screen = () => Array.from(host.querySelectorAll("p"), p => p.textContent);
  try {
    flush();
    await vi.advanceTimersByTimeAsync(1500);
    expect(screen()).toEqual(["Visible: true", "0 / 0"]);
    host.querySelector("button")!.click();
    expect(clicks).toBe(1);
    await vi.advanceTimersByTimeAsync(500);
    expect(screen()).toEqual(["Visible: false", "hidden"]);
    await vi.advanceTimersByTimeAsync(500);
    expect(screen()).toEqual(["Visible: false", "hidden"]);
    await vi.advanceTimersByTimeAsync(1500);
    expect(screen()).toEqual(["Visible: true", "0 / 0"]);
  } finally {
    dispose();
    host.remove();
    vi.clearAllTimers();
    vi.useRealTimers();
  }
});
