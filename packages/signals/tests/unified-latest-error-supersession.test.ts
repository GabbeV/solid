import { expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  createLoadingBoundary,
  createErrorBoundary,
  isPending,
  latest,
  flush
} from "../src/index.js";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const initialized of [false, true])
  it(`an unheld error supersedes latest derivations (initialized=${initialized})`, async () => {
    const flights: { value: number; resolve: (value: number) => void }[] = [];
    const frames: string[] = [];
    const app = createRoot(dispose => {
      const [id, setId] = createSignal(0);
      const source = createMemo(() => {
        const value = 1 + id();
        if (value === 2) throw new Error("source:2");
        return value;
      });
      const ask = (value: number) =>
        new Promise<number>(resolve => flights.push({ value, resolve }));
      const first = createMemo(() => ask(1 + latest(source) + latest(id)));
      const second = createMemo(() => ask(1 + latest(first)));
      const boundary = createErrorBoundary(
        () =>
          createLoadingBoundary(
            () => {
              createRenderEffect(
                () => isPending(source),
                () => {}
              );
              createRenderEffect(
                () => isPending(second),
                () => {}
              );
              return second;
            },
            () => "loading"
          ),
        () => "error"
      );
      createRenderEffect(
        () => {
          const value = boundary();
          return String(typeof value === "function" ? value() : value);
        },
        value => {
          frames.push(value);
        }
      );
      return { dispose, setId };
    });
    let settled = 0;
    const finish = async (afterAnswer?: () => void) => {
      let count = 0;
      while (settled < flights.length) {
        if (++count > 30) throw new Error("Latest derivations did not settle");
        const flight = flights[settled++];
        flight.resolve(flight.value);
        await turn();
        afterAnswer?.();
      }
    };
    try {
      flush();
      if (initialized) {
        await finish();
        expect(frames.at(-1)).toBe("3");
      } else expect(frames.at(-1)).toBe("loading");
      app.setId(1);
      await turn();
      expect(frames.at(-1)).toBe("error");
      // Answers requested before the error must not recover the display.
      await finish(() => expect(frames.at(-1)).toBe("error"));
      expect(frames.at(-1)).toBe("error");
      app.setId(2);
      await turn();
      await finish();
      expect(frames.at(-1)).toBe("7");
    } finally {
      app.dispose();
      flush();
    }
  });
