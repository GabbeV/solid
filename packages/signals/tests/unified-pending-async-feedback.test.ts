// #4677 with source-owned pending outputs. All ordinary consumers of the
// pending output publish together. Unlike next's reader-local verdict lane,
// a pending override does not keep its input update alive: a ready input
// supersedes an unfinished badge for pending=true and starts its correction.
// This is the same cancellation rule as a superseded optimistic guess.
import { expect, it } from "vitest";
import {
  createMemo, createRenderEffect, createRoot, createSignal, flush, isPending
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it.each([false, true].flatMap(detailsFirst =>
  [false, true].map(between => ({ detailsFirst, between }))
))(
  "pending and its async badge publish together (details first: $detailsFirst, memo between: $between)",
  async ({ detailsFirst, between }) => {
    const [id, setId] = createSignal(0);
    const detailsAnswer = Promise.withResolvers<string>();
    const badges: { text: string; answer: ReturnType<typeof Promise.withResolvers<string>> }[] = [];
    const screen = { id: 0, details: "", pending: false, badge: "" };
    const dispose = createRoot(dispose => {
      const details = createMemo(() => id() === 0 ? "Item 0" : detailsAnswer.promise);
      const badge = createMemo(() => {
        const i = id(), p = isPending(id);
        const text = `ID: ${i}, pending: ${p}`;
        if (i === 0 && !p) return text;
        const answer = Promise.withResolvers<string>();
        badges.push({ text, answer });
        return answer.promise;
      });
      createRenderEffect(id, value => { screen.id = value; });
      createRenderEffect(between ? createMemo(() => details()) : details,
        value => { screen.details = value; });
      createRenderEffect(() => isPending(id), value => { screen.pending = value; });
      createRenderEffect(badge, value => { screen.badge = value; });
      return dispose;
    });
    const initial = { id: 0, details: "Item 0", pending: false, badge: "ID: 0, pending: false" };
    const pending = { ...initial, pending: true, badge: "ID: 0, pending: true" };
    const final = { id: 1, details: "Item 1", pending: false, badge: "ID: 1, pending: false" };
    try {
      flush();
      await turn();
      expect(screen).toEqual(initial);
      setId(1);
      flush();
      expect(screen).toEqual(initial);
      const pendingBadge = badges.find(request => request.text === pending.badge)!;
      expect(pendingBadge).toBeDefined();
      if (!detailsFirst) {
        pendingBadge.answer.resolve(pendingBadge.text);
        await turn();
        expect(screen).toEqual(pending);
      }

      detailsAnswer.resolve("Item 1");
      await turn();
      expect(screen).toEqual(detailsFirst ? initial : pending);
      const correction = badges.at(-1)!;
      expect(correction.text).toBe(final.badge);

      // The correction must not wait for obsolete work. In the details-first
      // case the pending=true request has never answered at this point.
      correction.answer.resolve(correction.text);
      await turn();
      expect(screen).toEqual(final);
      // Late answers cannot overwrite the current frame or reveal a fragment.
      for (const request of badges) {
        if (request !== correction) request.answer.resolve(request.text);
      }
      await turn();
      expect(screen).toEqual(final);
    } finally {
      dispose();
      flush();
    }
  }
);
