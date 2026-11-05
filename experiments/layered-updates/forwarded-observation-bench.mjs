// Cost probes for the reference model. These are not production acceptance.
import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';
const { UnifiedScheduler } = await import(pathToFileURL(process.argv[2]));
const scenario = process.argv[3];
const shared = scenario === 'unobserved-shared';
const s = new UnifiedScheduler({ trace: false });
const base = s.source('base', 0), tick = s.source('tick', 0);
let value = 0, queries = 0;
const observed = s.observed;
if (observed) s.observed = function(...args) { queries++; return observed.apply(this, args); };
const views = [];
const count = shared ? 64 : scenario === 'nested-active' ? 8 : 256;
for (let i = 0; i < count; i++) {
  const input = shared ? s.memo(`input${i}`, read => read(base) ? new Promise(() => {}) : 0) :
    scenario === 'nested-active' && i ? views[i - 1] : base;
  const view = s.optimistic(`view${i}`, input);
  views.push(view);
  if (scenario !== 'unrelated-inactive') { s.guess(view, 1); s.flush(); }
}
if (shared) {
  let tail = s.memo('shared', read => views.reduce((sum, view) => sum + read(view), 0));
  for (let i = 0; i < 48; i++) {
    const previous = tail;
    tail = s.memo(`unused${i}`, read => read(previous) + 1);
  }
}
const rendered = shared ? base : scenario === 'nested-active' ? views.at(-1) : tick;
const display = s.render('display', read => read(rendered));
const run = n => {
  for (let i = 0; i < n; i++) {
    ++value;
    if (shared) s.write(base, value);
    else if (scenario === 'nested-active') s.guess(rendered, value);
    else s.write(tick, value);
    s.flush();
  }
};
let iterations = 100;
for (let warm = 0; warm < 4; warm++) {
  const start = performance.now(); run(iterations);
  iterations = Math.min(100000, Math.max(100, Math.round(iterations * 40 / Math.max(1, performance.now() - start))));
}
global.gc();
const samples = [];
for (let sample = 0; sample < 5; sample++) {
  const start = performance.now(); run(iterations);
  samples.push((performance.now() - start) * 1e6 / iterations);
  assert.equal(s.value(display), value);
  assert.equal(s.updates.size, 0);
}
// Synchronous work should never traverse the observation graph.
if (!shared) assert.equal(queries, 0);
console.log(JSON.stringify({ scenario, samples, ns: samples.toSorted((a,b)=>a-b)[2], iterations, queries }));
