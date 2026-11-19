// Shared public-API timelines for pinned next and the real scalar core build.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { action, createRoot, createMemo, createRenderEffect, createSignal, isPending, refresh, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const report = {};

{
  const answer = Promise.withResolvers(), end = Promise.withResolvers();
  let source, dispose, result = 0, delivered = null;
  const shown = { value: -1, pending: false }, events = [];
  createRoot(d => {
    dispose = d;
    source = createMemo(() => result);
    createRenderEffect(source, value => { shown.value = value; }, { schedule: true });
    if (isPending)
      createRenderEffect(() => isPending(source), value => { shown.pending = value; }, { schedule: true });
  });
  flush();
  const running = action(function* () {
    result = answer.promise;
    delivered = yield refresh(source);
    yield end.promise;
  })();
  await turn();
  events.push({ phase: "refetch pending", ...shown, delivered });
  assert.deepEqual(shown, { value: 0, pending: false });
  answer.resolve(2);
  await turn();
  events.push({ phase: "answer received; action open", ...shown, delivered });
  assert.deepEqual({ ...shown, delivered }, { value: 0, pending: false, delivered: 2 });
  end.resolve(); await running; await turn();
  events.push({ phase: "action ended", ...shown, delivered });
  assert.deepEqual(shown, { value: 2, pending: false });
  dispose(); flush();
  report.ownAction = events;
}

{
  const end = Promise.withResolvers();
  let source, set, dispose, delivered = null, shown = -1;
  createRoot(d => {
    dispose = d;
    const [input, write] = createSignal(0);
    set = write;
    source = createMemo(() => input() * 2);
    createRenderEffect(source, value => { shown = value; }, { schedule: true });
  });
  flush();
  const running = action(function* () { set(1); yield end.promise; })();
  await turn();
  const pending = refresh(source).then(value => { delivered = value; });
  await turn();
  report.foreignAction = [{ phase: "foreign action open", shown, delivered }];
  assert.deepEqual([shown, delivered], [0, null]);
  end.resolve(); await running; await pending; await turn();
  report.foreignAction.push({ phase: "foreign action ended", shown, delivered });
  assert.deepEqual([shown, delivered], [2, 2]);
  dispose(); flush();
}

{
  let source, dispose;
  createRoot(d => { dispose = d; source = createMemo(() => 1); });
  source();
  const delivered = [];
  refresh(source).then(value => { delivered.push(value); });
  await Promise.resolve();
  refresh(source).then(value => { delivered.push(value); });
  await turn();
  report.equalSupersession = delivered;
  assert.deepEqual(delivered, [1, 1]);
  dispose(); flush();
}
console.log(JSON.stringify(report, null, 2));
