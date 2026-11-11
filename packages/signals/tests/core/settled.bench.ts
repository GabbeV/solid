// Each update body performs 20 separate settled flushes, unlike the existing
// reactivity bench's many writes coalesced into one flush. Read bodies do 10k
// accessor calls. Vitest reports time per BODY, not time per read or flush.
import { bench, expect } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "../../src/index.js";

const READS = 10_000;
const FLUSHES = 20;
const options = { time: 1000, warmupTime: 500, iterations: 10, throws: true };

for (const memo of [false, true]) {
  {
    let read!: () => number, dispose!: () => void;
    let sink = 0,
      batches = 0,
      cleanups = 0;
    const setup = () => {
      dispose = createRoot(dispose => {
        onCleanup(() => cleanups++);
        const [source] = createSignal(1);
        read = memo ? createMemo(() => source() + 1) : source;
        return dispose;
      });
      flush();
      expect(read()).toBe(memo ? 2 : 1);
      expect(cleanups).toBe(0);
    };
    const run = () => {
      for (let i = 0; i < READS; i++) sink += read();
      batches++;
    };
    const teardown = () => {
      try {
        expect(read()).toBe(memo ? 2 : 1);
        expect(sink).toBe(batches * READS * (memo ? 2 : 1));
        expect(cleanups).toBe(0);
      } finally {
        dispose();
        flush();
      }
      expect(cleanups).toBe(1);
    };
    bench(`settled:${memo ? "memo" : "signal"}Read / 10k reads`, run, {
      ...options,
      setup: (_task, mode) => {
        if (mode === "warmup") setup();
      },
      teardown: (_task, mode) => {
        if (mode === "run") teardown();
      }
    });
  }
}

for (const shape of ["writeFlush", "chain20", "diamond", "fanout250"] as const) {
  {
    let setSource!: (value: number) => unknown, dispose!: () => void;
    let value = 0,
      shown = -1,
      cleanups = 0;
    const expected = (n: number) =>
      shape === "chain20"
        ? n + 20
        : shape === "diamond"
          ? n * 3 + 1
          : shape === "fanout250"
            ? n * 250 + 31_125
            : n;
    const update = () => setSource(++value);
    const setup = () => {
      dispose = createRoot(dispose => {
        onCleanup(() => cleanups++);
        const [source, write] = createSignal(0);
        setSource = write;
        let output = source;
        if (shape === "chain20") {
          for (let i = 0; i < 20; i++) {
            const previous = output;
            output = createMemo(() => previous() + 1);
          }
        } else if (shape === "diamond") {
          const left = createMemo(() => source() + 1);
          const right = createMemo(() => source() * 2);
          output = createMemo(() => left() + right());
        } else if (shape === "fanout250") {
          const leaves = Array.from({ length: 250 }, (_, i) => createMemo(() => source() + i));
          output = createMemo(() => leaves.reduce((sum, read) => sum + read(), 0));
        }
        createRenderEffect(output, next => {
          shown = next;
        });
        return dispose;
      });
      flush();
      expect(shown).toBe(expected(0));
      flush(update);
      expect(shown).toBe(expected(value));
      expect(cleanups).toBe(0);
    };
    const run = () => {
      for (let i = 0; i < FLUSHES; i++) flush(update);
    };
    const teardown = () => {
      try {
        expect(shown).toBe(expected(value));
        expect(cleanups).toBe(0);
      } finally {
        dispose();
        flush();
      }
      expect(cleanups).toBe(1);
    };
    bench(`settled:${shape} / 20 settled flushes`, run, {
      ...options,
      setup: (_task, mode) => {
        if (mode === "warmup") setup();
      },
      teardown: (_task, mode) => {
        if (mode === "run") teardown();
      }
    });
  }
}
