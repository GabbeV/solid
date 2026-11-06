import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const observations of [false, true]) {
  for (const combinedMemo of [false, true]) {
    it(`peer outputs coordinate through a memo (observations=${observations}, memo=${combinedMemo})`, async () => {
      const end = Promise.withResolvers<void>();
      const detail = Promise.withResolvers<number>();
      const [source, setSource] = createSignal(0);
      let write!: () => void;
      const shown = { source: 0, pending: false, ahead: 0, details: 0, combined: "false:0" };
      const history: string[] = [];
      const dispose = createRoot(dispose => {
        let pending: () => boolean;
        let ahead: () => number;
        if (observations) {
          pending = () => isPending(source);
          ahead = () => latest(source);
          write = () => setSource(1);
        } else {
          const [p, guessPending] = createOptimistic(false);
          const [a, guessAhead] = createOptimistic(0);
          pending = p;
          ahead = a;
          write = () => {
            guessPending(true);
            guessAhead(1);
          };
        }
        const details = createMemo(() => (ahead() ? detail.promise : 0));
        const pair = () => `${pending()}:${pending() ? ahead() : 0}`;
        const combined = combinedMemo ? createMemo(pair) : pair;
        createRenderEffect(source, value => {
          shown.source = value;
        });
        createRenderEffect(pending, value => {
          shown.pending = value;
        });
        createRenderEffect(ahead, value => {
          shown.ahead = value;
        });
        createRenderEffect(details, value => {
          shown.details = value;
        });
        createRenderEffect(combined, value => {
          shown.combined = value;
          history.push(value);
        });
        return dispose;
      });
      flush();
      const running = action(function* () {
        write();
        yield end.promise;
      })();
      try {
        flush();
        expect(shown).toEqual({
          source: 0,
          pending: !combinedMemo,
          ahead: 0,
          details: 0,
          combined: combinedMemo ? "false:0" : "true:0"
        });
        detail.resolve(1);
        await turn();
        flush();
        expect(shown).toEqual({
          source: 0,
          pending: true,
          ahead: 1,
          details: 1,
          combined: "true:1"
        });
        expect(history).toEqual(
          combinedMemo ? ["false:0", "true:1"] : ["false:0", "true:0", "true:1"]
        );
        end.resolve();
        await running;
        await turn();
        flush();
        expect(shown).toEqual({
          source: observations ? 1 : 0,
          pending: false,
          ahead: observations ? 1 : 0,
          details: observations ? 1 : 0,
          combined: "false:0"
        });
      } finally {
        end.resolve();
        detail.resolve(1);
        await running;
        dispose();
        flush();
      }
    });
  }
}
