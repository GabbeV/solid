import { action, affects, createStore, isPending } from "solid-js";
import { render } from "@solidjs/web";

const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

function App() {
  const [person] = createStore({ name: "Alice" });
  const [list] = createStore(() => ({ people: [person] }), { people: [] });

  const markList = action(function* () {
    affects(list);
    yield delay(1000);
  });

  return (
    <main style={{ padding: "16px", "font-family": "sans-serif" }}>
      <h1>affects propagates upstream</h1>
      <button onClick={() => markList()}>Mark derived list</button>
      <p>Original person pending: <strong id="person-pending">{String(isPending(() => person.name))}</strong></p>
      <p>Derived list pending: <strong id="list-pending">{String(isPending(() => list.people[0].name))}</strong></p>
      <p>list.people[0] === person: <code id="same">{String(list.people[0] === person)}</code></p>
      <p>Only the derived list should become pending.</p>
    </main>
  );
}

render(() => <App />, document.getElementById("root")!);
