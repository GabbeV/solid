import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "solid-js";
import { render } from "solid-js/web";

function App() {
  const [result, setResult] = createSignal("Not run");

  function run() {
    const [version, setVersion] = createSignal(0);
    createRoot(() => {
      createMemo(() => {
        version();
        onCleanup(() => {
          throw new Error("cleanup failed");
        });
        return new Promise(() => {});
      });
    });
    flush();
    setVersion(1);
    try {
      flush();
    } catch (error) {
      console.log("Caught:", error);
    }

    let cleaned = 0;
    let stop!: () => void;
    createRoot(() => {
      const value = createMemo(() => {
        onCleanup(() => cleaned++);
        return 1;
      }, { lazy: true });
      stop = createRoot(dispose => {
        createRenderEffect(value, () => {});
        return dispose;
      });
    });
    flush();
    stop();
    flush();
    setResult(`Cleanup count: ${cleaned}`);
  }

  return <>
    <button onClick={run}>Run</button>
    <p>{result()}</p>
  </>;
}

render(() => <App />, document.getElementById("root")!);
