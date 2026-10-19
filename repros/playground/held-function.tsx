import { createMemo, createSignal } from "solid-js";
import { render } from "@solidjs/web";

function App() {
  const [version, setVersion] = createSignal(0);
  const [callback, setCallback] = createSignal<() => string>(() => {
    version();
    return () => "derived";
  });
  let finish!: (value: number) => void;
  const request = new Promise<number>(resolve => { finish = resolve; });
  const slow = createMemo(() => version() === 0 ? 0 : request);
  const replacement = () => {
    console.log("Replacement invoked");
    return "replacement";
  };

  return <>
    <button onClick={() => setVersion(1)}>1. Start update</button>
    <button onClick={event => {
      const value = setCallback(() => replacement);
      event.currentTarget.textContent = `Returned: ${typeof value}`;
    }}>2. Store callback</button>
    <button onClick={() => finish(1)}>3. Finish request</button>
    <p>{`${version()} / ${typeof callback()} / ${slow()}`}</p>
  </>;
}

render(() => <App />, document.getElementById("root")!);
