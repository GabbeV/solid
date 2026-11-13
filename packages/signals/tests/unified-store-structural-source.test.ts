import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  deep,
  flush,
  NotReadyError
} from "../src/index.js";
import { $TARGET } from "../src/store/types.js";
const turn = async () => {
  await new Promise(r => setTimeout(r, 0));
  flush();
};
for (const kind of ["keys", "deep"] as const)
  it(`${kind} discards an initial property proposal and waits for the writing action`, async () => {
    const answer = Promise.withResolvers<{ truth: number; added?: number }>(),
      finish = Promise.withResolvers<void>();
    const shown: string[] = [];
    const [state, set, read, dispose] = createRoot(dispose => {
      const [state, set] = createOptimisticStore(() => answer.promise, { truth: 0 } as {
        truth: number;
        added?: number;
      });
      const read = () =>
        kind === "keys" ? Object.keys(state).join(",") : JSON.stringify(deep(state));
      createRenderEffect(read, s => void shown.push(s));
      return [state, set, read, dispose] as const;
    });
    flush();
    const running = action(function* () {
      set(d => {
        d.added = 9;
      });
      yield finish.promise;
    })();
    try {
      flush();
      expect(shown).toEqual([]);
      expect(read).toThrow(NotReadyError);
      answer.resolve({ truth: 1 });
      await turn();
      expect(shown).toEqual([]);
      expect(read).toThrow(NotReadyError);
      finish.resolve();
      await running;
      await turn();
      expect(shown).toEqual([kind === "keys" ? "truth" : '{"truth":1}']);
      expect("added" in state).toBe(false);
    } finally {
      answer.resolve({ truth: 1 });
      finish.resolve();
      await running;
      dispose();
      await turn();
    }
  });

for (const kind of ["keys", "deep"] as const)
  it(`${kind} structural inputs release across creator disposal and pending correction`, async () => {
    for (let cycle = 0; cycle < 12; cycle++) {
      const finish = Promise.withResolvers<void>(),
        answer = Promise.withResolvers<{ truth: number; added?: number }>();
      let suspend!: () => void;
      const [state, set, dispose] = createRoot(dispose => {
        const [value, write] = createSignal<any>({ truth: 1 });
        suspend = () => write(answer.promise);
        const [state, set] = createOptimisticStore(() => value(), { truth: 1 } as {
          truth: number;
          added?: number;
        });
        createRenderEffect(
          () => (kind === "keys" ? Object.keys(state).join(",") : JSON.stringify(deep(state))),
          () => {}
        );
        return [state, set, dispose] as const;
      });
      flush();
      const root = (state as any)[$TARGET];
      const running = action(function* () {
        set(d => {
          d.added = 9;
        });
        yield finish.promise;
      })();
      flush();
      suspend();
      flush();
      dispose();
      flush();
      finish.resolve();
      await running;
      answer.resolve({ truth: 2 });
      await turn();
      await turn();
      expect(root.nc).toBe(0);
      expect(root.k?._subs ?? null).toBeNull();
      expect(root.dk?._subs ?? null).toBeNull();
      expect(root._fam.node._subs).toBeNull();
    }
  });
