import assert from 'node:assert/strict';
import { setImmediate } from 'node:timers/promises';
import { createRoot, createSignal, createMemo, createRenderEffect, flush } from '@solidjs/signals';

const mode = process.argv[2] ?? 'same-recovery';
assert.ok(['same-recovery', 'changed-recovery', 'no-error'].includes(mode));
const cause = error => error instanceof Error && Object.hasOwn(error, 'cause') ? error.cause : error;
// Only observes the rejection from Solid's own Promise callback; it does not
// replace/wrap the Promise, its .then method, or any Solid operation.
process.on('unhandledRejection', error => console.log('Unhandled callback rejection:', cause(error)));
let finish, dispose;
const pending = new Promise(resolve => { finish = resolve; });
const rendered = [];
const app = createRoot(d => {
  dispose = d;
  const [waiting, setWaiting] = createSignal(false);
  const [stage, setStage] = createSignal(0);
  const b = createMemo(() => waiting() ? pending : 1);
  const a = createMemo(() => {
    if (stage() === 1) throw 99;
    return stage() === 2 ? 7 : 1;
  });
  const sum = createMemo(() => b() + a());
  createRenderEffect(sum, value => { rendered.push(value); });
  return { setWaiting, setStage, sum };
});
try {
  flush(); // Initially renders 1 + 1 = 2.
  app.setWaiting(true);
  if (mode !== 'no-error') app.setStage(1);
  flush(); // Pending b holds the frame; a has thrown 99.
  app.setStage(mode === 'changed-recovery' ? 2 : 0);
  flush(); // a recovers successfully while b is still pending.
  finish(2);
  await setImmediate();
  flush();
  let read;
  try { read = { returned: app.sum() }; }
  catch (error) { read = { threw: cause(error) }; }
  const expected = mode === 'changed-recovery' ? 9 : 3;
  console.log({ mode, expected: { rendered: [2, expected], read: { returned: expected } }, actual: { rendered, read } });
  assert.deepEqual(rendered, [2, expected], 'The successful recovery should render when the pending input resolves');
  assert.deepEqual(read, { returned: expected });
} finally {
  dispose();
}
