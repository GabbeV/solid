import { pathToFileURL } from "node:url";
const { createSignal, createMemo, createRoot, createRenderEffect, flush } = await import(
  pathToFileURL(process.argv[2])
);
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const iterators = [];
const stream = {
  [Symbol.asyncIterator]() {
    const record = { requests: [], closed: 0 };
    iterators.push(record);
    return {
      next() {
        const answer = Promise.withResolvers();
        record.requests.push(answer);
        return answer.promise;
      },
      async return() {
        record.closed++;
        return { done: true };
      }
    };
  }
};
const [revision, setRevision] = createSignal(0);
let shown = 0,
  dispose;
createRoot(d => {
  dispose = d;
  const value = createMemo(() => (revision() ? stream : 0));
  createRenderEffect(value, v => {
    shown = v;
  });
});
flush();
setRevision(1);
flush();
setRevision(2);
flush();
iterators[1].requests[0].resolve({ done: false, value: 20 });
await turn();
const current = shown;
iterators[0].requests[0].resolve({ done: false, value: 10 });
await turn();
console.log(
  JSON.stringify({ current, afterClosedAnswer: shown, closed: iterators.map(i => i.closed) })
);
dispose();
flush();
