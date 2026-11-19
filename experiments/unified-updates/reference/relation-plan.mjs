// Bounded research planner. Arrows mean "may read the lower committed frame".
// Native boundary arrows are strict; ordinary shared readers request peer joins.
// No values, owners, async jobs, or global ordinary-node registry live here.
export function relationPlan(origins, nativeEdges, meetings, fixed = []) {
  const parent = new Map(origins.map(origin => [origin, origin]));
  const root = origin => {
    const next = parent.get(origin);
    if (next !== origin) parent.set(origin, root(next));
    return parent.get(origin);
  };
  const union = (a, b) => { a = root(a); b = root(b); if (a !== b) parent.set(b, a); };
  for (const group of fixed) for (const origin of group.slice(1)) union(group[0], origin);
  const nodes = [...new Set(origins.map(root))];
  const native = new Map(nodes.map(node => [node, new Set()]));
  for (const [upper, lower] of nativeEdges) if (root(upper) !== root(lower)) native.get(root(upper)).add(root(lower));
  const reaches = (graph, a, b, seen = new Set()) => {
    if (a === b || seen.has(a)) return false;
    seen.add(a);
    for (const lower of graph.get(a)) if (lower === b || reaches(graph, lower, b, seen)) return true;
    return false;
  };
  for (const node of nodes) for (const lower of native.get(node))
    if (reaches(native, lower, node)) throw new Error('Native boundary ancestry contains a cycle');
  const peers = [];
  for (const meeting of meetings) {
    const groups = [...new Set(meeting.map(root))];
    const frontier = groups.filter(group => !groups.some(other => reaches(native, other, group)));
    for (let i = 0; i < frontier.length; i++) for (let j = i + 1; j < frontier.length; j++)
      peers.push([frontier[i], frontier[j]]);
  }
  const graph = new Map(nodes.map(node => [node, new Set(native.get(node))]));
  for (const [a, b] of peers) { graph.get(a).add(b); graph.get(b).add(a); }
  // Tarjan's SCCs expose peer joins that collectively contradict an actual
  // boundary, including a conflict that no individual join exposes on its own.
  let index = 0;
  const indices = new Map(), low = new Map(), stack = [], onStack = new Set(), components = [], component = new Map();
  const visit = node => {
    indices.set(node, index); low.set(node, index++); stack.push(node); onStack.add(node);
    for (const next of graph.get(node)) {
      if (!indices.has(next)) { visit(next); low.set(node, Math.min(low.get(node), low.get(next))); }
      else if (onStack.has(next)) low.set(node, Math.min(low.get(node), indices.get(next)));
    }
    if (low.get(node) !== indices.get(node)) return;
    const members = new Set(); let next;
    do { next = stack.pop(); onStack.delete(next); members.add(next); component.set(next, members); } while (next !== node);
    components.push(members);
  };
  for (const node of nodes) if (!indices.has(node)) visit(node);
  const ranks = new Map();
  const rank = node => {
    if (ranks.has(node)) return ranks.get(node);
    let value = 0;
    for (const lower of native.get(node)) if (component.get(lower) === component.get(node)) value = Math.max(value, 1 + rank(lower));
    ranks.set(node, value); return value;
  };
  const directed = [...nodes.flatMap(node => [...native.get(node)].map(lower => [node, lower]))];
  const conflicts = components.filter(members => [...members].some(node => rank(node) > 0));
  for (const [a, b] of peers) {
    // Rank is local to a conflicting interaction component, not global depth.
    // An unrelated deeper optimistic boundary still joins an ordinary peer.
    const difference = rank(a) - rank(b);
    if (!difference) union(a, b);
    else directed.push(difference > 0 ? [a, b] : [b, a]);
  }
  const below = new Map([...new Set(origins.map(root))].map(node => [node, new Set()]));
  for (const [a, b] of directed) if (root(a) !== root(b)) below.get(root(a)).add(root(b));
  const groups = new Map();
  for (const origin of origins) {
    const representative = root(origin);
    if (!groups.has(representative)) groups.set(representative, new Set());
    groups.get(representative).add(origin);
  }
  return {
    groups: [...groups.values()], conflicts,
    same: (a, b) => parent.has(a) && parent.has(b) && root(a) === root(b),
    above: (a, b) => parent.has(a) && parent.has(b) && reaches(below, root(a), root(b))
  };
}
