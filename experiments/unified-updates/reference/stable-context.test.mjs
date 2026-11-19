import assert from 'node:assert/strict';
import { test } from 'node:test';
import { StableScheduler } from './stable-scheduler.mjs';
import { scenario } from './depth-discovery-audit.mjs';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));

for (const depth of [0, 3]) {
  test(`stable context: async function suspension, supersession and errors (depth=${depth})`, async () => {
    const s = new StableScheduler(), jobs = new Map(), layers = [];
    let output = s.source('base', 0);
    for (let i = 0; i < depth; i++) {
      output = s.optimistic(`layer:${i}`, output); layers.push(output);
      s.guess(output, 0); s.flush();
    }
    const first = s.memo('first', read => {
      const value = read(output);
      if (!value) return 0;
      const job = Promise.withResolvers(); jobs.set(value, job); return job.promise;
    });
    const second = s.memo('second', async read => {
      const value = read(first);
      if (value === 3) throw new Error('async failure');
      return value * 2;
    });
    const shown = s.render('shown', read => [read(output), read(second)]);
    const propose = n => depth ? s.guess(output, n) : s.write(output, n);
    await turn(); s.flush();
    assert.deepEqual(s.value(shown), [0, 0]);
    propose(1); s.flush(); await turn();
    propose(2); s.flush(); await turn();
    jobs.get(1).resolve(1); await turn();
    assert.deepEqual(s.value(shown), [0, 0]);
    jobs.get(2).resolve(2); await turn();
    assert.deepEqual(s.value(shown), [2, 4]);
    propose(3); s.flush(); await turn(); jobs.get(3).resolve(3); await turn();
    assert.deepEqual(s.value(shown), { error: 'async failure' });
    propose(4); s.flush(); await turn(); jobs.get(4).resolve(4); await turn();
    assert.deepEqual(s.value(shown), [4, 8]);
    assert.equal(s.updates.size, 0);
    for (const frame of s.publications) if (Array.isArray(frame.shown))
      assert.equal(frame.shown[1], frame.shown[0] * 2);
    for (const node of [...s.nodes].reverse()) s.dispose(node, false);
    s.flush(); assert.equal(s.updates.size, 0);
  });
}

for (const actionLifetime of [false, true]) for (const reverse of [false, true]) {
  test(`stable context: hidden discovery neither releases nor prolongs the peer hold (action=${actionLifetime}, reverse=${reverse})`, async () => {
    const { checkpoints, remaining, retainedAfterDisposal } = await scenario({ actionLifetime, reverse, Model: StableScheduler });
    assert.deepEqual(checkpoints.map(c => c.values.pair), [[0, 0], [0, 0], [10, 20]]);
    assert.deepEqual(checkpoints.map(c => c.depth), [1, 1, 1]);
    assert.equal(remaining, 0);
    assert.equal(retainedAfterDisposal, 0);
  });
}

for (const asynchronous of [false, true]) for (const reverseReads of [false, true]) {
  test(`stable context: stop before a body completes with mixed versions (async=${asynchronous}, reverseReads=${reverseReads})`, async () => {
    const s = new StableScheduler(), jobs = [], bodies = [], owners = [];
    const x = s.source('x', 0), base = s.source('base', 0);
    const view = s.optimistic('view', base);
    const calculate = read => {
      const owner = { cleaned: 0 }; owners.push(owner);
      s.onCleanup(() => owner.cleaned++);
      let a, b;
      if (reverseReads) { b = read(view); a = read(x); }
      else { a = read(x); b = read(view); }
      const again = read(x);
      bodies.push([a, b, again]);
      assert.equal(a, again, 'The body reached work with two versions of the same input');
      if (!a && !b) return '0:0';
      const job = Promise.withResolvers(); jobs.push({ key: `${a}:${b}`, ...job });
      return job.promise;
    };
    const result = s.memo('result', asynchronous ? async read => calculate(read) : calculate);
    const shown = s.render('shown', read => read(result));
    await turn(); s.flush();
    const action = s.begin();
    s.write(x, 1, { group: action }); s.guess(view, 10, { action }); s.flush();
    assert(!jobs.some(job => job.key === '1:10'));
    for (const job of jobs) job.resolve(job.key);
    await turn(); s.flush();
    assert.equal(s.value(shown), '0:10');
    s.close(action);
    for (let i = 0; i < 6 && s.updates.size; i++) {
      for (const job of jobs) job.resolve(job.key);
      await turn(); s.flush();
    }
    assert.equal(s.updates.size, 0);
    assert.equal(s.value(shown), '1:0');
    assert(bodies.every(([a, , again]) => a === again));
    for (const node of [...s.nodes].reverse()) s.dispose(node, false);
    s.flush();
    assert(owners.every(owner => owner.cleaned === 1));
  });
}

for (const depth of [0, 1, 4, 8]) for (const reverse of [false, true]) {
  test(`stable context: repeat, late reader, error and recovery at depth ${depth} (reverse=${reverse})`, async () => {
    const s = new StableScheduler(), jobs = new Map(), layers = [], events = [];
    const base = s.source('base', 0), tick = s.source('tick', 0);
    let output = base;
    for (let i = 0; i < depth; i++) {
      const input = s.memo(`input:${i}`, read => read(layers[i - 1] || base));
      output = s.optimistic(`layer:${i}`, input); layers.push(output);
      s.guess(output, 0); s.flush();
    }
    const value = output;
    const derived = s.memo('derived', read => {
      const n = read(value);
      const frame = { n, cleaned: 0 }; events.push(frame);
      s.onCleanup(() => frame.cleaned++);
      if (n === 3) throw new Error('expected failure');
      if (!n) return 0;
      const job = Promise.withResolvers(); jobs.set(n, job); return job.promise;
    });
    const pair = s.render('pair', read => [read(value), read(derived)]);
    const direct = s.render('direct', read => [read(tick), read(value)]);
    const propose = n => depth ? s.guess(value, n) : s.write(value, n);
    if (reverse) s.nodes.reverse();
    propose(1); s.flush(); jobs.get(1).resolve(1); await turn();
    assert.deepEqual(s.value(pair), [1, 1]);
    propose(2); s.flush(); s.write(tick, 9); s.flush();
    const late = s.render('late', read => read(value)); s.flush();
    assert.deepEqual(s.value(pair), [1, 1]);
    assert.equal(s.value(direct)[1], 1); assert.equal(s.value(late), 1);
    jobs.get(2).resolve(2); await turn();
    assert.deepEqual(s.value(pair), [2, 2]); assert.equal(s.value(late), 2);
    propose(3); s.flush();
    assert.deepEqual(s.value(pair), { error: 'expected failure' });
    assert.equal(s.value(late), 3);
    propose(4); s.flush();
    assert.equal(s.value(late), 3);
    jobs.get(4).resolve(4); await turn();
    assert.deepEqual(s.value(pair), [4, 4]);
    assert.equal(s.updates.size, 0);
    for (const publication of s.publications) {
      const p = publication.pair;
      if (Array.isArray(p)) {
        assert.equal(p[0], p[1]);
        assert.equal(publication.direct[1], p[0]);
        if (publication.late !== undefined) assert.equal(publication.late, p[0]);
      }
    }
    for (const node of [...s.nodes].reverse()) s.dispose(node, false);
    s.flush();
    assert(events.every(frame => frame.cleaned === 1));
    assert.equal(s.updates.size, 0);
    assert.equal(s.inputObservers.size, 0);
    assert.equal(s.boundaries.size, 0);
  });
}
