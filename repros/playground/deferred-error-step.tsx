import { createDeferred, createSignal, until } from "solid-js";
import { render } from "solid-js/web";

const delay = <T,>(ms: number, value?: T) =>
  new Promise<T | undefined>(resolve => setTimeout(resolve, ms, value));

async function request() {
  const value = await delay(2000, 21);
  console.log("Old request finished.");
  return value;
}

function App() {
  const [step, setStep] = createSignal(0);
  const result = createDeferred(() => {
    if (step() === 1) return request();
    if (step() === 2) throw new Error("request failed");
    return 7;
  });

  return <button onClick={async event => {
    event.currentTarget.disabled = true;
    setStep(1);
    await delay(20);
    setStep(2);
    await delay(20);
    try {
      await until(result);
    } catch (error) {
      console.log("Current error received:", error);
    }
  }}>Run</button>;
}

render(() => <App />, document.getElementById("root")!);
