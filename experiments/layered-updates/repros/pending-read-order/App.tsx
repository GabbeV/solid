import { createMemo, createSignal, isPending } from "solid-js";

async function load(id: number) {
  await new Promise(resolve => setTimeout(resolve, 3000));
  return id * 10;
}

function IdFirst() {
  const [id, setId] = createSignal(0);
  const data = createMemo(() => {
    const value = id();
    isPending(id);
    return value === 0 ? 0 : load(value);
  });

  return (
    <section id="id-first">
      <h2>Read id first</h2>
      <button onClick={() => setId(1)}>Load item 1</button>
      <p>ID: <output data-value="id">{id()}</output></p>
      <p>Data: <output data-value="data">{data()}</output></p>
      <p>Pending: <output data-value="pending">{String(isPending(id))}</output></p>
    </section>
  );
}

function PendingFirst() {
  const [id, setId] = createSignal(0);
  const data = createMemo(() => {
    isPending(id);
    const value = id();
    return value === 0 ? 0 : load(value);
  });

  return (
    <section id="pending-first">
      <h2>Read pending first</h2>
      <button onClick={() => setId(1)}>Load item 1</button>
      <p>ID: <output data-value="id">{id()}</output></p>
      <p>Data: <output data-value="data">{data()}</output></p>
      <p>Pending: <output data-value="pending">{String(isPending(id))}</output></p>
    </section>
  );
}

export default function App() {
  return (
    <main style="font-family: sans-serif; padding: 24px">
      <h1>isPending: read order changes publication</h1>
      <p>Try each button separately. Each request takes three seconds. Reload to reset.</p>
      <p>The two memos differ only in the order of id() and isPending(id).</p>
      <div style="display: flex; gap: 64px; flex-wrap: wrap">
        <IdFirst />
        <PendingFirst />
      </div>
    </main>
  );
}
