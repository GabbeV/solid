import assert from 'node:assert/strict';
import { test } from 'node:test';
import { UnifiedScheduler } from './unified-scheduler.mjs';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));

function fixture({ trace = true, reverse = false, lowerOptimistic = false } = {}) {
  const s = new UnifiedScheduler({ trace }), flights = [], shown = {}, callbacks = [];
  const lowInput = s.source('lowInput', 0);
  const low = lowerOptimistic ? s.optimistic('low', lowInput) : lowInput;
  const highInput = s.source('highInput', 0);
  const parent = s.optimistic('parent', highInput);
  if (lowerOptimistic) { s.guess(parent, 1); s.flush(); }
  const high = s.optimistic('high', parent);
  const owners = [];
  const label = s.memo('label', read => {
    const key = `${read(high)}:${read(low)}`;
    const owner = { key, cleaned: 0 }; owners.push(owner);
    s.onCleanup(() => owner.cleaned++);
    if (key === `${lowerOptimistic ? 1 : 0}:0`) return key;
    const gate = Promise.withResolvers(); flights.push({ key, ...gate });
    return gate.promise;
  });
  const displays = [];
  for (const [name, node] of [['high', high], ['low', low], ['label', label]])
    displays.push(s.render(`show:${name}`, read => {
      const value = read(node);
      s.onPublish(() => {
        shown[name] = value;
        // Every committed accessor already agrees during each callback, even
        // though sibling callback delivery order itself is unspecified.
        callbacks.push([s.value(high), s.value(low), s.value(label)]);
      });
      return value;
    }));
  if (reverse && trace) s.nodes.reverse();
  const action = s.begin();
  const writeLow = value => lowerOptimistic ? s.guess(low, value) : s.write(low, value);
  const answer = async (key, error = false) => {
    const flight = flights.findLast(f => f.key === key);
    assert(flight, `Missing flight ${key}: ${flights.map(f => f.key)}`);
    if (error) flight.reject(new Error(key)); else flight.resolve(key);
    await turn();
  };
  const check = expected => {
    assert.deepEqual([shown.high, shown.low, shown.label], expected);
    for (const [hi, lo, value] of callbacks)
      if (value && typeof value === 'object') assert.equal(value.error, `${hi}:${lo}`);
      else assert.equal(value, `${hi}:${lo}`);
  };
  const drain = () => {
    for (const node of [...displays, label, high, parent, low, lowInput, highInput]) s.dispose(node);
    s.close(action);
    assert.equal(s.updates.size, 0);
    assert.equal(s.advances.length, 0);
    assert.equal(s.displaced.size, 0);
    assert(owners.every(owner => owner.cleaned === 1));
  };
  return { s, high, low, label, action, flights, owners, shown, answer, writeLow, check, drain };
}

for (const trace of [false, true]) for (const reverse of [false, true])
  for (const lowerOptimistic of [false, true]) {
    test(`ready lower proposal starts combined work immediately (trace=${trace}, reverse=${reverse}, optimistic=${lowerOptimistic})`, async () => {
      const f = fixture({ trace, reverse, lowerOptimistic });
      const { s, high, action, flights, answer, writeLow, check, drain } = f;
      const initial = lowerOptimistic ? 1 : 0;
      s.guess(high, 2, { action }); s.flush();
      writeLow(10); s.flush();
      assert.deepEqual(flights.map(f => f.key), ['2:0', '2:10']);
      check([initial, 0, `${initial}:0`]);
      const late = s.render('late', read => [read(high), read(f.low), read(f.label)]);
      assert.deepEqual(s.value(late), [initial, 0, `${initial}:0`]);
      await answer('2:0'); check([initial, 0, `${initial}:0`]);
      await answer('2:10'); check([2, 10, '2:10']);
      assert.deepEqual(s.value(late), [2, 10, '2:10']);
      assert.equal(action.ownScopes.size, 1);
      s.dispose(late); drain();
    });
  }

