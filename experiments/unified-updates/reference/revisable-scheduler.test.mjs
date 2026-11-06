// Historical stage-41 behavior. The delayed-join request rewrite below is
// rejected by the stage-56 stable-fetch-selection ruling; retaining these
// assertions documents that old model, not acceptance of a new implementation.
// See ../FETCH-SELECTION-56.md and fetch-selection.contract.mjs.
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { RevisableScheduler } from './revisable-scheduler.mjs';
import { delayedJoin } from './delayed-join-audit.mjs';

for (const reverse of [false, true]) for (const owned of [false, true]) {
  test(`an async answer revises an unpublished upper join (reverse=${reverse}, owned=${owned})`, async () => {
    const result = await delayedJoin(reverse, RevisableScheduler, { owned });
    assert.deepEqual(result.frames[2].values, [0, 0, 10, false, 0, 10]);
    assert.deepEqual(result.frames[3].values, [1, 2, 10, true, 3, 12]);
    assert.equal(result.bookkeeping.groups, 0);
    assert.equal(result.bookkeeping.joins, 0);
    for (const frame of result.publications) {
      assert.equal(frame['show:p'], frame['show:enabled'] ? frame['show:a'] + frame['show:b'] : 0);
      assert.equal(frame['show:q'], frame['show:c'] + frame['show:b']);
    }
    if (owned) {
      const discarded = result.afterRevision.filter(([kind, , value]) => kind === 'cleanup' && value === 12);
      assert(discarded.length > 0, 'The superseded 12 frame must be disposed');
      for (const [, id] of discarded)
        assert(!result.lifecycle.some(([kind, other]) => kind === 'publish' && other === id));
      assert(!result.afterRevision.some(([kind, , value]) => kind === 'cleanup' && value === 0));
      const published = result.lifecycle.filter(([kind]) => kind === 'publish').map(([, , value]) => value);
      assert.deepEqual(published, [0, 10, 12]);
    }
  });
}

test('open scope identities survive a join even when their labels match', () => {
  const s = new RevisableScheduler();
  const a = s.source('a', 0), b = s.source('b', 0);
  const sum = s.render('sum', read => read(a) + read(b));
  const first = s.write(a, 1, { name: 'same', open: true });
  const second = s.write(b, 2, { name: 'same', open: true });
  s.flush();
  s.close(first);
  assert.equal(s.value(sum), 0);
  s.close(second);
  assert.equal(s.value(sum), 3);
});

test('publication and supersession release obsolete coordination payloads', async () => {
  const s = new RevisableScheduler(), calls = [];
  const a = s.source('a', 0), b = s.source('b', 0);
  const sum = s.memo('sum', read => {
    const value = read(a) + read(b);
    if (!value) return 0;
    const gate = Promise.withResolvers(); calls.push({ value, ...gate }); return gate.promise;
  });
  s.render('display', read => read(sum));
  s.write(a, 1); s.flush();
  const obsolete = sum.candidate;
  s.write(b, 2); s.flush();
  assert.equal(obsolete.group, null);
  assert.equal(obsolete.context, null);
  assert.equal(obsolete.readGroup, null);
  assert.equal(obsolete.reads.size, 0);
  calls.at(-1).resolve(3);
  await new Promise(resolve => setTimeout(resolve, 0));
  for (const node of s.nodes) {
    assert.equal(node.candidate, null);
    assert.equal(node.frame.group, null);
    assert(!node.frame.context);
    assert(!node.frame.readGroup);
    assert.equal(node.fresh.size, 0);
  }
  assert.equal(s.updates.size, 0);
  assert.equal(s.joins.length, 0);
  // An unresolved obsolete request deliberately remains unresolved here.
});

test('ordinary lower updates and sibling optimistic layers obey the same join rule', async () => {
  for (const reverse of [false, true]) for (const owned of [false, true]) {
    const ordinary = await delayedJoin(reverse, RevisableScheduler, { owned });
    const optimistic = await delayedJoin(reverse, RevisableScheduler, { owned, peerLayer: true });
    assert.deepEqual(optimistic.frames, ordinary.frames);
    assert.deepEqual(optimistic.publications, ordinary.publications);
    assert.deepEqual(optimistic.lifecycle, ordinary.lifecycle);
    assert.equal(optimistic.bookkeeping.groups, 0);
    assert.equal(optimistic.bookkeeping.joins, 0);
  }
});

