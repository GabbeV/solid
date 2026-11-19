/**
 * #4648 landing controls under shared observation contexts. An untracked
 * isPending read still selects the whole calculation's update context. When
 * a later flight keeps the ordinary update open, that observation can publish
 * pending=true beside committed data; it must never publish proposed data
 * beside a stale callback read. Both read orders and sibling depths agree.
 * A completed update with no remaining hold still lands in one frame.
 */
import { describe, expect, it } from "vitest";
import {
  createEffect,
  createMemo,
  createRenderEffect,
  createSignal,
  flush,
  isPending,
  untrack
} from "../src/index.js";

type Row = { v: number; inner: unknown; p: unknown };
type Order = "probe after read" | "probe before read";
const orders: Order[] = ["probe after read", "probe before read"];

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r));
    flush();
  }
};

const initial = { v: 0, inner: 0, p: false };
const pending = { v: 0, inner: 0, p: true };
const landed = { v: 5, inner: 5, p: false };

function probePass(order: Order, cond: () => number, after: () => void, log: Row[]) {
  return createMemo(() => {
    let v = 0,
      inner: unknown,
      p: unknown;
    const probeIt = () => (p = untrack(() => isPending(() => (inner = cond()))));
    if (order === "probe before read") probeIt();
    v = cond();
    if (order === "probe after read") probeIt();
    after();
    const r = { v, inner, p };
    log.push(r);
    return r;
  });
}

describe.each(orders)("a pass that reads the hold's flight (%s)", order => {
  for (const hold of [false, true])
    it(`lands in one frame (${hold ? "held by its own flight" : "no hold"})`, async () => {
      const screen: Row[] = [];
      const effects: Row[] = [];
      const log: Row[] = [];
      let res!: (v: number) => void;
      const [open, setOpen] = createSignal(0);
      const cond = createMemo(() => open());
      const a = createMemo(async () => {
        const v = open();
        if (v && hold) await new Promise<number>(r => (res = r));
        return v;
      });
      const pass = probePass(order, cond, () => void (hold && a()), log);
      createRenderEffect(pass, r => void screen.push(r));
      createEffect(pass, r => void effects.push(r));
      flush();
      await tick();
      setOpen(5);
      flush();
      if (hold) {
        expect(screen).toEqual([initial]);
        res(5);
      }
      await tick();
      expect(screen).toEqual([initial, landed]);
      expect(effects).toEqual([initial, landed]);
    });
});

describe.each(["same pass", "sibling", "deep sibling"] as const)(
  "a later node blocks the hold again in the landing flush (%s)",
  where => {
    describe.each(orders)("%s", order => {
      it("publishes pending over committed data while a later flight holds the update", async () => {
        const screen: Row[] = [];
        const effects: Row[] = [];
        const log: Row[] = [];
        let resA!: (v: number) => void, resB!: (v: number) => void;
        const [open, setOpen] = createSignal(0);
        const cond = createMemo(() => open());
        const a = createMemo(async () => {
          const v = open();
          if (v) await new Promise<number>(r => (resA = r));
          return v;
        });
        // `deep sibling`: computed after the pass in the landing flush, so
        // the pass's probe ran while the hold was not yet blocked again.
        const m1 = createMemo(() => a());
        const m2 = createMemo(() => m1());
        const m3 = createMemo(() => m2());
        const b = createMemo(async () => {
          const v = where === "deep sibling" ? m3() : a();
          if (v) await new Promise<number>(r => (resB = r));
          return v;
        });
        const pass = probePass(
          order,
          cond,
          () => {
            a();
            if (where === "same pass") b();
          },
          log
        );
        createRenderEffect(pass, r => void screen.push(r));
        createEffect(pass, r => void effects.push(r));
        if (where !== "same pass") createRenderEffect(b, () => {});
        flush();
        await tick();
        expect(screen).toEqual([initial]);
        log.length = 0;
        setOpen(5);
        flush();
        resA(5);
        await tick();
        // `b` keeps the ordinary update open. The observation publishes its
        // own context: all ordinary reads in the pass see committed zero.
        expect(screen).toEqual([initial, pending]);
        expect(effects).toEqual([initial, pending]);
        expect(log.at(-1)).toEqual(pending);
        resB(5);
        await tick();
        expect(screen).toEqual([initial, pending, landed]);
        expect(effects).toEqual([initial, pending, landed]);
      });
    });
  }
);
