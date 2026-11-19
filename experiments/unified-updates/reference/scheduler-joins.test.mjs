import { UnifiedScheduler } from './unified-scheduler.mjs';
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { scenario } from './join-order-search.mjs';
import { RevisableScheduler } from './revisable-scheduler.mjs';
import { LayerOrderScheduler } from './layer-order-scheduler.mjs';
import { ActiveLayerScheduler } from './active-layer-scheduler.mjs';
import { LifetimeScheduler } from './lifetime-scheduler.mjs';
import { PendingScheduler } from './pending-scheduler.mjs';
const Model = process.env.UNIFIED ? UnifiedScheduler : process.env.OBSERVATION ? PendingScheduler : process.env.LIFETIME ? LifetimeScheduler : process.env.ACTIVE_LAYER ? ActiveLayerScheduler : process.env.LAYER_ORDER ? LayerOrderScheduler : process.env.REVISABLE ? RevisableScheduler : undefined;

for (const reverse of [false, true]) {
  test(`a newly discovered lower peer join extends the child's exclusion (reverse=${reverse})`, async () => {
    const result = await scenario(reverse, Model);
    assert.deepEqual(result.held, [0, 0, 10, false, 0, 10]);
    assert.deepEqual(result.final, [1, 2, 10, true, 3, 12]);
    for (const frame of result.publications) {
      assert.equal(frame['show:p'], frame['show:enabled'] ? frame['show:a'] + frame['show:b'] : 0);
      assert.equal(frame['show:q'], frame['show:c'] + frame['show:b']);
    }
  });
}

test('the accepted join is invariant under finite traversal, read-order and identity-memo changes', async () => {
  for (const wrapped of [false, true]) for (const readBFirst of [false, true]) {
    for (let seed = 0; seed < 12; seed++) {
      const result = await scenario(false, Model, { seed, wrapped, readBFirst });
      assert.deepEqual(result.held, [0, 0, 10, false, 0, 10], JSON.stringify({ seed, wrapped, readBFirst }));
      assert.deepEqual(result.final, [1, 2, 10, true, 3, 12]);
      for (const frame of result.publications) {
        assert.equal(frame['show:p'], frame['show:enabled'] ? frame['show:a'] + frame['show:b'] : 0);
        assert.equal(frame['show:q'], frame['show:c'] + frame['show:b']);
      }
    }
  }
});
