import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest
} from "../src/index.js";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const background of ["none", "action", "async"] as const)
  for (const wrapped of [false, true])
    for (const latestFirst of [false, true])
      it(`inactive latest propagates its input once (${background}, wrapped=${wrapped}, latest first=${latestFirst})`, async () => {
        const end = Promise.withResolvers<void>();
        const answer = Promise.withResolvers<number>();
        const calculations: number[][] = [];
        const shown: number[][] = [];
        const app = createRoot(dispose => {
          const [id, setId] = createSignal(1);
          const [other, setOther] = createSignal(0);
          const unrelated = createMemo(() =>
            other() && background === "async" ? answer.promise : other()
          );
          createRenderEffect(unrelated, () => {});
          const ahead = wrapped ? createMemo(() => latest(id)) : () => latest(id);
          const pair = createMemo(() => {
            let ordinary: number, proposed: number;
            if (latestFirst) {
              proposed = ahead();
              ordinary = id();
            } else {
              ordinary = id();
              proposed = ahead();
            }
            const value = [ordinary, proposed];
            calculations.push(value);
            return value;
          });
          createRenderEffect(pair, value => {
            shown.push(value);
          });
          const run = action(function* () {
            setOther(1);
            yield end.promise;
          });
          return { dispose, setId, setOther, run };
        });
        try {
          flush();
          let running: Promise<unknown> | undefined;
          if (background === "action") running = app.run();
          else if (background === "async") app.setOther(1);
          flush();
          calculations.length = 0;
          shown.length = 0;
          app.setId(2);
          flush();
          expect(calculations).toEqual([[2, 2]]);
          expect(shown).toEqual([[2, 2]]);
          end.resolve();
          answer.resolve(1);
          if (running) await running;
          await turn();
          expect(calculations).toEqual([[2, 2]]);
          expect(shown).toEqual([[2, 2]]);
        } finally {
          end.resolve();
          answer.resolve(1);
          app.dispose();
          flush();
        }
      });
