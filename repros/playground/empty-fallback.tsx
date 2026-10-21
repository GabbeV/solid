import { For, createSignal, onCleanup } from "solid-js";
import { render } from "solid-js/web";

function Empty() {
  console.log("Empty mounted");
  onCleanup(() => console.log("Empty cleaned"));
  return 0;
}

function App() {
  const [rows, setRows] = createSignal<number[]>([]);
  return <>
    <button onClick={() => setRows([])}>Reload empty rows</button>
    <For each={rows()} fallback={<Empty />}>{row => row}</For>
  </>;
}

render(() => <App />, document.getElementById("root")!);
