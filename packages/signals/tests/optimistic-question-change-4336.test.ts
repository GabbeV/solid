/**
 * #4336: changing the input question while a posting override is active.
 * A structural store answer joins the incoming update to the posting action;
 * it cannot remove unguessed indices before the selected append retires.
 * Scalar guesses retain their whole-value boundary. Every ordinary store
 * derivation, descriptor, presence read and For view must agree throughout.
 */
import { afterEach, describe, expect, it } from "vitest";
import {
  action,
  createEffect,
  createMemo,
  createOptimistic,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  mapArray,
  refresh,
  resetErrorHalt
} from "../src/index.js";

/** Every gate a test opened: settled after it, so an action a failing test
 * left open does not hold the next test's frames. */
const gates: Array<() => void> = [];
const disposals: Array<() => void> = [];
afterEach(async () => {
  for (const dispose of disposals.splice(0)) dispose();
  for (let g; (g = gates.pop()); ) g();
  await tick();
  resetErrorHalt();
  flush();
});

const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
const defer = <T = void>() => {
  let res!: (v: T) => void;
  let rej!: (e: unknown) => void;
  const p = new Promise<T>((a, b) => {
    res = a;
    rej = b;
  });
  gates.push(() => res([] as T));
  return { p, res, rej };
};

type Comment = { id: string; text: string };
type Ask = { id: number; d: ReturnType<typeof defer<any>> };
type Form = "signal" | "store-draft" | "store-return";

type StoreLayout = {
  length: number;
  keys: string[];
  own: boolean[];
  present: boolean[];
  descriptors: string[];
  entries: string[];
  native: string[];
  absentValues: boolean[];
};
type StorePublication = {
  pair?: [string, string];
  layout?: StoreLayout;
  forView?: string;
};

/** The issue's graph. `form` picks the optimistic primitive; `reader` the
 * screen: one render effect reading both, a user effect (the issue's), or
 * two render effects (`#sel` and the comments, recorded as one frame each
 * time either applies). `optimisticSel`: `sel` is a `createOptimistic` over
 * the saved selection (`setSelTruth`), guessed inside its own action. */
