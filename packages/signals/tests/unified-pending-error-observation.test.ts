import { expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";

for (const ordinaryRead of [false, true])
  for (const initialError of [false, true])
    it(`pending catches only its own error read (ordinary=${ordinaryRead}, initial=${initialError})`, () => {
      const app = createRoot(dispose => {
        const [failed, setFailed] = createSignal(initialError);
        const value = createMemo(() => {
          if (failed()) throw new Error("failed");
          return 0;
        });
        const output = createErrorBoundary(
          () => {
            const pending = isPending(() => value());
            return ordinaryRead ? `${pending}/${value()}` : String(pending);
          },
          () => "error"
        );
        const frames: string[] = [];
        createRenderEffect(output, value => void frames.push(value));
        return { dispose, setFailed, frames };
      });
      try {
        flush();
        expect(app.frames.at(-1)).toBe(
          initialError && ordinaryRead ? "error" : ordinaryRead ? "false/0" : "false"
        );
        app.setFailed(!initialError);
        flush();
        expect(app.frames.at(-1)).toBe(
          !initialError && ordinaryRead ? "error" : ordinaryRead ? "false/0" : "false"
        );
        app.setFailed(initialError);
        flush();
        expect(app.frames.at(-1)).toBe(
          initialError && ordinaryRead ? "error" : ordinaryRead ? "false/0" : "false"
        );
        if (!ordinaryRead) expect(app.frames).toEqual(["false"]);
      } finally {
        app.dispose();
        flush();
      }
    });

for (const initialError of [false, true])
  it(`recovery to undefined is a changed answer (initial=${initialError})`, async () => {
    const end = Promise.withResolvers<void>();
    const app = createRoot(dispose => {
      const [failed, setFailed] = createSignal(initialError);
      const value = createMemo(() => {
        if (failed()) throw new Error("failed");
        return undefined;
      });
      const output = createErrorBoundary(
        () => String(value()),
        () => "error"
      );
      const values: string[] = [];
      const pending: boolean[] = [];
      createRenderEffect(output, v => void values.push(v));
      createRenderEffect(
        () => isPending(value),
        v => void pending.push(v)
      );
      return { dispose, setFailed, values, pending };
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      if (!initialError) {
        app.setFailed(true);
        flush();
      }
      expect(app.values.at(-1)).toBe("error");
      running = action(function* () {
        app.setFailed(false);
        yield end.promise;
      })();
      flush();
      expect(app.values.at(-1)).toBe("error");
      expect(app.pending.at(-1)).toBe(true);
      end.resolve();
      await running;
      await new Promise(resolve => setTimeout(resolve, 0));
      flush();
      expect(app.values.at(-1)).toBe("undefined");
      expect(app.pending.at(-1)).toBe(false);
    } finally {
      end.resolve();
      await running;
      app.dispose();
      flush();
    }
  });
