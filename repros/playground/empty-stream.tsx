import { createMemo } from "solid-js";
import { render } from "@solidjs/web";

const immediately = value => ({ then: resolve => resolve(value) });
const empty = {
  [Symbol.asyncIterator]() {
    return { next: () => immediately({ done: true }) };
  }
};

function App() {
  const value = createMemo(() => immediately(empty));

  return <p>Value: {String(value())}</p>;
}

render(() => <App />, document.getElementById("root")!);