function setup(form: Form, reader: "render" | "user" | "split" = "render", optimisticSel = false) {
  const asks: Ask[] = [];
  const frames: string[] = [];
  const outputFrames: [string, string][] = [];
  const storePublications: StorePublication[] = [];
  let active = true;
  let pair: [string, string] | undefined, layout: StoreLayout | undefined;
  let shownCells: { text?: string }[] | undefined;
  const captureStore = () => {
    if (form === "signal") return;
    queueMicrotask(() => {
      if (!active || (!pair && !layout && !shownCells)) return;
      storePublications.push({
        pair,
        layout,
        forView:
          shownCells &&
          Array.from({ length: shownCells.length }, (_, i) =>
            Object.hasOwn(shownCells!, i) ? (shownCells![i]?.text ?? "<uninitialized>") : "<absent>"
          ).join(" | ")
      });
    });
  };
  const publish = (value: [string, string]) => {
    pair = value;
    outputFrames.push(value);
    captureStore();
  };
  let server!: ReturnType<typeof defer<unknown>>;
  let setSel!: (v: number) => void;
  let setSelTruth!: (v: number) => void;
  let post!: (text: string) => Promise<void>;
  let comments!: any;
  let sel!: () => number;
  let view!: () => string;
  let guess!: (text: string) => void;
  createRoot(dispose => {
    disposals.push(() => {
      active = false;
      dispose();
    });
    const [saved, setSaved] = createSignal(3);
    const [s, ss] = optimisticSel ? createOptimistic(() => saved()) : [saved, setSaved];
    sel = s;
    setSel = ss;
    setSelTruth = setSaved;
    const ask = () => {
      const id = sel();
      const d = defer<any>();
      asks.push({ id, d });
      return d.p;
    };
    if (form === "signal") {
      const [c, set] = createOptimistic<string[]>(async () => ask());
      comments = c;
      view = () => c().join(" | ");
      guess = text => set(v => [...v, `${text} (sending)`]);
    } else {
      const [c, set] = createOptimisticStore<Comment[]>(async d => {
        const rows: string[] = await ask();
        const list = rows.map(text => ({ id: text, text }));
        if (form === "store-return") return list;
        d.length = 0;
        d.push(...list);
      }, []);
      comments = c;
      const forRows = mapArray(
        () => c,
        row => {
          const cell: { text?: string } = {};
          createRenderEffect(
            () => row?.text ?? "<absent>",
            text => {
              cell.text = text;
              captureStore();
            }
          );
          return cell;
        }
      );
      createRenderEffect(forRows, cells => {
        shownCells = cells;
        captureStore();
      });
      createRenderEffect(
        () => {
          const length = c.length,
            keys = Object.keys(c);
          const own: boolean[] = [],
            present: boolean[] = [],
            descriptors: string[] = [],
            entries: string[] = [],
            absentValues: boolean[] = [];
          for (let i = 0; i < length; i++) {
            const exists = Object.hasOwn(c, i),
              descriptor = Object.getOwnPropertyDescriptor(c, i);
            const value = c[i];
            own.push(exists);
            present.push(i in c);
            descriptors.push(descriptor ? (descriptor.value?.text ?? "<undefined>") : "<absent>");
            entries.push(exists ? (value?.text ?? "<undefined>") : "<absent>");
            absentValues.push(exists || value === undefined);
          }
          const mapped = c.map(row => row?.text ?? "<undefined>");
          const native = Array.from({ length: mapped.length }, (_, i) =>
            Object.hasOwn(mapped, i) ? mapped[i] : "<absent>"
          );
          return { length, keys, own, present, descriptors, entries, native, absentValues };
        },
        value => {
          layout = value;
          captureStore();
        }
      );
      // Distinguish an actual missing own index from a present undefined value.
      view = () =>
        Array.from({ length: c.length }, (_, i) =>
          Object.hasOwn(c, i) ? (c[i]?.text ?? "<undefined>") : "<absent>"
        ).join(" | ");
      guess = text =>
        set(d => {
          d.push({ id: `tmp-${text}`, text: `${text} (sending)` });
        });
    }
    const derived = createMemo(() => view().toUpperCase());
    if (reader === "split") {
      // One frame per flush: both effects' latest values, sampled once the
      // flush that applied them is over.
      let a = "";
      let b = "";
      let queued = false;
      const sample = () => {
        if (queued) return;
        queued = true;
        queueMicrotask(() => {
          queued = false;
          frames.push(`${a} ${b}`);
        });
      };
      createRenderEffect(
        () => `#${sel()}:`,
        v => ((a = v), sample())
      );
      createRenderEffect(
        () => [view(), derived()] as [string, string],
        pair => {
          publish(pair);
          b = pair[0];
          sample();
        }
      );
    } else
      (reader === "user" ? createEffect : createRenderEffect)(
        () => [`#${sel()}: ${view()}`, view(), derived()] as const,
        ([frame, value, consequence]) => {
          frames.push(frame);
          publish([value, consequence]);
        }
      );
    post = action(function* (text: string) {
      guess(text);
      server = defer();
      try {
        yield server.p;
        refresh(comments);
      } catch (e) {}
    });
  });
  const read = (): string[] => (form === "signal" ? comments() : comments.map((r: any) => r.text));
  return {
    asks,
    frames,
    outputFrames,
    storePublications,
    setSel,
    setSelTruth,
    post,
    get comments() {
      return comments;
    },
    get server() {
      return server;
    },
    sel: () => sel(),
    view,
    read,
    guess: (text: string) => guess(text),
    screen: () => frames[frames.length - 1]
  };
}

function expectCoherentOutput(h: ReturnType<typeof setup>) {
  expect(h.outputFrames.length).toBeGreaterThan(0);
  for (const [value, consequence] of h.outputFrames) {
    expect(value).not.toContain("<undefined>");
    expect(value).not.toContain("<absent>");
    expect(consequence).toBe(value.toUpperCase());
  }
  for (const publication of h.storePublications) {
    const { pair, layout, forView } = publication;
    expect(layout).toBeDefined();
    expect(pair).toBeDefined();
    const value = layout!.entries.join(" | ");
    expect(pair![0]).toBe(value);
    expect(pair![1]).toBe(value.toUpperCase());
    expect(forView).toBe(value);
    expect(layout!.native).toEqual(layout!.entries);
    expect(layout!.descriptors).toEqual(layout!.entries);
    expect(layout!.present).toEqual(layout!.own);
    expect(layout!.absentValues.every(Boolean)).toBe(true);
    expect(layout!.length).toBe(layout!.entries.length);
    expect(layout!.keys).toEqual(layout!.own.flatMap((own, i) => (own ? [String(i)] : [])));
    expect(value).not.toContain("<undefined>");
    expect(value).not.toContain("<absent>");
  }
}

function expectDenseCorrection(h: ReturnType<typeof setup>, from: number) {
  for (const [value] of h.outputFrames.slice(from)) {
    expect(value).not.toContain("<absent>");
    expect(value).not.toContain("<undefined>");
  }
}

