import { action, createMemo, createSignal, isPending, Loading } from "solid-js";
import { render } from "@solidjs/web";

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));
const never = new Promise<never>(() => {});

function App() {
  const [id, setId] = createSignal(0);
  const pending = createMemo(() => isPending(id));
  const direct = createMemo(async () => {
    const value = isPending(id);
    await delay(500);
    return String(value);
  });
  const wrapped = createMemo(async () => {
    const value = pending();
    await delay(500);
    return String(value);
  });

  const run = action(function* () {
    setId(1);
    yield never;
  });

  return <main style={{ padding: "16px", "font-family": "sans-serif" }}>
    <h2>The same pending read, with and without a memo wrapper</h2>
    <Loading fallback={<p>Initializing...</p>}>
      <button onClick={event => { event.currentTarget.disabled = true; void run(); }}>Run</button>
      <p>Committed ID: <strong id="id">{id()}</strong></p>
      <p>Pending: <strong id="pending">{String(isPending(id))}</strong></p>
      <p>Async direct read: <strong id="direct">{direct()}</strong></p>
      <p>Async memo-wrapped read: <strong id="wrapped">{wrapped()}</strong></p>
    </Loading>
    <p>The action stays open. Both async presentations take 500 ms.</p>
  </main>;
}

render(() => <App />, document.getElementById("root")!);
