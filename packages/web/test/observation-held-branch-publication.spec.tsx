/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { render } from "@solidjs/web";
import { createMemo, createSignal, flush, isPending, Loading, Show } from "solid-js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const wrapped of [false, true])
  for (const asyncReviews of [false, true])
    test(`a new branch cannot deadlock the correction of a published pending view (wrapped=${wrapped}, async reviews=${asyncReviews})`, async () => {
      const profileAnswer = Promise.withResolvers<string>();
      const reviewsAnswer = Promise.withResolvers<string>();
      const obsoleteAnswer = Promise.withResolvers<string>();
      const element = document.createElement("div");
      const dispose = render(() => {
        const [id, setId] = createSignal(0);
        const profile = createMemo(() => (id() === 0 ? "guest" : profileAnswer.promise));
        const busy = createMemo(() => isPending(id));
        const params = createMemo(() => ({
          busy: wrapped ? busy() : isPending(id),
          id: id()
        }));
        const guestReviews = createMemo(() => obsoleteAnswer.promise, { lazy: true });
        const memberReviews = createMemo(() => (asyncReviews ? reviewsAnswer.promise : "reviews"), {
          lazy: true
        });
        return (
          <>
            <button disabled={params().busy} onClick={() => setId(1)}>
              Sign in
            </button>
            <Loading fallback={<p>Loading</p>}>
              <p data-profile>
                {id()}:{profile()}
              </p>
              <Show when={id() !== 0} fallback={<p data-reviews>signed out</p>}>
                <p data-reviews>{params().id === 1 ? memberReviews() : guestReviews()}</p>
              </Show>
            </Loading>
          </>
        );
      }, element);
      const frame = () => [
        element.querySelector("[data-profile]")?.textContent,
        element.querySelector("[data-reviews]")?.textContent,
        element.querySelector("button")!.disabled
      ];
      try {
        flush();
        expect(frame()).toEqual(["0:guest", "signed out", false]);
        element.querySelector("button")!.click();
        flush();
        expect(frame()).toEqual(["0:guest", "signed out", true]);
        profileAnswer.resolve("member");
        await turn();
        if (asyncReviews) {
          expect(frame()).toEqual(["0:guest", "signed out", true]);
          reviewsAnswer.resolve("reviews");
          await turn();
        }
        expect(frame()).toEqual(["1:member", "reviews", false]);
        obsoleteAnswer.resolve("obsolete guest reviews");
        await turn();
        expect(frame()).toEqual(["1:member", "reviews", false]);
      } finally {
        dispose();
      }
    });
