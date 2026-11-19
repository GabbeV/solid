/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { Show, createMemo, createSignal, flush, isPending, onCleanup } from "solid-js";
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

for (const derived of [false, true])
  for (const wrapped of [false, true])
    for (const pendingFirst of [false, true])
      for (const supersede of [false, true])
        test(`retained branch publication stays coherent across discovery and supersession (derived=${derived}, memo=${wrapped}, pending first=${pendingFirst}, supersede=${supersede})`, async () => {
          const [key, setKey] = createSignal("a");
          const [count, setCount] = createSignal(0);
          const first = Promise.withResolvers<number>();
          const second = Promise.withResolvers<number>();
          const host = document.createElement("div");
          const completed: (string | number | boolean)[][] = [];
          const frames: { cleaned: number }[] = [];
          const dispose = render(() => {
            const data = createMemo(() =>
              key() === "a" ? 0 : key() === "b" ? first.promise : second.promise
            );
            const pending = wrapped ? createMemo(() => isPending(data)) : () => isPending(data);
            return (
              <>
                <b>{count()}</b>
                <Show when={key()} keyed>
                  {captured => {
                    const frame = { cleaned: 0 };
                    frames.push(frame);
                    onCleanup(() => frame.cleaned++);
                    const text = () => {
                      let busy: boolean;
                      if (pendingFirst) busy = pending();
                      const current = key();
                      const value = count();
                      if (!pendingFirst) busy = pending();
                      const detail = data();
                      const fields = [captured, current, value, busy!, detail];
                      completed.push(fields);
                      return fields.join(":");
                    };
                    const value = derived ? createMemo(text) : text;
                    return <span>{value()}</span>;
                  }}
                </Show>
              </>
            );
          }, host);
          const check = () => {
            const fields = host.querySelector("span")!.textContent!.split(":");
            expect(fields[0]).toBe(fields[1]);
            expect(fields[2]).toBe(host.querySelector("b")!.textContent);
            expect(completed.filter(([captured, current]) => captured !== current)).toEqual([]);
          };
          try {
            flush();
            expect(host.textContent).toBe("0a:a:0:false:0");
            setKey("b");
            setCount(1);
            flush();
            check();
            if (supersede) setKey("c");
            setCount(2);
            flush();
            check();
            const answer = supersede ? second : first;
            answer.resolve(supersede ? 7 : 5);
            await answer.promise;
            flush();
            check();
            expect(host.textContent).toBe(supersede ? "2c:c:2:false:7" : "2b:b:2:false:5");
            if (supersede) {
              first.resolve(5);
              await first.promise;
              flush();
              check();
              expect(host.textContent).toBe("2c:c:2:false:7");
            }
          } finally {
            dispose();
            first.resolve(5);
            second.resolve(7);
            await Promise.all([first.promise, second.promise]);
            flush();
            expect(frames.every(frame => frame.cleaned === 1)).toBe(true);
          }
        });
