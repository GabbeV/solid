import { expect, it } from "vitest";
import {
  action,
  createEffect,
  createRenderEffect,
  createMemo,
  createOptimistic,
  createOptimisticStore,
  createRoot,
  createSignal,
  flush,
  latest,
  isPending
} from "../src/index.js";
const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
const serialize = (v: any) => JSON.stringify(v) ?? String(v);
function setup(
  kind: "store" | "scalar",
  whole: boolean,
  error: unknown,
  observation: "ordinary" | "latest" | "pending" = "ordinary"
) {
  const log: Record<string, string[]> = { selected: [], sibling: [], length: [], late: [] };
  let start!: () => any,
    finish!: () => void,
    setPhase!: (v: number) => void,
    late!: () => void,
    dispose!: () => void;
  let disposeLate: (() => void) | undefined;
  createRoot(d => {
    dispose = () => {
      disposeLate?.();
      d();
    };
    const [phase, sp] = createSignal(0);
    setPhase = sp;
    const source = createMemo(() => {
      if (phase() === 1) throw error;
      return phase() === 2 ? 4 : 1;
    });
    let selected: () => any, sibling: () => any, length: () => any, propose: () => void;
    if (kind === "scalar") {
      const [v, sv] = createOptimistic(source);
      selected = v;
      sibling = source;
      length = source;
      propose = () => sv(9);
    } else {
      const [st, set] = createOptimisticStore(
        (d: any[]) => {
          const n = source();
          d.length = 0;
          d.push({ id: 1, v: n }, { id: 2, v: n + 1 });
        },
        [],
        { key: "id" }
      );
      selected = () => st[0]?.v;
      sibling = () => st[1]?.v;
      length = () => st.length;
      propose = () =>
        set(d => {
          if (whole) d[0] = { id: 9, v: 9 };
          else d[0].v = 9;
        });
    }
    const watch = (fn: () => any, key: string) =>
      createEffect(fn, {
        effect: v => {
          log[key].push(serialize(v));
        },
        error: e => {
          log[key].push("ERR " + String(e?.message ?? e));
        }
      });
    const observed =
      observation === "latest"
        ? () => latest(selected)
        : observation === "pending"
          ? () => `${selected()}/${isPending(selected)}`
          : selected;
    watch(observed, "selected");
    watch(sibling, "sibling");
    watch(length, "length");
    late = () => {
      disposeLate = createRoot(d => {
        watch(observed, "late");
        return d;
      });
    };
    let resolve!: () => void;
    start = action(function* () {
      propose();
      yield new Promise<void>(r => (resolve = r));
    });
    finish = () => resolve?.();
  });
  return { log, start, finish, setPhase, late, dispose };
}
for (const whole of [false, true])
  for (const error of [new Error("bad"), undefined])
    for (const observation of ["ordinary", "latest", "pending"] as const) {
      it(`published selected ${whole ? "object" : "leaf"} error=${String(error)} observation=${observation}`, async () => {
        const h = setup("store", whole, error, observation);
        const control = setup("scalar", whole, error, observation);
        try {
          await tick();
          h.start();
          control.start();
          await tick();
          h.setPhase(1);
          control.setPhase(1);
          await tick();
          const active = JSON.parse(JSON.stringify(h.log)),
            scalar = JSON.parse(JSON.stringify(control.log));
          h.late();
          control.late();
          await tick();
          const late = JSON.parse(JSON.stringify(h.log));
          h.finish();
          control.finish();
          await tick();
          const retired = JSON.parse(JSON.stringify(h.log));
          h.setPhase(0);
          control.setPhase(0);
          await tick();

          expect(
            active.selected.filter((v: string, i: number, a: string[]) => i === 0 || v !== a[i - 1])
          ).toEqual(scalar.selected);
          expect(late.late).toEqual(control.log.late.slice(0, 1));
          expect(retired.selected.at(-1)).toMatch(/^ERR /);
          expect(h.log.selected.at(-1)).toBe(observation === "pending" ? '"1/false"' : "1");
        } finally {
          h.finish();
          control.finish();
          h.dispose();
          control.dispose();
          flush();
        }
      });
    }

