/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { action, createMemo, createSignal, latest, Show } from "solid-js";
import { render } from "@solidjs/web";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

test.each([false, true])("#4275 JSX mount (latest first: %s)", async latestFirst => {
  const answers = new Map<number, ReturnType<typeof Promise.withResolvers<number>>>();
  const saved = Promise.withResolvers<void>();
  const container = document.createElement("div");
  let start!: () => Promise<unknown>, mount!: () => void;
  function App() {
    const [source, setSource] = createSignal(0);
    const [mounted, setMounted] = createSignal(false);
    const data = createMemo(() => {
      const value = latest(source);
      const answer = Promise.withResolvers<number>();
      answers.set(value, answer);
      return answer.promise;
    });
    start = action(function* () {
      setSource(1);
      yield saved.promise;
    });
    mount = () => setMounted(true);
    const content = () =>
      latestFirst ? `[${latest(source)}, ${data()}]` : `[${data()}, ${latest(source)}]`;
    return (
      <>
        <p>{mounted() ? "on" : "off"}</p>
        <Show when={mounted()}>{content}</Show>
      </>
    );
  }
  const dispose = render(() => <App />, container);
  let running: Promise<unknown> | undefined;
  try {
    await turn();
    running = start();
    await turn();
    expect(container.textContent).toBe("off");
    mount();
    await turn();
    expect(container.textContent).toBe("off");
    expect(answers.has(1)).toBe(true);
    answers.get(1)!.resolve(1);
    await turn();
    expect(container.textContent).toBe("on[1, 1]");
  } finally {
    saved.resolve();
    await running;
    dispose();
  }
});
