/** A functional guess can use the last answer while the new input is loading.
 * The caller decides whether its prediction needs fresh data. */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  action,
  createOptimistic,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  OBSERVE,
  refresh
} from "../src/index.js";

const CODE = "OPTIMISTIC_WRITE_WHILE_LOADING";
let warn: ReturnType<typeof vi.spyOn>;
beforeEach(() => {
  warn = vi.spyOn(console, "warn").mockImplementation(() => {});
});
afterEach(() => {
  warn.mockRestore();
  flush();
});
const warned = () => warn.mock.calls.filter(c => String(c[0]).includes(CODE)).length;
const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};

function app(kind: "memo" | "store") {
  const asks: Record<string, (v: any) => void> = {};
  const ask = (k: string) => new Promise<any>(r => (asks[k] = r));
  const bases: string[][] = [];
  let setSel!: (v: number) => void, guess!: () => void, again!: () => void;
  createRoot(() => {
    const [sel, set] = createSignal(1);
    setSel = set;
    if (kind === "memo") {
      const [v, setV] = createOptimistic(async () => ask(`fetch:${sel()}`));
      createRenderEffect(
        () => v(),
        () => {}
      );
      guess = () =>
        setV((d: string[] | undefined) => {
          bases.push([...(d ?? [])]);
          return [...(d ?? []), "x"];
        });
      again = () => void refresh(v);
    } else {
      const [s, setS] = createOptimisticStore(async () => ask(`fetch:${sel()}`), [] as string[]);
      createRenderEffect(
        () => s.length,
        () => {}
      );
      guess = () =>
        setS(d => {
          bases.push([...d]);
          d.push("x");
        });
      again = () => void refresh(s);
    }
  });
  return {
    asks,
    bases,
    setSel: (v: number) => setSel(v),
    guess: () => guess(),
    again: () => again()
  };
}

describe("#4795: guessing while the source loads a new question", () => {
  for (const kind of ["memo", "store"] as const) {
    it(`${kind}: the setter composes on the last answer without warning`, async () => {
      const a = app(kind);
      flush();
      a.asks["fetch:1"](["a"]);
      await tick();
      a.setSel(2);
      flush();
      const capture = OBSERVE!.diagnostics.capture();
      action(function* () {
        a.guess();
        a.guess();
      })();
      flush();
      expect(a.bases).toEqual([["a"], ["a", "x"]]);
      expect(capture.stop().map(event => event.code)).not.toContain(CODE);
      expect(warned()).toBe(0);
    });
    it(`${kind}: not over a refresh of the same question`, async () => {
      const a = app(kind);
      flush();
      a.asks["fetch:1"](["a"]);
      await tick();
      a.again();
      flush();
      const capture = OBSERVE!.diagnostics.capture();
      action(function* () {
        a.guess();
      })();
      flush();
      expect(capture.stop().map(event => event.code)).not.toContain(CODE);
      expect(warned()).toBe(0);
    });
  }
  it("memo: not before the first answer (S-56)", () => {
    const a = app("memo");
    flush();
    const capture = OBSERVE!.diagnostics.capture();
    action(function* () {
      a.guess();
    })();
    flush();
    expect(capture.stop().map(event => event.code)).not.toContain(CODE);
    expect(warned()).toBe(0);
  });
});
