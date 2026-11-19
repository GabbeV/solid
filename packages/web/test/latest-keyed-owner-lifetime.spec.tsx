/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { createMemo, createSignal, flush, latest, Loading, onCleanup, Show } from "solid-js";
import { render } from "../src/index.js";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const callback of [false, true])
  test(`latest keyed children keep live owners through speculative replacement (callback=${callback})`, async () => {
    const div = document.createElement("div");
    const instances: { cleanups: number }[] = [];
    const answers: { value: number; resolve: (value: number) => void }[] = [];
    let setCount!: (value: number) => void;
    const dispose = render(() => {
      const [count, set] = createSignal(1);
      setCount = set;
      const data = createMemo(() => {
        const value = count();
        return new Promise<number>(resolve => answers.push({ value, resolve }));
      });
      const Child = () => {
        const id = instances.length;
        const instance = { cleanups: 0 };
        instances.push(instance);
        onCleanup(() => instance.cleanups++);
        return (
          <span data-instance={id}>
            <Loading fallback="loading">{data()}</Loading>
          </span>
        );
      };
      return (
        <>
          {count()}|
          {callback ? (
            <Show keyed when={latest(count)}>
              {(_key: number) => <Child />}
            </Show>
          ) : (
            <Show keyed when={latest(count)}>
              <Child />
            </Show>
          )}
          |<Loading fallback="loading">{data()}</Loading>
        </>
      );
    }, div);
    const checkOwners = () => {
      const live = Array.from(div.querySelectorAll("[data-instance]"), node =>
        Number(node.getAttribute("data-instance"))
      );
      expect(live).toHaveLength(1);
      instances.forEach((instance, id) => {
        expect(instance.cleanups, `instance ${id}, visible=${live.includes(id)}`).toBe(
          live.includes(id) ? 0 : 1
        );
      });
    };
    try {
      flush();
      answers[0].resolve(1);
      await turn();
      expect(div.textContent).toBe("1|1|1");
      checkOwners();
      for (const value of [2, 3, 4]) {
        setCount(value);
        flush();
        expect(div.textContent).toBe(`${value - 1}|${value - 1}|${value - 1}`);
        checkOwners();
        const visible = div.querySelector("[data-instance]");
        expect(answers.map(answer => answer.value)).toEqual(
          Array.from({ length: value }, (_, i) => i + 1)
        );
        answers.at(-1)!.resolve(value);
        await turn();
        expect(div.textContent).toBe(`${value}|${value}|${value}`);
        // The higher context already published this key. Settling its lower
        // input updates the content without replacing the displayed child.
        expect(div.querySelector("[data-instance]")).toBe(visible);
        checkOwners();
      }
    } finally {
      dispose();
      flush();
    }
    expect(instances.every(instance => instance.cleanups === 1)).toBe(true);
  });
