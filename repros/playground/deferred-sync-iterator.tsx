import { createDeferred, createSignal } from "solid-js";
import { render } from "solid-js/web";

const delay = <T,>(ms: number, value?: T) =>
  new Promise<T | undefined>(resolve => setTimeout(resolve, ms, value));

function App() {
  const [step, setStep] = createSignal(0);
  const value = createDeferred(() => {
    const current = step();
    if (current === 0) return 0;
    return {
      *[Symbol.asyncIterator]() {
        yield current;
      }
    };
  });

  return <button onClick={async event => {
    event.currentTarget.disabled = true;
    console.log("Initial value:", value());
    setStep(1);
    await delay(20);
    try {
      console.log("Updated value:", value());
    } catch (error) {
      console.log("Read failed:", error);
    }
  }}>Run</button>;
}

render(() => <App />, document.getElementById("root")!);
