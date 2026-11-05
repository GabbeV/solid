import { UnifiedScheduler } from './unified-scheduler.mjs';
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ActiveLayerScheduler as ActiveModel } from './active-layer-scheduler.mjs';
import { LifetimeScheduler } from './lifetime-scheduler.mjs';
import { PendingScheduler } from './pending-scheduler.mjs';
const ActiveLayerScheduler = process.env.UNIFIED ? UnifiedScheduler : process.env.OBSERVATION ? PendingScheduler : process.env.LIFETIME ? LifetimeScheduler : ActiveModel;

const turn = () => new Promise(resolve => setTimeout(resolve, 0));
function requests() {
  const calls = [];
  return {
    calls,
    run(value) {
      if (!value) return value;
      const gate = Promise.withResolvers();
      calls.push({ value, ...gate });
      return gate.promise;
    },
    async answer(value) {
      const call = calls.findLast(call => call.value === value);
      assert(call, `No request for ${value}; saw ${calls.map(c => c.value)}`);
      call.resolve(value); await turn();
    }
  };
}
function display(s, nodes) {
  for (const node of nodes) s.render(`show:${node.name}`, read => read(node));
  return () => nodes.map(node => s.value(node));
}

test('shared dependencies do not make layer positions depend on read order', () => {
  const s = new ActiveLayerScheduler(), input = s.source('input', 0);
  const a = s.optimistic('a', input), b = s.optimistic('b', a);
  s.guess(a, 1); s.guess(b, 2); s.flush();
  const ab = s.memo('ab', read => read(a) + read(b));
  const ba = s.memo('ba', read => read(b) + read(a));
  const wrapped = s.optimistic('wrapped', ab);
  assert.equal(s.layerOf(ab), 2);
  assert.equal(s.layerOf(ba), 2);
  assert.equal(s.layerOf(wrapped), 2);
});

test('inactive boundaries remain transparent through errors and recovery', () => {
  function scenario(wrapped) {
    const s = new ActiveLayerScheduler(), input = s.source('input', 0);
    const producer = s.memo('producer', read => {
      const value = read(input);
      if (value === 1) throw new Error('failed input');
      return value;
    });
    const view = wrapped ? s.optimistic('view', producer) : producer;
    const screen = s.render('screen', read => read(view));
    s.write(input, 1); s.flush();
    assert.deepEqual(s.value(screen), { error: 'failed input' });
    s.write(input, 2); s.flush();
    assert.equal(s.value(screen), 2);
    return s.publications;
  }
  assert.deepEqual(scenario(true), scenario(false));
});

test('owned inactive boundaries release their selectors and subscriptions on replacement', () => {
  const s = new ActiveLayerScheduler(), input = s.source('input', 0);
  const replace = s.source('replace', 0), events = [];
  const parent = s.memo('parent', read => {
    const value = read(replace);
    const view = s.optimistic('owned', input);
    s.render('child', read => read(view));
    s.onCleanup(() => events.push(`cleanup:${value}`));
    s.onPublish(() => events.push(`publish:${value}`));
    return value;
  });
  s.flush();
  const count = s.nodes.length;
  for (let i = 1; i <= 100; i++) {
    s.write(replace, i); s.flush();
    assert.equal(s.value(parent), i);
    assert.equal(s.nodes.length, count);
    assert.equal(s.boundaries.size, 1);
    assert.equal(input.readers.size, 1);
    assert.equal(s.updates.size, 0);
    assert.equal(s.joins.length, 0);
    assert.deepEqual(events.slice(-2), [`cleanup:${i - 1}`, `publish:${i}`]);
  }
  s.dispose(parent);
  assert.equal(s.boundaries.size, 0);
  assert.equal(input.readers.size, 0);
});

