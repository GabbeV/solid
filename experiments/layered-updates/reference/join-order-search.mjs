// A fixed event sequence with a late-discovered peer join. Compare scheduler
// traversal orders, not callback delivery order. The accepted ruling requires
// the child to exclude the whole lower joined update in either traversal.
import { Scheduler } from './scheduler.mjs';
import { pathToFileURL } from 'node:url';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
export async function scenario(reverse, Model = Scheduler, { seed = null, wrapped = false, readBFirst = false, peerLayer = false } = {}) {
  const s = new Model(), calls = [];
  function work(name, value) {
    if (value === 0) return 0;
    const gate = Promise.withResolvers();
    calls.push({ name, value, ...gate });
    return gate.promise;
  }
  const base = peerLayer ? s.source('base', 0) : null;
  const inputs = base ? [base] : [];
  const a = s.source('a', 0, { inputs }), b = s.source('b', 0, { inputs }), c = s.source('c', 0);
  const enabled = s.source('enabled', false);
  const holdA = s.render('holdA', read => work('a', read(a)));
  const holdB = s.render('holdB', read => work('b', read(b)));
  const condition = wrapped ? s.memo('identity:enabled', read => read(enabled)) : enabled;
  const bValue = wrapped ? s.memo('identity:b', read => read(b)) : b;
  const p = s.memo('p', read => read(condition) ? work('p', read(a) + read(bValue)) : 0);
  const q = s.memo('q', read => work('q', readBFirst ? read(bValue) + read(c) : read(c) + read(bValue)));
  const outputs = [a, b, c, enabled, p, q].map(node => s.render(`show:${node.name}`, read => read(node)));
  if (reverse) s.nodes.reverse();
  if (seed !== null) {
    let state = seed;
    for (let i = s.nodes.length - 1; i > 0; i--) {
      state = (Math.imul(state, 1664525) + 1013904223) >>> 0;
      const j = state % (i + 1);
      [s.nodes[i], s.nodes[j]] = [s.nodes[j], s.nodes[i]];
    }
  }
  s.write(a, 1); s.flush();
  s.write(b, 2); s.flush();
  s.write(c, 10, { above: [a] });
  s.write(enabled, true);
  s.flush();
  for (let i = 0; i < 4; i++) {
    for (const call of calls) if (call.name !== 'a') call.resolve(call.value);
    await turn(); s.flush();
  }
  const held = outputs.map(node => s.value(node));
  const prepared = calls.map(({ name, value }) => `${name}:${value}`);
  for (let i = 0; i < 4; i++) {
    for (const call of calls) call.resolve(call.value);
    await turn(); s.flush();
  }
  return { reverse, held, final: outputs.map(node => s.value(node)), prepared,
    publications: s.publications, evaluations: s.evaluations, discoveryRounds: s.discoveryRounds };
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href)
  console.log(JSON.stringify(await Promise.all([scenario(false), scenario(true)]), null, 2));
