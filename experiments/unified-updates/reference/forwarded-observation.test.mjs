import assert from 'node:assert/strict';
import { test } from 'node:test';
import { UnifiedScheduler } from './unified-scheduler.mjs';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const delay = () => {
  const calls = [];
  return {
    calls,
    run(value) {
      if (!value) return 0;
      const gate = Promise.withResolvers();
      calls.push({ value, ...gate });
      return gate.promise;
    },
    async answer(value) {
      for (const call of calls) if (call.value === value) call.resolve(value);
      await turn();
    }
  };
};

for (const reverse of [false, true]) {
  test(`removing the last observer releases forwarded input demand (reverse=${reverse})`, async () => {
    const s = new UnifiedScheduler(), work = delay();
    const source = s.source('source', 0);
    const input = s.memo('input', read => work.run(read(source)));
    const view = s.optimistic('view', input);
    const visible = s.render('visible', read => read(source));
    const observer = s.render('observer', read => read(view));
    s.guess(view, 10); s.flush();
    if (reverse) s.nodes.reverse();
    s.write(source, 1); s.flush();
    assert.equal(s.value(visible), 0);
    assert.equal(s.value(observer), 10);
    s.dispose(observer);
    assert.equal(s.value(visible), 1);
    assert.equal(s.value(input), undefined);
    // Reading an accessor imperatively does not enroll an observer.
    assert.equal(s.value(view), 10);
    await work.answer(1);
    assert.equal(s.value(input), 1);
    assert.equal(s.updates.size, 0);
    s.dispose(view);
    assert.equal(s.inputObservers.size, 0);
  });

  test(`a conditional removal in the input update releases its own hold (reverse=${reverse})`, () => {
    const s = new UnifiedScheduler(), work = delay();
    const source = s.source('source', 0), shown = s.source('shown', true);
    const input = s.memo('input', read => work.run(read(source)));
    const view = s.optimistic('view', input);
    const label = s.memo('label', read => read(shown) ? read(view) : 'hidden');
    const observer = s.render('observer', read => read(label));
    const visible = s.render('visible', read => read(source));
    s.guess(view, 10); s.flush();
    if (reverse) s.nodes.reverse();
    const update = s.write(source, 1); s.flush();
    assert.equal(s.value(visible), 0);
    s.write(shown, false, { group: update }); s.flush();
    assert.equal(s.value(observer), 'hidden');
    assert.equal(s.value(visible), 1);
    assert.equal(s.updates.size, 0);
  });

  test(`another held update has not removed the observer yet (reverse=${reverse})`, async () => {
    const s = new UnifiedScheduler(), work = delay(), hide = delay();
    const source = s.source('source', 0), shown = s.source('shown', true);
    const input = s.memo('input', read => work.run(read(source)));
    const view = s.optimistic('view', input);
    const observer = s.render('observer', read => read(shown) ? read(view) : 'hidden');
    const visible = s.render('visible', read => read(source));
    s.render('hideWork', read => hide.run(read(shown) ? 0 : 1));
    s.guess(view, 10); s.flush();
    if (reverse) s.nodes.reverse();
    s.write(source, 1); s.flush();
    s.write(shown, false); s.flush();
    assert.equal(s.value(observer), 10);
    assert.equal(s.value(visible), 0);
    await hide.answer(1);
    assert.equal(s.value(observer), 'hidden');
    assert.equal(s.value(visible), 1);
    assert.equal(s.updates.size, 0);
    for (const frame of s.publications)
      if (frame.visible === 1) assert.equal(frame.observer, 'hidden');
  });

  test(`an equal-valued owner can retire its observer without waiting for its input (reverse=${reverse})`, () => {
    const s = new UnifiedScheduler(), work = delay(), cleanups = [];
    const source = s.source('source', 0), shown = s.source('shown', true);
    const input = s.memo('input', read => work.run(read(source)));
    const view = s.optimistic('view', input);
    const owner = s.memo('owner', read => {
      if (read(shown)) {
        s.render('child', read => read(view));
        s.onCleanup(() => cleanups.push('child'));
      }
      return 0;
    });
    const visible = s.render('visible', read => [read(source), read(owner)]);
    s.guess(view, 10); s.flush();
    if (reverse) s.nodes.reverse();
    const update = s.write(source, 1); s.flush();
    s.write(shown, false, { group: update }); s.flush();
    assert.deepEqual(s.value(visible), [1, 0]);
    assert.deepEqual(cleanups, ['child']);
    assert.equal(s.updates.size, 0);
  });

  test(`a child override can publish above sibling proposals whose work it observes (reverse=${reverse})`, async () => {
    const s = new UnifiedScheduler(), work = delay();
    const base = s.source('base', 0), a = s.optimistic('a', base), b = s.optimistic('b', base);
    const sum = s.memo('sum', read => work.run(read(a) + read(b)));
    const c = s.optimistic('c', sum);
    const av = s.render('aValue', read => read(a)), bv = s.render('bValue', read => read(b));
    const cv = s.render('cValue', read => [read(c), read(c) * 2]);
    if (reverse) s.nodes.reverse();
    s.guess(a, 1); s.guess(b, 2); s.flush();
    s.guess(c, 10); s.flush();
    assert.deepEqual([s.value(av), s.value(bv), s.value(cv)], [0, 0, [10, 20]]);
    await work.answer(3);
    assert.deepEqual([s.value(av), s.value(bv), s.value(cv)], [1, 2, [10, 20]]);
    assert.equal(s.updates.size, 0);
  });
}

