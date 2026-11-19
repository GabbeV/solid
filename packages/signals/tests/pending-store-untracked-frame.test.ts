import { expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  flush,
  isPending,
  untrack
} from "../src/index.js";

// A pending observation selects an update above the held input. Store backings
// with no property node must select the same committed frame as scalar nodes.
for (const source of ["signal", "signal untracked", "store", "container", "leaf", "no node"])
  for (const pendingFirst of [false, true])
    it(`pending keeps an unrelated count in its committed frame (${source}, pending first=${pendingFirst})`, async () => {
      const answer = Promise.withResolvers<void>();
      const shown: [number, string][] = [];
      const app = createRoot(dispose => {
        const [step, setStep] = createSignal(0);
        const [trigger, setTrigger] = createSignal(0);
        const [count, setCount] = createSignal(0);
        const [state, setState] = createStore({ count: 0 });
        if (source === "container")
          createRenderEffect(
            () => Object.keys(state),
            () => {}
          );
        if (source === "leaf")
          createRenderEffect(
            () => state.count,
            () => {}
          );
        const data = createMemo(() => {
          const value = step();
          return value ? answer.promise.then(() => value) : value;
        });
        const pending = createMemo(() => isPending(data));
        const read = () =>
          source === "signal"
            ? count()
            : source === "signal untracked"
              ? untrack(count)
              : source === "store"
                ? state.count
                : untrack(() => state.count);
        const view = createMemo(() => {
          trigger();
          if (pendingFirst) {
            const busy = pending();
            return `${busy}/${read()}`;
          }
          const value = read();
          return `${pending()}/${value}`;
        });
        createRenderEffect(
          () => [data(), view()] as [number, string],
          value => {
            shown.push(value);
          }
        );
        return { dispose, setStep, setTrigger, setCount, setState, read };
      });
      try {
        flush();
        expect(shown).toEqual([[0, "false/0"]]);
        app.setStep(1);
        app.setCount(1);
        app.setState(draft => {
          draft.count = 1;
        });
        app.setTrigger(1);
        flush();
        expect(app.read()).toBe(0);
        expect(shown).toEqual([
          [0, "false/0"],
          [0, "true/0"]
        ]);
        answer.resolve();
        await new Promise(resolve => setTimeout(resolve, 0));
        flush();
        expect(app.read()).toBe(1);
        expect(shown).toEqual([
          [0, "false/0"],
          [0, "true/0"],
          [1, "false/1"]
        ]);
      } finally {
        answer.resolve();
        app.dispose();
        flush();
      }
    });
