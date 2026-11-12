import { action, createOptimisticStore } from "solid-js";
import { render } from "@solidjs/web";

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

function App() {
  const [state, setState] = createOptimisticStore({ a: 0, b: 0 });

  const saveA = action(function* () {
    setState(draft => {
      draft.a = 1;
    });
    yield delay(1000);
  });

  const saveB = action(function* () {
    setState(draft => {
      draft.b = draft.a + 1;
    });
    yield delay(1000);
  });

  async function run() {
    saveA();
    await delay(500);
    saveB();
  }

  return (
    <main style={{ padding: "20px", "font-family": "sans-serif" }}>
      <button onClick={run}>Run</button>
      <p>
        a: <span id="a">{state.a}</span>
      </p>
      <p>
        b: <span id="b">{state.b}</span>
      </p>
      <p>B guesses b = a + 1 using A's guess of 1.</p>
      <p>When A ends, a reverts to 0 while b remains 2.</p>
    </main>
  );
}

render(() => <App />, document.getElementById("root")!);
