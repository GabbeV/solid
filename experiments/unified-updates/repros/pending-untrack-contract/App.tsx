import { createMemo, createSignal, isPending, untrack } from "solid-js";
import { render } from "@solidjs/web";

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

function App() {
  const [id, setId] = createSignal(0);
  const [revision, setRevision] = createSignal(0);
  const answer = Promise.withResolvers<number>();
  const data = createMemo(() => id() === 0 ? 0 : answer.promise);
  const pending = createMemo(() => isPending(id));

  const direct = createMemo(() => {
    revision();
    const value = id();
    let inside: number | undefined;
    const sampled = untrack(() => isPending(() => (inside = id())));
    return `${value} / ${inside} / ${sampled}`;
  });

  const wrapped = createMemo(() => {
    revision();
    const value = id();
    const sampled = untrack(pending);
    return `${value} / — / ${sampled}`;
  });

  const asynchronous = createMemo(() => {
    revision();
    const value = id();
    let inside: number | undefined;
    const sampled = untrack(() => isPending(() => (inside = id())));
    const result = `${value} / ${inside} / ${sampled}`;
    return value === 0 ? result : delay(500).then(() => result);
  });

  async function run() {
    setId(1);
    await delay(500);
    setRevision(1);
    await delay(1000);
    answer.resolve(1);
  }

  return (
    <main style={{ padding: "16px", "font-family": "sans-serif" }}>
      <h2>Untracked isPending samples</h2>
      <button onClick={event => {
        event.currentTarget.disabled = true;
        void run();
      }}>Run</button>
      <p>Live ID / data / pending: <strong id="live">{id()} / {data()} / {String(isPending(id))}</strong></p>
      <p>Each row shows: ordinary ID / callback ID / pending sample.</p>
      <p>Direct, sync memo: <strong id="direct">{direct()}</strong></p>
      <p>Memo-wrapped pending: <strong id="wrapped">{wrapped()}</strong></p>
      <p>Direct, async memo: <strong id="async">{asynchronous()}</strong></p>
      <ol>
        <li>Immediately: request ID 1; the data request holds publication.</li>
        <li>500 ms: rerun the three sample memos while the request is held.</li>
        <li>1500 ms: resolve the data request. Compare the final samples.</li>
      </ol>
    </main>
  );
}

render(() => <App />, document.getElementById("root")!);
