/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { action, createMemo, createOptimistic, createSignal, createStore, Loading } from "solid-js";
import { render } from "@solidjs/web";

function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(r => (resolve = r));
  return { promise, resolve };
}

const tick = () => new Promise<void>(resolve => setTimeout(resolve, 0));

// #4927: an optimistic rederivation using the previous page's answer must
// not settle Loading's readers. Equal output has no property notification
// to make those readers encounter the pending producer again (#4862).
test.each(["store", "memo"])("equal %s output preserves Loading for the new page", async kind => {
  const answer = gate<string>();
  const correction = gate<void>();
  const finish = gate<void>();
  let running: Promise<void> | undefined;
  const container = document.body.appendChild(document.createElement("div"));

  function App() {
    const [page, setPage] = createSignal("A");
    const [text] = createSignal(() => (page() === "A" ? "A" : answer.promise));
    const [uppercase, guessUppercase] = createOptimistic(false);
    const derive = () => ({ text: uppercase() ? text().toUpperCase() : text() });
    const view =
      kind === "memo"
        ? createMemo(derive)
        : (() => {
            const [store] = createStore(derive);
            return () => store;
          })();
    const update = action(function* () {
      guessUppercase(true);
      yield correction.promise;
      guessUppercase(false);
      yield finish.promise;
    });

    return (
      <div>
        <button
          onClick={() => {
            running = update();
          }}
        >
          Start
        </button>
        <button onClick={() => setPage("B")}>Next</button>
        <p>Page: {page()}</p>
        <Loading on={page()} fallback={<p>Loading</p>}>
          <p>Content: {view().text}</p>
        </Loading>
      </div>
    );
  }

  const dispose = render(() => <App />, container);
  const screen = () => container.textContent;
  try {
    await tick();
    expect(screen()).toBe("StartNextPage: AContent: A");
    container.querySelectorAll("button")[0].click();
    await tick();
    container.querySelectorAll("button")[1].click();
    await tick();
    expect(screen()).toBe("StartNextPage: BLoading");

    correction.resolve();
    await tick();
    expect(screen()).toBe("StartNextPage: BLoading");

    answer.resolve("B");
    finish.resolve();
    await running;
    await tick();
    expect(screen()).toBe("StartNextPage: BContent: B");
  } finally {
    dispose();
    container.remove();
    correction.resolve();
    answer.resolve("B");
    finish.resolve();
    await running;
  }
});
