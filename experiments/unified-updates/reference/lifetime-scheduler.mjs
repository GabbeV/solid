// Research extension: retiring a selected override replaces work of its former
// peers. Publication groups and action lifetimes remain distinct.
import { ActiveLayerScheduler } from './active-layer-scheduler.mjs';

export class LifetimeScheduler extends ActiveLayerScheduler {
  couplings = [];
  actions = new Set();
  previousValues = new WeakMap();

  discard(node) {
    const previous = node.candidate;
    if (previous?.ready) this.previousValues.set(node,
      { id: previous.id, value: previous.value, error: previous.error });
    super.discard(node);
  }
  valueIdentity(node, candidate, previous) {
    // Read identity tracks a memo's value. Owner identity remains the frame
    // object: equal output can replace owned children without rerunning users
    // of that output. Source writes still explicitly create new identities.
    for (const frame of [previous, node.frame]) {
      if (frame && Object.is(frame.value, candidate.value) && frame.error === candidate.error) {
        candidate.id = frame.id;
        break;
      }
    }
  }
  evaluate(node, ...args) {
    const previous = this.previousValues.get(node);
    this.previousValues.delete(node);
    const result = super.evaluate(node, ...args);
    if (result.ready) this.valueIdentity(node, result, previous);
    else if (previous) result.previousValue = previous;
    return result;
  }
  answer(node, token, value, error = null) {
    if (node.candidate !== token || node.disposed) return;
    token.value = value; token.error = error;
    this.valueIdentity(node, token, token.previousValue);
    delete token.previousValue;
    super.answer(node, token, value, error);
  }
  optimistic(name, input) {
    const output = super.optimistic(name, input);
    const boundary = this.boundaries.get(output);
    boundary.empty = boundary.control.frame.value;
    return output;
  }

  layerOf(node, seen = new Set()) {
    if (seen.has(node)) return 0;
    seen.add(node);
    try {
      const boundary = this.boundaries.get(node);
      if (boundary) return this.layerOf(boundary.input, seen) + (boundary.active ? 1 : 0);
      if (node.inputs?.length)
        return 1 + Math.max(...node.inputs.map(input => this.layerOf(input, seen)));
      if (!node.fn) return 0;
      // A speculative branch cannot choose the context that decides that same
      // branch. Pending input publication can change this graph after commit.
      const dependencies = node.frame ? node.frame.reads.keys() : node.links;
      return Math.max(0, ...[...dependencies].map(input => this.layerOf(input, seen)));
    } finally { seen.delete(node); }
  }

