// Reference interpreter for read selection in a newly evaluated scalar graph.
// Deliberately not a scheduler: no Solid imports, publication, owner lifecycle,
// real promises, caches, or production performance claims.
export const WAIT = Symbol("unresolved proposal");
const NONE = Symbol("no published value");

export class ReadModel {
  cuts = new Map();
  groups = new Map();

  cut(name, parents = []) {
    if (this.cuts.has(name)) throw new Error(`Duplicate cut ${name}`);
    for (const parent of parents)
      if (!this.cuts.has(parent)) throw new Error(`Unknown parent ${parent}`);
    this.cuts.set(name, new Set(parents));
    return name;
  }

  group(name, { cut = null, open = true } = {}) {
    if (cut !== null && !this.cuts.has(cut)) throw new Error(`Unknown cut ${cut}`);
    this.groups.set(name, { name, cut, open });
    return name;
  }

  source(name, value = NONE, { cut = null, supports = [], proposal = null } = {}) {
    return { kind: "source", name, value, cut, supports, proposal };
  }

  memo(name, fn) {
    return { kind: "memo", name, fn };
  }

  above(child, ancestor) {
    for (const parent of this.cuts.get(child) || [])
      if (parent === ancestor || this.above(parent, ancestor)) return true;
    return false;
  }

  frontier(cuts) {
    const unique = [...new Set(cuts)];
    return unique.filter(cut => !unique.some(other => this.above(other, cut))).sort();
  }

  masked(groupName, context) {
    const group = this.groups.get(groupName);
    if (!group) throw new Error(`Unknown group ${groupName}`);
    return context.length !== 0 &&
      (group.cut === null || context.some(cut => this.above(cut, group.cut)));
  }

  run(root, context = [], published = false, advancing = []) {
    const supports = new Set(), consumes = new Set(), observes = new Set();
    const reads = [], stack = new Set(), requests = [], children = [];
    let calls = 0;
    const read = node => {
      if (node.kind === "memo") {
        if (stack.has(node)) throw new Error(`Reactive cycle at ${node.name}`);
        stack.add(node);
        calls++;
        try {
          return node.fn(read, {
            // Descriptors only. A real memo can start external work before
            // returning; this interpreter cannot measure or undo that cost.
            request: key => { requests.push(key); return { request: key }; },
            child: key => { children.push(key); }
          });
        } finally {
          stack.delete(node);
        }
      }
      const proposal = node.proposal;
      const useProposal = proposal && !published &&
        (advancing.includes(proposal.group) || !this.masked(proposal.group, context));
      if (proposal) (useProposal ? consumes : observes).add(proposal.group);
      const value = useProposal ? proposal.value : node.value;
      reads.push({ source: node.name, version: useProposal ? "proposal" : "published" });
      if (value === WAIT || value === NONE) throw WAIT;
      if (node.cut !== null) supports.add(node.cut);
      const frameSupports = useProposal ? (proposal.supports || []) : node.supports;
      for (const cut of frameSupports) supports.add(cut);
      return value;
    };
    let value, error, suspended = false;
    try {
      value = read(root);
    } catch (caught) {
      if (caught === WAIT) suspended = true;
      else error = caught;
    }
    return {
      context: [...context], value, error, suspended,
      supports: [...supports].sort(), consumes: [...consumes].sort(),
      observes: [...observes].sort(), reads, requests, children, calls
    };
  }

  supported(plan, inherited = []) {
    // A stronger observed boundary can authorize an ancestor context, but
    // an ancestor alone cannot authorize a child's committed-input reads.
    const witnesses = [...plan.supports, ...inherited];
    return plan.context.every(cut => witnesses.some(w => w === cut || this.above(w, cut)));
  }

  select(root, { policy = "boundary", inherited = [], search = "narrow", advancing = [] } = {}) {
    const attempts = [];
    const evaluate = (context, published = false) => {
      const plan = this.run(root, context, published, advancing);
      attempts.push(plan);
      return plan;
    };
    const finish = (plan, reason) => ({
      ...plan, reason, attempts,
      heldBy: plan.consumes.filter(group => this.groups.get(group).open),
      evaluations: attempts.reduce((sum, attempt) => sum + attempt.calls, 0)
    });
    if (policy === "ordinary") return finish(evaluate([]), "ordinary");
    const discovery = evaluate([], true);
    if (policy === "committed") return finish(discovery, "unrestricted committed mount");
    if (policy !== "boundary") throw new Error(`Unknown policy ${policy}`);

    // Only context witnessed by the committed discovery (or the owner) is
    // initially eligible. A conditional read reached solely through a proposal
    // cannot retrospectively authorize the input that made it reachable.
    const eligible = this.frontier([...discovery.supports, ...inherited]);
    if (!eligible.length) return finish(evaluate([]), "no boundary witness");
    if (search === "narrow") {
      // A conservative alternative to looking for the most permissive
      // context. Never re-add a permission lost during this selection.
      // Every unsuccessful pass removes at least one cut: <= N+1 retries.
      let context = eligible;
      while (context.length) {
        const plan = evaluate(context);
        if (this.supported(plan, inherited))
          return finish(plan, "supported boundary context");
        const witnesses = [...plan.supports, ...inherited];
        context = context.filter(cut => witnesses.some(w => w === cut || this.above(w, cut)));
      }
      return finish(evaluate([]), "lost boundary witness");
    }
    if (search !== "exhaustive") throw new Error(`Unknown search ${search}`);
    if (eligible.length > 10) throw new Error("Reference search limited to ten cuts");

    // Exhaustive, bounded reference search. This is explicitly NOT a proposed
    // production algorithm or permission to keep several async frames alive.
    const valid = [];
    for (let mask = 1; mask < (1 << eligible.length); mask++) {
      const context = eligible.filter((_, index) => mask & (1 << index));
      const plan = evaluate(context);
      if (this.supported(plan, inherited)) valid.push(plan);
    }
    const maximal = valid.filter(plan => !valid.some(other =>
      other.context.length > plan.context.length &&
      plan.context.every(cut => other.context.includes(cut))
    ));
    if (maximal.length === 1) return finish(maximal[0], "supported boundary context");
    // Do not pick a winning value by iteration order or by async readiness.
    // An ambiguous/ineligible escape conservatively retains entanglement.
    return finish(evaluate([]), maximal.length ? "ambiguous contexts" : "lost boundary witness");
  }
}

export function summary(plan) {
  return {
    value: plan.value,
    suspended: plan.suspended,
    error: plan.error?.message,
    context: plan.context,
    consumes: plan.consumes,
    observes: plan.observes,
    heldBy: plan.heldBy,
    reason: plan.reason,
    evaluations: plan.evaluations
  };
}
