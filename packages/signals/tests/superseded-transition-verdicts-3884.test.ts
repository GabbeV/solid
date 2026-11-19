/**
 * #3884: untracked observations add no subscription, but still select the
 * calculation context. A tracked observation also adds an output dependency:
 * its notification can supersede the computation that started the input's
 * work. This feedback is supported without a tearing exception or diagnostic.
 * Pin each resulting publication timeline rather than assuming that adding
 * a reactive dependency is observationally inert.
 */
import { describe, expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  untrack
} from "../src/index.js";

const tick = () => new Promise(r => setTimeout(r, 0));

type Extra =
  | "nothing"
  | "untracked latest"
  | "untracked isPending"
  | "tracked latest"
  | "tracked isPending";

const EXTRAS: Extra[] = [
  "nothing",
  "untracked latest",
  "untracked isPending",
  "tracked latest",
  "tracked isPending"
];

function readExtra(source: () => string, extra: Extra): void {
  if (extra === "untracked latest") untrack(() => latest(source));
  if (extra === "untracked isPending") untrack(() => isPending(source));
  if (extra === "tracked latest") latest(source);
  if (extra === "tracked isPending") isPending(source);
}

type Checkpoint = {
  label: string;
  effect: string;
  isPending: boolean;
  latest?: string;
};

/** The value the UI effect is showing at this point in the log. */
function effectAt(log: string[], index: number): string {
  let effect = "(none)";
  for (let i = 0; i <= index; i++) {
    const line = log[i];
    if (line.startsWith("effect: ")) effect = line.slice("effect: ".length);
  }
  return effect;
}

function checkpoints(log: string[]): Checkpoint[] {
  const out: Checkpoint[] = [];
  for (let i = 0; i < log.length; i++) {
    const line = log[i];
    if (!line.startsWith("| ")) continue;
    const pending = /isPending=(true|false)/.exec(line);
    const latestMatch = /latest=([^ ]+)/.exec(line);
    if (!pending) throw new Error(`checkpoint missing isPending: ${line}`);
    out.push({
      label: line.slice(2, line.indexOf(":")),
      effect: effectAt(log, i),
      isPending: pending[1] === "true",
      ...(latestMatch ? { latest: latestMatch[1] } : {})
    });
  }
  return out;
}

/**
 * Narrowed repro (rc.14 comment): the parked memo reads `source` directly and
 * the UI effect reads the verdicts directly.
 *
 * Baseline "nothing": effect `/slow1` when A parks, `/slow2` at B's flush,
 * `-` when B lands; outside isPending true from A parked until B lands.
 */
async function runNarrowed(extra: Extra): Promise<string[]> {
  const log: string[] = [];
  const gates: Record<string, PromiseWithResolvers<string>> = {};
  const gate = (k: string) => (gates[k] ??= Promise.withResolvers<string>());
  const [source, setSource] = createSignal("/");

  createRoot(() => {
    const data = createMemo(() => {
      const v = source();
      readExtra(source, extra);
      return v.startsWith("/slow") ? gate(v).promise : v;
    });
    createRenderEffect(data, () => {});
    createRenderEffect(
      () => (isPending(source) ? latest(source) : "-"),
      v => void log.push(`effect: ${v}`)
    );
  });
  flush();
  const cp = (label: string) => log.push(`| ${label}: isPending=${isPending(source)}`);

  setSource("/slow1");
  flush();
  cp("A parked");
  await tick();
  setSource("/slow2");
  flush();
  cp("B flushed");
  await tick();
  cp("B flushed +tick");
  gates["/slow1"].resolve("one");
  await tick();
  cp("A resolved");
  gates["/slow2"].resolve("two");
  await tick();
  cp("B resolved");
  return log;
}

/**
 * Original repro: a `path` memo between source and the parked memo, and the
 * effect behind a `target` memo.
 *
 * Baseline "nothing": effect shows `/slow2` at B's flush; outside isPending
 * true while B is parked.
 */
