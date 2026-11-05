// Operational research model. Deliberately scan-based, not production code.
// There is one committed frame and at most one eligible candidate per node.
const WAIT = Symbol('no eligible value');
const NONE = Symbol("no override");
const RETRY = Symbol('newly discovered update context');
// Active input/output selectors introduce positions only while overridden.
// Publication remains the ordinary one-frame/one-candidate protocol.
// This is still an operational model, not production code or a full action API.
export class ActiveLayerScheduler {
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
  joins = [];
  resetNeeded = false;

  layerOf(node, seen = new Set()) {
    if (seen.has(node)) return 0;
    seen.add(node);
    try {
      const boundary = this.boundaries.get(node);
      if (boundary) return this.layerOf(boundary.input, seen) + (boundary.active ? 1 : 0);
      if (node.inputs?.length)
        return 1 + Math.max(...node.inputs.map(input => this.layerOf(input, seen)));
      if (!node.fn) return 0;
      return Math.max(0, ...[...node.links].map(input => this.layerOf(input, seen)));
    } finally { seen.delete(node); }
  }
  group(name, { open = false, inputs = [], mount = false, position } = {}) {
    const levelSpec = position ?? ( inputs.length ? 1 + Math.max(...inputs.map(input => this.layerOf(input))) : mount ? null : 0);
    const level = typeof levelSpec === "function" ? levelSpec() : levelSpec;
    const group = { name, id: ++this.serial, root: null, level, levelSpec, entries: new Set(),
      scopes: new Set(), scope: Symbol(name), done: false, mount };
    if (open) group.scopes.add(group.scope);
    group.root = group;
    group.members = new Set([group]);
    group.ownScopes = new Set(group.scopes);
    this.updates.add(group);
    return group;
  }
  root(group) {
    if (group.root !== group) group.root = this.root(group.root);
    return group.root;
  }
  above(a, b) {
    a = this.root(a); b = this.root(b);
    return a.level !== null && b.level !== null && a.level > b.level;
  }
  join(a, b, record = true) {
    a = this.root(a); b = this.root(b);
    if (a === b) return a;
    if (this.above(a, b) || this.above(b, a))
      throw new Error('Cannot join an update with its ancestor');
    if (record) this.joins.push([...a.members, ...b.members]);
    if (a.id > b.id) [a, b] = [b, a];
    b.root = a;
    for (const member of b.members) a.members.add(member);
    // Unpublished mounting has no competing layer of its own. It adopts the
    // producing context when it first participates in an input's update.
    a.level ??= b.level;
    for (const scope of b.scopes) a.scopes.add(scope);
    this.merges++;
    return a;
  }
  pending(node) {
    for (const g of node.dirty) if (g.done) node.dirty.delete(g);
    return [...new Set([...node.dirty].map(g => this.root(g)))];
  }
  choose(node) {
    const groups = this.pending(node);
    const frontier = groups.filter(g => !groups.some(other => this.above(other, g)));
    return frontier.reduce((a, b) => a ? this.join(a, b) : b, null);
  }
  mark(node, group, seen = new Set()) {
    if (seen.has(node) || node.disposed) return;
    seen.add(node); node.dirty.add(group);
    for (const reader of node.readers) this.mark(reader, group, seen);
  }
  node(name, fn = null) {
    const node = { name, fn, frame: null, candidate: null, dirty: new Set(),
      readers: new Set(), links: new Set(), disposed: false, observer: null };
    this.nodes.push(node);
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
  memo(name, fn) {
    const owner = this.current;
    const node = this.node(name, fn);
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
      for (const group of dep.dirty) this.mark(node, group);
    return node;
  }
  render(name, fn) {
    const node = this.memo(name, fn);
    node.observer = { history: [] };
    if (node.frame) node.observer.history.push(this.value(node));
    return node;
  }
  value(node) {
    if (!node.frame) return undefined;
    return node.frame.error ? { error: node.frame.error.message } : node.frame.value;
  }
  write(node, value, { group = null, name = node.name, open = false, above = node.inputs || [] } = {}) {
    if (node.fn) throw new Error('Write a source, not a memo');
    if (above.length) node.inputs = above;
    group ??= this.group(name, { open, inputs: above });
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
    if (!group) return dep.frame;
    group = this.root(group);
    const pending = this.choose(dep);
    if (!pending) return dep.frame;
    if (this.above(group, pending)) return dep.frame;
    if (this.above(pending, group)) throw RETRY;
    if (pending !== group) { this.join(group, pending); throw RETRY; }
    this.prepare(dep, stack);
    return dep.candidate;
  }
  evaluate(node, group, stack = new Set(), cohort = group) {
    const result = { ...this.frame(undefined), node, group: cohort, readGroup: group, ready: false };
    const previous = this.current;
    this.current = result;
    this.evaluations++;
    const read = dep => {
      // Register the dependency before selecting its frame: even a suspended
      // read creates a publication obligation and a wake-up relationship.
      result.reads.set(dep, null);
      dep.readers.add(node);
      node.links.add(dep);
      for (const pending of dep.dirty) this.mark(node, pending);
      const selected = dep.owner === result ? dep.candidate : this.selected(dep, group, stack);
      result.reads.set(dep, selected?.id ?? null);
      if (!selected?.ready) throw WAIT;
      if (selected.error) throw selected.error;
      return selected.value;
    };
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
    } finally { this.current = previous; }
    return result;
  }
  onCleanup(fn) {
    if (!this.current) throw new Error('No evaluating frame');
    this.current.cleanups.push(fn);
  }
  onPublish(fn) {
    if (!this.current) throw new Error('No evaluating frame');
    this.current.effects.push(fn);
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
    node.candidate.readGroup = null;
    node.candidate.group = null;
    node.candidate = null;
    this.discarded++;
    this.relink(node);
    // node.dirty deliberately survives. Cancellation is not completion.
  }
  valid(node, candidate, group, stack) {
    if (this.root(candidate.group) !== this.root(group) || candidate.retry) return false;
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
    if (!node.fn) { this.choose(node); return; }
    let group = this.choose(node);
    if (!group || this.retiring(node, group)) return;
    if (stack.has(node)) throw new Error(`Dependency cycle at ${node.name}`);
    stack.add(node);
    try {
      // Every retry must discover/merge context or change a read generation.
      // The cap is a diagnostic, not a claimed termination proof.
      for (let attempt = 0; attempt < 100; attempt++) {
        group = this.choose(node);
        try {
          if (node.candidate && this.valid(node, node.candidate, group, stack)) return;
        } catch (error) { if (error !== RETRY) throw error; }
        this.discard(node);
        try {
          if (node.frame && this.unchanged(node.frame, group, stack)) {
            // A notification is an obligation to check, not proof that a
            // dependency changed. Retain the actual owner and frame identity.
            node.candidate = { ...this.frame(node.frame.value), id: node.frame.id,
              error: node.frame.error, reads: new Map(node.frame.reads),
              group, reused: node.frame };
            this.relink(node);
            return;
          }
        } catch (error) { if (error !== RETRY) throw error; else continue; }
        const candidate = this.evaluate(node, group, stack);
        candidate.group = group;
        node.candidate = candidate;
        this.relink(node);
        if (!candidate.retry && this.root(group) === this.choose(node)) return;
      }
      throw new Error(`Preparation did not converge: ${node.name}`);
    } finally { stack.delete(node); }
  }
  answer(node, token, value, error = null) {
    if (node.candidate !== token || node.disposed) return;
    token.ready = true; token.value = value; token.error = error;
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
      parent.candidate && !parent.candidate.reused && this.root(parent.candidate.group) === this.root(group);
  }
  canCommit(group) {
    if (group.scopes.size) return false;
    for (const node of this.nodes) {
      if (node.disposed || this.retiring(node, group) || !this.pending(node).includes(group)) continue;
      if (!node.candidate?.ready || this.root(node.candidate.group) !== group) return false;
    }
    return true;
  }
  commit(group) {
    const old = [], callbacks = [], changed = [];
    const retiring = new Set(this.nodes.filter(node => this.retiring(node, group)));
    for (const node of this.nodes) {
      if (retiring.has(node)) continue;
      if (!node.candidate || this.root(node.candidate.group) !== group) continue;
      if (node.candidate.reused === node.frame) { node.candidate = null; continue; }
      old.push(node.frame);
      node.frame = node.candidate; node.candidate = null;
      node.frame.group = null;
      node.frame.readGroup = null;
      changed.push(node);
      for (const effect of node.frame.effects) callbacks.push({ node, effect });
    }
    group.done = true;
    for (const member of group.members) { member.done = true; this.updates.delete(member); }
    this.joins = this.joins.filter(edge => !edge.some(g => g.done));
    for (const node of this.nodes) { this.pending(node); this.relink(node); }
    // Install every frame before cleanup/delivery. Old owners clean up before
    // replacement callbacks. No sibling callback ordering contract is modeled.
    for (const frame of old) this.cleanup(frame);
    for (const { node, effect } of callbacks) if (!node.disposed) effect();
    for (const node of changed) if (node.observer) node.observer.history.push(this.value(node));
    this.publications.push(Object.fromEntries(this.nodes.filter(n => n.observer && !n.disposed)
      .map(node => [node.name, this.value(node)])));
  }
  rebuildLayers() {
    const levels = new Map([...this.updates].map(g =>
      [g, typeof g.levelSpec === 'function' ? g.levelSpec() : g.levelSpec]));
    if (!this.resetNeeded && ![...levels].some(([g, level]) =>
      level !== null && level !== this.root(g).level)) return false;
    this.resetNeeded = false;
    for (const [g, level] of levels) {
      g.root = g; g.level = level;
      g.scopes = new Set(g.ownScopes); g.members = new Set([g]);
    }
    const retained = [];
    for (const edge of this.joins) {
      if (edge.some(g => g.done)) continue;
      const groups = [...new Set(edge.map(g => this.root(g)))];
      const positions = new Set(groups.map(g => g.level).filter(level => level !== null));
      if (positions.size > 1) continue;
      groups.reduce((a, b) => a ? this.join(a, b, false) : b, null);
      retained.push(edge);
    }
    this.joins = retained;
    return true;
  }
  optimistic(name, input) {
    const control = this.source(`${name}:override`, NONE);
    const boundary = { input, control, active: false, value: NONE, output: null };
    const output = this.memo(name, read => {
      const override = read(control);
      return override === NONE ? read(input) : override;
    });
    boundary.output = output;
    this.boundaries.set(output, boundary);
    return output;
  }
  guess(output, value) {
    const boundary = this.boundaries.get(output);
    if (!boundary) throw new Error('Not an optimistic output');
    const previous = boundary.active ? boundary.value : this.value(output);
    boundary.active = true;
    boundary.value = typeof value === 'function' ? value(previous) : value;
    const group = this.group(`guess:${output.name}`, {
      position: () => 1 + this.layerOf(boundary.input)
    });
    this.write(boundary.control, boundary.value, { group });
    return group;
  }
  clear(output) {
    const boundary = this.boundaries.get(output);
    if (!boundary) throw new Error('Not an optimistic output');
    if (!boundary.active) return;
    boundary.active = false;
    boundary.value = NONE;
    // Cancel outstanding guesses at this boundary, without cancelling peer
    // boundaries that previously shared their publication group.
    for (const group of [...this.updates]) {
      if (!group.entries.delete(boundary.control) || group.entries.size || group.mount) continue;
      group.done = true;
      this.updates.delete(group);
      for (const node of [...this.nodes]) {
        node.dirty.delete(group);
        if (node.candidate?.group === group) this.discard(node);
      }
      group.root = group;
    }
    this.resetNeeded = true;
    this.rebuildLayers();
    // An override that never published has no selected committed value to
    // replace. Cancelling its candidate restores the existing selector frame.
    if (boundary.control.frame.value === NONE) return;
    const group = this.group(`clear:${output.name}`, { position: () => this.layerOf(boundary.input) });
    this.write(boundary.control, NONE, { group });
    return group;
  }
  flush() {
    if (this.flushing) return;
    this.flushing = true;
    try {
      for (let pass = 0; pass < 1000; pass++) {
        this.rebuildLayers();
        const before = this.merges;
        for (const node of this.nodes) this.prepare(node);
        // A merge can alter exclusions for a candidate evaluated earlier.
        // Validate the whole preparation before considering publication.
        if (before !== this.merges || this.rebuildLayers()) continue;
        const ready = this.roots().find(group => this.canCommit(group));
        if (!ready) return;
        this.commit(ready);
      }
      throw new Error('Publication did not converge');
    } finally { this.flushing = false; }
  }
  dispose(node, flush = true) {
    if (node.disposed) return;
    this.discard(node); this.cleanup(node.frame);
    node.disposed = true;
    for (const dep of node.links) dep.readers.delete(node);
    node.links.clear(); node.dirty.clear();
    this.nodes = this.nodes.filter(n => n !== node);
    const boundary = this.boundaries.get(node);
    if (boundary) {
      this.boundaries.delete(node);
      this.dispose(boundary.control, false);
    }
    if (flush) this.flush();
  }
}
