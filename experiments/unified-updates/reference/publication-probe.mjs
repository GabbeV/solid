// A deliberately bounded coordination probe: several scalar producers, ONE
// asynchronous consequence, and observable commits. Not a general graph runtime.
// There is one eligible answer token; old answers have no publication rights.
export class PublicationProbe {
  constructor(model, sources, consequence) {
    this.model = model;
    this.sources = sources;
    this.consequence = consequence;
    this.value = undefined;
    this.flight = null;
    this.serial = 0;
    this.frames = [];
    this.waiters = [];
    this.committed = new Set();
    this.cohorts = [];
  }

  join(groups) {
    const combined = new Set(groups);
    for (let i = this.cohorts.length - 1; i >= 0; i--) {
      if ([...this.cohorts[i]].some(group => combined.has(group))) {
        for (const group of this.cohorts.splice(i, 1)[0]) combined.add(group);
      }
    }
    if (combined.size) this.cohorts.push(combined);
  }

  afterCommit(group, callback) {
    this.waiters.push({ group, callback });
  }

  snapshot() {
    return { sources: this.sources.map(source => source.value), consequence: this.value };
  }

  flush() {
    // Advancing an externally ready input is a request to revalidate its
    // committed readers BEFORE publication, not permission to publish first.
    const advancing = [];
    let plan;
    for (;;) {
      plan = this.model.select(this.consequence, { advancing });
      const next = plan.observes.filter(group =>
        !advancing.includes(group) && !this.model.groups.get(group).open
      );
      if (!next.length) break;
      // Each pass adds a previously unprocessed ready input, including an
      // optimistic parent. No callback/waiter can reinsert itself here.
      advancing.push(...next);
    }
    this.plan = plan;
    this.join(plan.consumes);
    if (plan.suspended) return;
    if (plan.error) throw plan.error; // Error publication deliberately not modeled yet.
    const key = plan.value;
    if (!this.flight || !Object.is(this.flight.key, key)) {
      this.flight = { id: ++this.serial, key, ready: false, answer: undefined };
    }

    const ready = cohort => [...cohort].every(group => !this.model.groups.get(group).open);
    const cohortFor = group => this.cohorts.find(cohort => cohort.has(group)) || new Set([group]);
    const selected = new Set(plan.consumes);
    for (const group of plan.consumes)
      for (const peer of cohortFor(group)) selected.add(peer);
    const canPublishConsequence = this.flight.ready && ready(selected);
    let changed = false;
    const landed = new Set();
    for (const source of this.sources) {
      const proposal = source.proposal;
      if (!proposal) continue;
      const cohort = cohortFor(proposal.group);
      if (!ready(cohort)) continue;
      if ([...cohort].some(group => selected.has(group)) && !canPublishConsequence) continue;
      // A ready observed input must have been consumed by revalidation. Failing
      // this assertion is a protocol defect, not a reason to commit it anyway.
      if (plan.observes.includes(proposal.group))
        throw new Error(`Unrevalidated input: ${proposal.group}`);
      source.value = proposal.value;
      source.proposal = null;
      landed.add(proposal.group);
      changed = true;
    }
    if (canPublishConsequence && !Object.is(this.value, this.flight.answer)) {
      this.value = this.flight.answer;
      changed = true;
    }
    if (changed) this.frames.push(this.snapshot());
    for (const group of landed) this.committed.add(group);
    this.cohorts = this.cohorts.filter(cohort => ![...cohort].every(group => this.committed.has(group)));

    // Delivery has its own phase. A waiter is never a preparation obligation.
    const deliver = this.waiters.filter(waiter => this.committed.has(waiter.group));
    this.waiters = this.waiters.filter(waiter => !this.committed.has(waiter.group));
    for (const waiter of deliver) waiter.callback(this.snapshot());
  }

  answer(token, value = token.key) {
    if (token !== this.flight) return false;
    token.ready = true;
    token.answer = value;
    this.flush();
    return true;
  }
}