test('a staged lower error participates in the same hierarchy and publication', async () => {
  for (const reverse of [false, true]) {
    const result = await delayedJoin(reverse, RevisableScheduler, { failLower: true, owned: true });
    assert.deepEqual(result.frames[2].values, [0, 0, 10, false, 0, 10]);
    assert.deepEqual(result.frames[3].values, [1, 2, 10, true, { error: 'lower failed' }, 12]);
    for (const frame of result.publications) {
      assert.equal(frame['show:q'], frame['show:c'] + frame['show:b']);
      if (frame['show:enabled']) assert.deepEqual(frame['show:p'], { error: 'lower failed' });
      else assert.equal(frame['show:p'], 0);
    }
  }
});

test('finite conditional sibling campaign preserves complete published expressions', async () => {
  for (const reverse of [false, true]) {
    const s = new RevisableScheduler(), calls = [];
    const work = value => {
      if (!value) return 0;
      const gate = Promise.withResolvers(); calls.push({ value, ...gate }); return gate.promise;
    };
    const a = s.source('a', 0), b = s.source('b', 0);
    const c = s.source('c', 0, { inputs: [a] }), d = s.source('d', 0, { inputs: [b] });
    const flag = s.source('flag', false);
    const p = s.memo('p', read => read(flag) ? read(a) + read(b) : read(a) + read(c));
    const q = s.memo('q', read => work(read(flag) ? read(c) + read(b) : read(d) + read(a)));
    const r = s.memo('r', read => work(read(p) + read(q)));
    const nodes = [a, b, c, d, flag, p, q, r];
    for (const node of nodes) s.render(node.name, read => read(node));
    if (reverse) s.nodes.reverse();
    let state = 19;
    const random = n => ((state = (Math.imul(state, 1664525) + 1013904223) >>> 0) >>> 8) % n;
    const values = [0, 0, 0, 0, false];
    for (let step = 0; step < 120; step++) {
      const target = random(5);
      values[target] = target === 4 ? !values[target] : values[target] + 1;
      s.write(nodes[target], values[target]); s.flush();
      if (calls.length && random(2)) {
        const call = calls[random(calls.length)]; call.resolve(call.value);
        await new Promise(resolve => setTimeout(resolve, 0));
      }
      if (random(3) === 0) {
        for (const call of calls) call.resolve(call.value);
        await new Promise(resolve => setTimeout(resolve, 0));
      }
    }
    for (let i = 0; i < 20 && s.updates.size; i++) {
      for (const call of calls) call.resolve(call.value);
      await new Promise(resolve => setTimeout(resolve, 0));
    }
    assert.equal(s.updates.size, 0);
    assert.equal(s.joins.length, 0);
    assert.deepEqual(nodes.slice(0, 5).map(node => s.value(node)), values);
    for (const frame of s.publications) {
      assert.equal(frame.p, frame.flag ? frame.a + frame.b : frame.a + frame.c);
      assert.equal(frame.q, frame.flag ? frame.c + frame.b : frame.d + frame.a);
      assert.equal(frame.r, frame.p + frame.q);
    }
  }
});

test('a peer first encountered inside a new child branch yields to discovery', async () => {
  const s = new RevisableScheduler(), gate = Promise.withResolvers();
  const base = s.source('base', 0);
  const a = s.source('a', 0, { inputs: [base] }), b = s.source('b', 0, { inputs: [base] });
  const c = s.source('c', 0, { inputs: [a] });
  const q = s.memo('q', read => {
    const value = read(c);
    if (!value) return 0;
    const sum = value + read(b);
    return gate.promise.then(() => sum);
  });
  s.render('display', read => read(q));
  const first = s.write(a, 1, { open: true });
  const second = s.write(b, 2, { open: true });
  s.flush();
  s.write(c, 10); s.flush();
  assert.equal(s.value(q), 0);
  gate.resolve(); await new Promise(resolve => setTimeout(resolve, 0));
  assert.equal(s.value(q), 0);
  s.close(second);
  assert.deepEqual([a, b, c, q].map(node => s.value(node)), [0, 2, 10, 12]);
  s.close(first);
  assert.equal(s.updates.size, 0);
});
