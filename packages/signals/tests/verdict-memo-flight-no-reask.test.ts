// Async derivations downstream of latest and pending observations
// (#4050, #4393, #4397). The shared engine keeps one eligible flight per
// memo: context changes can restart an earlier question. These tests pin
// those transitions, observable publication, and reader-grouping equivalence.
import { expect, it } from "vitest";
import {
  createErrorBoundary,
  createLoadingBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  refresh
} from "../src/index.js";

const sleep = (ms: number) => new Promise(r => setTimeout(r, ms));
async function settle() {
  for (let i = 0; i < 4; i++) {
    await sleep(15);
    flush();
  }
}

// Flights land only when the test lands them, so each step of a pin comes
// at the same point of the write's flights at any runner speed. `land(n)`
// lands what is up, `n` times over (what a landing asks is up next round).
function inFlight() {
  const up: (() => void)[] = [];
  const land = async (rounds = 8) => {
    for (let i = 0; i < rounds; i++) {
      up.splice(0).forEach(f => f());
      await sleep(0);
      flush();
    }
  };
  const fly = <T>(v: T) => new Promise<T>(r => up.push(() => r(v)));
  return { land, fly };
}

// A memo that holds the write's frame (the boundary's content reads it) until
// the test releases it, after the write's other flights have landed.
function holder(s: () => number) {
  let release = () => {};
  const h = createMemo(() =>
    s() === 1 ? 1 : new Promise<number>(r => void (release = () => r(1)))
  );
  return { h, release: () => release() };
}

const expected = {
  // The independently observed h keeps the input open for m0:4/m1:5.
  // Correction restarts m0:5: there is one eligible flight per memo.
  "latest held": ["m0:5", "m0:4", "m1:5", "m0:5", "m1:6"],
  // m1 previously published an error. Pending-only observation does not
  // hold this recovery, so latest's inactive input propagates ordinarily.
  "latest unheld": ["m0:5", "m1:6"],
  "plain held": ["m0:5", "m1:6"],
  "plain unheld": ["m0:5", "m1:6"]
};

for (const useLatest of [true, false])
  for (const heldWrite of [true, false]) {
    const name = `${useLatest ? "latest" : "plain"} ${heldWrite ? "held" : "unheld"}`;
    it(`${name}: recovery follows the input lifetime`, async () => {
      const [s, setS] = createSignal(1);
      const asks: string[] = [];
      const ask = (name: string, v: number) => {
        asks.push(`${name}:${v}`);
        return sleep(10).then(() => {
          if (v === 3) throw new Error(`${name}:${v}`);
          return v;
        });
      };
      const out: string[] = [];
      createRoot(() => {
        const m0 = createMemo(() => ask("m0", 1 + (useLatest ? latest(s) : s()) + s()));
        const m1 = createMemo(() => ask("m1", 1 + m0()));
        // Holds the write's frame for 80ms (the boundary's content reads it).
        const h = createMemo(() => (s() === 1 ? 1 : sleep(80).then(() => 1)));
        createErrorBoundary(
          () =>
            createLoadingBoundary(
              () => {
                createRenderEffect(
                  () => (heldWrite ? h() : 0, String(isPending(m1))),
                  v => void out.push(v)
                );
                return null;
              },
              () => "L"
            ),
          () => "E"
        );
      });
      flush();
      await settle();
      expect(asks).toEqual(["m0:3"]);
      setS(2);
      await settle();
      await settle();
      const after = asks.slice(1);
      expect(after).toEqual(expected[name as keyof typeof expected]);
      const m1Asks = after.filter(a => a.startsWith("m1"));
      expect(new Set(m1Asks).size).toBe(m1Asks.length);
      expect(out[out.length - 1]).toBe("false");
    });
  }