  group(name, options) {
    // Independent initial work starts in the ordinary context. A producer's
    // suspended initial job must not adopt the context of a later override.
    const group = super.group(name, options?.mount ? { ...options, position: options.position ?? 0 } : options);
    group.nativeLevel = group.level;
    return group;
  }
  prepare(node, stack) {
    if (!node.fn && !node.disposed) {
      const group = this.choose(node);
      if (group && !node.candidate) {
        // A newer write may already have published while an older obligation
        // remains. Satisfy it with that committed source, never revive a value
        // superseded by the newer write.
        node.candidate = { ...this.frame(node.frame.value), id: node.frame.id,
          error: node.frame.error, group, reused: node.frame };
      }
      return;
    }
    super.prepare(node, stack);
  }
  joinCoupled(a, b) {
    a = this.root(a); b = this.root(b);
    if (a === b) return a;
    if (a.id > b.id) [a, b] = [b, a];
    b.root = a;
    for (const member of b.members) a.members.add(member);
    for (const scope of b.scopes) a.scopes.add(scope);
    a.level = a.level === null ? b.level : b.level === null ? a.level : Math.min(a.level, b.level);
    this.merges++;
    return a;
  }
  rebuildLayers() {
    const levels = new Map([...this.updates].map(g =>
      [g, typeof g.levelSpec === 'function' ? g.levelSpec() : g.levelSpec]));
    if (!this.resetNeeded && ![...levels].some(([g, level]) => level !== g.nativeLevel)) return false;
    this.resetNeeded = false;
    for (const [g, level] of levels) {
      g.root = g; g.level = g.nativeLevel = level;
      g.scopes = new Set(g.ownScopes); g.members = new Set([g]);
    }
    this.couplings = this.couplings.filter(edge => edge.every(g => !g.done));
    for (const edge of this.couplings)
      edge.reduce((a, b) => a ? this.joinCoupled(a, b) : b, null);
    const retained = [];
    for (const edge of this.joins) {
      if (edge.some(g => g.done)) continue;
      const groups = [...new Set(edge.map(g => this.root(g)))];
      if (new Set(groups.map(g => g.level).filter(level => level !== null)).size > 1) continue;
      groups.reduce((a, b) => a ? this.join(a, b, false) : b, null);
      retained.push(edge);
    }
    this.joins = retained;
    return true;
  }
  clear(output) {
    const boundary = this.boundaries.get(output);
    if (!boundary?.active) return super.clear(output);
    const oldLevel = this.layerOf(output), peers = new Set(), seen = new Set();
    const visit = node => {
      if (seen.has(node)) return;
      seen.add(node);
      for (const group of this.pending(node)) if (group.level === oldLevel)
        for (const member of group.members) peers.add(member);
      for (const reader of node.readers) visit(reader);
    };
    visit(output);
    boundary.active = false;
    boundary.value = boundary.empty;
    const correction = this.group(`clear:${output.name}`, { position: () => this.layerOf(boundary.input) });
    // Transfer publication obligations. Calculation cancellation follows normal
    // dependency validation, so equal proposed outputs can retain async users.
    const replaced = new Set();
    for (const group of [...this.updates]) {
      if (!group.entries.delete(boundary.control) || group.entries.size || group.mount) continue;
      group.done = true; this.updates.delete(group); replaced.add(group);
      for (const node of this.nodes) if (node.dirty.delete(group)) node.dirty.add(correction);
      group.root = correction;
    }
    for (const edges of [this.couplings, this.joins])
      for (const edge of edges) for (let i = 0; i < edge.length; i++)
        if (replaced.has(edge[i])) edge[i] = correction;
    this.write(boundary.control, boundary.empty, { group: correction });
    const surviving = [...peers].filter(g => !g.done);
    if (surviving.length) {
      this.couplings.push([correction, ...surviving]);
    }
    this.resetNeeded = true;
    this.rebuildLayers();
    return correction;
  }
  commit(group) {
    super.commit(group);
    for (const node of this.nodes) if (!node.candidate) this.previousValues.delete(node);
    this.couplings = this.couplings.filter(edge => edge.every(g => !g.done));
    for (const action of this.actions) if (action.done) this.actions.delete(action);
  }
  dispose(node, flush = true) {
    super.dispose(node, flush);
    this.previousValues.delete(node);
  }
  couple(a, b) {
    a = this.root(a); b = this.root(b);
    if (a === b) return false;
    this.couplings.push([...a.members, ...b.members]);
    this.resetNeeded = true;
    this.rebuildLayers();
    return true;
  }
  begin(name = 'action') {
    const action = this.group(name, { open: true });
    this.actions.add(action);
    return action;
  }
  guess(output, value, { action } = {}) {
    if (action) {
      if (action.done || !action.ownScopes.size) throw new Error('Action body has ended');
      const boundary = this.boundaries.get(output);
      if (!boundary) throw new Error('Not an optimistic output');
      if (boundary.scope && !boundary.scope.done) this.couple(action, boundary.scope);
      boundary.scope = action;
    }
    return super.guess(output, value);
  }
  coordinateActions() {
    const scoped = [...this.boundaries.values()].filter(boundary => boundary.scope);
    // Input arrival joins the guessing scope. A parent optimistic proposal is
    // an input here, just as an ordinary source proposal is.
    for (const boundary of scoped) {
      const input = this.choose(boundary.input);
      if (input && this.couple(boundary.scope, input)) return true;
    }
    const waiting = new Set();
    for (const boundary of scoped) {
      if (this.choose(boundary.input) && !boundary.input.candidate?.ready)
        waiting.add(this.root(boundary.scope));
    }
    let changed = false;
    for (const boundary of scoped) {
      const scope = this.root(boundary.scope);
      if (scope.scopes.size || waiting.has(scope)) continue;
      const correction = this.clear(boundary.output);
      boundary.scope = null;
      if (correction) this.couple(correction, scope);
      changed = true;
    }
    return changed;
  }
  flush() {
    if (this.flushing) return;
    this.flushing = true;
    try {
      for (let pass = 0; pass < 1000; pass++) {
        this.rebuildLayers();
        const before = this.merges;
        for (const node of this.nodes) this.prepare(node);
        if (before !== this.merges || this.rebuildLayers() || this.coordinateActions()) continue;
        const ready = this.roots().find(group => this.canCommit(group));
        if (!ready) return;
        this.commit(ready);
      }
      throw new Error('Publication did not converge');
    } finally { this.flushing = false; }
  }
}
