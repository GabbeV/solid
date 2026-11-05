import { expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  untrack
} from "../src/index.js";

it("a new binding with no published value holds the subtree that attaches it", async () => {
  const [value, setValue] = createSignal(0);
  const [open, setOpen] = createSignal(false);
  const gate = Promise.withResolvers<void>();
  const frames: unknown[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(value, () => {});
    const branch = createMemo(
      () => {
        if (!open()) return "closed";
        const element = { text: "" };
        const label = createMemo(
          () => {
            createRoot(
              () =>
                untrack(() => {
                  const text = createMemo(() => `label ${value()}`);
                  createRenderEffect(text, text => {
                    element.text = text;
                  });
                }),
              { transparent: true }
            );
            return element;
          },
          { sync: true }
        );
        const sibling = createLoadingBoundary(
          () => {
            const text = createMemo(() => `content ${value()}`);
            createRenderEffect(text, () => {});
            return "content";
          },
          () => "fallback"
        );
        createRenderEffect(sibling, () => {});
        return label();
      },
      { sync: true }
    );
    createRenderEffect(
      () => [open(), branch()],
      frame => {
        frames.push(frame);
      },
      { schedule: true }
    );
    return dispose;
  });
  flush();
  const done = action(function* () {
    setValue(1);
    yield gate.promise;
  })();
  flush();
  setOpen(true);
  flush();
  try {
    expect(frames).toEqual([[false, "closed"]]);
  } finally {
    gate.resolve();
    await done;
    flush();
    dispose();
  }
  expect(frames.at(-1)).toEqual([true, { text: "label 1" }]);
});
