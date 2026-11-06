import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRoot,
  createSignal,
  flush,
  resolve
} from "../src/index.js";

it.each([false, true])(
  "resolve keeps its first settled answer (initial error=%s)",
  async initialError => {
    const failure = new Error("first answer");
    const app = createRoot(dispose => {
      const [value, setValue] = createSignal(0);
      const memo = createMemo(() => {
        if (initialError && value() === 0) throw failure;
        return value();
      });
      return { dispose, setValue, memo };
    });
    try {
      const answer = resolve(app.memo).then(
        value => ({ value }),
        error => ({ error })
      );
      app.setValue(1);
      flush();
      expect(await answer).toEqual(initialError ? { error: failure } : { value: 0 });
    } finally {
      app.dispose();
    }
  }
);

it.each([false, true])(
  "resolve waits for a foreign proposal and drops its superseded answer (error=%s)",
  async error => {
    const lifetime = Promise.withResolvers<void>();
    const failure = new Error("superseded proposal");
    const app = createRoot(dispose => {
      const [value, setValue] = createSignal(0);
      const memo = createMemo(() => {
        if (error && value() === 1) throw failure;
        return value();
      });
      return { dispose, setValue, memo };
    });
    const running = action(function* () {
      app.setValue(1);
      yield lifetime.promise;
    })();
    try {
      flush();
      let settled = false;
      const answer = resolve(app.memo).then(value => {
        settled = true;
        return value;
      });
      app.setValue(2);
      flush();
      await Promise.resolve();
      expect(settled).toBe(false);
      lifetime.resolve();
      await running;
      await expect(answer).resolves.toBe(2);
    } finally {
      lifetime.resolve();
      await running;
      app.dispose();
    }
  }
);

it.each([false, true])(
  "resolve does not deliver an interrupted context-discovery pass as an error (inside action=%s)",
  async insideAction => {
    const end = Promise.withResolvers<void>();
    const app = createRoot(dispose => {
      const [source, setSource] = createSignal(0);
      const [optimistic, guess] = createOptimistic(0);
      return { dispose, source, setSource, optimistic, guess };
    });
    const running = action(function* () {
      app.setSource(1);
      app.guess(10);
      yield end.promise;
    })();
    try {
      flush();
      let value: number | undefined;
      const read = () => resolve(() => app.source() + app.optimistic());
      const result = insideAction
        ? action(function* () {
            return yield read();
          })()
        : read();
      const answer = result.then(result => {
        value = result;
      });
      await new Promise(resolve => setTimeout(resolve, 0));
      expect(value).toBe(10);
      await answer;
    } finally {
      end.resolve();
      await running;
      app.dispose();
    }
  }
);
