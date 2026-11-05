// Profile the real compiled runtime; this is not a replacement graph model.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { action, createMemo, createOptimistic, createRenderEffect, createRoot, flush } =
  await import(pathToFileURL(process.argv[2]));
let guess,
  dispose,
  value = 1,
  shown = 0;
createRoot(cleanup => {
  dispose = cleanup;
  let input = () => 0;
  for (let i = 0; i < 16; i++) {
    const [view, write] = createOptimistic(input);
    if (!i) guess = write;
    input = createMemo(() => view() + 1);
  }
  createRenderEffect(
    input,
    next => {
      shown = next;
    },
    { schedule: true }
  );
});
flush();
const end = Promise.withResolvers();
const running = action(function* () {
  guess(1);
  yield end.promise;
})();
flush();
const update = () => guess(++value);
for (let i = 0; i < 120000; i++) flush(update);
assert.equal(shown, value + 16);
dispose();
end.resolve();
await running;
flush();