/** Keyed views and same-action input changes still pair resource identity. */
const torn = (frames: string[]) =>
  frames.filter(
    f =>
      f.includes("<absent>") ||
      f.includes("<undefined>") ||
      (f.startsWith("#1:") && (f.includes("dana") || f.includes("sending")))
  );

async function primed(form: Form, reader?: "render" | "user" | "split", optimisticSel?: boolean) {
  const h = setup(form, reader, optimisticSel);
  await tick();
  h.asks[0].d.res(["dana"]);
  await tick();
  expect(h.screen()).toBe("#3: dana");
  h.post("mine");
  await tick();
  expect(h.screen()).toBe("#3: dana | mine (sending)");
  return h;
}

const beforeIndependentAnswer = (form: Form) =>
  form === "signal" ? "#1: dana | mine (sending)" : "#3: dana | mine (sending)";
const afterIndependentEmptyAnswer = (form: Form) =>
  form === "signal" ? "#1: dana | mine (sending)" : "#3: dana | mine (sending)";
const expectSelectedAfterEmptyAnswer = (h: ReturnType<typeof setup>, form: Form) => {
  expect(h.read()).toStrictEqual(["dana", "mine (sending)"]);
  if (form !== "signal") {
    expect(h.comments.length).toBe(2);
    expect(Object.keys(h.comments)).toEqual(["0", "1"]);
    expect(Object.hasOwn(h.comments, 0)).toBe(true);
    expect(0 in h.comments).toBe(true);
    expect(h.comments[0].text).toBe("dana");
    expect(Object.hasOwn(h.comments, 1)).toBe(true);
    expect(1 in h.comments).toBe(true);
    expect(h.comments[1].text).toBe("mine (sending)");
  }
};

const forms = ["signal", "store-draft", "store-return"] as const;

