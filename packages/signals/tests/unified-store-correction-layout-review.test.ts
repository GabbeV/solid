import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  refresh
} from "../src/index.js";
const turn = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
type Row = { id: string; text: string };
const view = (rows: Row[]) =>
  Array.from({ length: rows.length }, (_, i) =>
    Object.hasOwn(rows, i) ? (rows[i]?.text ?? "<undefined>") : "<absent>"
  ).join(" | ");

it("a draft-store correction never publishes a missing row beside its length", async () => {
  const asks: Array<PromiseWithResolvers<string[]>> = [];
  const finish = Promise.withResolvers<void>();
  const frames: Array<[string, string]> = [];
  const [rows, setRows, dispose] = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore<Row[]>(async d => {
      const ask = Promise.withResolvers<string[]>();
      asks.push(ask);
      const truth = await ask.promise;
      d.length = 0;
      d.push(...truth.map(text => ({ id: text, text })));
    }, []);
    const derived = createMemo(() => view(rows).toUpperCase());
    createRenderEffect(
      () => [view(rows), derived()] as [string, string],
      pair => void frames.push(pair)
    );
    return [rows, setRows, dispose] as const;
  });
  let posting: Promise<unknown> | undefined;
  try {
    flush();
    asks[0].resolve(["dana"]);
    await turn();
    posting = action(function* () {
      setRows(d => {
        d.push({ id: "tmp", text: "mine (sending)" });
      });
      yield finish.promise;
      refresh(rows);
    })();
    await turn();
    finish.resolve();
    await turn();
    const from = frames.length;
    asks.at(-1)!.resolve(["dana", "mine"]);
    await turn();
    expect(rows.map(row => row.text)).toEqual(["dana", "mine"]);
    expect(frames.at(-1)).toEqual(["dana | mine", "DANA | MINE"]);
    for (const [direct, memo] of frames.slice(from)) {
      expect(direct).not.toContain("<absent>");
      expect(direct).not.toContain("<undefined>");
      expect(memo).toBe(direct.toUpperCase());
    }
  } finally {
    dispose();
    for (const ask of asks) ask.resolve([]);
    finish.resolve();
    await posting;
    await turn();
  }
});

it("a restored unguessed row and the memo of that selected array publish together", async () => {
  const asks: Array<{ id: number; request: PromiseWithResolvers<string[]> }> = [];
  const finish = Promise.withResolvers<void>(),
    reverse = Promise.withResolvers<void>();
  const frames: Array<[string, string]> = [];
  const [rows, setRows, select, dispose] = createRoot(dispose => {
    const [question] = createSignal(3);
    const [selection, select] = createOptimistic(question);
    const [rows, setRows] = createOptimisticStore<Row[]>(async d => {
      const id = selection(),
        request = Promise.withResolvers<string[]>();
      asks.push({ id, request });
      const truth = await request.promise;
      d.length = 0;
      d.push(...truth.map(text => ({ id: text, text })));
    }, []);
    const derived = createMemo(() => view(rows).toUpperCase());
    createRenderEffect(
      () => [view(rows), derived()] as [string, string],
      pair => void frames.push(pair)
    );
    return [rows, setRows, select, dispose] as const;
  });
  let posting: Promise<unknown> | undefined;
  let choosing: Promise<unknown> | undefined;
  try {
    flush();
    asks[0].request.resolve(["dana"]);
    await turn();
    posting = action(function* () {
      setRows(d => {
        d.push({ id: "tmp", text: "mine (sending)" });
      });
      yield finish.promise;
    })();
    await turn();
    choosing = action(function* () {
      select(1);
      yield reverse.promise;
    })();
    await turn();
    asks.at(-1)!.request.resolve([]);
    await turn();
    expect(frames.at(-1)).toEqual(["<absent> | mine (sending)", "<ABSENT> | MINE (SENDING)"]);
    reverse.resolve();
    await turn();
    expect(asks.at(-1)!.id).toBe(3);
    const from = frames.length;
    asks.at(-1)!.request.resolve(["dana"]);
    await turn();
    expect(frames.at(-1)?.[0]).toBe("dana | mine (sending)");
    for (const [direct, memo] of frames.slice(from)) expect(memo).toBe(direct.toUpperCase());
  } finally {
    dispose();
    finish.resolve();
    reverse.resolve();
    for (const ask of asks) ask.request.resolve([]);
    await Promise.all([posting, choosing]);
    await turn();
  }
});