test('a pending probe alone does not forward observation', async () => {
  const s = new UnifiedScheduler(), work = delay();
  const source = s.source('source', 0);
  const input = s.memo('input', read => work.run(read(source)));
  const visible = s.render('visible', read => read(source));
  const status = s.render('status', () => s.isPending(input));
  s.write(source, 1); s.flush();
  assert.equal(s.value(visible), 1);
  assert.equal(s.value(status), true);
  assert.equal(s.inputObservers.size, 0);
  await work.answer(1);
  assert.equal(s.value(status), false);
  assert.equal(s.updates.size, 0);
});

test('forwarded observation does not wait for an obsolete guessed flight before correction', async () => {
  const s = new UnifiedScheduler(), work = delay();
  const source = s.source('source', 0), first = s.optimistic('first', source);
  const middle = s.memo('middle', read => work.run(read(first)));
  const second = s.optimistic('second', middle);
  const visible = s.render('visible', read => [read(first), read(second)]);
  const parent = s.begin(), child = s.begin();
  s.guess(first, 1, { action: parent }); s.flush();
  s.guess(second, 3, { action: child }); s.flush();
  assert.deepEqual(s.value(visible), [0, 3]);
  s.close(parent);
  assert.deepEqual(s.value(visible), [0, 3]);
  s.close(child);
  assert.deepEqual(s.value(visible), [0, 0]);
  assert.equal(s.updates.size, 0);
  await work.answer(1);
  assert.deepEqual(s.value(visible), [0, 0]);
  assert.equal(s.inputObservers.size, 0);
});

test('observation forwards through four overrides without merging their publication', async () => {
  const s = new UnifiedScheduler(), work = delay(), views = [];
  const source = s.source('source', 0);
  let previous = source;
  for (let depth = 0; depth < 4; depth++) {
    const input = previous;
    const derived = s.memo(`input${depth}`, read => work.run(read(input)));
    previous = s.optimistic(`view${depth}`, derived);
    views.push(previous);
  }
  const sourceDisplay = s.render('sourceDisplay', read => read(source));
  const display = s.render('display', read => [read(previous), read(previous) * 2]);
  s.write(source, 1); s.flush();
  for (let i = 0; i < views.length; i++) { s.guess(views[i], 3 + 2 * i); s.flush(); }
  assert.equal(s.value(sourceDisplay), 0);
  assert.deepEqual(s.value(display), [9, 18]);
  for (let pass = 0; pass < 10 && s.updates.size; pass++) {
    for (const call of work.calls) call.resolve(call.value);
    await turn();
  }
  assert.equal(s.value(sourceDisplay), 1);
  assert.deepEqual(s.value(display), [9, 18]);
  assert.equal(s.updates.size, 0);
  for (const view of views.toReversed()) s.dispose(view);
  assert.equal(s.inputObservers.size, 0);
});

test('removing the observer also releases a closed action waiting for its guessed input', () => {
  const s = new UnifiedScheduler(), work = delay();
  const source = s.source('source', 0);
  const input = s.memo('input', read => work.run(read(source)));
  const view = s.optimistic('view', input);
  const visible = s.render('visible', read => read(source));
  const observer = s.render('observer', read => read(view));
  const action = s.begin();
  s.write(source, 1, { group: action }); s.guess(view, 3, { action }); s.flush();
  assert.equal(s.value(observer), 3);
  s.close(action);
  assert.equal(s.value(visible), 0);
  s.dispose(observer);
  assert.equal(s.value(visible), 1);
  assert.equal(s.updates.size, 0);
});

test('an action can retire the owner observing its own guessed input', () => {
  const s = new UnifiedScheduler(), work = delay();
  const source = s.source('source', 0), shown = s.source('shown', true);
  const input = s.memo('input', read => work.run(read(source)));
  const view = s.optimistic('view', input);
  const visible = s.render('visible', read => read(source));
  s.memo('owner', read => {
    if (read(shown)) s.render('child', read => read(view));
    return 0;
  });
  const action = s.begin();
  s.write(source, 1, { group: action }); s.guess(view, 3, { action }); s.flush();
  s.write(shown, false, { group: action }); s.close(action);
  assert.equal(s.value(visible), 1);
  assert.equal(s.updates.size, 0);
});

