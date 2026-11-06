/** @vitest-environment jsdom */
import { afterEach, expect, it } from "vitest";
import {
  createErrorBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";

const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  document.body.replaceChildren();
  flush();
});

for (const optimistic of [false, true]) {
  it(`initializes detached children before publishing an async replacement (optimistic=${optimistic})`, async () => {
    let finish!: () => void;
    const ready = new Promise<void>(resolve => {
      finish = resolve;
    });
    const host = document.createElement("main");
    document.body.append(host);
    const initialized: { value: number; connected: boolean }[] = [];
    const cleaned: number[] = [];
    let set!: (value: number) => unknown;
    let proposed!: HTMLElement;
    createRoot(dispose => {
      disposals.push(dispose);
      const [value, write] = optimistic ? createLayer(() => 0) : createSignal(0);
      set = write;
      const tree = createMemo(() => {
        const current = value();
        const element = document.createElement("span");
        onCleanup(() => {
          cleaned.push(current);
        });
        // Renderer plumbing initializes a detached node synchronously.
        createRenderEffect(
          () => current,
          next => {
            element.textContent = String(next);
            initialized.push({ value: next, connected: element.isConnected });
          }
        );
        if (current === 0) return element;
        proposed = element;
        return ready.then(() => element);
      });
      // Attachment to an existing visible parent participates in publication.
      createRenderEffect(
        tree,
        element => {
          host.replaceChildren(element);
        },
        { schedule: true }
      );
    });
    flush();
    const oldChild = host.firstChild;
    expect(host.textContent).toBe("0");
    set(1);
    flush();
    expect(initialized).toEqual([
      { value: 0, connected: false },
      { value: 1, connected: false }
    ]);
    expect(proposed.textContent).toBe("1");
    expect(proposed.isConnected).toBe(false);
    expect(host.firstChild).toBe(oldChild);
    expect(host.textContent).toBe("0");
    expect(cleaned).toEqual([]);
    finish();
    await new Promise(resolve => setTimeout(resolve, 0));
    expect(host.firstChild).toBe(proposed);
    expect(host.textContent).toBe("1");
    expect(cleaned).toEqual([0]);
  });
}

for (const optimistic of [false, true])
  for (const obsolete of [false, true]) {
    it(`async errors preserve DOM ownership through recovery (optimistic=${optimistic}, obsolete=${obsolete})`, async () => {
      let reject!: (error: unknown) => void;
      const failed = new Promise<HTMLElement>((_, no) => {
        reject = no;
      });
      const host = document.createElement("main");
      const input = document.createElement("output");
      document.body.append(input, host);
      const frames: { value: number; cleaned: number }[] = [];
      let set!: (value: number) => unknown;
      let retry: (() => void) | undefined;
      let dispose!: () => void;
      createRoot(d => {
        dispose = d;
        disposals.push(d);
        const [value, write] = optimistic ? createLayer(() => 0) : createSignal(0);
        set = write;
        const tree = createMemo(() => {
          const current = value();
          const frame = { value: current, cleaned: 0 };
          frames.push(frame);
          onCleanup(() => {
            frame.cleaned++;
          });
          const element = document.createElement("span");
          createRenderEffect(
            () => current,
            next => {
              element.textContent = String(next);
            }
          );
          return current === 1 ? failed : element;
        });
        const boundary = createErrorBoundary(tree, (error, reset) => {
          retry = reset;
          const element = document.createElement("strong");
          element.textContent = (error() as Error).message;
          return element;
        });
        createRenderEffect(value, next => {
          input.textContent = String(next);
        });
        createRenderEffect(
          boundary,
          element => {
            host.replaceChildren(element);
          },
          { schedule: true }
        );
      });
      flush();
      const visible = () => [input.textContent, host.textContent];
      expect(visible()).toEqual(["0", "0"]);
      set(1);
      flush();
      expect(visible()).toEqual(["0", "0"]);
      expect(frames.find(frame => frame.value === 0)!.cleaned).toBe(0);
      if (obsolete) {
        set(2);
        flush();
        expect(visible()).toEqual(["2", "2"]);
      }
      reject(new Error("failed"));
      await new Promise(resolve => setTimeout(resolve, 0));
      expect(visible()).toEqual(obsolete ? ["2", "2"] : ["1", "failed"]);
      if (!obsolete) {
        set(2);
        flush();
        retry!();
        flush();
        expect(visible()).toEqual(["2", "2"]);
      }
      dispose();
      expect(frames.every(frame => frame.cleaned === 1)).toBe(true);
    });
  }