for (const form of forms) {
  describe(`#4336 the question changes under an independent override (${form})`, () => {
    for (const reader of ["render", "split"] as const)
      it(`an incoming structural answer waits for the store post (${reader})`, async () => {
        const h = await primed(form, reader);

        // A new question belongs to its own update, outside the posting action.
        h.setSel(1);
        await tick();
        expect(h.asks.at(-1)!.id).toBe(1);
        expect(h.screen()).toBe(beforeIndependentAnswer(form));

        // Structural removal holds the dense selected array until the action closes.
        h.asks.at(-1)!.d.res([]);
        await tick();
        expect(h.screen()).toBe(afterIndependentEmptyAnswer(form));
        expectSelectedAfterEmptyAnswer(h, form);

        // The post settles; its refresh re-asks issue 1; the landing reveals.
        h.server.res({});
        await tick();
        expect(h.screen()).toBe(afterIndependentEmptyAnswer(form));
        expectSelectedAfterEmptyAnswer(h, form);
        expect(h.asks.at(-1)!.id).toBe(1);
        const correctionStart = h.outputFrames.length;
        h.asks.at(-1)!.d.res(["mine"]);
        await tick();
        expectDenseCorrection(h, correctionStart);
        expect(h.screen()).toBe("#1: mine");
        expectCoherentOutput(h);
      });

    // User effects obey the same output/derivation consistency.
    it("a user effect observes the independent input and coherent output", async () => {
      const h = await primed(form, "user");
      h.setSel(1);
      await tick();
      // Structural removal holds the dense selected array until the action closes.
      h.asks.at(-1)!.d.res([]);
      await tick();
      expect(h.screen()).toBe(afterIndependentEmptyAnswer(form));
      expectSelectedAfterEmptyAnswer(h, form);
      h.server.res({});
      await tick();
      const correctionStart = h.outputFrames.length;
      h.asks.at(-1)!.d.res(["mine"]);
      await tick();
      expectDenseCorrection(h, correctionStart);
      expect(h.screen()).toBe("#1: mine");
      expectCoherentOutput(h);
    });

    it("pending follows the input flight; latest observes the selected output", async () => {
      const h = await primed(form);
      // A ready override alone has no pending input question.
      expect(isPending(h.read)).toBe(false);

      h.setSel(1);
      await tick();
      expect(isPending(h.read)).toBe(true);
      expect(latest(h.sel)).toBe(1);

      // Structural removal holds the dense selected array until the action closes.
      h.asks.at(-1)!.d.res([]);
      await tick();
      expect(isPending(h.read)).toBe(form !== "signal");
      // latest observes the selected output layer, whose active append still
      // requires the coherent dense array while the structural removal waits.
      const expected = ["dana", "mine (sending)"];
      expect(latest(h.read)).toStrictEqual(expected);
      // Untracked reads see the screen (D-34).
      expectSelectedAfterEmptyAnswer(h, form);

      h.server.res({});
      await tick();
      // A structural store answer remains pending through the joined refresh.
      expect(isPending(h.read)).toBe(form !== "signal");
      const correctionStart = h.outputFrames.length;
      h.asks.at(-1)!.d.res(["mine"]);
      await tick();
      expectDenseCorrection(h, correctionStart);
      expect(isPending(h.read)).toBe(false);
      expect(h.read()).toEqual(["mine"]);
      expect(latest(h.read)).toEqual(["mine"]);
      expect(h.screen()).toBe("#1: mine");
      expectCoherentOutput(h);
    });

    // Confirming the lower selection does not shorten the posting lifetime;
    // a structural store answer retains the old selection until correction.
    for (const reader of ["render", "split"] as const)
      it(`an optimistic input respects the structural store hold (F-6, F-11; ${reader})`, async () => {
        const h = await primed(form, reader, true);
        const go = defer();
        action(function* () {
          h.setSel(1);
          yield go.p;
          h.setSelTruth(1);
        })();
        await tick();
        expect(h.asks.at(-1)!.id).toBe(1);
        // Store structure retains the input dependency until the post settles.
        expect(h.screen()).toBe(beforeIndependentAnswer(form));
        // Structural removal holds the dense selected array until the action closes.
        h.asks.at(-1)!.d.res([]);
        await tick();
        expect(h.screen()).toBe(afterIndependentEmptyAnswer(form));
        expectSelectedAfterEmptyAnswer(h, form);
        go.res();
        await tick();
        for (const a of h.asks) if (a.id === 1) a.d.res([]);
        await tick();
        expect(h.screen()).toBe(afterIndependentEmptyAnswer(form));
        expectSelectedAfterEmptyAnswer(h, form);
        h.server.res({});
        await tick();
        const correctionStart = h.outputFrames.length;
        h.asks.at(-1)!.d.res(["mine"]);
        await tick();
        expectDenseCorrection(h, correctionStart);
        expect(h.screen()).toBe("#1: mine");
        expectCoherentOutput(h);
      });

    // Reversing the lower override also leaves the upper override selected.
    // The restored selection publishes without waiting for the masked input.
    for (const reader of ["render", "split"] as const) {
      const pureRevert = async () => {
        const h = await primed(form, reader, true);
        const go = defer();
        action(function* () {
          h.setSel(1);
          yield go.p;
        })();
        await tick();
        // Structural removal holds the dense selected array until the action closes.
        h.asks.at(-1)!.d.res([]);
        await tick();
        expect(h.screen()).toBe(afterIndependentEmptyAnswer(form));
        expectSelectedAfterEmptyAnswer(h, form);
        const from = h.frames.length;
        go.res();
        await tick();
        expect(h.asks.at(-1)!.id).toBe(3);
        expect(h.screen()).toBe("#3: dana | mine (sending)");
        h.asks.at(-1)!.d.res(["dana"]);
        await tick();
        expect(h.screen()).toBe("#3: dana | mine (sending)");
        return { h, from };
      };
      it(`an optimistic input that reverts preserves the post's guess (F-11, D-33; ${reader})`, async () => {
        const { h, from } = await pureRevert();
        expect(h.screen()).toBe("#3: dana | mine (sending)");
        // Store structure held the old selection throughout, so restoring its
        // question leaves the existing screen intact without another callback.
        // The scalar selection did publish #1 and must publish #3 on reversal.
        expect(new Set(h.frames.slice(from))).toEqual(
          new Set(form === "signal" ? ["#3: dana | mine (sending)"] : [])
        );
        expect(h.read()).toEqual(["dana", "mine (sending)"]);
        expectCoherentOutput(h);
      });
      it(`an optimistic input that reverts: the post still lands as one frame (${reader})`, async () => {
        const { h, from } = await pureRevert();
        h.server.res({});
        await tick();
        expect(h.screen()).toBe("#3: dana | mine (sending)");
        expect(h.asks.at(-1)!.id).toBe(3);
        const correctionStart = h.outputFrames.length;
        h.asks.at(-1)!.d.res(["dana", "mine"]);
        await tick();
        expectDenseCorrection(h, correctionStart);
        expect(h.screen()).toBe("#3: dana | mine");
        expect(new Set(h.frames.slice(from))).toEqual(
          new Set(
            form === "signal"
              ? ["#3: dana | mine (sending)", "#3: dana | mine"]
              : ["#3: dana | mine"]
          )
        );
        expectCoherentOutput(h);
      });
    }

    it("control: a refresh() re-ask of the same question keeps the guess until the commit (D-34, #4329)", async () => {
      const h = await primed(form);
      refresh(h.comments);
      await tick();
      expect(h.asks.at(-1)!.id).toBe(3);
      expect(h.screen()).toBe("#3: dana | mine (sending)");
      expect(isPending(h.read)).toBe(false);
      h.asks.at(-1)!.d.res(["dana"]);
      await tick();
      expect(h.screen()).toBe("#3: dana | mine (sending)");

      h.server.res({});
      await tick();
      expect(h.screen()).toBe("#3: dana | mine (sending)");
      const correctionStart = h.outputFrames.length;
      h.asks.at(-1)!.d.res(["dana", "mine"]);
      await tick();
      expectDenseCorrection(h, correctionStart);
      expect(h.screen()).toBe("#3: dana | mine");
      expect(h.frames.slice(1)).not.toContain("#3: dana");
      expectCoherentOutput(h);
    });

    it("control: the guess's own action changing the question keeps the guess until its commit (D-34)", async () => {
      const h = setup(form);
      await tick();
      h.asks[0].d.res(["dana"]);
      await tick();
      const go = defer();
      const done = defer();
      action(function* () {
        h.guess("mine");
        yield go.p;
        h.setSel(1);
        yield done.p;
      })();
      await tick();
      expect(h.screen()).toBe("#3: dana | mine (sending)");

      go.res();
      await tick();
      expect(h.asks.at(-1)!.id).toBe(1);
      expect(h.screen()).toBe("#3: dana | mine (sending)");
      h.asks.at(-1)!.d.res([]);
      await tick();
      // The action's own question: a different truth corrects at the commit.
      expect(h.screen()).toBe("#3: dana | mine (sending)");
      done.res();
      await tick();
      expect(h.screen()).toBe("#1: ");
      expect(torn(h.frames)).toEqual([]);
      expectCoherentOutput(h);
    });
  });
}

