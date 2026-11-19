import { action, createMemo, createSignal, latest } from "solid-js";
import { render } from "@solidjs/web";

const never = new Promise<never>(() => {});

function App() {
  const [id, setId] = createSignal(1);
  const [filter, setFilter] = createSignal(0);
  const proposed = createMemo(() => latest(id));
  const pair = createMemo(() => `${proposed()} / ${filter()}`);

  const run = action(function* () {
    setId(2);
    setFilter(1);
    yield never;
  });

  return <main style={{ padding: "16px", "font-family": "sans-serif" }}>
    <h2>A published memo and its ordinary consumer disagree</h2>
    <button onClick={event => { event.currentTarget.disabled = true; void run(); }}>Run</button>
    <p>Committed ID: <strong id="id">{id()}</strong></p>
    <p>Committed filter: <strong id="filter">{filter()}</strong></p>
    <p>Memo of latest ID: <strong id="proposed">{proposed()}</strong></p>
    <p>The same memo / filter: <strong id="pair">{pair()}</strong></p>
    <p>The action proposes ID 2 and filter 1, then stays open.</p>
  </main>;
}

render(() => <App />, document.getElementById("root")!);
