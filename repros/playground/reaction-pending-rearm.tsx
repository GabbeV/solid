import { createMemo, createReaction, createSignal } from "solid-js";
import { render } from "solid-js/web";

function App() {
  let finish!: (value: number) => void;
  const oldResult = createMemo(() => new Promise<number>(resolve => finish = resolve));
  const [currentField, setCurrentField] = createSignal(0);
  const [calls, setCalls] = createSignal(0);
  const track = createReaction(() => { setCalls(n => n + 1); });

  return <>
    <button onClick={() => { track(oldResult); track(currentField); }}>Arm</button>
    <button onClick={() => finish(1)}>Finish old result</button>
    <button onClick={() => setCurrentField(n => n + 1)}>Change current field</button>
    <p>Reaction calls: {calls()}</p>
  </>;
}

render(() => <App />, document.getElementById("root")!);
