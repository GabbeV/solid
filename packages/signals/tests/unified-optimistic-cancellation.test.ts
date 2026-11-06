import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest,
  onCleanup
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const wrapped of [false, true])
  for (const intermediary of [false, true])
    it(`latest preserves an unchanged flight through callback=${wrapped}, intermediary=${intermediary}`, async () => {
      const jobs: { key: number; answer: ReturnType<typeof Promise.withResolvers<number>> }[] = [];
      const shown: number[] = [];
      const [id, setId] = createSignal(0);
      const dispose = createRoot(dispose => {
        const observed = () => wrapped ? latest(() => id()) : latest(id);
        const input = intermediary ? createMemo(observed) : observed;
        const result = createMemo(() => {
          const key = input();
          if (!key) return 0;
          const job = { key, answer: Promise.withResolvers<number>() };
          jobs.push(job);
          return job.answer.promise;
        });
        createRenderEffect(result, value => { shown.push(value); });
        return dispose;
      });
      try {
        flush(); setId(1); flush();
        expect(jobs.map(job => job.key)).toEqual([1]);
        setId(2); flush();
        expect(jobs.map(job => job.key)).toEqual([1, 2]);
        jobs[0].answer.resolve(10); await turn();
        expect(shown).toEqual([0]);
        jobs[1].answer.resolve(20); await turn();
        expect(shown).toEqual([0, 20]);
      } finally {
        dispose();
        for (const job of jobs) job.answer.resolve(job.key * 10);
        await turn(); flush();
      }
    });

for (const mode of ["flag", "result", "latest"] as const) {
  it(`${mode}: async cancellation follows the position of the optimistic boundary`, async () => {
    const end = Promise.withResolvers<void>();
    const jobs: {
      key: number;
      gate: ReturnType<typeof Promise.withResolvers<number>>;
      cancelled: boolean;
      done: boolean;
    }[] = [];
    let dispose!: () => void,
      start!: () => unknown,
      running: unknown,
      shown = 0;
    const load = (key: number) => {
      if (key === 0) return 0;
      const job = { key, gate: Promise.withResolvers<number>(), cancelled: false, done: false };
      jobs.push(job);
      onCleanup(() => {
        if (!job.done) job.cancelled = true;
      });
      return job.gate.promise.then(value => {
        job.done = true;
        return value;
      });
    };
    try {
      createRoot(cleanup => {
        dispose = cleanup;
        const [id, setId] = createSignal(0);
        let view: () => number;
        if (mode === "flag") {
          const [busy, guess] = createOptimistic(() => false);
          view = createMemo(() => {
            const key = id();
            return busy() ? -1 : load(key);
          });
          start = action(function* () {
            setId(1);
            guess(true);
            yield end.promise;
          });
        } else if (mode === "result") {
          const [output, guess] = createOptimistic(() => load(id()));
          view = output;
          start = action(function* () {
            setId(1);
            guess(-1);
            yield end.promise;
          });
        } else {
          view = createMemo(() => load(latest(id)));
          start = () => setId(1);
        }
        createRenderEffect(id, () => {}, { schedule: true });
        createRenderEffect(
          view,
          value => {
            shown = value;
          },
          { schedule: true }
        );
      });
      flush();
      running = start();
      flush();
      await turn();
      if (mode === "latest") {
        expect(jobs).toHaveLength(1);
        expect(jobs[0].cancelled).toBe(false);
      } else {
        expect(shown).toBe(-1);
        expect(jobs).toHaveLength(1);
        expect(jobs[0].cancelled).toBe(mode === "flag");
      }
      end.resolve();
      await turn();
      expect(jobs.map(job => job.key)).toEqual(mode === "flag" ? [1, 1] : [1]);
      for (const job of jobs) job.gate.resolve(10);
      await turn();
      await running;
      expect(shown).toBe(10);
    } finally {
      end.resolve();
      for (let round = 0; round < 3; round++) {
        for (const job of jobs) job.gate.resolve(10);
        await turn();
      }
      dispose?.();
      flush();
    }
  });
}
