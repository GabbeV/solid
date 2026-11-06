import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { createRoot, createMemo, createRenderEffect, flush, isPending } = await import(
  pathToFileURL(process.argv[2])
);
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const sourceAnswer = Promise.withResolvers(),
  aAnswer = Promise.withResolvers(),
  bAnswer = Promise.withResolvers();
const events = [],
  snapshots = [];
let dispose;
createRoot(d => {
  dispose = d;
  const source = createMemo(() => sourceAnswer.promise);
  const a = createMemo(() => aAnswer.promise);
  const b = createMemo(() => bAnswer.promise);
  const pending = createMemo(() => isPending(source));
  createRenderEffect(
    () => `${pending()}:${a()}`,
    value => {
      events.push(`A=${value}`);
    },
    { schedule: true }
  );
  createRenderEffect(
    () => `${pending()}:${b()}`,
    value => {
      events.push(`B=${value}`);
    },
    { schedule: true }
  );
});
flush();
for (const [name, answer, value] of [
  ["source", sourceAnswer, 0],
  ["A", aAnswer, 1],
  ["B", bAnswer, 2]
]) {
  answer.resolve(value);
  await turn();
  snapshots.push({ settled: name, events: [...events] });
}
assert.equal(snapshots[1].events.length, 0);
assert.deepEqual([...events].sort(), ["A=false:1", "B=false:2"]);
console.log(JSON.stringify(snapshots, null, 2));
dispose();
flush();
