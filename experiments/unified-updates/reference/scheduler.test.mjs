import { UnifiedScheduler } from './unified-scheduler.mjs';
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { Scheduler as InitialScheduler } from './scheduler.mjs';
import { RevisableScheduler } from './revisable-scheduler.mjs';
import { LayerOrderScheduler } from './layer-order-scheduler.mjs';
import { ActiveLayerScheduler } from './active-layer-scheduler.mjs';
import { LifetimeScheduler } from './lifetime-scheduler.mjs';
import { PendingScheduler } from './pending-scheduler.mjs';
const Scheduler = process.env.UNIFIED ? UnifiedScheduler : process.env.OBSERVATION ? PendingScheduler : process.env.LIFETIME ? LifetimeScheduler : process.env.ACTIVE_LAYER ? ActiveLayerScheduler : process.env.LAYER_ORDER ? LayerOrderScheduler : process.env.REVISABLE ? RevisableScheduler : InitialScheduler;
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
function requests() {
  const calls = [];
  const run = value => {
    if (value === 0) return 0;
    const gate = Promise.withResolvers();
    calls.push({ value, ...gate });
    return gate.promise;
  };
  const latest = value => calls.filter(call => call.value === value).at(-1);
  const answer = async value => {
    const call = latest(value);
    assert(call, `No request for ${value}; requests: ${calls.map(c => c.value)}`);
    call.resolve(value); await turn();
  };
  return { run, calls, latest, answer };
}
function pairFixture(reverse = false) {
  const s = new Scheduler(), work = requests();
  const x = s.source('x', 0), y = s.source('y', 0);
  const sum = s.memo('sum', read => work.run(read(x) + read(y)));
  const pair = s.render('pair', read => [read(x), read(y), read(sum)]);
  const doubled = s.render('doubled', read => read(sum) * 2);
  if (reverse) s.nodes.reverse();
  return { s, work, x, y, sum, pair, doubled };
}

for (const reverse of [false, true]) {
  test(`ordinary peers automatically combine and hold all shared readers (reverse=${reverse})`, async () => {
    const { s, work, x, y, pair, doubled } = pairFixture(reverse);
    const a = s.write(x, 1, { name: 'a', open: true }); s.flush();
    const old = work.latest(1);
    const b = s.write(y, 2, { name: 'b', open: true }); s.flush();
    assert.deepEqual(work.calls.map(c => c.value), [1, 3]);
    await work.answer(3);
    assert.deepEqual(s.value(pair), [0, 0, 0]);
    s.close(a); assert.deepEqual(s.value(pair), [0, 0, 0]);
    s.close(b);
    assert.deepEqual(s.value(pair), [1, 2, 3]);
    assert.equal(s.value(doubled), 6);
    old.resolve(1); await turn();
    assert.deepEqual(pair.observer.history, [[0, 0, 0], [1, 2, 3]]);
    assert.equal(s.updates.size, 0);
  });

  test(`child supersedes shared work, publishes, then lower work resumes automatically (reverse=${reverse})`, async () => {
    const { s, work, x, y, pair, doubled } = pairFixture(reverse);
    s.write(x, 1); s.flush();
    const old = work.latest(1);
    s.write(y, 10, { above: [x] }); s.flush();
    assert.deepEqual(work.calls.map(c => c.value), [1, 10]);
    old.resolve(1); await turn();
    assert.deepEqual(s.value(pair), [0, 0, 0]);
    await work.answer(10);
    assert.deepEqual(s.value(pair), [0, 10, 10]);
    assert.equal(s.value(doubled), 20);
    assert.deepEqual(work.calls.map(c => c.value), [1, 10, 11]);
    await work.answer(11);
    assert.deepEqual(s.value(pair), [1, 10, 11]);
    assert.equal(s.updates.size, 0);
    for (const frame of s.publications) {
      assert.equal(frame.pair[2], frame.pair[0] + frame.pair[1]);
      assert.equal(frame.doubled, frame.pair[2] * 2);
    }
  });
}

