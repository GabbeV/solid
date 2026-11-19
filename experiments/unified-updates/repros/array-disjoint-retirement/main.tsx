import { action, createOptimisticStore } from "solid-js";
import { render } from "@solidjs/web";

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

function App() {
  const [array, setArray] = createOptimisticStore([0, 0]);
  const [object, setObject] = createOptimisticStore({ 0: 0, 1: 0 });

  const save = action(function* (index: 0 | 1) {
    setArray(draft => {
      draft[index] = index + 1;
    });
    setObject(draft => {
      draft[index] = index + 1;
    });
    yield delay(1000);
  });

  async function run() {
    save(1);
    await delay(500);
    save(0);
  }

  return (
    <main style={{ padding: "20px", "font-family": "sans-serif" }}>
      <button onClick={run}>Run</button>
      <p>
        Array:{" "}
        <span id="array">
          {array[0]}, {array[1]}
        </span>
      </p>
      <p>
        Object:{" "}
        <span id="object">
          {object[0]}, {object[1]}
        </span>
      </p>
      <p>Both should follow the same sequence. The array keeps 2 longer.</p>
    </main>
  );
}

render(() => <App />, document.getElementById("root")!);