// With no independent lifetime, correction supersedes the optimistic
// flight before its answer. The ordinary m1 derivation publishes only 6.
for (const reader of ["m1()", "[isPending(m1), m1()]"] as const)
  it(`${reader}: a memo over a re-asking verdict memo waits on it, pending`, async () => {
    const [s, setS] = createSignal(1);
    const asks: string[] = [];
    const ask = (name: string, v: number) => {
      asks.push(`${name}:${v}`);
      return sleep(10).then(() => v);
    };
    const out: string[] = [];
    createRoot(() => {
      const m0 = createMemo(() => ask("m0", 1 + latest(s) + s()));
      const m1 = createMemo(() => ask("m1", 1 + m0()));
      createLoadingBoundary(
        () => {
          createRenderEffect(
            () => (reader === "m1()" ? String(m1()) : `${isPending(m1)},${m1()}`),
            v => void out.push(v)
          );
          return null;
        },
        () => "L"
      );
    });
    flush();
    await settle();
    expect(asks).toEqual(["m0:3", "m1:4"]);
    setS(2);
    await settle();
    await settle();
    expect(asks.slice(2)).toEqual(["m0:5", "m0:4", "m0:5", "m1:6"]);
    if (reader === "m1()") expect(out).toEqual(["4", "6"]);
    else {
      expect(out[0]).toBe("false,4");
      expect(out[out.length - 1]).toBe("false,6");
      // Never final before `m1:6` lands.
      expect(out.slice(1, -1).every(v => v.startsWith("true,"))).toBe(true);
    }
  });

// Vary the abandoned ordinary flight's delay. It must not recover after
// optimistic selection and correction have replaced it (#4365).
for (const frameMs of [5, 30, 80])
  it(`an abandoned ordinary flight of ${frameMs}ms cannot replace correction`, async () => {
    const [s, setS] = createSignal(1);
    const asks: string[] = [];
    const ask = (name: string, v: number) => {
      asks.push(`${name}:${v}`);
      return sleep(name === "m0" && v === 5 ? frameMs : 10).then(() => v);
    };
    const out: string[] = [];
    createRoot(() => {
      const m0 = createMemo(() => ask("m0", 1 + latest(s) + s()));
      const m1 = createMemo(() => ask("m1", 1 + m0()));
      createLoadingBoundary(
        () => {
          createRenderEffect(
            () => `${isPending(m1)},${m1()}`,
            v => void out.push(v)
          );
          return null;
        },
        () => "L"
      );
    });
    flush();
    await settle();
    setS(2);
    for (let i = 0; i < 3; i++) await settle();
    expect(asks).toEqual(["m0:3", "m1:4", "m0:5", "m0:4", "m0:5", "m1:6"]);
    expect(out[0]).toBe("false,4");
    expect(out[out.length - 1]).toBe("false,6");
    expect(out.slice(1, -1).every(v => v.startsWith("true,"))).toBe(true);
  });

// Two latest-derived memos feed a shared async consequence. The second
// input changes while the first input's downstream request remains open.
async function twoVerdicts(grouped: boolean) {
  const [s, setS] = createSignal(1);
  const [t, setT] = createSignal(0);
  const asks: string[] = [];
  const { land, fly } = inFlight();
  const ask = (name: string, v: number) => {
    asks.push(`${name}:${v}`);
    return fly(v);
  };
  const shown = { pending: "", value: "" };
  createRoot(() => {
    const m0 = createMemo(() => ask("m0", 1 + latest(s) + s()));
    const m0b = createMemo(() => ask("m0b", 10 * (latest(t) + t())));
    const m1 = createMemo(() => ask("m1", 1 + m0() + m0b()));
    createLoadingBoundary(
      () => {
        if (grouped)
          createRenderEffect(
            () => [String(isPending(m1)), String(m1())],
            ([p, v]) => void Object.assign(shown, { pending: p, value: v })
          );
        else {
          createRenderEffect(
            () => String(isPending(m1)),
            p => void (shown.pending = p)
          );
          createRenderEffect(
            () => String(m1()),
            v => void (shown.value = v)
          );
        }
        return null;
      },
      () => "L"
    );
  });
  flush();
  await land();
  asks.length = 0;
  // The s write's first flights land, then t is written while the
  // landing's `m1` question is up.
  setS(2);
  flush();
  await land(1);
  setT(1);
  flush();
  await land();
  return { asks, shown };
}

