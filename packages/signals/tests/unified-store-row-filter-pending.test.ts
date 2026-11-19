import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  flush,
  refresh
} from "../src/index.js";
const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};
for (const objects of [false, true])
  it(`filtering during a refetch publishes selected rows (objects=${objects})`, async () => {
    type Row = number | { id: number };
    const requests: ReturnType<typeof Promise.withResolvers<Row[]>>[] = [];
    const finish = Promise.withResolvers<void>();
    const truth: Row[] = objects ? [{ id: 1 }, { id: 2 }] : [1, 2];
    const id = (row: Row) => (typeof row === "number" ? row : row.id);
    const shown: string[] = [];
    const [rows, set, dispose] = createRoot(dispose => {
      const [rows, set] = createOptimisticStore(() => {
        const request = Promise.withResolvers<Row[]>();
        requests.push(request);
        return request.promise;
      }, [] as Row[]);
      createRenderEffect(
        () => rows.map(id).join(","),
        value => void shown.push(value)
      );
      return [rows, set, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      requests[0].resolve(truth);
      await turn();
      expect(shown).toEqual(["1,2"]);
      refresh(rows);
      flush();
      running = action(function* () {
        set(draft => draft.filter(row => id(row) !== 1));
        yield finish.promise;
      })();
      flush();
      expect(shown).toEqual(["1,2", "2"]);
      expect(rows.map(id).join(",")).toBe("2");
      requests[1].resolve(truth);
      await turn();
      expect(shown).toEqual(["1,2", "2"]);
      finish.resolve();
      await running;
      await turn();
      expect(shown.at(-1)).toBe("1,2");
    } finally {
      for (const request of requests) request.resolve(truth);
      finish.resolve();
      await running;
      await turn();
      dispose();
      flush();
    }
  });
