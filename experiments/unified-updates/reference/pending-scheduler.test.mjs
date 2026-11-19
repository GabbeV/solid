import assert from 'node:assert/strict';
import { test } from 'node:test';
import { PendingScheduler as PendingModel } from './pending-scheduler.mjs';
import { UnifiedScheduler } from './unified-scheduler.mjs';
const PendingScheduler = process.env.UNIFIED ? UnifiedScheduler : PendingModel;
const turn = () => new Promise(resolve => setTimeout(resolve, 0));

test('equal pending-false work and its owned child survive the action release', async () => {
  const s = new PendingScheduler(), revision = s.source('revision', 0), answer = Promise.withResolvers();
  const input = s.memo('input', read => read(revision) ? answer.promise : 0);
  const view = s.optimistic('view', input), calls = [], owners = [];
  const status = s.render('status', () => s.isPending(view));
  const label = s.render('label', read => {
    const pending = s.isPending(view), value = read(view);
    const owner = { pending, value, cleaned: 0 }; owners.push(owner);
    s.onCleanup(() => owner.cleaned++);
    s.render('owned', () => `${pending}:${value}`);
    if (pending) return 'pending';
    if (!value) return 'idle';
    const call = { owner, ...Promise.withResolvers() }; calls.push(call); return call.promise;
  });
  const action = s.begin(); s.write(revision, 1, { group: action }); s.guess(view, 1, { action }); s.flush();
  assert.deepEqual([s.value(status), s.value(label)], [true, 'pending']);
  answer.resolve(1); await turn();
  const confirming = calls.at(-1), count = calls.length;
  assert(confirming);
  assert.deepEqual([s.value(status), s.value(label)], [true, 'pending']);
  s.close(action);
  assert.equal(calls.length, count);
  assert.equal(confirming.owner.cleaned, 0);
  confirming.resolve('settled'); await turn();
  assert.deepEqual([s.value(status), s.value(label)], [false, 'settled']);
  assert.equal(s.updates.size, 0);
  s.dispose(label); s.dispose(status); s.dispose(view);
  assert(owners.every(owner => owner.cleaned === 1));
  assert.equal(s.observations.size, 0);
});

test('repeated observed action cycles release all update and observation-owned records', () => {
  const s = new PendingScheduler(), x = s.source('x', 0);
  const pair = s.render('pair', read => [s.isPending(x), read(x)]);
  const count = s.nodes.length;
  for (let i = 1; i <= 100; i++) {
    const action = s.begin(); s.write(x, i, { group: action }); s.flush();
    assert.deepEqual(s.value(pair), [true, i - 1]);
    s.close(action);
    assert.deepEqual(s.value(pair), [false, i]);
    assert.equal(s.nodes.length, count);
    assert.equal(s.observations.size, 1);
    assert.equal(s.updates.size, 0);
    assert.equal(s.couplings.length, 0);
    assert.equal(s.joins.length, 0);
  }
  s.dispose(pair); s.dispose(x);
  assert.equal(s.observations.size, 0);
  assert.equal(s.nodes.length, 0);
});

for (const publishTrue of [false, true]) test(`retirement replaces pending work and holds false with its consumers (revealed=${publishTrue})`, async () => {
  const s = new PendingScheduler(), x = s.source('x', 0);
  const pendingWork = Promise.withResolvers(), settledWork = Promise.withResolvers();
  const status = s.render('status', () => s.isPending(x));
  const value = s.render('value', read => read(x));
  const label = s.render('label', read => {
    const pending = s.isPending(x), value = read(x);
    if (pending) return pendingWork.promise;
    return value ? settledWork.promise : 'false:0';
  });
  const action = s.begin(); s.write(x, 1, { group: action }); s.flush();
  if (publishTrue) { pendingWork.resolve('true:0'); await turn(); }
  const held = [s.value(status), s.value(value), s.value(label)];
  s.close(action);
  assert.deepEqual([s.value(status), s.value(value), s.value(label)], held);
  settledWork.resolve('false:1'); await turn();
  assert.deepEqual([s.value(status), s.value(value), s.value(label)], [false, 1, 'false:1']);
  if (!publishTrue) { pendingWork.reject(new Error('obsolete')); await turn(); }
  assert.deepEqual([s.value(status), s.value(value), s.value(label)], [false, 1, 'false:1']);
  assert.equal(s.updates.size, 0);
});

