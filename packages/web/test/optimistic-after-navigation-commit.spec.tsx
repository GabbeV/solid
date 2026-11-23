/** @jsxImportSource @solidjs/web */
import { expect, it } from "vitest";
import { createOptimistic, createSignal, flush, Loading, Show } from "solid-js";
import { render } from "@solidjs/web";

it("a revealed panel holds its preview during correction while a newly opened panel waits for the answer", async () => {
  const load = Promise.withResolvers<string[]>();
  const host = document.body.appendChild(document.createElement("div"));
  const dispose = render(() => {
    const [issue, choose] = createSignal("A");
    const [open, setOpen] = createSignal(false);
    const [comments] = createSignal(() => (issue() === "A" ? ["from A"] : load.promise));
    const [shown, guess] = createOptimistic(() => comments());
    return (
      <>
        <button onClick={() => choose("B")}>Open B</button>
        <button onClick={() => guess(rows => [...rows, "ping"])}>Guess</button>
        <button onClick={() => setOpen(true)}>Open second panel</button>
        <h1>{issue()}</h1>
        <p>
          <Loading on={issue()} fallback="Loading">
            {shown().join(", ")}
          </Loading>
        </p>
        <Show when={open()}>
          <p>
            <Loading fallback="Loading">{shown().join(", ")}</Loading>
          </p>
        </Show>
      </>
    );
  }, host);
  const panels = () => Array.from(host.querySelectorAll("p"), p => p.textContent);
  const click = async (index: number) => {
    host.querySelectorAll("button")[index].click();
    await new Promise(r => setTimeout(r, 0));
    flush();
  };
  try {
    flush();
    expect(panels()).toEqual(["from A"]);
    await click(0);
    expect(host.querySelector("h1")?.textContent).toBe("B");
    expect(panels()).toEqual(["Loading"]);
    await click(1);
    expect(panels()).toEqual(["from A, ping"]);
    await click(2);
    expect(panels()).toEqual(["from A, ping", "Loading"]);
    load.resolve(["from B"]);
    await new Promise(resolve => setTimeout(resolve, 0));
    expect(panels()).toEqual(["from B", "from B"]);
  } finally {
    dispose();
    host.remove();
    load.resolve([]);
  }
});
