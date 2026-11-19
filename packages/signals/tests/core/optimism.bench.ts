// Native shipped-module benchmarks, not tree-shaken application bundles. Static
// imports alone do not prove import-size isolation for Node's ESM module graph.
// Tinybench setup is awaited; its teardown is synchronous. Vitest suite hooks
// are not called by the installed native benchmark runner.
import { bench, expect } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "../../src/index.js";

const FLUSHES = 20;
const options = { time: 1000, warmupTime: 500, iterations: 10, throws: true };

// An optimistic node is alive, but no guess or action is active.
{
  let dispose!: () => void, setSource!: (value: number) => unknown;
  let value = 0,
    shown = -1,
    inactive = -1,
    cleanups = 0;
  const update = () => setSource(++value);
  const setup = () => {
    dispose = createRoot(dispose => {
      onCleanup(() => cleanups++);
      const [source, write] = createSignal(0);
      setSource = write;
      const [view] = createOptimistic(() => 0);
      createRenderEffect(source, next => {
        shown = next;
      });
      createRenderEffect(view, next => {
        inactive = next;
      });
      return dispose;
    });
    flush();
    expect([shown, inactive, cleanups]).toEqual([0, 0, 0]);
    flush(update);
    expect([shown, inactive, cleanups]).toEqual([value, 0, 0]);
  };
  const run = () => {
    for (let i = 0; i < FLUSHES; i++) flush(update);
  };
  const teardown = () => {
    try {
      expect([shown, inactive, cleanups]).toEqual([value, 0, 0]);
    } finally {
      dispose();
      flush();
    }
    expect(cleanups).toBe(1);
  };
  bench("optimism:importedInactive / 20 ordinary settled flushes", run, {
    ...options,
    setup: (_task, mode) => {
      if (mode === "warmup") setup();
    },
    teardown: (_task, mode) => {
      if (mode === "run") teardown();
    }
  });
}

// Await the previous released action before opening another fixture. The final
// timed teardown only disposes/releases synchronously; full completion/correction
// is verified using the SAME fixture factory in awaited setup, outside timing.
let previousCompletion: Promise<unknown> = Promise.resolve();
for (const shape of [
  "activeDirect",
  "activeCallback",
  "activeChain16",
  "activeFanout128"
] as const) {
  const createFixture = () => {
    let dispose!: () => void, setSource!: (value: number) => unknown;
    let guess!: (value: number) => unknown, release!: () => void;
    let value = 2,
      shown = -1,
      sourceShown = -1;
    let starts = 0,
      completions = 0,
      cleanups = 0;
    const expected = (n: number) =>
      shape === "activeChain16" ? n + 16 : shape === "activeFanout128" ? n * 128 + 8_128 : n;
    const update = () => guess(++value);
    const assertHeld = () => {
      expect(shown).toBe(expected(value));
      expect([sourceShown, starts, completions, cleanups]).toEqual([0, 1, 0, 0]);
    };
    const end = new Promise<void>(resolve => {
      release = resolve;
    });
    dispose = createRoot(dispose => {
      onCleanup(() => cleanups++);
      const [source, write] = createSignal(0);
      setSource = write;
      const [view, override] = createOptimistic(shape === "activeDirect" ? source : () => source());
      guess = override;
      let output = view;
      if (shape === "activeChain16") {
        for (let i = 0; i < 16; i++) {
          const previous = output;
          output = createMemo(() => previous() + 1);
        }
      } else if (shape === "activeFanout128") {
        const leaves = Array.from({ length: 128 }, (_, i) => createMemo(() => view() + i));
        output = createMemo(() => leaves.reduce((sum, read) => sum + read(), 0));
      }
      createRenderEffect(
        source,
        next => {
          sourceShown = next;
        },
        { schedule: true }
      );
      createRenderEffect(
        output,
        next => {
          shown = next;
        },
        { schedule: true }
      );
      return dispose;
    });
    flush();
    expect([shown, sourceShown, cleanups]).toEqual([expected(0), 0, 0]);
    const running = action(function* () {
      starts++;
      setSource(1);
      yield end;
      completions++;
    })();
    flush(() => guess(value));
    return {
      running,
      release,
      assertHeld,
      run() {
        for (let i = 0; i < FLUSHES; i++) flush(update);
      },
      assertCompleted() {
        flush();
        expect([shown, sourceShown, starts, completions, cleanups]).toEqual([
          expected(1),
          1,
          1,
          1,
          0
        ]);
      },
      dispose() {
        dispose();
        flush();
        expect(cleanups).toBe(1);
      }
    };
  };
  let fixture: ReturnType<typeof createFixture>;
  bench(`optimism:${shape} / 20 active guess flushes`, () => fixture.run(), {
    ...options,
    async setup(_task, mode) {
      if (mode === "run") {
        fixture.assertHeld();
        return;
      }
      await previousCompletion;
      // Full lifecycle preflight: awaited, with failures propagated to runner.
      const probe = createFixture();
      try {
        probe.assertHeld();
        await Promise.resolve();
        flush();
        probe.assertHeld();
        probe.run();
        probe.assertHeld();
        probe.release();
        await probe.running;
        probe.assertCompleted();
      } finally {
        probe.release();
        await probe.running;
        probe.dispose();
      }
      fixture = createFixture();
      fixture.assertHeld();
    },
    teardown(_task, mode) {
      if (mode !== "run") return;
      try {
        fixture.assertHeld();
      } finally {
        try {
          fixture.dispose();
        } finally {
          fixture.release();
          previousCompletion = fixture.running;
        }
      }
    }
  });
}