test('second revealed proposal, unrelated rerun and late mounted shared reader', async () => {
  const { s, work, y, sum, pair } = pairFixture();
  const tick = s.source('tick', 0);
  s.write(y, 1); s.flush(); await work.answer(1);
  s.write(y, 2); s.flush();
  const late = s.render('late', read => [read(tick), read(y), read(sum)]);
  assert.deepEqual(s.value(late), [0, 1, 1]);
  // Direct committed reads agree while the new proposal remains suspended.
  assert.deepEqual(s.value(pair), [0, 1, 1]);
  // This is an ordinary memo update, so peer entanglement remains allowed.
  s.write(tick, 9); s.flush();
  assert.deepEqual(s.value(late), [0, 1, 1]);
  await work.answer(2);
  assert.deepEqual(s.value(late), [9, 2, 2]);
  assert.deepEqual(late.observer.history, [[0, 1, 1], [9, 2, 2]]);
});

test('a disjoint update publishes while another component is suspended', () => {
  const { s, x } = pairFixture();
  const separate = s.source('separate', 0);
  const display = s.render('display', read => read(separate));
  s.write(x, 1); s.flush();
  s.write(separate, 42); s.flush();
  assert.equal(s.value(display), 42);
  assert.equal(s.value(x), 0);
});

for (const reverse of [false, true]) {
  test(`nested child excludes the whole joined lower group (reverse=${reverse})`, async () => {
    const s = new Scheduler(), pWork = requests(), qWork = requests();
    const a = s.source('a', 0), b = s.source('b', 0), c = s.source('c', 0);
    const p = s.memo('p', read => pWork.run(read(a) + read(b)));
    const q = s.memo('q', read => qWork.run(read(c) + read(b)));
    const all = ['a', 'b', 'c', 'p', 'q'].map((name, i) =>
      s.render(`show:${name}`, read => read([a, b, c, p, q][i])));
    if (reverse) s.nodes.reverse();
    s.write(a, 1); s.flush(); s.write(b, 2); s.flush();
    s.write(c, 10, { above: [a] }); s.flush();
    assert.equal(qWork.calls.at(-1).value, 10);
    await qWork.answer(10);
    assert.deepEqual(all.map(n => s.value(n)), [0, 0, 10, 0, 10]);
    await pWork.answer(3);
    assert.deepEqual(all.map(n => s.value(n)), [0, 0, 10, 0, 10]);
    assert.equal(qWork.calls.at(-1).value, 12);
    await qWork.answer(12);
    assert.deepEqual(all.map(n => s.value(n)), [1, 2, 10, 3, 12]);
  });
}

test('three nested updates resume outstanding work without retaining old async candidates', async () => {
  const s = new Scheduler(), work = requests();
  const a = s.source('a', 0), b = s.source('b', 0), c = s.source('c', 0);
  const sum = s.memo('sum', read => work.run(read(a) + read(b) + read(c)));
  const output = s.render('output', read => [read(a), read(b), read(c), read(sum)]);
  s.write(a, 1); s.flush();
  s.write(b, 10, { above: [a] }); s.flush();
  s.write(c, 100, { above: [b] }); s.flush();
  assert.deepEqual(work.calls.map(c => c.value), [1, 10, 100]);
  await work.answer(100);
  assert.deepEqual(s.value(output), [0, 0, 100, 100]);
  await work.answer(110);
  assert.deepEqual(s.value(output), [0, 10, 100, 110]);
  await work.answer(111);
  assert.deepEqual(s.value(output), [1, 10, 100, 111]);
});

test('errors and recovery publish coherently to separate consumers', () => {
  const s = new Scheduler(), x = s.source('x', 0);
  const derived = s.memo('derived', read => {
    const value = read(x);
    if (value === 1) throw new Error('failed');
    return value * 2;
  });
  const a = s.render('a', read => read(derived)), b = s.render('b', read => read(derived));
  s.write(x, 1); s.flush();
  assert.deepEqual(s.value(a), { error: 'failed' });
  assert.deepEqual(s.value(b), s.value(a));
  s.write(x, 2); s.flush();
  assert.deepEqual(a.observer.history, [0, { error: 'failed' }, 4]);
  assert.deepEqual(b.observer.history, a.observer.history);
});

test('real cleanup runs for discarded work; old committed owner survives until replacement', async () => {
  const s = new Scheduler(), work = requests(), events = [];
  const x = s.source('x', 0);
  const child = s.memo('owned', read => {
    const value = read(x);
    events.push(`create:${value}`);
    s.onCleanup(() => events.push(`cleanup:${value}`));
    s.onPublish(() => events.push(`publish:${value}`));
    return work.run(value);
  });
  s.render('display', read => read(child));
  s.write(x, 1); s.flush();
  s.write(x, 2); s.flush();
  assert.deepEqual(events, ['create:0', 'publish:0', 'create:1', 'cleanup:1', 'create:2']);
  await work.answer(1);
  assert.equal(events.includes('publish:1'), false);
  await work.answer(2);
  assert.deepEqual(events.slice(-2), ['cleanup:0', 'publish:2']);
});

