import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

for (const wrapped of [false, true])
  for (const externalRequest of [false, true])
    it(`a private optimistic consequence cannot keep its own override alive (memo=${wrapped}, external request=${externalRequest})`, async () => {
      const end = Promise.withResolvers<void>();
      const answer = Promise.withResolvers<void>();
      let shown: { value?: number } | undefined;
      let shownView = 0;
      const app = createRoot(dispose => {
        const [visible, setVisible] = createSignal(false);
        const [view, guess] = createOptimistic(() => 0);
        const read = wrapped ? createMemo(view) : view;
        const request = () => {
          const value = read();
          return value ? answer.promise.then(() => value) : 0;
        };
        const resource = externalRequest ? createMemo(request) : undefined;
        const page = createMemo(() => {
          if (!visible()) return undefined;
          const frame: { value?: number } = {};
          const child = resource ?? createMemo(request);
          createRenderEffect(
            child,
            value => {
              frame.value = value;
            },
            { schedule: true }
          );
          return frame;
        });
        createRenderEffect(
          page,
          frame => {
            shown = frame;
          },
          { schedule: true }
        );
        createRenderEffect(
          view,
          value => {
            shownView = value;
          },
          { schedule: true }
        );
        return { dispose, setVisible, guess };
      });
      flush();
      const running = action(function* () {
        app.setVisible(true);
        app.guess(1);
        yield end.promise;
      })();
      await turn();
      try {
        expect(shown).toBeUndefined();
        end.resolve();
        await turn();
        expect([shownView, shown?.value]).toEqual([0, 0]);
        answer.resolve();
        await running;
        await turn();
        expect([shownView, shown?.value]).toEqual([0, 0]);
      } finally {
        end.resolve();
        answer.resolve();
        await running;
        app.dispose();
        flush();
      }
    });

it("dropping a private proposal dependency releases only its publication wait", async () => {
  const guessEnd = Promise.withResolvers<void>();
  const mountEnd = Promise.withResolvers<void>();
  const answer = Promise.withResolvers<void>();
  let shown: { value?: number } | undefined;
  let shownView = 0;
  let shownPending = false;
  const app = createRoot(dispose => {
    const [visible, setVisible] = createSignal(false);
    createRenderEffect(
      () => isPending(visible),
      value => {
        shownPending = value;
      }
    );
    const [selected, setSelected] = createSignal(true);
    const [view, guess] = createOptimistic(() => 0);
    const slow = createMemo(() => {
      const value = view();
      return value ? answer.promise.then(() => value) : 0;
    });
    createRenderEffect(slow, () => {});
    createRenderEffect(
      view,
      value => {
        shownView = value;
      },
      { schedule: true }
    );
    const page = createMemo(() => {
      if (!visible()) return undefined;
      const frame: { value?: number } = {};
      createRenderEffect(
        () => (selected() ? view() : 7),
        value => {
          frame.value = value;
        }
      );
      return frame;
    });
    createRenderEffect(
      page,
      frame => {
        shown = frame;
      },
      { schedule: true }
    );
    return { dispose, setVisible, setSelected, guess };
  });
  flush();
  const guessing = action(function* () {
    app.guess(1);
    yield guessEnd.promise;
  })();
  await turn();
  const mounting = action(function* () {
    app.setVisible(true);
    yield mountEnd.promise;
  })();
  await turn();
  try {
    expect(shown).toBeUndefined();
    mountEnd.resolve();
    await mounting;
    await turn();
    expect(shown).toBeUndefined();
    expect(shownPending).toBe(true);
    app.setSelected(false);
    flush();
    expect([shownView, shown?.value]).toEqual([0, 7]);
    expect(shownPending).toBe(false);
  } finally {
    guessEnd.resolve();
    mountEnd.resolve();
    answer.resolve();
    await guessing;
    await mounting;
    app.dispose();
    flush();
  }
});