test('a lower open scope advances when it closes, without ending the guessing action', async () => {
  const { s, high, low, action, flights, answer, check, drain } = fixture();
  s.guess(high, 2, { action }); s.flush();
  const lower = s.begin('lower'); s.write(low, 10, { group: lower }); s.flush();
  assert.deepEqual(flights.map(f => f.key), ['2:0']);
  s.close(lower);
  assert.deepEqual(flights.map(f => f.key), ['2:0', '2:10']);
  await answer('2:10'); check([2, 10, '2:10']);
  assert.equal(action.ownScopes.size, 1);
  drain();
});

test('a separate lower async consequence holds admission until its answer arrives', async () => {
  const { s, high, low, action, flights, answer, check, drain } = fixture();
  const gate = Promise.withResolvers();
  const slow = s.memo('slow', read => read(low) ? gate.promise : 0);
  const display = s.render('slowDisplay', read => read(slow));
  s.guess(high, 2, { action }); s.flush();
  s.write(low, 10); s.flush();
  assert.deepEqual(flights.map(f => f.key), ['2:0']);
  gate.resolve(10); await turn();
  assert.deepEqual(flights.map(f => f.key), ['2:0', '2:10']);
  check([0, 0, '0:0']); assert.equal(s.value(display), 0);
  await answer('2:10'); check([2, 10, '2:10']);
  assert.equal(s.value(display), 10);
  s.dispose(display); s.dispose(slow); drain();
});

test('expiration replaces combined work and releases both proposals with the correction', async () => {
  const { s, high, action, answer, writeLow, check, drain } = fixture();
  s.guess(high, 2, { action }); s.flush();
  writeLow(10); s.flush();
  s.close(action);
  await answer('2:10'); check([0, 0, '0:0']);
  await answer('0:10'); check([0, 10, '0:10']);
  assert.equal(s.updates.size, 0);
  drain();
});

test('combined error and later recovery replace owners and publish coherently', async () => {
  const { s, high, low, label, action, owners, answer, writeLow, check, drain } = fixture();
  s.guess(high, 2, { action }); s.flush();
  writeLow(10); s.flush();
  assert.equal(owners.find(o => o.key === '2:0').cleaned, 1);
  assert.equal(owners[0].cleaned, 0);
  await answer('2:10', true);
  // Error frames are delivered through the model's render observer. A failed
  // callback does not get a successful publication callback.
  assert.deepEqual([s.value(high), s.value(low), s.value(label)], [2, 10, { error: '2:10' }]);
  writeLow(20); s.flush();
  await answer('2:20'); check([2, 20, '2:20']);
  assert.equal(owners[0].cleaned, 1);
  drain();
});

test('repeated combined supersession retains one eligible answer and drains bookkeeping', async () => {
  const { s, high, action, flights, answer, writeLow, check, drain } = fixture();
  for (let n = 1; n <= 30; n++) {
    s.guess(high, n, { action }); s.flush();
    writeLow(n * 10); s.flush();
    for (const flight of flights.slice(0, -1)) flight.resolve(flight.key);
    await turn();
    await answer(`${n}:${n * 10}`); check([n, n * 10, `${n}:${n * 10}`]);
    assert.equal(s.advances.length, 0);
    assert.equal(s.displaced.size, 0);
    assert.equal(s.updates.size, 1); // Only the open action lifetime remains.
  }
  drain();
});

for (const trace of [false, true]) for (const reverse of [false, true])
  for (const flushLower of [false, true]) {
    test(`a new optimistic context preserves unfinished lower work (trace=${trace}, reverse=${reverse}, flushLower=${flushLower})`, async () => {
      const { s, high, low, action, flights, answer, check, drain } = fixture({ trace, reverse });
      s.write(low, 10);
      if (flushLower) s.flush();
      s.guess(high, 2, { action }); s.flush();
      assert.deepEqual(flights.map(f => f.key), ['0:10', '2:0']);
      check([0, 0, '0:0']);
      // The old lower answer has no publication rights after cancellation.
      await answer('0:10'); check([0, 0, '0:0']);
      await answer('2:0'); check([2, 0, '2:0']);
      await answer('2:10'); check([2, 10, '2:10']);
      drain();
    });
  }
