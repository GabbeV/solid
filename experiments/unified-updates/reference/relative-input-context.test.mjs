import assert from 'node:assert/strict';
import { test } from 'node:test';
import { UnifiedScheduler } from './unified-scheduler.mjs';

const turn = () => new Promise(resolve => setTimeout(resolve, 0));

for (const reverse of [false, true]) {
  test(`an override stays above an input whose pending branch discovers a deeper layer (reverse=${reverse})`, async () => {
    const s = new UnifiedScheduler();
    const source = s.source('source', 0), branch = s.source('branch', false);
    const a = s.optimistic('a', source), b = s.optimistic('b', a);
    s.guess(a, 1); s.flush();
    const hold = Promise.withResolvers();
    const holdB = s.memo('holdB', read => read(b) === 2 ? hold.promise : read(b));
    const input = s.memo('input', read => read(branch) ? read(b) : 0);
    const c = s.optimistic('c', input);
    const doubled = s.memo('doubled', read => 2 * read(c));
    const pair = s.memo('pair', read => reverse ? read(b) + read(c) : read(c) + read(b));
    const nodes = { branch, a, b, input, c, doubled, pair, holdB };
    for (const [name, node] of Object.entries(nodes)) s.render(`show:${name}`, read => read(node));
    if (reverse) s.nodes.reverse();
    s.publications.length = 0;
    const visible = () => Object.fromEntries(Object.entries(nodes).map(([name, node]) => [name, s.value(node)]));

    s.guess(b, 2); s.flush();
    s.write(branch, true); s.flush();
    s.guess(c, 10); s.flush();
    assert.deepEqual(visible(), { branch: false, a: 1, b: 1, input: 0, c: 10, doubled: 20, pair: 11, holdB: 1 });
    hold.resolve(2); await turn(); s.flush();
    assert.deepEqual(visible(), { branch: true, a: 1, b: 2, input: 2, c: 10, doubled: 20, pair: 12, holdB: 2 });
    s.clear(c); s.flush();
    assert.equal(s.value(c), 2);
    for (const frame of s.publications) {
      assert.equal(frame['show:doubled'], 2 * frame['show:c']);
      assert.equal(frame['show:pair'], frame['show:c'] + frame['show:b']);
      assert.equal(frame['show:input'], frame['show:branch'] ? frame['show:b'] : 0);
    }
    assert.equal(s.updates.size, 0);
  });
}

for (const observe of [false, true]) for (const seed of [3, 17, 31, 211]) {
  test(`changing input branches preserves coherent layered publications (seed=${seed}, observe=${observe})`, async () => {
    const s = new UnifiedScheduler(), flights = [], operations = [];
    let state = seed;
    const random = () => (state = (Math.imul(state, 1664525) + 1013904223) >>> 0) >>> 16;
    const delayed = value => {
      if (value === 0) return 0;
      const gate = Promise.withResolvers();
      flights.push({ value, ...gate });
      return gate.promise;
    };
    const source = s.source('source', 0), left = s.source('left', true), top = s.source('top', true);
    const a = s.optimistic('a', source), b = s.optimistic('b', source);
    const input = s.memo('input', read => read(left) ? read(a) : read(b));
    const c = s.optimistic('c', input);
    const joined = s.memo('joined', read => read(a) + read(b));
    const d = s.optimistic('d', joined);
    const upper = s.memo('upper', read => read(top) ? read(c) : read(d));
    const e = s.optimistic('e', upper);
    const sum = s.memo('sum', read => delayed(read(a) + read(b) + read(c) + read(d) + read(e)));
    const nodes = { source, left, top, a, b, input, c, joined, d, upper, e, sum };
    if (observe) {
      nodes.pending = s.memo('pending', () => s.isPending(e));
      nodes.label = s.memo('label', read => delayed(read(e) + (read(nodes.pending) ? 1000 : 0)));
    }
    for (const [name, node] of Object.entries(nodes)) s.render(`show:${name}`, read => read(node));
    if (seed % 2) s.nodes.reverse();
    let checked = 0;
    const check = () => {
      for (const frame of s.publications.slice(checked)) {
        const value = name => frame[`show:${name}`];
        const why = `seed=${seed} operations=${operations.join(' ')}`;
        assert.equal(value('input'), value('left') ? value('a') : value('b'), why);
        assert.equal(value('joined'), value('a') + value('b'), why);
        assert.equal(value('upper'), value('top') ? value('c') : value('d'), why);
        assert.equal(value('sum'), value('a') + value('b') + value('c') + value('d') + value('e'), why);
        if (observe) assert.equal(value('label'), value('e') + (value('pending') ? 1000 : 0), why);
      }
      checked = s.publications.length;
      assert([...s.updates].every(g => g.nativeLevel <= 5 + Number(observe)), `unbounded layer growth: ${operations.join(' ')}`);
    };
    const boundaries = [a, b, c, d, e];
    for (let step = 0; step < 120; step++) {
      const op = random() % 6, value = random() % 5;
      operations.push(`${op}:${value}`);
      if (op === 0) s.guess(boundaries[value], 1 + random() % 9);
      else if (op === 1) s.clear(boundaries[value]);
      else if (op === 2) s.write(left, !!(value % 2));
      else if (op === 3) s.write(top, !!(value % 2));
      else if (op === 4) s.write(source, value);
      else if (flights.length) {
        const flight = flights.splice(value % flights.length, 1)[0];
        flight.resolve(flight.value); await turn();
      }
      s.flush(); check();
    }
    for (const boundary of boundaries.reverse()) s.clear(boundary);
    s.flush();
    for (let round = 0; round < 20 && (flights.length || s.updates.size); round++) {
      for (const flight of flights.splice(0)) flight.resolve(flight.value);
      await turn(); s.flush(); check();
    }
    assert.equal(s.updates.size, 0, `did not drain: ${operations.join(' ')}`);
  });
}
