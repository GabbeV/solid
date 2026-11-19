/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { createMemo, createSignal, flush, isPending } from "solid-js";
import { render } from "@solidjs/web";

test("a pending navigation keeps the old id and disables the button through correction", async () => {
  const container = document.createElement("div");
  const requests: ((value: string) => void)[] = [];
  function App() {
    const [id, setId] = createSignal(0);
    const page = createMemo(() => {
      const key = id();
      if (isPending(id)) return "Loading";
      if (!key) return "Home";
      return new Promise<string>(resolve => requests.push(resolve));
    });
    return (
      <>
        <button disabled={isPending(id)} onClick={() => setId(1)}>
          Next
        </button>
        <p>
          {id()} | {page()}
        </p>
      </>
    );
  }
  document.body.append(container);
  const dispose = render(() => <App />, container);
  try {
    flush();
    const button = container.querySelector("button")!;
    const text = container.querySelector("p")!;
    expect(text.textContent).toBe("0 | Home");
    button.click();
    flush();
    expect([text.textContent, button.disabled]).toEqual(["0 | Loading", true]);
    expect(requests).toHaveLength(2);
    requests[0]("Obsolete");
    await Promise.resolve();
    flush();
    expect([text.textContent, button.disabled]).toEqual(["0 | Loading", true]);
    requests[1]("Page 1");
    await Promise.resolve();
    flush();
    expect([text.textContent, button.disabled]).toEqual(["1 | Page 1", false]);
  } finally {
    dispose();
    container.remove();
  }
});
