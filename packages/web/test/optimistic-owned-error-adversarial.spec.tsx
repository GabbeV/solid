/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import {
  Errored,
  action,
  createMemo,
  createOptimistic,
  createRoot,
  flush,
  onCleanup
} from "solid-js";
import { render } from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

for (const depth of [1, 3])
  for (const roots of [0, 2])
    test(`error fallback, suspended recovery and expiration retain coherent ownership (depth=${depth}, roots=${roots})`, async () => {
      const next = Promise.withResolvers<void>();
      const end = Promise.withResolvers<void>();
      const obsolete = Promise.withResolvers<string>();
      const frames: { version: number; cleaned: number }[] = [];
      const host = document.createElement("div");
      let begin!: () => Promise<unknown>;
      const dispose = render(() => {
        let input = () => 0;
        let guess!: (value: number) => unknown;
        for (let i = 0; i < depth; i++) {
          const parent = input;
          const [view, write] = createOptimistic(parent);
          if (!i) guess = write;
          input = view;
        }
        const view = input;
        const data = createMemo(() => {
          const version = view();
          const frame = { version, cleaned: 0 };
          frames.push(frame);
          const own = (remaining: number): void => {
            if (remaining) {
              createRoot(() => own(remaining - 1));
              return;
            }
            onCleanup(() => {
              frame.cleaned++;
            });
            createMemo(() => version * 3);
          };
          own(roots);
          if (version === 1) throw new Error("failed1");
          if (version === 2) return obsolete.promise;
          return `value${version}`;
        });
        begin = action(function* () {
          guess(1);
          yield next.promise;
          guess(2);
          yield end.promise;
        });
        return (
          <>
            <b>{view()}</b>
            <Errored fallback={error => (error() as Error).message}>
              <span>{data()}</span>
            </Errored>
          </>
        );
      }, host);
      let running: Promise<unknown> | undefined;
      try {
        flush();
        expect(host.textContent).toBe("0value0");
        running = begin();
        await turn();
        expect(host.textContent).toBe("1failed1");
        next.resolve();
        await turn();
        // D-39: an Errored fallback is an explicit observation boundary.
        // Hidden recovery does not hold the input; the old error remains
        // until an answer replaces it. This is also pinned next's behavior.
        expect(host.textContent).toBe("2failed1");
        end.resolve();
        await running;
        await turn();
        expect(host.textContent).toBe("0value0");
        obsolete.resolve("obsolete2");
        await turn();
        expect(host.textContent).toBe("0value0");
      } finally {
        next.resolve();
        end.resolve();
        obsolete.resolve("obsolete2");
        await running;
        dispose();
        flush();
        expect(frames.every(frame => frame.cleaned === 1)).toBe(true);
      }
    });
