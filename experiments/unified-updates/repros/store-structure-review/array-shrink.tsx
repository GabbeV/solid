import { action, createOptimisticStore, createSignal, For } from "solid-js";
import { render } from "@solidjs/web";

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

function App() {
  const [input, setInput] = createSignal(["A"]);
  const [rows, guess] = createOptimisticStore(() => input(), ["A"]);

  const save = action(function* () {
    guess(draft => {
      draft.push("M");
    });
    yield delay(1500);
  });

  async function run() {
    void save();
    await delay(500);
    setInput([]);
  }

  return (
    <main style={{ padding: "16px", "font-family": "sans-serif" }}>
      <h2>A push followed by an independent empty input</h2>
      <button
        onClick={event => {
          event.currentTarget.disabled = true;
          void run();
        }}
      >
        Run
      </button>
      <p>
        Input: <strong id="input">{JSON.stringify(input())}</strong>
      </p>
      <p>
        Optimistic array: <strong id="rows">{JSON.stringify(Array.from(rows))}</strong>
      </p>
      <ul id="list">
        <For each={rows}>{item => <li>{item.toUpperCase()}</li>}</For>
      </ul>
      <p>Immediately: push M. At 500 ms: set the input to []. At 1500 ms: the action ends.</p>
    </main>
  );
}

render(() => <App />, document.getElementById("root")!);