for (const initialSeed of [17, 83, 211, 987]) test(`finite active-layer lifecycle campaign preserves every published derivation (seed=${initialSeed})`, async () => {
  const s = new ActiveLayerScheduler(), calls = [];
  const input = s.source('input', 0);
  const flag = s.source('flag', false);
  const a = s.optimistic('a', input), b = s.optimistic('b', input);
  const selected = s.memo('selected', read => read(flag) ? read(a) : read(input));
  const c = s.optimistic('c', selected), d = s.optimistic('d', b);
  const run = value => {
    if (value === 0) return 0;
    const gate = Promise.withResolvers(); calls.push({ value, ...gate }); return gate.promise;
  };
  const p = s.memo('p', read => run(read(c) + read(b)));
  const q = s.memo('q', read => run(read(d) + read(a)));
  display(s, [input, flag, selected, a, b, c, d, p, q]);
  let seed = initialSeed, checked = 0;
  const operations = new Set();
  const random = n => { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; return Math.floor(seed / 2 ** 32 * n); };
  const check = () => {
    for (; checked < s.publications.length; checked++) {
      const frame = s.publications[checked];
      assert.equal(frame['show:p'], frame['show:c'] + frame['show:b']);
      assert.equal(frame['show:q'], frame['show:d'] + frame['show:a']);
      assert.equal(frame['show:selected'], frame['show:flag'] ? frame['show:a'] : frame['show:input']);
    }
  };
  for (let step = 0; step < 160; step++) {
    const node = [a, b, c, d][random(4)];
    const operation = random(4);
    operations.add(`${node.name}:${operation}`);
    switch (operation) {
      case 0: s.clear(node); break;
      case 1: s.write(input, random(5)); break;
      default: s.guess(node, random(7));
    }
    s.flush(); check();
    if (step % 11 === 0) { s.write(flag, !s.value(flag)); s.flush(); check(); }
    if (calls.length) {
      const call = calls[random(calls.length)]; call.resolve(call.value);
      await turn(); check();
    }
    if (step % 8 === 7) s.nodes.reverse();
  }
  for (const node of [c, d, a, b]) s.clear(node);
  s.flush();
  for (let pass = 0; pass < 20 && s.updates.size; pass++) {
    for (const call of calls) call.resolve(call.value);
    await turn(); check();
  }
  assert.equal(s.updates.size, 0);
  assert.equal(s.joins.length, 0);
  assert.equal(s.nodes.filter(node => node.candidate || node.dirty.size).length, 0);
  for (const node of [a, b, c, d]) assert.equal(s.value(node), s.value(input));
  for (const node of [a, b, c, d]) for (const operation of [0, 1, 2, 3])
    assert(operations.has(`${node.name}:${operation}`));
});

