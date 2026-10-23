import { createDeferred, createSignal, isPending, until } from "solid-js";
import { render } from "solid-js/web";

function delay<T>(ms: number, result?: T) {
  return new Promise<T | undefined>(resolve => setTimeout(resolve, ms, result));
}

function App() {
  const [step, setStep] = createSignal(0);
  const value = createDeferred(() =>
    step() === 0
      ? 0
      : {
          [Symbol.asyncIterator]() {
            return {
              next() {
                throw new Error("stream failed");
              }
            };
          }
        }
  );

  async function run() {
    setStep(1);
    await delay(0);
    console.log("Pending:", isPending(value));
    try {
      console.log("Value:", await until(value));
    } catch (error) {
      console.log("Error:", error);
    }
  }

  return <button onClick={run}>Run</button>;
}

render(() => <App />, document.getElementById("root")!);
