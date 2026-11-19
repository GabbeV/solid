import { expect, test } from "vitest";
import {
  action,
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

test("latest of a selected array keeps its coherent structure while an incoming removal is held", async () => {
  type Row = { id: string; text: string };
  let dispose!: () => void;
  let setSource!: (rows: Row[]) => void;
  let append!: () => Promise<void>;
  let release!: () => void;
  let selected!: Row[];
  let source!: () => Row[];
  let renderLatest!: () => void;
  const gate = new Promise<void>(resolve => (release = resolve));
  const ordinaryFrames: string[][] = [];
  const latestFrames: string[][] = [];
  const latestInputFrames: string[][] = [];
  // Guard every index so a sparse output is observable as an assertion failure,
  // without dereferencing an absent row inside a render binding.
  const snapshot = (rows: Row[]) =>
    Array.from({ length: rows.length }, (_, i) =>
      Object.hasOwn(rows, i) ? (rows[i]?.text ?? "<undefined>") : "<absent>"
    );
  createRoot(d => {
    dispose = d;
    const [render, setRender] = createSignal(0);
    renderLatest = () => setRender(value => value + 1);
    const [input, setInput] = createSignal<Row[]>([{ id: "dana", text: "dana" }]);
    source = input;
    setSource = setInput;
    const [rows, setRows] = createOptimisticStore(() => input(), []);
    selected = rows;
    append = action(function* () {
      setRows(draft => {
        draft.push({ id: "tmp-mine", text: "mine (sending)" });
      });
      yield gate;
    });
    createRenderEffect(
      () => snapshot(rows),
      frame => void ordinaryFrames.push(frame)
    );
    createRenderEffect(
      () => {
        render();
        return latest(() => snapshot(rows));
      },
      frame => void latestFrames.push(frame)
    );
    createRenderEffect(
      () => latest(input).map(row => row.text),
      frame => void latestInputFrames.push(frame)
    );
  });
  try {
    await tick();
    expect(ordinaryFrames.at(-1)).toEqual(["dana"]);
    const posting = append();
    await tick();
    expect(ordinaryFrames.at(-1)).toEqual(["dana", "mine (sending)"]);
    // An unrelated render trigger evaluates latest in a real binding even
    // when the current output proposal did not notify that binding itself.
    renderLatest();
    await tick();
    expect(latestFrames.at(-1)).toEqual(["dana", "mine (sending)"]);

    setSource([]);
    await tick();
    renderLatest();
    await tick();
    // latest may lead on the source signal. The selected output still has an
    // active append, so its incoming structural removal must remain coherent.
    expect(latest(source)).toEqual([]);
    expect(latestInputFrames.at(-1)).toEqual([]);
    expect(ordinaryFrames.at(-1)).toEqual(["dana", "mine (sending)"]);
    const observed = {
      rendered: latestFrames.at(-1),
      imperative: latest(() => snapshot(selected))
    };
    expect(observed, JSON.stringify(observed)).toEqual({
      rendered: ["dana", "mine (sending)"],
      imperative: ["dana", "mine (sending)"]
    });

    release();
    await posting;
    await tick();
    expect(ordinaryFrames.at(-1)).toEqual([]);
    expect(latestFrames.at(-1)).toEqual([]);
  } finally {
    release();
    dispose();
    await tick();
  }
});
