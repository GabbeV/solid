// Verifies that the repros fail their intended-behavior assertions, and that
// the paired controls pass. Each case gets a fresh, unmodified Solid instance.
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
const metadata = createRequire(import.meta.url)('@solidjs/signals/package.json');
assert.equal(metadata.version, '2.0.0-rc.15');
const next = metadata.reproSourceCommit === 'd2ad8b288886a5c7171e6746ccc019ad1d08d8ab';
console.log(next ? `Solid next ${metadata.reproSourceCommit}` : 'Published @solidjs/signals@2.0.0-rc.15 (older than pinned next)');
const cases = [
  ['empty-flatten.mjs', 'immediate', 'empty iterable object', 1],
  ['empty-flatten.mjs', 'direct', "actual: 'undefined'", 0],
  ['empty-flatten.mjs', 'native', "actual: 'undefined'", 0],
  ...(next ? [
    ['held-error-recovery.mjs', 'same-recovery', 'threw: 1', 1],
    ['held-error-recovery.mjs', 'changed-recovery', 'threw: 7', 1],
    ['held-function-value.mjs', 'held', "returned: 'string'", 1],
    ['held-function-value.mjs', 'no-hold', "returned: 'function'", 0],
    ['held-function-value.mjs', 'plain', "returned: 'function'", 0]
  ] : []),
  ['held-error-recovery.mjs', 'no-error', 'returned: 3', 0]
];
for (const [file, mode, observation, status] of cases) {
  const run = spawnSync(process.execPath, [file, mode], {
    cwd: fileURLToPath(new URL('.', import.meta.url)), encoding: 'utf8', timeout: 10000
  });
  assert.equal(run.error, undefined);
  assert.equal(run.status, status, `${file} ${mode}\n${run.stdout}\n${run.stderr}`);
  assert.ok(run.stdout.includes(observation), `${file} ${mode}\n${run.stdout}\n${run.stderr}`);
  if (status === 1) assert.match(run.stderr, /AssertionError/);
  if (file === 'held-error-recovery.mjs' && status === 1) {
    assert.match(run.stderr, /\[REACTIVITY_HALTED\]/);
    assert.ok(run.stdout.includes(`Unhandled callback rejection: ${mode === 'same-recovery' ? 1 : 7}`));
  }
  console.log(`${file} ${mode}: ${status ? 'reproduced failure' : 'control passed'}`);
}
if (!next) console.log('Held recovery requires the newer next commit: run npm run use:next, then npm test.');
