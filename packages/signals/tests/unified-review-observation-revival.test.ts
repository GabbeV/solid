import { expect, it } from "vitest";
import {
  createEffect,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  untrack
} from "../src/index.js";

const settle = async () => {
  for (let i = 0; i < 8; i++) await Promise.resolve();
  flush();
};

type Frame = { value: number; pending: boolean };

for (const reviveOutsideConsumer of [false, true]) {
  it(`lands an untracked pending observation after revival=${reviveOutsideConsumer}`, async () => {
    const [value, setValue] = createSignal(0);
    const [rerun, setRerun] = createSignal(0);
    let release!: () => void;
    let query!: () => boolean;
    const renders: Frame[] = [];
    const effects: Frame[] = [];
    const dispose = createRoot(dispose => {
      // This ordinary update is held until its controlled request resolves.
      const request = createMemo(() => {
        const next = value();
        return new Promise<number>(resolve => (release = () => resolve(next)));
      });
      const condition = createMemo(value);
      query = () => isPending(condition);
      const frame = createMemo(() => {
        rerun();
        const next = condition();
        const pending = untrack(query);
        return { value: next, pending };
      });
      createRenderEffect(request, () => {});
      createRenderEffect(frame, frame => void renders.push(frame));
      createEffect(frame, frame => void effects.push(frame));
      return dispose;
    });
    try {
      flush();
      release();
      await settle();
      setValue(5);
      flush();
      setRerun(1);
      flush();
      const held = [
        { value: 0, pending: false },
        { value: 0, pending: true }
      ];
      expect(renders).toEqual(held);
      expect(effects).toEqual(held);
      // A standalone public read revives the observation previously sampled
      // under untrack. It must not make the finished update remain pending.
      if (reviveOutsideConsumer) {
        expect(query()).toBe(true);
        flush();
      }
      release();
      await settle();
      const finished = [...held, { value: 5, pending: false }];
      expect({ renders, effects }).toEqual({ renders: finished, effects: finished });
    } finally {
      dispose();
      flush();
    }
  });
}
