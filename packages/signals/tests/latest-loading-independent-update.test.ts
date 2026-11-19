import { expect, it } from "vitest";
import {
  action, createLoadingBoundary, createMemo, createRenderEffect,
  createRoot, createSignal, flush, latest
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const wrappers of [0, 1, 3])
  for (const staleFirst of [false, true])
    it(`latest re-arms independent content without adopting its input hold (wrappers=${wrappers}, staleFirst=${staleFirst})`, async () => {
      const first = Promise.withResolvers<string>();
      const second = Promise.withResolvers<string>();
      const end = Promise.withResolvers<void>();
      const [frame, setFrame] = createSignal(0);
      const [request, setRequest] = createSignal(0);
      const shown = { frame: 0, content: "" };
      const content: string[] = [];
      const dispose = createRoot(dispose => {
        let input = frame;
        for (let i = 0; i < wrappers; i++) {
          const parent = input;
          input = createMemo(() => latest(parent));
        }
        const data = createMemo(() => {
          const id = request();
          return id === 0 ? "data 0" : id === 1 ? first.promise : second.promise;
        });
        const loading = createLoadingBoundary(data, () => "loading", {
          on: () => latest(input)
        });
        createRenderEffect(frame, value => { shown.frame = value; });
        createRenderEffect(loading, value => {
          shown.content = value;
          content.push(value);
        });
        return dispose;
      });
      flush();
      setRequest(1);
      flush();
      expect({ ...shown }).toEqual({ frame: 0, content: "data 0" });
      const running = action(function* () {
        setFrame(1);
        yield end.promise;
      })();
      try {
        flush();
        expect({ ...shown }).toEqual({ frame: 0, content: "loading" });
        setRequest(2);
        flush();
        expect({ ...shown }).toEqual({ frame: 0, content: "loading" });
        if (staleFirst) {
          first.resolve("obsolete data 1");
          await turn();
          expect({ ...shown }).toEqual({ frame: 0, content: "loading" });
        }
        second.resolve("data 2");
        await turn();
        expect({ ...shown }).toEqual({ frame: 0, content: "data 2" });
        first.resolve("obsolete data 1");
        await turn();
        expect({ ...shown }).toEqual({ frame: 0, content: "data 2" });
        end.resolve();
        await running;
        await turn();
        expect({ ...shown }).toEqual({ frame: 1, content: "data 2" });
        expect(content).toEqual(["data 0", "loading", "data 2"]);
      } finally {
        first.resolve("obsolete data 1");
        second.resolve("data 2");
        end.resolve();
        await running;
        dispose();
        flush();
      }
    });
