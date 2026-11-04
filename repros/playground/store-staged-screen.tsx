import { createMemo, createSignal, createStore, latest, untrack } from "solid-js";
import { render } from "solid-js/web";

const delay = <T,>(ms: number, value: T): Promise<T> =>
  new Promise(resolve => setTimeout(resolve, ms, value));

function App() {
  const [step, setStep] = createSignal(0);
  const [state, setState] = createStore({ count: 0 });
  const data = createMemo(() => {
    const current = step();
    return current === 0 ? current : delay(100, current);
  });

  return <>
    <button onClick={() => {
      setStep(1);
      setState(draft => { draft.count = 1; });
    }}>Run</button>
    <p>{`${latest(data)} / ${untrack(() => state.count)}`}</p>
  </>;
}

render(() => <App />, document.getElementById("root")!);
