import { expect, test } from "vitest";
import {
  action,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest
} from "../src/index.js";

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(resolve => setTimeout(resolve, 0));
    flush();
  }
};

type Row = { id: string; text: string };
const initial: Row = { id: "dana", text: "dana" };
const optimistic: Row = { id: "tmp-mine", text: "mine (sending)" };

for (const nested of [false, true])
  for (const reader of ["indices", "structure", "memo", "async memo"] as const)
    test(`latest selected array preserves ${reader} through a held removal (nested=${nested})`, async () => {
      let dispose!: () => void;
      let release!: () => void;
      let setSource!: (rows: Row[]) => void;
      let renderLatest!: () => void;
      let source!: () => Row[];
      let append!: () => Promise<void>;
      const gate = new Promise<void>(resolve => (release = resolve));
      const ordinaryFrames: unknown[] = [];
      const latestFrames: unknown[] = [];
      const value = (rows: Row[]) => {
        if (reader === "indices") return [rows[0]?.text ?? "<absent>", rows[1]?.text ?? "<absent>"];
        if (reader === "structure")
          return {
            length: rows.length,
            keys: Object.keys(rows),
            has: [0 in rows, 1 in rows],
            own: [Object.hasOwn(rows, 0), Object.hasOwn(rows, 1)],
            descriptors: [0, 1].map(index => {
              const descriptor = Object.getOwnPropertyDescriptor(rows, index);
              return descriptor ? (descriptor.value?.text ?? "<undefined>") : "<absent>";
            })
          };
        return Array.from({ length: rows.length }, (_, i) =>
          Object.hasOwn(rows, i) ? (rows[i]?.text ?? "<undefined>") : "<absent>"
        );
      };
      createRoot(d => {
        dispose = d;
        const [input, setInput] = createSignal<Row[]>([initial]);
        const [render, setRender] = createSignal(0);
        source = input;
        setSource = setInput;
        renderLatest = () => setRender(n => n + 1);
        let rows: () => Row[];
        if (nested) {
          const [store, setStore] = createOptimisticStore(() => ({ rows: input() }), { rows: [] });
          rows = () => store.rows;
          append = action(function* () {
            setStore(draft => void draft.rows.push(optimistic));
            yield gate;
          });
        } else {
          const [store, setStore] = createOptimisticStore(() => input(), []);
          rows = () => store;
          append = action(function* () {
            setStore(draft => void draft.push(optimistic));
            yield gate;
          });
        }
        const read = () => value(rows());
        const first = reader === "memo" ? createMemo(read) : read;
        const derived =
          reader === "memo"
            ? createMemo(() => first())
            : reader === "async memo"
              ? createMemo(async () => {
                  const current = read();
                  await Promise.resolve();
                  return current;
                })
              : read;
        createRenderEffect(read, frame => void ordinaryFrames.push(frame));
        createRenderEffect(
          () => {
            render();
            return latest(derived);
          },
          frame => void latestFrames.push(frame)
        );
      });
      try {
        await tick();
        const posting = append();
        await tick();
        renderLatest();
        await tick();
        const selected = value([initial, optimistic]);
        expect(ordinaryFrames.at(-1)).toEqual(selected);
        expect(latestFrames.at(-1)).toEqual(selected);

        setSource([]);
        await tick();
        renderLatest();
        await tick();
        expect(latest(source)).toEqual([]);
        expect(ordinaryFrames.at(-1)).toEqual(selected);
        const observed = latestFrames.at(-1);

        release();
        await posting;
        await tick();
        renderLatest();
        await tick();
        const corrected = value([]);
        expect(ordinaryFrames.at(-1)).toEqual(corrected);
        expect(latestFrames.at(-1)).toEqual(corrected);
        // Every publication is one complete state. This catches a transient
        // sparse proposal even if a later render repairs the visible output.
        const coherent = [value([initial]), selected, corrected];
        for (const frame of ordinaryFrames) expect(coherent).toContainEqual(frame);
        for (const frame of latestFrames)
          expect(coherent, JSON.stringify({ ordinaryFrames, latestFrames })).toContainEqual(frame);
        expect(observed, JSON.stringify(observed)).toEqual(selected);
      } finally {
        release();
        dispose();
        await tick();
      }
    });