// Repeated questions are limited to input/optimistic/correction changes.
// Grouping pending and value reads does not add more requests.
it("two verdict memos into one async memo: bounded context restarts, grouped or split", async () => {
  const grouped = await twoVerdicts(true);
  const split = await twoVerdicts(false);
  for (const { asks } of [grouped, split])
    expect(asks).toEqual(["m0:5", "m0:4", "m0:5", "m1:6", "m0b:20", "m0b:10", "m0b:20", "m1:26"]);
  expect(grouped.shown).toEqual({ pending: "false", value: "26" });
  expect(split.shown).toEqual(grouped.shown);
});

// #4398 (lane merge) on #4393: with `latest()`'s pass the frame's (R5), the
// grouped reader no longer decides whether the t write merges into the s
// write's transaction or opens its own lane — grouped and split ask the same
// questions (D-25, D-26; F-6: `[isPending(x), x()]` in one render effect
// holds like `x()` alone). Before R5 the grouped reader held `isPending(m1)`
// beside `m1()` in the s write's transaction, the t write merged into it,
// and the t lane's views of `m1` were asked only split.
it("two verdict memos into one async memo: grouped asks the questions split does", async () => {
  const grouped = await twoVerdicts(true);
  const split = await twoVerdicts(false);
  expect(grouped.asks).toEqual(split.asks);
});

// Compare value-only, grouped pending/value, and split bindings. A
// separately observed h preserves the input lifetime; h read only by the
// optimistic consumer loses its observer when that consumer changes context.
type Hold = { land: (rounds?: number) => Promise<void>; release: () => void };
async function heldShapes(
  f: (l: number, v: number) => number,
  script: (setS: (v: number) => void, m0: () => number, hold: Hold) => Promise<void>,
  independent: boolean
) {
  const shown: Record<string, string[]> = {};
  const asked: Record<string, string[]> = {};
  for (const reader of ["value", "pair", "split"] as const) {
    const { land, fly } = inFlight();
    const [s, setS] = createSignal(1);
    const asks: string[] = [];
    const values: string[] = [];
    const ask = (n: string, v: number) => {
      asks.push(`${n}:${v}`);
      return fly(v);
    };
    const show = (v: string) => void (values.at(-1) !== v && values.push(v));
    let m0!: () => number;
    let release!: () => void;
    const dispose = createRoot(dispose => {
      m0 = createMemo(() => ask("m0", f(latest(s), s())));
      const m1 = createMemo(() => ask("m1", 100 + m0()));
      const hold = holder(s);
      const h = hold.h;
      if (independent) createRenderEffect(h, () => {});
      release = hold.release;
      createLoadingBoundary(
        () => {
          if (reader === "pair")
            createRenderEffect(
              () => (h(), [isPending(m1), m1()] as const),
              ([, v]) => show(String(v))
            );
          else if (reader === "split") {
            createRenderEffect(
              () => (h(), isPending(m1)),
              () => {}
            );
            createRenderEffect(
              () => (h(), m1()),
              v => show(String(v))
            );
          } else
            createRenderEffect(
              () => (h(), m1()),
              v => show(String(v))
            );
          return null;
        },
        () => "L"
      );
      return dispose;
    });
    flush();
    await land();
    asks.length = 0;
    await script(setS, m0, { land, release });
    await land();
    release();
    await land();
    dispose();
    shown[reader] = values;
    asked[reader] = asks;
  }
  return { shown, asked };
}

// Preserve the original grouping assertions, and also exercise a separate
// observer of h so its lifetime does not depend on the preview consumer.
it.each([false, true])(
  "held write: grouped and split agree (independent=%s)",
  async independent => {
    const { shown, asked } = await heldShapes(
      (l, v) => 1 + l + v,
      async setS => {
        setS(2);
        flush();
      },
      independent
    );
    expect(shown.value).toEqual(["103", "104", "105"]);
    expect(shown.pair).toEqual(shown.value);
    expect(shown.split).toEqual(shown.value);
    // With `latest()`'s pass the frame's (R5, #4393), the held transaction
    // asks `m0:5` at the write, before the lane's display-ahead `m0:4`.
    for (const a of Object.values(asked))
      expect(a).toEqual(["m0:5", "m0:4", "m1:104", "m0:5", "m1:105"]);
  }
);

