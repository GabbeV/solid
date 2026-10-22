import { createDeferred, createSignal, until } from "solid-js";
import { render } from "solid-js/web";

function App() {
  const [mode, setMode] = createSignal(0);
  const [status, setStatus] = createSignal("Not read");
  let finish!: (value: number) => void;
  const result = createDeferred(() => {
    const current = mode();
    if (current === 2) throw new Error("request failed");
    return current === 1
      ? new Promise<number>(resolve => (finish = resolve))
      : 7;
  });

  function read() {
    setStatus("Waiting");
    until(result).then(
      value => setStatus(`Value: ${value}`),
      error => setStatus(`Failed: ${error.message}`)
    );
  }

  return <>
    <button onClick={() => setMode(1)}>Start request</button>
    <button onClick={() => setMode(2)}>Fail next request</button>
    <button onClick={read}>Read settled result</button>
    <button onClick={() => finish(21)}>Finish old request</button>
    <p>{status()}</p>
  </>;
}

render(() => <App />, document.getElementById("root")!);
