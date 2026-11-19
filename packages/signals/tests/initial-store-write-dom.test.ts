// @vitest-environment jsdom
import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  flush
} from "../src/index.js";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

it("builds first-answer DOM eagerly and publishes a late binding with the writing action", async () => {
  const answer = Promise.withResolvers<{ a: number; b: number }>();
  const end = Promise.withResolvers<void>();
  const host = document.createElement("div");
  const lateHost = document.createElement("span");
  const prepared: HTMLElement[] = [];
  const [state, setState, dispose] = createRoot(dispose => {
    const [state, setState] = createOptimisticStore(() => answer.promise, { a: 0, b: 2 });
    createRenderEffect(
      () => {
        const value = state.a;
        const element = document.createElement("span");
        element.textContent = String(value);
        prepared.push(element);
        return element;
      },
      element => {
        host.replaceChildren(element);
      }
    );
    return [state, setState, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  let unmount: (() => void) | undefined;
  try {
    flush();
    running = action(function* () {
      setState(draft => {
        draft.a++;
      });
      yield end.promise;
    })();
    await turn();
    answer.resolve({ a: 7, b: 8 });
    await turn();
    expect(prepared.some(element => element.textContent === "7")).toBe(true);
    expect(prepared.every(element => element.parentNode === null)).toBe(true);
    expect(host.textContent).toBe("");
    unmount = createRoot(dispose => {
      createRenderEffect(
        () => state.b,
        value => {
          lateHost.textContent = String(value);
        }
      );
      return dispose;
    });
    flush();
    expect(lateHost.textContent).toBe("");
    end.resolve();
    await running;
    await turn();
    expect(host.textContent).toBe("7");
    expect(lateHost.textContent).toBe("8");
  } finally {
    answer.resolve({ a: 7, b: 8 });
    end.resolve();
    await Promise.allSettled(running ? [running] : []);
    unmount?.();
    dispose();
    flush();
  }
});
