import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest
} from "../src/index.js";

const snapshot = (rows: string[]) => {
  const length = rows.length;
  return {
    length,
    values: Array.from({ length }, (_, index) => rows[index]),
    present: Array.from({ length }, (_, index) => index in rows),
    descriptors: Array.from(
      { length },
      (_, index) => Object.getOwnPropertyDescriptor(rows, index)?.value
    ),
    keys: Object.keys(rows)
  };
};

it("array length, values, presence, descriptors and keys publish one structural frame", async () => {
  const [source, setSource] = createSignal(["A", "B"]);
  const [tick, setTick] = createSignal(0);
  const gates = [Promise.withResolvers<void>(), Promise.withResolvers<void>()];
  const running: Promise<unknown>[] = [];
  const frames: Array<{
    reader: string;
    phase: string;
    rows: ReturnType<typeof snapshot>;
  }> = [];
  let phase = "initial";
  const [{ inner, outer, editInner, editOuter, mountReader }, dispose] = createRoot(dispose => {
    const [inner, editInner] = createOptimisticStore(source, ["A", "B"]);
    const [outer, editOuter] = createOptimisticStore(() => inner, ["A", "B"]);
    const mountReader = (name: string) => {
      for (const [index, value] of [source, () => inner, () => outer].entries()) {
        const read = () => snapshot(value());
        createRenderEffect(
          () => {
            tick();
            return read();
          },
          rows => {
            frames.push({ reader: `${name} ${index}`, phase, rows });
          }
        );
        createRenderEffect(
          () => {
            tick();
            return latest(read);
          },
          rows => {
            frames.push({ reader: `${name} ${index} latest`, phase, rows });
          }
        );
      }
    };
    mountReader("existing");
    return [{ inner, outer, editInner, editOuter, mountReader }, dispose] as const;
  });
  let disposeNewReader: (() => void) | undefined;
  try {
    flush();
    phase = "inner active";
    running.push(
      action(function* () {
        editInner(draft => {
          draft[1] = "I";
        });
        yield gates[0].promise;
      })()
    );
    flush();
    phase = "both active";
    running.push(
      action(function* () {
        editOuter(draft => {
          draft.push("M");
        });
        yield gates[1].promise;
      })()
    );
    flush();
    phase = "source shrink";
    setSource([]);
    flush();
    phase = "unrelated tick after shrink";
    setTick(value => value + 1);
    flush();
    phase = "new reader after shrink";
    disposeNewReader = createRoot(dispose => {
      mountReader("new");
      return dispose;
    });
    flush();
    for (const layer of [0, 1]) {
      phase = `release ${layer}`;
      gates[layer].resolve();
      await running[layer];
      await new Promise<void>(resolve => setTimeout(resolve, 0));
      flush();
    }
    phase = "final tick";
    setTick(value => value + 1);
    flush();

    for (const frame of frames) {
      const rows = frame.rows;
      const evidence = JSON.stringify(frame);
      expect(rows.present, evidence).toEqual(Array(rows.length).fill(true));
      expect(rows.values, evidence).not.toContain(undefined);
      expect(rows.descriptors, evidence).toEqual(rows.values);
      expect(rows.keys, evidence).toEqual(
        Array.from({ length: rows.length }, (_, index) => String(index))
      );
    }
    for (const name of ["existing", "new"]) {
      for (const index of [0, 1, 2]) {
        for (const suffix of ["", " latest"]) {
          const reader = `${name} ${index}${suffix}`;
          const published = frames.filter(frame => frame.reader === reader);
          expect(published.length).toBeGreaterThan(0);
          expect(published.at(-1)?.rows.values).toEqual([]);
        }
      }
    }
    expect(source()).toEqual([]);
    expect(snapshot(inner).values).toEqual([]);
    expect(snapshot(outer).values).toEqual([]);
  } finally {
    gates.forEach(gate => gate.resolve());
    await Promise.allSettled(running);
    disposeNewReader?.();
    dispose();
    flush();
  }
});