describe("#4336 keyed store: a new question that writes another key", () => {
  // A store's derive is one node asking one question for every key; what
  // holds is a frame still reading a guess at the seam. Key 1 carries none,
  // so `sel` waits for issue 1's answer (F-2), not for the post; back on key
  // 3 the guess shows once issue 3's answer is in.
  it("does not wait for the post; switching back shows the guess", async () => {
    const asks: Ask[] = [];
    const frames: string[] = [];
    let server!: ReturnType<typeof defer<unknown>>;
    let setSel!: (v: number) => void;
    let post!: () => Promise<void>;
    createRoot(dispose => {
      disposals.push(dispose);
      const [sel, ss] = createSignal(3);
      setSel = ss;
      const [comments, set] = createOptimisticStore<Record<number, string[]>>(async d => {
        const id = sel();
        const p = defer<string[]>();
        asks.push({ id, d: p });
        const rows = await p.p;
        d[id] = rows;
      }, {});
      createRenderEffect(
        () => `#${sel()}: ${(comments[sel()] ?? []).join(" | ")}`,
        v => void frames.push(v)
      );
      post = action(function* () {
        set(d => {
          d[3].push("mine (sending)");
        });
        server = defer();
        yield server.p;
        refresh(comments);
      });
    });
    await tick();
    asks[0].d.res(["dana"]);
    await tick();
    expect(frames.at(-1)).toBe("#3: dana");
    post();
    await tick();
    expect(frames.at(-1)).toBe("#3: dana | mine (sending)");

    setSel(1);
    await tick();
    expect(asks.at(-1)!.id).toBe(1);
    asks.at(-1)!.d.res([]);
    await tick();
    // `sel` may wait for issue 1's answer, but not for the post.
    expect(frames.at(-1)).toBe("#1: ");

    setSel(3);
    await tick();
    if (asks.at(-1)!.id === 3) {
      asks.at(-1)!.d.res(["dana"]);
      await tick();
    }
    expect(frames.at(-1)).toBe("#3: dana | mine (sending)");

    server.res({});
    await tick();
    expect(asks.at(-1)!.id).toBe(3);
    asks.at(-1)!.d.res(["dana", "mine"]);
    await tick();
    expect(frames.at(-1)).toBe("#3: dana | mine");
    expect(torn(frames)).toEqual([]);
    expect(frames.filter(f => f.startsWith("#3:") && f.includes("sending"))).not.toContain(
      "#3: dana"
    );
  });
});
