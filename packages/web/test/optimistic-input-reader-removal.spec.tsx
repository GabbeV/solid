/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { createMemo, createOptimistic, createSignal, Show } from "solid-js";
import { render } from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

test("removing an optimistic reader retains the existing input hold until its answer", async () => {
  const answer = Promise.withResolvers<number>();
  const container = document.createElement("div");
  let run!: () => void, hide!: () => void;
  function App() {
    const [id, setId] = createSignal(0);
    const [visible, setVisible] = createSignal(true);
    const data = createMemo(() => (id() === 0 ? 0 : answer.promise));
    const [view, guess] = createOptimistic(data);
    run = () => {
      setId(1);
      guess(3);
    };
    hide = () => setVisible(false);
    return (
      <>
        <span id="source">{id()}</span>
        <Show when={visible()} fallback={<span id="removed">removed</span>}>
          <span id="value">{view()}</span>
        </Show>
      </>
    );
  }
  const dispose = render(() => <App />, container);
  const source = () => container.querySelector("#source")?.textContent;
  try {
    await turn();
    expect(source()).toBe("0");
    expect(container.querySelector("#value")?.textContent).toBe("0");
    run();
    await turn();
    expect(source()).toBe("0");
    expect(container.querySelector("#value")?.textContent).toBe("3");
    hide();
    await turn();
    expect(container.querySelector("#value")).toBeNull();
    expect(container.querySelector("#removed")?.textContent).toBe("removed");
    expect(source()).toBe("0");
    answer.resolve(1);
    await turn();
    expect(source()).toBe("1");
    expect(container.querySelector("#value")).toBeNull();
  } finally {
    dispose();
  }
});
