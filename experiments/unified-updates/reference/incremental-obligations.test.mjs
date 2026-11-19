import assert from 'node:assert/strict';
import { test } from 'node:test';
import { UnifiedScheduler } from './unified-scheduler.mjs';
import { UnifiedScheduler as Stage51Scheduler } from '../results/incremental-obligations-stage51/after.mjs';
import { UnifiedScheduler as PreviousScheduler } from '../results/incremental-obligations-stage51/before.mjs';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));

for (const trace of [false, true]) {
  test(`queued source writes coalesce without joining independent sources (trace=${trace})`, async () => {
    const s = new UnifiedScheduler({ trace }), answer = Promise.withResolvers();
    const a = s.source('a', 0), b = s.source('b', 0);
    const slow = s.memo('slow', read => read(a) ? answer.promise : 0);
    const av = s.render('av', read => [read(a), read(slow)]);
    const bv = s.render('bv', read => read(b));
    for (let value = 1; value <= 10; value++) s.write(a, value);
    assert.equal(s.updates.size, 1);
    s.write(b, 20); s.flush();
    assert.deepEqual(s.value(av), [0, 0]);
    assert.equal(s.value(bv), 20);
    answer.resolve(100); await turn();
    assert.deepEqual(s.value(av), [10, 100]);
    assert.equal(s.updates.size, 0);
  });

  test(`same-action nested guesses keep independent publication contexts (trace=${trace})`, async () => {
    const s = new UnifiedScheduler({ trace });
    const answer = Promise.withResolvers();
    const base = s.source('base', 0), a = s.optimistic('a', base);
    const input = s.memo('input', read => read(a) === 1 ? answer.promise : 0);
    const b = s.optimistic('b', input);
    const av = s.render('av', read => read(a)), bv = s.render('bv', read => read(b));
    const action = s.begin();
    s.guess(a, 1, { action }); s.guess(b, 2, { action }); s.flush();
    assert.deepEqual([s.value(av), s.value(bv)], [0, 2]);
    s.close(action);
    assert.deepEqual([s.value(av), s.value(bv)], [0, 2]);
    answer.resolve(10); await turn();
    assert.deepEqual([s.value(av), s.value(bv)], [0, 0]);
    assert.equal(s.updates.size, 0);
  });

  test(`discovering existing origins is linear through a synchronous chain (trace=${trace})`, () => {
    class Counted extends UnifiedScheduler {
      visits = 0;
      mark(...args) { this.visits++; return super.mark(...args); }
    }
    const s = new Counted({ trace }), source = s.source('source', 0);
    let last = source;
    for (let depth = 0; depth < 64; depth++) {
      const previous = last;
      last = s.memo(`step${depth}`, read => read(previous) + 1);
    }
    const shown = s.render('shown', read => read(last));
    for (let value = 1; value <= 8; value++) {
      s.visits = 0;
      s.write(source, value); s.flush();
      assert.equal(s.value(shown), 64 + value);
      assert.ok(s.visits <= 66, `repeated notification walks: ${s.visits}`);
      assert.equal(s.updates.size, 0);
    }
  });

  test(`a second write in an existing origin still invalidates its readers (trace=${trace})`, async () => {
    const s = new UnifiedScheduler({ trace }), answers = new Map();
    const source = s.source('source', 0);
    const derived = s.memo('derived', read => {
      const value = read(source);
      if (!value) return 0;
      const gate = Promise.withResolvers(); answers.set(value, gate);
      return gate.promise;
    });
    const pair = s.render('pair', read => [read(source), read(derived)]);
    const update = s.write(source, 1); s.flush();
    s.write(source, 2, { group: update }); s.flush();
    answers.get(1).resolve(10); await turn();
    assert.deepEqual(s.value(pair), [0, 0]);
    answers.get(2).resolve(20); await turn();
    assert.deepEqual(s.value(pair), [2, 20]);
    assert.equal(s.updates.size, 0);
  });
}

// Replay the same changing graph using the conservative operational model.
// Compare actual callbacks, values, live groups, and settled cleanup; cached
// affected-node enumeration runs with trace=false as in the public adapter.
async function campaign(Model, seed, trace = false) {
  const s = new Model({ trace }), flights = [], actions = [], history = [], snapshots = [];
  let state = seed;
  const random = n => ((state = (Math.imul(state, 1664525) + 1013904223) >>> 0) >>> 16) % n;
  const source = s.source('source', 0), choose = s.source('choose', false), visible = s.source('visible', true);
  const a = s.optimistic('a', source), b = s.optimistic('b', source);
  const input = s.memo('input', read => {
    const value = read(choose) ? read(a) + read(b) : read(a);
    if (!value) return 0;
    const gate = Promise.withResolvers(); flights.push({ ...gate, value });
    return gate.promise;
  });
  const c = s.optimistic('c', input);
  let shown = null;
  s.render('shown', read => {
    const value = read(visible) ? [read(c), read(c) * 2] : null;
    s.onPublish(() => { shown = value; history.push(value); });
    return value;
  });
  for (let step = 0; step < 100; step++) {
    const op = random(7), value = random(4);
    if (op === 0) s.write(source, value);
    else if (op === 1) s.write(choose, !!(value % 2));
    else if (op === 2) s.write(visible, !!(value % 2));
    else if (op === 3 || op === 4) {
      const action = s.begin(); actions.push(action);
      s.guess([a, b, c][value % 3], op === 3 ? value : x => x + 1, { action });
    } else if (op === 5 && actions.length) s.close(actions.splice(value % actions.length, 1)[0]);
    else if (op === 6 && flights.length) {
      const flight = flights.splice(value % flights.length, 1)[0];
      flight.resolve(flight.value); await turn();
    }
    s.flush(); snapshots.push(shown);
    if (shown) assert.equal(shown[1], shown[0] * 2);
  }
  for (const action of actions) s.close(action);
  s.write(visible, false); s.flush();
  for (let pass = 0; pass < 30 && (s.updates.size || flights.length); pass++) {
    for (const flight of flights.splice(0)) flight.resolve(flight.value);
    await turn(); s.flush();
  }
  assert.equal(s.updates.size, 0);
  assert.equal(s.inputObservers.size, 0);
  assert.equal(s.scopedBoundaries.size, 0);
  for (const node of [c, input, a, b, source, choose, visible]) s.dispose(node);
  assert.equal(s.affected().length, 0);
  return { history, snapshots };
}

for (const seed of [3, 17, 83, 211]) test(`cached pending-origin discovery preserves publication traces (seed=${seed})`, async () => {
  assert.deepEqual(await campaign(Stage51Scheduler, seed), await campaign(PreviousScheduler, seed));
});

// Stage 53 intentionally changes cross-layer arbitration. The previous models
// remain an oracle for the archived stage 51 optimization, not for this ruling.
for (const seed of [3, 17, 83, 211]) test(`combined arbitration preserves callbacks across enumeration strategies (seed=${seed})`, async () => {
  assert.deepEqual(await campaign(UnifiedScheduler, seed, false), await campaign(UnifiedScheduler, seed, true));
});
