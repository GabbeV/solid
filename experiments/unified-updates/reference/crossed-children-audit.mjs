import { RevisableScheduler } from './revisable-scheduler.mjs';
import { pathToFileURL } from 'node:url';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
export async function scenario(reverse, Model = RevisableScheduler, { peerLayer = true } = {}) {
  const s = new Model(), calls = [];
  const work = (name, value) => {
    if (!value) return 0;
    const gate = Promise.withResolvers(); calls.push({ name, value, ...gate }); return gate.promise;
  };
  const base = s.source('base', 0);
  const inputs = peerLayer ? [base] : [];
  const a = s.source('a', 0, { inputs }), b = s.source('b', 0, { inputs });
  const c = s.source('c', 0, { inputs: [a] }), d = s.source('d', 0, { inputs: [b] });
  s.memo('holdA', read => work('a', read(a))); s.memo('holdB', read => work('b', read(b)));
  const p = s.memo('p', read => work('p', read(c) + read(b)));
  const q = s.memo('q', read => work('q', read(d) + read(a)));
  const outputs = [a, b, c, d, p, q].map(node => s.render(`show:${node.name}`, read => read(node)));
  if (reverse) s.nodes.reverse();
  s.write(a, 1); s.write(b, 2); s.flush();
  s.write(c, 10); s.write(d, 20); s.flush();
  for (let i = 0; i < 5; i++) {
    for (const call of calls) if (call.name !== 'a' && call.name !== 'b') call.resolve(call.value);
    await turn(); s.flush();
  }
  const held = outputs.map(node => s.value(node)), prepared = calls.map(c => `${c.name}:${c.value}`);
  for (let i = 0; i < 8; i++) {
    for (const call of calls) call.resolve(call.value);
    await turn(); s.flush();
  }
  return { reverse, held, final: outputs.map(node => s.value(node)), prepared, publications: s.publications };
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href)
  console.log(JSON.stringify(await Promise.all([scenario(false), scenario(true)]), null, 2));
