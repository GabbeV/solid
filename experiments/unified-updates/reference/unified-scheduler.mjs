// Consolidated operational reference model, not a production runtime.
// One committed frame and one eligible candidate; value and owner identities
// are distinct. All graph scans here are research instrumentation.
const WAIT = Symbol('no eligible value');
const NONE = Symbol('no override');
const RETRY = Symbol('newly discovered update context');
export class UnifiedScheduler {
  constructor({ trace = true } = {}) { this.trace = trace; }
  nodes = [];
  updates = new Set();
  serial = 0;
  current = null;
  flushing = false;
  publications = [];
  discarded = 0;
  evaluations = 0;
  merges = 0;
  boundaries = new Map();
  // Observation edges belong to active optimistic boundaries, not ordinary
  // nodes or dependency links. They never carry values or notifications.
  inputObservers = new Map();
  scopedBoundaries = new Set();
  joins = [];
  advances = [];
  displaced = new Map();
  admitted = null;
  resetNeeded = false;
  dynamicGroups = new Set();
  preparation = 0;
  obligations = 0;
  affectedCache = null;

  affected() {
    if (!this.trace && this.affectedCache) return this.affectedCache;
    const nodes = new Set();
    for (const group of this.updates) for (const node of group.nodes) if (!node.disposed) nodes.add(node);
    return this.trace ? this.nodes.filter(node => nodes.has(node)) : (this.affectedCache = [...nodes]);
  }
  layerOf(node, seen = new Set()) {
    if (seen.has(node)) return 0;
    seen.add(node);
    try {
      const boundary = this.boundaries.get(node);
      if (boundary) return boundary.active ? 1 + this.inputPosition(boundary, seen) : this.layerOf(boundary.input, seen);
      if (node.inputs?.length)
        return 1 + Math.max(...node.inputs.map(input => this.layerOf(input, seen)));
      if (!node.fn) return 0;
      // A speculative branch cannot choose the context that decides that same
      // branch. Pending input publication can change this graph after commit.
      const dependencies = node.inputsPublished && node.candidate ? node.candidate.reads.keys() : node.frame ? node.frame.reads.keys() : node.links;
      return Math.max(0, ...[...dependencies].map(input => this.layerOf(input, seen)));
    } finally { seen.delete(node); }
  }
  inputPosition(boundary, seen = new Set()) {
    // An override is above the input proposal it cuts off, even when that
    // proposal discovered a dependency absent from the committed input frame.
    return Math.max(this.layerOf(boundary.input, seen),
      ...this.pending(boundary.input).map(group => group.level));
  }
  group(name, { open = false, inputs = [], mount = false, position } = {}) {
    const levelSpec = position ?? ( inputs.length ? 1 + Math.max(...inputs.map(input => this.layerOf(input))) : 0);
    const level = typeof levelSpec === "function" ? levelSpec() : levelSpec;
    const group = { name, id: ++this.serial, root: null, level, levelSpec, entries: new Set(), nodes: new Set(),
      scopes: new Set(), scope: Symbol(name), done: false, mount };
    if (open) group.scopes.add(group.scope);
    group.root = group;
    group.nativeLevel = level;
    group.members = new Set([group]);
    group.ownScopes = new Set(group.scopes);
    this.updates.add(group);
    if (typeof levelSpec === 'function') this.dynamicGroups.add(group);
    return group;
  }
  root(group) {
    if (group.root !== group) group.root = this.root(group.root);
    return group.root;
  }
  above(a, b) {
    a = this.root(a); b = this.root(b);
    return a.level > b.level;
  }
  join(a, b, record = true, coupled = false) {
    a = this.root(a); b = this.root(b);
    if (a === b) return a;
    if (!coupled && (this.above(a, b) || this.above(b, a)))
      throw new Error('Cannot join an update with its ancestor');
    if (record) this.joins.push([...a.members, ...b.members]);
    if (a.id > b.id) [a, b] = [b, a];
    b.root = a;
    for (const member of b.members) a.members.add(member);
    // Lifecycle coupling moves peer work into the input publication context.
    if (coupled) a.level = Math.min(a.level, b.level);
    for (const scope of b.scopes) a.scopes.add(scope);
    this.merges++;
    this.preparation++;
    return a;
  }
  pending(node) {
    for (const g of node.dirty) if (g.done) node.dirty.delete(g);
    return [...new Set([...node.dirty].map(g => this.root(g)))];
  }
  choose(node) {
    if (node.dirty.size === 1) {
      const group = node.dirty.values().next().value;
      if (!group.done) return !this.admitted || [...this.root(group).members].some(member => this.admitted.has(member)) ? this.root(group) : null;
      node.dirty.delete(group);
      return null;
    }
    const groups = this.pending(node).filter(g => !this.admitted || [...g.members].some(member => this.admitted.has(member)));
    const frontier = groups.filter(g => !groups.some(other => this.above(other, g)));
    return frontier.reduce((a, b) => a ? this.join(a, b) : b, null);
  }
  mark(node, group, seen = new Set()) {
    if (seen.has(node) || node.disposed) return;
    if (node.fn && node.preparedAt === -1 && node.dirty.has(group)) return;
    if (!node.dirty.has(group)) { this.obligations++; this.affectedCache = null; }
    seen.add(node); node.dirty.add(group); group.nodes.add(node);
    if (node.fn) node.preparedAt = -1;
    for (const reader of node.readers) this.mark(reader, group, seen);
  }
  node(name, fn = null) {
    const node = { name, fn, frame: null, candidate: null, dirty: new Set(),
      readers: new Set(), links: new Set(), disposed: false, observer: null };
    if (this.trace) this.nodes.push(node);
    return node;
  }
  source(name, value, { inputs = [] } = {}) {
    const node = this.node(name);
    node.inputs = inputs;
    node.frame = this.frame(value);
    return node;
  }
  frame(value) {
    return { id: ++this.serial, value, error: null, ready: true,
      reads: new Map(), cleanups: [], effects: [], group: null };
  }
  memo(name, fn, { effect = false } = {}) {
    const owner = this.current;
    const node = this.node(name, fn);
    if (effect) node.effect = true;
    if (owner) {
      owner.group ??= this.group(`mount:${owner.node.name}`, { mount: true });
      node.owner = owner;
      owner.cleanups.push(() => this.dispose(node, false));
    }
    // Children inherit preparation reads; an independent mount reads committed.
    const initial = this.evaluate(node, owner?.readGroup ?? null, new Set(), owner?.group ?? null);
    if (owner || initial.group || !initial.ready) {
      initial.group ??= this.group(`mount:${name}`, { mount: true });
      node.candidate = initial;
      this.mark(node, initial.group);
      this.relink(node);
      // A ready initial owned subtree can publish atomically without first
      // consuming unrelated pending input proposals. Suspended work coordinates
      // normally when flush runs.
      if (!owner && this.canCommit(initial.group)) this.commit(initial.group);
    } else {
      node.frame = initial;
      this.relink(node);
      for (const effect of initial.effects) effect();
    }
    for (const dep of initial.reads.keys())
      for (const group of dep.dirty) if (!node.dirty.has(group)) this.mark(node, group);
    return node;
  }
  render(name, fn) {
    const node = this.memo(name, fn, { effect: true });
    node.observer = { history: [] };
    if (node.frame) node.observer.history.push(this.value(node));
    return node;
  }
  value(node) {
    if (!node.frame || node.inputsPublished) return undefined;
    return node.frame.error ? { error: node.frame.error.message } : node.frame.value;
  }
  write(node, value, { group = null, name = node.name, open = false, above = node.inputs || [] } = {}) {
    if (node.fn) throw new Error('Write a source, not a memo');
    if (above.length) node.inputs = above;
    if (!group) {
      const queued = node.candidate?.group;
      // Repeated ordinary writes before preparation replace the same source
      // proposal. They cannot have independent downstream publications. Keep
      // distinct origins for different sources, explicit groups and actions.
      if (!open && !above.length && queued?.queuedAt === this.preparation && !queued.done)
        group = queued;
      else {
        group = this.group(name, { open, inputs: above });
        if (!open && !above.length) group.queuedAt = this.preparation;
      }
    }
    group.entries.add(node);
    node.candidate = { ...this.frame(value), group };
    this.mark(node, group);
    return group;
  }
  close(group, scope = group.scope) {
    group.ownScopes.delete(scope);
    this.root(group).scopes.delete(scope);
    this.flush();
  }
  relink(node) {
    const next = new Set([...(node.frame?.reads.keys() || []), ...(node.candidate?.reads.keys() || [])]);
    for (const old of node.links) if (!next.has(old)) old.readers.delete(node);
    for (const dep of next) dep.readers.add(node);
    node.links = next;
  }
  selected(dep, group, stack) {
    if (!group) return dep.inputsPublished ? null : dep.frame;
    group = this.root(group);
    const pending = this.choose(dep);
    if (!pending) return dep.inputsPublished ? null : dep.frame;
    if (this.above(group, pending)) {
      if (!this.publication(group).has(pending)) return dep.inputsPublished ? null : dep.frame;
      this.prepare(dep, stack);
      return dep.candidate;
    }
    if (this.above(pending, group)) throw RETRY;
    if (pending !== group) { this.join(group, pending); throw RETRY; }
    this.prepare(dep, stack);
    return dep.candidate;
  }
  evaluate(node, group, stack = new Set(), cohort = group, previousValue) {
    const result = { ...this.frame(undefined), node, group: cohort, readGroup: group, ready: false };
    const previous = this.current;
    const previousRead = this.activeRead;
    this.current = result;
    this.evaluations++;
    const read = dep => {
      // Register the dependency before selecting its frame: even a suspended
      // read creates a publication obligation and a wake-up relationship.
      result.reads.set(dep, null);
      dep.readers.add(node);
      node.links.add(dep);
      // Reading a dependency learns an obligation, not a new notification.
      // Existing obligations already propagated to this reader's subscribers.
      // Re-walking that suffix here makes a plain chain quadratic. Actual
      // writes still invalidate the complete affected suffix via mark().
      for (const pending of dep.dirty) if (!node.dirty.has(pending)) this.mark(node, pending);
      const selected = dep.owner === result ? dep.candidate : this.selected(dep, group, stack);
      result.reads.set(dep, selected?.id ?? null);
      if (!selected?.ready) throw WAIT;
      if (selected.error) throw selected.error;
      return selected.value;
    };
    this.activeRead = read;
    try {
      const value = node.fn(read);
      if (value && typeof value.then === 'function') {
        value.then(answer => this.answer(node, result, answer),
          error => this.answer(node, result, undefined, error));
      } else { result.value = value; result.ready = true; }
    } catch (error) {
      if (error === RETRY) result.retry = true;
      else if (error === WAIT) result.waiting = true;
      else { result.error = error; result.ready = true; }
    } finally { this.current = previous; this.activeRead = previousRead; }
    if (result.ready) this.valueIdentity(node, result, previousValue);
    else if (previousValue) result.previousValue = previousValue;
    return result;
  }
  onCleanup(fn) {
    if (!this.current) throw new Error('No evaluating frame');
    this.current.cleanups.push(fn);
  }
  onPublish(fn) {
    if (!this.current) throw new Error('No evaluating frame');
    this.current.effects.push(fn);
    this.current.node.effect = true;
  }
  cleanup(frame) {
    if (!frame) return;
    for (const fn of frame.cleanups.splice(0).reverse()) fn();
  }
  discard(node) {
    if (!node.candidate) return;
    this.cleanup(node.candidate);
    node.candidate.reads.clear();
    node.candidate.effects.length = 0;
    delete node.candidate.previousValue;
    node.candidate.readGroup = null;
    node.candidate.group = null;
    node.candidate = null;
    this.discarded++;
    this.relink(node);
    // node.dirty deliberately survives. Cancellation is not completion.
  }
  valid(node, candidate, group, stack) {
    if (!candidate.group || this.root(candidate.group) !== this.root(group) || candidate.retry) return false;
    for (const [dep, version] of candidate.reads) {
      const selected = this.selected(dep, group, stack);
      if ((selected?.id ?? null) !== version || candidate.waiting && selected?.ready) return false;
    }
    return true;
  }
  unchanged(frame, group, stack) {
    for (const [dep, version] of frame.reads)
      if ((this.selected(dep, group, stack)?.id ?? null) !== version) return false;
    return true;
  }
  prepare(node, stack = new Set()) {
    if (node.disposed) return;
    if (!node.fn) {
      const group = this.choose(node);
      if (group && !node.candidate) {
        // Superseded source work retains an obligation, not an old value.
        node.candidate = { ...this.frame(node.frame.value), id: node.frame.id,
          error: node.frame.error, group, reused: node.frame };
      }
      return;
    }
    if (node.preparedAt === this.preparation) return;
    let group = this.choose(node);
    if (!group || this.retiring(node, group)) return;
    if (stack.has(node)) throw new Error(`Dependency cycle at ${node.name}`);
    stack.add(node);
    try {
      // Every retry must discover/merge context or change a read generation.
      // The cap is a diagnostic, not a claimed termination proof.
      for (let attempt = 0; attempt < 100; attempt++) {
        group = this.choose(node);
        if (!group) return;
        try {
          if (node.candidate && this.valid(node, node.candidate, group, stack)) return;
        } catch (error) { if (error !== RETRY) throw error; }
        const old = node.candidate;
        if (old?.group && !old.ready && !old.waiting && !old.retry &&
            this.above(group, old.group) && !this.publication(group).has(this.root(old.group))) {
          let displaced = this.displaced.get(node);
          if (!displaced) this.displaced.set(node, displaced = new Set());
          displaced.add(old.group);
        }
        const displaced = this.displaced.get(node);
        if (displaced) {
          for (const oldGroup of displaced) if (this.root(oldGroup) === this.root(group)) displaced.delete(oldGroup);
          if (!displaced.size) this.displaced.delete(node);
        }
        const previousValue = old?.ready ? { id: old.id, value: old.value, error: old.error } : undefined;
        this.discard(node);
        try {
          if (node.frame && !node.inputsPublished && this.unchanged(node.frame, group, stack)) {
            // A notification is an obligation to check, not proof that a
            // dependency changed. Retain the actual owner and frame identity.
            node.candidate = { ...this.frame(node.frame.value), id: node.frame.id,
              error: node.frame.error, reads: new Map(node.frame.reads),
              group, reused: node.frame };
            this.relink(node);
            return;
          }
        } catch (error) { if (error !== RETRY) throw error; else continue; }
        const candidate = this.evaluate(node, group, stack, group, previousValue);
        candidate.group = group;
        node.candidate = candidate;
        this.relink(node);
        if (!candidate.retry && this.root(group) === this.choose(node)) return;
      }
      throw new Error(`Preparation did not converge: ${node.name}`);
    } finally { stack.delete(node); node.preparedAt = this.preparation; }
  }
  answer(node, token, value, error = null) {
    if (node.candidate !== token || node.disposed) return;
    token.ready = true; token.value = value; token.error = error;
    this.valueIdentity(node, token, token.previousValue);
    delete token.previousValue;
    if (!token.group) {
      token.group = this.group(`answer:${node.name}`);
      this.mark(node, token.group);
    }
    this.flush();
  }
  roots() {
    return [...new Set([...this.updates].map(g => this.root(g)))].filter(g => !g.done);
  }
  retiring(node, group) {
    const owner = node.owner;
    if (!owner) return false;
    const parent = owner.node;
    return this.retiring(parent, group) || parent.frame === owner &&
      parent.candidate?.group && !parent.candidate.reused && this.root(parent.candidate.group) === this.root(group);
  }
  publication(group) {
    const groups = new Set([this.root(group)]);
    if (!this.advances.length) return groups;
    let changed;
    do {
      changed = false;
      for (const edge of this.advances) {
        const roots = edge.filter(g => !g.done).map(g => this.root(g));
        if (roots.some(g => groups.has(g))) for (const g of roots)
          if (!groups.has(g)) { groups.add(g); changed = true; }
      }
    } while (changed);
    return groups;
  }
  advanceReadyInputs() {
    // A lower update can be ready except for consequences currently being
    // prepared above it. Revalidate those consequences against both proposals
    // before either publication. This is not a lifecycle or layer union.
    const affected = this.affected();
    const ready = group => {
      if (group.scopes.size) return false;
      for (const boundary of this.scopedBoundaries)
        if (boundary.scope && this.root(boundary.scope) === group) return false;
      for (const [node, groups] of this.displaced)
        if ([...groups].some(g => this.root(g) === group) && this.observed(node, group)) return false;
      for (const node of affected) {
        if (this.retiring(node, group) || this.choose(node) !== group) continue;
        if (!node.candidate?.ready && this.observed(node, group)) return false;
      }
      return true;
    };
    for (const node of affected) {
      const candidate = node.candidate;
      if (!candidate?.group) continue;
      const upper = this.root(candidate.group);
      for (const dep of candidate.reads.keys()) {
        const lower = this.choose(dep);
        if (!lower || !this.above(upper, lower) || this.publication(upper).has(lower)) continue;
        if (![...this.publication(lower)].every(ready)) continue;
        this.advances.push([upper, lower]);
        return true;
      }
    }
    return false;
  }
  canCommit(group) {
    const publication = this.publication(group);
    for (const member of publication) if (member.scopes.size) return false;
    // A closed action can still be waiting for a hidden input answer. Its
    // lifetime ends when coordinateScopes stages the correction.
    for (const boundary of this.scopedBoundaries)
      if (boundary.scope && publication.has(this.root(boundary.scope))) return false;
    const affected = this.affected();
    if (this.inputObservers.size)
      for (const member of publication) if (this.forwardedHold(member, affected)) return false;
    for (const node of affected) {
      if (node.disposed || [...publication].some(member => this.retiring(node, member)) ||
          !this.pending(node).some(member => publication.has(member))) continue;
      if (!node.effect) continue;
      if (!node.candidate?.ready || !publication.has(this.root(node.candidate.group))) return false;
      for (let owner = node.owner; owner; owner = owner.node.owner)
        if (owner.node.candidate === owner && !owner.ready) return false;
    }
    return true;
  }
  forwardedHold(group, affected) {
    // Restrict the cold walk to unresolved input work belonging to this
    // publication. Unrelated active boundaries cost no scan or traversal.
    let known;
    for (const input of affected) {
      if (input.candidate?.ready || !this.pending(input).includes(group)) continue;
      const observers = this.inputObservers.get(input);
      if (observers) for (const boundary of observers)
        if (this.observed(boundary.output, group, known ??= new Map())) return true;
    }
    return false;
  }
  observed(node, group, known) {
    if (known?.has(node)) return known.get(node);
    const seen = new Set();
    const visit = node => {
      if (known?.has(node)) return known.get(node);
      if (seen.has(node) || node.disposed || this.retiring(node, group)) return false;
      seen.add(node);
      if (node.effect) return true;
      for (const reader of node.readers) {
        const candidate = reader.candidate;
        // This publication may remove its own observer. A different held
        // publication has not removed the currently displayed observer yet.
        const replaces = candidate?.ready && !candidate.error && candidate.group &&
          this.root(candidate.group) === group;
        if ((candidate?.reads.has(node) || !replaces && reader.frame?.reads.has(node)) &&
          visit(reader)) return true;
      }
      for (const boundary of this.inputObservers.get(node) || [])
        if (visit(boundary.output)) return true;
      return false;
    };
    const result = visit(node);
    if (known) {
      if (result) known.set(node, true);
      // Cache absence only after the whole reachable search has failed.
      // A recursive back edge alone is not evidence of an unobserved node.
      else for (const visited of seen) known.set(visited, false);
    }
    return result;
  }
  forwardObservation(boundary, active) {
    if (boundary.probe) return;
    if (active) {
      let observers = this.inputObservers.get(boundary.input);
      if (!observers) this.inputObservers.set(boundary.input, observers = new Set());
      observers.add(boundary);
    } else {
      const observers = this.inputObservers.get(boundary.input);
      if (observers?.delete(boundary) && !observers.size) this.inputObservers.delete(boundary.input);
    }
  }
  commit(group) {
    const old = [], callbacks = [], changed = [];
    const publication = this.publication(group);
    const affected = this.affected();
    const retiring = new Set(affected.filter(node => [...publication].some(member => this.retiring(node, member))));
    for (const node of affected) {
      if (retiring.has(node)) continue;
      if (!node.candidate?.group || !publication.has(this.root(node.candidate.group))) continue;
      if (!node.candidate.ready) {
        // The inputs can publish once no visible reader needs this answer.
        // Keep the flight and its ownership, but its old result is no longer
        // a valid committed value for an ordinary reader arriving later.
        node.inputsPublished = true;
        node.candidate.group = node.candidate.readGroup = null;
        continue;
      }
      if (node.candidate.reused === node.frame) { node.candidate = null; continue; }
      old.push(node.frame);
      node.frame = node.candidate; node.candidate = null;
      node.inputsPublished = false;
      node.frame.group = null;
      node.frame.readGroup = null;
      changed.push(node);
      for (const effect of node.frame.effects) callbacks.push({ node, effect });
    }
    this.affectedCache = null;
    for (const root of publication) for (const member of root.members) {
      member.done = true; this.updates.delete(member); this.dynamicGroups.delete(member);
    }
    this.advances = this.advances.filter(edge => edge.every(g => !g.done));
    for (const [node, groups] of this.displaced) {
      for (const member of groups) if (member.done) groups.delete(member);
      if (!groups.size) this.displaced.delete(node);
    }
    this.joins = this.joins.filter(edge => !edge.some(g => g.done));
    this.couplings = this.couplings.filter(edge => edge.every(g => !g.done));
    for (const action of this.actions) if (action.done) this.actions.delete(action);
    for (const node of affected) { this.pending(node); this.relink(node); }
    // Install every frame before cleanup/delivery. Old owners clean up before
    // replacement callbacks. No sibling callback ordering contract is modeled.
    for (const frame of old) this.cleanup(frame);
    for (const { node, effect } of callbacks) if (!node.disposed) effect();
    for (const node of changed) if (node.observer) node.observer.history.push(this.value(node));
    if (this.trace) this.publications.push(Object.fromEntries(this.nodes.filter(n => n.observer && !n.disposed)
      .map(node => [node.name, this.value(node)])));
  }
  rebuildLayers() {
    if (!this.resetNeeded && !this.dynamicGroups.size) return false;
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
      edge.reduce((a, b) => a ? this.join(a, b, false, true) : b, null);
    const retained = [];
    for (const edge of this.joins) {
      if (edge.some(g => g.done)) continue;
      const groups = [...new Set(edge.map(g => this.root(g)))];
      if (new Set(groups.map(g => g.level)).size > 1) continue;
      groups.reduce((a, b) => a ? this.join(a, b, false) : b, null);
      retained.push(edge);
    }
    this.joins = retained;
    return true;
  }
  optimistic(name, input) {
    const control = this.source(`${name}:override`, NONE);
    const boundary = { input, control, active: false, value: NONE, empty: NONE, output: null };
    const output = this.memo(name, read => {
      const override = read(control);
      return override === NONE ? read(input) : override;
    });
    boundary.output = output;
    this.boundaries.set(output, boundary);
    return output;
  }
  guess(output, value, { action } = {}) {
    if (action) {
      if (action.done || !action.ownScopes.size) throw new Error('Action body has ended');
      const boundary = this.boundaries.get(output);
      if (!boundary) throw new Error('Not an optimistic output');
      if (boundary.scope && !boundary.scope.done) this.couple(action, boundary.scope);
      boundary.scope = action;
      this.scopedBoundaries.add(boundary);
    }
    const boundary = this.boundaries.get(output);
    if (!boundary) throw new Error('Not an optimistic output');
    const previous = boundary.active ? boundary.value : this.value(output);
    if (!boundary.active) {
      boundary.active = true;
      this.forwardObservation(boundary, true);
    }
    boundary.value = typeof value === 'function' ? value(previous) : value;
    const group = this.group(`guess:${output.name}`, {
      position: () => 1 + this.inputPosition(boundary)
    });
    this.write(boundary.control, boundary.value, { group });
    return group;
  }
  clear(output) {
    const boundary = this.boundaries.get(output);
    if (!boundary) throw new Error('Not an optimistic output');
    if (!boundary.active) return;
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
    this.forwardObservation(boundary, false);
    boundary.value = boundary.empty;
    const correction = this.group(`clear:${output.name}`, { position: () => this.inputPosition(boundary) });
    // Transfer publication obligations. Calculation cancellation follows normal
    // dependency validation, so equal proposed outputs can retain async users.
    const replaced = new Set();
    for (const group of [...this.updates]) {
      if (!group.entries.delete(boundary.control) || group.entries.size || group.mount) continue;
      group.done = true; this.updates.delete(group); this.dynamicGroups.delete(group); replaced.add(group);
      for (const node of group.nodes) if (node.dirty.delete(group)) {
        node.dirty.add(correction); correction.nodes.add(node);
      }
      group.root = correction;
    }
    for (const edges of [this.couplings, this.joins, this.advances])
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
  discoverNewLayers() {
    // New lower work must be prepared before a new upper context can displace
    // it. Otherwise skipping its async calculation is mistaken for readiness.
    // An upper context already in flight remains eligible when later lower
    // work arrives: that work can request combined preparation directly.
    const fresh = [...this.updates].filter(group => !group.prepared);
    if (!fresh.length) return;
    if (!fresh.some(group => group.level > 0)) {
      for (const group of fresh) group.prepared = true;
      return;
    }
    this.admitted = new Set([...this.updates].filter(group => group.prepared));
    try {
      for (;;) {
        const remaining = fresh.filter(group => !this.admitted.has(group));
        if (!remaining.length) break;
        const level = Math.min(...remaining.map(group => group.level));
        for (const group of remaining) if (group.level === level) this.admitted.add(group);
        for (let pass = 0; pass < 1000; pass++) {
          this.preparation++;
          const merges = this.merges, obligations = this.obligations;
          for (const node of this.affected()) this.prepare(node);
          if (merges === this.merges && obligations === this.obligations && !this.rebuildLayers()) break;
          if (pass === 999) throw new Error('New layer preparation did not converge');
        }
      }
    } finally {
      this.admitted = null;
      for (const group of fresh) group.prepared = true;
    }
  }
  flush() {
    if (this.flushing || !this.updates.size) return;
    this.flushing = true;
    try {
      for (let pass = 0; pass < 1000; pass++) {
        this.rebuildLayers();
        this.discoverNewLayers();
        this.preparation++;
        const before = this.merges;
        const obligations = this.obligations;
        for (const node of this.affected()) this.prepare(node);
        // A speculative read can discover an origin after an earlier reader
        // was prepared. Stabilize those obligations before testing visibility.
        if (before !== this.merges || obligations !== this.obligations || this.rebuildLayers()) continue;
        if (this.coordinateBoundaries() || before !== this.merges) continue;
        if (this.advanceReadyInputs()) continue;
        const ready = this.roots().find(group => this.canCommit(group));
        if (!ready) return;
        this.commit(ready);
      }
      throw new Error('Publication did not converge');
    } finally { this.flushing = false; }
  }
  dispose(node, flush = true) {
    if (node.disposed) return;
    this.affectedCache = null;
    const observation = this.observations.get(node);
    if (observation) {
      this.observations.delete(node);
      this.dispose(observation.output, false);
      this.dispose(observation.fallback, false);
    }
    this.displaced.delete(node);
    this.discard(node); this.cleanup(node.frame);
    node.disposed = true;
    for (const dep of node.links) dep.readers.delete(node);
    node.links.clear();
    for (const group of node.dirty) group.nodes.delete(node);
    node.dirty.clear();
    if (this.trace) this.nodes = this.nodes.filter(n => n !== node);
    const boundary = this.boundaries.get(node);
    if (boundary) {
      this.forwardObservation(boundary, false);
      this.scopedBoundaries.delete(boundary);
      this.boundaries.delete(node);
      this.dispose(boundary.control, false);
    }
    if (flush) this.flush();
  }
  couplings = [];
  actions = new Set();
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
  observations = new Map();
  activeRead = null;
  inputGroup(source) {
    const boundary = this.boundaries.get(source);
    return (boundary?.active && this.choose(boundary.input)) || this.choose(source);
  }
  proposedPending(source) {
    if (!source.frame) return false;
    const candidate = source.candidate;
    if ((this.choose(source) || source.inputsPublished) && candidate &&
      (!candidate.ready || !Object.is(candidate.value, source.frame.value))) return true;
    const boundary = this.boundaries.get(source);
    if (boundary?.active && this.choose(boundary.input)) {
      const incoming = boundary.input.candidate;
      return !incoming?.ready || !Object.is(incoming.value, source.frame.value);
    }
    return false;
  }
  pendingOutput(source) {
    const existing = this.observations.get(source);
    if (existing) return existing.output;
    // Source-owned identity, independent of the first calling computation.
    const owner = this.current;
    this.current = null;
    let record;
    try {
      const fallback = this.source(`${source.name}:pending:false`, false);
      const output = this.optimistic(`${source.name}:pending`, fallback);
      const boundary = this.boundaries.get(output);
      boundary.probe = true;
      boundary.input = source; // Context parent; the selector's fallback is false.
      const initial = this.proposedPending(source);
      if (initial) {
        // Initialize before the first reader exists; no published reader is
        // bypassed. Later changes always use the common proposal protocol.
        boundary.active = true; boundary.value = true;
        boundary.control.frame.value = true;
        output.frame.value = true;
        output.frame.reads = new Map([[boundary.control, boundary.control.frame.id]]);
        this.relink(output);
      }
      record = { source, output, fallback, boundary, retiring: null };
      this.observations.set(source, record);
    } finally { this.current = owner; }
    return record.output;
  }
  isPending(source) {
    const output = this.pendingOutput(source);
    return this.current ? this.activeRead(output) : this.value(output);
  }
  readyBelowObservation(group, output) {
    group = this.root(group);
    if (group.scopes.size) return false;
    const above = new Set();
    const visit = node => {
      if (above.has(node)) return;
      above.add(node);
      for (const reader of node.readers) visit(reader);
    };
    visit(output);
    // This boundary's consequences will be replaced by retirement. They cannot
    // require their obsolete boolean to finish before that retirement starts.
    for (const node of this.affected()) {
      if (above.has(node) || node.disposed || this.retiring(node, group)) continue;
      if (this.choose(node) === group && !node.candidate?.ready) return false;
    }
    return true;
  }
  coordinateScopes() {
    const scoped = this.scopedBoundaries;
    if (!scoped.size) return false;
    // Input arrival joins the guessing scope. A parent optimistic proposal is
    // an input here, just as an ordinary source proposal is.
    for (const boundary of scoped) {
      const input = this.choose(boundary.input);
      if (input && boundary.input.candidate?.ready && this.couple(boundary.scope, input)) return true;
    }
    const waiting = new Set();
    for (const boundary of scoped) {
      const scope = this.root(boundary.scope);
      if (scope.scopes.size) continue;
      if ((this.choose(boundary.input) || boundary.input.inputsPublished) && !boundary.input.candidate?.ready &&
        this.observed(boundary.output, scope))
        waiting.add(scope);
    }
    let changed = false;
    for (const boundary of scoped) {
      const scope = this.root(boundary.scope);
      if (scope.scopes.size || waiting.has(scope)) continue;
      const correction = this.clear(boundary.output);
      boundary.scope = null;
      this.scopedBoundaries.delete(boundary);
      if (correction) this.couple(correction, scope);
      changed = true;
    }
    return changed;
  }
  coordinateBoundaries() {
    if (this.coordinateScopes()) return true;
    for (const record of this.observations.values()) {
      const { source, output, boundary } = record;
      const group = this.inputGroup(source);
      const generation = source.candidate ?? source.frame;
      if (record.retiring) {
        if (!record.retiring.group.done && record.retiring.generation === generation) continue;
        record.retiring = null;
      }
      if (boundary.active && !(source.inputsPublished && !source.candidate?.ready) && (!group || this.readyBelowObservation(group, output))) {
        const correction = this.clear(output);
        if (correction && group) this.couple(correction, group);
        if (correction || group) record.retiring = { group: correction || group, generation };
        return true;
      }
      const next = this.proposedPending(source);
      if (next !== (boundary.active ? boundary.value : false)) {
        this.guess(output, next);
        return true;
      }
    }
    return false;
  }
}
