/** @jsxImportSource @solidjs/web */
import { expect, test } from "vitest";
import { createMemo, createSignal, isPending, latest, untrack } from "solid-js";
import { render } from "@solidjs/web";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const kind of ["pending", "latest"] as const)
  for (const callback of [false, true])
    for (const tracked of [false, true])
      for (const asynchronous of [false, true])
        test(`${kind} selects one context: callback=${callback}, tracked=${tracked}, async=${asynchronous}`, async () => {
          const answer = Promise.withResolvers<number>();
          const container = document.createElement("div");
          let rerun!: () => void;
          function App() {
            const [id, setId] = createSignal(0);
            const [revision, setRevision] = createSignal(0);
            rerun = () => setRevision(n => n + 1);
            const data = createMemo(() => (id() === 0 ? 0 : answer.promise));
            const observe = () =>
              kind === "pending"
                ? isPending(callback ? () => id() : id)
                : latest(callback ? () => id() : id);
            const calculate = () => {
              revision();
              const before = id();
              const value = tracked ? observe() : untrack(observe);
              return `${before}/${value}/${id()}`;
            };
            const sample = createMemo(asynchronous ? async () => calculate() : calculate);
            return (
              <>
                <button onClick={() => setId(1)}>Run</button>
                <p>
                  {id()} / {data()}
                </p>
                <output>{sample()}</output>
              </>
            );
          }
          const dispose = render(() => <App />, container);
          try {
            await turn();
            expect(container.querySelector("output")!.textContent).toBe(
              `0/${kind === "pending" ? false : 0}/0`
            );
            container.querySelector("button")!.click();
            await turn();
            rerun();
            await turn();
            expect(container.querySelector("p")!.textContent).toBe("0 / 0");
            expect(container.querySelector("output")!.textContent).toBe(
              `0/${kind === "pending" ? true : 1}/0`
            );
            answer.resolve(1);
            await turn();
            expect(container.querySelector("p")!.textContent).toBe("1 / 1");
            expect(container.querySelector("output")!.textContent).toBe(
              `1/${kind === "pending" ? false : 1}/1`
            );
          } finally {
            answer.resolve(1);
            dispose();
          }
        });
