import { createDeferred, createSignal, from } from "solid-js";
import { render } from "solid-js/web";

function App() {
  const [source, setSource] = createSignal(0);
  const value = createDeferred(() => {
    const current = source();
    return from<number>(next => next(current));
  });

  return <>
    <button onClick={() => setSource(n => n + 1)}>Change source</button>
    <p>Value: {value()}</p>
  </>;
}

render(() => <App />, document.getElementById("root")!);
