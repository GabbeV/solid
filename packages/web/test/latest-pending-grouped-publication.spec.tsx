/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { createMemo, createSignal, flush, isPending, latest, Loading, Show } from "solid-js";
import { render } from "../src/index.js";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const pending of [false, true])
  test(`a grouped latest reader agrees with a late mount (pending=${pending})`, async () => {
    const div = document.createElement("div");
    const stop = Promise.withResolvers<number>();
    const requests: { value: number; resolve: (value: number) => void }[] = [];
    const ask = (value: number) =>
      new Promise<number>(resolve => requests.push({ value, resolve }));
    let setId!: (value: number) => void;
    let mount!: () => void;
    let result!: () => number;
    const dispose = render(() => {
      const [id, set] = createSignal(1);
      setId = set;
      const [visible, setVisible] = createSignal(false);
      mount = () => setVisible(true);
      const preview = createMemo(() => ask(1 + latest(id) + id()));
      result = createMemo(() => ask(100 + preview()));
      const hold = createMemo(() => (id() === 1 ? 1 : stop.promise));
      return (
        <>
          <b>{id()}</b>
          <Loading fallback="loading">
            {pending ? (
              <span>{`${hold()} / ${isPending(result)} / ${result()}`}</span>
            ) : (
              <span>{`${hold()} / ${result()}`}</span>
            )}
          </Loading>
          <Show when={visible()}>
            <em>{result()}</em>
          </Show>
        </>
      );
    }, div);
    const check = () => {
      const span = div.querySelector("span");
      if (!span) return;
      const parts = span.textContent!.split(" / ");
      expect(Number(parts.at(-1))).toBe(result());
      if (pending) expect(parts[1]).toBe(String(isPending(result)));
      const late = div.querySelector("em");
      if (late) expect(Number(late.textContent)).toBe(result());
    };
    let answered = 0;
    const land = async () => {
      for (let i = 0; i < 8; i++) {
        const end = requests.length;
        while (answered < end) {
          const request = requests[answered++];
          request.resolve(request.value);
        }
        await turn();
        check();
      }
    };
    try {
      flush();
      await land();
      expect(result()).toBe(103);
      setId(2);
      flush();
      check();
      await land();
      mount();
      flush();
      expect(div.querySelector("em")).not.toBeNull();
      check();
      stop.resolve(1);
      await land();
      expect(result()).toBe(105);
      expect(div.querySelector("b")!.textContent).toBe("2");
    } finally {
      stop.resolve(1);
      dispose();
      flush();
    }
  });
