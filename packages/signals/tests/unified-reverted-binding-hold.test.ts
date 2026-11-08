import { expect, test } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  flush,
  latest
} from "../src/index.js";

for (const observation of [false, true])
  for (const form of ["direct", "memo", "memo chain", "property", "keys", "json"] as const)
    test(`a reverted binding rediscovers its pending input before publication (${form}, latest=${observation})`, async () => {
      const requests: { value: number; resolve: (value: number) => void }[] = [];
      const [source, setSource] = createSignal(1);
      const [visible, setVisible] = createSignal(false);
      const [noise, setNoise] = createSignal(0);
      const screen = { source: 0, result: "" };
      let dispose!: () => void;
      createRoot(d => {
        dispose = d;
        const question = createMemo(() => (observation ? latest(source) + source() : source() * 2));
        const answer = createMemo(() => {
          const value = question();
          return new Promise<number>(resolve => requests.push({ value, resolve }));
        });
        let read = answer;
        if (form === "memo") read = createMemo(() => answer());
        else if (form === "memo chain") {
          const first = createMemo(() => answer());
          const second = createMemo(() => first());
          read = createMemo(() => second());
        } else if (form !== "direct") {
          const [store] = createStore<{ value?: number }>(draft => {
            draft.value = answer();
          }, {});
          read = () => {
            if (form === "keys") expect(Object.keys(store)).toEqual(["value"]);
            return form === "json" ? JSON.parse(JSON.stringify(store)).value : store.value!;
          };
        }
        createRenderEffect(source, value => {
          screen.source = value;
        });
        createRenderEffect(
          () => {
            noise();
            return visible() ? String(read()) : "off";
          },
          value => {
            screen.result = value;
          }
        );
      });
      const settle = async (request: (typeof requests)[number]) => {
        request.resolve(request.value);
        await new Promise<void>(resolve => setTimeout(resolve, 0));
        flush();
      };
      try {
        flush();
        await settle(requests[0]);
        expect(screen).toEqual({ source: 1, result: "off" });
        setSource(2);
        flush();
        const oldAnswer = requests.at(-1)!;
        expect(oldAnswer.value).toBe(4);
        expect(screen).toEqual({ source: 2, result: "off" });
        setVisible(true);
        flush();
        expect(screen).toEqual({ source: 2, result: "off" });
        setSource(3);
        flush();
        const currentAnswer = requests.at(-1)!;
        expect(currentAnswer.value).toBe(6);
        expect(screen).toEqual({ source: 2, result: "off" });
        await settle(oldAnswer);
        expect(screen).toEqual({ source: 2, result: "off" });
        setNoise(1);
        flush();
        expect(screen).toEqual({ source: 2, result: "off" });
        await settle(currentAnswer);
        expect(screen).toEqual({ source: 3, result: "6" });
        expect(source()).toBe(3);
        expect(visible()).toBe(true);
      } finally {
        dispose();
        for (const request of requests) request.resolve(request.value);
        await new Promise<void>(resolve => setTimeout(resolve, 0));
        flush();
      }
    });
