import assert from 'node:assert/strict';
import { test } from 'node:test';
import { LayerOrderScheduler } from './layer-order-scheduler.mjs';
import { scenario } from './crossed-children-audit.mjs';

for (const reverse of [false, true]) for (const peerLayer of [false, true]) {
  test(`both crossed children publish over the held parent layer (reverse=${reverse}, optimistic parents=${peerLayer})`, async () => {
    const result = await scenario(reverse, LayerOrderScheduler, { peerLayer });
    assert.deepEqual(result.held, [0, 0, 10, 20, 10, 20]);
    assert.deepEqual(result.final, [1, 2, 10, 20, 12, 21]);
    for (const frame of result.publications) {
      assert.equal(frame['show:p'], frame['show:c'] + frame['show:b']);
      assert.equal(frame['show:q'], frame['show:d'] + frame['show:a']);
    }
  });
}
