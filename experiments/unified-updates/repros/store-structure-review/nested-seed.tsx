import { render } from "@solidjs/web";
import { createStore, createSignal, Loading } from "solid-js";

const delay = (ms = 500) => new Promise<void>(resolve => setTimeout(resolve, ms));

function App() {
  let resolveFirst!: (value: { x: number }) => void;
  const first = new Promise<{ x: number }>(resolve => {
    resolveFirst = resolve;
  });
  const [inner] = createStore(() => first, { x: 0 });
  const [outer, setOuter] = createStore(() => ({ child: inner }), { child: { x: 0 } });
  const [result, setResult] = createSignal("Ready.");
  const [started, setStarted] = createSignal(false);

  async function run() {
    setStarted(true);
    let childReturned = false;
    try {
      setOuter(draft => {
        const child = draft.child;
        childReturned = true;
        child.x = 9;
      });
      setResult(`draft.child returned: ${childReturned}; setter completed.`);
    } catch (error) {
      setResult(
        `draft.child returned: ${childReturned}; setter failed: ${(error as Error).constructor.name}`
      );
    }
    await delay();
    resolveFirst({ x: 2 });
  }

  return (
    <main style={{ padding: "24px", "font-family": "sans-serif", "max-width": "760px" }}>
      <h1>Nested write through a pending store</h1>
      <p>
        The outer store returns its child synchronously. The child is waiting for its first answer.
      </p>
      <p>
        Visible child.x:{" "}
        <Loading fallback={<strong>Loading</strong>}>
          <strong>{outer.child.x}</strong>
        </Loading>
      </p>
      <button disabled={started()} onClick={run}>
        Run reproduction
      </button>
      <p>{result()}</p>
      <p>The button writes child.x = 9, then resolves the child to 2 after 500 ms.</p>
    </main>
  );
}

render(() => <App />, document.getElementById("root")!);
