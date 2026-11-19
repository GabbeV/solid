/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import {
  Loading,
  Show,
  action,
  createEffect,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createSignal,
  flush
} from "solid-js";
import { render } from "../src/index.js";

const delay = () => new Promise<void>(resolve => setTimeout(resolve, 0));

// A user effect must see the rendered frame its value belongs to, including
// attachment of a child mounted while that value's async consequence was held.
for (const optimistic of [false, true])
  for (const schedule of [false, true])
    for (const memo of [false, true])
      test(`held mount publishes DOM before user effects (optimistic=${optimistic}, scheduled=${schedule}, memo=${memo})`, async () => {
        const answer = Promise.withResolvers<void>();
        const lifetime = Promise.withResolvers<void>();
        const root = document.createElement("div");
        const [value, setValue] = optimistic ? createOptimistic(0) : createSignal(0);
        const [visible, setVisible] = createSignal(false);
        const slow = createMemo(() => {
          const current = value();
          return current === 0 ? current : answer.promise.then(() => current);
        });
        const users: [number, string][] = [];
        const renders: number[] = [];
        const order: string[] = [];
        function Child() {
          const read = memo ? createMemo(value) : value;
          createRenderEffect(
            read,
            current => {
              renders.push(current);
              order.push(`render:${current}`);
            },
            { schedule }
          );
          createEffect(read, current => {
            users.push([current, root.textContent!]);
            order.push(`user:${current}`);
          });
          return <i>child:{read()}</i>;
        }
        const dispose = render(
          () => (
            <Loading fallback="loading">
              <p>data:{slow()}</p>
              <Show when={visible()}>
                <Child />
              </Show>
            </Loading>
          ),
          root
        );
        try {
          flush();
          expect(root.textContent).toBe("data:0");
          if (optimistic)
            action(function* () {
              setValue(1);
              yield lifetime.promise;
            })();
          else setValue(1);
          flush();
          setVisible(true);
          flush();
          expect(users.filter(([current]) => current === 1)).toEqual([]);
          expect(renders.filter(current => current === 1)).toEqual([]);
          answer.resolve();
          await delay();
          flush();
          expect(root.textContent).toBe("data:1child:1");
          expect(users.filter(([current]) => current === 1)).toEqual([[1, "data:1child:1"]]);
          expect(renders.filter(current => current === 1)).toEqual([1]);
          expect(order.indexOf("render:1")).toBeLessThan(order.indexOf("user:1"));
        } finally {
          answer.resolve();
          lifetime.resolve();
          await delay();
          dispose();
          flush();
        }
      });