it.each([false, true])(
  "held write landing equal: grouped and split agree (independent=%s)",
  async independent => {
    const { shown } = await heldShapes(
      (l, v) => l - v + 3,
      async setS => {
        setS(2);
        flush();
      },
      independent
    );
    expect(shown.value).toEqual(["103", "104", "103"]);
    expect(shown.pair).toEqual(shown.value);
    expect(shown.split).toEqual(shown.value);
  }
);

it.each([false, true])(
  "held write, refresh after settling: grouped and split agree (independent=%s)",
  async independent => {
    const { shown } = await heldShapes(
      (l, v) => 1 + l + v,
      async (setS, m0, { land, release }) => {
        setS(2);
        flush();
        await land();
        release();
        await land();
        refresh(m0);
        flush();
      },
      independent
    );
    expect(shown.value).toEqual(["103", "104", "105"]);
    expect(shown.pair).toEqual(shown.value);
    expect(shown.split).toEqual(shown.value);
  }
);

// The refresh comes once `m0:4` has landed, with the lane's `m1:104` up.
// Before: `m1:104` was asked four times (F-9; D-25, verdict.ts
// `holdWork`).
it.each([false, true])(
  "held write, refresh mid-hold: grouped and split agree (independent=%s)",
  async independent => {
    const { shown, asked } = await heldShapes(
      (l, v) => 1 + l + v,
      async (setS, m0, { land }) => {
        setS(2);
        flush();
        await land(1);
        refresh(m0);
        flush();
      },
      independent
    );
    expect(shown.value).toEqual(["103", "104", "105"]);
    expect(shown.pair).toEqual(shown.value);
    expect(shown.split).toEqual(shown.value);
    // The transaction's `m0:5` at the write first (R5, #4393), then the
    // refresh re-asks both of `m0`'s questions (A19 exc. 2).
    for (const a of Object.values(asked))
      expect(a).toEqual(["m0:5", "m0:4", "m1:104", "m0:4", "m0:5", "m1:105"]);
  }
);

// Extracting latest into a memo does not change the calculation context.
// No independent input hold exists: the optimistic flight is superseded,
// then a later ordinary write supersedes the correction if it is still up.
async function extracted(reader: "value" | "pair" | "split", second: boolean, inline = false) {
  // Flights land only when the test lands them, so the later write always
  // comes while the write's flights are up, at any runner speed.
  const flights: (() => void)[] = [];
  const land = async () => {
    for (let i = 0; i < 8; i++) {
      flights.splice(0).forEach(f => f());
      await sleep(0);
      flush();
    }
  };
  const [s, setS] = createSignal(1);
  const [u, setU] = createSignal(0);
  const asks: string[] = [];
  const values: string[] = [];
  const show = (x: string) => void (values.at(-1) !== x && values.push(x));
  const dispose = createRoot(dispose => {
    const v = inline ? () => latest(s) : createMemo(() => latest(s));
    const m1 = createMemo(() => {
      const q = v() * 10 + s() * 100 + u();
      asks.push(`m1:${q}`);
      return new Promise<number>(r => flights.push(() => r(q)));
    });
    createLoadingBoundary(
      () => {
        if (reader === "pair")
          createRenderEffect(
            () => [isPending(m1), m1()] as const,
            ([, x]) => show(`v${x}`)
          );
        else if (reader === "split") {
          createRenderEffect(
            () => isPending(m1),
            () => {}
          );
          createRenderEffect(m1, x => show(`v${x}`));
        } else createRenderEffect(m1, x => show(`v${x}`));
        return null;
      },
      () => "L"
    );
    return dispose;
  });
  flush();
  await land();
  asks.length = 0;
  setS(2);
  flush();
  if (second) {
    await sleep(0);
    flush();
    setU(5);
    flush();
  }
  await land();
  dispose();
  return { asks, values };
}

