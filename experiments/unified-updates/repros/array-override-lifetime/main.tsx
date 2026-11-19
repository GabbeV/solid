import { action, createOptimisticStore, createSignal, For } from "solid-js";
import { render } from "@solidjs/web";

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

function App() {
  const [items, guess] = createOptimisticStore<number[]>([]);
  const [bFinished, setBFinished] = createSignal(false);
  const [aFinished, setAFinished] = createSignal(false);

  const saveB = action(function* () {
    guess(draft => {
      draft[1] = 2;
    });
    yield delay(1000);
  });

  const saveA = action(function* () {
    guess(draft => {
      draft[0] = 1;
    });
    yield delay(1000);
  });

  async function run(event: MouseEvent & { currentTarget: HTMLButtonElement }) {
    event.currentTarget.disabled = true;
    const b = saveB();
    await delay(500);
    const a = saveA();
    await b;
    setBFinished(true);
    await a;
    setAFinished(true);
  }

  return (
    <main style={{ padding: "20px", "font-family": "sans-serif" }}>
      <button onClick={run}>Run</button>
      <p>B finished: <span id="b-finished">{String(bFinished())}</span></p>
      <p>A finished: <span id="a-finished">{String(aFinished())}</span></p>
      <p>Length: <span id="length">{items.length}</span></p>
      <ol id="rows">
        <For each={items}>{item => <li>{String(item)}</li>}</For>
      </ol>
      <p>The first undefined row is the hole created by writing index 1.</p>
      <p>When B finishes, its value 2 remains until A finishes.</p>
    </main>
  );
}

render(() => <App />, document.getElementById("root")!);
