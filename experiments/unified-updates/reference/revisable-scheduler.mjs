// Operational research model. Deliberately scan-based, not production code.
// There is one committed frame and at most one eligible candidate per node.
const WAIT = Symbol('no eligible value');
const RETRY = Symbol('newly discovered update context');
const DISCOVER = Symbol('settle lower joins before joining apparent peers');
export class RevisableScheduler {
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
  discoveryRequested = false;
  joins = [];
  rebuilding = false;
  rebuiltAt = -1;

  group(name, { open = false, parents = [], inputs = [], mount = false } = {}) {
    const group = { name, id: ++this.serial, root: null, below: new Set(parents), inputs: new Set(inputs),
      scopes: new Set(), scope: Symbol(name), done: false, mount };
    if (open) group.scopes.add(group.scope);
    group.root = group;
    group.members = new Set([group]);
    group.ownBelow = new Set(parents);
    group.ownInputs = new Set(inputs);
    group.ownScopes = new Set(group.scopes);
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
  join(a, b, record = true) {
    a = this.root(a); b = this.root(b);
    if (a === b) return a;
    if (this.above(a, b) || this.above(b, a))
      throw new Error('Cannot join an update with its ancestor');
    if (record && this.flushing && !this.rebuilding && this.rebuiltAt !== this.epoch &&
        [a, b].some(g => [...g.below].some(p => !this.root(p).done))) {
      this.discoveryRequested = true;
      throw DISCOVER;
    }
    if (record) this.joins.push({ left: [...a.members], right: [...b.members] });
    if (a.id > b.id) [a, b] = [b, a];
    b.root = a;
    for (const member of b.members) a.members.add(member);
    for (const p of b.below) a.below.add(p);
    for (const input of b.inputs) a.inputs.add(input);
    for (const scope of b.scopes) a.scopes.add(scope);
    this.merges++;
    return a;
  }
  pending(node) {
    // Keep original causes while membership is provisional. Resolving a query
    // must not destroy the information needed to revise a later peer join.
    for (const g of node.dirty) if (this.root(g).done) node.dirty.delete(g);
    return [...new Set([...node.dirty].map(g => this.root(g)))];
  }
  choose(node) {
    const groups = this.pending(node).filter(g => !this.admitted || this.admitted.has(g));
    const frontier = groups.filter(g => !groups.some(other => this.above(other, g)));
    return frontier.reduce((a, b) => a ? this.join(a, b) : b, null);
  }
  mark(node, group, seen = new Set()) {
    if (seen.has(node) || node.disposed) return;
    seen.add(node);
    node.dirty.add(group);
    for (const reader of node.readers) this.mark(reader, group, seen);
  }
  invalidate(node, group, seen = new Set(), context = [group]) {
    if (seen.has(node) || node.disposed) return;
    seen.add(node);
    for (const origin of context) node.dirty.add(origin);
    node.fresh.add(context);
    for (const reader of node.readers) this.invalidate(reader, group, seen, context);
  }
  acknowledge(node, group) {
    group = this.root(group);
    for (const context of node.fresh) {
      const pending = context.map(g => this.root(g)).filter(g => !g.done);
      if (!pending.length || pending.some(g => g === group) &&
          pending.every(g => !this.admitted || this.admitted.has(g))) node.fresh.delete(context);
    }
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
      initial.context = [...this.root(initial.group).members];
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
      for (const origin of dep.dirty) this.mark(node, origin);
    if (!owner) for (const origin of node.dirty) node.fresh.add([origin]);
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
    const origin = group;
    if (node.candidate) this.join(group, node.candidate.group);
    node.candidate = { ...this.frame(value), group: origin };
    this.invalidate(node, origin);
    return origin;
  }
  close(group, scope = group.scope) {
    for (const g of this.updates) g.ownScopes.delete(scope);
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
      for (const origin of dep.dirty) this.mark(node, origin);
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
    // A stale promise may retain its answer token. It needs identity only;
    // release obsolete ownership, dependency and update records immediately.
    node.candidate.reads.clear();
    node.candidate.effects.length = 0;
    node.candidate.context = null;
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
        candidate.context = [...this.root(group).members];
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
    for (const reader of node.readers)
      this.invalidate(reader, token.group, new Set(), token.context || [token.group]);
    this.flush();
  }
  inputClosure(input, seen = new Set()) {
    if (seen.has(input)) return seen;
    seen.add(input);
    for (const dep of input.inputs || input.links) this.inputClosure(dep, seen);
    return seen;
  }
  refreshParents() {
    for (const group of this.updates) {
      for (const parent of group.ownBelow) if (this.root(parent).done) group.ownBelow.delete(parent);
      for (const parent of group.below) if (this.root(parent).done) group.below.delete(parent);
    }
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
      node.frame.readGroup = null;
      node.frame.context = null;
      changed.push(node);
      for (const effect of node.frame.effects) callbacks.push({ node, effect });
    }
    group.done = true;
    for (const member of group.members) { member.done = true; this.updates.delete(member); }
    this.joins = this.joins.filter(edge =>
      ![...edge.left, ...edge.right].some(g => g.done));
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
  resetJoins() {
    for (const group of this.updates) {
      group.root = group;
      group.members = new Set([group]);
      group.below = new Set(group.ownBelow);
      group.inputs = new Set(group.ownInputs);
      group.scopes = new Set(group.ownScopes);
    }
  }
  replay(edge) {
    const members = [...edge.left, ...edge.right].filter(g => !g.done);
    const roots = [...new Set(members.map(g => this.root(g)))];
    if (!roots.every(g => this.admitted.has(g))) return false;
    // A peer join that has become an ancestor/child relationship is no longer
    // eligible. Its candidate will be checked against the replacement context.
    if (roots.some(a => roots.some(b => this.above(a, b)))) {
      edge.rejected = true;
      return true;
    }
    roots.reduce((a, b) => a ? this.join(a, b, false) : b, null);
    return true;
  }
  discover() {
    this.discoveryRequested = false;
    this.rebuilding = true;
    const previous = [...this.joins];
    this.resetJoins();
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
        for (let i = previous.length - 1; i >= 0; i--)
          if (this.replay(previous[i])) previous.splice(i, 1);
        for (let pass = 0; pass < 1000; pass++) {
          this.admitted = new Set([...this.admitted].map(g => this.root(g)).filter(g => !g.done));
          const work = this.nodes.filter(node => node.fn && !node.disposed &&
            [...node.fresh].some(context => context.some(g => !this.root(g).done) &&
              context.every(g => this.root(g).done || this.admitted.has(this.root(g)))));
          if (!work.length) break;
          for (const node of work) this.prepare(node);
          if (pass === 999) throw new Error('Fresh preparation did not converge');
        }
        if (this.roots().every(g => this.admitted.has(g))) {
          this.joins = this.joins.filter(edge => !edge.rejected);
          this.rebuiltAt = this.epoch;
          return;
        }
        if (!next.length) throw new Error('Update ancestry has no admissible frontier');
      }
      throw new Error('Context discovery did not converge');
    } finally { this.admitted = null; this.rebuilding = false; }
  }
  flush() {
    if (this.flushing) return;
    this.flushing = true;
    try {
      for (let pass = 0; pass < 1000; pass++) {
        if (this.rebuiltAt !== this.epoch && this.joins.some(edge =>
          [...edge.left, ...edge.right].some(g => g.ownInputs.size || g.ownBelow.size))) this.discover();
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