async function runOriginal(extra: Extra): Promise<string[]> {
  const log: string[] = [];
  const gates: Record<string, PromiseWithResolvers<string>> = {};
  const gate = (k: string) => (gates[k] ??= Promise.withResolvers<string>());
  const [source, setSource] = createSignal("/");

  createRoot(() => {
    const path = createMemo(() => source());
    const data = createMemo(() => {
      const v = path();
      readExtra(source, extra);
      return v.startsWith("/slow") ? gate(v).promise : v;
    });
    createRenderEffect(data, () => {});
    const target = createMemo(() => (isPending(source) ? latest(source) : "-"));
    createRenderEffect(target, v => void log.push(`effect: ${v}`));
  });
  flush();
  const cp = (label: string) =>
    log.push(`| ${label}: isPending=${isPending(source)} latest=${latest(source)}`);

  setSource("/slow1");
  flush();
  cp("A parked");
  await tick();
  setSource("/slow2");
  flush();
  cp("B flushed");
  await tick();
  cp("B flushed +tick");
  gates["/slow1"].resolve("one");
  await tick();
  cp("A resolved");
  gates["/slow2"].resolve("two");
  await tick();
  cp("B resolved");
  return log;
}

/** Baselines for the graph without a subscribed observation inside data. */
const NARROWED: Checkpoint[] = [
  { label: "A parked", effect: "/slow1", isPending: true },
  { label: "B flushed", effect: "/slow2", isPending: true },
  { label: "B flushed +tick", effect: "/slow2", isPending: true },
  { label: "A resolved", effect: "/slow2", isPending: true },
  { label: "B resolved", effect: "-", isPending: false }
];

const ORIGINAL: Checkpoint[] = [
  { label: "A parked", effect: "/slow1", isPending: true, latest: "/slow1" },
  { label: "B flushed", effect: "/slow2", isPending: true, latest: "/slow2" },
  { label: "B flushed +tick", effect: "/slow2", isPending: true, latest: "/slow2" },
  { label: "A resolved", effect: "/slow2", isPending: true, latest: "/slow2" },
  { label: "B resolved", effect: "-", isPending: false, latest: "/slow2" }
];

function expected(extra: Extra, original: boolean): Checkpoint[] {
  const baseline = original ? ORIGINAL : NARROWED;
  if (extra === "tracked latest") {
    // The latest proposal's own derivation keeps it held. Ordinary source
    // reads in that higher computation use the committed '/' frame. In the
    // original shape, target combines both peer proposals in a memo: pending
    // waits with latest. A direct render binding uses their published values
    // independently. See unified-observation-peer-publication for the same
    // distinction with explicit optimistic boundaries and no feedback.
    return baseline.map((checkpoint, index) =>
      index === baseline.length - 1
        ? checkpoint
        : {
            ...checkpoint,
            effect: original ? "-" : "/",
            ...(original ? { latest: "/", isPending: false } : {})
          }
    );
  }
  if (extra === "untracked latest") {
    // A's initial pass precedes latest's notification, which is untracked.
    // The ordinary B write reruns data; its latest read now selects the
    // higher context. Preparation then starts B's incoming request. That
    // work holds the replacement latest output, so A remains visible until B
    // completes. The producer's obsolete A answer never reaches the display.
    return baseline.map((checkpoint, index) =>
      index === baseline.length - 1
        ? checkpoint
        : { ...checkpoint, effect: "/slow1", ...(original ? { latest: "/slow1" } : {}) }
    );
  }
  if (extra === "tracked isPending") {
    // Pending=true supersedes the blocking pass with one over committed
    // source. The input can publish; pending's reversal then starts its
    // consequence again. The source itself is no longer unpublished.
    return baseline.map(checkpoint => ({ ...checkpoint, effect: "-", isPending: false }));
  }
  return baseline;
}

describe("#3884 superseded-transition verdicts", () => {
  describe("narrowed repro", () => {
    for (const extra of EXTRAS) {
      it(`${extra} publishes its coherent feedback timeline`, async () => {
        const log = await runNarrowed(extra);
        expect(checkpoints(log), log.join(" ; ")).toEqual(expected(extra, false));
      });
    }
  });

  describe("original repro", () => {
    for (const extra of EXTRAS) {
      it(`${extra} publishes its coherent feedback timeline`, async () => {
        const log = await runOriginal(extra);
        expect(checkpoints(log), log.join(" ; ")).toEqual(expected(extra, true));
      });
    }
  });
});
