/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createSignal,
  flush,
  latest,
  onCleanup,
  Show
} from "solid-js";
import { render } from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

for (const read of ["ordinary", "latest", "memo latest"] as const)
  for (const cancel of [false, true])
    test(`a ready owned binding initializes before attachment (read=${read}, cancel=${cancel})`, async () => {
      const next = Promise.withResolvers<void>();
      const end = Promise.withResolvers<void>();
      const container = document.createElement("div");
      const created: { node: HTMLElement; initial: string | null }[] = [];
      const scheduled: number[] = [];
      let cleanups = 0;
      let start!: () => Promise<unknown>;
      const dispose = render(() => {
        const [count, setCount] = createSignal(0);
        start = action(function* () {
          setCount(1);
          yield next.promise;
          setCount(cancel ? 0 : 2);
          yield end.promise;
        });
        function Child() {
          const value =
            read === "ordinary"
              ? count
              : read === "latest"
                ? () => latest(count)
                : createMemo(() => latest(count));
          createRenderEffect(
            value,
            v => {
              scheduled.push(v * 10);
            },
            { schedule: true }
          );
          onCleanup(() => {
            cleanups++;
          });
          const node = (<span>{value() * 10}</span>) as HTMLElement;
          created.push({ node, initial: node.textContent });
          return node;
        }
        return (
          <Show when={count() > 0} fallback="off">
            <Child />
          </Show>
        );
      }, container);
      let running: Promise<unknown> | undefined;
      try {
        flush();
        expect(container.textContent).toBe("off");
        running = start();
        await turn();
        expect(created).toHaveLength(1);
        expect(created[0].initial).toBe("10");
        expect(created[0].node.textContent).toBe("10");
        expect(container.contains(created[0].node)).toBe(false);
        expect(container.textContent).toBe("off");
        expect(scheduled).toEqual([]);
        expect(cleanups).toBe(0);

        next.resolve();
        await turn();
        expect(created).toHaveLength(1);
        expect(created[0].node.textContent).toBe("10");
        expect(container.textContent).toBe("off");
        expect(scheduled).toEqual([]);
        // A later latest proposal retries the creator on committed count=0,
        // removing the private child. Ordinary reads keep their private frame.
        expect(cleanups).toBe(cancel || read !== "ordinary" ? 1 : 0);

        end.resolve();
        await running;
        await turn();
        expect(container.textContent).toBe(cancel ? "off" : "20");
        const rebuilt = !cancel && read !== "ordinary";
        expect(created).toHaveLength(rebuilt ? 2 : 1);
        expect(container.contains(created[0].node)).toBe(!cancel && !rebuilt);
        if (rebuilt) {
          expect(created[1].initial).toBe("20");
          expect(container.contains(created[1].node)).toBe(true);
        }
        expect(scheduled).toEqual(cancel ? [] : [20]);
        expect(cleanups).toBe(cancel || rebuilt ? 1 : 0);
      } finally {
        next.resolve();
        end.resolve();
        await running;
        dispose();
        flush();
        expect(cleanups).toBe(created.length);
      }
    });
