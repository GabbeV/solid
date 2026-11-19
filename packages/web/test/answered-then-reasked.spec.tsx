/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test, vi } from "vitest";
import { Loading, createMemo, createOptimistic, createSignal, flush, latest } from "solid-js";
import { render } from "@solidjs/web";

for (const depth of [0, 1, 3])
  test.each([0, 500])(
    `a first answer reaches latest through ${depth} inactive optimistic boundaries (delay %i)`,
    async wait => {
      vi.useFakeTimers();
      const first = Promise.withResolvers<number>();
      const second = Promise.withResolvers<number>();
      const host = document.createElement("div");
      document.body.append(host);
      let replace!: () => void;
      const dispose = render(() => {
        const [version, setVersion] = createSignal(0);
        replace = () => setVersion(1);
        let value = createMemo(() => (version() === 0 ? first.promise : second.promise));
        for (let i = 0; i < depth; i++) {
          const input = value;
          [value] = createOptimistic(() => input());
        }
        const doubled = createMemo(() => value() * 2);
        const preview = createMemo(() => latest(doubled));
        const consequence = createMemo(() => preview() + 1);
        return (
          <Loading fallback={<p>Loading</p>}>
            <p>
              {preview()} / {consequence()}
            </p>
          </Loading>
        );
      }, host);
      try {
        flush();
        await vi.advanceTimersByTimeAsync(0);
        expect(host.textContent).toBe("Loading");
        first.resolve(10);
        if (wait) {
          await vi.advanceTimersByTimeAsync(wait);
          expect(host.textContent).toBe("20 / 21");
        }
        replace();
        await vi.advanceTimersByTimeAsync(0);
        expect(host.textContent).toBe("20 / 21");
        second.resolve(30);
        await vi.advanceTimersByTimeAsync(0);
        expect(host.textContent).toBe("60 / 61");
      } finally {
        dispose();
        host.remove();
        vi.clearAllTimers();
        vi.useRealTimers();
      }
    }
  );
