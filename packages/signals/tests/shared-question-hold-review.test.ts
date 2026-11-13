/** An independent producer flight holds only ordinary demanded inputs. A
 * complete selected value cuts that demand; observing the raw input preserves
 * it. Store For also reads container structure, unlike native map over selected
 * length/presence/rows. This is distinct from same-action own-input retention. */
import { test, expect } from "vitest";
import {
  action,
  createOptimistic,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  mapArray,
  flush,
  $REFRESH,
  refresh
} from "../src/index.js";
import { read } from "../src/core/core.js";
import { STATUS_PENDING } from "../src/core/constants.js";
import { boundaries } from "../src/layers/boundary.js";
import { txOf, blocked, blockersOf } from "../src/core/scheduler.js";
const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
for (const kind of ["store", "scalar"] as const)
  for (const observer of (kind === "store" ? ["none", "For", "raw"] : ["none", "raw"]) as Array<
    "none" | "For" | "raw"
  >)
    test(`${kind} ${observer}`, async () => {
      const asks: { key: string; resolve: (v: any) => void }[] = [];
      const ask = (key: string) => new Promise<any>(resolve => asks.push({ key, resolve }));
      const settle = async (key: string, v: any) => {
        const i = asks.findIndex(a => a.key === key);
        expect(i).toBeGreaterThanOrEqual(0);
        asks.splice(i, 1)[0].resolve(v);
        await tick();
      };
      let dispose!: () => void,
        setFilter!: (v: string) => void,
        close!: () => unknown,
        producer: any;
      const frames: string[] = [];
      let sourceRows!: () => { id: number }[];
      createRoot(d => {
        dispose = d;
        const [filter, sf] = createSignal("open");
        setFilter = sf;
        let set: any;
        let store: any;
        if (kind === "store") {
          [store, set] = createOptimisticStore(() => ask(`issues:${filter()}`), [], { key: "id" });
          sourceRows = () => store;
          producer = store[$REFRESH];
        } else {
          const [rows, gs] = createOptimistic(() => ask(`issues:${filter()}`));
          sourceRows = rows;
          set = gs;
          producer = boundaries.get((rows as any)[$REFRESH])!._input;
        }
        close = action(function* () {
          if (kind === "store")
            set((list: any[]) => {
              list.splice(0, 1);
            });
          else set((list: any[]) => list.slice(1));
          yield ask("close");
          refresh(kind === "store" ? store : sourceRows);
        });
        if (observer !== "none")
          createRoot(() => {
            if (observer === "raw")
              createRenderEffect(
                () => read(producer),
                () => {}
              );
            if (observer === "For") {
              const rows = mapArray(sourceRows, r => r.id);
              createRenderEffect(rows, () => {});
            }
          });
        createRenderEffect(
          () =>
            `${filter()}: ${sourceRows()
              .map(r => r.id)
              .join()}`,
          v => {
            frames.push(v);
          }
        );
      });
      try {
        await tick();
        await settle("issues:open", [{ id: 1 }, { id: 3 }, { id: 4 }]);
        setFilter("closed");
        await tick();
        expect(frames.at(-1)).toBe("open: 1,3,4");
        expect(blocked(txOf(producer))).toBe(true);
        const closing = close();
        await tick();
        const held = observer === "raw" || (kind === "store" && observer === "For");
        expect(frames.at(-1)).toBe(`${held ? "open" : "closed"}: 3,4`);
        expect(producer._statusFlags & STATUS_PENDING).toBe(STATUS_PENDING);
        expect(producer._x?._transaction ? blocked(txOf(producer)) : false).toBe(held);
        expect(producer._x?._transaction ? blockersOf(txOf(producer)).length > 0 : false).toBe(
          held
        );
        await settle("issues:closed", [{ id: 1 }, { id: 2 }]);
        // An unpublished store membership change joins the active splice action.
        // With native map alone every read is selected, so the filter already
        // forwarded before this answer; a later proposal cannot retract it.
        expect(frames.at(-1)).toBe(kind === "store" && held ? "open: 3,4" : "closed: 3,4");
        await settle("close", {});
        await settle("issues:closed", [{ id: 2 }]);
        await closing;
        expect(frames.at(-1)).toBe("closed: 2");
        for (const frame of frames)
          expect(["open: 1,3,4", "open: 3,4", "closed: 3,4", "closed: 2"]).toContain(frame);
      } finally {
        dispose();
      }
    });