for (const reverse of [false, true]) {
  test(`three active overrides unwind through transparent wrappers (reverse=${reverse})`, async () => {
    const s = new ActiveLayerScheduler(), aw = requests(), bw = requests(), work = requests();
    const input = s.source('input', 0), a = s.optimistic('a', input);
    const b = s.optimistic('b', s.optimistic('unusedA', a));
    const c = s.optimistic('c', s.optimistic('unusedB', b));
    s.render('holdA', read => aw.run(read(a)));
    s.render('holdB', read => bw.run(read(b)));
    const q = s.memo('q', read => work.run(read(c)));
    const visible = display(s, [a, b, c, q]);
    if (reverse) s.nodes.reverse();
    s.guess(a, 1); s.flush(); s.guess(b, 2); s.flush(); s.guess(c, 3); s.flush();
    await work.answer(3);
    assert.deepEqual(visible(), [0, 0, 3, 3]);
    await bw.answer(2);
    assert.deepEqual(visible(), [0, 2, 3, 3]);
    await aw.answer(1);
    assert.deepEqual(visible(), [1, 2, 3, 3]);
    s.clear(c); s.flush();
    assert.deepEqual(visible(), [1, 2, 3, 3]);
    await work.answer(2);
    assert.deepEqual(visible(), [1, 2, 2, 2]);
    s.clear(b); s.flush(); await bw.answer(1); await work.answer(1);
    assert.deepEqual(visible(), [1, 1, 1, 1]);
    s.clear(a); s.flush();
    assert.deepEqual(visible(), [0, 0, 0, 0]);
    assert.equal(s.updates.size, 0);
    for (const frame of s.publications) assert.equal(frame['show:c'], frame['show:q']);
    for (const node of [a, b, c]) assert.equal(s.layerOf(node), 0);
  });

  test(`both crossed active children publish over held parents (reverse=${reverse})`, async () => {
    const s = new ActiveLayerScheduler(), pw = requests(), qw = requests();
    const aw = requests(), bw = requests(), input = s.source('input', 0);
    const a = s.optimistic('a', input), b = s.optimistic('b', input);
    const c = s.optimistic('c', a), d = s.optimistic('d', b);
    s.guess(c, 0); s.guess(d, 0); s.flush();
    s.publications.length = 0;
    s.render('holdA', read => aw.run(read(a)));
    s.render('holdB', read => bw.run(read(b)));
    const p = s.memo('p', read => pw.run(read(c) + read(b)));
    const q = s.memo('q', read => qw.run(read(d) + read(a)));
    const visible = display(s, [a, b, c, d, p, q]);
    if (reverse) s.nodes.reverse();
    s.guess(a, 1); s.guess(b, 2); s.flush();
    s.guess(c, 10); s.guess(d, 20); s.flush();
    await pw.answer(10); await qw.answer(20);
    assert.deepEqual(visible(), [0, 0, 10, 20, 10, 20]);
    await aw.answer(1); await bw.answer(2);
    await pw.answer(12); await qw.answer(21);
    assert.deepEqual(visible(), [1, 2, 10, 20, 12, 21]);
    for (const frame of s.publications) {
      assert.equal(frame['show:p'], frame['show:c'] + frame['show:b']);
      assert.equal(frame['show:q'], frame['show:d'] + frame['show:a']);
    }
    assert.equal(s.updates.size, 0);
  });

  test(`parent activation separates a suspended child from its former peer (reverse=${reverse})`, async () => {
    const s = new ActiveLayerScheduler(), work = requests(), holdB = requests();
    const input = s.source('input', 0);
    const a = s.optimistic('a', input), b = s.optimistic('b', input);
    const c = s.optimistic('c', a);
    s.render('holdB', read => holdB.run(read(b)));
    const q = s.memo('q', read => work.run(read(c) + read(b)));
    const visible = display(s, [a, b, c, q]);
    if (reverse) s.nodes.reverse();
    s.guess(b, 2); s.flush(); s.guess(c, 10); s.flush();
    assert(work.calls.some(call => call.value === 12));
    s.guess(a, 1); s.flush();
    await work.answer(12);
    assert.equal(s.value(c), 0);
    await work.answer(10);
    assert.deepEqual(visible(), [0, 0, 10, 10]);
    await holdB.answer(2); await work.answer(12);
    assert.deepEqual(visible(), [1, 2, 10, 12]);
    for (const frame of s.publications)
      assert.equal(frame['show:q'], frame['show:c'] + frame['show:b']);
    assert.equal(s.updates.size, 0);
  });

  test(`parent expiration makes a suspended child coordinate with its new peer (reverse=${reverse})`, async () => {
    const s = new ActiveLayerScheduler(), work = requests(), holdB = requests();
    const input = s.source('input', 0);
    const a = s.optimistic('a', input), b = s.optimistic('b', input);
    const c = s.optimistic('c', a);
    s.guess(c, 0); s.flush(); s.guess(a, 1); s.flush();
    s.publications.length = 0;
    s.render('holdB', read => holdB.run(read(b)));
    const q = s.memo('q', read => work.run(read(c) + read(b)));
    const visible = display(s, [a, b, c, q]);
    if (reverse) s.nodes.reverse();
    s.guess(b, 2); s.flush(); s.guess(c, 10); s.flush();
    assert(work.calls.some(call => call.value === 10));
    s.clear(a); s.flush();
    await work.answer(10);
    assert.equal(s.value(c), 0);
    await work.answer(12);
    assert.equal(s.value(c), 0);
    await holdB.answer(2);
    assert.deepEqual(visible(), [0, 2, 10, 12]);
    for (const frame of s.publications)
      assert.equal(frame['show:q'], frame['show:c'] + frame['show:b']);
    assert.equal(s.updates.size, 0);
    assert.equal(s.layerOf(a), s.layerOf(input));
  });

  test(`expiring one suspended override does not cancel its joined peer (reverse=${reverse})`, async () => {
    const s = new ActiveLayerScheduler(), work = requests();
    const input = s.source('input', 0);
    const a = s.optimistic('a', input), b = s.optimistic('b', input);
    const q = s.memo('q', read => work.run(read(a) + read(b)));
    const visible = display(s, [a, b, q]);
    if (reverse) s.nodes.reverse();
    s.guess(a, 1); s.flush(); s.guess(b, 2); s.flush();
    s.clear(a); s.flush();
    await work.answer(3);
    assert.deepEqual(visible(), [0, 0, 0]);
    await work.answer(2);
    assert.deepEqual(visible(), [0, 2, 2]);
    assert.equal(s.updates.size, 0);
  });

  test(`unused wrappers preserve peer coordination (reverse=${reverse})`, async () => {
    async function scenario(wrapped) {
      const s = new ActiveLayerScheduler(), qb = requests(), bb = requests();
      const source = s.source('source', 0);
      const a = s.optimistic('a', source), b = s.optimistic('b', source);
      const c = s.optimistic('c', wrapped ? a : source);
      s.render('holdB', read => bb.run(read(b)));
      const q = s.memo('q', read => qb.run(read(c) + read(b)));
      const visible = display(s, [b, c, q]);
      if (reverse) s.nodes.reverse();
      s.guess(b, 2); s.flush(); s.guess(c, 10); s.flush();
      await qb.answer(12);
      assert.deepEqual(visible(), [0, 0, 0]);
      await bb.answer(2);
      assert.deepEqual(visible(), [2, 10, 12]);
      assert.equal(s.updates.size, 0);
      return s.publications;
    }
    assert.deepEqual(await scenario(true), await scenario(false));
  });

  test(`inactive input propagation and late mounts match a direct input (reverse=${reverse})`, async () => {
    async function scenario(wrapped) {
      const s = new ActiveLayerScheduler(), work = requests();
      const input = s.source('input', 0);
      const view = wrapped ? s.optimistic('view', s.optimistic('inner', input)) : input;
      const result = s.memo('result', read => work.run(read(view)));
      const screen = s.render('screen', read => [read(view), read(result)]);
      if (reverse) s.nodes.reverse();
      s.write(input, 1); s.flush();
      const late = s.render('late', read => [read(view), read(result)]);
      assert.deepEqual(s.value(late), [0, 0]);
      assert.deepEqual(s.value(screen), [0, 0]);
      await work.answer(1);
      assert.deepEqual(s.value(screen), [1, 1]);
      assert.deepEqual(s.value(late), [1, 1]);
      return s.publications;
    }
    assert.deepEqual(await scenario(true), await scenario(false));
  });

  test(`repeated guesses retain published output across unrelated reruns (reverse=${reverse})`, async () => {
    const s = new ActiveLayerScheduler(), work = requests();
    const input = s.source('input', 0), tick = s.source('tick', 0);
    const view = s.optimistic('view', input);
    const result = s.memo('result', read => work.run(read(view)));
    const screen = s.render('screen', read => [read(view), read(result)]);
    const other = s.render('other', read => [read(tick), read(view)]);
    if (reverse) s.nodes.reverse();
    s.guess(view, 1); s.flush(); await work.answer(1);
    s.guess(view, x => x + 1); s.flush();
    s.write(tick, 9); s.flush();
    const late = s.render('late', read => read(view));
    assert.deepEqual(s.value(screen), [1, 1]);
    assert.equal(s.value(other)[1], 1);
    assert.equal(s.value(late), 1);
    await work.answer(2);
    assert.deepEqual(s.value(screen), [2, 2]);
    assert.deepEqual(s.value(other), [9, 2]);
    assert.equal(s.value(late), 2);
    for (const frame of s.publications) {
      assert.equal(frame.screen[0], frame.screen[1]);
      assert.equal(frame.other[1], frame.screen[0]);
      if ('late' in frame) assert.equal(frame.late, frame.screen[0]);
    }
  });

  test(`clearing an override cancels its suspended consequence (reverse=${reverse})`, async () => {
    const s = new ActiveLayerScheduler(), work = requests();
    const input = s.source('input', 0), view = s.optimistic('view', input);
    const result = s.memo('result', read => work.run(read(view)));
    const screen = s.render('screen', read => [read(view), read(result)]);
    if (reverse) s.nodes.reverse();
    s.guess(view, 1); s.flush(); await work.answer(1);
    s.guess(view, 2); s.flush();
    s.clear(view); s.flush();
    assert.deepEqual(s.value(screen), [0, 0]);
    await work.answer(2);
    assert.deepEqual(s.value(screen), [0, 0]);
    assert.equal(s.updates.size, 0);
    s.write(input, 3); s.flush(); await work.answer(3);
    assert.deepEqual(s.value(screen), [3, 3]);
    assert.equal(s.layerOf(view), s.layerOf(input));
  });
}
