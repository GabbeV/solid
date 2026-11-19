import assert from 'node:assert/strict';
import { UnifiedScheduler } from './unified-scheduler.mjs';
import { pathToFileURL } from 'node:url';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
export async function scenario({ actionLifetime = false, reverse = false, fetches = false, Model = UnifiedScheduler } = {}) {
  const s = new Model(), gate = Promise.withResolvers(), deepGate = Promise.withResolvers(), peerGate = Promise.withResolvers();
  const base = s.source('base', 0), trigger = s.source('trigger', false);
  const first = s.optimistic('first', base), deep = s.optimistic('deep', first);
  const peer = s.optimistic('peer', base);
  const enabled = s.memo('enabled', read => read(trigger) ? gate.promise : false);
  const reads = [], inputWork = [];
  const input = s.memo('input', read => {
    reads.push('enabled');
    const flag = read(enabled);
    if (flag) reads.push('deep');
    const value = flag ? read(deep) : 0;
    const request = Promise.withResolvers(); inputWork.push({ value, ...request });
    return request.promise;
  });
  const view = s.optimistic('view', input);
  const holdDeep = s.memo('holdDeep', read => read(deep) === 2 ? deepGate.promise : read(deep));
  const holdPeer = s.memo('holdPeer', read => read(peer) === 20 ? peerGate.promise : read(peer));
  const pair = s.memo('pair', read => [read(view), read(peer)]);
  const nodes = { trigger, enabled, first, deep, peer, input, view, holdDeep, holdPeer, pair };
  const fetchWork = [];
  if (fetches) nodes.label = s.memo('label', read => {
    const key = read(pair).join(':');
    if (key === '0:0') return key;
    const request = Promise.withResolvers(); fetchWork.push({ key, ...request });
    return request.promise;
  });
  for (const [name, node] of Object.entries(nodes)) s.render(`show:${name}`, read => read(node));
  inputWork[0].resolve(0); await turn(); s.flush();
  if (reverse) s.nodes.reverse();
  s.guess(first, 1); s.flush();
  s.guess(deep, 2); s.flush();
  s.guess(peer, 20); s.flush();
  const update = s.begin('uncompleted input update');
  s.write(trigger, true, { group: update }); s.flush();
  const guessing = actionLifetime ? s.begin('guessing action') : null;
  s.guess(view, 10, guessing ? { action: guessing } : {}); s.flush();
  const checkpoints = [];
  const record = phase => checkpoints.push({ phase, values: Object.fromEntries(Object.entries(nodes).map(([name, node]) => [name, s.value(node)])),
    depth: s.layerOf(view), requests: fetchWork.map(request => request.key), reads: [...reads], inputUpdateOpen: update.ownScopes.size,
    pending: [...s.updates].map(g => ({ name: g.name, level: g.level, nativeLevel: g.nativeLevel })) });
  record('optimistic proposal ready but held by peer');
  gate.resolve(true); await turn(); s.flush();
  record('dependency discovered; input update, deep work and peer work still held');
  peerGate.resolve(20); await turn(); s.flush();
  record('actual peer blocker completes');
  deepGate.resolve(2); await turn();
  for (let pass = 0; pass < 8; pass++) {
    for (const request of inputWork) request.resolve(request.value);
    for (const request of fetchWork) request.resolve(request.key);
    await turn(); s.flush();
  }
  s.close(update);
  if (guessing) s.close(guessing);
  for (const node of [view, peer, deep, first]) s.clear(node);
  for (let pass = 0; pass < 12 && s.updates.size; pass++) {
    for (const request of inputWork) request.resolve(request.value);
    for (const request of fetchWork) request.resolve(request.key);
    await turn(); s.flush();
  }
  const remaining = s.updates.size;
  assert.equal(remaining, 0, 'Updates did not drain after all holds completed');
  for (const frame of s.publications) {
    if (frame['show:pair']) assert.deepEqual(frame['show:pair'], [frame['show:view'], frame['show:peer']]);
    if (fetches && frame['show:label'] !== undefined)
      assert.equal(frame['show:label'], `${frame['show:view']}:${frame['show:peer']}`);
  }
  for (const node of [...s.nodes].reverse()) s.dispose(node, false);
  s.flush();
  assert.equal(s.updates.size, 0, 'Disposed graph retained updates');
  return { actionLifetime, reverse, fetches, checkpoints, remaining, retainedAfterDisposal: s.updates.size };
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href)
  console.log(JSON.stringify(await Promise.all([false, true].flatMap(actionLifetime => [false, true].map(reverse => scenario({ actionLifetime, reverse })))), null, 2));
