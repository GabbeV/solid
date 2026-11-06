// Direct-accessor observation experiment. Callback probing/latest are not here.
import { LifetimeScheduler } from './lifetime-scheduler.mjs';

export class PendingScheduler extends LifetimeScheduler {
  observations = new Map();
  observationRead = null;

  evaluate(node, ...args) {
    const fn = node.fn;
    node.fn = read => {
      const previous = this.observationRead;
      this.observationRead = read;
      try { return fn(read); } finally { this.observationRead = previous; }
    };
    try { return super.evaluate(node, ...args); } finally { node.fn = fn; }
  }
  inputGroup(source) {
    const boundary = this.boundaries.get(source);
    return (boundary?.active && this.choose(boundary.input)) || this.choose(source);
  }
  proposedPending(source) {
    if (!source.frame) return false;
    const candidate = source.candidate;
    if (this.choose(source) && candidate &&
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
    return this.current ? this.observationRead(output) : this.value(output);
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
    for (const node of this.nodes) {
      if (above.has(node) || node.disposed || this.retiring(node, group)) continue;
      if (this.choose(node) === group && !node.candidate?.ready) return false;
    }
    return true;
  }
  coordinateActions() {
    if (super.coordinateActions()) return true;
    for (const record of this.observations.values()) {
      const { source, output, boundary } = record;
      const group = this.inputGroup(source);
      const generation = source.candidate ?? source.frame;
      if (record.retiring) {
        if (!record.retiring.group.done && record.retiring.generation === generation) continue;
        record.retiring = null;
      }
      if (boundary.active && (!group || this.readyBelowObservation(group, output))) {
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
  dispose(node, flush = true) {
    const record = this.observations.get(node);
    if (record) {
      this.observations.delete(node);
      super.dispose(record.output, false);
      super.dispose(record.fallback, false);
    }
    super.dispose(node, flush);
  }
}
