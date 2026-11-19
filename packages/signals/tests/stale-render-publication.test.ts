/** Known publication bug shared with pinned next. Keep these assertions as
 * ordinary failures until the replacement reveal holds its control coherently.
 * Direct async reads pass; an intervening memo exposes F2's missing hold.
 */
import { expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const schedule of [false, true])
  for (const depth of [0, 1, 3])
    it(`a superseded reveal discovers its replacement flight before publishing its control (schedule=${schedule}, depth=${depth})`, async () => {
      const answers: ReturnType<typeof Promise.withResolvers<number>>[] = [];
      const controls: boolean[] = [];
      const panels: (readonly number[] | null)[] = [];
      let setVisible!: (value: boolean) => void;
      let setId!: (value: number) => void;
      const dispose = createRoot(dispose => {
        const [visible, writeVisible] = createSignal(true);
        const [id, writeId] = createSignal(0);
        setVisible = writeVisible;
        setId = writeId;
        let data = createMemo(() => {
          id();
          const answer = Promise.withResolvers<number>();
          answers.push(answer);
          return answer.promise;
        });
        for (let i = 0; i < depth; i++) {
          const input = data;
          data = createMemo(() => input());
        }
        createRenderEffect(
          () => visible() ? [id(), data()] as const : null,
          value => { panels.push(value); },
          undefined,
          { schedule }
        );
        createRenderEffect(visible, value => { controls.push(value); }, undefined, { schedule });
        return dispose;
      });
      try {
        flush();
        answers[0].resolve(0);
        await turn();
        expect(controls).toEqual([true]);
        expect(panels).toEqual([[0, 0]]);

        setVisible(false);
        setId(1);
        flush();
        expect(controls).toEqual([true, false]);
        expect(panels).toEqual([[0, 0], null]);

        setVisible(true);
        flush();
        expect(controls).toEqual([true, false]);
        expect(panels).toEqual([[0, 0], null]);

        setId(0);
        flush();
        expect(answers).toHaveLength(3);
        // The old reveal is superseded, but its replacement still suspends.
        expect(controls).toEqual([true, false]);
        expect(panels).toEqual([[0, 0], null]);
        answers[1].resolve(1);
        await turn();
        expect(controls).toEqual([true, false]);
        expect(panels).toEqual([[0, 0], null]);

        answers[2].resolve(0);
        await turn();
        expect(controls).toEqual([true, false, true]);
        expect(panels).toEqual([[0, 0], null, [0, 0]]);
      } finally {
        dispose();
        for (const answer of answers) answer.resolve(0);
        await turn();
      }
    });
