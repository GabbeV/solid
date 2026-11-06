/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { action, createMemo, createOptimistic, createSignal, Loading } from "solid-js";
import { render } from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

test.each([
  { asyncDetail: false, inputFirst: false },
  { asyncDetail: false, inputFirst: true },
  { asyncDetail: true, inputFirst: false },
  { asyncDetail: true, inputFirst: true }
])(
  "a guess before the first answer stays coherent (async detail=$asyncDetail, input first=$inputFirst)",
  async ({ asyncDetail, inputFirst }) => {
    const input = Promise.withResolvers<number>();
    const saved = Promise.withResolvers<void>();
    const detailAnswer = Promise.withResolvers<number>();
    const container = document.createElement("div");
    let save!: () => Promise<unknown>, repeat!: () => void, rerun!: () => void;
    function App() {
      const [tick, setTick] = createSignal(0);
      const [view, guess] = createOptimistic(() => input.promise);
      const detail = createMemo(() =>
        view() === 2 && asyncDetail ? detailAnswer.promise : view()
      );
      save = action(function* () {
        guess(1);
        yield saved.promise;
      });
      repeat = () => guess(2);
      rerun = () => setTick(1);
      return (
        <Loading fallback="loading">
          <span id="direct">
            {tick()}:{view()}
          </span>
          <span id="pair">
            {view()}/{detail()}
          </span>
        </Loading>
      );
    }
    const dispose = render(() => <App />, container);
    const shown = () =>
      ["direct", "pair"].map(id => container.querySelector(`#${id}`)?.textContent);
    let saving: Promise<unknown> | undefined;
    try {
      await turn();
      expect(container.textContent).toBe("loading");
      saving = save();
      await turn();
      expect(shown()).toEqual(["0:1", "1/1"]);
      repeat();
      await turn();
      rerun();
      await turn();
      expect(shown()).toEqual(asyncDetail ? ["1:1", "1/1"] : ["1:2", "2/2"]);
      detailAnswer.resolve(2);
      await turn();
      expect(shown()).toEqual(["1:2", "2/2"]);
      if (inputFirst) input.resolve(0);
      else saved.resolve();
      await turn();
      // The override remains while either its action or own input is pending.
      expect(shown()).toEqual(["1:2", "2/2"]);
      input.resolve(0);
      saved.resolve();
      await saving;
      await turn();
      expect(shown()).toEqual(["1:0", "0/0"]);
    } finally {
      input.resolve(0);
      saved.resolve();
      detailAnswer.resolve(2);
      await saving;
      dispose();
    }
  }
);
