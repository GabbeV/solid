/**
 * #4544: a held session update opens a branch whose params also depend on
 * pending/latest observations. The old DOM stays visible while preparation
 * and creator retries run. A retry can close the private branch on committed
 * session, so its previous private params need not refresh until preparation
 * resumes. The final published branch always uses complete incoming params.
 * See the stage-141 context rule and stage-172 creator-retry rule.
 */
import { expect, it } from "vitest";
import {
  createLoadingBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  untrack
} from "../src/index.js";

const tick = async () => {
  for (let i = 0; i < 8; i++) await Promise.resolve();
  flush();
};

type Probe = "plain read" | "isPending" | "latest" | "inline isPending" | "same-node isPending";
type Params = { plan: boolean; signedIn: boolean; busy?: boolean };

function page(probe: Probe) {
  const [session, setSession] = createSignal<string | undefined>(undefined);
  const [plan, setPlan] = createSignal(false);
  const [gate, setGate] = createSignal(0);
  let release: () => void = () => {};
  let screen = "";
  const branchSaw: Params[] = [];
  const chromeSaw: boolean[] = [];
  let signedOutIssued = false;
  const dispose = createRoot(dispose => {
    const held = createMemo(() => {
      const g = gate();
      return g === 0 ? g : new Promise<number>(r => (release = () => r(g)));
    });
    const out = createLoadingBoundary(
      () => {
        const chrome = createMemo(() => {
          const v =
            probe === "isPending"
              ? (isPending(plan), plan())
              : probe === "latest"
                ? latest(plan)
                : plan();
          chromeSaw.push(v);
          return v;
        });
        const params = createMemo(() =>
          probe === "same-node isPending"
            ? { plan: plan(), signedIn: session() !== undefined, busy: isPending(session) }
            : {
                plan: probe === "inline isPending" ? (isPending(plan), plan()) : chrome(),
                signedIn: session() !== undefined
              }
        );
        const signedOutOnly = createMemo(
          () => {
            signedOutIssued = true;
            return new Promise<never>(() => {});
          },
          { lazy: true }
        );
        const cond = createMemo(() => session() !== undefined);
        const show = createMemo(() => {
          if (!cond()) return "signed out";
          return untrack(() => {
            let text = "";
            createRenderEffect(
              () => {
                const p = params();
                branchSaw.push(p);
                return p.signedIn ? "rows" : signedOutOnly();
              },
              v => {
                text = v as string;
              }
            );
            return () => text;
          });
        });
        return createMemo(() => {
          const h = held();
          let s: unknown = show();
          while (typeof s === "function") s = s();
          return `${h} ${s}`;
        });
      },
      () => "root"
    );
    createRenderEffect(
      () => {
        let v: unknown = out;
        while (typeof v === "function") v = v();
        return v;
      },
      v => {
        screen = v as string;
      }
    );
    return dispose;
  });
  return {
    dispose,
    screen: () => screen,
    branchSaw,
    chromeSaw,
    setSession,
    setPlan,
    setGate,
    release: () => release(),
    signedOutIssued: () => signedOutIssued
  };
}

type Shape = "split" | "one";
/** `split`: the hold's writes in one `flush()`, `plan`'s in the next. `one`:
 * all three in one `flush()`. */
function write(p: ReturnType<typeof page>, shape: Shape) {
  p.setGate(1);
  p.setSession("acc");
  if (shape === "split") flush();
  p.setPlan(true);
  flush();
}

for (const shape of ["split", "one"] as Shape[]) {
  for (const probe of ["plain read", "isPending", "latest"] as Probe[])
    it(`${probe} upstream of a held branch (${shape} flush): the branch reads the hold's session and the hold lands`, async () => {
      const p = page(probe);
      try {
        flush();
        expect(p.screen()).toBe("0 signed out");
        write(p, shape);
        // Preparation supplies the new branch's complete incoming params.
        // This calculation does not reveal the branch before the gate.
        expect(p.branchSaw.at(-1)).toMatchObject({
          plan: true,
          signedIn: true
        });
        expect(p.screen()).toBe("0 signed out");
        p.release();
        await tick();
        await tick();
        expect(p.screen()).toBe("1 rows");
      } finally {
        p.dispose();
      }
    });

  for (const probe of ["inline isPending", "same-node isPending"] as Probe[])
    it(`${probe} in params (${shape} flush): private params stay coherent while publication waits`, async () => {
      const p = page(probe);
      try {
        flush();
        write(p, shape);
        // A same-node pending observation can retry the private creator and
        // close its branch on committed session. The previous private plan
        // remains until ordinary preparation resumes; it is never displayed.
        expect(p.branchSaw.at(-1)).toMatchObject({
          plan: !(probe === "same-node isPending" && shape === "split"),
          signedIn: true
        });
        expect(p.screen()).toBe("0 signed out");
        p.release();
        for (let i = 0; i < 4; i++) await tick();
        // The gate releases the whole signed-in frame, including params.
        expect(p.branchSaw.at(-1)).toEqual(
          probe === "inline isPending"
            ? { plan: true, signedIn: true }
            : { plan: true, signedIn: true, busy: false }
        );
        expect(p.screen()).toBe("1 rows");
      } finally {
        p.dispose();
      }
    });
}

// An earlier latest observation must not change the next update's context.
// The new plan-pending output can publish independently of held x=2. Its
// params calculation therefore reads committed x=1, whether x was observed
// in the earlier update or not. The x update's eventual frame still uses 2.
for (const shape of ["split", "one"] as Shape[])
  for (const probed of [false, true])
    it(`a probe under an earlier hold leaves no mark on the next (${probed ? "probed" : "never probed"}, ${shape} flush)`, async () => {
      const [x, setX] = createSignal(0);
      const [plan, setPlan] = createSignal(false);
      const [gate, setGate] = createSignal(0);
      const [ask, setAsk] = createSignal(probed);
      let release: () => void = () => {};
      const saw: number[] = [];
      let screen = "";
      const dispose = createRoot(d => {
        const held = createMemo(() => {
          const g = gate();
          return g === 0 ? g : new Promise<number>(r => (release = () => r(g)));
        });
        const asker = createMemo(() => (ask() ? latest(x) : -1));
        const chrome = createMemo(() => (isPending(plan), plan()));
        const params = createMemo(() => {
          chrome();
          const v = x();
          saw.push(v);
          return v;
        });
        createRenderEffect(
          () => `${held()} ${params()} ${asker()}`,
          v => void (screen = v)
        );
        return d;
      });
      try {
        flush();
        expect(screen).toBe(`0 0 ${probed ? 0 : -1}`);
        // Hold 1: `x` = 1, asked of while held when `probed`.
        setGate(1);
        setX(1);
        flush();
        release();
        await tick();
        await tick();
        expect(screen).toBe(`1 1 ${probed ? 1 : -1}`);
        setAsk(false);
        flush();
        expect(screen).toBe("1 1 -1");
        // Hold 2: the plan observation selects committed x in either case.
        setGate(2);
        setX(2);
        if (shape === "split") flush();
        setPlan(true);
        flush();
        expect(saw.at(-1)).toBe(1);
        expect(screen).toBe("1 1 -1");
        release();
        await tick();
        await tick();
        expect(screen).toBe("2 2 -1");
        expect(saw.at(-1)).toBe(2);
      } finally {
        dispose();
      }
    });