test('repeated confirm, correction, and error cycles release forwarding and action records', async () => {
  const s = new UnifiedScheduler(), work = delay();
  const source = s.source('source', 0);
  const input = s.memo('input', read => work.run(read(source)));
  const view = s.optimistic('view', input);
  const visible = s.render('visible', read => read(source));
  const observer = s.render('observer', read => read(view));
  const nodeCount = s.nodes.length;
  for (let value = 1; value <= 40; value++) {
    const action = s.begin();
    s.write(source, value, { group: action });
    s.guess(view, value % 2 ? value : value + 100, { action }); s.flush();
    assert.equal(s.value(visible), value - 1);
    assert.equal(s.value(observer), value % 2 ? value : value + 100);
    s.close(action);
    assert.equal(s.value(visible), value - 1);
    for (const call of work.calls) if (call.value === value) {
      if (value % 5 === 0) call.reject(new Error(`failure ${value}`));
      else call.resolve(value);
    }
    await turn();
    assert.equal(s.value(visible), value);
    assert.deepEqual(s.value(observer), value % 5 ? value : { error: `failure ${value}` });
    assert.equal(s.updates.size, 0);
    assert.equal(s.actions.size, 0);
    assert.equal(s.inputObservers.size, 0);
    assert.equal(s.scopedBoundaries.size, 0);
    assert.equal(s.nodes.length, nodeCount);
    assert.equal(source.readers.size, 2);
    assert.equal(input.readers.size, 1);
  }
});

const uncachedPublications = new Map();
class UncachedScheduler extends UnifiedScheduler {
  observed(node, group) { return super.observed(node, group); }
}
for (const cached of [false, true]) for (const seed of [1, 17, 83, 211]) test(`changing observers and overlapping actions preserve publications (seed=${seed}, cached=${cached})`, async () => {
  const Model = cached ? UnifiedScheduler : UncachedScheduler;
  const s = new Model(), work = delay(), actions = [], operations = [];
  let randomState = seed;
  const random = n => ((randomState = (Math.imul(randomState, 1664525) + 1013904223) >>> 0) >>> 16) % n;
  const source = s.source('source', 0);
  const input = s.memo('input', read => work.run(read(source) * 10));
  const a = s.optimistic('a', input), b = s.optimistic('b', input);
  const sum = s.memo('sum', read => work.run(read(a) + read(b)));
  const c = s.optimistic('c', sum);
  const upper = s.memo('upper', read => work.run(read(c)));
  const d = s.optimistic('d', upper), views = [a, b, c, d];
  const gates = views.map((view, i) => {
    const gate = s.source(`gate${i}`, true);
    const label = s.memo(`label${i}`, read => work.run(read(view) * 10));
    s.render(`pair${i}`, read => read(gate) ? [read(view), read(label)] : null);
    s.render(`direct${i}`, read => read(gate) ? read(view) : null);
    return gate;
  });
  s.render('sourceValue', read => read(source));
  let checked = 0;
  const check = () => {
    for (const frame of s.publications.slice(checked)) for (let i = 0; i < views.length; i++) {
      const pair = frame[`pair${i}`];
      if (pair === undefined) continue;
      const why = `seed=${seed} operations=${operations.join(' ')}`;
      assert.equal(frame[`direct${i}`], pair ? pair[0] : null, why);
      if (pair) assert.equal(pair[1], pair[0] * 10, why);
    }
    checked = s.publications.length;
  };
  for (let step = 0; step < 120; step++) {
    const op = random(6), index = random(4), value = random(5);
    operations.push(`${op}:${index}:${value}`);
    if (op === 0) s.write(source, value);
    else if (op === 1 || op === 2) {
      const action = s.begin(); actions.push(action);
      s.guess(views[index], op === 1 ? value : x => x + 1, { action });
    } else if (op === 3) {
      if (actions.length) s.close(actions.splice(index % actions.length, 1)[0]);
    } else if (op === 4) s.write(gates[index], value % 2 === 0);
    else if (work.calls.length) {
      const call = work.calls.splice(random(work.calls.length), 1)[0];
      call.resolve(call.value); await turn();
    }
    s.flush(); check();
    if (step % 9 === 0) s.nodes.reverse();
  }
  for (const action of actions) s.close(action);
  for (const gate of gates) s.write(gate, false);
  s.flush(); check();
  for (let pass = 0; pass < 30 && (s.updates.size || work.calls.length); pass++) {
    for (const call of work.calls.splice(0)) call.resolve(call.value);
    await turn(); s.flush(); check();
  }
  assert.equal(s.updates.size, 0);
  assert.equal(s.inputObservers.size, 0);
  assert.equal(s.scopedBoundaries.size, 0);
  assert.equal(s.actions.size, 0);
  if (cached) assert.deepEqual(s.publications, uncachedPublications.get(seed));
  else uncachedPublications.set(seed, s.publications);
});
