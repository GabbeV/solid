/** @jsxImportSource @solidjs/web */
import { expect, test } from "vitest";
import { createMemo, createSignal, isPending, untrack } from "solid-js";
import { render } from "@solidjs/web";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const wrapped of [false, true])
  for (const tracked of wrapped ? [false, true] : [true])
    test(`pending snapshot wrapped=${wrapped}, tracked=${tracked}`, async () => {
      const answer = Promise.withResolvers<number>();
      const container = document.createElement("div");
      let rerun!: () => void;
      function App() {
        const [id, setId] = createSignal(0);
        const [revision, setRevision] = createSignal(0);
        rerun = () => setRevision(v => v + 1);
        const data = createMemo(() => (id() === 0 ? 0 : answer.promise));
        const pending = wrapped ? createMemo(() => isPending(id)) : () => isPending(id);
        const sample = createMemo(() => {
          revision();
          const value = id();
          return `${value}:${tracked ? pending() : untrack(pending)}`;
        });
        return (
          <>
            <button onClick={() => setId(1)}>Run</button>
            <p>
              {id()} / {data()} / {String(isPending(id))} / {sample()}
            </p>
          </>
        );
      }
      const dispose = render(() => <App />, container);
      const frames: (string | null)[] = [];
      const frame = () => frames.push(container.querySelector("p")!.textContent);
      try {
        await turn();
        frame();
        container.querySelector("button")!.click();
        await turn();
        frame();
        rerun();
        await turn();
        frame();
        answer.resolve(1);
        await turn();
        frame();
        expect(frames).toEqual([
          "0 / 0 / false / 0:false",
          `0 / 0 / true / ${tracked ? "0:true" : "0:false"}`,
          "0 / 0 / true / 0:true",
          `1 / 1 / false / ${tracked ? "1:false" : "1:true"}`
        ]);
      } finally {
        dispose();
      }
    });
