// #4677 requires coherent publication of pending and its async derivation.
// Experiment ruling: unfinished optimistic work does not extend the lifetime
// of the optimism. When details finish, supersede the pending-true badge and
// start correction immediately; keep the displayed frame until correction is
// ready. If the pending badge finishes first, reveal it with pending instead.
import { describe, expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";

const tick = async () => {
  for (let i = 0; i < 8; i++) await Promise.resolve();
  flush();
};

function setup(between = false) {
  const [id, setId] = createSignal(0);
  const details: Array<() => void> = [];
  const badges: Array<{ text: string; resolve: () => void }> = [];
  const screen = { id: "", details: "", pending: "", badge: "" };
  const frames: string[] = [];
  const publications = {
    id: [] as string[],
    details: [] as string[],
    pending: [] as string[],
    badge: [] as string[]
  };
  const dispose = createRoot(dispose => {
    const detailsMemo = createMemo(() => {
      const i = id();
      if (i === 0) return "Item 0";
      return new Promise<string>(r => details.push(() => r(`Item ${i}`)));
    });
    const badge = createMemo(() => {
      const i = id();
      const p = isPending(id);
      const text = `ID: ${i}, pending: ${p}`;
      if (i === 0 && !p) return text;
      return new Promise<string>(r => badges.push({ text, resolve: () => r(text) }));
    });
    const bind = (k: keyof typeof screen, fn: () => unknown) =>
      createRenderEffect(fn, v => {
        screen[k] = String(v);
        publications[k].push(String(v));
      });
    bind("id", id);
    // A plain memo between the landed node and its binding: still the
    // landing's frame.
    bind("details", between ? createMemo(() => `${detailsMemo()}`) : detailsMemo);
    bind("pending", () => isPending(id));
    bind("badge", badge);
    return dispose;
  });
  flush();
  const frame = () =>
    `id ${screen.id} | ${screen.details} | pending ${screen.pending} | ${screen.badge}`;
  const snap = () => frames.push(frame());
  return { setId, details, badges, frames, snap, publications, dispose };
}

const initial = "id 0 | Item 0 | pending false | ID: 0, pending: false";
const pending = "id 0 | Item 0 | pending true | ID: 0, pending: true";
const final = "id 1 | Item 1 | pending false | ID: 1, pending: false";

describe("#4677 isPending beside an async memo derived from it", () => {
  for (const between of [false, true]) {
    it.each([false, true])(
      `publishes whole frames without waiting for obsolete optimism (details first: %s, memo between: ${between})`,
      async detailsFirst => {
        const t = setup(between);
        try {
          t.snap();
          t.setId(1);
          flush();
          t.snap();
          const pendingBadge = t.badges.find(b => b.text === "ID: 0, pending: true");
          expect(pendingBadge).toBeDefined();
          // Keep any superseded discovery pass unresolved. Neither it nor
          // the optimistic request may be needed for the final publication.
          const previousRequests = t.badges.slice();
          if (!detailsFirst) {
            pendingBadge!.resolve();
            await tick();
            t.snap();
          }
          t.details.shift()!();
          await tick();
          t.snap();
          const corrections = t.badges.slice(previousRequests.length);
          expect(corrections.map(b => b.text)).toEqual(["ID: 1, pending: false"]);
          corrections[0].resolve();
          await tick();
          t.snap();
          // In the details-first order, the pending-true request has never
          // resolved. Resolving all stale answers after commit is inert.
          for (const request of previousRequests) {
            request.resolve();
            await tick();
            expect(t.publications.id).toEqual(["0", "1"]);
            expect(t.publications.details).toEqual(["Item 0", "Item 1"]);
          }
          t.snap();
          expect(t.frames).toEqual(
            detailsFirst
              ? [initial, initial, initial, final, final]
              : [initial, initial, pending, pending, final, final]
          );
          expect(t.publications.pending).toEqual(
            detailsFirst ? ["false", "false"] : ["false", "true", "false"]
          );
          expect(t.publications.badge).toEqual(
            detailsFirst
              ? ["ID: 0, pending: false", "ID: 1, pending: false"]
              : ["ID: 0, pending: false", "ID: 0, pending: true", "ID: 1, pending: false"]
          );
        } finally {
          t.dispose();
        }
      }
    );
  }
});
