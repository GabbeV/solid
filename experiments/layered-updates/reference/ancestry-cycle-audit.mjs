import { Scheduler } from './scheduler.mjs';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
async function run(script = null) {
  const s = new Scheduler(), calls = [], trace = [];
  const x = s.source('x', 0), y = s.source('y', 0), z = s.source('z', 0);
  const left = s.memo('left', read => read(x) + read(y));
  const right = s.memo('right', read => read(x) + read(z));
  const sum = s.memo('sum', read => {
    const value = read(left) + read(right);
    if (!value) return 0;
    const gate = Promise.withResolvers(); calls.push({ value, ...gate }); return gate.promise;
  });
  const nodes = [x, y, z, left, right, sum];
  for (const node of nodes) s.render(`show:${node.name}`, read => read(node));
  let state = 7;
  const random = n => ((state = (Math.imul(state, 1664525) + 1013904223) >>> 0) >>> 8) % n;
  const values = [0, 0, 0];
  async function event(event) {
    trace.push(event);
    if ('write' in event) {
      const target = event.write;
      s.write(nodes[target], event.value, { above: target ? [nodes[target - 1]] : [] });
      s.flush();
    } else {
      const call = event.answer === 'latest' ? calls.at(-1) : calls[event.answer];
      call?.resolve(call.value); await turn();
    }
  }
  try {
    if (script) for (const step of script) await event(step);
    else for (let step = 0; step < 150; step++) {
      const target = random(3);
      await event({ write: target, value: ++values[target] });
      if (calls.length && random(2)) await event({ answer: random(calls.length) });
      if (random(3) === 0) await event({ answer: 'latest' });
    }
  } catch (error) {
    return { error: error.message, trace,
      groups: s.roots().map(g => ({ id: g.id, name: g.name,
        below: [...g.below].map(p => ({ id: s.root(p).id, done: s.root(p).done })),
        inputs: [...g.inputs].map(n => n.name) })),
      nodes: nodes.map(n => ({ name: n.name, committed: s.value(n),
        pending: s.pending(n).map(g => g.id), candidate: n.candidate?.group && s.root(n.candidate.group).id })) };
  }
  return { error: null, trace };
}
let result = await run();
if (!result.error) throw new Error('Expected to reproduce the campaign failure');
let trace = result.trace;
for (let size = Math.ceil(trace.length / 2); size; size = Math.floor(size / 2)) {
  let changed = true;
  while (changed) {
    changed = false;
    for (let start = 0; start < trace.length; start += size) {
      const next = trace.filter((_, index) => index < start || index >= start + size);
      const attempt = await run(next);
      if (attempt.error === 'Cyclic update ancestry') {
        trace = next; result = attempt; changed = true; break;
      }
    }
  }
}
console.log(JSON.stringify(result, null, 2));
