import assert from 'node:assert/strict';
import { test } from 'node:test';
import { DirectedScheduler } from './directed-scheduler.mjs';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));

for (const trace of [false, true]) test(`unrelated ordinary and optimistic proposals remain peers through renewed suspension (trace=${trace})`, async () => {
  const s = new DirectedScheduler({ trace }), lower = Promise.withResolvers(), flights = [];
  const revision = s.source('revision', 0), constant = s.source('constant', 0);
  const input = s.memo('input', read => read(revision) === 20 ? lower.promise : read(revision));
  const view = s.optimistic('view', constant);
  const label = s.memo('label', read => {
    const key = `${read(view)}:${read(input)}`;
    if (key === '0:0') return key;
    const gate = Promise.withResolvers(); flights.push({ key, ...gate }); return gate.promise;
  });
  const displays = [view, input, label].map(node => s.render(`show:${node.name}`, read => {
    const value = read(node);
    s.onPublish(() => assert.equal(s.value(label), `${s.value(view)}:${s.value(input)}`));
    return value;
  }));
  const action = s.begin();
  s.guess(view, 1, { action }); s.flush();
  s.write(revision, 10); s.flush();
  assert.deepEqual(flights.map(f => f.key), ['1:0', '1:10']);
  s.write(revision, 20); s.flush();
  s.guess(view, 2, { action }); s.flush();
  assert.deepEqual(displays.map(node => s.value(node)), [0, 0, '0:0']);
  assert(!flights.some(f => f.key === '2:0'));
  for (const flight of flights) flight.resolve(flight.key);
  await turn();
  assert.deepEqual(displays.map(node => s.value(node)), [0, 0, '0:0']);
  lower.resolve(20); await turn();
  assert.equal(flights.at(-1).key, '2:20');
  flights.at(-1).resolve('2:20'); await turn();
  assert.deepEqual(displays.map(node => s.value(node)), [2, 20, '2:20']);
  assert.equal(action.ownScopes.size, 1);
  for (const node of [...displays, label, view, input, revision, constant]) s.dispose(node);
  s.close(action);
  assert.equal(s.updates.size, 0);
  assert.equal(s.joins.length, 0);
});

for (const reverse of [false, true]) test(`an actual child still publishes above the whole entangled input group (reverse=${reverse})`, async () => {
  const s = new DirectedScheduler(), hold = Promise.withResolvers();
  const a = s.source('a', 0), b = s.source('b', 0), c = s.optimistic('c', a);
  const shared = s.memo('shared', read => read(a) + read(b) ? hold.promise : 0);
  const p = s.render('p', read => [read(a), read(b), read(shared)]);
  const q = s.render('q', read => [read(c), read(b)]);
  if (reverse) s.nodes.reverse();
  const lower = s.begin('lower');
  s.write(a, 1, { group: lower }); s.write(b, 2); s.flush();
  s.guess(c, 10); s.flush();
  assert.deepEqual(s.value(p), [0, 0, 0]);
  assert.deepEqual(s.value(q), [10, 0]);
  hold.resolve(3); await turn(); s.close(lower);
  assert.deepEqual(s.value(p), [1, 2, 3]);
  assert.deepEqual(s.value(q), [10, 2]);
  assert.equal(s.updates.size, 0);
});
