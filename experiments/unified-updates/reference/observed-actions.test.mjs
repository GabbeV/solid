import assert from 'node:assert/strict';
import { test } from 'node:test';
import { PendingScheduler as PendingModel } from './pending-scheduler.mjs';
import { UnifiedScheduler } from './unified-scheduler.mjs';
const PendingScheduler = process.env.UNIFIED ? UnifiedScheduler : PendingModel;
const turn = () => new Promise(resolve => setTimeout(resolve, 0));

for (const initialSeed of [1, 17, 83, 211]) test(`observed overlapping actions publish coherent frames (seed=${initialSeed})`, async () => {
  const s = new PendingScheduler(), calls = [], actions = [], operations = [];
  const source = s.source('source', 0), flag = s.source('flag', false);
  const work = (kind, value) => {
    if (value === 0 || value === '0/0/0/false/false/false') return value;
    const call = { kind, value, ...Promise.withResolvers() }; calls.push(call); return call.promise;
  };
  const input = s.memo('input', read => work('input', read(source)));
  const a = s.optimistic('a', input), b = s.optimistic('b', input);
  const selected = s.memo('selected', read => read(flag) ? read(a) : read(b));
  const c = s.optimistic('c', selected);
  const pending = [a, b, c].map(node => s.memo(`pending:${node.name}`, () => s.isPending(node)));
  const parts = [a, b, c, ...pending];
  const label = s.memo('label', read => work('label', parts.map(read).join('/')));
  for (const node of [...parts, label]) s.render(node.name, read => read(node));
  let seed = initialSeed, checked = 0;
  const random = n => { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; return Math.floor(seed / 2 ** 32 * n); };
  const check = () => {
    for (; checked < s.publications.length; checked++) {
      const frame = s.publications[checked];
      assert.equal(frame.label, parts.map(node => frame[node.name]).join('/'), JSON.stringify(operations));
    }
  };
  for (let step = 0; step < 60; step++) {
    const open = actions.filter(action => action.ownScopes.size);
    const action = open[random(open.length)];
    switch (random(5)) {
      case 0: {
        const next = s.begin('same name'); actions.push(next);
        const node = [a, b, c][random(3)], value = random(5);
        operations.push(['begin', actions.length - 1, node.name, value]);
        s.guess(node, value, { action: next }); break;
      }
      case 1:
        if (action) {
          const node = [a, b, c][random(3)], value = random(5);
          operations.push(['guess', actions.indexOf(action), node.name, value]);
          s.guess(node, value, { action });
        }
        break;
      case 2:
        if (action) {
          const value = random(5); operations.push(['end', actions.indexOf(action), value]);
          s.write(source, value, { group: action }); s.close(action);
        }
        break;
      case 3:
        operations.push(['flag', !s.value(flag)]); s.write(flag, !s.value(flag)); break;
      case 4: {
        const value = random(5); operations.push(['input', value]); s.write(source, value); break;
      }
    }
    try { s.flush(); } catch (error) { error.message += `; operations=${JSON.stringify(operations)}`; throw error; }
    check();
    if (calls.length) {
      const index = random(calls.length), call = calls[index]; operations.push(['answer', index, call.kind, call.value]);
      call.resolve(call.value); await turn(); check();
    }
    if (step % 7 === 6) { operations.push(['reverse']); s.nodes.reverse(); }
  }
  for (const action of actions) if (action.ownScopes.size) s.close(action);
  for (let pass = 0; pass < 30 && s.updates.size; pass++) {
    for (const call of calls) call.resolve(call.value);
    await turn(); check();
  }
  if (s.updates.size && process.env.MODEL_DIAGNOSTIC) console.error(JSON.stringify({
    operations,
    roots: s.roots().map(g => ({ id: g.id, name: g.name, level: g.level, scopes: g.scopes.size })),
    nodes: s.nodes.filter(n => n.dirty.size).map(n => ({ name: n.name,
      pending: s.pending(n).map(g => g.id), candidate: n.candidate && {
        group: s.root(n.candidate.group).id, ready: n.candidate.ready, waiting: n.candidate.waiting,
        reads: [...n.candidate.reads].map(([n,id]) => [n.name,id]), value: n.candidate.value
      }})),
    observations: [...s.observations.values()].map(r => ({ source: r.source.name, active: r.boundary.active,
      value: r.boundary.value, retiring: r.retiring && { group: s.root(r.retiring.group).id,
        sameGeneration: r.retiring.generation === (r.source.candidate ?? r.source.frame) }}))
  }, null, 2));
  assert.equal(s.updates.size, 0);
  assert.equal(s.actions.size, 0);
  assert.equal(s.couplings.length, 0);
  assert.equal(s.joins.length, 0);
  for (const node of pending) assert.equal(s.value(node), false);
});
