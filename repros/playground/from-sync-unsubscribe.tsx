import { createMemo, from } from "solid-js";
import { render } from "solid-js/web";

function App() {
  const value = createMemo(() => from<number>((next, _error, complete) => {
    next(7);
    complete();
    return () => { throw new Error("unsubscribe failed"); };
  }));

  return <p>Value: {value()}</p>;
}

render(() => <App />, document.getElementById("root")!);
