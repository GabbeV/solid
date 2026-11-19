/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { action, createMemo, createOptimistic, createSignal } from "solid-js";
import { render } from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

test.each([false, true])(
  "input publication stays independent of a suspended repeated guess (async input=%s)",
  async asyncInput => {
    const saved = Promise.withResolvers<void>();
    const incoming = Promise.withResolvers<number>();
    const speculative = Promise.withResolvers<number>();
    const corrected = Promise.withResolvers<number>();
    const container = document.createElement("div");
    let save!: () => Promise<unknown>, repeat!: () => void, answer!: () => void;
    function App() {
      const [source, setSource] = createSignal(0);
      const [tick, setTick] = createSignal(0);
      const [view, guess] = createOptimistic(() =>
        source() && asyncInput ? incoming.promise : source()
      );
      const detail = createMemo(() =>
        view() === 3 ? speculative.promise : view() === 2 ? corrected.promise : view()
      );
      save = action(function* () {
        guess(1);
        yield saved.promise;
      });
      repeat = () => guess(3);
      answer = () => {
        setSource(2);
        setTick(1);
      };
      return (
        <>
          <span id="source">{source()}</span>
          <span id="direct">
            {tick()}:{view()}
          </span>
          <span id="pair">
            {view()}/{detail()}
          </span>
        </>
      );
    }
    const dispose = render(() => <App />, container);
    const shown = () =>
      ["source", "direct", "pair"].map(id => container.querySelector(`#${id}`)?.textContent);
    let saving: Promise<unknown> | undefined;
    try {
      await turn();
      expect(shown()).toEqual(["0", "0:0", "0/0"]);
      saving = save();
      await turn();
      expect(shown()).toEqual(["0", "0:1", "1/1"]);
      repeat();
      await turn();
      answer();
      await turn();
      expect(shown()).toEqual(["2", "1:1", "1/1"]);
      incoming.resolve(2);
      await turn();
      expect(shown()).toEqual(["2", "1:1", "1/1"]);
      saved.resolve();
      await saving;
      await turn();
      expect(shown()).toEqual(["2", "1:1", "1/1"]);
      corrected.resolve(2);
      await turn();
      expect(shown()).toEqual(["2", "1:2", "2/2"]);
      speculative.resolve(3);
      await turn();
      expect(shown()).toEqual(["2", "1:2", "2/2"]);
    } finally {
      saved.resolve();
      incoming.resolve(2);
      speculative.resolve(3);
      corrected.resolve(2);
      await saving;
      dispose();
    }
  }
);
