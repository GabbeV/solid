// Product shell and reviews fetch in parallel. Compare the publication selected
// by each Loading.on expression with separate controlled completion gates.
import { pathToFileURL } from "node:url";
const {
  createRoot, createSignal, createMemo, createRenderEffect,
  createLoadingBoundary, isPending, latest, flush
} = await import(pathToFileURL(process.argv[2]));
const on = process.argv[3] || "id";
const order = process.argv[4] || "product-first";
const productAnswer = Promise.withResolvers();
const reviewsAnswer = Promise.withResolvers();
const shown = {}, events = [], snapshots = [];
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
let set, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [id, setId] = createSignal("A");
  set = setId;
  const product = createMemo(() => {
    const value = id();
    return value === "A" ? "Product A" : productAnswer.promise.then(() => `Product ${value}`);
  });
  const reviews = createMemo(() => {
    const value = id();
    return value === "A" ? "Reviews A" : reviewsAnswer.promise.then(() => `Reviews ${value}`);
  });
  const trigger = on === "id" ? id : on === "data" ? reviews
    : on === "pending" ? () => isPending(reviews) : () => latest(id);
  const content = createLoadingBoundary(reviews, () => "Loading reviews…", { on: trigger });
  for (const [key, read] of Object.entries({ id, product, reviews: content }))
    createRenderEffect(read, value => {
      shown[key] = value;
      events.push({ key, value });
    }, { schedule: true });
});
const snapshot = phase => snapshots.push({ phase, shown: { ...shown } });
flush(); snapshot("initial A");
set("B"); flush(); await turn(); snapshot("both requests pending");
if (order === "product-first") productAnswer.resolve();
else reviewsAnswer.resolve();
await turn(); snapshot(order === "product-first" ? "product B ready" : "reviews B ready");
if (order === "product-first") reviewsAnswer.resolve();
else productAnswer.resolve();
await turn(); snapshot("both ready");
dispose(); flush();
console.log(JSON.stringify({ on, order, snapshots, events }, null, 2));
