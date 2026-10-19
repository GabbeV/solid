import assert from 'node:assert/strict';
import { setImmediate } from 'node:timers/promises';
import { createRoot, createMemo, createRenderEffect, flush } from '@solidjs/signals';

// The control modes change only the outer wrapper around the same empty stream.
const mode = process.argv[2] ?? 'immediate';
assert.ok(['immediate', 'direct', 'native'].includes(mode));
const empty = {
  [Symbol.asyncIterator]() {
    return {
      next: () => ({ then: onFulfilled => onFulfilled({ done: true }) })
    };
  }
};
const result = mode === 'direct' ? empty
  : mode === 'native' ? Promise.resolve(empty)
  : { then: onFulfilled => onFulfilled(empty) };

let dispose;
const read = createRoot(d => {
  dispose = d;
  const read = createMemo(() => result);
  createRenderEffect(read, () => {});
  return read;
});
try {
  // The render observer activates the memo and handles the native control's
  // initial pending state. All three modes then have time to finish.
  await setImmediate();
  flush();
  const actual = read();
  console.log({ mode, expected: 'undefined', actual: actual === empty ? 'empty iterable object' : String(actual) });
  assert.equal(actual, undefined, 'An empty flattened stream should settle to undefined');
} finally {
  dispose();
}
