// New acceptance contract, intentionally separate from historical model tests.
// The current reference fails it; never treat the older suite's pass as satisfying it.
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { scenario } from './depth-discovery-audit.mjs';
for (const actionLifetime of [false, true]) for (const reverse of [false, true]) {
  test(`dependency discovery must not change fetch arguments (action=${actionLifetime}, reverse=${reverse})`, async () => {
    const { checkpoints } = await scenario({ actionLifetime, reverse, fetches: true });
    const [before, after] = checkpoints;
    const selected = before.requests.at(-1);
    assert.equal(selected, '10:20');
    // This contract concerns selecting different input versions. It does not
    // independently legislate every same-argument rerun/ownership case.
    for (const key of after.requests.slice(before.requests.length))
      assert.equal(key, selected, 'Only dependency discovery occurred; selected input proposals did not change');
  });
}
