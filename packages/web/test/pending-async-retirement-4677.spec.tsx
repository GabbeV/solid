/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import { createMemo, createSignal, isPending } from "solid-js";
import { render } from "@solidjs/web";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

test.each([false, true])(
  "pending's async derivation does not extend its lifetime (details first: %s)",
  async detailsFirst => {
    const detailsAnswer = Promise.withResolvers<string>();
    const requests: { text: string; answer: ReturnType<typeof Promise.withResolvers<string>> }[] =
      [];
    const container = document.createElement("div");
    document.body.append(container);
    function App() {
      const [id, setId] = createSignal(0);
      const details = createMemo(() => (id() === 0 ? "Item 0" : detailsAnswer.promise));
      const badge = createMemo(() => {
        const current = id(),
          pending = isPending(id);
        const text = `${current}:${pending}`;
        if (current === 0 && !pending) return text;
        const answer = Promise.withResolvers<string>();
        requests.push({ text, answer });
        return answer.promise;
      });
      return (
        <>
          <button onClick={() => setId(1)}>Navigate</button>
          <main>
            <span>{id()}</span> / <span>{details()}</span> / <span>{String(isPending(id))}</span> /{" "}
            <span>{badge()}</span>
          </main>
        </>
      );
    }
    const dispose = render(() => <App />, container);
    const screen = () => container.querySelector("main")!.textContent;
    try {
      await turn();
      expect(screen()).toBe("0 / Item 0 / false / 0:false");
      container.querySelector("button")!.click();
      await turn();
      const previous = requests.slice();
      const pending = previous.find(r => r.text === "0:true");
      expect(pending).toBeDefined();
      if (!detailsFirst) {
        pending!.answer.resolve(pending!.text);
        await turn();
        expect(screen()).toBe("0 / Item 0 / true / 0:true");
      }
      detailsAnswer.resolve("Item 1");
      await turn();
      expect(screen()).toBe(
        detailsFirst ? "0 / Item 0 / false / 0:false" : "0 / Item 0 / true / 0:true"
      );
      const corrections = requests.slice(previous.length);
      expect(corrections.map(r => r.text)).toEqual(["1:false"]);
      corrections[0].answer.resolve("1:false");
      await turn();
      expect(screen()).toBe("1 / Item 1 / false / 1:false");
      for (const stale of previous) {
        stale.answer.resolve(stale.text);
        await turn();
        expect(screen()).toBe("1 / Item 1 / false / 1:false");
      }
    } finally {
      dispose();
      container.remove();
    }
  }
);
