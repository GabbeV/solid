/** @jsxImportSource @solidjs/web */
import { action, createOptimisticStore, createSignal, flush, Loading } from "solid-js";
import { render } from "../src/index.js";
import { expect, test } from "vitest";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

test("a structural answer waits at an unguessed index while the explicitly guessed row stays visible", async () => {
  const container = document.createElement("div");
  const questions = new Map<number, ReturnType<typeof Promise.withResolvers<string[]>>>();
  let navigate!: (id: number) => void;
  let guess!: (end: Promise<void>) => Promise<unknown>;
  const dispose = render(() => {
    const [id, setId] = createSignal(0);
    navigate = setId;
    const [rows, edit] = createOptimisticStore(() => {
      const answer = Promise.withResolvers<string[]>();
      questions.set(id(), answer);
      return answer.promise;
    }, [] as string[]);
    guess = action(function* (end: Promise<void>) {
      edit(draft => {
        draft.splice(1, draft.length - 1, "mine");
      });
      yield end;
    });
    return (
      <>
        <Loading on={id()} fallback="loading">
          {rows[0]}
        </Loading>
        <Loading fallback="waiting">/{rows[1]}</Loading>
      </>
    );
  }, container);
  try {
    questions.get(0)!.resolve(["a", "b", "c"]);
    await turn();
    expect(container.textContent).toBe("a/b");
    for (const [id, answer] of [
      [1, ["d", "e"]],
      [2, ["f", "g", "h"]]
    ] as const) {
      const hold = Promise.withResolvers<void>();
      const running = guess(hold.promise);
      try {
        await turn();
        navigate(id);
        await turn();
        expect(container.textContent).toBe("loading/mine");
        questions.get(id)!.resolve([...answer]);
        await turn();
        expect(container.textContent).toBe("loading/mine");
      } finally {
        hold.resolve();
        await running;
        await turn();
      }
      expect(container.textContent).toBe(answer.slice(0, 2).join("/"));
    }
  } finally {
    dispose();
  }
});

test.each([true, false])(
  "a guessed field leaves the other fields waiting (key retained: %s)",
  async keepKey => {
    type Row = { id: number; name: string; badge: string };
    const open = Promise.withResolvers<Row[]>();
    const closed = Promise.withResolvers<Row[]>();
    const end = Promise.withResolvers<void>();
    const container = document.createElement("div");
    let navigate!: () => void;
    let guess!: () => Promise<unknown>;
    const dispose = render(() => {
      const [isClosed, setClosed] = createSignal(false);
      navigate = () => setClosed(true);
      const [rows, edit] = createOptimisticStore(
        () => (isClosed() ? closed.promise : open.promise),
        [] as Row[],
        { key: "id" }
      );
      guess = action(function* () {
        edit(draft => {
          draft[0].badge = "guess";
          draft.pop();
        });
        yield end.promise;
      });
      return (
        <>
          <Loading on={isClosed()} fallback="loading">
            {rows[0].name}
          </Loading>
          <Loading fallback="waiting">/{rows[0].badge}</Loading>
        </>
      );
    }, container);
    let running: Promise<unknown> | undefined;
    try {
      open.resolve([
        { id: 1, name: "old", badge: "a" },
        { id: 2, name: "other", badge: "b" }
      ]);
      await turn();
      running = guess();
      await turn();
      expect(container.textContent).toBe("old/guess");
      navigate();
      await turn();
      expect(container.textContent).toBe("loading/guess");
      closed.resolve([{ id: keepKey ? 1 : 3, name: "new", badge: "answer" }]);
      await turn();
      expect(container.textContent).toBe("loading/guess");
      end.resolve();
      await running;
      await turn();
      expect(container.textContent).toBe("new/answer");
    } finally {
      end.resolve();
      await running;
      dispose();
    }
  }
);
