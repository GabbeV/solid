/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { Show, action, createMemo, createSignal, flush, latest } from "solid-js";
import { render } from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

for (const wrapped of [false, true])
  test(`a newly mounted page never computes latest behind its captured input (memo=${wrapped})`, async () => {
    const end = Promise.withResolvers<void>();
    const answer = Promise.withResolvers<void>();
    const calculations: number[][] = [];
    const host = document.createElement("div");
    let begin!: () => Promise<unknown>;
    let show!: () => unknown;
    const dispose = render(() => {
      const [id, setId] = createSignal(0);
      const [visible, setVisible] = createSignal(false);
      const ahead = wrapped ? createMemo(() => latest(id)) : () => latest(id);
      const slow = createMemo(() => {
        const value = ahead();
        return value ? answer.promise.then(() => value) : 0;
      });
      begin = action(function* () {
        setId(1);
        yield end.promise;
      });
      show = () => setVisible(true);
      function Page() {
        const captured = id();
        const text = () => {
          const ordinary = id(),
            proposed = ahead();
          calculations.push([captured, ordinary, proposed]);
          return `${captured}:${ordinary}:${proposed}`;
        };
        return <span>{text()}</span>;
      }
      return (
        <>
          <b>{slow()}</b>
          <Show when={visible()}>
            <Page />
          </Show>
        </>
      );
    }, host);
    let running: Promise<unknown> | undefined;
    try {
      flush();
      expect(host.textContent).toBe("0");
      running = begin();
      await turn();
      show();
      flush();
      expect(host.textContent).toBe("0");
      expect(calculations.length).toBeGreaterThan(0);
      expect(calculations.filter(([, ordinary, proposed]) => proposed < ordinary)).toEqual([]);
      answer.resolve();
      end.resolve();
      await running;
      await turn();
      expect(host.textContent).toBe("11:1:1");
    } finally {
      end.resolve();
      answer.resolve();
      await running;
      dispose();
      flush();
    }
  });
