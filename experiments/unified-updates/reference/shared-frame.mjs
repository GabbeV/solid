// Executable publication protocol, NOT a scheduler or Solid implementation.
// One shared async memo, multiple consumers, explicit preparation requests.
// A caller chooses which updates to prepare; this does not decide when a lower
// update may interrupt an upper update. No private memo copy per consumer.
export class SharedFrame {
  constructor(values, calculate) {
    this.sources = new Map(Object.entries(values).map(([name, value]) =>
      [name, { value, version: 0, proposal: null }]));
    this.calculate = calculate;
    this.groups = new Map();
    this.observers = new Map();
    this.serial = 0;
    this.flight = null;
    this.frame = { value: calculate(values), error: null };
    this.publications = [];
    this.lifecycle = [];
  }

  snapshot() {
    return { inputs: Object.fromEntries([...this.sources].map(([name, node]) => [name, node.value])),
      value: this.frame.value, error: this.frame.error?.message ?? null };
  }

  propose(group, changes, { open = false } = {}) {
    let update = this.groups.get(group);
    if (!update) this.groups.set(group, update = { open, owesMemo: true });
    update.open = open;
    update.owesMemo = true;
    for (const [name, value] of Object.entries(changes)) {
      const node = this.sources.get(name);
      if (node.proposal && node.proposal.group !== group)
        throw new Error('Same-source action merging is outside this probe');
      node.proposal = { group, value, version: ++this.serial };
    }
  }

  prepare(groups) {
    const selected = new Set(groups);
    for (const group of selected)
      if (!this.groups.has(group)) throw new Error(`Unknown update: ${group}`);
    this.discard();
    const inputs = {}, versions = new Map();
    for (const [name, node] of this.sources) {
      const consume = node.proposal && selected.has(node.proposal.group);
      inputs[name] = consume ? node.proposal.value : node.value;
      versions.set(name, { proposed: Boolean(consume),
        version: consume ? node.proposal.version : node.version });
    }
    let expected, error = null;
    try { expected = this.calculate(inputs); } catch (caught) { error = caught; }
    const token = { id: ++this.serial, selected, inputs, versions,
      ready: false, expected, error, answer: undefined };
    this.flight = token;
    this.lifecycle.push(['create candidate', token.id]);
    return token;
  }

  discard() {
    if (!this.flight) return;
    this.lifecycle.push(['discard candidate', this.flight.id]);
    this.flight = null;
    // Crucially, superseding a calculation does NOT discharge its groups'
    // downstream obligations. Its lower work is owed, not considered finished.
  }

  answer(token, answer = token.expected) {
    if (token !== this.flight) return false;
    token.ready = true;
    token.answer = answer;
    return true;
  }

  close(group) { this.groups.get(group).open = false; }

  mount(name, read = snapshot => snapshot.value) {
    // A mounted reader uses the ONE committed frame. It doesn't choose another
    // context for the memo or read that memo's private pending answer.
    const observer = { read, value: read(this.snapshot()), history: [] };
    observer.history.push(observer.value);
    this.observers.set(name, observer);
    return observer;
  }

  rerun(name) {
    const observer = this.observers.get(name);
    observer.value = observer.read(this.snapshot());
    observer.history.push(observer.value);
    return observer.value;
  }

  unmount(name) { this.observers.delete(name); }

  commit(token = this.flight) {
    if (!token || token !== this.flight || !token.ready) return false;
    if ([...token.selected].some(group => this.groups.get(group).open)) return false;
    // Check generations, including equal-valued writes. A result is not valid
    // just because its numeric request key happens to equal an earlier one.
    for (const [name, read] of token.versions) {
      const node = this.sources.get(name);
      const current = read.proposed ? node.proposal?.version : node.version;
      if (current !== read.version) return false;
    }
    for (const node of this.sources.values()) {
      if (!node.proposal || !token.selected.has(node.proposal.group)) continue;
      node.value = node.proposal.value;
      node.version = node.proposal.version;
      node.proposal = null;
    }
    for (const group of token.selected) this.groups.delete(group);
    this.frame = { value: token.error ? undefined : token.answer, error: token.error };
    this.flight = null;
    this.lifecycle.push(['publish candidate', token.id]);
    const snapshot = this.snapshot();
    this.publications.push(snapshot);
    for (const name of this.observers.keys()) this.rerun(name);
    return true;
  }
}
