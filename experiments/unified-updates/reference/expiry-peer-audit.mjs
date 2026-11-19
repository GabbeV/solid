import { ActiveLayerScheduler } from './active-layer-scheduler.mjs';
import { pathToFileURL } from 'node:url';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
export async function scenario(Model = ActiveLayerScheduler, reverse = false) {
  const s = new Model(), calls = [];
  const a = s.optimistic('a', s.source('inputA', 4));
  const b = s.optimistic('b', s.source('inputB', 0));
  const q = s.memo('q', read => {
    const value = `${read(a)}/${read(b)}`;
    if (value === '4/0') return value;
    const gate = Promise.withResolvers(); calls.push({ value, ...gate }); return gate.promise;
  });
  const visible = () => [a, b, q].map(node => s.value(node));
  for (const node of [a, b, q]) s.render(`show:${node.name}`, read => read(node));
  if (reverse) s.nodes.reverse();
  s.guess(a, 6); s.guess(b, 2); s.flush();
  calls.findLast(c => c.value === '6/2').resolve('6/2'); await turn();
  const revealed = visible();
  s.guess(b, 1); s.flush();
  s.clear(a); s.flush();
  const afterExpiry = { visible: visible(), started: calls.map(c => c.value) };
  calls.findLast(c => c.value === '6/1')?.resolve('6/1'); await turn();
  const afterObsolete = { visible: visible(), started: calls.map(c => c.value) };
  calls.findLast(c => c.value === '4/1')?.resolve('4/1'); await turn();
  return { reverse, revealed, afterExpiry, afterObsolete, final: visible(), publications: s.publications };
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href)
  console.log(JSON.stringify(await Promise.all([scenario(undefined, false), scenario(undefined, true)]), null, 2));