for (const reader of ["value", "pair", "split"] as const)
  it(`${reader}: extracted latest has the same eligible flights and publications as inline`, async () => {
    for (const inline of [false, true]) {
      const one = await extracted(reader, false, inline);
      expect(one.asks).toEqual(["m1:220", "m1:120", "m1:220"]);
      expect(one.values).toEqual(["v110", "v220"]);
      const two = await extracted(reader, true, inline);
      expect(two.asks).toEqual(["m1:220", "m1:120", "m1:220", "m1:225"]);
      expect(two.values).toEqual(["v110", "v225"]);
    }
  });

// Dispose and remount a reader during replacement work, optionally followed
// by another input write. A remount must not revive an abandoned answer.
async function remounted(reader: "value" | "pair" | "split", later: boolean) {
  const { land, fly } = inFlight();
  const [s, setS] = createSignal(1);
  const [u, setU] = createSignal(0);
  const asks: string[] = [];
  const out: string[] = [];
  const ask = (n: string, v: number) => {
    asks.push(`${n}:${v}`);
    return fly(v);
  };
  let unmount!: () => void;
  const mount = () =>
    createRoot(d => {
      unmount = d;
      createLoadingBoundary(
        () => {
          const push = (x: string) => void out.push(x);
          if (reader === "pair") createRenderEffect(() => `${isPending(m1)},${m1()}`, push);
          else if (reader === "split") {
            createRenderEffect(() => `p${isPending(m1)}`, push);
            createRenderEffect(() => `v${m1()}`, push);
          } else createRenderEffect(() => `v${m1()}`, push);
          return null;
        },
        () => "L"
      );
    });
  let m1!: () => number;
  let release!: () => void;
  const dispose = createRoot(dispose => {
    const m0 = createMemo(() => ask("m0", 1 + latest(s) + s()));
    m1 = createMemo(() => ask("m1", 1 + m0() + u()));
    release = holder(s).release;
    mount();
    return dispose;
  });
  flush();
  await land();
  asks.length = 0;
  setS(2);
  flush();
  await land(1);
  unmount();
  flush();
  mount();
  flush();
  if (later) setU(5);
  await land();
  release();
  await land();
  unmount();
  dispose();
  return { asks, out };
}

// Remounting cannot revive an expired optimistic answer. The original
// ordinary flight was superseded too; only the final correction may publish.
for (const later of [false, true])
  it(`remounted mid-flight${later ? ", then a write" : ""}: every shape shows the screen, then the landing`, async () => {
    const last = later ? 11 : 6;
    for (const reader of ["value", "pair", "split"] as const) {
      const { asks, out } = await remounted(reader, later);
      expect(asks).toEqual(["m0:5", "m0:4", "m0:5", "m1:6", ...(later ? ["m1:11"] : [])]);
      expect(asks.at(-1)).toBe(`m1:${last}`);
      const values = out
        .map(x => x.slice(x.indexOf(",") + 1).replace(/^[vp]/, ""))
        .filter(x => !/^(true|false)$/.test(x));
      expect(values).not.toContain("5");
      expect(values[0]).toBe("4");
      expect(values.at(-1)).toBe(String(last));
      if (reader === "pair") {
        expect(out[0]).toBe("false,4");
        expect(out.at(-1)).toBe(`false,${last}`);
      } else if (reader === "split") expect(out.filter(x => x[0] === "p").at(-1)).toBe("pfalse");
    }
  });

