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

const settle = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};
const snapshot = (rows: string[]) =>
  Array.from({ length: rows.length }, (_, index) =>
    Object.hasOwn(rows, index) ? (rows[index] ?? "<undefined>") : "<absent>"
  );

for (const depth of [2, 3]) {
  for (const innerEdit of ["append", "value"] as const) {
    for (const release of ["inside out", "outside in"] as const) {
      it(`${depth} active array layers remain dense through incoming shrink (${innerEdit}, ${release})`, async () => {
        const [input, setInput] = createSignal(["A", "B"]);
        const [render, setRender] = createSignal(0);
        const gates = Array.from({ length: depth }, () => Promise.withResolvers<void>());
        const flags = Array.from({ length: depth }, () => createSignal(false));
        const ordinary: string[][][] = Array.from({ length: depth }, () => []);
        const leading: string[][][] = Array.from({ length: depth }, () => []);
        const source: string[][] = [],
          leadingSource: string[][] = [];
        const saved: boolean[][] = [];
        const [setters, dispose] = createRoot(dispose => {
          let lower: () => string[] = input;
          const setters: Array<(edit: (draft: string[]) => void) => void> = [];
          for (let layer = 0; layer < depth; layer++) {
            const readLower = lower;
            const [rows, guess] = createOptimisticStore(readLower, ["A", "B"]);
            setters.push(guess);
            lower = () => rows;
            createRenderEffect(
              () => snapshot(rows),
              value => {
                ordinary[layer].push(value);
              }
            );
            createRenderEffect(
              () => {
                render();
                return latest(() => snapshot(rows));
              },
              value => {
                leading[layer].push(value);
              }
            );
          }
          createRenderEffect(
            () => snapshot(input()),
            value => {
              source.push(value);
            }
          );
          createRenderEffect(
            () => latest(() => snapshot(input())),
            value => {
              leadingSource.push(value);
            }
          );
          createRenderEffect(
            () => flags.map(([read]) => read()),
            value => {
              saved.push(value);
            }
          );
          return [setters, dispose] as const;
        });
        const running: Array<Promise<unknown>> = [];
        const phases: unknown[] = [];
        const record = (phase: string) => {
          phases.push({
            phase,
            source: source.at(-1),
            latestSource: leadingSource.at(-1),
            ordinary: ordinary.map(frames => frames.at(-1)),
            latest: leading.map(frames => frames.at(-1)),
            saved: saved.at(-1)
          });
        };
        try {
          flush();
          for (let layer = 0; layer < depth; layer++) {
            running.push(
              action(function* () {
                setters[layer](draft => {
                  if (layer === 0 && innerEdit === "value") draft[1] = "I0";
                  else draft.push(`I${layer}`);
                });
                flags[layer][1](true);
                yield gates[layer].promise;
              })()
            );
            flush();
          }
          setRender(value => value + 1);
          flush();
          record("all active");
          // Every output contains the selected lower output and its own edit.
          const selected = ["A", innerEdit === "value" ? "I0" : "B"];
          if (innerEdit === "append") selected.push("I0");
          for (let layer = 0; layer < depth; layer++) {
            if (layer) selected.push(`I${layer}`);
            expect(ordinary[layer].at(-1)).toEqual(selected);
            expect(leading[layer].at(-1)).toEqual(selected);
          }
          setInput([]);
          flush();
          setRender(value => value + 1);
          flush();
          record("incoming shrink");
          for (let step = 0; step < depth; step++) {
            const layer = release === "inside out" ? step : depth - step - 1;
            gates[layer].resolve();
            await running[layer];
            await settle();
            setRender(value => value + 1);
            flush();
            record(`release ${layer}`);
          }
          for (const frames of [...ordinary, ...leading]) {
            expect(frames.flat(), JSON.stringify(phases)).not.toContain("<absent>");
            expect(frames.flat(), JSON.stringify(phases)).not.toContain("<undefined>");
            expect(frames.at(-1)).toEqual([]);
          }
          expect(source.at(-1)).toEqual([]);
          expect(leadingSource.at(-1)).toEqual([]);
          expect(saved.at(-1)).toEqual(Array(depth).fill(true));
        } finally {
          gates.forEach(gate => gate.resolve());
          await Promise.allSettled(running);
          dispose();
          flush();
        }
      });
    }
  }
}