test('a conditional dependency discovered during preparation joins the pending peer', async () => {
  const s = new Scheduler(), work = requests();
  const branch = s.source('branch', false), x = s.source('x', 0);
  const result = s.memo('result', read => read(branch) ? work.run(read(x)) : 0);
  const shown = s.render('shown', read => read(result));
  s.write(x, 5, { name: 'x', open: true }); s.flush();
  s.write(branch, true); s.flush();
  await work.answer(5);
  assert.equal(s.value(shown), 0);
  s.close([...s.updates].find(g => g.name === 'x'));
  assert.equal(s.value(shown), 5);
});

test('late async mount joins the proposal and supersedes work started from committed inputs', async () => {
  const s = new Scheduler(), calls = [];
  const x = s.source('x', 0);
  const update = s.write(x, 1, { open: true }); s.flush();
  const late = s.memo('late', read => {
    const value = read(x), gate = Promise.withResolvers();
    calls.push({ value, ...gate }); return gate.promise;
  });
  const display = s.render('display', read => read(late));
  s.flush();
  assert.deepEqual(calls.map(c => c.value), [0, 1]);
  calls[0].resolve(0); await turn();
  assert.equal(s.value(display), undefined);
  calls[1].resolve(1); await turn();
  assert.equal(s.value(display), undefined);
  s.close(update);
  assert.equal(s.value(display), 1);
  assert.deepEqual(display.observer.history, [1]);
});

test('a mounted async producer and its new reader publish together when initially absent', async () => {
  const s = new Scheduler(), gate = Promise.withResolvers();
  const a = s.memo('a', () => gate.promise);
  const b = s.render('b', read => read(a) * 2);
  s.flush();
  assert.equal(s.value(b), undefined);
  gate.resolve(3); await turn();
  assert.equal(s.value(b), 6);
  assert.equal(s.updates.size, 0);
});

test('a dynamic branch can detach a no-longer-read source after its own update commits', () => {
  const s = new Scheduler();
  const choose = s.source('choose', true), a = s.source('a', 0), b = s.source('b', 10);
  const result = s.render('result', read => read(choose) ? read(a) : read(b));
  s.write(choose, false); s.flush();
  assert.equal(s.value(result), 10);
  assert.equal(a.readers.size, 0);
  s.write(a, 1); s.flush();
  assert.deepEqual(result.observer.history, [0, 10]);
});

test('equal source proposals still replace owned frames coherently', () => {
  const s = new Scheduler(), events = [], x = s.source('x', 0);
  let generation = 0;
  s.memo('owner', read => {
    const value = read(x), id = ++generation;
    s.onCleanup(() => events.push(`clean:${id}`));
    s.onPublish(() => events.push(`show:${id}`));
    return value;
  });
  s.write(x, 0); s.flush();
  assert.deepEqual(events, ['show:1', 'clean:1', 'show:2']);
});

test('owned child inherits its proposed parent, and only the accepted subtree publishes', async () => {
  const s = new Scheduler(), work = requests(), events = [];
  const x = s.source('x', 0);
  const parent = s.memo('parent', read => {
    const captured = read(x);
    const child = s.memo(`child:${captured}`, childRead => {
      const direct = childRead(x);
      assert.equal(direct, captured);
      events.push(`create:${captured}`);
      s.onCleanup(() => events.push(`clean:${captured}`));
      s.onPublish(() => events.push(`show:${captured}`));
      return direct;
    });
    assert.equal(read(child), captured);
    return work.run(captured);
  });
  const display = s.render('display', read => read(parent));
  assert.deepEqual(events, ['create:0', 'show:0']);
  s.write(x, 1); s.flush();
  s.write(x, 2); s.flush();
  assert.equal(s.value(display), 0);
  assert.equal(events.includes('clean:0'), false);
  assert.equal(events.includes('clean:1'), true);
  await work.answer(1);
  assert.equal(events.includes('show:1'), false);
  await work.answer(2);
  assert.equal(s.value(display), 2);
  assert.deepEqual(events.slice(-2), ['clean:0', 'show:2']);
  assert.equal(s.nodes.filter(n => n.name.startsWith('child:')).length, 1);
});

