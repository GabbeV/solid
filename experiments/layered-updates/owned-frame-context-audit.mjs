import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const {
  action, createMemo, createOptimistic, createRenderEffect, createRoot,
  createSignal, flush, onCleanup
} = await import(pathToFileURL(process.argv[2]));
const end = Promise.withResolvers(), answer = Promise.withResolvers();
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const cleanups = [], snapshots = [];
const owned = process.argv[3] !== "direct";
const reads = process.argv[4] || "new";
const shown = { branch: false, outside: "false/false", details: 0 };
let generation = 0, start, drag;
const dispose = createRoot(dispose => {
  const [view, guess] = createOptimistic(() => false);
  const [moving, setMoving] = createSignal(false);
  drag = () => setMoving(true);
  const condition = createMemo(() => {
    const frame = ++generation;
    onCleanup(() => { cleanups.push(frame); });
    const child = owned ? createMemo(() => !!view()) : view;
    return reads === "new" ? (child() ? !moving() : view())
      : reads === "old" ? (child() ? true : moving())
      : child() !== moving();
  });
  const details = createMemo(() => view() ? answer.promise : 0);
  createRenderEffect(condition, value => { shown.branch = value; }, { schedule: true });
  createRenderEffect(details, value => { shown.details = value; }, { schedule: true });
  createRenderEffect(() => `${moving()}/${view()}`, value => { shown.outside = value; }, { schedule: true });
  start = action(function* () { guess(true); yield end.promise; });
  return dispose;
});
const snapshot = phase => snapshots.push({ phase, shown: { ...shown }, generation, cleanups: [...cleanups] });
flush(); snapshot("initial");
const running = start(); flush(); await turn(); snapshot("guess pending");
assert.equal(cleanups.includes(1), false, "the displayed frame survives the pending replacement");
drag(); flush(); await turn(); snapshot("independent drag update");
assert.equal(cleanups.includes(1), false, "the displayed frame survives a stale-reader rerun");
answer.resolve(1); await turn(); snapshot("guess ready");
assert.equal(cleanups.includes(1), true, "publication retires the displayed frame");
end.resolve(); await running; await turn(); snapshot("reverted");
dispose(); flush(); snapshot("disposed");
assert.deepEqual(cleanups.toSorted((a, b) => a - b), Array.from({ length: generation }, (_, i) => i + 1));
console.log(JSON.stringify({ owned, reads, snapshots }, null, 2));
