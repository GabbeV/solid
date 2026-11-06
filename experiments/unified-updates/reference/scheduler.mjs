// Operational research model. Deliberately scan-based, not production code.
// There is one committed frame and at most one eligible candidate per node.
const WAIT = Symbol('no eligible value');
const RETRY = Symbol('newly discovered update context');
const DISCOVER = Symbol('settle lower joins before joining apparent peers');
export class Scheduler {
  nodes = [];
  updates = new Set();
  serial = 0;
  current = null;
  flushing = false;
  publications = [];
  discarded = 0;
  evaluations = 0;
  merges = 0;
  admitted = null;
  discoveryRounds = 0;
  epoch = 0;
  discoveredAt = -1;
  discoveryRequested = false;

  group(name, { open = false, parents = [], inputs = [], mount = false } = {}) {
    const group = { name, id: ++this.serial, root: null, below: new Set(parents), inputs: new Set(inputs),
      scopes: new Set(open ? [name] : []), done: false, mount };
    group.root = group;
    this.updates.add(group);
    return group;
  }
  root(group) {
    if (group.root !== group) group.root = this.root(group.root);
    return group.root;
  }
  above(a, b, seen = new Set()) {
    a = this.root(a); b = this.root(b);
    if (a === b || seen.has(a)) return false;
    seen.add(a);
    return [...a.below].some(p => {
      p = this.root(p);
      return !p.done && (p === b || this.above(p, b, seen));
    });
  }
  join(a, b) {
    a = this.root(a); b = this.root(b);
    if (a === b) return a;
    if (this.above(a, b) || this.above(b, a))
      throw new Error('Cannot join an update with its ancestor');
    // A boundary's apparent peer can still join an unfinished lower update.
    // Establish fresh lower work before making that union irreversible.
    if (this.flushing && !this.admitted && this.discoveredAt !== this.epoch &&
        [a, b].some(g => [...g.below].some(p => !this.root(p).done))) {
      this.discoveryRequested = true;
      throw DISCOVER;
    }
    if (a.id > b.id) [a, b] = [b, a];
    b.root = a;
    for (const p of b.below) a.below.add(p);
    for (const input of b.inputs) a.inputs.add(input);
    for (const scope of b.scopes) a.scopes.add(scope);
    this.merges++;
    return a;
  }
  pending(node) {
    const groups = new Set([...node.dirty].map(g => this.root(g)).filter(g => !g.done));
    node.dirty = groups;
    return [...groups];
  }
  choose(node) {
    const groups = this.pending(node).filter(g => !this.admitted || this.admitted.has(g));
    const frontier = groups.filter(g => !groups.some(other => this.above(other, g)));
    return frontier.reduce((a, b) => a ? this.join(a, b) : b, null);
  }
  mark(node, group, seen = new Set()) {
    if (seen.has(node) || node.disposed) return;
    seen.add(node);
    group = this.root(group);
    if (!this.pending(node).includes(group)) node.fresh.add(group);
    node.dirty.add(group);
    for (const reader of node.readers) this.mark(reader, group, seen);
  }
  invalidate(node, group, seen = new Set()) {
    if (seen.has(node) || node.disposed) return;
    seen.add(node);
    group = this.root(group);
    node.dirty.add(group); node.fresh.add(group);
    for (const reader of node.readers) this.invalidate(reader, group, seen);
  }
  acknowledge(node, group) {
    group = this.root(group);
    for (const fresh of node.fresh) if (this.root(fresh) === group) node.fresh.delete(fresh);
  }
  node(name, fn = null) {
    const node = { name, fn, frame: null, candidate: null, dirty: new Set(),
      readers: new Set(), links: new Set(), fresh: new Set(), disposed: false, observer: null };
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
      for (const group of this.pending(dep)) this.mark(node, group);
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
    this.epoch++;
    group ??= this.group(name, { open, parents: above.flatMap(input => this.pending(input)), inputs: above });
    if (node.candidate) group = this.join(group, node.candidate.group);
    node.candidate = { ...this.frame(value), group };
    this.invalidate(node, group);
    return group;
  }
  close(group, scope = group.name) {
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
      for (const pending of this.pending(dep)) this.mark(node, pending);
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
      if (error === RETRY || error === DISCOVER) result.retry = true;
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
  prepare(node, stack = new Set()) {
    if (node.disposed || !node.fn) return;
    let group = this.choose(node);
    if (!group) return;
    if (this.retiring(node, group)) { this.acknowledge(node, group); return; }
    if (stack.has(node)) throw new Error(`Dependency cycle at ${node.name}`);
    stack.add(node);
    try {
      // Every retry must discover/merge context or change a read generation.
      // The cap is a diagnostic, not a claimed termination proof.
      for (let attempt = 0; attempt < 100; attempt++) {
        group = this.choose(node);
        try {
          if (node.candidate && this.valid(node, node.candidate, group, stack)) {
            this.acknowledge(node, group); return;
          }
        } catch (error) { if (error !== RETRY) throw error; }
        this.discard(node);
        const candidate = this.evaluate(node, group, stack);
        candidate.group = group;
        node.candidate = candidate;
        this.relink(node);
        if (this.discoveryRequested && !this.admitted) throw DISCOVER;
        if (!candidate.retry && this.root(group) === this.choose(node)) {
          this.acknowledge(node, group); return;
        }
      }
      throw new Error(`Preparation did not converge: ${node.name}`);
    } finally { stack.delete(node); }
  }
  answer(node, token, value, error = null) {
    if (node.candidate !== token || node.disposed) return;
    this.epoch++;
    token.ready = true; token.value = value; token.error = error;
    for (const reader of node.readers) this.invalidate(reader, token.group);
    this.flush();
  }
  inputClosure(input, seen = new Set()) {
    if (seen.has(input)) return seen;
    seen.add(input);
    for (const dep of input.inputs || input.links) this.inputClosure(dep, seen);
    return seen;
  }
  refreshParents() {
    for (const group of this.roots()) for (const input of group.inputs)
      for (const ancestor of this.inputClosure(input))
        for (const parent of this.pending(ancestor)) {
          if (parent === group) continue;
          if (this.above(parent, group)) throw new Error('Cyclic update ancestry');
          group.below.add(parent);
        }
  }
  roots() {
    return [...new Set([...this.updates].map(g => this.root(g)))].filter(g => !g.done);
  }
  retiring(node, group) {
    const owner = node.owner;
    if (!owner) return false;
    const parent = owner.node;
    return this.retiring(parent, group) || parent.frame === owner &&
      parent.candidate && this.root(parent.candidate.group) === this.root(group);
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
      old.push(node.frame);
      node.frame = node.candidate; node.candidate = null;
      node.frame.group = null;
      changed.push(node);
      for (const effect of node.frame.effects) callbacks.push({ node, effect });
    }
    group.done = true;
    for (const update of this.updates) if (this.root(update) === group) this.updates.delete(update);
    for (const node of this.nodes) {
      this.pending(node); this.acknowledge(node, group); this.relink(node);
    }
    // Install every frame before cleanup/delivery. Old owners clean up before
    // replacement callbacks. No sibling callback ordering contract is modeled.
    for (const frame of old) this.cleanup(frame);
    for (const { node, effect } of callbacks) if (!node.disposed) effect();
    for (const node of changed) if (node.observer) node.observer.history.push(this.value(node));
    this.publications.push(Object.fromEntries(this.nodes.filter(n => n.observer && !n.disposed)
      .map(node => [node.name, this.value(node)])));
  }
  discover() {
    this.discoveryRequested = false;
    // Establish fresh lower work before allowing a higher update to consume
    // apparent peers. Admission follows ancestry, not a numeric priority.
    // A suspended lower calculation does not stop admission of its children.
    this.admitted = new Set();
    try {
      for (let round = 0; round < 1000; round++) {
        this.discoveryRounds++;
        this.refreshParents();
        this.admitted = new Set([...this.admitted].map(g => this.root(g)).filter(g => !g.done));
        const roots = this.roots();
        const next = roots.filter(g => !this.admitted.has(g) &&
          [...g.below].every(p => this.root(p).done || this.admitted.has(this.root(p))));
        for (const group of next) this.admitted.add(group);
        for (let pass = 0; pass < 1000; pass++) {
          this.admitted = new Set([...this.admitted].map(g => this.root(g)).filter(g => !g.done));
          const work = this.nodes.filter(node => node.fn && !node.disposed &&
            [...node.fresh].some(g => this.admitted.has(this.root(g))));
          if (!work.length) break;
          for (const node of work) this.prepare(node);
          if (pass === 999) throw new Error('Fresh preparation did not converge');
        }
        if (this.roots().every(g => this.admitted.has(g))) {
          this.discoveredAt = this.epoch; return;
        }
        if (!next.length) throw new Error('Update ancestry has no admissible frontier');
      }
      throw new Error('Context discovery did not converge');
    } finally { this.admitted = null; }
  }
  flush() {
    if (this.flushing) return;
    this.flushing = true;
    try {
      for (let pass = 0; pass < 1000; pass++) {
        this.refreshParents();
        const before = this.merges;
        try {
          for (const node of this.nodes) this.prepare(node);
        } catch (error) {
          if (error !== DISCOVER) throw error;
          this.discover();
          continue;
        }
        // A merge can alter exclusions for a candidate evaluated earlier.
        // Validate the whole preparation before considering publication.
        if (before !== this.merges) continue;
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
    node.links.clear(); node.dirty.clear(); node.fresh.clear();
    this.nodes = this.nodes.filter(n => n !== node);
    if (flush) this.flush();
  }
}