test('initial owned async child is staged with its parent, including cleanup on disposal', async () => {
  const s = new Scheduler(), gate = Promise.withResolvers(), events = [];
  const parent = s.memo('parent', read => {
    s.render('child', () => {
      s.onPublish(() => events.push('show'));
      s.onCleanup(() => events.push('clean'));
      return gate.promise;
    });
    return 7;
  });
  const display = s.render('display', read => read(parent));
  s.flush();
  assert.deepEqual(events, []);
  gate.resolve(7); await turn();
  assert.equal(s.value(display), 7);
  assert.deepEqual(events, ['show']);
  s.dispose(display); s.dispose(parent);
  assert.deepEqual(events, ['show', 'clean']);
});

test('a ready lower update arriving during child work prepares the combined answer', async () => {
  const { s, work, x, y, pair } = pairFixture();
  s.write(y, 10, { above: [x] }); s.flush();
  s.write(x, 1); s.flush();
  // Stage 53 ruling: a ready lower proposal starts combined preparation now.
  // Historical schedulers retain their original sequential arbitration.
  assert.deepEqual(work.calls.map(c => c.value), process.env.UNIFIED ? [10, 11] : [10]);
  await work.answer(10);
  assert.deepEqual(s.value(pair), process.env.UNIFIED ? [0, 0, 0] : [0, 10, 10]);
  await work.answer(11);
  assert.deepEqual(s.value(pair), [1, 10, 11]);
});

test('repeated owned replacement releases old nodes, subscribers and update records', () => {
  const s = new Scheduler(), x = s.source('x', 0);
  let alive = 0, cleaned = 0;
  const parent = s.memo('parent', read => {
    const captured = read(x);
    const child = s.memo('child', childRead => {
      alive++;
      s.onCleanup(() => { alive--; cleaned++; });
      return captured + childRead(x);
    });
    return read(child);
  });
  const display = s.render('display', read => read(parent));
  for (let value = 1; value <= 200; value++) {
    s.write(x, value); s.flush();
    assert.equal(s.value(display), value * 2);
    assert.equal(alive, 1);
    assert.equal(s.nodes.length, 4);
    assert.equal(x.readers.size, 2);
    assert.equal(s.updates.size, 0);
    for (const node of s.nodes) {
      assert.equal(node.candidate, null);
      assert.equal(node.dirty.size, 0);
    }
  }
  assert.equal(cleaned, 200);
  s.dispose(display); s.dispose(parent);
  assert.equal(alive, 0);
  assert.equal(x.readers.size, 0);
  assert.equal(s.nodes.length, 1);
});

test('finite async diamond campaign preserves every observable frame across supersession', async () => {
  for (const reverse of [false, true]) {
    const s = new Scheduler(), work = requests();
    const x = s.source('x', 0), y = s.source('y', 0, { inputs: [x] });
    const z = s.source('z', 0, { inputs: [y] });
    const left = s.memo('left', read => read(x) + read(y));
    const right = s.memo('right', read => read(x) + read(z));
    const sum = s.memo('sum', read => work.run(read(left) + read(right)));
    const nodes = [x, y, z, left, right, sum];
    for (const node of nodes) s.render(`show:${node.name}`, read => read(node));
    if (reverse) s.nodes.reverse();
    let state = 7;
    const random = n => ((state = (Math.imul(state, 1664525) + 1013904223) >>> 0) >>> 8) % n;
    const values = [0, 0, 0];
    for (let step = 0; step < 150; step++) {
      const target = random(3);
      s.write(nodes[target], ++values[target], { above: target ? [nodes[target - 1]] : [] });
      s.flush();
      if (work.calls.length && random(2)) {
        const old = work.calls[random(work.calls.length)];
        old.resolve(old.value); await turn();
      }
      if (random(3) === 0) {
        const latest = work.calls.at(-1);
        latest.resolve(latest.value); await turn();
      }
    }
    for (let step = 0; step < 8 && s.updates.size; step++) {
      const latest = work.calls.at(-1);
      latest.resolve(latest.value); await turn();
    }
    assert.equal(s.updates.size, 0);
    assert.deepEqual(nodes.slice(0, 3).map(n => s.value(n)), values);
    for (const frame of s.publications) {
      assert.equal(frame['show:left'], frame['show:x'] + frame['show:y']);
      assert.equal(frame['show:right'], frame['show:x'] + frame['show:z']);
      assert.equal(frame['show:sum'], frame['show:left'] + frame['show:right']);
    }
  }
});
