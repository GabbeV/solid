import { createMemo, createSignal, isPending } from "solid-js";
import { render } from "@solidjs/web";

function delay<T>(ms: number, value: T): Promise<T> {
  return new Promise(resolve => setTimeout(() => resolve(value), ms));
}

export default function App() {
  const [id, setId] = createSignal(0);

  // Item 0 is already loaded. Loading item 1 takes 500 ms.
  const details = createMemo(() => {
    const value = id();
    return value === 0 ? "Item 0" : delay(500, `Item ${value}`);
  });

  // An async presentation of the ID and its pending status (e.g. a worker).
  const badge = createMemo(() => {
    const value = id();
    const pending = isPending(id);
    const text = `ID: ${value}, pending: ${pending}`;
    return value === 0 && !pending ? text : delay(1000, text);
  });

  return (
    <main>
      <h1>Pending and its async badge disagree</h1>
      <p>Click once and watch for two seconds.</p>
      <button onClick={() => setId(1)}>Load item 1</button>
      <p>ID: <output id="id">{id()}</output></p>
      <p>Details: <output id="details">{details()}</output></p>
      <p>Pending: <output id="pending">{String(isPending(id))}</output></p>
      <p>Async badge: <output id="badge">{badge()}</output></p>
      <p>
        Bug: Pending says false while the badge says pending: true.
        There is no Loading or createDeferred boundary.
      </p>
    </main>
  );
}

render(() => <App />, document.getElementById("root")!);
