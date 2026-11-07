/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { Show, action, createMemo, createOptimistic, createSignal, flush, latest } from "solid-js";
import { render } from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

for (const wrapped of [false, true])
  for (const inputFirst of [false, true])
    test(`an owned latest proposal publishes coherently in either completion order (memo=${wrapped}, input first=${inputFirst})`, async () => {
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
            const direct = id(),
              proposed = ahead();
            calculations.push([captured, direct, proposed]);
            return `${captured}:${direct}:${proposed}`;
          };
          return <span data-page>{text()}</span>;
        }
        return (
          <>
            <span data-id>{id()}</span>
            <span data-latest>{ahead()}</span>
            <span data-slow>{slow()}</span>
            <Show when={visible()}>
              <Page />
            </Show>
          </>
        );
      }, host);
      const screen = () =>
        ["id", "latest", "slow", "page"].map(
          name => host.querySelector(`[data-${name}]`)?.textContent ?? null
        );
      let running: Promise<unknown> | undefined;
      try {
        flush();
        expect(screen()).toEqual(["0", "0", "0", null]);
        running = begin();
        await turn();
        show();
        flush();
        expect(screen()).toEqual(["0", "0", "0", null]);
        expect(calculations.length).toBeGreaterThan(0);
        if (inputFirst) {
          end.resolve();
          await turn();
          // Expiring optimism must not keep itself alive. Its ordinary
          // correction still waits for the answer before coherent reveal.
          expect(screen()).toEqual(["0", "0", "0", null]);
          answer.resolve();
        } else {
          answer.resolve();
          await turn();
          // The upper output is independent of the still-open input action.
          expect(screen()).toEqual(["0", "1", "1", null]);
          end.resolve();
        }
        await running;
        await turn();
        expect(screen()).toEqual(["1", "1", "1", "1:1:1"]);
        expect(
          calculations.filter(
            ([captured, direct, proposed]) => captured !== direct || proposed < direct
          )
        ).toEqual([]);
      } finally {
        end.resolve();
        answer.resolve();
        await running;
        dispose();
        flush();
      }
    });

test("private structure waiting for a guess cannot keep that guess alive", async () => {
  const end = Promise.withResolvers<void>();
  const answer = Promise.withResolvers<void>();
  const host = document.createElement("div");
  let begin!: () => Promise<unknown>;
  const dispose = render(() => {
    const [visible, setVisible] = createSignal(false);
    const [view, guess] = createOptimistic(() => 0);
    const slow = createMemo(() => {
      const value = view();
      return value ? answer.promise.then(() => value) : 0;
    });
    begin = action(function* () {
      setVisible(true);
      guess(1);
      yield end.promise;
    });
    return (
      <>
        <span>{view()}</span>
        <span>{slow()}</span>
        <Show when={visible()}>
          <Show when={view()} fallback="zero">
            one
          </Show>
        </Show>
      </>
    );
  }, host);
  flush();
  const running = begin();
  await turn();
  try {
    expect(host.textContent).toBe("00");
    end.resolve();
    await running;
    await turn();
    expect(host.textContent).toBe("00zero");
    answer.resolve();
    await turn();
    expect(host.textContent).toBe("00zero");
  } finally {
    end.resolve();
    answer.resolve();
    await running;
    dispose();
    flush();
  }
});
