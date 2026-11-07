/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { Show, createMemo, createSignal, flush, isPending } from "solid-js";
import { render } from "../src/index.js";

test("a displayed branch agrees with a sibling on an independently updated input", async () => {
  const [key, setKey] = createSignal("a");
  const [count, setCount] = createSignal(0);
  const answer = Promise.withResolvers<number>();
  const host = document.createElement("div");
  const dispose = render(() => {
    const data = createMemo(() => (key() === "a" ? 0 : answer.promise));
    return (
      <>
        <b>{count()}</b>
        <Show when={key()} keyed>
          {captured => (
            <span>{`${captured}:${key()}:${count()}:${isPending(data)}:${data()}`}</span>
          )}
        </Show>
      </>
    );
  }, host);
  const assertCoherent = () => {
    const fields = host.querySelector("span")!.textContent!.split(":");
    expect(fields[0]).toBe(fields[1]);
    expect(fields[2]).toBe(host.querySelector("b")!.textContent);
  };
  try {
    flush();
    expect(host.textContent).toBe("0a:a:0:false:0");
    setKey("b");
    setCount(1);
    flush();
    assertCoherent();
    setCount(2);
    flush();
    assertCoherent();
    answer.resolve(5);
    await answer.promise;
    flush();
    assertCoherent();
    expect(host.textContent).toBe("2b:b:2:false:5");
  } finally {
    dispose();
    answer.resolve(5);
    flush();
  }
});
