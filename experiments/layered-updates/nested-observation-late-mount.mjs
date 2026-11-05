import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { createSignal, createRoot, createMemo, createRenderEffect, flush, latest, isPending } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const first = Promise.withResolvers(),
  second = Promise.withResolvers();
const [revision, setRevision] = createSignal(0);
let source, disposeSource, disposeProbe;
const frames = [];
createRoot(dispose => {
  disposeSource = dispose;
  source = createMemo(() => (revision() ? second.promise : first.promise));
  createRenderEffect(source, () => {});
});
flush();
first.resolve(0);
await turn();
setRevision(1);
flush();
assert.equal(
  isPending(() => source()),
  true
);
assert.equal(
  latest(() => isPending(() => source())),
  true
);
createRoot(dispose => {
  disposeProbe = dispose;
  const probe = createMemo(() => latest(() => isPending(() => source())));
  createRenderEffect(
    probe,
    value => {
      frames.push(value);
    },
    { schedule: true }
  );
});
flush();
assert.deepEqual(frames, [true]);
second.resolve(1);
await turn();
assert.deepEqual(frames, [true, false]);
console.log(JSON.stringify({ frames }));
disposeProbe();
disposeSource();
flush();
