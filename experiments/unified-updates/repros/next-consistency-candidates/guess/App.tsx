import { action, createMemo, createOptimistic, createSignal } from "solid-js";
import { render } from "@solidjs/web";

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));
const never = new Promise<never>(() => {});

function App() {
  const [view, guess] = createOptimistic(() => 0);
  const [tick, setTick] = createSignal(0);
  const derived = createMemo(() => view() === 2 ? never : view());
  const pair = createMemo(() => `${view()} / ${derived()}`);

  const save = action(function* () {
    guess(1);
    yield delay(500);
    guess(2);
    yield never;
  });

  async function run() {
    void save();
    await delay(1000);
    setTick(1);
  }

  return <main style={{ padding: "16px", "font-family": "sans-serif" }}>
    <h2>Two ordinary readers of the same optimistic value</h2>
    <button onClick={event => { event.currentTarget.disabled = true; void run(); }}>Run</button>
    <p>Value / async copy: <strong id="pair">{pair()}</strong></p>
    <p>Value with independent tick: <strong id="reader">{`${view()} (tick ${tick()})`}</strong></p>
    <p>Guess 1 publishes first. At 500 ms, guess 2 starts an unfinished request.
      At 1000 ms, only the independent tick changes.</p>
  </main>;
}

render(() => <App />, document.getElementById("root")!);
