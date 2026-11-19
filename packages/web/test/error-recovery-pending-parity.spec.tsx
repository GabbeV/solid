/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { Errored, action, createMemo, createSignal, createStore, flush, isPending } from "solid-js";
import { render } from "../src/index.js";

test("pending during recovery from an initially displayed error", async () => {
  const end = Promise.withResolvers<void>();
  const root = document.createElement("div");
  document.body.append(root);
  let retry!: () => Promise<unknown>;
  function App() {
    const [ready, setReady] = createSignal(false);
    const value = createMemo(() => {
      if (!ready()) throw new Error("failed");
      return 0;
    });
    const [store] = createStore(
      draft => {
        draft.value = value();
      },
      { value: 0 }
    );
    retry = action(function* () {
      setReady(true);
      yield end.promise;
    });
    return (
      <>
        <div id="memo-value">
          <Errored fallback="failed">{value()}</Errored>
        </div>
        <div id="memo-pending">{String(isPending(value))}</div>
        <div id="store-value">
          <Errored fallback="failed">{store.value}</Errored>
        </div>
        <div id="store-pending">{String(isPending(() => store.value))}</div>
      </>
    );
  }
  const dispose = render(() => <App />, root);
  const frames: unknown[] = [];
  const take = () =>
    frames.push(
      Object.fromEntries(
        ["memo-value", "memo-pending", "store-value", "store-pending"].map(id => [
          id,
          root.querySelector(`#${id}`)?.textContent
        ])
      )
    );
  try {
    flush();
    take();
    const running = retry();
    flush();
    take();
    end.resolve();
    await running;
    await new Promise(resolve => setTimeout(resolve, 0));
    flush();
    take();
    expect(frames).toEqual([
      {
        "memo-value": "failed",
        "memo-pending": "false",
        "store-value": "failed",
        "store-pending": "false"
      },
      {
        "memo-value": "failed",
        "memo-pending": "true",
        "store-value": "failed",
        "store-pending": "true"
      },
      { "memo-value": "0", "memo-pending": "false", "store-value": "0", "store-pending": "false" }
    ]);
  } finally {
    end.resolve();
    dispose();
    root.remove();
    flush();
  }
});
