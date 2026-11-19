// Finite, reproducible search over conditional scalar snapshots. This compares
// two selection policies; the exhaustive policy is not an independent oracle
// for publication correctness, and differences are not automatically bugs.
import assert from "node:assert/strict";
import { ReadModel, summary } from "./read-context.mjs";

let state = 1;
const random = n => ((state = (Math.imul(state, 1664525) + 1013904223) >>> 0) >>> 8) % n;
const names = ["a", "b", "c", "d", "e", "x"];
const count = Number(process.argv[2] || 5000);
function expression(depth) {
  if (!depth || random(4) === 0) return names[random(names.length)];
  return [expression(depth - 1), expression(depth - 1), expression(depth - 1)];
}
function evaluate(tree, read, nodes) {
  return typeof tree === "string" ? read(nodes[tree]) :
    evaluate(tree[0], read, nodes) ? evaluate(tree[1], read, nodes) : evaluate(tree[2], read, nodes);
}
function observable(plan) {
  return { value: plan.value, context: plan.context, consumes: plan.consumes, observes: plan.observes };
}
let differences = 0, maxAttempts = 0, example = null;
for (let index = 0; index < count; index++) {
  const m = new ReadModel();
  for (let i = 0; i < 5; i++) {
    const cut = names[i];
    m.cut(cut, i && random(2) ? [names[random(i)]] : []);
    m.group(cut, { cut });
  }
  m.group("x");
  const nodes = Object.fromEntries(names.map(name => [name,
    m.source(name, random(2), {
      cut: name === "x" ? null : name,
      proposal: { group: name, value: random(2) }
    })
  ]));
  const tree = expression(4), root = m.memo("root", read => evaluate(tree, read, nodes));
  const narrowed = m.select(root);
  assert(m.supported(narrowed), `Unsupported result at snapshot ${index}`);
  assert(narrowed.attempts.length <= 7, `Non-progress at snapshot ${index}`);
  maxAttempts = Math.max(maxAttempts, narrowed.attempts.length);
  const exhaustive = m.select(root, { search: "exhaustive" });
  if (JSON.stringify(observable(narrowed)) !== JSON.stringify(observable(exhaustive))) {
    differences++;
    example ??= {
      index, tree, nodes: Object.values(nodes),
      cuts: [...m.cuts].map(([cut, parents]) => [cut, [...parents]]),
      narrowed: summary(narrowed), exhaustive: summary(exhaustive)
    };
  }
  const before = summary(narrowed);
  m.cut("unrelated");
  m.group("unrelated", { cut: "unrelated" });
  assert.deepEqual(summary(m.select(root)), before, `Disjoint interference at snapshot ${index}`);
}
console.log(JSON.stringify({ snapshots: count, maxAttempts, differences, example }, null, 2));
