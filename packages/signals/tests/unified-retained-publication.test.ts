import { expect, it } from "vitest";
import {
  action, createMemo, createOptimistic, createRenderEffect, createRoot,
  createSignal, flush, latest, onCleanup
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const depth of [0, 1, 2, 3])
  it(`a retained child publishes with its output while removal is held (depth=${depth})`, async () => {
    const end = Promise.withResolvers<void>(), answer = Promise.withResolvers<number>();
    const shown = { outside: 0, details: 0 as number | null, visible: true };
    const details: number[] = [];
    let run!: () => Promise<unknown>, cleanupCount = 0;
    const value = depth ? 2 ** (depth - 1) : 1;
    const dispose = createRoot(dispose => {
      const [show, setShow] = createSignal(true);
      const [source, setSource] = createSignal(0);
      const guesses: (() => void)[] = [];
      let output = () => latest(source);
      for (let index = 0; index < depth; index++) {
        const parent = index ? output : source;
        const [view, guess] = createOptimistic(() => parent() * 2);
        const proposal = 2 ** index;
        guesses.push(() => { guess(proposal); });
        output = view;
      }
      const detail = createMemo(() => output() ? answer.promise : 0);
      createRenderEffect(output, value => { shown.outside = value; }, { schedule: true });
      createRenderEffect(show, value => { shown.visible = value; }, { schedule: true });
      createRenderEffect(() => {
        if (show()) {
          createRenderEffect(detail, value => {
            shown.details = value;
            details.push(value);
          }, { schedule: true });
          onCleanup(() => { cleanupCount++; shown.details = null; });
        }
      }, () => {}, { schedule: true });
      run = action(function* () {
        if (depth) for (const guess of guesses) guess();
        else setSource(1);
        setShow(false);
        yield end.promise;
        setSource(0);
      });
      return dispose;
    });
    try {
      flush();
      const running = run(); flush();
      expect(shown).toEqual({ outside: 0, details: 0, visible: true });
      expect(cleanupCount).toBe(0);
      answer.resolve(value * 10); await turn();
      expect(shown).toEqual({ outside: value, details: value * 10, visible: true });
      expect(details).toEqual([0, value * 10]);
      expect(cleanupCount).toBe(0);
      end.resolve(); await running; await turn();
      expect(shown).toEqual({ outside: 0, details: null, visible: false });
      expect(cleanupCount).toBe(1);
    } finally { end.resolve(); answer.resolve(value * 10); dispose(); flush(); }
  });
