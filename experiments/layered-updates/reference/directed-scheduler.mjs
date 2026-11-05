// Independent scalar experiment: reuse the stage-51 value/ownership/publication
// engine, replacing global layer-depth ordering with an explicit relation plan.
// No stage-53 admission edges or displaced-flight readiness records are used.
import { UnifiedScheduler as ScalarScheduler } from '../results/incremental-obligations-stage51/after.mjs';
import { relationPlan } from './relation-plan.mjs';
export class DirectedScheduler extends ScalarScheduler {
  plan = null;
  planKey = '';
  creating = null;
  group(name, options = {}) {
    const group = super.group(name, options);
    group.inputs = this.creating?.kind === 'guess' ? [this.creating.boundary.input] : options.inputs || [];
    group.parents = this.creating?.kind === 'guess' && this.creating.action ? [this.creating.action] : [];
    group.context = this.creating?.kind === 'clear' ? this.creating.boundary.input : null;
    return group;
  }
  above(a, b) {
    a = this.root(a); b = this.root(b);
    if (a === b || !this.plan) return false;
    for (const left of a.members) for (const right of b.members)
      if (!left.done && !right.done && this.plan.above(left, right)) return true;
    return false;
  }
  guess(output, value, options = {}) {
    const previous = this.creating;
    this.creating = { kind: 'guess', boundary: this.boundaries.get(output), action: options.action };
    try { return super.guess(output, value, options); }
    finally { this.creating = previous; }
  }
  inputOrigins(input, seen = new Set(), result = new Set()) {
    if (seen.has(input)) return result;
    seen.add(input);
    for (const origin of input.dirty) if (!origin.done) result.add(origin);
    // Current input work may discover a dependency absent from its old frame.
    // Both are obligations until that input publishes its replacement frame.
    for (const dep of input.inputs || input.links) this.inputOrigins(dep, seen, result);
    return result;
  }
  contextParents(input, seen = new Set(), result = new Set()) {
    if (seen.has(input)) return result;
    seen.add(input);
    const boundary = this.boundaries.get(input);
    if (boundary?.active) {
      for (const origin of this.inputOrigins(boundary.input)) result.add(origin);
      if (boundary.scope && !boundary.scope.done) result.add(boundary.scope);
    } else for (const dep of input.inputs || input.links) this.contextParents(dep, seen, result);
    return result;
  }
  rebuildLayers() {
    const origins = [...this.updates].filter(group => !group.done);
    const native = [], meetings = [];
    for (const group of origins) {
      const parents = new Set(group.parents.filter(parent => !parent.done));
      for (const input of group.inputs) for (const parent of this.inputOrigins(input)) parents.add(parent);
      if (group.context) for (const parent of this.contextParents(group.context)) parents.add(parent);
      for (const parent of parents) if (parent !== group && origins.includes(parent)) native.push([group, parent]);
    }
    for (const node of this.affected()) {
      const causes = [...node.dirty].filter(group => !group.done);
      if (causes.length > 1) meetings.push(causes);
    }
    this.joins = this.joins.filter(edge => edge.every(group => !group.done));
    this.couplings = this.couplings.filter(edge => edge.every(group => !group.done));
    meetings.push(...this.joins);
    const plan = relationPlan(origins, native, meetings, this.couplings);
    const signature = plan.groups.map(group => [...group].map(g => g.id).sort((a, b) => a - b).join(',')).sort();
    const arrows = [];
    for (const a of origins) for (const b of origins) if (plan.above(a, b)) arrows.push(`${a.id}>${b.id}`);
    const key = JSON.stringify([signature, arrows.sort()]);
    this.resetNeeded = false;
    if (key === this.planKey) return false;
    this.plan = plan; this.planKey = key;
    for (const group of origins) {
      group.root = group;
      group.members = new Set([group]);
      group.scopes = new Set(group.ownScopes);
    }
    for (const members of plan.groups) {
      const ordered = [...members].sort((a, b) => a.id - b.id), first = ordered[0];
      first.members = new Set(ordered);
      for (const member of ordered) {
        member.root = first;
        for (const scope of member.ownScopes) first.scopes.add(scope);
      }
    }
    this.merges++; this.preparation++;
    return true;
  }
  clear(output) {
    const boundary = this.boundaries.get(output);
    if (!boundary) throw new Error('Not an optimistic output');
    if (!boundary.active) return;
    // Expiration preserves already joined peer obligations, without absorbing
    // every other update that happens to have the same numerical depth.
    const peers = new Set();
    for (const group of this.pending(boundary.control)) for (const member of group.members) peers.add(member);
    boundary.active = false;
    this.forwardObservation(boundary, false);
    boundary.value = boundary.empty;
    const previous = this.creating;
    this.creating = { kind: 'clear', boundary };
    let correction;
    try { correction = this.group(`clear:${output.name}`); }
    finally { this.creating = previous; }
    const replaced = new Set();
    for (const group of [...this.updates]) {
      if (!group.entries.delete(boundary.control) || group.entries.size || group.mount) continue;
      group.done = true; this.updates.delete(group); this.dynamicGroups.delete(group); replaced.add(group);
      for (const node of group.nodes) if (node.dirty.delete(group)) {
        node.dirty.add(correction); correction.nodes.add(node);
      }
      group.root = correction;
    }
    for (const edges of [this.couplings, this.joins]) for (const edge of edges)
      for (let i = 0; i < edge.length; i++) if (replaced.has(edge[i])) edge[i] = correction;
    this.write(boundary.control, boundary.empty, { group: correction });
    const surviving = [...peers].filter(group => !group.done);
    if (surviving.length) this.couplings.push([correction, ...surviving]);
    this.resetNeeded = true;
    this.rebuildLayers();
    return correction;
  }
}
export { DirectedScheduler as UnifiedScheduler };
