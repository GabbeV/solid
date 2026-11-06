// This exposes a choice, not an accepted contract: count declared layers or
// only layers whose output currently has an optimistic override.
import { LayerOrderScheduler } from './layer-order-scheduler.mjs';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
async function run(wrapped) {
  const s = new LayerOrderScheduler();
  const qGate = Promise.withResolvers(), bGate = Promise.withResolvers(), requests = [];
  const source = s.source('source', 0), a = s.source('a', 0, { inputs: [source] });
  const b = s.source('b', 0, { inputs: [source] });
  const c = s.source('c', 0, { inputs: [wrapped ? a : source] });
  s.memo('holdB', read => {
    const value = read(b); return value ? bGate.promise.then(() => value) : 0;
  });
  const q = s.memo('q', read => {
    const value = read(c) + read(b);
    if (!value) return 0;
    requests.push(value); return qGate.promise.then(() => value);
  });
  for (const node of [a,b,c,q]) s.render(node.name, read => read(node));
  s.write(b, 2); s.flush(); s.write(c, 10); s.flush();
  qGate.resolve(); await turn();
  const held = [a,b,c,q].map(node => s.value(node));
  bGate.resolve(); await turn();
  return { wrapped, held, final: [a,b,c,q].map(node => s.value(node)), requests };
}
console.log(JSON.stringify(await Promise.all([run(false),run(true)]), null, 2));