function heldFixture(kind: "store" | "scalar", whole: boolean) {
  const log: { fast: string[]; slow: string[] } = { fast: [], slow: [] };
  let start!: () => any,
    finish!: () => void,
    answer!: () => void,
    change!: () => void,
    dispose!: () => void;
  createRoot(d => {
    dispose = d;
    const [n, s] = createSignal(1);
    change = () => s(4);
    let selected: () => number, propose: () => void;
    if (kind === "scalar") {
      const [v, sv] = createOptimistic(n);
      selected = v;
      propose = () => sv(9);
    } else {
      const [st, set] = createOptimisticStore(
        (d: any[]) => {
          d.length = 0;
          d.push({ id: 1, v: n() }, { id: 2, v: 2 });
        },
        [],
        { key: "id" }
      );
      selected = () => st[0]?.v;
      propose = () =>
        set(d => {
          if (whole) d[0] = { id: 9, v: 9 };
          else d[0].v = 9;
        });
      createEffect(() => st.length, { effect: () => {}, error: () => {} });
    }
    const wait = new Promise<void>(r => (answer = r));
    const slow = createMemo(() => {
      const v = selected();
      return v === 4 ? wait.then(() => v) : v;
    });
    createRenderEffect(selected, v => {
      log.fast.push(String(v));
    });
    createRenderEffect(slow, v => {
      log.slow.push(String(v));
    });
    let resolve!: () => void;
    start = action(function* () {
      propose();
      yield new Promise<void>(r => (resolve = r));
    });
    finish = () => resolve?.();
  });
  return { log, start, finish, answer, change, dispose };
}
for (const whole of [false, true])
  it(`holds published ${whole ? "object" : "leaf"} correction with async downstream like scalar`, async () => {
    const h = heldFixture("store", whole),
      c = heldFixture("scalar", whole);
    try {
      await tick();
      h.start();
      c.start();
      await tick();
      h.change();
      c.change();
      await tick();
      const active = serialize(h.log),
        controlActive = serialize(c.log);
      h.finish();
      c.finish();
      await tick();
      const held = serialize(h.log),
        controlHeld = serialize(c.log);
      h.answer();
      c.answer();
      await tick();

      expect(active).toBe(controlActive);
      expect(JSON.parse(held)).toEqual({ fast: ["1", "9"], slow: ["1", "9"] });
      expect(JSON.parse(controlHeld)).toEqual({ fast: ["1", "9"], slow: ["1", "9"] });
      expect(held).toBe(controlHeld);
      expect(h.log).toEqual(c.log);
      expect(h.log.slow.at(-1)).toBe("4");
    } finally {
      h.finish();
      c.finish();
      h.answer();
      c.answer();
      h.dispose();
      c.dispose();
      flush();
    }
  });
for (const error of [new Error("bad"), undefined])
  it(`whole selected object publishes protected body error=${String(error)}`, async () => {
    const frames: string[] = [];
    let start!: () => any,
      finish!: () => void,
      fail!: () => void,
      recover!: () => void,
      dispose!: () => void;
    createRoot(d => {
      dispose = d;
      const [bad, setBad] = createSignal(false);
      fail = () => setBad(true);
      recover = () => setBad(false);
      const source = createMemo(() => {
        if (bad()) throw error;
        return [
          { id: 1, v: 1 },
          { id: 2, v: 2 }
        ];
      });
      const [st, set] = createOptimisticStore(
        (d: any[]) => {
          const rows = source();
          d.length = 0;
          d.push(...rows);
        },
        [],
        { key: "id" }
      );
      createEffect(() => st.length, { effect: () => {}, error: () => {} });
      createEffect(() => st[1]?.v, { effect: () => {}, error: () => {} });
      createEffect(() => JSON.stringify(st[0]), {
        effect: v => {
          frames.push(v);
        },
        error: e => {
          frames.push("ERR " + String(e?.message ?? e));
        }
      });
      let resolve!: () => void;
      start = action(function* () {
        set(d => {
          d[0] = { id: 9, v: 9 };
        });
        yield new Promise<void>(r => (resolve = r));
      });
      finish = () => resolve?.();
    });
    try {
      await tick();
      start();
      await tick();
      fail();
      await tick();
      const active = [...frames];
      finish();
      await tick();
      const retired = [...frames];
      recover();
      await tick();

      expect(active.at(-1)).toBe('{"id":9,"v":9}');
      expect(active.some(v => v.startsWith("ERR"))).toBe(false);
      expect(retired.at(-1)).toMatch(/^ERR /);
      expect(frames.at(-1)).toBe('{"id":1,"v":1}');
    } finally {
      finish();
      dispose();
      flush();
    }
  });
