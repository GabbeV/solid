import { createMemo, createSignal } from "solid-js";
import { render } from "@solidjs/web";

function App() {
  const [step, setStep] = createSignal(0);
  let finish!: (value: number) => void;
  const request = new Promise<number>(resolve => { finish = resolve; });
  const slow = createMemo(() => step() === 0 ? 1 : request);
  const value = createMemo(() => {
    if (step() === 1) throw new Error("boom");
    return 1;
  });

  return <>
    <button onClick={() => setStep(1)}>1. Start update</button>
    <button onClick={() => setStep(2)}>2. Recover</button>
    <button onClick={() => finish(2)}>3. Finish request</button>
    <p>Sum: {slow() + value()}</p>
  </>;
}

render(() => <App />, document.getElementById("root")!);