// Own windows. A memo that calls `isPending()`/`latest()` itself is a verdict
// reader (D-25), whatever it returns: `m1`, async, over
// `${isPending(m0)}:${latest(m0)}` asks at the write with `m0`'s flight up
// (`true:1`), when it lands with the write still pending (`true:2`) and at
// the landing (`false:2`). Under the accepted shared-update lifetime rule,
// the unfinished `true:2` answer cannot keep its input pending. Correction
// supersedes it; no ordinary observer or action keeps that input open here.
it("own window: an async pending/latest answer is superseded when its input finishes", async () => {
  const { land, fly } = inFlight();
  const [s, setS] = createSignal(1);
  const asks: string[] = [];
  const out: string[] = [];
  const dispose = createRoot(dispose => {
    const m0 = createMemo(() => (asks.push(`m0:${s()}`), fly(s())));
    const m1 = createMemo(() => {
      const q = `${isPending(m0)}:${latest(m0)}`;
      asks.push(q);
      return fly(q);
    });
    createLoadingBoundary(
      () => {
        createRenderEffect(m1, v => void out.push(v));
        return null;
      },
      () => "L"
    );
    return dispose;
  });
  flush();
  await land();
  expect(asks).toEqual(["m0:1", "false:1"]);
  expect(out).toEqual(["false:1"]);
  asks.length = 0;
  setS(2);
  flush();
  await land();
  dispose();
  expect(asks).toEqual(["m0:2", "true:1", "true:2", "false:2"]);
  expect(out).toEqual(["false:1", "false:2"]);
});

// An unchanged latest value does not re-ask l1 merely because its input
// started a request. Once latest publishes 2, m1's new request is pending
// until l2 answers; its ordinary displayed value stays 1 in the meantime.
it("own window: an async memo over latest() of an async memo, read with isPending() beside it", async () => {
  const { land, fly } = inFlight();
  const [s, setS] = createSignal(1);
  const asks: string[] = [];
  const out: string[] = [];
  const dispose = createRoot(dispose => {
    const m0 = createMemo(() => (asks.push(`m0:${s()}`), fly(s())));
    const m1 = createMemo(() => {
      const l = latest(m0);
      asks.push(`l${l}`);
      return fly(l);
    });
    createLoadingBoundary(
      () => {
        createRenderEffect(
          () => [isPending(m1), m1()] as const,
          ([p, v]) => void out.push(`${p},${v}`)
        );
        return null;
      },
      () => "L"
    );
    return dispose;
  });
  flush();
  await land();
  expect(asks).toEqual(["m0:1", "l1"]);
  expect(out).toEqual(["false,1"]);
  asks.length = 0;
  setS(2);
  flush();
  await land();
  dispose();
  expect(asks).toEqual(["m0:2", "l2"]);
  expect(out).toEqual(["false,1", "true,1", "false,2"]);
});

// An error is an answer (F-1): after `m1` throws on `m0`'s 5, its pass left
// no flight of its own, so `m0` going pending again re-derives it (D-25,
// verdict.ts `holdWork`). `refresh(m0)` re-asks `m0:5`, `m1` throws again,
// and the boundary keeps the error, never `m1`'s pre-error value as final.
for (const plain of [false, true])
  it(`error, then refresh(m0) to the same answer: ${plain ? "unheld" : "held"}, the error stays`, async () => {
    const { land, fly } = inFlight();
    const [s, setS] = createSignal(1);
    const out: string[] = [];
    let release = () => {};
    let m0!: () => number;
    createRoot(() => {
      m0 = createMemo(() => fly(1 + latest(s) + s()));
      const m1 = createMemo(() => {
        const v = m0();
        if (v === 5) throw new Error("boom");
        return fly(100 + v);
      });
      const h = createMemo(() =>
        plain || s() === 1 ? 1 : new Promise<number>(r => void (release = () => r(1)))
      );
      createErrorBoundary(
        () =>
          createLoadingBoundary(
            () => {
              createRenderEffect(
                () => (h(), `${isPending(m1)},${m1()}`),
                v => void out.push(v)
              );
              return null;
            },
            () => "L"
          ),
        () => (out.push("E"), "E")
      );
    });
    flush();
    await land();
    setS(2);
    flush();
    await land(2);
    release();
    await land();
    const atError = out.length;
    expect(out[atError - 1]).toBe("E");
    refresh(m0);
    flush();
    await land();
    expect(out.slice(atError)).toEqual([]);
  });
