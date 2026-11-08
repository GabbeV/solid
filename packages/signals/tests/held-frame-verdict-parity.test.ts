/**
 * #4473: inline and memo-wrapped observations in a held frame must agree.
 * Next keeps the private creator in its incoming context. The shared model
 * retries that creator when a child selects optimism, so its branch can close
 * on committed input until the ordinary update publishes. The tests assert
 * the full callback timeline, matching forms, and exactly-once frame cleanup.
 * The two-hold comparison retains the original visible outcomes.
 */
import { describe, expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest,
  onCleanup
} from "../src/index.js";

const tick = async () => {
  for (let i = 0; i < 6; i++) await Promise.resolve();
  flush();
};

describe("a held frame's leaf over the hold's display-ahead value", () => {
  async function single(form: "inline" | "memo inside" | "memo outside") {
    const [y, setY] = createSignal(0);
    let b1!: () => void, b2!: () => void;
    const actB = action(function* () {
      setY(1);
      yield new Promise<void>(r => (b1 = r));
      setY(2);
      yield new Promise<void>(r => (b2 = r));
    });
    const leaf: unknown[] = [];
    const frames: { cleaned: number }[] = [];
    let shown: unknown;
    const dispose = createRoot(dispose => {
      const outside = createMemo(() => latest(y) * 10);
      const when = createMemo(() => y() > 0);
      const content = createMemo(() => {
        if (!when()) return "off";
        const frame = { cleaned: 0 };
        frames.push(frame);
        onCleanup(() => frame.cleaned++);
        const read =
          form === "inline"
            ? () => latest(y) * 10
            : form === "memo inside"
              ? createMemo(() => latest(y) * 10)
              : outside;
        createRenderEffect(read, v => void leaf.push(v));
        return "on";
      });
      createRenderEffect(content, v => {
        shown = v;
      });
      return dispose;
    });
    flush();
    const steps: unknown[] = [];
    actB();
    await tick();
    steps.push([shown, ...leaf]);
    b1();
    await tick();
    await tick();
    steps.push([shown, ...leaf]);
    b2();
    await tick();
    await tick();
    steps.push([shown, ...leaf]);
    expect(frames.filter(frame => frame.cleaned === 0)).toHaveLength(1);
    dispose();
    expect(frames.every(frame => frame.cleaned === 1)).toBe(true);
    return steps;
  }

  // The leaf selects optimism and retries its still-private creator. In that
  // context y is the committed 0, so the branch returns before creating a
  // leaf. The final ordinary frame creates its leaf when y=2 can publish.
  // Inline and wrapped reads must agree, and every discarded frame cleans up.
  const expected = [["off"], ["off"], ["on", 20]];
  for (const form of ["inline", "memo inside", "memo outside"] as const)
    it(`one hold, ${form}: the leaf's run waits for the landing`, async () => {
      expect(await single(form)).toEqual(expected);
    });

  async function merged(form: "inline" | "memo" | "split") {
    const [x, setX] = createSignal(0);
    const [y, setY] = createSignal(0);
    let a1!: () => void, a2!: () => void, b1!: () => void;
    const actA = action(function* () {
      setX(1);
      yield new Promise<void>(r => (a1 = r));
      setX(2);
      yield new Promise<void>(r => (a2 = r));
    });
    const actB = action(function* () {
      setY(1);
      yield new Promise<void>(r => (b1 = r));
    });
    let shownM: unknown, shown: unknown, leaf: unknown;
    createRoot(() => {
      const m = createMemo(() => latest(x) * 10);
      const k = createMemo(() => x() + y());
      createRenderEffect(m, v => {
        shownM = v;
      });
      createRenderEffect(k, () => {});
      const when = createMemo(() => y() > 0);
      const content = createMemo(() => {
        if (!when()) return "off";
        if (form === "inline")
          createRenderEffect(
            () => `${latest(y)}/${m()}`,
            v => {
              leaf = v;
            }
          );
        else if (form === "memo") {
          const mm = createMemo(() => `${latest(y)}/${m()}`);
          createRenderEffect(mm, v => {
            leaf = v;
          });
        } else {
          let ly: unknown, lm: unknown;
          createRenderEffect(
            () => latest(y),
            v => {
              ly = v;
              leaf = `${ly}/${lm}`;
            }
          );
          createRenderEffect(m, v => {
            lm = v;
            leaf = `${ly}/${lm}`;
          });
        }
        return "on";
      });
      createRenderEffect(content, v => {
        shown = v;
      });
    });
    flush();
    const steps: unknown[] = [];
    actA();
    await tick();
    actB();
    await tick();
    steps.push([shownM, shown, leaf]);
    a1();
    await tick();
    await tick();
    steps.push([shownM, shown, leaf]);
    a2();
    b1();
    await tick();
    await tick();
    steps.push([shownM, shown, leaf]);
    return steps;
  }

  const expectedMerged = [
    [10, "off", "1/10"],
    [20, "off", "1/10"],
    [20, "on", "1/20"]
  ];
  for (const form of ["inline", "memo", "split"] as const)
    it(`merged holds, ${form}: the same screens`, async () => {
      expect(await merged(form)).toEqual(expectedMerged);
    });
});
