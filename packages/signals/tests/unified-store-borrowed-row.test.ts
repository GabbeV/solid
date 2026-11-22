import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  flush
} from "../src/index.js";

it("a row borrowed by an optimistic setter follows the source store until release", async () => {
  let finish!: () => void;
  const pending = new Promise<void>(resolve => {
    finish = resolve;
  });
  const app = createRoot(dispose => {
    const [source, setSource] = createStore([{ id: 1, value: 0 }]);
    const [rows, setRows] = createOptimisticStore<{ id: number; value: number }[]>([]);
    const frames: number[] = [];
    createRenderEffect(
      () => rows[0]?.value ?? -1,
      value => {
        frames.push(value);
      }
    );
    const borrow = action(function* () {
      setRows(() => [source[0]]);
      yield pending;
    });
    return { borrow, frames, dispose, setSource };
  });
  try {
    const completion = app.borrow();
    flush();
    expect(app.frames.at(-1)).toBe(0);
    app.setSource(draft => {
      draft[0].value = 1;
    });
    flush();
    expect(app.frames.at(-1)).toBe(1);
    finish();
    await completion;
    flush();
    expect(app.frames.at(-1)).toBe(-1);
  } finally {
    finish();
    app.dispose();
  }
});

it("a derived store can accept its own same-key answer without writing to the lender", () => {
  const app = createRoot(dispose => {
    const [source] = createStore([{ id: 1, value: 0 }]);
    const [answer, setAnswer] = createSignal<{ id: number; value: number }>();
    const [derived, guess] = createOptimisticStore(
      (draft: { id: number; value: number }[]) => {
        const row = answer();
        if (row) draft[0] = row;
      },
      [],
      { key: "id" }
    );
    let frame: (number | undefined)[] = [];
    createRenderEffect(
      () => [source[0].value, derived[0]?.value],
      value => {
        frame = value;
      }
    );
    return {
      dispose,
      frame: () => frame,
      run() {
        guess(() => [source[0]]);
        setAnswer({ id: 1, value: 1 });
      }
    };
  });
  try {
    flush();
    expect(app.frame()).toEqual([0, undefined]);
    app.run();
    flush();
    expect(app.frame()).toEqual([0, 1]);
  } finally {
    app.dispose();
  }
});
