import Base
import ./memo-setter-cuts.bend as Cuts
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-history-states.bend as M
import ./memo-history-setter-data.bend as D

def origin(+prior: Bool, +tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {M.origin(prior, tick, previous, events, jobs) == D.origin(prior, tick, previous, events, jobs) : R.World}:
  match prior:
    case True{}: {==}
    case False{}: {==}

def queue(+prior: Bool, +tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {W.queuePendingNode(D.origin(prior, tick, previous, events, jobs), 2n) == D.queued(prior, tick, previous, events, jobs) : R.World}:
  match prior:
    case True{}: {==}
    case False{}: {==}

def slot(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {B.store_node(D.queued(prior, tick, previous, events, jobs), 2n, R.Node.with_pending(B.node(D.queued(prior, tick, previous, events, jobs), 2n), R.Present{R.Number{input}})) == D.slotted(prior, tick, previous, input, events, jobs) : R.World}:
  match prior:
    case True{}: {==}
    case False{}: {==}

def stamp(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {B.store_node(D.slotted(prior, tick, previous, input, events, jobs), 2n, R.Node.with_notified(B.node(D.slotted(prior, tick, previous, input, events, jobs), 2n), R.Stamped{R.World.epoch(D.slotted(prior, tick, previous, input, events, jobs))})) == D.stamped(prior, tick, previous, input, events, jobs) : R.World}:
  match prior:
    case True{}: {==}
    case False{}: {==}

def insert(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {H.enqueueSub(D.stamped(prior, tick, previous, input, events, jobs), 3n) == D.inserted(prior, tick, previous, input, events, jobs) : R.World}:
  match prior:
    case True{}: {==}
    case False{}: {==}

def schedule(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {B.schedule(D.inserted(prior, tick, previous, input, events, jobs)) == D.scheduled(prior, tick, previous, input, events, jobs) : R.World}:
  match prior:
    case True{}: {==}
    case False{}: {==}

def prefix(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {Cuts.noSlot(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{input}) == D.slotted(prior, tick, previous, input, events, jobs) : R.World}:
  match prior:
    case True{}: {==}
    case False{}: {==}

def notify(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {W.insertSubs(D.slotted(prior, tick, previous, input, events, jobs), 2n) == D.inserted(prior, tick, previous, input, events, jobs) : R.World}:
  match prior:
    case True{}: {==}
    case False{}: {==}
