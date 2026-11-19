import { action, createMemo, createSignal, latest } from "solid-js";
import { render } from "@solidjs/web";

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));
const never = new Promise<never>(() => {});

function App() {
  const [id, setId] = createSignal(0);
  const [enabled, setEnabled] = createSignal(false);
  const [log, setLog] = createSignal("No requests yet");
  const requests: string[] = [];

  const data = createMemo(() => {
    if (!enabled()) return "Not requested";
    const before = id();
    const proposed = latest(id);
    const after = id();
    const request = `before=${before}, latest=${proposed}, after=${after}`;
    requests.push(request);
    console.log("Request:", request);
    return delay(500).then(() => request);
  });

  const save = action(function* () {
    setId(1);
    yield never;
  });

  async function run() {
    void save();
    await delay(500);
    setEnabled(true);
    await delay(500);
    setLog(requests.join("\n"));
  }

  return <main style={{ padding: "16px", "font-family": "sans-serif" }}>
    <h2>Read the same signal twice during one calculation</h2>
    <button onClick={event => { event.currentTarget.disabled = true; void run(); }}>Run</button>
    <p>Committed ID: {id()}</p>
    <p>Result: {data()}</p>
    <p>Request arguments captured synchronously:</p>
    <pre id="log">{log()}</pre>
    <p>The action stays open. Enable the request after 500 ms, then copy its arguments here after another 500 ms.</p>
  </main>;
}

render(() => <App />, document.getElementById("root")!);
