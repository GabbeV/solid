// A lower join becomes discoverable after the child has already begun work.
import { Scheduler } from './scheduler.mjs';
import { pathToFileURL } from 'node:url';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
export async function delayedJoin(reverse = false, Model = Scheduler, { owned = false, peerLayer = false, failLower = false } = {}) {
  const s = new Model(), calls = [], frames = [], lifecycle = [];
  let generation = 0;
  const gate = Promise.withResolvers();
  const work = (name, value) => {
    if (!value) return 0;
    const gate = Promise.withResolvers(); calls.push({ name, value, ...gate }); return gate.promise;
  };
  const base = peerLayer ? s.source('base', 0) : null;
  const inputs = base ? [base] : [];
  const a = s.source('a', 0, { inputs }), b = s.source('b', 0, { inputs });
  const c = s.source('c', 0, { inputs: [a] });
  const trigger = s.source('trigger', false);
  const enabled = s.memo('enabled', read => read(trigger) ? gate.promise : false);
  s.memo('holdA', read => work('a', read(a)));
  s.memo('holdB', read => work('b', read(b)));
  const p = s.memo('p', read => {
    if (!read(enabled)) return 0;
    const value = read(a) + read(b);
    if (failLower) throw new Error('lower failed');
    return work('p', value);
  });
  const q = s.memo('q', read => {
    const value = read(c) + read(b);
    if (owned) {
      const id = ++generation;
      const child = s.memo(`owned:${id}`, readChild => {
        const direct = readChild(c) + readChild(b);
        if (direct !== value) throw new Error('Owned child read a different frame');
        lifecycle.push(['create', id, value]);
        s.onCleanup(() => lifecycle.push(['cleanup', id, value]));
        s.onPublish(() => lifecycle.push(['publish', id, value]));
        return direct;
      });
      read(child);
    }
    return work('q', value);
  });
  const outputs = [a, b, c, enabled, p, q].map(node => s.render(`show:${node.name}`, read => read(node)));
  const publicationStart = s.publications.length;
  if (reverse) s.nodes.reverse();
  const record = phase => frames.push({ phase, values: outputs.map(n => s.value(n)),
    requests: calls.map(c => `${c.name}:${c.value}`) });
  s.write(a, 1); s.flush(); s.write(b, 2); s.flush();
  s.write(c, 10); s.write(trigger, true); s.flush();
  record('child started; lower condition unresolved');
  gate.resolve(true); await turn(); s.flush();
  record('lower condition resolved; child result unresolved');
  const afterRevision = lifecycle.map(event => [...event]);
  for (let i = 0; i < 5; i++) {
    for (const call of calls) if (call.name !== 'a') call.resolve(call.value);
    await turn(); s.flush();
  }
  record('all answers except a');
  for (let i = 0; i < 5; i++) {
    for (const call of calls) call.resolve(call.value);
    await turn(); s.flush();
  }
  record('all answers');
  return { reverse, frames, publications: s.publications.slice(publicationStart), lifecycle, afterRevision,
    bookkeeping: { groups: s.updates.size, joins: s.joins?.length, nodes: s.nodes.length } };
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href)
  console.log(JSON.stringify(await Promise.all([delayedJoin(false), delayedJoin(true)]), null, 2));
