import assert from 'node:assert/strict';
import { test } from 'node:test';
import { PendingScheduler as PendingModel } from './pending-scheduler.mjs';
import { UnifiedScheduler } from './unified-scheduler.mjs';
const PendingScheduler = process.env.UNIFIED ? UnifiedScheduler : PendingModel;
const turn = () => new Promise(resolve => setTimeout(resolve, 0));

for (const reverse of [false, true]) test(`an override can publish before its first input exists (reverse=${reverse})`, async () => {
  const s = new PendingScheduler(), initial = Promise.withResolvers(), calls = [];
  const input = s.memo('input', () => initial.promise);
  const view = s.optimistic('view', input);
  const result = s.memo('result', read => {
    const value = read(view), call = { value, ...Promise.withResolvers() };
    calls.push(call); return call.promise;
  });
  const display = s.render('display', read => [read(view), read(result)]);
  if (reverse) s.nodes.reverse();
  const action = s.begin(); s.guess(view, 1, { action }); s.flush();
  calls.findLast(call => call.value === 1).resolve(1); await turn();
  assert.deepEqual(s.value(display), [1, 1]);
  assert.equal(s.value(input), undefined);
  s.close(action);
  assert.deepEqual(s.value(display), [1, 1]);
  initial.resolve(2); await turn();
  calls.findLast(call => call.value === 2).resolve(2); await turn();
  assert.deepEqual(s.value(display), [2, 2]);
  assert.equal(s.updates.size, 0);
});
