import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  refresh
} from "../src/index.js";
const turn = async () => {
  for (let i = 0; i < 3; i++) {
    await new Promise<void>(resolve => setTimeout(resolve, 0));
    flush();
  }
};
for (const sibling of [false, true])
  for (const order of ["question first", "rows first"] as const)
    it(`answered ordinary inputs release independently of a selected scalar output (sibling=${sibling}, ${order})`, async () => {
      const asks: Array<{ key: string; answer: ReturnType<typeof Promise.withResolvers<any>> }> =
        [];
      const ask = (key: string) => {
        const answer = Promise.withResolvers<any>();
        asks.push({ key, answer });
        return answer.promise;
      };
      const answer = async (key: string, value: any) => {
        const index = asks.findIndex(request => request.key === key);
        expect(index).toBeGreaterThanOrEqual(0);
        asks.splice(index, 1)[0].answer.resolve(value);
        await turn();
      };
      const end = Promise.withResolvers<void>();
      const frames: string[] = [],
        pairs: [string, string][] = [];
      let setQuestion!: (value: string) => void, close!: () => unknown;
      const dispose = createRoot(dispose => {
        const [question, set] = createSignal("open");
        setQuestion = set;
        const input = createMemo<number[]>(() => ask(`rows:${question()}`));
        const [rows, guess] = createOptimistic(() => input());
        // An ordinary consumer retains the unanswered input independently of
        // the selected rows. It stops holding as soon as that answer is ready.
        createRenderEffect(
          () => input().length,
          () => {}
        );
        if (sibling) {
          const other = createMemo(() => ask(`other:${question()}`));
          createRenderEffect(other, () => {});
        }
        const text = () => rows().join(",");
        const derived = createMemo(text);
        createRenderEffect(
          () => [text(), derived()] as [string, string],
          pair => void pairs.push(pair)
        );
        createRenderEffect(
          () => {
            let q: string, r: string;
            if (order === "question first") {
              q = question();
              r = text();
            } else {
              r = text();
              q = question();
            }
            return `${q}:${r}`;
          },
          frame => void frames.push(frame)
        );
        close = action(function* () {
          guess([3, 4]);
          yield end.promise;
          refresh(input);
        });
        return dispose;
      });
      try {
        await turn();
        if (sibling) await answer("other:open", {});
        await answer("rows:open", [1, 3, 4]);
        expect(frames.at(-1)).toBe("open:1,3,4");
        setQuestion("closed");
        await turn();
        expect(frames.at(-1)).toBe("open:1,3,4");
        close();
        await turn();
        expect(frames.at(-1)).toBe("open:3,4");
        expect(frames.filter(frame => frame.startsWith("closed:"))).toEqual([]);
        await answer("rows:closed", [1, 2]);
        expect(frames.at(-1)).toBe(sibling ? "open:3,4" : "closed:3,4");
        if (sibling) {
          expect(frames.filter(frame => frame.startsWith("closed:"))).toEqual([]);
          await answer("other:closed", {});
          expect(frames.at(-1)).toBe("closed:3,4");
        }
        end.resolve();
        await turn();
        expect(frames.at(-1)).toBe("closed:3,4");
        await answer("rows:closed", [2]);
        expect(frames.at(-1)).toBe("closed:2");
        for (const [direct, memo] of pairs) expect(memo).toBe(direct);
      } finally {
        dispose();
        end.resolve();
        for (const request of asks) request.answer.resolve([]);
        await turn();
      }
    });
