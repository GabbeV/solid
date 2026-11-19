// Reduce a policy disagreement; neither policy is a correctness oracle.
import { readFileSync } from 'node:fs';
import { ReadModel, summary } from './read-context.mjs';
const input = JSON.parse(readFileSync(process.argv[2], 'utf8')).example;
function evaluate(tree, read, nodes) {
  return typeof tree === 'string' ? read(nodes[tree]) :
    evaluate(tree[0], read, nodes) ? evaluate(tree[1], read, nodes) : evaluate(tree[2], read, nodes);
}
function inspect(tree) {
  const m = new ReadModel();
  for (const [name, parents] of input.cuts) m.cut(name, parents);
  const nodes = Object.fromEntries(input.nodes.map(node => {
    m.group(node.name, { cut: node.cut });
    return [node.name, node];
  }));
  const root = m.memo('root', read => evaluate(tree, read, nodes));
  return { narrowed: m.select(root), exhaustive: m.select(root, { search: 'exhaustive' }) };
}
function differs(tree) {
  const { narrowed, exhaustive } = inspect(tree);
  return narrowed.value !== exhaustive.value && exhaustive.reason === 'ambiguous contexts';
}
function* reductions(tree) {
  if (typeof tree === 'string') return;
  yield* tree;
  for (let i = 0; i < tree.length; i++)
    for (const replacement of reductions(tree[i])) {
      const next = [...tree]; next[i] = replacement; yield next;
    }
}
let tree = input.tree;
while (true) {
  const next = [...reductions(tree)].find(differs);
  if (next === undefined) break;
  tree = next;
}
const result = inspect(tree);
console.log(JSON.stringify({ tree, cuts: input.cuts, nodes: input.nodes,
  narrowed: summary(result.narrowed), exhaustive: summary(result.exhaustive),
  attempts: result.exhaustive.attempts }, null, 2));
