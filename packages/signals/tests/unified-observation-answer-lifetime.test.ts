import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

const settle = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const held of [false, true])
  it(`an observation's async answer does not extend its input lifetime (action=${held})`, async () => {
    const inputAnswers = [Promise.withResolvers<number>(), Promise.withResolvers<number>()];
    const end = Promise.withResolvers<void>();
    const requests: { value: string; answer: ReturnType<typeof Promise.withResolvers<string>> }[] =
      [];
    const screens: string[] = [];
    let shownInput: number | undefined;
    const app = createRoot(dispose => {
      const [id, setId] = createSignal(0);
      const data = createMemo(() => inputAnswers[id()].promise);
      const badge = createMemo(() => {
        const value = `${isPending(data)}:${latest(data)}`;
        const answer = Promise.withResolvers<string>();
        requests.push({ value, answer });
        return answer.promise;
      });
      createRenderEffect(data, value => void (shownInput = value));
      createRenderEffect(badge, value => void screens.push(value));
      return { dispose, setId };
    });
    const answer = async (value: string) => {
      const matching = requests.filter(request => request.value === value);
      expect(matching.length, `request ${value}`).toBeGreaterThan(0);
      for (const request of matching) request.answer.resolve(value);
      await settle();
    };
    let running: Promise<unknown> | undefined;
    try {
      inputAnswers[0].resolve(0);
      await settle();
      await answer("false:0");
      expect(screens).toEqual(["false:0"]);
      if (held)
        running = action(function* () {
          app.setId(1);
          yield end.promise;
        })();
      else app.setId(1);
      flush();
      await answer("true:0");
      expect(shownInput).toBe(0);
      expect(screens).toEqual(["false:0", "true:0"]);

      inputAnswers[1].resolve(1);
      await settle();
      await answer("true:1");
      expect(screens).toEqual(held ? ["false:0", "true:0", "true:1"] : ["false:0", "true:0"]);
      expect(shownInput).toBe(0);
      end.resolve();
      await running;
      await settle();
      await answer("false:1");
      expect(shownInput).toBe(1);
      expect(screens).toEqual(
        held ? ["false:0", "true:0", "true:1", "false:1"] : ["false:0", "true:0", "false:1"]
      );
    } finally {
      end.resolve();
      for (const pending of inputAnswers) pending.resolve(0);
      for (const request of requests) request.answer.resolve(request.value);
      app.dispose();
      await running;
      flush();
    }
  });
