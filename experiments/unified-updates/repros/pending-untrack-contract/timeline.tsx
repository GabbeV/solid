import { createMemo, createSignal, isPending, untrack } from "solid-js";
import { render } from "@solidjs/web";

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

const events: unknown[] = [];
(window as any).__timeline = events;
let phase = "mount";
const counts: Record<string, number> = {};
function begin(name: string) {
  const run = counts[name] = (counts[name] || 0) + 1;
  events.push({ phase, name, run, event: "start", time: performance.now() });
  return (value: unknown) => events.push({ phase, name, run, event: "return", value, time: performance.now() });
}
function event(name: string) {
  phase = name;
  events.push({ event: name, time: performance.now() });
}
function App() {
  const [id, setId] = createSignal(0);
  const [revision, setRevision] = createSignal(0);
  const answer = Promise.withResolvers<number>();
  const data = createMemo(() => {
    const finish = begin("data");
    const value = id();
    finish(value === 0 ? 0 : "answer.promise");
    return value === 0 ? 0 : answer.promise;
  });
  const pending = createMemo(() => {
    const finish = begin("pending wrapper");
    let inside: number | undefined;
    const sampled = isPending(() => (inside = id()));
    finish({ inside, sampled });
    return { inside, sampled };
  });

  const direct = createMemo(() => {
    const finish = begin("direct sync");
    revision();
    const value = id();
    let inside: number | undefined;
    const sampled = untrack(() => isPending(() => (inside = id())));
    finish({ value, inside, sampled });
    return `${value} / ${inside} / ${sampled}`;
  });

  const wrapped = createMemo(() => {
    const finish = begin("wrapped reader");
    revision();
    const value = id();
    const { inside, sampled } = untrack(pending);
    finish({ value, inside, sampled });
    return `${value} / ${inside} / ${sampled}`;
  });

  const asynchronous = createMemo(async () => {
    const finish = begin("direct async");
    revision();
    const value = id();
    let inside: number | undefined;
    const sampled = untrack(() => isPending(() => (inside = id())));
    const result = `${value} / ${inside} / ${sampled}`;
    finish({ value, inside, sampled });
    return result;
  });

  async function run() {
    event("setId(1)");
    setId(1);
    await delay(500);
    event("setRevision(1)");
    setRevision(1);
    await delay(1000);
    event("answer.resolve(1)");
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