test('a late conditional pending reader is independent of disjoint observation activity', () => {
  function run(extra) {
    const s = new PendingScheduler(), x = s.source('x', 0), unrelated = s.source('unrelated', 0);
    if (extra) s.render('unrelatedStatus', () => s.isPending(unrelated));
    const a = s.begin(); s.write(x, 1, { group: a });
    const b = s.begin(); s.write(unrelated, 1, { group: b }); s.flush();
    const late = s.render('late', read => {
      const value = read(x);
      return value === 0 ? `${s.isPending(x)}:${value}` : `value:${value}`;
    });
    s.flush();
    const held = s.value(late);
    s.close(a); s.close(b);
    return { held, final: s.value(late), history: late.observer.history };
  }
  assert.deepEqual(run(false), run(true));
  assert.equal(run(false).held, 'true:0');
});

test('ordinary async consequences still hold the source pending', async () => {
  const s = new PendingScheduler(), x = s.source('x', 0), work = Promise.withResolvers();
  const derived = s.memo('derived', read => read(x) ? work.promise : 0);
  const screen = s.render('screen', read => [read(x), read(derived)]);
  const status = s.render('status', () => s.isPending(x));
  s.write(x, 1); s.flush();
  assert.deepEqual(s.value(screen), [0, 0]);
  assert.equal(s.value(status), true);
  work.resolve(1); await turn();
  assert.deepEqual(s.value(screen), [1, 1]);
  assert.equal(s.value(status), false);
});

for (const reverse of [false, true]) test(`pending publishes with committed x through an ordinary memo (reverse=${reverse})`, () => {
  const s = new PendingScheduler(), x = s.source('x', 0);
  const status = s.memo('status', () => s.isPending(x));
  const pair = s.render('pair', read => [read(status), read(x)]);
  s.render('status', read => read(status));
  if (reverse) s.nodes.reverse();
  const action = s.begin(); s.write(x, 1, { group: action }); s.flush();
  assert.deepEqual(s.value(pair), [true, 0]);
  assert.equal(s.isPending(x), true);
  s.close(action);
  assert.deepEqual(s.value(pair), [false, 1]);
  assert.equal(s.isPending(x), false);
  for (const frame of s.publications) assert.equal(frame.pair[0], frame.status);
  assert.equal(s.updates.size, 0);
});

test('lazy pending identity survives its first reader and shares an async consequence', async () => {
  const s = new PendingScheduler(), x = s.source('x', 0), gate = Promise.withResolvers();
  const first = s.render('first', () => s.isPending(x));
  const second = s.render('second', () => s.isPending(x));
  const label = s.render('label', () => s.isPending(x) ? gate.promise : 'idle');
  const action = s.begin(); s.write(x, 1, { group: action }); s.flush();
  assert.deepEqual([s.value(first), s.value(second), s.value(label), s.isPending(x)], [false, false, 'idle', false]);
  s.dispose(first);
  gate.resolve('pending'); await turn();
  assert.deepEqual([s.value(second), s.value(label), s.isPending(x)], [true, 'pending', true]);
  assert.equal(s.observations.size, 1);
  s.close(action);
  assert.deepEqual([s.value(second), s.value(label), s.isPending(x)], [false, 'idle', false]);
  assert.equal(s.updates.size, 0);
});

test('a matching answer can release pending while the guessing action remains open', async () => {
  const s = new PendingScheduler(), revision = s.source('revision', 0), answer = Promise.withResolvers();
  const input = s.memo('input', read => read(revision) ? answer.promise : 0);
  const view = s.optimistic('view', input);
  const screen = s.render('screen', read => [read(view), s.isPending(view)]);
  const action = s.begin(); s.write(revision, 1, { group: action }); s.guess(view, 1, { action }); s.flush();
  assert.deepEqual(s.value(screen), [1, true]);
  answer.resolve(1); await turn();
  assert.deepEqual(s.value(screen), [1, false]);
  assert.equal(action.ownScopes.size, 1);
  s.close(action);
  assert.deepEqual(s.value(screen), [1, false]);
  assert.equal(s.updates.size, 0);
});
